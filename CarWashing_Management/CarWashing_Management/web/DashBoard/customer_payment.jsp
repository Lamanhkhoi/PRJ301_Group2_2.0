
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dto.WashService"%>
<%@page import="dto.Vehicle"%>
<%@page import="dto.Customer"%>
<%@page import="dto.Booking"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    // ================= INTEGRATE REAL BACKEND DATA =================
    // Lấy thông tin khách hàng và thông tin đặt lịch nháp từ Session
    Customer cus = (Customer) session.getAttribute("CUSTOMER");
    CustomerLoyalty cusLoy = (CustomerLoyalty) request.getAttribute("LOYAL");
    Booking draft = (Booking) session.getAttribute("BOOKING_DRAFT");
    String timeText = (String) session.getAttribute("BOOKING_TIME_TEXT");

    // Nếu chưa có dữ liệu nháp, đá về trang đặt lịch để tránh lỗi
    if (draft == null || cus == null) {
        response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");
        return;
    }

    // Lấy danh sách Voucher thật của khách hàng (Từ request hoặc session do Controller gửi sang)
    // Cấu trúc mảng: {Mã voucher, Tên voucher, Số tiền giảm giá}
    List<String[]> availableVouchers = (List<String[]>) session.getAttribute("AVAILABLE_VOUCHERS");
    if (availableVouchers == null) {
        availableVouchers = new ArrayList<>(); // Tạo danh sách rỗng nếu chưa có dữ liệu
    }

    // Các thông số cấu hình từ hệ thống
    int currentPoints = cusLoy.getCurrentPoints(); // Lấy số điểm hiện tại của khách
    int pointRate = 1;               // 1 Điểm = 1.000đ (Có thể lấy từ DB SystemConfig)
    int pointsWillEarn = (int) (draft.getTotalAmount() / (pointRate*1000));

    // CẤU HÌNH NGÂN HÀNG THẬT CỦA BẠN ĐỂ TẠO CỔNG VIETQR
    String bankId = "BIDV"; // Điền mã ngân hàng của bạn (VD: MB, VCB, TCB, ACB...)
    String accountNo = "96247SMARTWASH"; // Điền SỐ TÀI KHOẢN ngân hàng thật của bạn
    String accountName = "LE NGUYEN MINH THANG"; // Điền TÊN TÀI KHOẢN (Viết hoa không dấu)

    // Tạo mã nội dung chuyển khoản DUY NHẤT để tránh trùng lặp giao dịch giữa các khách hàng
    // Định dạng ngắn gọn gồm mã nhận diện viết liền không dấu: VD: SW + Thời gian hiện tại
    String paymentMemo = "SW" + (System.currentTimeMillis() % 1000000);
    session.setAttribute("PAYMENT_MEMO", paymentMemo); // Lưu lại vào session để Servlet đối chiếu dữ liệu thật
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thanh Toán Đặt Lịch - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body {
            font-family: 'Inter', sans-serif;
        }</style>
    </head>
    <body class="bg-[#F8FAFC] text-slate-800 min-h-screen flex flex-col">

        <%-- ===== HEADER GỌN ===== --%>
        <header class="bg-[#0F172A] text-white">
            <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
                <div class="flex items-center gap-2.5 font-bold">
                    <i class="fa-solid fa-car-side text-emerald-400"></i> SmartWash <span class="text-slate-500 font-normal">·</span> <span class="font-medium">Cổng Thanh Toán Trực Tuyến</span>
                </div>
                <div class="text-xs text-slate-400 flex items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-emerald-400"></i> Mã bảo mật: <span class="font-mono font-bold text-white"><%= paymentMemo%></span>
                </div>
            </div>
        </header>

        <main class="flex-1 max-w-6xl w-full mx-auto px-6 py-8">
            <a href="<%=request.getContextPath()%>/MainController?action=customerBookingPage" class="inline-flex items-center gap-2 text-sm text-slate-400 hover:text-emerald-600 transition mb-6">
                <i class="fa-solid fa-arrow-left"></i> Hủy giao dịch, quay lại chỉnh sửa lịch
            </a>

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

                <%-- ============ CỘT TRÁI (45%): MÃ QR QUÉT TOÀN MÀN HÌNH ============ --%>
                <div class="lg:col-span-5 flex flex-col items-center justify-center bg-white rounded-3xl border border-slate-200 shadow-xl p-8 sticky top-8">
                    <h2 class="text-lg font-bold text-slate-800 mb-1 flex items-center gap-2">
                        <i class="fa-solid fa-qrcode text-[#464BE5]"></i> Quét Mã Để Thanh Toán
                    </h2>
                    <p class="text-xs text-slate-400 text-center mb-6">Hỗ trợ tất cả ứng dụng Ngân hàng Việt Nam & Ví điện tử</p>

                    <!-- Khung hiển thị Mã QR động -->
                    <div class="bg-slate-50 p-4 rounded-2xl inline-block border-2 border-dashed border-slate-200 relative group">
                        <img id="realQRCodeImg" src="https://img.vietqr.io/image/<%= bankId%>-<%= accountNo%>-compact2.png?amount=<%= (int) draft.getTotalAmount()%>&addInfo=<%= paymentMemo%>&accountName=<%= accountName%>" 
                             alt="Mã QR VietQR Thật" class="w-64 h-64 mx-auto object-contain transition-all">

                        <!-- Lớp phủ mờ khi đang cập nhật lại giá tiền -->
                        <div id="qrLoadingOverlay" class="absolute inset-0 bg-white/80 rounded-2xl flex items-center justify-center hidden">
                            <i class="fa-solid fa-spinner fa-spin text-2xl text-[#464BE5]"></i>
                        </div>
                    </div>

                    <!-- Hộp trạng thái lắng nghe giao dịch realtime -->
                    <div id="paymentStatusBox" class="w-full flex items-center justify-center gap-3 bg-blue-50 text-[#464BE5] py-3.5 px-4 rounded-xl font-semibold text-sm mt-6 border border-blue-100">
                        <i class="fa-solid fa-circle-notch fa-spin text-lg" id="statusIcon"></i>
                        <span id="statusText">Hệ thống đang chờ bạn quét mã chuyển khoản...</span>
                    </div>

                    <p class="text-[11px] text-slate-400 text-center mt-4">
                        <i class="fa-solid fa-circle-info mr-1"></i> Vui lòng giữ nguyên nội dung chuyển khoản <span class="font-bold text-slate-700 font-mono"><%= paymentMemo%></span> để hệ thống tự động nhận diện.
                    </p>
                </div>

                <%-- ============ CỘT PHẢI (55%): THÔNG TIN ĐƠN + GIẢM GIÁ ============ --%>
                <div class="lg:col-span-7 space-y-6">

                    <%-- Cấu hình Ưu đãi giảm giá --%>
                    <div class="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 space-y-5">
                        <h3 class="text-base font-bold text-slate-800"><i class="fa-solid fa-tags text-emerald-500 mr-2"></i>Áp dụng ưu đãi giảm tiền</h3>

                        <!-- Voucher -->
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Voucher khả dụng của bạn</label>
                            <select id="voucherSelect" onchange="recalc()" class="w-full px-4 py-3 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-400 transition bg-slate-50 font-medium">
                                <option value="0">Không sử dụng voucher</option>
                                <% for (String[] v : availableVouchers) {%>
                                <input type="hiden" name="rewardId" value="0">
                                <option value="<%= v[2]%>"><%= v[1]%> (−<%= String.format("%,d", Integer.parseInt(v[2]))%>đ)</option>
                                <% }%>
                            </select>
                        </div>

                        <!-- Sử dụng điểm tích lũy -->
                        <div class="border-t border-slate-100 pt-4">
                            <div class="flex items-center justify-between mb-2">
                                <label class="text-xs font-bold text-slate-500 uppercase tracking-wider"><i class="fa-solid fa-coins text-amber-500 mr-1"></i>Tiêu điểm tích lũy (1 P = <%= pointRate%>đ)</label>
                                <button type="button" id="pointToggle" onclick="togglePoints()" class="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-200 transition">
                                    <span class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition translate-x-1"></span>
                                </button>
                            </div>
                            <div id="pointSliderWrap" class="hidden bg-slate-50 p-4 rounded-xl border border-slate-100">
                                <input type="range" id="pointSlider" min="0" max="0" value="0" step="1" oninput="recalc()" class="w-full accent-[#464BE5]">
                                <div class="flex justify-between text-xs mt-2">
                                    <span class="text-slate-400 font-medium">Bạn đang có: <%= String.format("%,d", currentPoints)%> P</span>
                                    <span class="font-bold text-amber-600"><span id="pointUsedLabel">0</span> P đổi giảm −<span id="pointDiscountLabel">0</span>đ</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Tóm tắt chi tiết hóa đơn thanh toán --%>
                    <div class="bg-white rounded-3xl border border-slate-200 shadow-sm p-6">
                        <h3 class="text-base font-bold text-slate-800 mb-4">Chi tiết hóa đơn lịch hẹn</h3>

                        <div class="grid grid-cols-2 gap-4 text-sm bg-slate-50 p-4 rounded-2xl border border-slate-100 mb-4">
                            <div><span class="text-slate-400 block text-xs">Biển số xe</span><span class="font-bold text-slate-700 text-base"><%= draft.getLicensePlate()%></span></div>
                            <div><span class="text-slate-400 block text-xs">Mã dịch vụ đặt</span><span class="font-bold text-slate-700 text-base">DV-<%= draft.getServiceId()%></span></div>
                            <div class="col-span-2 border-t border-slate-200/60 pt-2"><span class="text-slate-400 block text-xs">Thời gian rửa xe đã chọn</span><span class="font-bold text-emerald-600"><%= draft.getBookingDate()%> · <%= timeText%></span></div>
                        </div>

                        <div class="space-y-3 text-sm px-1">
                            <div class="flex justify-between text-slate-500"><span>Giá gốc dịch vụ:</span><span class="font-semibold text-slate-700"><%= String.format("%,d", (int) draft.getTotalAmount())%>đ</span></div>
                            <div class="flex justify-between text-emerald-600 hidden" id="rowVoucher"><span>Khấu trừ từ Voucher:</span><span>−<span id="voucherDiscount">0</span>đ</span></div>
                            <div class="flex justify-between text-amber-600 hidden" id="rowPoint"><span>Khấu trừ từ điểm thưởng:</span><span>−<span id="pointDiscount">0</span>đ</span></div>

                            <div class="border-t border-slate-200 my-3 pt-3 flex items-baseline justify-between">
                                <span class="font-bold text-slate-800 text-base">Thành tiền cần chuyển:</span>
                                <span class="text-3xl font-black text-[#464BE5]" id="grandTotal"><%= String.format("%,d", (int) draft.getTotalAmount())%>đ</span>
                            </div>
                        </div>

                        <div class="bg-amber-50 border border-amber-100 rounded-xl px-4 py-3 mt-4 text-xs text-amber-700 flex items-center gap-2">
                            <i class="fa-solid fa-gift text-sm"></i>
                            <span>Tích lũy thêm <strong>+<%= pointsWillEarn%> P</strong> vào tài khoản sau khi hoàn thành chu trình rửa xe tại cửa hàng.</span>
                        </div>
                    </div>

                </div>
            </div>
        </main>

        <!--        <script>
                    // Các hằng số cấu hình hệ thống đồng bộ từ server
                    const BASE_PRICE = <%= (int) draft.getTotalAmount()%>;
                    const CURRENT_POINTS = <%= currentPoints%>;
                    const POINT_RATE = <%= pointRate%>;
                    const BANK_ID = "<%= bankId%>";
                    const ACCOUNT_NO = "<%= accountNo%>";
                    const ACCOUNT_NAME = encodeURIComponent("<%= accountName%>");
                    const MEMO = "<%= paymentMemo%>";
        
                    let usePoints = false;
                    let currentFinalPrice = BASE_PRICE;
        
                    function togglePoints() {
                        usePoints = !usePoints;
                        const toggle = document.getElementById('pointToggle');
                        const knob = toggle.querySelector('span');
                        toggle.classList.toggle('bg-emerald-500', usePoints);
                        toggle.classList.toggle('bg-slate-200', !usePoints);
                        knob.classList.toggle('translate-x-5', usePoints);
                        knob.classList.toggle('translate-x-1', !usePoints);
                        document.getElementById('pointSliderWrap').classList.toggle('hidden', !usePoints);
                        if (!usePoints) document.getElementById('pointSlider').value = 0;
                        recalc();
                    }
        
                    // HÀM TÍNH TOÁN LẠI GIÁ TIỀN & THAY ĐỔI MÃ QR TỰ ĐỘNG THEO REALTIME
                    function recalc() {
                        const voucherDiscount = parseInt(document.getElementById('voucherSelect').value) || 0;
                        const remainAfterVoucher = Math.max(0, BASE_PRICE - voucherDiscount);
                        
                        const maxPointsByMoney = Math.floor(remainAfterVoucher / POINT_RATE);
                        const maxPoints = Math.min(CURRENT_POINTS, maxPointsByMoney);
        
                        const slider = document.getElementById('pointSlider');
                        slider.max = maxPoints;
                        if (parseInt(slider.value) > maxPoints) slider.value = maxPoints;
        
                        const pointsUsed = usePoints ? parseInt(slider.value) : 0;
                        const pointDiscount = pointsUsed * POINT_RATE;
        
                        // Tính toán thành tiền cuối cùng khách phải quét app chuyển khoản
                        currentFinalPrice = Math.max(0, BASE_PRICE - voucherDiscount - pointDiscount);
        
                        // Re-render UI
                        document.getElementById('voucherDiscount').textContent = voucherDiscount.toLocaleString('vi-VN');
                        document.getElementById('pointDiscount').textContent = pointDiscount.toLocaleString('vi-VN');
                        document.getElementById('pointUsedLabel').textContent = pointsUsed;
                        document.getElementById('pointDiscountLabel').textContent = pointDiscount.toLocaleString('vi-VN');
                        document.getElementById('grandTotal').textContent = currentFinalPrice.toLocaleString('vi-VN') + 'đ';
        
                        document.getElementById('rowVoucher').classList.toggle('hidden', voucherDiscount === 0);
                        document.getElementById('rowPoint').classList.toggle('hidden', pointDiscount === 0);
        
                        // THAY ĐỔI SRC MÃ QR DỰA TRÊN SỐ TIỀN MỚI
                        updateQRCode(currentFinalPrice);
                    }
        
                    function updateQRCode(amount) {
                        const overlay = document.getElementById('qrLoadingOverlay');
                        overlay.classList.remove('hidden'); // Hiện icon xoay loading mã QR
                        
                        const newQRUrl = `https://img.vietqr.io/image/${BANK_ID}-${ACCOUNT_NO}-compact2.png?amount=${amount}&addInfo=${MEMO}&accountName=${ACCOUNT_NAME}`;
                        
                        const imgElement = document.getElementById('realQRCodeImg');
                        imgElement.src = newQRUrl;
                        
                        imgElement.onload = function() {
                            overlay.classList.add('hidden'); // Ẩn loading khi ảnh QR mới tải xong hoàn chỉnh
                        };
                    }
        
                    // ================= LUỒNG TỰ ĐỘNG LẮNG NGHE GIAO DỊCH THẬT (LONG-POLLING) =================
                    // Hệ thống cứ 3 giây một lần sẽ gọi ngầm xuống API Servlet để kiểm tra lịch sử biến động số dư tài khoản
                    const checkPaymentInterval = setInterval(function() {
                        // Đóng gói tham số truyền xuống Server để kiểm tra đúng hóa đơn + đúng số tiền
                        const checkUrl = `<%= request.getContextPath()%>/MainController?action=checkRealPaymentStatus&memo=${MEMO}&amount=${currentFinalPrice}`;
                        
                        fetch(checkUrl)
                            .then(response => response.json())
                            .then(data => {
                                if (data.status === "SUCCESS") {
                                    clearInterval(checkPaymentInterval); // Dừng vòng lặp check ngầm ngay lập tức
                                    
                                    // Thay đổi toàn bộ trạng thái UI sang thành công rực rỡ
                                    const statusBox = document.getElementById('paymentStatusBox');
                                    statusBox.className = "w-full flex items-center justify-center gap-3 bg-emerald-50 text-emerald-600 py-3.5 px-4 rounded-xl font-semibold text-sm mt-6 border border-emerald-100";
                                    document.getElementById('statusIcon').className = "fa-solid fa-circle-check text-lg text-emerald-500";
                                    document.getElementById('statusText').innerText = "Hệ thống đã nhận được tiền thật! Đang tạo lịch hẹn...";
        
                                    // Thu thập dữ liệu giảm giá người dùng đã chọn để nộp lên Server lưu DB chính thức
                                    const voucherDiscount = parseInt(document.getElementById('voucherSelect').value) || 0;
                                    const pointsUsed = usePoints ? parseInt(document.getElementById('pointSlider').value) : 0;
        
                                    // Chuyển hướng trình duyệt gọi lệnh INSERT dữ liệu trực tiếp vào Database thông qua Controller
                                    setTimeout(() => {
                                        window.location.href = `<%= request.getContextPath()%>/MainController?action=executeInsertBooking&voucherDiscount=${voucherDiscount}&pointsUsed=${pointsUsed}&finalPrice=${currentFinalPrice}`;
                                    }, 2000);
                                }
                            })
                            .catch(error => console.error("Lỗi đồng bộ dữ liệu cổng thanh toán:", error));
                    }, 3000); // 3 giây/lần
                </script>-->
        <script>
            // Các hằng số cấu hình hệ thống đồng bộ từ server
            const BASE_PRICE = <%= (int) draft.getTotalAmount()%>;
            const CURRENT_POINTS = <%= currentPoints%>;
            const POINT_RATE = <%= pointRate%>;
            const BANK_ID = "<%= bankId%>";
            const ACCOUNT_NO = "<%= accountNo%>";
            const ACCOUNT_NAME = encodeURIComponent("<%= accountName%>");
            const MEMO = "<%= paymentMemo%>";

            let usePoints = false;
            let currentFinalPrice = BASE_PRICE;
            let paymentTimer = null; // Biến toàn cục quản lý luồng check tiền ngầm

            function togglePoints() {
                usePoints = !usePoints;
                const toggle = document.getElementById('pointToggle');
                const knob = toggle.querySelector('span');
                toggle.classList.toggle('bg-emerald-500', usePoints);
                toggle.classList.toggle('bg-slate-200', !usePoints);
                knob.classList.toggle('translate-x-5', usePoints);
                knob.classList.toggle('translate-x-1', !usePoints);
                document.getElementById('pointSliderWrap').classList.toggle('hidden', !usePoints);
                if (!usePoints)
                    document.getElementById('pointSlider').value = 0;
                recalc();
            }

            // HÀM TÍNH TOÁN LẠI GIÁ TIỀN & THAY ĐỔI MÃ QR TỰ ĐỘNG THEO REALTIME
            function recalc() {
                const voucherDiscount = parseInt(document.getElementById('voucherSelect').value) || 0;
                const remainAfterVoucher = Math.max(0, BASE_PRICE - voucherDiscount);

                const maxPointsByMoney = Math.floor(remainAfterVoucher / POINT_RATE);
                const maxPoints = Math.min(CURRENT_POINTS, maxPointsByMoney);

                const slider = document.getElementById('pointSlider');
                slider.max = maxPoints;
                if (parseInt(slider.value) > maxPoints)
                    slider.value = maxPoints;

                const pointsUsed = usePoints ? parseInt(slider.value) : 0;
                const pointDiscount = pointsUsed * POINT_RATE;

                // Tính toán thành tiền cuối cùng khách phải quét app chuyển khoản
                currentFinalPrice = Math.max(0, BASE_PRICE - voucherDiscount - pointDiscount);

                // Re-render UI văn bản
                document.getElementById('voucherDiscount').textContent = voucherDiscount.toLocaleString('vi-VN');
                document.getElementById('pointDiscount').textContent = pointDiscount.toLocaleString('vi-VN');
                document.getElementById('pointUsedLabel').textContent = pointsUsed;
                document.getElementById('pointDiscountLabel').textContent = pointDiscount.toLocaleString('vi-VN');
                document.getElementById('grandTotal').textContent = currentFinalPrice.toLocaleString('vi-VN') + 'đ';

                document.getElementById('rowVoucher').classList.toggle('hidden', voucherDiscount === 0);
                document.getElementById('rowPoint').classList.toggle('hidden', pointDiscount === 0);

                // THAY ĐỔI SRC MÃ QR DỰA TRÊN SỐ TIỀN MỚI
                updateQRCode(currentFinalPrice);

                // KÍCH HOẠT LẠI LUỒNG LẮNG NGHE ĐỐI SOÁT VỚI SỐ TIỀN MỚI NÀY
                startPaymentChecking(currentFinalPrice);
            }

            function updateQRCode(amount) {
                const overlay = document.getElementById('qrLoadingOverlay');
                overlay.classList.remove('hidden'); // Hiện icon xoay loading mã QR

                // Đảm bảo số tiền truyền vào API là số nguyên không chứa ký tự lạ
                const cleanAmount = Math.floor(amount);
                const newQRUrl = "https://img.vietqr.io/image/" + BANK_ID + "-" + ACCOUNT_NO + "-compact2.png?amount=" + cleanAmount + "&addInfo=" + MEMO + "&accountName=" + ACCOUNT_NAME;

                const imgElement = document.getElementById('realQRCodeImg');
                imgElement.src = newQRUrl;

                imgElement.onload = function () {
                    overlay.classList.add('hidden'); // Tắt xoay loading ngay khi ảnh QR tải thành công
                };

                imgElement.onerror = function () {
                    overlay.classList.add('hidden');
                    console.error("Không thể tải hình ảnh từ VietQR API.");
                };
            }

            // ================= LUỒNG TỰ ĐỘNG LẮNG NGHE GIAO DỊCH THẬT (ĐÃ KHẮC PHỤC TREO) =================
            function startPaymentChecking(amountToCheck) {
                // Bước 1: Xóa bỏ luồng chạy cũ ngay lập tức nếu có để tránh xếp chồng Request
                if (paymentTimer) {
                    clearInterval(paymentTimer);
                }

                // Bước 2: Tạo luồng lắng nghe mới đồng bộ với số tiền truyền vào
                paymentTimer = setInterval(function () {
                    const checkUrl = "<%= request.getContextPath()%>/MainController?action=checkRealPaymentStatus&memo=" + MEMO + "&amount=" + amountToCheck;

                                fetch(checkUrl)
                                        .then(response => response.json())
                                        .then(data => {
                                            if (data.status === "SUCCESS") {
                                                clearInterval(paymentTimer); // Dừng vòng lặp đối soát ngay lập tức

                                                // Thay đổi toàn bộ trạng thái UI sang thành công
                                                const statusBox = document.getElementById('paymentStatusBox');
                                                statusBox.className = "w-full flex items-center justify-center gap-3 bg-emerald-50 text-emerald-600 py-3.5 px-4 rounded-xl font-semibold text-sm mt-6 border border-emerald-100";
                                                document.getElementById('statusIcon').className = "fa-solid fa-circle-check text-lg text-emerald-500";
                                                document.getElementById('statusText').innerText = "Hệ thống đã nhận được tiền thật! Đang tạo lịch hẹn...";

                                                // Thu thập dữ liệu giảm giá chính xác để đẩy về Controller lưu Database
                                                const voucherDiscount = parseInt(document.getElementById('voucherSelect').value) || 0;
                                                const pointsUsed = usePoints ? parseInt(document.getElementById('pointSlider').value) : 0;

                                                // Chuyển hướng trình duyệt gọi lệnh COMMIT đơn hàng vào DB
                                                setTimeout(() => {
                                                    window.location.href = "<%= request.getContextPath()%>/MainController?action=executeInsertBooking&voucherDiscount=" + voucherDiscount + "&pointsUsed=" + pointsUsed + "&finalPrice=" + amountToCheck;
                                                                                }, 1800);
                                                                            }
                                                                        })
                                                                        .catch(error => console.error("Lỗi đồng bộ dữ liệu cổng thanh toán:", error));
                                                            }, 3000); // 3 giây kiểm tra tài khoản một lần
                                                        }

                                                        // Khởi chạy tiến trình lần đầu tiên ngay khi trang vừa tải xong
                                                        window.onload = function () {
                                                            startPaymentChecking(BASE_PRICE);
                                                        };
        </script>
    </body>
</html>