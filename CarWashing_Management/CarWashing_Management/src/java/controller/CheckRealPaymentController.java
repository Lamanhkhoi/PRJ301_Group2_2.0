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
        String amount = request.getParameter("amount");
        String status = "PENDING";

        try {
            // GỌI API TRA CỨU BIẾN ĐỘNG SỐ DƯ THẬT TỪ SEPAY / PAYOS
            // Ví dụ minh họa gọi API tra cứu của SePay:
            String apiKey = "DUKPLR0BT65AIOVGL58PTLSKBEWAMFHKBV2PZENEDNX7182S1WI07G3UAOUHTXRF"; 
//            String apiURL = "https://api.sepay.vn/user/v1/transactions?limit=10"; // Lấy 10 giao dịch mới nhất
            String apiURL = "https://my.sepay.vn/userapi/transactions/list?limit=10";
            
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

                // Dùng cơ chế đọc chuỗi String (hoặc thư viện Gson/Jackson) để phân tích dữ liệu trả về từ Ngân hàng
                String jsonResult = apiResponse.toString();
                
                // Kiểm tra xem trong danh sách lịch sử giao dịch mới nhất, có giao dịch nào chứa nội dung 'memo' 
                // và trùng khớp số tiền 'amount' chuyển khoản hay không
                if (jsonResult.contains(memo) && jsonResult.contains(amount)) {
                    status = "SUCCESS"; // Phát hiện dòng tiền thật chạy vào tài khoản!
                }
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