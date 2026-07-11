package dao;

import dbutils.DBContext;
import dto.RewardRedemption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO CHỈ ĐỌC cho bảng RewardRedemptions (kho voucher của khách).
 * Hành động TẠO voucher (đổi điểm thật hoặc hệ thống tự cấp khi hủy lịch)
 * nằm bên service/LoyaltyService.java để mọi thao tác ghi vào điểm/voucher
 * đi qua đúng 1 chỗ, tránh 2 nơi cùng ghi dữ liệu gây lệch sổ sách.
 */
public class RewardRedemptionDAO {

    /**
     * Lấy danh sách voucher của 1 khách, lọc theo trạng thái.
     * @param customerId  LƯU Ý: CustomerId (cus.getCustomerId()), KHÔNG PHẢI AccountId
     * @param statusFilter "ALL" hoặc đúng 1 trong "Available" / "Used" / "Expired"
     */
    public List<RewardRedemption> getMyRedemptions(int customerId, String statusFilter) {
        List<RewardRedemption> list = new ArrayList<>();

        String sql = "SELECT rr.*, r.RewardName, r.Description, r.DiscountPercent, "
                + "       r.MinBillAmount, r.MaxDiscountAmount "
                + "FROM RewardRedemptions rr "
                + "JOIN Rewards r ON rr.RewardId = r.RewardId "
                + "WHERE rr.CustomerId = ? AND (? = 'ALL' OR rr.Status = ?) "
                + "ORDER BY rr.RedeemedAt DESC";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, statusFilter);
            ps.setString(3, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số voucher theo từng trạng thái - dùng để hiện số trên 3 tab
     * (Khả dụng / Đã dùng / Hết hạn) mà không cần tải hết dữ liệu về.
     */
    public int countByStatus(int customerId, String status) {
        int count = 0;
        String sql = "SELECT COUNT(*) AS Total FROM RewardRedemptions WHERE CustomerId = ? AND Status = ?";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count = rs.getInt("Total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    private RewardRedemption mapRow(ResultSet rs) throws SQLException {
        RewardRedemption rr = new RewardRedemption();
        rr.setRedemptionId(rs.getInt("RedemptionId"));
        rr.setCustomerId(rs.getInt("CustomerId"));
        rr.setRewardId(rs.getInt("RewardId"));
        rr.setPointsUsed(rs.getInt("PointsUsed"));
        rr.setRedeemedAt(rs.getTimestamp("RedeemedAt"));
        rr.setStatus(rs.getString("Status"));

        int usedBookingId = rs.getInt("UsedBookingId");
        rr.setUsedBookingId(rs.wasNull() ? null : usedBookingId);
        rr.setUsedAt(rs.getTimestamp("UsedAt"));

        rr.setRewardName(rs.getString("RewardName"));
        rr.setDescription(rs.getString("Description"));
        rr.setDiscountPercent(rs.getDouble("DiscountPercent"));
        rr.setMinBillAmount(rs.getDouble("MinBillAmount"));
        rr.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
        return rr;
    }
}