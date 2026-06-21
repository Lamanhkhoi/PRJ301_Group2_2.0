package controller;

import dao.BookingDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "UpdateBookingStatus", urlPatterns = {"/UpdateBookingStatus"})
public class UpdateBookingStatus extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String currentBookingDate = request.getParameter("bookingDate");
        String currentSearchPlate = request.getParameter("searchLicensePlate");

        try {
            int bookingId = Integer.parseInt(request.getParameter("id"));
            String targetStatus = request.getParameter("status");

            BookingDAO dao = new BookingDAO();
            Map<String, Object> booking = dao.getBookingById(bookingId);

            if (booking != null) {
                String currentStatus = (String) booking.get("BookingStatus");
                int slotNumber = (Integer) booking.get("SlotNumber");
                String bookingDateStr = booking.get("BookingDate").toString();

                LocalDate bDate = LocalDate.parse(bookingDateStr);
                LocalDate today = LocalDate.now();
                LocalTime now = LocalTime.now();

                double startHour = 8.0 + (slotNumber - 1) / 2.0;
                int hourPart = (int) startHour;
                int minutePart = (startHour % 1 == 0) ? 0 : 30;
                LocalTime slotStartTime = LocalTime.of(hourPart, minutePart);
                LocalTime noShowDeadline = slotStartTime.plusMinutes(1);

                // Kiểm tra quy trình trạng thái hợp lệ
                boolean isValidFlow = false;
                if ("Pending".equals(currentStatus) && "CheckedIn".equals(targetStatus)) {
                    isValidFlow = true;
                } else if ("CheckedIn".equals(currentStatus) && "Completed".equals(targetStatus)) {
                    isValidFlow = true;
                }

                if (!isValidFlow) {
                    session.setAttribute("ALERT_TYPE", "error");
                    session.setAttribute("ALERT_MSG", "Lỗi: Quy trình chuyển đổi trạng thái không hợp lệ!");
                    return;
                }

                // Kiểm tra điều kiện thời gian thao tác đơn đặt
                if (bDate.isBefore(today)) {
                    session.setAttribute("ALERT_TYPE", "error");
                    session.setAttribute("ALERT_MSG", "Lỗi: Không thể thao tác lịch đặt của ngày trong quá khứ!");
                    return;
                } else if (bDate.isAfter(today)) {
                    session.setAttribute("ALERT_TYPE", "error");
                    session.setAttribute("ALERT_MSG", "Lỗi: Chưa đến ngày hẹn, không thể thao tác!");
                    return;
                } else {
                    if (now.isBefore(slotStartTime)) {
                        session.setAttribute("ALERT_TYPE", "error");
                        session.setAttribute("ALERT_MSG", "Lỗi: Ca làm việc chưa bắt đầu!");
                        return;
                    }

                    if ("Pending".equals(currentStatus) && now.isAfter(noShowDeadline)) {
                        dao.updateBookingStatus(bookingId, "NoShow");
                        session.setAttribute("ALERT_TYPE", "error");
                        session.setAttribute("ALERT_MSG", "Lỗi: Quá hạn 1 phút! Hệ thống đã chuyển sang No-Show.");
                        return;
                    }
                }

                // Tiến hành thực thi cập nhật dữ liệu thực tế
                boolean success = dao.updateBookingStatus(bookingId, targetStatus);
                if (success) {
                    session.setAttribute("ALERT_TYPE", "success");
                    session.setAttribute("ALERT_MSG", "Cập nhật trạng thái đơn đặt lịch thành công!");
                } else {
                    session.setAttribute("ALERT_TYPE", "error");
                    session.setAttribute("ALERT_MSG", "Lỗi: Không thể cập nhật trạng thái vào cơ sở dữ liệu.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("ALERT_TYPE", "error");
            session.setAttribute("ALERT_MSG", "Có lỗi hệ thống xảy ra: " + e.getMessage());
        } finally {
            // Lưu lại bộ lọc tìm kiếm hiện tại vào Session để trang sau lấy lại
            session.setAttribute("KEEP_DATE", currentBookingDate);
            session.setAttribute("KEEP_PLATE", currentSearchPlate);
            response.sendRedirect("MainController?action=manageBooking");
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
