package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import dbutils.DBContext;

public class AdminConfigDAO extends DBContext {

    public Map<String, String> getAllConfig() {

        Map<String, String> map = new HashMap<>();

        String sql =
                "SELECT ConfigKey, ConfigValue "
                + "FROM SystemConfig";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                map.put(
                        rs.getString("ConfigKey"),
                        rs.getString("ConfigValue"));

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return map;

    }

    public String getValue(String key) {

        String sql =
                "SELECT ConfigValue "
                + "FROM SystemConfig "
                + "WHERE ConfigKey=?";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, key);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getString("ConfigValue");

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return "";

    }

    public boolean updateConfig(String key, String value) {

        String sql =
                "UPDATE SystemConfig "
                + "SET ConfigValue=?,"
                + "UpdatedAt=GETDATE() "
                + "WHERE ConfigKey=?";

        try (
                Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, value);

            ps.setString(2, key);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;

    }

}