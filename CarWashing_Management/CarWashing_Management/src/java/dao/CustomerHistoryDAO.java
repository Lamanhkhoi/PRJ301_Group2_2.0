package dao;

import dbutils.DBContext;
import dto.BookingHistory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerHistoryDAO {
  
    //Hàm đếm tổng số trang trong lịch sử
    public int countTotalHistory(int customerId, String statusFilter, String timeFilter) {
        int count = 0;
        
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Bookings b "
              + "WHERE b.CustomerId = ? "
              + "AND b.BookingStatus IN (N'Completed', N'Cancelled', N'NoShow') "
        );
        
        if(statusFilter != null && !statusFilter.equals("ALL")){
            sql.append("AND b.BookingStatus = ?");
        }
        
        if ("30".equals(timeFilter)) {
            sql.append(" AND b.BookingDate >= DATEADD(day, -30, GETDATE()) ");
        } else if ("90".equals(timeFilter)) {
            sql.append(" AND b.BookingDate >= DATEADD(day, -90, GETDATE()) ");
        }
        
        try (Connection cn = DBContext.getConnection(); 
             PreparedStatement pst = cn.prepareStatement(sql.toString())) {

            // Kỹ thuật gán biến tự động tăng (paramIndex)
            int paramIndex = 1;
            pst.setInt(paramIndex++, customerId);

            if (statusFilter != null && !statusFilter.equals("ALL")) {
                pst.setNString(paramIndex++, statusFilter); // setNString vì DB là chữ có dấu
            }

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1); // Lấy con số ở cột đếm đầu tiên
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi tại countTotalHistory: " + e.getMessage());
        }
        return count;
    }
    
    //Hàm lấy danh sách (Đã tích hợp Lọc & Phân trang)
    public List<BookingHistory> getHistory(int customerId, String statusFilter, String timeFilter, int page, int pageSize) {
        List<BookingHistory> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT "
              + "FORMAT(b.BookingDate, 'dd/MM/yyyy') AS FormattedDate, "
              + "ISNULL(FORMAT(b.CompletedAt, 'HH:mm'), 'N/A') AS FormattedTime, "
              + "cv.LicensePlate, cv.VehicleBrand, cv.VehicleModel, cv.VehicleColor, "
              + "ws.ServiceName, b.TotalAmount, b.BookingStatus "
              + "FROM Bookings b "
              + "JOIN CustomerVehicles cv ON b.VehicleId = cv.VehicleId "
              + "JOIN WashServices ws ON b.ServiceId = ws.ServiceId "
              + "WHERE b.CustomerId = ? "
              + "AND b.BookingStatus IN (N'Completed', N'Cancelled', N'NoShow') "
        );

        if (statusFilter != null && !statusFilter.equals("ALL")) {
            sql.append(" AND b.BookingStatus = ? ");
        }

        if ("30".equals(timeFilter)) {
            sql.append(" AND b.BookingDate >= DATEADD(day, -30, GETDATE()) ");
        } else if ("90".equals(timeFilter)) {
            sql.append(" AND b.BookingDate >= DATEADD(day, -90, GETDATE()) ");
        }

        // Ráp thêm Phân trang (OFFSET và FETCH)
        sql.append(" ORDER BY b.BookingDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection cn = DBContext.getConnection(); 
             PreparedStatement pst = cn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            pst.setInt(paramIndex++, customerId);

            if (statusFilter != null && !statusFilter.equals("ALL")) {
                pst.setNString(paramIndex++, statusFilter);
            }

            // Toán học Phân trang: Số dòng cần bỏ qua (Offset)
            int offset = (page - 1) * pageSize;
            pst.setInt(paramIndex++, offset);      
            pst.setInt(paramIndex++, pageSize);    

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    BookingHistory history = new BookingHistory();
                    history.setBookingDate(rs.getString("FormattedDate"));
                    history.setTime(rs.getString("FormattedTime"));
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
            System.out.println("Lỗi tại getHistory: " + e.getMessage());
        }

        return list;
    }
}
