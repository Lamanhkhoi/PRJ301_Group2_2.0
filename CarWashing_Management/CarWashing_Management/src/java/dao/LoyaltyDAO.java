package dao;

import dto.LoyaltyTier;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import dbutils.DBContext;

public class LoyaltyDAO extends DBContext {

    public List<LoyaltyTier> getAllTiers() {

        List<LoyaltyTier> list = new ArrayList<>();

        String sql =
                "SELECT * FROM LoyaltyTiers ORDER BY TierId";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                LoyaltyTier t = new LoyaltyTier();

                t.setTierId(rs.getInt("TierId"));
                t.setTierName(rs.getString("TierName"));

                t.setMinWashCount(rs.getInt("MinWashCount"));
                t.setMinTotalSpent(rs.getDouble("MinTotalSpent"));

                t.setBasePointRate(rs.getDouble("BasePointRate"));
                t.setBonusPointRate(rs.getDouble("BonusPointRate"));

                t.setBookingWindowDays(rs.getInt("BookingWindowDays"));

                t.setPriorityLevel(rs.getInt("PriorityLevel"));

                t.setHasPriorityQueue(
                        rs.getBoolean("HasPriorityQueue"));

                t.setFreeUpgradeMonthly(
                        rs.getBoolean("FreeUpgradeMonthly"));

                t.setFreeWashMonthly(
                        rs.getBoolean("FreeWashMonthly"));

                t.setIsActive(
                        rs.getBoolean("IsActive"));

                list.add(t);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateTier(LoyaltyTier t) {

        String sql =
                "UPDATE LoyaltyTiers "
                + "SET "
                + "MinWashCount=?,"
                + "MinTotalSpent=?,"
                + "BonusPointRate=?,"
                + "BookingWindowDays=?,"
                + "FreeUpgradeMonthly=?,"
                + "FreeWashMonthly=? "
                + "WHERE TierId=?";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getMinWashCount());

            ps.setDouble(2, t.getMinTotalSpent());

            ps.setDouble(3, t.getBonusPointRate());

            ps.setInt(4, t.getBookingWindowDays());

            ps.setBoolean(5, t.isFreeUpgradeMonthly());

            ps.setBoolean(6, t.isFreeWashMonthly());

            ps.setInt(7, t.getTierId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    public boolean updateBasePointRate(double rate) {

        String sql =
                "UPDATE LoyaltyTiers "
                + "SET BasePointRate=?";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, rate);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

}