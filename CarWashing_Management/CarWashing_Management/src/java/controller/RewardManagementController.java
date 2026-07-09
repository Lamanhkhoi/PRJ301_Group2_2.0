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

        RewardDAO dao = new RewardDAO();

        List<Reward> rewardList = dao.getAllRewards();

        request.setAttribute("rewardList", rewardList);

        request.setAttribute("ACTIVE_ADMIN", "voucherreward");

        request.getRequestDispatcher("/Admin/admin_reward.jsp")
                .forward(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            System.out.println("===== DO POST =====");
            String rewardName = request.getParameter("rewardName");
            String description = request.getParameter("description");

            int pointsRequired = Integer.parseInt(
                    request.getParameter("pointsRequired"));

            double discountPercent = Double.parseDouble(
                    request.getParameter("discountPercent"));
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

            Reward reward = new Reward();

            reward.setRewardName(rewardName);
            reward.setDescription(description);
            reward.setPointsRequired(pointsRequired);
            reward.setDiscountPercent(discountPercent);

            double minBillAmount = Double.parseDouble(
                    request.getParameter("minBillAmount"));

            double maxDiscountAmount = Double.parseDouble(
                    request.getParameter("maxDiscountAmount"));

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

            RewardDAO dao = new RewardDAO();

            boolean result = dao.insertReward(reward);
            System.out.println("Insert = " + result);
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
