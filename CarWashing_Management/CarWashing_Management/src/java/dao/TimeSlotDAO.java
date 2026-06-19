/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dbutils.DBContext;
import dto.TimeSlot;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author LENOVO
 */
public class TimeSlotDAO {
    public List<TimeSlot> getSlotsWithBookingStatus(String dateToCheck) {
        List<TimeSlot> list = new ArrayList<>();
        Connection cn = null; 
        // Câu SQL sử dụng LEFT JOIN để lấy tất cả các slot giờ, 
        // đồng thời đếm xem ngày đó có bao nhiêu booking đã chọn slotNumber này.
        
                     
        try {
            cn = new DBContext().getConnection();
            String sql = "SELECT t.slotNumber, t.timeValue, t.isPrioritySlot, " +
                     "COUNT(b.BookingId) AS TotalBooked " +
                     "FROM TimeSlot t " +
                     "LEFT JOIN Bookings b ON t.slotNumber = b.SlotNumber AND b.BookingDate = ? " +
                     "GROUP BY t.slotNumber, t.timeValue, t.isPrioritySlot " +
                     "ORDER BY t.timeValue ASC";
            PreparedStatement ps = cn.prepareStatement(sql);
            ps.setString(1, dateToCheck);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                TimeSlot slot = new TimeSlot();
                slot.setSlotNumber(rs.getInt("slotNumber"));
                slot.setTime(rs.getString("timeValue"));
                slot.setIsPriority(rs.getBoolean("isPrioritySlot"));
                
                // Giả sử tiệm nhận tối đa 3 xe cùng lúc cho mỗi khung giờ
                int totalBooked = rs.getInt("TotalBooked");
                if (totalBooked >= 3) {
                    slot.setIsFull(true);
                } else {
                    slot.setIsFull(false);
                }
                
                list.add(slot);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
