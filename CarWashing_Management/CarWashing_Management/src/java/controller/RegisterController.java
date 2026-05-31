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

    /**
     * Xử lý chức năng Đăng ký tài khoản
     *
     * Luồng xử lý: 1. Lấy dữ liệu từ form register_view.jsp 2. Kiểm tra dữ liệu
     * hợp lệ 3. Kiểm tra email đã tồn tại hay chưa 4. Tạo đối tượng Account 5.
     * Lưu vào bảng Accounts 6. Chuyển về trang đăng nhập nếu thành công
     */
    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            // =========================
            // 1. LẤY DỮ LIỆU TỪ FORM
            // =========================
            String fullname = request.getParameter("reg_fullname");
            String email = request.getParameter("reg_email");
            String phone = request.getParameter("reg_phoneNumber");
            String password = request.getParameter("reg_password");
            String rePassword = request.getParameter("reg_RE_password");

            // =========================
            // 2. VALIDATE DỮ LIỆU
            // =========================
            if (fullname == null || fullname.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.trim().isEmpty()
                    || rePassword == null || rePassword.trim().isEmpty()) {

                request.setAttribute("ERROR",
                        "Please fill in all required fields.");

                request.getRequestDispatcher(
                        "login_page/register_view.jsp")
                        .forward(request, response);
                return;
            }

            // Kiểm tra mật khẩu xác nhận
            if (!password.equals(rePassword)) {

                request.setAttribute("ERROR",
                        "Password confirmation does not match.");

                request.getRequestDispatcher(
                        "login_page/register_view.jsp")
                        .forward(request, response);
                return;
            }

            // =========================
            // 3. KIỂM TRA EMAIL TỒN TẠI
            // =========================
            AccountDAO dao = new AccountDAO();

            Account found = dao.getAccountByEmail(email);

            if (found != null) {

                request.setAttribute("ERROR",
                        "Email already exists.");

                request.getRequestDispatcher(
                        "login_page/register_view.jsp")
                        .forward(request, response);
                return;
            }

            // =========================
            // 4. TẠO USERNAME
            // =========================
            //
            // Theo yêu cầu hiện tại:
            // Username = Họ và tên
            //
            String username = fullname;

            // =========================
            // 5. TẠO ACCOUNT OBJECT
            // =========================
            Account acc = new Account();

            acc.setUsername(username);
            acc.setFullname(fullname);
            acc.setEmail(email);

            // Hiện tại lưu password thô
            // Sau này sẽ thay bằng Password Hash + Salt
            acc.setPasswordHash(password);

            // Không cần set:
            // AvatarUrl
            // Role
            // Status
            //
            // Vì AccountDAO đã tự gán:
            // Role = Customer
            // AccountStatus = Active
            // =========================
            // 6. LƯU DATABASE
            // =========================
            int result = dao.registerAccount(acc);

            // =========================
            // 7. KIỂM TRA KẾT QUẢ
            // =========================
            if (result > 0) {

                System.out.println("REGISTER SUCCESS");

                System.out.println("Fullname: " + fullname);
                System.out.println("Email: " + email);
                System.out.println("Phone: " + phone);

                // Hiện tại PhoneNumber chưa được lưu
                // Vì CustomerDAO chưa có insertCustomer()
                response.sendRedirect(
                        request.getContextPath()
                        + "/login_page/login_view.jsp");

            } else {

                request.setAttribute("ERROR",
                        "Register failed.");

                request.getRequestDispatcher(
                        "login_page/register_view.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute("ERROR",
                    "System error occurred.");

            request.getRequestDispatcher(
                    "login_page/register_view.jsp")
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
