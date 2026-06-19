package dao;

import dbutils.DBContext;
import dto.BookingHistory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerHistoryDAO {

    public List<BookingHistory> getHistoryByCustomerId(int customerId) {
        List<BookingHistory> list = new ArrayList<>();

        String sql = "SELECT "
                   + "FORMAT(b.BookingDate, 'dd/MM/yyyy') AS FormattedDate, "
                   + "ISNULL(FORMAT(b.CompletedAt, 'HH:mm'), 'N/A') AS FormattedTime, "
                   + "cv.LicensePlate, cv.VehicleBrand, cv.VehicleModel, cv.VehicleColor, "
                   + "ws.ServiceName, b.TotalAmount, b.BookingStatus "
                   + "FROM Bookings b "
                   + "JOIN CustomerVehicles cv ON b.VehicleId = cv.VehicleId "
                   + "JOIN WashServices ws ON b.ServiceId = ws.ServiceId "
                   + "WHERE b.CustomerId = ? "
                   + "AND b.BookingStatus IN (N'Completed', N'Cancelled', N'NoShow') "
                   + "ORDER BY b.BookingDate DESC";

        // CÚ PHÁP TỐI ƯU (Try-with-Resources): Tự động dọn dẹp bộ nhớ
        try ( Connection cn = DBContext.getConnection();  PreparedStatement pst = cn.prepareStatement(sql)) {
            // Truyền tham số
            pst.setInt(1, customerId);

            // Thực thi và bọc ResultSet vào Try để tự động đóng
            try ( ResultSet rs = pst.executeQuery()) {
                while (rs.next()) { // Hoặc `if (rs.next())` nếu chỉ lấy 1 dòng
                    BookingHistory history = new BookingHistory();
                    history.setBookingDate(rs.getString("BookingDate"));
                    history.setTime(rs.getString("CompletedAt"));
                    history.setLicensePlate(rs.getString("LicensePlate"));
                    history.setBrand(rs.getString("VehicleBrand"));
                    history.setModel(rs.getString("VehicleModel"));
                    history.setColor(rs.getString("VehicleColor"));
                    history.setServiceName(rs.getString("ServiceName"));
                    history.setTotalAmount(rs.getDouble("TotalAmount"));
                    history.setStatus(rs.getString("BookingStatus"));
                    
                    list.add(history);
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi tại getHistoryByCustomerId:" + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }
}
