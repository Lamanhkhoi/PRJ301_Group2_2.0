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
            int voucherDiscount = Integer.parseInt(request.getParameter("voucherDiscount"));
            int pointsUsed = Integer.parseInt(request.getParameter("pointsUsed"));
            double finalPrice = Double.parseDouble(request.getParameter("finalPrice"));
            String rewardIdParam = request.getParameter("rewardId");
            int currentRewardId = 0;

            try {
                if (rewardIdParam != null && !rewardIdParam.isEmpty()) {
                    currentRewardId = Integer.parseInt(rewardIdParam);
                }
            } catch (NumberFormatException e) {
                // Nếu dữ liệu gửi lên không phải là số (bị lỗi), ta mặc định rewardId = 0
                currentRewardId = 0;
            }

            // TIẾN HÀNH TRANSACTION TRONG DAO
            BookingDAO bookingDAO = new BookingDAO();

            // Hàm xử lý Transaction gộp: 
            // 1) Trừ điểm tích lũy  2) Hủy Voucher đã dùng  3) INSERT Booking chính thức với status = 'CONFIRMED'
            boolean isTransactionSuccess = bookingDAO.insertRealPaidBooking(account.getAccountID(), draft, pointsUsed, currentRewardId, finalPrice, sessionMemo);

            if (isTransactionSuccess) {
                // Xóa toàn bộ dữ liệu lưu nháp trong Session sau khi đã ghi xuống Database thành công
                session.removeAttribute("BOOKING_DRAFT");
                session.removeAttribute("BOOKING_TIME_TEXT");
                session.removeAttribute("PAYMENT_MEMO");

                session.setAttribute("ALERT_TYPE", "success");
                session.setAttribute("ALERT_MSG", "Thanh toán thành công! Lịch hẹn của bạn đã được xác nhận tự động trên hệ thống.");
            } else {
                session.setAttribute("ALERT_TYPE", "fail");
                session.setAttribute("ALERT_MSG", "Thanh toán thành công nhưng hệ thống gặp lỗi khi tạo lịch hẹn!");
            }

            // Quay về đúng trang Đặt Lịch ban đầu và hiển thị Toast thông báo kết quả
            response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");

        } catch (Exception e) {
            e.printStackTrace();
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
