/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.CustomerLoyaltyDAO;
import dto.Customer;
import dto.CustomerLoyalty;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


@WebServlet(name = "CustomerDashboardController", urlPatterns = {"/CustomerDashboardController"})
public class CustomerDashboardController extends HttpServlet {

    private CustomerLoyaltyDAO loyaltyDAO = new CustomerLoyaltyDAO();
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        try {
            HttpSession session = request.getSession();
            
            // Lấy thông tin tài khoản người dùng thực tế từ Session Đăng nhập
            Customer customer = (Customer) session.getAttribute("USER");
            
            // BỔ SUNG: Kiểm tra bảo mật hệ thống khi chạy thật
            if (customer == null) {
                // Nếu chưa đăng nhập, bắt buộc chuyển hướng về trang login và dừng xử lý phía sau
                request.setAttribute("LOGIN_ERROR", "Vui lòng đăng nhập hệ thống để xem thông tin hạng thành viên!");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return; 
            }

            int accId = customer.getAccountId();
            
            // Lấy dữ liệu loyalty thật từ Database thông qua DAO
            CustomerLoyalty loyaltyProfile = loyaltyDAO.getLoyaltyProfileByAccountId(accId);
            
            // Đẩy dữ liệu sang file .jsp của bạn FE hiển thị
            request.setAttribute("LOYALTY_PROFILE", loyaltyProfile);
            
            // Điều hướng sang file JSP hiển thị giao diện chính thức
            request.getRequestDispatcher("/views/customer_dashboard.jsp").forward(request, response);
            
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
        return "Controller xử lý hiển thị Hồ sơ hạng thành viên và Lợi ích kế tiếp (Next Reward)";
    }// </editor-fold>

}
