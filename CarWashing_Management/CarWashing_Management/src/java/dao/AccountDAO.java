package dao;

import dbutils.DBContext;
import dto.Account;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
// Hàm checkLogin(), registerAccount()
public class AccountDAO {
    
    Connection cn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    public Account checkLogin(String login, String password) {

        Account acc = null;

        try {
            cn = DBContext.getConnection();

            String sql = "SELECT * "
                    + "FROM Accounts "
                    + "WHERE (Email=? OR Username=?) "
                    + "AND PasswordHash=?";

            pst = cn.prepareStatement(sql);

            pst.setString(1, login);
            pst.setString(2, login);
            pst.setString(3, password);

            rs = pst.executeQuery();

            if (rs.next()) {

                acc = new Account();

                acc.setAccountID(rs.getInt("AccountId"));
                acc.setUsername(rs.getString("Username"));
                acc.setEmail(rs.getString("Email"));
                acc.setPasswordHash(rs.getString("PasswordHash"));
                acc.setFullname(rs.getString("FullName"));
                acc.setAvaUrl(rs.getString("AvatarUrl"));
                acc.setRole(rs.getString("Role"));

                String status = rs.getString("AccountStatus");

                acc.setStatus(status.equalsIgnoreCase("Active"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return acc;
    }

    public Account getAccountByEmail(String email) {

        Account acc = null;

        try {

            cn = DBContext.getConnection();

            String sql = "SELECT * FROM Accounts WHERE Email=?";

            pst = cn.prepareStatement(sql);

            pst.setString(1, email);

            rs = pst.executeQuery();

            if (rs.next()) {

                acc = new Account();

                acc.setAccountID(rs.getInt("AccountId"));
                acc.setEmail(rs.getString("Email"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return acc;
    }

    public int registerAccount(Account acc) {

        int result = 0;

        try {

            cn = DBContext.getConnection();

            String sql = "INSERT INTO Accounts "
                    + "(Username,Email,PasswordHash,FullName,Role,AccountStatus) "
                    + "VALUES(?,?,?,?,?,?)";

            pst = cn.prepareStatement(sql);

            pst.setString(1, acc.getUsername());
            pst.setString(2, acc.getEmail());
            pst.setString(3, acc.getPasswordHash());
            pst.setString(4, acc.getFullname());
            pst.setString(5, "Customer");
            pst.setString(6, "Active");

            result = pst.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
}
