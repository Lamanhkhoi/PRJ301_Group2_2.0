/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.BookingDAO;
import dao.WashServiceDAO;
import dto.Booking;
import dto.Customer;
import dto.TimeSlot;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import static java.time.LocalTime.now;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javafx.util.converter.LocalDateTimeStringConverter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author LENOVO
 */
@WebServlet(name = "BookingController", urlPatterns = {"/BookingController"})
public class BookingController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "customerBookingPage":
            case "bookingCheckSlots":
                handleCheckSlots(request, response);
                break;
            case "processBooking":
                handleProcessBooking(request, response);

                break;
            default:
                response.sendRedirect("error.jsp");
        }
    }

    private void handleCheckSlots(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String bookingDate = request.getParameter("date");
        if (bookingDate == null || bookingDate.trim().isEmpty()) {
            bookingDate = LocalDate.now().toString();
        }

        BookingDAO bookingDAO = new BookingDAO();
        int totalSlotsInDay = 28;
        int startHour = 8;
        int startMinute = 0;
        boolean foundFirstAvailable = false;

        // Tạo một List để chứa các slot 
        List<TimeSlot> slotList = new ArrayList<>();

        int[] carCounts = new int[totalSlotsInDay];
        for (int i = 0; i < totalSlotsInDay; i++) {
            carCounts[i] = bookingDAO.countBookedCars(bookingDate, i + 1);
        }

        for (int i = 0; i < totalSlotsInDay; i++) {
            int slotNumber = i + 1;

            int totalMinutesStart = i * 30;
            int totalMinutesEnd = (i + 1) * 30;

            int slotStartHour = startHour + (totalMinutesStart / 60);
            int slotStartMin = startMinute + (totalMinutesStart % 60);
            int slotEndHour = startHour + (totalMinutesEnd / 60);
            int slotEndMin = startMinute + (totalMinutesEnd % 60);

            String timeLabel = String.format("%02d:%02d - %02d:%02d",
                    slotStartHour, slotStartMin, slotEndHour, slotEndMin);

            int currentCars = carCounts[i];
            boolean isFull = (currentCars >= 3);
            boolean isPastOrTooClose = false;
            String startHourStr = String.format("%02d:%02d", slotStartHour, slotStartMin);
            LocalTime slotStartTime = LocalTime.parse(startHourStr, DateTimeFormatter.ofPattern("HH:mm"));
            // Điều kiện chặn: Giờ của slot < (Giờ hiện tại + 20 phút)
            ZoneId vnZone = ZoneId.of("Asia/Ho_Chi_Minh");
            LocalDate today = LocalDate.now(vnZone);
            LocalTime now = LocalTime.now(vnZone);
            LocalDate parsedBookingDate = LocalDate.parse(bookingDate);
            if (parsedBookingDate.isEqual(today)) {

                if (slotStartTime.isBefore(now.plusMinutes(20))) {
                    isPastOrTooClose = true;
                }
            }
            boolean isPriority = false;
            if (!isPastOrTooClose && !isFull && !foundFirstAvailable) {
                isPriority = true;
                foundFirstAvailable = true;
            }

            // Tạo object Slot và add vào list
            slotList.add(new TimeSlot(slotNumber, timeLabel, isFull, isPriority, currentCars));
        }

        // Gửi list này và ngày đã chọn sang trang JSP
        request.setAttribute("slots", slotList);
        request.setAttribute("selectedDate", bookingDate);

        // Chuyển hướng hiển thị lại giao diện (Thay vì in JSON)
        request.getRequestDispatcher("DashBoard/customer_booking.jsp").forward(request, response);
    }

    private void handleProcessBooking(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        try {
            Customer cus = (Customer) request.getSession().getAttribute("CUSTOMER");

            int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            String bookingDate = request.getParameter("bookingDate");
            int slotNumber = Integer.parseInt(request.getParameter("slotNumber"));
            WashServiceDAO w = new WashServiceDAO();
            System.out.println(slotNumber);
            BookingDAO bookingDAO = new BookingDAO();

            // Gọi phương thức thêm mới bản ghi từ BookingDAO
            boolean isSuccess = bookingDAO.createNewBooking(cus.getCustomerId(), vehicleId, serviceId, bookingDate, slotNumber, w.getServiceById(serviceId).getPrice());

            if (isSuccess) {
                // Thành công: Chuyển hướng về trang Dashboard chung kèm cờ báo thành công
                session.setAttribute("ALERT_TYPE", "success");
                session.setAttribute("ALERT_MSG", "Booking thành công!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerPage&status=success");
            } else {
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Booking thất bại!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("ALERT_TYPE", "error");
            session.setAttribute("ALERT_MSG", "Hệ thống bảo trì!");
            response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=error");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
