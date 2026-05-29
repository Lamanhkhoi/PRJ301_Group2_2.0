
package controller;

import dao.AccountDAO;
import dto.Account;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterController", urlPatterns = {"/RegisterController"})
public class RegisterController extends HttpServlet {

    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect("index.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            // Lấy dữ liệu từ form register_view.jsp
            String fullname = request.getParameter("reg_fullname");
            String email = request.getParameter("reg_email");
            String phone = request.getParameter("reg_phoneNumber");
            String password = request.getParameter("reg_password");
            String rePassword = request.getParameter("reg_RE_password");

            // Kiểm tra dữ liệu rỗng
            if (fullname == null || fullname.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()
                    || rePassword == null || rePassword.trim().isEmpty()) {

                request.setAttribute("ERROR",
                        "Please fill in all required fields.");

                request.getRequestDispatcher("register.jsp")
                        .forward(request, response);
                return;
            }

            // Kiểm tra xác nhận mật khẩu
            if (!password.equals(rePassword)) {

                request.setAttribute("ERROR",
                        "Password confirmation does not match.");

                request.getRequestDispatcher("register.jsp")
                        .forward(request, response);
                return;
            }

            AccountDAO dao = new AccountDAO();

            // Kiểm tra email đã tồn tại chưa
            Account found = dao.getAccountByEmail(email);

            if (found != null) {

                request.setAttribute("ERROR",
                        "Email already exists.");

                request.getRequestDispatcher("register.jsp")
                        .forward(request, response);
                return;
            }

            // Tự tạo username từ email
            String username;

            if (email.contains("@")) {
                username = email.substring(0, email.indexOf("@"));
            } else {
                username = email;
            }

            // Tạo Account
            Account acc = new Account();

            acc.setFullname(fullname);
            acc.setUsername(username);
            acc.setEmail(email);
            acc.setPasswordHash(password);

            int result = dao.registerAccount(acc);

            if (result > 0) {

                // Hiện tại phone chưa được lưu
                // vì CustomerDAO chưa có method xử lý

                response.sendRedirect("login.jsp");

            } else {

                request.setAttribute("ERROR",
                        "Register failed.");

                request.getRequestDispatcher("register.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("ERROR",
                    "System error occurred.");

            request.getRequestDispatcher("register.jsp")
                    .forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Register Controller";
    }
}

