package controller;

import dao.AdminConfigDAO;
import dao.LoyaltyDAO;
import dto.LoyaltyTier;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminConfigController")
public class AdminConfigController extends HttpServlet {

    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        LoyaltyDAO loyaltyDAO = new LoyaltyDAO();
        AdminConfigDAO configDAO = new AdminConfigDAO();

        String configAction = request.getParameter("configAction");

        try {

            //==========================
            // LOAD PAGE
            //==========================
            if (configAction == null || configAction.equals("view")) {

                List<LoyaltyTier> tierList = loyaltyDAO.getAllTiers();

                Map<String, String> configs = configDAO.getAllConfig();

                request.setAttribute("LOYALTY_LIST", tierList);

                request.setAttribute(
                        "PointExpiryMonths",
                        configs.get("PointExpiryMonths"));

                request.setAttribute(
                        "TierReviewCycle",
                        configs.get("TierReviewCycle"));
                request.setAttribute(
                        "PointRate",
                        configs.get("PointRate"));
                request.setAttribute(
                        "ACTIVE_ADMIN",
                        "cauhinh");

                request.getRequestDispatcher(
                        "/Admin/admin_config.jsp")
                        .forward(request, response);

                return;
            }

            //==========================
            // UPDATE LOYALTY TIER
            //==========================
            if (configAction.equals("updateTier")) {

                LoyaltyTier tier = new LoyaltyTier();

                tier.setTierId(
                        Integer.parseInt(
                                request.getParameter("tierId")));

                tier.setMinWashCount(
                        Integer.parseInt(
                                request.getParameter("minWashCount")));

                tier.setMinTotalSpent(
                        Double.parseDouble(
                                request.getParameter("minTotalSpent")));

                tier.setBonusPointRate(
                        Double.parseDouble(
                                request.getParameter("bonusPointRate"))/ 100.0);

                tier.setBookingWindowDays(
                        Integer.parseInt(
                                request.getParameter("bookingWindowDays")));

                tier.setFreeUpgradeMonthly(
                        request.getParameter("freeUpgradeMonthly") != null);

                tier.setFreeWashMonthly(
                        request.getParameter("freeWashMonthly") != null);

                loyaltyDAO.updateTier(tier);

                response.sendRedirect(
                        request.getContextPath()
                        + "/MainController?action=adminConfig");

                return;
            }

            //==========================
            // UPDATE SYSTEM CONFIG
            //==========================
            if (configAction.equals("updateSystem")) {

                configDAO.updateConfig(
                        "PointExpiryMonths",
                        request.getParameter("PointExpiryMonths"));

                configDAO.updateConfig(
                        "TierReviewCycle",
                        request.getParameter("TierReviewCycle"));

                configDAO.updateConfig(
                        "PointRate",
                        request.getParameter("PointRate"));
                response.sendRedirect(
                        request.getContextPath()
                        + "/MainController?action=adminConfig");

                return;
            }

        } catch (Exception e) {

            e.printStackTrace();
            throw new ServletException(e);

        }

    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);

    }

    @Override
    public String getServletInfo() {
        return "Admin Config Controller";
    }

}
