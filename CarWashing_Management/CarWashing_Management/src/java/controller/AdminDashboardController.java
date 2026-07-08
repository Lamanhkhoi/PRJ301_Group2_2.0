package controller;

import dao.AdminDashboardDAO;
import dao.BookingDAO;
import dao.TimeSlotDAO;
import dto.AdminDashboardData;
import dto.TimeSlot;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DateRangeUtil;
import util.DateRangeUtil.FilterType;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/AdminDashboardController"})
public class AdminDashboardController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            String filterParam = request.getParameter("filterType");
            FilterType filterType = DateRangeUtil.parseFilterType(filterParam);

            // Quét và cập nhật trạng thái booking trước khi tính toán,
            String todayStr = LocalDate.now().toString();
            TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
            Map<Integer, TimeSlot> timeSlotMap = timeSlotDAO.getAllTimeSlots();
            new BookingDAO().scanAndUpdateNoShowStatus(todayStr, timeSlotMap);

            // Tổng hợp toàn bộ dữ liệu Dashboard -- mỗi hàm phụ trách đúng 1 khối
            AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
            AdminDashboardData data = new AdminDashboardData();

            dashboardDAO.loadTodayKpi(data);                        // 1. KPI Cards (luôn "hôm nay")
            dashboardDAO.loadRevenueChart(data, filterType);        // 2. Revenue Chart (theo filter)
            dashboardDAO.loadBookingTrend(data, filterType);        // 3. Booking Trend (theo filter)
            dashboardDAO.loadPaymentOverview(data, filterType);     // 4. Payment Overview (theo filter)
            dashboardDAO.loadTopServices(data, filterType);         // 5. Top Services (theo filter)
            dashboardDAO.loadRecentBookings(data);                  // 6. Recent Bookings (real-time)
            dashboardDAO.loadPromotionMembership(data, filterType); // 7. Promotion/Membership (theo filter)

            request.setAttribute("DASHBOARD_DATA", data);
            request.setAttribute("SELECTED_FILTER", filterType.name().toLowerCase());

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            request.getRequestDispatcher("Admin/admin_dashboard.jsp").forward(request, response);
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
