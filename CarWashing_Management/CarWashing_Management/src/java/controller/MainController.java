package controller;

import dao.CustomerVehicleDAO;
import dto.Customer;
import dto.Vehicle;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 2,
        maxRequestSize = 1024 * 1024 * 10
)
public class MainController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String url = "home.jsp";
        try {
            String ac = request.getParameter("action");

            if (ac == null) {
                url = "index.jsp";
            } else {
                switch (ac) {
                    // --- LUỒNG QUẢN LÝ HOME PAGE ---
                    case "home":
                        request.setAttribute("activeTab", "trangchu");
                        url = "home.jsp";
                        break;
                    case "login":
                        url = "LoginController";
                        break;
                    case "register":
                        url = "RegisterController";
                        break;

                    // --- LUỒNG QUẢN LÝ DASHBOARD ---
                    case "customerPage":

                        request.setAttribute(
                                "ACTIVE_TAB",
                                "tongquan");

                        url = "CustomerDashboardController";

                        break;
                    case "adminDashboard":
                        request.setAttribute("ACTIVE_ADMIN", "tongquan");
                        if (request.getAttribute("DASHBOARD_DATA") == null) {
                            url = "AdminDashboardController";
                        } else {
                            url = "Admin/admin_dashboard.jsp";
                        }
                        break;

                    // --- Luồng History ---
                    case "customerHistory":
                        url = "HistoryController";
                        break;
                    case "customerHistoryDashboard":
                        request.setAttribute("ACTIVE_TAB", "lichsu");
                        url = "DashBoard/customer_history.jsp";
                        break;

                    // --- LUỒNG QUẢN LÝ VEHICLES ---
                    case "customerVehicle":
                        request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                        url = "DashBoard/customer_vehicles.jsp";
                        break;
                    case "viewVehicle":
                    case "updateVehicle":
                    case "addVehicle":
                    case "deleteVehicle":
                        request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                        url = "VehicleController";
                        break;

                    // --- LUỒNG QUẢN LÝ PROFILE ---
                    case "customerProfile":
                        request.setAttribute("ACTIVE_TAB", "thongtincanhan");
                        url = "DashBoard/customer_profile.jsp";
                        break;
                    case "updateProfile":
                    case "changePassword":
                        request.setAttribute("ACTIVE_TAB", "thongtincanhan");
                        url = "UserProfileController";
                        break;
                    // --- LUỒNG QUẢN LÝ BOOKING ---
                    case "customerBookingPage":
                        Customer cus = (Customer) request.getSession().getAttribute("CUSTOMER");
                        CustomerVehicleDAO veDAO = new CustomerVehicleDAO();
                        List<Vehicle> list = veDAO.getAllVehicles(cus.getCustomerId());
                        if (list == null || list.isEmpty()) {
                            request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                            url = "DashBoard/customer_vehicles.jsp";
                            break;
                        }
                    case "processBooking":
                        request.setAttribute("ACTIVE_TAB", "datlich");
                        url = "BookingController";
                        break;
                    case "checkRealPaymentStatus":
                        url = "CheckRealPaymentController";
                        break;
                    case "calculatePaymentDetails":
                        url = "CalculatePaymentController";
                        break;
                    case "executeInsertBooking":
                        url = "FinalizeBookingController";
                        break;

                    // --- LUỒNG QUẢN LÝ ADMIN BOOKINGS ---
                    case "manageBooking":
                        request.setAttribute("ACTIVE_ADMIN", "quanly_datlich");
                        if (request.getAttribute("SLOT_MAP") == null) {
                            url = "AdminBookingManagement";
                        } else {
                            url = "Admin/admin_booking_management.jsp";
                        }
                        break;
                    case "updateBookingStatus":
                        request.setAttribute("ACTIVE_ADMIN", "quanly_datlich");
                        url = "UpdateBookingStatus";
                        break;
                    //xử lý đưa data lên upcoming.jsp
                    case "customerUpcoming":
                        url = "UpcomingBookingController";
                        break;

                    case "cancelBooking":
                        url = "CancelBookingController";
                        break;
                    // --- LUỒNG QUẢN LÝ ADMIN DASHBOARD ---
                    case "rewardManagement":
                        request.setAttribute("ACTIVE_ADMIN", "voucherreward");
                        url = "RewardManagementController";
                        break;

                    case "promotionManagement":
                        request.setAttribute("ACTIVE_ADMIN", "khuyenmai");
                        url = "PromotionManagementController";
                        break;
                    case "adminConfig":
                        request.setAttribute("ACTIVE_ADMIN", "cauhinh");
                        url = "AdminConfigController";
                        break;
                
                         // --- LUỒNG LOYALTY ENGINE (Điểm Thưởng / Đổi Thưởng / Voucher Của Tôi) ---
                    case "customerLoyalty":
                        url = "LoyaltyController";
                        break;
                    case "customerLoyaltyDashboard":
                        request.setAttribute("ACTIVE_TAB", "diemthuong");
                        url = "DashBoard/customer_loyalty.jsp";
                        break;

                    case "customerRewards":
                        url = "RewardsController";
                        break;
                    case "customerRewardsDashboard":
                        request.setAttribute("ACTIVE_TAB", "rewardcuatoi");
                        url = "DashBoard/customer_rewards.jsp";
                        break;

                    case "customerVouchers":
                        url = "VouchersController";
                        break;
                    case "customerVouchersDashboard":
                        request.setAttribute("ACTIVE_TAB", "vouchercuatoi");
                        url = "DashBoard/customer_vouchers.jsp";
                        break;  
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
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

    @Override
    public String getServletInfo() {
        return "Main Controller for SmartWash Project";
    }
}