<%@page import="dto.RewardRedemption"%>
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dto.WashService"%>
<%@page import="dto.Vehicle"%>
<%@page import="dto.Customer"%>
<%@page import="dto.Booking"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    Customer cus = (Customer) session.getAttribute("CUSTOMER");
    CustomerLoyalty cusLoy = (CustomerLoyalty) request.getAttribute("LOYAL");
    Booking draft = (Booking) session.getAttribute("BOOKING_DRAFT");
    String timeText = (String) session.getAttribute("BOOKING_TIME_TEXT");

    if (draft == null || cus == null) {
        response.sendRedirect(request.getContextPath() + "/MainController?action=customerBookingPage");
        return;
    }

    List<RewardRedemption> availableVouchers = (List<RewardRedemption>) request.getAttribute("AVAILABLE_VOUCHERS");
    if (availableVouchers == null) {
        availableVouchers = new ArrayList<RewardRedemption>();
    }

    int currentPoints = cusLoy.getCurrentPoints();
    int pointRate = 1000; // 1 Điểm = 1.000đ
    int pointsWillEarn = (int) (draft.getTotalAmount() / pointRate);

    String bankId = "BIDV";
    String accountNo = "96247SMARTWASH";
    String accountName = "LE NGUYEN MINH THANG";

    String paymentMemo = "SW" + (System.currentTimeMillis() % 1000000);
    session.setAttribute("PAYMENT_MEMO", paymentMemo);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thanh Toán Đặt Lịch - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <!--        <style>
                    body { font-family: 'Inter', sans-serif; }
                    .voucher-box-item { transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); }
                    /* Hiệu ứng tạo nếp vé răng cưa giả lập bằng CSS nếu muốn */
                    .ticket-edge { relative;}
                    .ticket-edge::before, .ticket-edge::after {
                        content: ''; position: absolute; left: -6px; width: 12px; height: 12px; background: #F8FAFC; border-radius: 50%;
                    }
                    .ticket-edge::before { top: 25%; }
                    .ticket-edge::after { bottom: 25%; }
                </style>-->
    </head>
    <body class="bg-[#F8FAFC] text-slate-800 min-h-screen flex flex-col">
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
                <!-- CỘT TRÁI: MÃ QR -->
                <div class="lg:col-span-5 flex flex-col items-center justify-center bg-white rounded-3xl border border-slate-200 shadow-xl p-8 sticky top-8">
                    <h2 class="text-lg font-bold text-slate-800 mb-1 flex items-center gap-2">
                        <i class="fa-solid fa-qrcode text-[#464BE5]"></i> Quét Mã Để Thanh Toán
                    </h2>
                    <p class="text-xs text-slate-400 text-center mb-6">Hỗ trợ tất cả ứng dụng Ngân hàng Việt Nam & Ví điện tử</p>

                    <div class="bg-slate-50 p-4 rounded-2xl inline-block border-2 border-dashed border-slate-200 relative group">
                        <img id="realQRCodeImg" src="https://img.vietqr.io/image/<%= bankId%>-<%= accountNo%>-compact2.png?amount=<%= (int) draft.getTotalAmount()%>&addInfo=<%= paymentMemo%>&accountName=<%= accountName%>" 
                             alt="Mã QR VietQR" class="w-64 h-64 mx-auto object-contain">
                        <div id="qrLoadingOverlay" class="absolute inset-0 bg-white/80 rounded-2xl flex items-center justify-center hidden">
                            <i class="fa-solid fa-spinner fa-spin text-2xl text-[#464BE5]"></i>
                        </div>
                    </div>

                    <div id="paymentStatusBox" class="w-full flex items-center justify-center gap-3 bg-blue-50 text-[#464BE5] py-3.5 px-4 rounded-xl font-semibold text-sm mt-6 border border-blue-100">
                        <i class="fa-solid fa-circle-notch fa-spin text-lg" id="statusIcon"></i>
                        <span id="statusText">Hệ thống đang chờ bạn quét mã chuyển khoản...</span>
                    </div>
                </div>

                <!-- CỘT PHẢI: ƯU ĐÃI (DẠNG BOX POPUP) & HÓA ĐƠN -->
                <div class="lg:col-span-7 space-y-6">
                    <div class="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 space-y-5">
                        <h3 class="text-base font-bold text-slate-800"><i class="fa-solid fa-tags text-emerald-500 mr-2"></i>Áp dụng ưu đãi giảm tiền</h3>

                        <!-- HIỂN THỊ VOUCHER HIỆN TẠI DẠNG MỘT BOX ĐẸP MẮT -->
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Voucher đang áp dụng</label>
                            <input type="hidden" id="selectedRedemptionId" name="redemptionId" value="0">

                            <!-- Box Preview lớn thay thế cho chuỗi text cũ -->
                            <div id="mainVoucherPreviewBox" class="border-2 border-dashed border-slate-200 bg-slate-50/50 rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 transition-all">
                                <div class="flex items-center gap-3.5">
                                    <div id="mainVoucherIconBadge" class="w-12 h-12 bg-slate-200 text-slate-500 rounded-xl flex items-center justify-center text-xl shrink-0">
                                        <i class="fa-solid fa-ticket-simple"></i>
                                    </div>
                                    <div>
                                        <div id="mainVoucherName text" class="font-bold text-slate-700 text-sm">Chưa chọn mã giảm giá</div>
                                        <div id="mainVoucherSub text" class="text-xs text-slate-400 mt-0.5">Nhấn nút bên phải để mở kho ưu đãi tích lũy</div>
                                    </div>
                                </div>
                                <button type="button" onclick="openVoucherModal()" class="w-full sm:w-auto px-4 py-2.5 bg-[#464BE5] text-white hover:bg-[#3b3ec7] text-xs font-bold rounded-xl transition shadow-sm shrink-0 flex items-center justify-center gap-1.5">
                                    <i class="fa-solid fa-folder-open"></i> Chọn Ưu Đãi
                                </button>
                            </div>
                        </div>

                        <!-- Tiêu điểm tích lũy -->
                        <div class="border-t border-slate-100 pt-4">
                            <div class="flex items-center justify-between mb-2">
                                <label class="text-xs font-bold text-slate-500 uppercase tracking-wider"><i class="fa-solid fa-coins text-amber-500 mr-1"></i>Tiêu điểm tích lũy (1P = 1đ)</label>
                                <button type="button" id="pointToggle" onclick="togglePoints()" class="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-200 transition">
                                    <span class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition translate-x-1"></span>
                                </button>
                            </div>
                            <div id="pointSliderWrap" class="hidden bg-slate-50 p-4 rounded-xl border border-slate-100">
                                <input type="range" id="pointSlider" min="0" max="<%= currentPoints%>" value="0" step="1" oninput="recalc()" class="w-full accent-[#464BE5]">
                                <div class="flex justify-between text-xs mt-2">
                                    <span class="text-slate-400 font-medium">Bạn đang có: <%= String.format("%,d", currentPoints)%> P</span>
                                    <span class="font-bold text-amber-600"><span id="pointUsedLabel">0</span> P đổi giảm −<span id="pointDiscountLabel">0</span>đ</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Chi tiết hóa đơn -->
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
                            <div class="bg-amber-50 border border-amber-100 rounded-xl px-4 py-3 mt-4 text-xs text-amber-700 flex items-center gap-2">
                                <i class="fa-solid fa-gift text-sm"></i>
                                <span>Tích lũy thêm <strong>+<%= pointsWillEarn%> P</strong> vào tài khoản sau khi hoàn thành chu trình rửa xe tại cửa hàng.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- ================= POPUP MODAL HIỂN THỊ VOUCHER DẠNG BOX GRID ================= -->
        <div id="voucherModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 items-center justify-center hidden p-4 animate-fade-in">
            <div class="bg-[#F8FAFC] rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[85vh]">

                <!-- Modal Header -->
                <div class="bg-white px-6 py-4 border-b border-slate-200 flex items-center justify-between">
                    <div>
                        <h3 class="text-base font-bold text-slate-800 flex items-center gap-2">
                            <i class="fa-solid fa-box-archive text-[#464BE5]"></i> Kho Voucher Ưu Đãi Của Bạn
                        </h3>
                        <p class="text-xs text-slate-400 mt-0.5">Chọn một ô Box ưu đãi phía dưới để áp dụng giảm trừ trực tiếp</p>
                    </div>
                    <button type="button" onclick="closeVoucherModal()" class="w-9 h-9 rounded-full bg-slate-100 text-slate-400 hover:bg-slate-200 hover:text-slate-600 flex items-center justify-center transition">
                        <i class="fa-solid fa-xmark text-lg"></i>
                    </button>
                </div>

                <!-- Vùng hiển thị Box Grid cuộn tròn mượt mà -->
                <div class="p-6 overflow-y-auto flex-1 grid grid-cols-1 sm:grid-cols-2 gap-4" id="modalBoxContainer">

                    <!-- Box mặc định: Không dùng mã -->
                    <div onclick="selectVoucherBox(this, 0, 'Không dùng voucher', 'Giữ nguyên giá gốc dịch vụ', false)"
                         class="voucher-box-item border-2 border-emerald-500 bg-emerald-50/40 rounded-2xl p-4 cursor-pointer relative flex flex-col justify-between shadow-sm border-dashed">
                        <div class="flex items-start gap-3">
                            <div class="w-10 h-10 bg-emerald-100 text-emerald-700 rounded-xl flex items-center justify-center text-lg shrink-0">
                                <i class="fa-solid fa-ban"></i>
                            </div>
                            <div>
                                <div class="font-bold text-slate-700 text-sm">Không dùng voucher</div>
                                <div class="text-[11px] text-slate-400 mt-1">Hủy bỏ áp dụng giảm trừ thẻ</div>
                            </div>
                        </div>
                        <div class="absolute top-4 right-4 check-mark-icon text-emerald-600">
                            <i class="fa-solid fa-circle-check text-lg"></i>
                        </div>
                    </div>

                    <%-- Duyệt danh sách đối tượng DTO đẩy lên từ Servlet --%>
                    <% for (RewardRedemption v : availableVouchers) {
                            String rName = (v.getRewardName() != null) ? v.getRewardName() : "Mã ưu đãi thành viên";
                    %>
                    <div onclick="selectVoucherBox(this, <%= v.getRedemptionId()%>, '<%= rName%>', 'Mã lượt đổi: #<%= v.getRedemptionId()%>', true)"
                         class="voucher-box-item border border-slate-200 hover:border-emerald-300 bg-white hover:bg-emerald-50/10 rounded-2xl p-4 cursor-pointer relative flex flex-col justify-between hover:shadow-md ticket-edge">
                        <div class="flex items-start gap-3">
                            <!-- Khối icon của từng Box mã giảm giá -->
                            <div class="w-10 h-10 bg-rose-50 text-rose-500 rounded-xl flex items-center justify-center text-lg shrink-0">
                                <i class="fa-solid fa-ticket-simple"></i>
                            </div>
                            <div>
                                <span class="inline-block bg-rose-50 text-rose-600 font-bold text-[10px] px-1.5 py-0.5 rounded mb-1.5 uppercase tracking-wide">
                                    SmartWash Code
                                </span>
                                <div class="font-bold text-slate-800 text-sm line-clamp-2 pr-4 leading-tight"><%= rName%></div>
                                <div class="text-[11px] text-slate-400 mt-2 font-mono">ID: #<%= v.getRedemptionId()%></div>
                            </div>
                        </div>
                        <!-- Checkmark ẩn, sẽ hiển thị khi được chọn thông qua JS Class -->
                        <div class="absolute top-4 right-4 check-mark-icon text-emerald-600 hidden">
                            <i class="fa-solid fa-circle-check text-lg"></i>
                        </div>
                    </div>
                    <% }%>

                </div>
            </div>
        </div>

        <script>
            const BASE_PRICE = <%= (int) draft.getTotalAmount()%>;
            const BANK_ID = "<%= bankId%>";
            const ACCOUNT_NO = "<%= accountNo%>";
            const ACCOUNT_NAME = encodeURIComponent("<%= accountName%>");
            const MEMO = "<%= paymentMemo%>";

            let usePoints = false;
            let currentFinalPrice = BASE_PRICE;
            let paymentTimer = null;
            let chosenRedemptionId = 0;
            let recalcSeq = 0;               // ← THÊM: biến đếm số lần gọi recalc()

                function openVoucherModal() {
                    const modal = document.getElementById('voucherModal');
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                }

                function closeVoucherModal() {
                    const modal = document.getElementById('voucherModal');
                    modal.classList.remove('flex');
                    modal.classList.add('hidden');
                }

                // XỬ LÝ KHI CLICK CHỌN BOX VOUCHER TRONG POPUP
                function selectVoucherBox(element, redemptionId, name, desc, isRealVoucher) {
                    // 1. Đồng bộ lại trạng thái active giữa các Box trong Modal
                    const allBoxes = document.querySelectorAll('#modalBoxContainer .voucher-box-item');
                    allBoxes.forEach(box => {
                        box.className = "voucher-box-item border border-slate-200 hover:border-emerald-300 bg-white hover:bg-emerald-50/10 rounded-2xl p-4 cursor-pointer relative flex flex-col justify-between hover:shadow-md ticket-edge";
                        const check = box.querySelector('.check-mark-icon');
                        if (check)
                            check.classList.add('hidden');
                    });

                    // Làm nổi bật Box vừa click
                    element.className = "voucher-box-item border-2 border-emerald-500 bg-emerald-50/40 rounded-2xl p-4 cursor-pointer relative flex flex-col justify-between shadow-sm ring-2 ring-emerald-500/10" + (!isRealVoucher ? " border-dashed" : " ticket-edge");
                    const currentCheck = element.querySelector('.check-mark-icon');
                    if (currentCheck)
                        currentCheck.classList.remove('hidden');

                    // 2. BIẾN ĐỔI TOÀN BỘ BOX PREVIEW TRÊN MÀN HÌNH CHÍNH (Thay đổi theo dạng Box chứ không thay chuỗi thuần)
                    const previewBox = document.getElementById('mainVoucherPreviewBox');
                    const badge = document.getElementById('mainVoucherIconBadge');

                    if (isRealVoucher) {
                        previewBox.className = "border-2 border-emerald-500 bg-emerald-50/30 rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 transition-all shadow-sm";
                        badge.className = "w-12 h-12 bg-emerald-500 text-white rounded-xl flex items-center justify-center text-xl shrink-0 shadow-sm animate-bounce-short";
                        badge.innerHTML = '<i class="fa-solid fa-gift"></i>';
                    } else {
                        previewBox.className = "border-2 border-dashed border-slate-200 bg-slate-50/50 rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 transition-all";
                        badge.className = "w-12 h-12 bg-slate-200 text-slate-500 rounded-xl flex items-center justify-center text-xl shrink-0";
                        badge.innerHTML = '<i class="fa-solid fa-ticket-simple"></i>';
                    }

                    document.getElementById('mainVoucherName text').textContent = name;
                    document.getElementById('mainVoucherSub text').textContent = desc;

                    // 3. Đẩy dữ liệu Id sang Input Hidden để gửi đi
                    chosenRedemptionId = redemptionId;
                    document.getElementById('selectedRedemptionId').value = redemptionId;

                    // 4. Kích hoạt tính toán giá từ Backend Action cũ
                    recalc();

                    // Đóng Modal mượt sau 250ms
                    setTimeout(closeVoucherModal, 250);
                }

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

                function recalc() {
                    const mySeq = ++recalcSeq;
                    const pointsUsed = usePoints ? (parseInt(document.getElementById('pointSlider').value) || 0) : 0;
                    const calcUrl = "<%= request.getContextPath()%>/MainController?action=calculatePaymentDetails&redemptionId=" + chosenRedemptionId + "&pointsUsed=" + pointsUsed;

                    fetch(calcUrl)
                            .then(response => response.json())
                            .then(data => {
                                if (mySeq !== recalcSeq)
                                    return;   // ← THÊM: có lần gọi mới hơn rồi -> bỏ qua response cũ này, không ghi đè UI
                                const voucherDiscount = data.voucherDiscount || 0;
                                const pointDiscount = data.pointDiscount || 0;
                                currentFinalPrice = data.grandTotal;
                                const maxPointsAllowed = data.maxPointsAllowed !== undefined ? data.maxPointsAllowed : <%= currentPoints%>;

                                const slider = document.getElementById('pointSlider');
                                slider.max = maxPointsAllowed;
                                if (parseInt(slider.value) > maxPointsAllowed) {
                                    slider.value = maxPointsAllowed;
                                }

                                document.getElementById('voucherDiscount').textContent = voucherDiscount.toLocaleString('vi-VN');
                                document.getElementById('pointDiscount').textContent = pointDiscount.toLocaleString('vi-VN');
                                document.getElementById('pointUsedLabel').textContent = usePoints ? slider.value : 0;
                                document.getElementById('pointDiscountLabel').textContent = pointDiscount.toLocaleString('vi-VN');
                                document.getElementById('grandTotal').textContent = currentFinalPrice.toLocaleString('vi-VN') + 'đ';

                                document.getElementById('rowVoucher').classList.toggle('hidden', voucherDiscount === 0);
                                document.getElementById('rowPoint').classList.toggle('hidden', pointDiscount === 0);

                                updateQRCode(currentFinalPrice);
                                startPaymentChecking(currentFinalPrice);
                            })
                            .catch(error => console.error("Lỗi đồng bộ hệ thống:", error));
                }

                function updateQRCode(amount) {
                    const overlay = document.getElementById('qrLoadingOverlay');
                    if (overlay)
                        overlay.classList.remove('hidden');

                    const cleanAmount = Math.floor(amount);
                    const newQRUrl = "https://img.vietqr.io/image/" + BANK_ID + "-" + ACCOUNT_NO + "-compact2.png?amount=" + cleanAmount + "&addInfo=" + MEMO + "&accountName=" + ACCOUNT_NAME;

                    const imgElement = document.getElementById('realQRCodeImg');
                    imgElement.src = newQRUrl;
                    imgElement.onload = function () {
                        if (overlay)
                            overlay.classList.add('hidden');
                    };
                    imgElement.onerror = function () {
                        if (overlay)
                            overlay.classList.add('hidden');
                        console.error('Không tải được mã QR.');
                    };
                }

                function startPaymentChecking(amountToCheck) {
                    if (paymentTimer) {
                        clearInterval(paymentTimer);
                    }

                    paymentTimer = setInterval(function () {
                        const currentPointsUsed = usePoints ? (parseInt(document.getElementById('pointSlider').value) || 0) : 0;
                        const checkUrl = "<%= request.getContextPath()%>/MainController?action=checkRealPaymentStatus&memo=" + MEMO + "&redemptionId=" + chosenRedemptionId + "&pointsUsed=" + currentPointsUsed;

                        fetch(checkUrl)
                                .then(response => response.json())
                                .then(data => {
                                    if (data.status === "SUCCESS") {
                                        clearInterval(paymentTimer);
                                        document.getElementById('paymentStatusBox').className = "w-full flex items-center justify-center gap-3 bg-emerald-50 text-emerald-600 py-3.5 px-4 rounded-xl font-semibold text-sm mt-6 border border-emerald-100";
                                        document.getElementById('statusIcon').className = "fa-solid fa-circle-check text-lg text-emerald-500";
                                        document.getElementById('statusText').innerText = "Thanh toán thành công! Đang xử lý tạo lịch hẹn...";

                                        setTimeout(() => {
                                            window.location.href = "<%= request.getContextPath()%>/MainController?action=executeInsertBooking&redemptionId=" + chosenRedemptionId + "&pointsUsed=" + currentPointsUsed + "&finalPrice=" + amountToCheck;
                                        }, 1800);
                                    }
                                })
                                .catch(error => console.error("Lỗi kiểm tra:", error));
                    }, 3000);
                }

                window.onload = function () {
                    recalc();
                }
                ;
        </script>
    </body>
</html>