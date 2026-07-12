package controller;

import dao.BookingDAO;
import dto.Account;
import dto.Booking;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "FinalizeBookingController", urlPatterns = {"/FinalizeBookingController"})
public class FinalizeBookingController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        try {
            Booking draft = (Booking) session.getAttribute("BOOKING_DRAFT");
            String sessionMemo = (String) session.getAttribute("PAYMENT_MEMO");
            Account account = (Account) session.getAttribute("USER");
            if (draft == null) {
                session.setAttribute("ALERT_TYPE", "error");
                session.setAttribute("ALERT_MSG", "Lỗi: Phiên đặt lịch nháp đã hết hạn hoặc không tồn tại!");
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");
                return;
            }

            // Đọc các thông số giảm giá cuối cùng mà khách hàng chọn ở trang JSP nộp lên
            int pointsUsed = Integer.parseInt(request.getParameter("pointsUsed"));
            double finalPrice = Double.parseDouble(request.getParameter("finalPrice"));
            String redemptionIdParam = request.getParameter("redemptionId");   // ← đổi tên khớp với JSP
            int currentRewardId = 0;

            try {
                if (redemptionIdParam != null && !redemptionIdParam.isEmpty()) {
                    currentRewardId = Integer.parseInt(redemptionIdParam);
                }
            } catch (NumberFormatException e) {
                currentRewardId = 0;
            }

            // TIẾN HÀNH TRANSACTION TRONG DAO
            BookingDAO bookingDAO = new BookingDAO();
            boolean isTransactionSuccess = bookingDAO.insertRealPaidBooking(account.getAccountID(), draft, pointsUsed, currentRewardId, finalPrice, sessionMemo);

            if (isTransactionSuccess) {
                session.removeAttribute("BOOKING_DRAFT");
                session.removeAttribute("BOOKING_TIME_TEXT");
                session.removeAttribute("PAYMENT_MEMO");

                session.setAttribute("ALERT_TYPE", "success");
                session.setAttribute("ALERT_MSG", "Thanh toán thành công! Lịch hẹn của bạn đã được xác nhận tự động trên hệ thống.");
            } else {
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Thanh toán thành công nhưng hệ thống gặp lỗi khi tạo lịch hẹn!");
            }

            response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("ALERT_TYPE", "error");                                              // ← THÊM: để không còn "im lặng" khi lỗi
            session.setAttribute("ALERT_MSG", "Thanh toán ghi nhận nhưng có lỗi khi tạo lịch hẹn: " + e.getMessage());   // ← THÊM
            response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
}
