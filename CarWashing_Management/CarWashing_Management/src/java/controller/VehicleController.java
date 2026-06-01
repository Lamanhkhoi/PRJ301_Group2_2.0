/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.CustomerVehicleDAO;
import dto.Customer;
import dto.Vehicle;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author LENOVO
 */
@WebServlet(name = "VehicleController", urlPatterns = {"/VehicleController"})
public class VehicleController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        try {
            String action = request.getParameter("action");
            HttpSession session = request.getSession();
            Customer cus = (Customer) session.getAttribute("CUSTOMER");
            if (cus == null) {
                response.sendRedirect("home.jsp");
                return;
            }
            CustomerVehicleDAO d = new CustomerVehicleDAO();
            switch (action) {
                case "view":

                    String liplate = request.getParameter("filterPlate");
                    String brand = request.getParameter("filterBrand");
                    String model = request.getParameter("filterModel");
                    String color = request.getParameter("filterColor");

                    List<Vehicle> vehicleList;

                    // Không nhập gì => lấy toàn bộ
                    if ((liplate == null || liplate.trim().isEmpty())
                            && (brand == null || brand.trim().isEmpty())
                            && (model == null || model.trim().isEmpty())
                            && (color == null || color.trim().isEmpty())) {

                        vehicleList = d.getAllVehicles(cus.getCustomerId());
                        request.setAttribute("IS_SEARCH", false);
                    } else {

                        vehicleList = d.searchVehicles(cus.getCustomerId(),
                                liplate, brand, model, color);
                        request.setAttribute("IS_SEARCH", true);
                    }
                    
                    request.setAttribute("VEHICLE_LIST", vehicleList);

                    request.getRequestDispatcher(
                            "/DashBoard/customer_vehicles.jsp"
                    ).forward(request, response);

                    break;
                case "add":
                    liplate = request.getParameter("plate");
                    brand = request.getParameter("brand");
                    model = request.getParameter("model");
                    color = request.getParameter("color");
                    Vehicle vehicle = new Vehicle();
                    vehicle.setCustomerId(cus.getCustomerId());
                    vehicle.setLicensePlate(liplate);
                    vehicle.setBrand(brand);
                    vehicle.setModel(model);
                    vehicle.setColor(color);

                    Vehicle found = d.getVehicle(liplate);
                    if (found == null) {
                        int result = d.addVehicle(vehicle);

                        if (result >= 1) {
                            //chen thanh cong
                            //mo lai trang index.html
                            request.setAttribute("ALERT_TYPE", "success");
                            request.setAttribute("ALERT_MSG", "Vehicle added successfully.");
                            request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                            request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);
                        } else {
                            request.setAttribute("ALERT_TYPE", "error");
                            request.setAttribute("ALERT_MSG", "Duplicate License Plate.");
                            request.setAttribute("ACTIVE_TAB", "cus_vehicle");

                            //mo file customer_vehicles.jsp de xuat msg
                            request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);
                        }
                    } else {
//                        String msg = "duplicate License Plate";
//                        request.setAttribute("ERROR", msg);
//                        request.setAttribute("MODE", "add");
                        request.setAttribute("ALERT_TYPE", "error");
                        request.setAttribute("ALERT_MSG", "Duplicate License Plate.");
                        request.setAttribute("MODE", "add");
                        request.setAttribute("ACTIVE_TAB", "cus_vehicle");

                        //mo file customer_vehicles.jsp de xuat msg
                        request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);
                    }
                    break;

                case "update":
                    liplate = request.getParameter("plate");
                    brand = request.getParameter("brand");
                    model = request.getParameter("model");
                    color = request.getParameter("color");
                    int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
                    found = d.getVehicle(liplate);
                    if (found == null || found.getVehicleId() == vehicleId) {
                        int result = d.updateVehicle(vehicleId, liplate, brand, model, color);

                        if (result >= 1) {
                            //update thanh cong
                            //mo lai trang customer_vehicles.jsp
                            request.setAttribute("ALERT_TYPE", "success");
                            request.setAttribute("ALERT_MSG", "Vehicle updated successfully.");
                            request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                            request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);
                        } else {
                            response.getWriter().print("coming soon");
                        }
                    } else {
//                        String msg = "duplicate License Plate";
//                        request.setAttribute("ERROR", msg);
//                        request.setAttribute("MODE", "edit");
                        request.setAttribute("ALERT_TYPE", "error");
                        request.setAttribute("ALERT_MSG", "Duplicate License Plate.");
                        request.setAttribute("MODE", "edit");
                        request.setAttribute("vehicleId", vehicleId);
                        request.setAttribute("plate", liplate);
                        request.setAttribute("brand", brand);
                        request.setAttribute("model", model);
                        request.setAttribute("color", color);
                        //mo file customer_vehicles.jsp de xuat msg
                        request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                        request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);

                    }
                    break;

                case "delete":
                    vehicleId = Integer.parseInt(request.getParameter("vehicleId"));

                    int result = d.removeVehicle(vehicleId);

                    if (result > 0) {
                        //delete thanh cong
                        request.setAttribute("ALERT_TYPE", "success");
                        request.setAttribute("ALERT_MSG", "Vehicle deleted successfully.");

                    } else {
                        //that bai
                        request.setAttribute("ALERT_TYPE", "error");
                        request.setAttribute("ALERT_MSG", "Delete vehicle failed.");
                    }

                    request.setAttribute("ACTIVE_TAB", "cus_vehicle");
                    request.getRequestDispatcher("DashBoard/customer_vehicles.jsp").forward(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
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
