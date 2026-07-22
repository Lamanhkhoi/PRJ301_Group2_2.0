package controller;

import dao.AdminDashboardDAO;
import dao.BookingDAO;
import dao.TimeSlotDAO;
import dto.AdminDashboardData;
import dto.TimeSlot;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
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
            // Đọc filter từ form POST. Không nhớ qua session
            // Mỗi lần vào lại trang đều reset về mặc định "week"
            String filterParam = request.getParameter("filterType");
            FilterType filterType = DateRangeUtil.parseFilterType(filterParam);

            // Xác định "ngày tham chiếu" -- cho phép Admin xem kỳ khác kỳ hiện tại.
            // 3 nguồn theo thứ tự ưu tiên:
            //   1. Bấm nút "Kỳ trước" / "Kỳ sau"  
            //   2. Tự chọn ngày qua
            //   3. Không có gì (lần đầu vào trang)       
            String referenceDateParam = request.getParameter("referenceDate");
            String navigateParam = request.getParameter("navigate"); // prev | next | null

            LocalDate referenceDate;
            try {
                referenceDate = (referenceDateParam != null && !referenceDateParam.trim().isEmpty())
                        ? LocalDate.parse(referenceDateParam)
                        : LocalDate.now();
            } catch (DateTimeParseException ex) {
                referenceDate = LocalDate.now();
            }

            if ("prev".equals(navigateParam)) {
                referenceDate = DateRangeUtil.shiftPeriod(filterType, referenceDate, -1);
            } else if ("next".equals(navigateParam)) {
                referenceDate = DateRangeUtil.shiftPeriod(filterType, referenceDate, 1);
            } else if ("today".equals(navigateParam)) {
                referenceDate = DateRangeUtil.today();
            }

            // Quét và cập nhật trạng thái booking quá hạn của HÔM NAY trước khi tính toán
            String todayStr = LocalDate.now().toString();
            TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
            Map<Integer, TimeSlot> timeSlotMap = timeSlotDAO.getAllTimeSlots();
            new BookingDAO().scanAndUpdateNoShowStatus(todayStr, timeSlotMap);

            // Tổng hợp toàn bộ dữ liệu Dashboard -- mỗi hàm phụ trách đúng 1 khối
            AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
            AdminDashboardData data = new AdminDashboardData();

            dashboardDAO.loadTodayKpi(data);                                          // KPI Cards (luôn "hôm nay")
            dashboardDAO.loadRevenueChart(data, filterType, referenceDate);           // Revenue Chart
            dashboardDAO.loadBookingTrend(data, filterType, referenceDate);           // Booking Trend
            dashboardDAO.loadPaymentOverview(data, filterType, referenceDate);        // Payment Overview
            dashboardDAO.loadTopServices(data, filterType, referenceDate);            // Top Services
            dashboardDAO.loadRecentBookings(data);                                    // Recent Bookings (real-time)
            dashboardDAO.loadPromotionMembership(data, filterType, referenceDate);    // Promotion/Membership

            // Lưu lại ngày tham chiếu + khoảng ngày đang xem để JSP hiển thị và để ô chọn ngày
            // giữ đúng giá trị đang xem (không tự nhảy về hôm nay sau khi bấm Kỳ trước/Kỳ sau).
            LocalDate[] range = DateRangeUtil.getRange(filterType, referenceDate);
            DateTimeFormatter displayFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            data.setReferenceDate(referenceDate.toString());
            data.setRangeLabel(range[0].format(displayFormat) + " - " + range[1].format(displayFormat));

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
