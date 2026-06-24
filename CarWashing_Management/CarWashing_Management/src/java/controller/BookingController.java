/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.BookingDAO;
import dao.CustomerVehicleDAO;
import dao.WashServiceDAO;
import dto.Booking;
import dto.Customer;
import dto.TimeSlot;
import dto.Vehicle;
import dto.WashService;
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
            // 1. Kiểm tra session của khách hàng xem có bị hết hạn không
            Customer cus = (Customer) session.getAttribute("CUSTOMER");
            if (cus == null) {
                session.setAttribute("ALERT_TYPE", "error");
                session.setAttribute("ALERT_MSG", "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
                request.getRequestDispatcher(request.getContextPath() + "/login.jsp"); // Đổi link login của bạn nếu cần
                return;
            }

            // 2. Lấy dữ liệu dạng Chuỗi từ Request
            String vehicleIdStr = request.getParameter("vehicleId");
            String serviceIdStr = request.getParameter("serviceId");
            String bookingDate = request.getParameter("bookingDate");
            String slotNumberStr = request.getParameter("slotNumber");
//            System.out.println("--- DEBUG BOOKING PARAMETERS ---");
//            System.out.println("vehicleId: " + vehicleIdStr);
//            System.out.println("serviceId: " + serviceIdStr);
//            System.out.println("bookingDate: " + bookingDate);
//            System.out.println("slotNumber: " + slotNumberStr);
//            System.out.println("--------------------------------");
//            // 3. Kiểm tra xem có tham số nào bị rỗng hoặc null không (Lỗi từ phía JSP không gửi đúng tên name)
//            if (vehicleIdStr == null || vehicleIdStr.trim().isEmpty()
//                    || serviceIdStr == null || serviceIdStr.trim().isEmpty()
//                    || bookingDate == null || bookingDate.trim().isEmpty()
//                    || slotNumberStr == null || slotNumberStr.trim().isEmpty()) {
//
//                session.setAttribute("ALERT_TYPE", "fail");
//                session.setAttribute("ALERT_MSG", "Lỗi: Không nhận được đầy đủ dữ liệu từ Form (Có tham số bị rỗng)!");
//                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
//                return;
//            }

            // 4. Tiến hành parse dữ liệu một cách an toàn
            int vehicleId, serviceId, slotNumber;
            try {
                vehicleId = Integer.parseInt(vehicleIdStr.trim());
                serviceId = Integer.parseInt(serviceIdStr.trim());
                slotNumber = Integer.parseInt(slotNumberStr.trim());
            } catch (NumberFormatException nfe) {
                // Nếu nhảy vào đây tức là JSP có gửi dữ liệu, nhưng dữ liệu không phải là SỐ (ví dụ: chuỗi "abc")
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Lỗi định dạng: ID xe, dịch vụ hoặc mã Slot phải là số!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
                return;
            }
            BookingDAO bookingDAO = new BookingDAO();
            // Kiểm tra trùng: Mỗi khách hàng chỉ được đặt 1 slot vào 1 ngày
            if (bookingDAO.isDuplicateBooking(vehicleId, bookingDate, slotNumber)) {
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Xe này của bạn đã có một lịch hẹn trong khung giờ này rồi!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
                return;
            }
            // 5. Kiểm tra tính hợp lệ của Service dịch vụ trong Database trước khi lấy giá tiền
            WashServiceDAO w = new WashServiceDAO();
            WashService service = w.getServiceById(serviceId);
//            if (service == null) {
//                session.setAttribute("ALERT_TYPE", "fail");
//                session.setAttribute("ALERT_MSG", "Lỗi: Dịch vụ bạn chọn không tồn tại trong hệ thống!");
//                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
//                return;
//            }

            // 6. Thực hiện gọi DAO để chèn vào Database
            boolean isSuccess = bookingDAO.createNewBooking(
                    cus.getCustomerId(),
                    vehicleId,
                    serviceId,
                    bookingDate,
                    slotNumber,
                    service.getPrice()
            );

            if (isSuccess) {
                session.setAttribute("ALERT_TYPE", "success");
                session.setAttribute("ALERT_MSG", "Booking thành công!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=success");
            } else {
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Booking thất bại! Vui lòng thử chọn khung giờ khác.");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage&status=fail");
            }

        } catch (Exception e) {
            e.printStackTrace(); // In log ra console để dev kiểm tra hệ thống sập vì lý do gì khác
            session.setAttribute("ALERT_TYPE", "error");
            session.setAttribute("ALERT_MSG", "Hệ thống gặp sự cố không xác định: " + e.getMessage());
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
