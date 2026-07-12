package controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CheckRealPaymentController", urlPatterns = {"/CheckRealPaymentController"})
public class CheckRealPaymentController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String memo = request.getParameter("memo");
        String status = "PENDING";

        // JSP hiện tại chỉ gửi memo, không gửi amount -> chỉ cần kiểm tra thiếu memo
        if (memo == null || memo.trim().isEmpty()) {
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\": \"ERROR\", \"message\": \"Thiếu mã giao dịch\"}");
                out.flush();
            }
            return;
        }

        try {
            // GỌI API TRA CỨU BIẾN ĐỘNG SỐ DƯ THẬT TỪ SEPAY
            String apiKey = "DUKPLR0BT65AIOVGL58PTLSKBEWAMFHKBV2PZENEDNX7182S1WI07G3UAOUHTXRF";
            String apiURL = "https://my.sepay.vn/userapi/transactions/list?limit=10"; // Lấy 10 giao dịch mới nhất

            URL url = new URL(apiURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json");

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder apiResponse = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    apiResponse.append(inputLine);
                }
                in.close();

                String jsonResult = apiResponse.toString();

                // Tách chuỗi JSON thành từng giao dịch riêng lẻ (mỗi object trong mảng "transactions"
                // cách nhau bởi "},{"), để kiểm tra memo trên ĐÚNG 1 giao dịch, tránh khớp rải rác
                String[] transactionBlocks = jsonResult.split("\\},\\s*\\{");

                for (String block : transactionBlocks) {
                    // Kiểm tra xem trong nội dung giao dịch có chứa đúng mã memo hay không
                    if (block.contains(memo)) {
                        status = "SUCCESS"; // Phát hiện dòng tiền thật chạy vào tài khoản!
                        break;
                    }
                }

                if (!"SUCCESS".equals(status)) {
                    System.out.println("Chưa tìm thấy giao dịch khớp memo=" + memo);
                }
            } else {
                System.out.println("SePay API trả về lỗi HTTP: " + responseCode);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Trả kết quả JSON về cho JavaScript ở giao diện JSP biết để chuyển trang
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"status\": \"" + status + "\"}");
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
}
