package dao;

import dbutils.DBContext;
import dto.TimeSlot;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TimeSlotDAO {

    public List<TimeSlot> getAllAvailableSlots(String selectedDate) {
        List<TimeSlot> list = new ArrayList<>();
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT ts.SlotNumber, ts.StartTime, ts.EndTime, "
                + "ISNULL(b.BookedCount, 0) AS BookedCount "
                + "FROM TimeSlot ts "
                + "LEFT JOIN ("
                + "    SELECT SlotNumber, COUNT(*) AS BookedCount "
                + "    FROM Bookings "
                + "    WHERE BookingDate = ? AND BookingStatus <> 'Cancelled' "
                + "    GROUP BY SlotNumber"
                + ") b ON ts.SlotNumber = b.SlotNumber "
                + "ORDER BY ts.SlotNumber ASC"; // Sắp xếp tăng dần theo thời gian là bắt buộc

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, selectedDate);
            rs = pst.executeQuery();

            LocalTime now = LocalTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDate parsedDate = LocalDate.parse(selectedDate);

            while (rs.next()) {
                TimeSlot slot = new TimeSlot();
                slot.setSlotNumber(rs.getInt("SlotNumber"));
                slot.setStartTime(rs.getString("StartTime"));
                slot.setEndTime(rs.getString("EndTime"));
                int bookedCount = rs.getInt("BookedCount");
                slot.setBookedCount(bookedCount);
                slot.setIsFull(bookedCount >= 3); // Giới hạn tối đa 3 xe/slot

                LocalTime slotStartTime = LocalTime.parse(rs.getString("StartTime"));
                if (parsedDate.isBefore(today)) {
                    slot.setIsPast(true);
                } else if (parsedDate.isEqual(today) && slotStartTime.isBefore(now.plusMinutes(20))) {
                    slot.setIsPast(true);
                } else {
                    slot.setIsPast(false);
                }

                // Mặc định ban đầu tất cả các slot đều là false
                slot.setIsPriority(false);

                list.add(slot);
            }

            // --- LOGIC THIẾT LẬP ISPRIORITY CHO SLOT TRỐNG SỚM NHẤT ---
            for (TimeSlot slot : list) {
                // Điều kiện: Slot KHÔNG nằm trong quá khứ VÀ KHÔNG bị đầy (còn trống)
                if (!slot.isIsPast() && !slot.isIsFull()) {
                    slot.setIsPriority(true); // Gắn cờ Priority cho slot này
                    break; // Dừng vòng lặp ngay lập tức để chỉ lấy duy nhất 1 slot sớm nhất
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Đóng kết nối DB (cn, pst, rs)...
        }
        return list;
    }

    public Map<Integer, TimeSlot> getAllTimeSlots() {
        Map<Integer, TimeSlot> map = new java.util.HashMap<>();
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT SlotNumber, StartTime, EndTime FROM TimeSlot ORDER BY SlotNumber ASC";
        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            rs = pst.executeQuery();
            while (rs.next()) {
                TimeSlot slot = new TimeSlot();
                slot.setSlotNumber(rs.getInt("SlotNumber"));
                slot.setStartTime(rs.getString("StartTime"));
                slot.setEndTime(rs.getString("EndTime"));
                map.put(slot.getSlotNumber(), slot);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }

                if (pst != null) {
                    pst.close();
                }

                if (cn != null) {
                    cn.close();
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return map;
    }
}
