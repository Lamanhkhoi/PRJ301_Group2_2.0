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
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 2,
        maxRequestSize = 1024 * 1024 * 10
)
public class UserProfileController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        Account userAcc = (Account) session.getAttribute("USER");
        Customer cus = (Customer) session.getAttribute("CUSTOMER");

        try {
            String action = request.getParameter("action");

            if ("changePassword".equals(action)) {
                // --- LUỒNG ĐỔI MẬT KHẨU ---
                String oldPassword = request.getParameter("oldPassword");
                String newPassword = request.getParameter("newPassword");

                AccountDAO accountDao = new AccountDAO();
                boolean isChanged = accountDao.changePassword(userAcc.getAccountID(), oldPassword, newPassword);

                if (isChanged) {
                    userAcc.setPasswordHash(newPassword);
                    session.setAttribute("USER", userAcc);
                    request.setAttribute("ALERT_TYPE", "success");
                    request.setAttribute("ALERT_MSG", "Thay đổi mật khẩu tài khoản thành công!");
                } else {
                    request.setAttribute("ALERT_TYPE", "error");
                    request.setAttribute("ALERT_MSG", "Mật khẩu hiện tại không chính xác!");
                }

            } else if ("updateProfile".equals(action)) {
                // --- LUỒNG CẬP NHẬT THÔNG TIN ---
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phoneNumber");
                String dobString = request.getParameter("dateOfBirth");
                String gender = request.getParameter("gender");
                String address = request.getParameter("address");
                String isDeleteAvatar = request.getParameter("isDeleteAvatar");

                Date dob = null;
                if (dobString != null && !dobString.trim().isEmpty()) {
                    dob = new SimpleDateFormat("yyyy-MM-dd").parse(dobString);
                }

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
                Part filePart = request.getPart("avatarFile");

                if ("true".equals(isDeleteAvatar) || (filePart != null && filePart.getSize() > 0)) {
                    System.gc();
                    String[] extensions = {".jpg", ".jpeg", ".png", ".gif", ".webp"};
                    for (String ext : extensions) {
                        String checkFileName = "avatar_" + userAcc.getAccountID() + ext;
                        new File(savePathBuild + File.separator + checkFileName).delete();
                        new File(savePathSource + File.separator + checkFileName).delete();
                    }
                    if ("true".equals(isDeleteAvatar)) {
                        relativeAvatarPath = null;
                    }
                }

                if (filePart != null && filePart.getSize() > 0) {
                    String submittedFileName = filePart.getSubmittedFileName();
                    String fileExtension = "";
                    int i = submittedFileName.lastIndexOf('.');
                    if (i > 0) {
                        fileExtension = submittedFileName.substring(i);
                    }

                    String newFileName = "avatar_" + userAcc.getAccountID() + fileExtension;
                    filePart.write(savePathBuild + File.separator + newFileName);

                    try ( InputStream input = filePart.getInputStream()) {
                        File sourceFile = new File(savePathSource + File.separator + newFileName);
                        Files.copy(input, sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    relativeAvatarPath = "image/uploads/" + newFileName;
                }

                AccountDAO accDAO = new AccountDAO();
                CustomerDAO cusDAO = new CustomerDAO();

                boolean updateAccount = accDAO.updateProfileInfo(userAcc.getAccountID(), fullName, email, relativeAvatarPath);
                boolean updateCustomer = cusDAO.updateCustomerInfo(userAcc.getAccountID(), phone, dob, gender, address);

                if (updateAccount && updateCustomer) {
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
            request.setAttribute("ALERT_MSG", "Hệ thống xảy ra lỗi: " + e.getMessage());
        }
        request.getRequestDispatcher("MainController?action=customerProfile").forward(request, response);
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
