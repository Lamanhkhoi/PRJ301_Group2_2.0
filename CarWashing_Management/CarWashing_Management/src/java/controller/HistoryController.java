/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.CustomerHistoryDAO;
import dto.BookingHistory;
import dto.Customer;
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
 * @author Admin
 */
@WebServlet(name = "HistoryController", urlPatterns = {"/HistoryController"})
public class HistoryController extends HttpServlet {

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
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession();
        Customer cus = (Customer) session.getAttribute("CUSTOMER");
        
        if(cus == null){
            response.sendRedirect("MainController?action=login");
        }
        
        try {
            String statusFilter = request.getParameter("statusFilter");
            String timeFilter = request.getParameter("timeFilter");
            String pageStr = request.getParameter("page");
            
            if (statusFilter == null) statusFilter = "ALL";
            if (timeFilter == null) timeFilter = "ALL";
            int page = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr); 
            }
            int pageSize = 10;
            
            
            CustomerHistoryDAO dao = new CustomerHistoryDAO();
            // Lấy tính tổng số giao dịch trong lịch sử
            int totalRecords = dao.countTotalHistory(cus.getCustomerId(), statusFilter, timeFilter);
            // Dùng Math.ceil để làm tròn lên (Ví dụ 45/10 = 4.5 -> làm tròn thành 5 trang)
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            
            List<BookingHistory> historyList = dao.getHistory(cus.getCustomerId(), statusFilter, timeFilter, page, pageSize);
            
            request.setAttribute("HISTORY_LIST", historyList);
            request.setAttribute("TOTAL_PAGES", totalPages);
            request.setAttribute("CURRENT_PAGE", page);
            request.setAttribute("TOTAL_RECORDS", totalRecords);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("timeFilter", timeFilter);
            
            request.getRequestDispatcher("DashBoard/customer_history.jsp").forward(request, response); 
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("MainController?action=customerPage");
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
