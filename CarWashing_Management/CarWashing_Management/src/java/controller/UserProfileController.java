package controller;

import dao.AccountDAO;
import dao.CustomerDAO;
import dto.Account;
import dto.Customer;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(name = "UserProfileController", urlPatterns = {"/UserProfileController"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 2, // Tối đa 2 MB cho 1 ảnh đại diện
        maxRequestSize = 1024 * 1024 * 10 // Tối đa 10 MB cho gói dữ liệu Form
)
public class UserProfileController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        Account userAcc = (Account) session.getAttribute("USER");
        Customer cus = (Customer) session.getAttribute("CUSTOMER");

        try {
            // ĐỌC THAM SỐ ACTION ĐỂ PHÂN BIỆT FORM
            String action = request.getParameter("action");

            if ("changePassword".equals(action)) {
                // --- LUỒNG ĐỔI MẬT KHẨU ---
                String oldPassword = request.getParameter("oldPassword");
                String newPassword = request.getParameter("newPassword");

                AccountDAO accountDao = new AccountDAO();
                boolean isChanged = accountDao.changePassword(userAcc.getAccountID(), oldPassword, newPassword);

                if (isChanged) {
                    userAcc.setPasswordHash(newPassword);
                    session.setAttribute("userAcc", userAcc);
                    request.setAttribute("ALERT_TYPE", "success");
                    request.setAttribute("ALERT_MSG", "Thay đổi mật khẩu tài khăn thành công!");
                } else {
                    request.setAttribute("ALERT_TYPE", "error");
                    request.setAttribute("ALERT_MSG", "Mật khẩu hiện tại không chính xác!");
                }

                // Chuyển hướng về trang JSP
                request.getRequestDispatcher("/DashBoard/customer_profile.jsp").forward(request, response);
                return;
            } else {
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phoneNumber");
                String dobString = request.getParameter("dateOfBirth");
                String gender = request.getParameter("gender");
                String address = request.getParameter("address");

                // Đọc trạng thái xóa ảnh ẩn từ Form gửi lên
                String isDeleteAvatar = request.getParameter("isDeleteAvatar");

                Date dob = null;
                if (dobString != null && !dobString.trim().isEmpty()) {
                    dob = new SimpleDateFormat("yyyy-MM-dd").parse(dobString);
                }

                // --- THIẾT LẬP ĐƯỜNG DẪN KÉP ĐẾN THƯ MỤC UPLOADS ---
                String appPath = request.getServletContext().getRealPath("");
                if (appPath.endsWith(File.separator)) {
                    appPath = appPath.substring(0, appPath.length() - 1);
                }

                String savePathBuild = appPath + File.separator + "image" + File.separator + "uploads";
                File dirBuild = new File(savePathBuild);
                if (!dirBuild.exists()) {
                    dirBuild.mkdirs();
                }

                String savePathSource = savePathBuild;
                if (savePathBuild.contains("build" + File.separator + "web")) {
                    savePathSource = savePathBuild.replace("build" + File.separator + "web", "Web Pages");
                    File checkSourceDir = new File(savePathSource);
                    if (!checkSourceDir.exists()) {
                        savePathSource = savePathBuild.replace("build" + File.separator + "web", "web");
                    }
                }
                File dirSource = new File(savePathSource);
                if (!dirSource.exists()) {
                    dirSource.mkdirs();
                }

                String relativeAvatarPath = userAcc.getAvaUrl();

                // 1. LẤY TRẠNG THÁI XÓA TỪ FORM GỬI LÊN
                Part filePart = request.getPart("avatarFile");

                // 2. TIẾN HÀNH QUÉT VÀ XÓA FILE CŨ TRÊN Ổ CỨNG NẾU CÓ YÊU CẦU XÓA HOẶC UP ẢNH MỚI
                if ("true".equals(isDeleteAvatar) || (filePart != null && filePart.getSize() > 0)) {

                    // Giải phóng bộ nhớ kết nối tập tin để tránh lỗi khóa file trên Windows
                    System.gc();

                    // Quét tìm tận gốc các file ảnh có tên "avatar_[AccountId].*" để xóa sạch
                    String[] extensions = {".jpg", ".jpeg", ".png", ".gif", ".webp"};
                    for (String ext : extensions) {
                        String checkFileName = "avatar_" + userAcc.getAccountID() + ext;

                        File fileInBuild = new File(savePathBuild + File.separator + checkFileName);
                        if (fileInBuild.exists()) {
                            fileInBuild.delete();
                        }

                        File fileInSource = new File(savePathSource + File.separator + checkFileName);
                        if (fileInSource.exists()) {
                            fileInSource.delete();
                        }
                    }
                    System.out.println(">>> [SmartWash Log] Da xoa sach file anh cu tren he thong.");

                    // Nếu người dùng thực sự bấm nút xóa ảnh, gán giá trị truyền vào DB là null
                    if ("true".equals(isDeleteAvatar)) {
                        relativeAvatarPath = null;
                    }
                }

                // 3. TRƯỜNG HỢP UP ẢNH MỚI (Lấy thứ tự ưu tiên đè lên hành động xóa)
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedFileName = filePart.getSubmittedFileName();
                    String fileExtension = "";

                    int i = submittedFileName.lastIndexOf('.');
                    if (i > 0) {
                        fileExtension = submittedFileName.substring(i);
                    }

                    String newFileName = "avatar_" + userAcc.getAccountID() + fileExtension;
                    String filePathBuild = savePathBuild + File.separator + newFileName;
                    String filePathSource = savePathSource + File.separator + newFileName;

                    // Ghi file mới vào Server
                    filePart.write(filePathBuild);

                    // Ghi file mới vào mã nguồn gốc Web Pages bằng Stream an toàn
                    try ( InputStream input = filePart.getInputStream()) {
                        File sourceFile = new File(filePathSource);
                        Files.copy(input, sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    relativeAvatarPath = "image/uploads/" + newFileName;
                }

                // --- THỰC THI GHI DỮ LIỆU XUỐNG DATABASE VÀ ĐỒNG BỘ SESSION ---
                AccountDAO accDAO = new AccountDAO();
                CustomerDAO cusDAO = new CustomerDAO();

                boolean updateAccount = accDAO.updateProfileInfo(userAcc.getAccountID(), fullName, email, relativeAvatarPath);
                boolean updateCustomer = cusDAO.updateCustomerInfo(userAcc.getAccountID(), phone, dob, gender, address);

                if (updateAccount && updateCustomer) {
                    // Cập nhật lại Session tức thì để Topbar và UserProfile hiển thị chính xác dữ liệu mới
                    userAcc.setFullname(fullName);
                    userAcc.setEmail(email);
                    userAcc.setAvaUrl(relativeAvatarPath);

                    cus.setPhone(phone);
                    cus.setDob(dob);
                    cus.setGender(gender);
                    cus.setAddress(address);

                    session.setAttribute("USER", userAcc);
                    session.setAttribute("CUSTOMER", cus);

                    request.setAttribute("ALERT_TYPE", "success");
                    request.setAttribute("ALERT_MSG", "Cập nhật thông tin hồ sơ thành công!");
                } else {
                    request.setAttribute("ALERT_TYPE", "error");
                    request.setAttribute("ALERT_MSG", "Lỗi: Không thể lưu thông tin vào cơ sở dữ liệu.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("ALERT_TYPE", "error");
            request.setAttribute("ALERT_MSG", "Hệ thống xảy ra lỗi xử lý: " + e.getMessage());
        }

        // Trả luồng về giao diện hiển thị
        request.getRequestDispatcher("/DashBoard/customer_profile.jsp").forward(request, response);
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
