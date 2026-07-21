package controller;

import dao.PromotionDAO;
import dto.Promotion;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.annotation.WebServlet;

@WebServlet(name = "PromotionManagementController", urlPatterns = {"/PromotionManagementController"})
public class PromotionManagementController extends HttpServlet {

    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        PromotionDAO dao = new PromotionDAO();

        String action = request.getParameter("promotionAction");

        try {

            //========================
            // LIST
            //========================
            if (action == null || action.equals("list")) {

                List<Promotion> list = dao.getAllPromotion();

                request.setAttribute("PROMOTION_LIST", list);

                request.getRequestDispatcher("/Admin/admin_promotion.jsp")
                        .forward(request, response);

                return;
            }

            //========================
            // CREATE
            //========================
            if (action.equals("create")) {

                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");

                if (startDateStr != null && startDateStr.equals(endDateStr)) {
                    request.getSession().setAttribute("PROMO_ERROR",
                            "Không thể tạo khuyến mãi có thời hạn chỉ trong 1 ngày! Vui lòng chọn Từ ngày và Đến ngày khác nhau.");
                    response.sendRedirect(
                            request.getContextPath()
                            + "/MainController?action=promotionManagement");
                    return;
                }

                Promotion p = new Promotion();

                p.setPromotionName(request.getParameter("promotionName"));
                p.setDescription(request.getParameter("description"));

                p.setDiscountPercent(
                        Double.parseDouble(request.getParameter("discountPercent")));

                p.setMinBillAmount(
                        Double.parseDouble(request.getParameter("minBillAmount")));

                p.setMaxDiscountAmount(
                        Double.parseDouble(request.getParameter("maxDiscountAmount")));

                try {
                    java.util.Date parsed
                            = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
                                    .parse(request.getParameter("startDate") + " 00:00:00");

                    p.setStartDate(new java.sql.Date(parsed.getTime()));
                } catch (ParseException e) {
                    throw new RuntimeException("Invalid startDate: " + request.getParameter("startDate"), e);
                }

                try {
                    java.util.Date parsed
                            = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
                                    .parse(request.getParameter("endDate") + " 23:59:59");

                    p.setEndDate(new java.sql.Date(parsed.getTime()));
                } catch (ParseException e) {
                    throw new RuntimeException("Invalid endDate: " + request.getParameter("endDate"), e);
                }

                p.setActive(true);

                dao.insertPromotion(p);

                response.sendRedirect(
                        request.getContextPath()
                        + "/MainController?action=promotionManagement");

                return;
            }

            //========================
            // UPDATE
            //========================
            if (action.equals("update")) {

                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");

                if (startDateStr != null && startDateStr.equals(endDateStr)) {
                    request.getSession().setAttribute("PROMO_ERROR",
                            "Không thể cập nhật khuyến mãi có thời hạn chỉ trong 1 ngày!");
                    response.sendRedirect(
                            request.getContextPath()
                            + "/MainController?action=promotionManagement");
                    return;
                }

                Promotion p = new Promotion();

                p.setPromotionId(
                        Integer.parseInt(request.getParameter("promotionId")));

                p.setPromotionName(request.getParameter("promotionName"));
                p.setDescription(request.getParameter("description"));

                p.setDiscountPercent(
                        Double.parseDouble(request.getParameter("discountPercent")));

                p.setMinBillAmount(
                        Double.parseDouble(request.getParameter("minBillAmount")));

                p.setMaxDiscountAmount(
                        Double.parseDouble(request.getParameter("maxDiscountAmount")));

                p.setStartDate(
                        Timestamp.valueOf(
                                request.getParameter("startDate") + " 00:00:00"));

                p.setEndDate(
                        Timestamp.valueOf(
                                request.getParameter("endDate") + " 23:59:59"));

                dao.updatePromotion(p);

                response.sendRedirect(
                        request.getContextPath()
                        + "/MainController?action=promotionManagement");

                return;
            }

            //========================
            // TOGGLE ACTIVE
            //========================
            if (action.equals("toggle")) {

                int id = Integer.parseInt(request.getParameter("id"));

                Promotion p = dao.getPromotionById(id);

                if (p != null) {
                    dao.updateStatus(id, !p.isActive());
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/MainController?action=promotionManagement");

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

}
