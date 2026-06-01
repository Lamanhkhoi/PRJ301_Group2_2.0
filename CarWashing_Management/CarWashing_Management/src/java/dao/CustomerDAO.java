package dao;

import dbutils.DBContext;
import dto.Customer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
// Hàm getCustomerByAccountId(), updatePhoneNumber()

public class CustomerDAO {

    Connection cn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    public Customer getCustomerByAccountId(int accountId) {

        Customer cus = null;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "SELECT * "
                    + "FROM Customers "
                    + "WHERE AccountId = ?";

            pst = cn.prepareStatement(sql);

            pst.setInt(1, accountId);

            rs = pst.executeQuery();

            if (rs.next()) {

                cus = new Customer();

                cus.setCustomerId(
                        rs.getInt("CustomerId"));

                cus.setAccountId(
                        rs.getInt("AccountId"));

                cus.setPhone(
                        rs.getString("PhoneNumber"));

                cus.setDob(
                        rs.getDate("DateOfBirth"));

                cus.setGender(
                        rs.getString("Gender"));

                cus.setAddress(
                        rs.getString("Address"));

                cus.setCreatedAt(
                        rs.getDate("CreatedAt"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return cus;
    }

    public int insertCustomer(int accountId, String phoneNumber) {

        int result = 0;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "INSERT INTO Customers "
                    + "(AccountId, PhoneNumber) "
                    + "VALUES (?, ?)";

            pst = cn.prepareStatement(sql);

            pst.setInt(1, accountId);
            pst.setString(2, phoneNumber);

            result = pst.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

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

        return result;
    }

    public boolean isPhoneExists(String phone) {

        boolean exists = false;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "SELECT CustomerID FROM Customers WHERE PhoneNumber = ?";

            pst = cn.prepareStatement(sql);
            pst.setString(1, phone);

            rs = pst.executeQuery();

            exists = rs.next();

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

        return exists;
    }

    public boolean updateCustomerInfo(int accountId, String phone, java.util.Date dob, String gender, String address) {
        Connection cn = null;
        PreparedStatement pst = null;
        boolean result = false;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                // FIX 1: Bỏ bỏ lệnh SET DATEFORMAT, chỉ để lại duy nhất câu lệnh UPDATE chuẩn
                String sql = "UPDATE Customers SET PhoneNumber = ?, DateOfBirth = ?, Gender = ?, Address = ? WHERE AccountId = ?";
                pst = cn.prepareStatement(sql);

                pst.setString(1, phone);

                if (dob != null) {
                    pst.setDate(2, new java.sql.Date(dob.getTime()));
                } else {
                    pst.setNull(2, java.sql.Types.DATE);
                }

                // FIX 2: Ánh xạ linh hoạt, chấp nhận cả tiếng Anh (JSP mới gửi về) và tiếng Việt (phòng hờ)
                String dbGender = null;
                if ("Male".equalsIgnoreCase(gender) || "Nam".equalsIgnoreCase(gender)) {
                    dbGender = "Male";
                } else if ("Female".equalsIgnoreCase(gender) || "Nữ".equalsIgnoreCase(gender)) {
                    dbGender = "Female";
                } else if ("Other".equalsIgnoreCase(gender) || "Khác".equalsIgnoreCase(gender)) {
                    dbGender = "Other";
                } else {
                    // Nếu không rơi vào các trường hợp trên, giữ nguyên giá trị gender nhận được từ controller
                    dbGender = gender;
                }
                pst.setString(3, dbGender);

                pst.setString(4, address);
                pst.setInt(5, accountId);

                int row = pst.executeUpdate();
                if (row > 0) {
                    result = true;
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace(); // Bạn hãy kiểm tra log Console của NetBeans/Tomcat để xem có lỗi ràng buộc nào khác không nhé
        } finally {
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
        return result;
    }
}
