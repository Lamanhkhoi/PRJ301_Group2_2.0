package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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

        HttpSession session = request.getSession();
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
                        request.setAttribute("ACTIVE_TAB", "tongquan");
                        url = "DashBoard/customer_dashboard.jsp";
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
                    case "bookingCheckSlots":
                    case "processBooking":
                        request.setAttribute("ACTIVE_TAB", "datlich");
                        url = "BookingController";
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
