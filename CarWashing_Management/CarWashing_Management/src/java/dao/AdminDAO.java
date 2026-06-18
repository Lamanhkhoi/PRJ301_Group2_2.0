package dao;

import dbutils.DBContext;
import dto.Admin;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminDAO {
    Connection cn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    public Admin getAdminByAccountId(int accountId) {

        Admin admin = null;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "SELECT * "
                    + "FROM Admins "
                    + "WHERE AccountId = ?";

            pst = cn.prepareStatement(sql);

            pst.setInt(1, accountId);

            rs = pst.executeQuery();

            if (rs.next()) {

                admin = new Admin();

                admin.setAdminId(
                        rs.getInt("AdminId"));

                admin.setAccountId(accountId);

                admin.setCreatedAt(
                        rs.getDate("CreatedAt"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return admin;
    }
}
