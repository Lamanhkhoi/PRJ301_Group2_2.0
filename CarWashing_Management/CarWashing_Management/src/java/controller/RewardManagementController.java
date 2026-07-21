package controller;

import dao.RewardDAO;
import dto.Reward;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "RewardManagementController",
        urlPatterns = {"/RewardManagementController"}
)
public class RewardManagementController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        RewardDAO dao = new RewardDAO();

        String action = request.getParameter("action");

        /* ==========================
       XÓA MỀM
    ===========================*/
        if ("delete".equals(action)) {

            int rewardId = Integer.parseInt(request.getParameter("rewardId"));

            dao.deleteReward(rewardId);

            response.sendRedirect("MainController?action=rewardManagement");
            return;
        }

        /* ==========================
       BẬT / TẮT ACTIVE
    ===========================*/
        if ("toggle".equals(action)) {

            int rewardId = Integer.parseInt(request.getParameter("rewardId"));

            boolean active
                    = Boolean.parseBoolean(request.getParameter("active"));

            dao.updateStatus(rewardId, active);

            response.sendRedirect("MainController?action=rewardManagement");
            return;
        }

        /* ==========================
       SEARCH
    ===========================*/
        String keyword = request.getParameter("keyword");

        List<Reward> rewardList;

        if (keyword != null && !keyword.trim().isEmpty()) {

            rewardList = dao.searchReward(keyword);

        } else {

            rewardList = dao.getAllRewards();

        }

        request.setAttribute("rewardList", rewardList);

        request.setAttribute("ACTIVE_ADMIN", "voucherreward");

        request.getRequestDispatcher("/Admin/admin_reward.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            RewardDAO dao = new RewardDAO();
            System.out.println("===== DO POST =====");
            String rewardName = request.getParameter("rewardName");
            String description = request.getParameter("description");
            System.out.println("pointsRequired raw = "
                    + request.getParameter("pointsRequired"));
            int pointsRequired = Integer.parseInt(
                    request.getParameter("pointsRequired"));

            String discountStr = request.getParameter("discountPercent");

            double discountPercent = 0;

            if (discountStr != null && !discountStr.trim().isEmpty()) {
                discountPercent = Double.parseDouble(discountStr);
            }
            if (rewardName == null || rewardName.trim().isEmpty()) {

                request.setAttribute("ERROR",
                        "Tên Reward không được để trống.");

                doGet(request, response);

                return;
            }
            if (pointsRequired < 0) {

                request.setAttribute("ERROR",
                        "Điểm đổi phải lớn hơn hoặc bằng 0.");

                doGet(request, response);

                return;
            }
            if (discountPercent < 0 || discountPercent > 100) {

                request.setAttribute("ERROR",
                        "Phần trăm giảm phải từ 0 đến 100.");

                doGet(request, response);

                return;
            }
            String rewardIdStr = request.getParameter("rewardId");
            Reward reward = new Reward();
            if (rewardIdStr != null && !rewardIdStr.trim().isEmpty()
                    && !rewardIdStr.equalsIgnoreCase("undefined")
                    && !rewardIdStr.equalsIgnoreCase("null")) {
                reward.setRewardId(Integer.parseInt(rewardIdStr));
            }
            reward.setRewardName(rewardName);
            reward.setDescription(description);
            reward.setPointsRequired(pointsRequired);
            reward.setDiscountPercent(discountPercent);

            String minBillStr = request.getParameter("minBillAmount");
            String maxDiscountStr = request.getParameter("maxDiscountAmount");

            double minBillAmount = 0;
            double maxDiscountAmount = 0;

            if (minBillStr != null && !minBillStr.trim().isEmpty()) {
                minBillAmount = Double.parseDouble(minBillStr);
            }

            if (maxDiscountStr != null && !maxDiscountStr.trim().isEmpty()) {
                maxDiscountAmount = Double.parseDouble(maxDiscountStr);
            }

            reward.setMinBillAmount(minBillAmount);
            reward.setMaxDiscountAmount(maxDiscountAmount);
            if (minBillAmount < 0) {
                request.setAttribute("ERROR",
                        "Hóa đơn tối thiểu không hợp lệ.");
                doGet(request, response);
                return;
            }

            if (maxDiscountAmount <= 0) {
                request.setAttribute("ERROR",
                        "Giảm tối đa phải lớn hơn 0.");
                doGet(request, response);
                return;
            }
            reward.setActive(true);

            System.out.println("Reward = "
                    + reward.getRewardName());

            System.out.println("Point = "
                    + reward.getPointsRequired());

            System.out.println("Discount = "
                    + reward.getDiscountPercent());

            System.out.println("MinBill = "
                    + reward.getMinBillAmount());

            System.out.println("MaxDiscount = "
                    + reward.getMaxDiscountAmount());

            System.out.println("Active = "
                    + reward.isActive());

            boolean result;

            if (reward.getRewardId() > 0) {

                result = dao.updateReward(reward);

            } else {

                result = dao.insertReward(reward);

            }
            System.out.println("Insert result = " + result);
            if (result) {

                response.sendRedirect(
                        "MainController?action=rewardManagement");

            } else {

                request.setAttribute(
                        "ERROR",
                        "Không thể tạo Reward.");

                doGet(request, response);

            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "ERROR",
                    e.getMessage());

            doGet(request, response);

        }

    }

}
