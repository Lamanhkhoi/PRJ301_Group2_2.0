package controller;

import dao.AccountDAO;
import dao.CustomerDAO;
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

        try {

            // 1. LẤY DỮ LIỆU TỪ FORM
            String fullname = request.getParameter("reg_fullname");
            String email = request.getParameter("reg_email");
            String phone = request.getParameter("reg_phoneNumber");
            String password = request.getParameter("reg_password");
            String rePassword = request.getParameter("reg_RE_password");

            // 2. VALIDATE DỮ LIỆU
            if (fullname == null || fullname.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()
                    || rePassword == null || rePassword.trim().isEmpty()) {

                request.setAttribute("errorMessage",
                        "Please fill in all required fields.");

                request.setAttribute("SHOW_REGISTER", true);

                request.getRequestDispatcher("/home.jsp")
                        .forward(request, response);
                return;
            }

            // Kiểm tra mật khẩu xác nhận
            if (!password.equals(rePassword)) {

                request.setAttribute("errorMessage",
                        "Password confirmation does not match.");

                request.setAttribute("SHOW_REGISTER", true);

                request.getRequestDispatcher("/home.jsp")
                        .forward(request, response);
                return;
            }

            // 3. KIỂM TRA EMAIL và PHONE TỒN TẠI
            AccountDAO dao = new AccountDAO();

            Account found = dao.getAccountByEmail(email);

            System.out.println("FOUND = " + found);
            if (found != null) {

                System.out.println("EMAIL DUPLICATE");

                request.setAttribute("errorMessage", "Email already exists.");

                request.setAttribute("SHOW_REGISTER", true);

                request.getRequestDispatcher("/home.jsp").forward(request, response);

                return;
            }
            CustomerDAO cdao = new CustomerDAO();

            if (cdao.isPhoneExists(phone)) {

                request.setAttribute("errorMessage",
                        "Phone number already exists.");

                request.setAttribute("SHOW_REGISTER", true);

                request.getRequestDispatcher("/home.jsp")
                        .forward(request, response);

                return;
            }

            // 4. TẠO USERNAME
            // Username = Họ và tên
            String username = fullname;
            // 5. TẠO ACCOUNT OBJECT

            Account acc = new Account();

            acc.setUsername(username);
            acc.setFullname(fullname);
            acc.setEmail(email);

            acc.setPasswordHash(password);

            // 6. LƯU DATABASE
            int accountId = dao.registerAccount(acc);

            // 7. KIỂM TRA KẾT QUẢ
            int customerResult
                    = cdao.insertCustomer(
                            accountId,
                            phone);
            if (accountId > 0
                    && customerResult > 0) {

                System.out.println("REGISTER SUCCESS");

                response.sendRedirect(request.getContextPath() + "/MainController?action=home");

            } else {

                request.setAttribute("errorMessage",
                        "Register failed.");

                request.setAttribute("SHOW_REGISTER", true);

                request.getRequestDispatcher("/home.jsp")
                        .forward(request, response);
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage",
                    e.getMessage());

            request.getRequestDispatcher("login_page/register_view.jsp")
                    .forward(request, response);
        }
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

        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Register Controller";
    }

}
