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
                // LỆNH 1: Lấy chi tiêu thực tế và đặc quyền hạng hiện tại của khách hàng
                String sqlCurrent = "SELECT cl.*, t.* FROM CustomerLoyalty cl "
                                  + "JOIN LoyaltyTiers t ON cl.CurrentTierId = t.TierId "
                                  + "WHERE cl.AccountId = ?";
                
                ps1 = conn.prepareStatement(sqlCurrent);
                ps1.setInt(1, accountId);
                rs1 = ps1.executeQuery();

                if (rs1.next()) {
                    loyalty = new CustomerLoyalty();
                    loyalty.setAccountId(rs1.getInt("AccountId"));
                    loyalty.setCurrentPoints(rs1.getInt("CurrentPoints"));
                    loyalty.setTotalSpent(rs1.getDouble("TotalSpent"));
                    loyalty.setTotalWashCount(rs1.getInt("TotalWashCount"));

                    LoyaltyTier currentTier = new LoyaltyTier();
                    currentTier.setTierName(rs1.getString("TierName"));
                    currentTier.setBonusPointRate(rs1.getDouble("BonusPointRate"));
                    currentTier.setBookingWindowDays(rs1.getInt("BookingWindowDays"));
                    currentTier.setHasPriorityQueue(rs1.getBoolean("HasPriorityQueue"));
                    currentTier.setFreeUpgradeMonthly(rs1.getBoolean("FreeUpgradeMonthly"));
                    currentTier.setFreeWashMonthly(rs1.getBoolean("FreeWashMonthly"));
                    loyalty.setCurrentTierDetails(currentTier);
                } else {
                    // BỔ SUNG: Trường hợp tài khoản mới tinh, chưa có bản ghi trong bảng CustomerLoyalty
                    loyalty = new CustomerLoyalty();
                    loyalty.setAccountId(accountId);
                    loyalty.setCurrentPoints(0);
                    loyalty.setTotalSpent(0.0);
                    loyalty.setTotalWashCount(0);

                    // Gán mặc định hạng đầu tiên (Thường là Member)
                    LoyaltyTier defaultTier = new LoyaltyTier();
                    defaultTier.setTierName("Member");
                    defaultTier.setBonusPointRate(0.0);
                    defaultTier.setBookingWindowDays(7); // Theo tài liệu SRS của nhóm
                    defaultTier.setHasPriorityQueue(false);
                    loyalty.setCurrentTierDetails(defaultTier);
                }

                // LỆNH 2: Truy vấn Hạng kế tiếp từ DB (Next Reward) dựa trên chi tiêu thực tế
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
                        nextTier.setMinTotalSpent(rs2.getDouble("MinTotalSpent"));
                        nextTier.setMinWashCount(rs2.getInt("MinWashCount"));
                        
                        loyalty.setNextTierDetails(nextTier);
                    }
                    // Nếu không có dòng nào (rs2.next() == false), nghĩa là khách đã đạt hạng tối cao (Platinum). 
                    // Thuộc tính nextTierDetails giữ nguyên là null, FE sẽ dựa vào đó để hiển thị chúc mừng.
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            try { 
                if (rs1 != null) rs1.close(); 
                if (rs2 != null) rs2.close(); 
            } catch (SQLException e) {
                e.printStackTrace();
            }
            try { 
                if (ps1 != null) ps1.close(); 
                if (ps2 != null) ps2.close(); } 
            catch (SQLException e) {
                e.printStackTrace();
            }
            try { 
                if (conn != null) conn.close(); 
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return loyalty;
    }
}
