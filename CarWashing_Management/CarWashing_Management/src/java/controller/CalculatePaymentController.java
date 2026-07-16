package controller;

import dao.PromotionDAO;
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

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession();

            Booking draft = (Booking) session.getAttribute("BOOKING_DRAFT");
            double basePrice = (draft != null) ? (double) draft.getTotalAmount() : 0.0;

            CustomerLoyalty cusLoy = (CustomerLoyalty) session.getAttribute("LOYAL");
            int currentPoints = (cusLoy != null) ? cusLoy.getCurrentPoints() : 0;

            int redemptionId = 0;
            int promotionId = 0;   // ← THÊM
            int pointsUsed = 0;

            String redemptionParam = request.getParameter("redemptionId");
            if (redemptionParam != null && !redemptionParam.isEmpty()) {
                redemptionId = Integer.parseInt(redemptionParam);
            }

            String promotionParam = request.getParameter("promotionId");   // ← THÊM
            if (promotionParam != null && !promotionParam.isEmpty()) {
                promotionId = Integer.parseInt(promotionParam);
            }

            String pointsParam = request.getParameter("pointsUsed");
            if (pointsParam != null && !pointsParam.isEmpty()) {
                pointsUsed = Integer.parseInt(pointsParam);
            }

            // 2. Tính tiền giảm từ Voucher (RewardDAO) — tính trên basePrice gốc
            RewardDAO rewardDAO = new RewardDAO();
            double voucherDiscount = (double) rewardDAO.calculateVoucherDiscount(redemptionId, basePrice);
            request.getSession().setAttribute("VOUCHERDISCOUNT", voucherDiscount);
            // 2b. Tính tiền giảm từ Promotion (PromotionDAO) — cũng tính trên basePrice gốc, ĐỘC LẬP với voucher
            PromotionDAO promotionDAO = new PromotionDAO();
            double promotionDiscount = (double) promotionDAO.calculatePromoDiscount(promotionId, basePrice);
            request.getSession().setAttribute("PROMOTIONDISCOUNT", promotionDiscount);
            // 3. Gộp 2 khoản giảm lại, chặn không cho tổng giảm vượt quá giá gốc
            double totalDiscount = voucherDiscount + promotionDiscount;
            if (totalDiscount > basePrice) {
                // Co giãn tỉ lệ 2 khoản giảm để tổng không vượt basePrice, thay vì cắt bỏ hẳn 1 bên
                double ratio = (double) basePrice / totalDiscount;
                voucherDiscount = (double) (voucherDiscount * ratio);
                promotionDiscount = basePrice - voucherDiscount; // phần còn lại dồn hết vào promotion để tổng luôn khớp basePrice tuyệt đối
                totalDiscount = basePrice;
            }

            double amountAfterDiscount = basePrice - totalDiscount;
            if (amountAfterDiscount < 0) {
                amountAfterDiscount = 0;
            }

            // 4. Tính toán số điểm tối đa hợp lệ để chống âm tiền
            int maxPointsForRemainingAmount = (int) amountAfterDiscount;
            int maxPointsAllowed = Math.min(currentPoints, maxPointsForRemainingAmount);

            if (pointsUsed > maxPointsAllowed) {
                pointsUsed = maxPointsAllowed;
            }

            // 5. Tính tổng tiền cuối cùng
            double grandTotal = amountAfterDiscount - pointsUsed;
            if (grandTotal < 0) {
                grandTotal = 0;
            }

            // 6. Build chuỗi JSON trả về — thêm field promotionDiscount
            String jsonResponse = String.format(
                "{\"voucherDiscount\": %f, \"promotionDiscount\": %f, \"pointDiscount\": %d, \"grandTotal\": %f, \"maxPointsAllowed\": %d}",
                voucherDiscount, promotionDiscount, pointsUsed, grandTotal, maxPointsAllowed
            );

            try (PrintWriter out = response.getWriter()) {
                out.print(jsonResponse);
                out.flush();
            }

        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"voucherDiscount\": 0, \"promotionDiscount\": 0, \"pointDiscount\": 0, \"grandTotal\": 0, \"maxPointsAllowed\": 0}");
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
        processRequest(request, response);
    }
}