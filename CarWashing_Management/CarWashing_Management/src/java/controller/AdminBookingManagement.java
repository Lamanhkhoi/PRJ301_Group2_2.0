package controller;

import dao.BookingDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminBookingManagement", urlPatterns = {"/AdminBookingManagement"})
public class AdminBookingManagement extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession();

            // Kiểm tra và lấy dữ liệu bộ lọc được treo tạm ở Session
            String keepDate = (String) session.getAttribute("KEEP_DATE");
            String keepPlate = (String) session.getAttribute("KEEP_PLATE");

            String dateParam = request.getParameter("bookingDate");
            String searchLicensePlate = request.getParameter("searchLicensePlate");

            if (keepDate != null) {
                dateParam = keepDate;
                session.removeAttribute("KEEP_DATE"); 
            }
            if (keepPlate != null) {
                searchLicensePlate = keepPlate;
                session.removeAttribute("KEEP_PLATE"); 
            }

            // Chuyển tiếp các thông điệp Toast Alert từ Session
            String sessAlert = (String) session.getAttribute("ALERT_TYPE");
            String sessMsg = (String) session.getAttribute("ALERT_MSG");
            if (sessAlert != null) {
                request.setAttribute("ALERT_TYPE", sessAlert);
                request.setAttribute("ALERT_MSG", sessMsg);
                session.removeAttribute("ALERT_TYPE");
                session.removeAttribute("ALERT_MSG");
            }

            // Xử lý giá trị mặc định của bộ lọc
            if (dateParam == null || dateParam.trim().isEmpty()) {
                dateParam = LocalDate.now().toString();
            }
            if (searchLicensePlate == null) {
                searchLicensePlate = "";
            }

            boolean isFiltered = !searchLicensePlate.trim().isEmpty();
            BookingDAO dao = new BookingDAO();

            // QUÉT VÀ CẬP NHẬT TRƯỚC KHI HIỂN THỊ (Logic NoShow giữ nguyên của bạn)
            LocalDate today = LocalDate.now();
            LocalTime now = LocalTime.now();

            List<Map<String, Object>> allBookingsForCheck = dao.getAdminBookingSlots(dateParam, "");
            if (allBookingsForCheck != null) {
                for (Map<String, Object> b : allBookingsForCheck) {
                    String status = (String) b.get("BookingStatus");
                    int slotNumber = (Integer) b.get("SlotNumber");
                    int bookingId = (Integer) b.get("BookingId");
                    LocalDate bDate = LocalDate.parse(dateParam);

                    boolean isPastDate = bDate.isBefore(today);

                    // Nếu đơn ở trạng thái Pending ở QUÁ KHỨ -> No show
                    if ("Pending".equals(status)) {
                        double startHour = 8.0 + (slotNumber - 1) / 2.0;
                        int hourPart = (int) startHour;
                        int minutePart = (startHour % 1 == 0) ? 0 : 30;
                        LocalTime slotStartTime = LocalTime.of(hourPart, minutePart);
                        LocalTime noShowDeadline = slotStartTime.plusMinutes(1);

                        boolean isTodayAndOverdue = bDate.isEqual(today) && now.isAfter(noShowDeadline);

                        if (isPastDate || isTodayAndOverdue) {
                            dao.updateBookingStatus(bookingId, "NoShow");
                        }
                    }

                    // Nếu đơn CheckedIn ở QUÁ KHỨ -> Completed
                    if ("CheckedIn".equals(status) && isPastDate) {
                        dao.updateBookingStatus(bookingId, "Completed");
                    }
                }
            }

            // Tiến hành lấy lại dữ liệu mới nhất sau khi quét
            List<Map<String, Object>> rawBookings = dao.getAdminBookingSlots(dateParam, searchLicensePlate);

            Map<Integer, List<Map<String, Object>>> slotMap = new HashMap<>();
            for (int i = 1; i <= 28; i++) {
                slotMap.put(i, new ArrayList<>());
            }

            int totalCount = 0;
            int pendingCount = 0;
            int checkedInCount = 0;
            int completedCount = 0;

            if (rawBookings != null) {
                for (Map<String, Object> b : rawBookings) {
                    int slotNumber = (Integer) b.get("SlotNumber");
                    String status = (String) b.get("BookingStatus");

                    if (slotMap.containsKey(slotNumber) && !"Cancelled".equals(status)) {
                        slotMap.get(slotNumber).add(b);
                    }

                    totalCount++;
                    if ("Pending".equals(status)) {
                        pendingCount++;
                    } else if ("CheckedIn".equals(status)) {
                        checkedInCount++;
                    } else if ("Completed".equals(status)) {
                        completedCount++;
                    }
                }
            }

            request.setAttribute("SLOT_MAP", slotMap);
            request.setAttribute("TOTAL_COUNT", totalCount);
            request.setAttribute("PENDING_COUNT", pendingCount);
            request.setAttribute("CHECKEDIN_COUNT", checkedInCount);
            request.setAttribute("COMPLETED_COUNT", completedCount);
            request.setAttribute("CURRENT_DATE_STR", dateParam);
            request.setAttribute("IS_FILTERED", isFiltered);

        } catch (Exception e) {
            log("Error in AdminBookingManagement: " + e.getMessage());
            e.printStackTrace();
        } finally {
            request.getRequestDispatcher("Admin/admin_booking_management.jsp").forward(request, response);
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
