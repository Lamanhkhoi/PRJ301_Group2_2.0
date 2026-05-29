package dao;

import dbutils.DBContext;
import dto.Customer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
// Hàm getCustomerByAccountId(), updatePhoneNumber()
public class CustomerDAO {

    Connection cn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    public Customer getCustomerByAccountId(int accountId) {

        Customer cus = null;

        try {

            cn = DBContext.getConnection();

            String sql =
                    "SELECT * "
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
}