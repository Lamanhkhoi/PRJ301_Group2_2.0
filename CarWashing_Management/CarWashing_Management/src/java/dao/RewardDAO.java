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
                = "SELECT * FROM Rewards ORDER BY RewardId DESC";

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
