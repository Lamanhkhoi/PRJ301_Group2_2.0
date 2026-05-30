/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AccountDAO;
import dao.CustomerDAO;
import dto.Account;
import dto.Customer;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Truc
 */
@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) {
        try {
            // 1. Lấy email/username và password (chưa mã hóa) từ form login
            String login = request.getParameter("username");
            String password = request.getParameter("password");

            AccountDAO dao = new AccountDAO();
            Account acc = dao.checkLogin(login, password);

            // COMMENT SỬA ĐỔI: Chuyển khối kiểm tra acc lên trên ĐẦU. 
            // Phải chắc chắn acc khác null thì mới được phép lấy thông tin Customer và xử lý tiếp!
            if (acc == null) {
                // COMMENT SỬA ĐỔI: Tài khoản không tồn tại hoặc đã bị khóa/ngừng hoạt động (đã lọc tại DAO)
                request.setAttribute("ERROR", "Username/Email or Password is invalid, or account is locked!");

                // COMMENT SỬA ĐỔI: Điền trang điều hướng quay về trang login.jsp để hiển thị thông báo lỗi
                request.getRequestDispatcher("home.jsp").forward(request, response);
                return; // Dừng hàm lại, không chạy tiếp xuống dưới
            }

            // COMMENT SỬA ĐỔI: Lúc này chắc chắn acc != null và đang ở trạng thái 'Active'
            // Tiến hành lấy thông tin cá nhân Customer an toàn từ database
            CustomerDAO cdao = new CustomerDAO();
            Customer cus = cdao.getCustomerByAccountId(acc.getAccountID());

            // Lưu thông tin người dùng đăng nhập vào Session hệ thống
            request.getSession().setAttribute("USER", acc);
            request.getSession().setAttribute("CUSTOMER", cus);

            // 2. Phân quyền điều hướng (Role-based Authorization)
            if ("Admin".equalsIgnoreCase(acc.getRole())) {
                // Chuyển hướng sang trang quản trị của Admin
                response.sendRedirect("/CarWashing_Management/DashBoard/admin_dashboard.jsp");
            } else {
                // Chuyển hướng sang trang tổng quan của Khách hàng
                response.sendRedirect("/CarWashing_Management/DashBoard/customer_dashboard.jsp");
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
