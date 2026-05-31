package dao;

import dbutils.DBContext;
import dto.Account;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
// Hàm checkLogin(), registerAccount()

public class AccountDAO {

    // XÓA BỎ hoàn toàn việc khai báo biến Connection, PreparedStatement, ResultSet ở đây!
    /**
     * Hàm kiểm tra Đăng nhập Đã chặn trực tiếp nếu trạng thái tài khoản không
     * phải 'Active'
     */
    public Account checkLogin(String login, String password) throws SQLException {
        Account acc = null;
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                // Bổ sung điều kiện kiểm tra AccountStatus trực tiếp trong câu lệnh SQL
                String sql = "SELECT * FROM Accounts "
                        + "WHERE (Email=? OR Username=?) "
                        + "AND PasswordHash=? "
                        + "AND AccountStatus = 'Active'";

                pst = cn.prepareStatement(sql);
                pst.setString(1, login);
                pst.setString(2, login);
                pst.setString(3, password); // Hiện tại lưu văn bản thuần (plain text) theo cấu hình thử nghiệm

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
                    acc.setStatus(true); // Đã lọc ở SQL nên chắc chắn tài khoản đang Active
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            // Đảm bảo đóng kết nối an toàn cho mọi luồng (Thread-safe)
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException e) {
            }
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (SQLException e) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
            }
        }

        return acc;
    }

    /**
     * Hàm tìm kiếm tài khoản theo Email
     */
    public Account getAccountByEmail(String email) {
        Account acc = null;
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "SELECT * FROM Accounts WHERE Email=?";
                pst = cn.prepareStatement(sql);
                pst.setString(1, email);

                rs = pst.executeQuery();

                if (rs.next()) {
                    acc = new Account();
                    acc.setAccountID(rs.getInt("AccountId"));
                    acc.setUsername(rs.getString("Username"));
                    acc.setEmail(rs.getString("Email"));
                    acc.setFullname(rs.getString("FullName"));
                    acc.setAvaUrl(rs.getString("AvatarUrl"));
                    acc.setRole(rs.getString("Role"));

                    String status = rs.getString("AccountStatus");
                    acc.setStatus(status.equalsIgnoreCase("Active"));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException e) {
            }
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (SQLException e) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException e) {
            }
        }

        return acc;
    }

    /**
     * Hàm đăng ký tài khoản khách hàng mới
     */
    public int registerAccount(Account acc) {

        int accountId = -1;

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "INSERT INTO Accounts "
                    + "(Username, Email, PasswordHash, FullName, Role, AccountStatus) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            pst = cn.prepareStatement(
                    sql,
                    PreparedStatement.RETURN_GENERATED_KEYS);

            pst.setString(1, acc.getUsername());
            pst.setString(2, acc.getEmail());
            pst.setString(3, acc.getPasswordHash());
            pst.setString(4, acc.getFullname());
            pst.setString(5, "Customer");
            pst.setString(6, "Active");

            pst.executeUpdate();

            rs = pst.getGeneratedKeys();

            if (rs.next()) {
                accountId = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception e) {
            }

            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
            }

            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
            }
        }

        return accountId;
    }
}
