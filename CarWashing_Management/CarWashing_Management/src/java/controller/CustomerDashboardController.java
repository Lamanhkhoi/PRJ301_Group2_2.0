package controller;

import dao.CustomerLoyaltyDAO;
import dto.Account;
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
            
            // Đọc thông tin thực tế từ Session kiểm tra Login
            Account acc = (Account) session.getAttribute("USER");
            Customer cus = (Customer) session.getAttribute("CUSTOMER");
            
            // KIỂM TRA BẢO MẬT: Nếu chưa đăng nhập, đá về trang login ngay lập tức
            if (acc == null || cus == null) {
                request.setAttribute("LOGIN_ERROR", "Vui lòng đăng nhập hệ thống để xem hồ sơ thành viên!");
                request.getRequestDispatcher("home.jsp").forward(request, response);
                return;
            }

            // Gọi đúng hàm getAccountID() chữ ID viết hoa theo đúng DTO của bạn
            int accId = acc.getAccountID();
            
            // Thực hiện gọi DAO kết nối DB thật
            CustomerLoyalty loyaltyProfile = loyaltyDAO.getLoyaltyProfileByAccountId(accId);
            
            // Gửi dữ liệu đồng bộ sang cho file .jsp
            request.setAttribute("LOYALTY_PROFILE", loyaltyProfile);
            
            // Điều hướng sang file hiển thị
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
