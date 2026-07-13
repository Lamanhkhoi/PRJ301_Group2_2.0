package dao;

import dbutils.DBContext;
import dto.Reward;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;

public class RewardDAO {

    public List<Reward> getAllRewards() {

        List<Reward> list = new ArrayList<>();

        String sql
                = "SELECT\n"
                + "    RewardId,\n"
                + "    RewardName,\n"
                + "    Description,\n"
                + "    PointsRequired,\n"
                + "    DiscountPercent,\n"
                + "    MinBillAmount,\n"
                + "    MaxDiscountAmount,\n"
                + "    IsActive,\n"
                + "    CreatedAt\n"
                + "FROM Rewards\n"
                + "ORDER BY RewardId DESC";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Reward r = new Reward();

                r.setRewardId(rs.getInt("RewardId"));
                r.setRewardName(rs.getString("RewardName"));
                r.setDescription(rs.getString("Description"));

                r.setPointsRequired(
                        rs.getInt("PointsRequired"));

                r.setDiscountPercent(
                        rs.getDouble("DiscountPercent"));

                r.setMinBillAmount(
                        rs.getDouble("MinBillAmount"));

                r.setMaxDiscountAmount(
                        rs.getDouble("MaxDiscountAmount"));

                r.setActive(
                        rs.getBoolean("IsActive"));

                r.setCreatedAt(
                        rs.getTimestamp("CreatedAt"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean insertReward(Reward reward) {

        System.out.println("===== INSERT DAO =====");

        String sql
                = "INSERT INTO Rewards "
                + "(RewardName, Description, PointsRequired, DiscountPercent, MinBillAmount, MaxDiscountAmount, IsActive) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {

            System.out.println(sql);

            ps.setString(1, reward.getRewardName());
            ps.setString(2, reward.getDescription());
            ps.setInt(3, reward.getPointsRequired());
            ps.setDouble(4, reward.getDiscountPercent());
            ps.setDouble(5, reward.getMinBillAmount());
            ps.setDouble(6, reward.getMaxDiscountAmount());
            ps.setBoolean(7, reward.isActive());

            int row = ps.executeUpdate();

            System.out.println("Rows affected = " + row);

            return row > 0;

        } catch (Exception e) {

            System.out.println("========== SQL ERROR ==========");
            e.printStackTrace();

            return false;
        }
    }

    public boolean updateStatus(int rewardId, boolean active) {

        String sql = "UPDATE Rewards SET IsActive = ? WHERE RewardId = ?";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, rewardId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteReward(int rewardId) {

        String sql = "UPDATE Rewards SET IsActive = 0 WHERE RewardId = ?";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, rewardId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Reward> searchReward(String keyword) {

        List<Reward> list = new ArrayList<>();

        String sql
                = "SELECT * FROM Rewards "
                + "WHERE IsActive = 1 "
                + "ORDER BY RewardId DESC";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Reward r = new Reward();

                r.setRewardId(rs.getInt("RewardId"));
                r.setRewardName(rs.getString("RewardName"));
                r.setDescription(rs.getString("Description"));
                r.setPointsRequired(rs.getInt("PointsRequired"));
                r.setDiscountPercent(rs.getDouble("DiscountPercent"));
                r.setMinBillAmount(rs.getDouble("MinBillAmount"));
                r.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                r.setActive(rs.getBoolean("IsActive"));
                r.setCreatedAt(rs.getTimestamp("CreatedAt"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateReward(Reward reward) {

        String sql
                = "UPDATE Rewards "
                + "SET RewardName = ?, "
                + "Description = ?, "
                + "PointsRequired = ?, "
                + "DiscountPercent = ?, "
                + "MinBillAmount = ?, "
                + "MaxDiscountAmount = ?, "
                + "IsActive = ? "
                + "WHERE RewardId = ?";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, reward.getRewardName());
            ps.setString(2, reward.getDescription());
            ps.setInt(3, reward.getPointsRequired());
            ps.setDouble(4, reward.getDiscountPercent());
            ps.setDouble(5, reward.getMinBillAmount());
            ps.setDouble(6, reward.getMaxDiscountAmount());
            ps.setBoolean(7, reward.isActive());
            ps.setInt(8, reward.getRewardId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    /**
     * Dành RIÊNG cho catalog đổi thưởng của khách hàng (customer_rewards.jsp).
     * KHÁC getAllRewards() ở chỗ chỉ lấy IsActive = 1 - để ẩn khỏi mắt khách
     * những reward đang tắt, và đặc biệt là các reward hệ thống tự cấp khi
     * đền bù hủy lịch (LoyaltyService.handleBookingCancelled tạo với IsActive=0,
     * PointsRequired=0 - khách KHÔNG được thấy để tự đổi những dòng này).
     * Sắp theo điểm cần thấp -> cao cho dễ nhìn.
     */
    public List<Reward> getActiveRewards() {

        List<Reward> list = new ArrayList<>();

        String sql
                = "SELECT * FROM Rewards WHERE IsActive = 1 ORDER BY PointsRequired ASC";

        try (
                 Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Reward r = new Reward();

                r.setRewardId(rs.getInt("RewardId"));
                r.setRewardName(rs.getString("RewardName"));
                r.setDescription(rs.getString("Description"));

                r.setPointsRequired(
                        rs.getInt("PointsRequired"));

                r.setDiscountPercent(
                        rs.getDouble("DiscountPercent"));

                r.setMinBillAmount(
                        rs.getDouble("MinBillAmount"));

                r.setMaxDiscountAmount(
                        rs.getDouble("MaxDiscountAmount"));

                r.setActive(
                        rs.getBoolean("IsActive"));

                r.setCreatedAt(
                        rs.getTimestamp("CreatedAt"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

}