package controller;
import dao.RewardDAO;
import dto.Booking;
import dto.CustomerLoyalty;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CalculatePaymentController", urlPatterns = {"/CalculatePaymentController"})
public class CalculatePaymentController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Cấu hình định dạng trả về là JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession();
            
            // Lấy thông tin đơn hàng nháp từ session
            Booking draft = (Booking) session.getAttribute("BOOKING_DRAFT");
            long basePrice = (draft != null) ? (long) draft.getTotalAmount() : 0;

            // Lấy điểm hiện tại của người dùng
            CustomerLoyalty cusLoy = (CustomerLoyalty) session.getAttribute("LOYAL");
            int currentPoints = (cusLoy != null) ? cusLoy.getCurrentPoints() : 0;

            // Đọc tham số từ request (nếu không có thì mặc định là 0)
            int redemptionId = 0;
            int pointsUsed = 0;
            
            String redemptionParam = request.getParameter("redemptionId");
            if (redemptionParam != null && !redemptionParam.isEmpty()) {
                redemptionId = Integer.parseInt(redemptionParam);
            }
            
            String pointsParam = request.getParameter("pointsUsed");
            if (pointsParam != null && !pointsParam.isEmpty()) {
                pointsUsed = Integer.parseInt(pointsParam);
            }

            // 2. Tính tiền giảm từ Voucher (Giả lập RewardDAO)
            RewardDAO rewardDAO = new RewardDAO();
            long voucherDiscount = (long) rewardDAO.calculateVoucherDiscount(redemptionId, basePrice);

            long amountAfterVoucher = basePrice - voucherDiscount;
            if (amountAfterVoucher < 0) {
                amountAfterVoucher = 0;
                voucherDiscount = basePrice;
            }

            // 3. Tính toán số điểm tối đa hợp lệ để chống âm tiền
            int maxPointsForRemainingAmount = (int) (amountAfterVoucher);
            int maxPointsAllowed = Math.min(currentPoints, maxPointsForRemainingAmount);

            // Bắt lỗi tự động ép về điểm hợp lệ nếu request gửi lố
            if (pointsUsed > maxPointsAllowed) {
                pointsUsed = maxPointsAllowed;
            }

            // 4. Tính tổng tiền cuối cùng
            long grandTotal = amountAfterVoucher - pointsUsed;
            if (grandTotal < 0) grandTotal = 0;

            // 5. Build chuỗi JSON trả về
            String jsonResponse = String.format(
                "{\"voucherDiscount\": %d, \"pointDiscount\": %d, \"grandTotal\": %d, \"maxPointsAllowed\": %d}",
                voucherDiscount, pointsUsed, grandTotal, maxPointsAllowed
            );

            try (PrintWriter out = response.getWriter()) {
                out.print(jsonResponse);
                out.flush();
            }

        } catch (Exception e) {
            e.printStackTrace();
            // Xử lý an toàn: Trả về 0 nếu có lỗi (tránh crash frontend)
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"voucherDiscount\": 0, \"pointDiscount\": 0, \"grandTotal\": 0, \"maxPointsAllowed\": 0}");
                out.flush();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chỉ gọi duy nhất processRequest để xử lý logic
        processRequest(request, response);
    }
}
