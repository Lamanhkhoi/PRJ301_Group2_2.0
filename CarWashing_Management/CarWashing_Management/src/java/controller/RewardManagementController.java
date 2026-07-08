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

            String rewardName = request.getParameter("rewardName");
            String description = request.getParameter("description");

            int pointsRequired = Integer.parseInt(
                    request.getParameter("pointsRequired"));

            double discountPercent = Double.parseDouble(
                    request.getParameter("discountPercent"));

            Reward reward = new Reward();

            reward.setRewardName(rewardName);
            reward.setDescription(description);
            reward.setPointsRequired(pointsRequired);
            reward.setDiscountPercent(discountPercent);

            reward.setMinBillAmount(0);

            reward.setMaxDiscountAmount(0);

            reward.setActive(true);

            RewardDAO dao = new RewardDAO();

            boolean result = dao.insertReward(reward);

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
