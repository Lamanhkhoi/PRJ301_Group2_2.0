package dao;

import dbutils.DBContext;
import dto.CustomerLoyalty;
import dto.LoyaltyTier;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CustomerLoyaltyDAO {
    public CustomerLoyalty getLoyaltyProfileByAccountId(int accountId) {
        CustomerLoyalty loyalty = null;
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet rs1 = null;
        ResultSet rs2 = null;

        try {
            conn = DBContext.getConnection();
            if (conn != null) {
                // LỆNH 1: Lấy thông tin tài khoản loyalty thực tế kết hợp đặc quyền Hạng Hiện Tại
                String sqlCurrent = "SELECT cl.*, t.* FROM CustomerLoyalty cl "
                                  + "JOIN LoyaltyTiers t ON cl.CurrentTierId = t.TierId "
                                  + "WHERE cl.AccountId = ?";
                
                ps1 = conn.prepareStatement(sqlCurrent);
                ps1.setInt(1, accountId);
                rs1 = ps1.executeQuery();

                if (rs1.next()) {
                    loyalty = new CustomerLoyalty();
                    // Lưu ý: Đặt tên hàm set tương ứng với cấu trúc thuộc tính DTO của bạn
                    loyalty.setAccountId(rs1.getInt("AccountId"));
                    loyalty.setCurrentPoints(rs1.getInt("CurrentPoints"));
                    loyalty.setLifetimeEarnedPoints(rs1.getInt("LifetimeEarnedPoints"));
                    loyalty.setLifetimeRedeemedPoints(rs1.getInt("LifetimeRedeemedPoints"));
                    
                    // ĐÃ SỬA: KHÔNG đọc TotalSpent/TotalWashCount từ cột DB nữa (2 cột này đứng yên,
                    // không có code nào cập nhật - xem ghi chú dưới). Tính lại bằng rolling-window
                    // 12 tháng NGAY BÊN DƯỚI, gán đè vào 2 field này để "hạng kế tiếp" và "% tiến
                    // trình" phía dưới dùng ĐÚNG CÙNG con số đã quyết định CurrentTierId, tránh
                    // tình trạng badge ghi "Gold" nhưng thanh tiến trình lại tính theo số liệu khác.
                    loyalty.setTotalSpent(0);   // sẽ gán đè lại ngay sau khối này
                    loyalty.setTotalWashCount(0);

                    // Đọc cấu hình chi tiết đặc quyền từ bảng LoyaltyTiers
                    LoyaltyTier currentTier = new LoyaltyTier();
                    currentTier.setTierName(rs1.getString("TierName"));
                    currentTier.setBonusPointRate(rs1.getDouble("BonusPointRate"));
                    currentTier.setBookingWindowDays(rs1.getInt("BookingWindowDays"));
                    currentTier.setHasPriorityQueue(rs1.getBoolean("HasPriorityQueue"));
                    currentTier.setFreeUpgradeMonthly(rs1.getBoolean("FreeUpgradeMonthly"));
                    currentTier.setFreeWashMonthly(rs1.getBoolean("FreeWashMonthly"));
                    
                    loyalty.setCurrentTierDetails(currentTier);
                } else {
                    // Nếu tài khoản mới chưa có bản ghi trong bảng CustomerLoyalty, tự khởi tạo mức cơ bản
                    loyalty = new CustomerLoyalty();
                    loyalty.setAccountId(accountId);
                    loyalty.setCurrentPoints(0);
                    loyalty.setLifetimeEarnedPoints(0);
                    loyalty.setLifetimeRedeemedPoints(0);
                    loyalty.setTotalSpent(0);
                    loyalty.setTotalWashCount(0);

                    LoyaltyTier defaultTier = new LoyaltyTier();
                    defaultTier.setTierName("Member"); // Chỉ dùng tiếng Anh theo thống nhất
                    defaultTier.setBonusPointRate(0.0);
                    defaultTier.setBookingWindowDays(7); 
                    defaultTier.setHasPriorityQueue(false);
                    loyalty.setCurrentTierDetails(defaultTier);
                }

                // LỆNH 1.5: Tính lại "hoạt động gần đây" (rolling-window 12 tháng) TRỰC TIẾP từ
                // Bookings + Payments - THAY THẾ cho CustomerLoyalty.TotalWashCount/TotalSpent
                // (2 cột đó hiện không có bất kỳ code nào cập nhật, chỉ là số seed đứng yên).
                // Công thức PHẢI KHỚP với LoyaltyService.recalculateAllTiers(12) để badge hạng và
                // % tiến trình luôn đồng nhất với nhau. LƯU Ý: số "12" đang lặp lại ở 2 file khác
                // nhau (đây và LoyaltyService) - nếu sau này đổi độ dài cửa sổ, nhớ sửa CẢ HAI chỗ,
                // tốt nhất nên tách ra 1 hằng số dùng chung.
                if (loyalty != null) {
                    String sqlRecent = "SELECT ISNULL(COUNT(b.BookingId), 0) AS RecentWashCount, "
                            + "       ISNULL(SUM(p.FinalAmount), 0) AS RecentSpent "
                            + "FROM Customers cust "
                            + "LEFT JOIN Bookings b ON b.CustomerId = cust.CustomerId "
                            + "    AND b.BookingStatus = N'Completed' "
                            + "    AND b.CompletedAt >= DATEADD(MONTH, -12, SYSDATETIME()) "
                            + "LEFT JOIN Payments p ON p.BookingId = b.BookingId AND p.IsPaid = 1 "
                            + "WHERE cust.AccountId = ?";
                    PreparedStatement ps3 = null;
                    ResultSet rs3 = null;
                    try {
                        ps3 = conn.prepareStatement(sqlRecent);
                        ps3.setInt(1, accountId);
                        rs3 = ps3.executeQuery();
                        if (rs3.next()) {
                            loyalty.setTotalWashCount(rs3.getInt("RecentWashCount"));
                            loyalty.setTotalSpent((int) rs3.getDouble("RecentSpent"));
                        }
                        // Nếu không có dòng nào (accountId không có Customers tương ứng - hiếm gặp,
                        // vd tài khoản Admin lỡ có CustomerLoyalty) -> giữ nguyên 0 đã set ở trên.
                    } finally {
                        try { if (rs3 != null) rs3.close(); } catch (SQLException e) {}
                        try { if (ps3 != null) ps3.close(); } catch (SQLException e) {}
                    }
                }

                // LỆNH 2: Xác định chính xác "Next Reward" (Hạng mục tiêu liền kề tiếp theo)
                if (loyalty != null) {
                    String sqlNext = "SELECT TOP 1 * FROM LoyaltyTiers "
                                   + "WHERE MinTotalSpent > ? OR MinWashCount > ? "
                                   + "ORDER BY MinTotalSpent ASC, MinWashCount ASC";
                    
                    ps2 = conn.prepareStatement(sqlNext);
                    ps2.setDouble(1, loyalty.getTotalSpent());
                    ps2.setInt(2, loyalty.getTotalWashCount());
                    rs2 = ps2.executeQuery();

                    if (rs2.next()) {
                        LoyaltyTier nextTier = new LoyaltyTier();
                        nextTier.setTierName(rs2.getString("TierName"));
                        nextTier.setBonusPointRate(rs2.getDouble("BonusPointRate"));
                        nextTier.setBookingWindowDays(rs2.getInt("BookingWindowDays"));
                        nextTier.setHasPriorityQueue(rs2.getBoolean("HasPriorityQueue"));
                        nextTier.setFreeUpgradeMonthly(rs2.getBoolean("FreeUpgradeMonthly"));
                        nextTier.setFreeWashMonthly(rs2.getBoolean("FreeWashMonthly"));
                        
                        // Lấy mốc điều kiện thăng hạng để gửi ra ngoài Front-End làm phép trừ tính độ lệch
                        nextTier.setMinTotalSpent((int) rs2.getDouble("MinTotalSpent"));
                        nextTier.setMinWashCount(rs2.getInt("MinWashCount"));
                        
                        loyalty.setNextTierDetails(nextTier);
                    }
                    // Nếu không tìm thấy rs2.next(), nextTierDetails giữ giá trị null (Nghĩa là hạng MAX - Platinum)
                    
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs1 != null) rs1.close(); if (rs2 != null) rs2.close(); } catch (SQLException e) {}
            try { if (ps1 != null) ps1.close(); if (ps2 != null) ps2.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
        
        if (loyalty != null) {
            LoyaltyTier currentTier = loyalty.getCurrentTierDetails();
            LoyaltyTier nextTier = loyalty.getNextTierDetails();
            String currentRank = (currentTier != null) ? currentTier.getTierName() : "Member";

            // 1. Cấu hình màu sắc thẻ theo Hạng thành viên
            loyalty.setBgClass("bg-white border-slate-100");
            loyalty.setTextClass("text-slate-800");
            loyalty.setLabelClass("text-slate-500");
            loyalty.setIconColor("text-slate-400");
            loyalty.setIconClass("fa-user");
            loyalty.setCurrentBenefits("1 điểm thưởng = 1.000 VNĐ chi tiêu");

            if ("Silver".equalsIgnoreCase(currentRank)) {
                loyalty.setBgClass("bg-gradient-to-br from-slate-100 to-gray-200 border-gray-300");
                loyalty.setTextClass("text-gray-900");
                loyalty.setLabelClass("text-gray-600");
                loyalty.setIconColor("text-gray-500");
                loyalty.setIconClass("fa-shield-halved");
                loyalty.setCurrentBenefits("Thưởng " + (int)(currentTier.getBonusPointRate()) + "%");
            } else if ("Gold".equalsIgnoreCase(currentRank)) {
                loyalty.setBgClass("bg-gradient-to-br from-yellow-50 to-amber-100 border-yellow-200");
                loyalty.setTextClass("text-yellow-900");
                loyalty.setLabelClass("text-yellow-700");
                loyalty.setIconColor("text-yellow-500");
                loyalty.setIconClass("fa-crown");
                loyalty.setCurrentBenefits("Thưởng " + (int)(currentTier.getBonusPointRate()) + "%");
            } else if ("Platinum".equalsIgnoreCase(currentRank)) {
                loyalty.setBgClass("bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 border-purple-200");
                loyalty.setTextClass("text-purple-900");
                loyalty.setLabelClass("text-purple-700");
                loyalty.setIconColor("text-purple-500");
                loyalty.setIconClass("fa-gem");
                loyalty.setCurrentBenefits("Thưởng " + (int)(currentTier.getBonusPointRate()) + "%");
            }

            // 2. Tính toán phần trăm tiến trình lên hạng
            int wPercent = 100;
            int sPercent = 100;
            if (nextTier != null) {
                wPercent = (int) Math.min(100, ((double) loyalty.getTotalWashCount() / nextTier.getMinWashCount()) * 100);
                sPercent = (int) Math.min(100, (loyalty.getTotalSpent() / nextTier.getMinTotalSpent()) * 100);
            }
            loyalty.setWashPercent(wPercent);
            loyalty.setSpentPercent(sPercent);

            // 3. Tính toán độ lệch SVG (Chu vi vòng tròn là 226)
            int c = 226;
            loyalty.setWashOffset(c - (c * wPercent) / 100);
            loyalty.setSpentOffset(c - (c * sPercent) / 100);
        }
        
        return loyalty;
    }
}