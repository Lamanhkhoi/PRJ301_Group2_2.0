package controller;

import dao.CustomerVehicleDAO;
import dto.Customer;
import dto.Vehicle;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "VehicleController", urlPatterns = {"/VehicleController"})
public class VehicleController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String url = "MainController?action=customerVehicle";
        boolean isRedirect = false;
        try {
            String action = request.getParameter("action");
            HttpSession session = request.getSession();

            // Đồng bộ đồng loạt sử dụng KEY viết hoa "CUSTOMER"
            Customer cus = (Customer) session.getAttribute("CUSTOMER");
            if (cus == null) {
                response.sendRedirect(request.getContextPath() + "/MainController?action=home");
                return;
            }

            CustomerVehicleDAO d = new CustomerVehicleDAO();
            switch (action) {
                case "viewVehicle":
                    String liplate = request.getParameter("filterPlate");
                    String brand = request.getParameter("filterBrand");
                    String model = request.getParameter("filterModel");
                    String color = request.getParameter("filterColor");

                    List<Vehicle> vehicleList;

                    if ((liplate == null || liplate.trim().isEmpty())
                            && (brand == null || brand.trim().isEmpty())
                            && (model == null || model.trim().isEmpty())
                            && (color == null || color.trim().isEmpty())) {

                        vehicleList = d.getAllVehicles(cus.getCustomerId());
                        request.setAttribute("IS_SEARCH", false);
                    } else {
                        vehicleList = d.searchVehicles(cus.getCustomerId(), liplate, brand, model, color);
                        request.setAttribute("IS_SEARCH", true);
                    }
                    request.setAttribute("VEHICLE_LIST", vehicleList);
                    isRedirect = false;
                    break;

                case "addVehicle":
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
                            // Thành công -> Lưu msg vào session để chuyển hướng Redirect không bị mất
                            session.setAttribute("ALERT_TYPE", "success");
                            session.setAttribute("ALERT_MSG", "Thêm phương tiện mới thành công!");
                            isRedirect = true;
                        } else {
                            request.setAttribute("ALERT_TYPE", "error");
                            request.setAttribute("ALERT_MSG", "Lỗi: Không thể thêm phương tiện vào hệ thống.");
                            isRedirect = false;
                        }
                    } else {
                        request.setAttribute("ALERT_TYPE", "error");
                        request.setAttribute("ALERT_MSG", "Biển số xe này đã tồn tại trên hệ thống!");
                        request.setAttribute("MODE", "add");
                        request.setAttribute("plate", liplate);
                        request.setAttribute("brand", brand);
                        request.setAttribute("model", model);
                        request.setAttribute("color", color);
                        isRedirect = false;
                    }
                    break;

                case "updateVehicle":
                    liplate = request.getParameter("plate");
                    brand = request.getParameter("brand");
                    model = request.getParameter("model");
                    color = request.getParameter("color");
                    int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
                    found = d.getVehicle(liplate);

                    if (found == null || found.getVehicleId() == vehicleId) {
                        int result = d.updateVehicle(vehicleId, liplate, brand, model, color);
                        if (result >= 1) {
                            session.setAttribute("ALERT_TYPE", "success");
                            session.setAttribute("ALERT_MSG", "Cập nhật thông tin xe thành công!");
                            isRedirect = true;
                        } else {
//                            response.getWriter().print("Hệ thống bảo trì chức năng cập nhật!");
                            session.setAttribute("ALERT_TYPE", "fail");
                            session.setAttribute("ALERT_MSG", "Cập nhật thông tin xe thất bại!");
                            isRedirect = true;
                        }
                    } else {
                        request.setAttribute("ALERT_TYPE", "error");
                        request.setAttribute("ALERT_MSG", "Biển số chỉnh sửa đã được dùng cho xe khác!");
                        request.setAttribute("MODE", "edit");
                        request.setAttribute("vehicleId", vehicleId);
                        request.setAttribute("plate", liplate);
                        request.setAttribute("brand", brand);
                        request.setAttribute("model", model);
                        request.setAttribute("color", color);
                        isRedirect = false;
                    }
                    break;

                case "deleteVehicle":
                    vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
                    int result = d.removeVehicle(vehicleId);

                    if (result > 0) {
                        session.setAttribute("ALERT_TYPE", "success");
                        session.setAttribute("ALERT_MSG", "Xóa phương tiện thành công!");
                    } else {
                        session.setAttribute("ALERT_TYPE", "error");
                        session.setAttribute("ALERT_MSG", "Xóa phương tiện thất bại.");
                    }
                    isRedirect = true;
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (isRedirect) {
                response.sendRedirect(request.getContextPath() + "/MainController?action=customerVehicle");
            } else {
                request.getRequestDispatcher(url).forward(request, response);
            }
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
