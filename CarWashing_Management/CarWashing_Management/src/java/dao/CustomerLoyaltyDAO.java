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
                    
                    // Ép kiểu DECIMAL từ Database về int theo yêu cầu của bạn
                    loyalty.setTotalSpent((int) rs1.getDouble("TotalSpent"));
                    loyalty.setTotalWashCount(rs1.getInt("TotalWashCount"));

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
                    loyalty.setTotalSpent(0);
                    loyalty.setTotalWashCount(0);

                    LoyaltyTier defaultTier = new LoyaltyTier();
                    defaultTier.setTierName("Member"); // Chỉ dùng tiếng Anh theo thống nhất
                    defaultTier.setBonusPointRate(0.0);
                    defaultTier.setBookingWindowDays(7); 
                    defaultTier.setHasPriorityQueue(false);
                    loyalty.setCurrentTierDetails(defaultTier);
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

        return loyalty;
    }
}
