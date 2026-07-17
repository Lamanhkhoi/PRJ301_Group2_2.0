package dao;

import dbutils.DBContext;
import dto.Promotion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAO {

    //==========================
    // Lấy toàn bộ Promotion
    //==========================
    public List<Promotion> getAllPromotion() {

        List<Promotion> list = new ArrayList<>();

        String sql = "SELECT * FROM Promotions ORDER BY PromotionId DESC";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Promotion p = new Promotion();

                p.setPromotionId(rs.getInt("PromotionId"));
                p.setPromotionName(rs.getString("PromotionName"));
                p.setDescription(rs.getString("Description"));

                p.setDiscountPercent(rs.getDouble("DiscountPercent"));
                p.setMinBillAmount(rs.getDouble("MinBillAmount"));
                p.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));

                p.setStartDate(rs.getTimestamp("StartDate"));
                p.setEndDate(rs.getTimestamp("EndDate"));

                p.setActive(rs.getBoolean("IsActive"));

                p.setCreatedAt(rs.getTimestamp("CreatedAt"));

                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    //==========================
    // Lấy Promotion theo ID
    //==========================
    public Promotion getPromotionById(int id) {

        String sql = "SELECT * FROM Promotions WHERE PromotionId=?";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                Promotion p = new Promotion();

                p.setPromotionId(rs.getInt("PromotionId"));
                p.setPromotionName(rs.getString("PromotionName"));
                p.setDescription(rs.getString("Description"));

                p.setDiscountPercent(rs.getDouble("DiscountPercent"));
                p.setMinBillAmount(rs.getDouble("MinBillAmount"));
                p.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));

                p.setStartDate(rs.getTimestamp("StartDate"));
                p.setEndDate(rs.getTimestamp("EndDate"));

                p.setActive(rs.getBoolean("IsActive"));

                p.setCreatedAt(rs.getTimestamp("CreatedAt"));

                return p;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    //==========================
    // Insert
    //==========================
    public boolean insertPromotion(Promotion p) {

        String sql = "INSERT INTO Promotions("
                + "PromotionName,"
                + "Description,"
                + "DiscountPercent,"
                + "MinBillAmount,"
                + "MaxDiscountAmount,"
                + "StartDate,"
                + "EndDate,"
                + "IsActive)"
                + " VALUES(?,?,?,?,?,?,?,?)";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getPromotionName());
            ps.setString(2, p.getDescription());

            ps.setDouble(3, p.getDiscountPercent());
            ps.setDouble(4, p.getMinBillAmount());
            ps.setDouble(5, p.getMaxDiscountAmount());

            ps.setTimestamp(6, p.getStartDate());
            ps.setTimestamp(7, p.getEndDate());

            ps.setBoolean(8, p.isActive());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    //==========================
    // Update
    //==========================
    public boolean updatePromotion(Promotion p) {

        String sql = "UPDATE Promotions SET "
                + "PromotionName=?,"
                + "Description=?,"
                + "DiscountPercent=?,"
                + "MinBillAmount=?,"
                + "MaxDiscountAmount=?,"
                + "StartDate=?,"
                + "EndDate=? "
                + "WHERE PromotionId=?";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getPromotionName());
            ps.setString(2, p.getDescription());

            ps.setDouble(3, p.getDiscountPercent());
            ps.setDouble(4, p.getMinBillAmount());
            ps.setDouble(5, p.getMaxDiscountAmount());

            ps.setTimestamp(6, p.getStartDate());
            ps.setTimestamp(7, p.getEndDate());

            ps.setInt(8, p.getPromotionId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    //==========================
    // Bật / Tắt Promotion
    //==========================
    public boolean updateStatus(int id, boolean active) {

        String sql = "UPDATE Promotions SET IsActive=? WHERE PromotionId=?";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    //==========================
    // Delete thật
    //==========================
    public boolean deletePromotion(int id) {

        String sql = "DELETE FROM Promotions WHERE PromotionId=?";

        try (
                Connection con = DBContext.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

}