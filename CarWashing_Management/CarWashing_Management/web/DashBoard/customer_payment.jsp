<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: THANH TOÁN (Customer) - customer_payment.jsp
    Trang ẩn (KHÔNG có mục sidebar). Hiện ra khi bấm "Hoàn tất Đặt lịch" ở step 4 của customer_booking.jsp.
    Full màn hình, không sidebar để khách tập trung trả tiền.

    *** LƯU Ý QUAN TRỌNG VỀ LUỒNG (đọc kỹ trước khi làm backend) ***
    Đây là BƯỚC CUỐI. Booking CHỈ được tạo SAU KHI thanh toán thành công.
    -> customer_booking.jsp KHÔNG được INSERT booking. Nó chỉ gom dữ liệu đặt lịch
       (vehicleId, serviceId, ngày, slot...) và chuyển sang trang này (qua session hoặc hidden field).
    -> Nếu khách thoát giữa chừng / mất mạng / đóng tab ở trang này => KHÔNG tạo booking (tránh lịch ảo).
    -> Chỉ khi Controller nhận được "xác nhận thanh toán thành công" mới:
          1) Trừ điểm (nếu khách dùng điểm)  2) Đánh dấu voucher đã dùng
          3) INSERT booking (status = CONFIRMED)  4) Cộng điểm thưởng (hoặc để lúc rửa xong)
       -> Nên bọc toàn bộ trong 1 TRANSACTION: lỗi bất kỳ bước nào thì rollback hết.

    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include auth-check bên dưới khi gắn Controller.
      2. Thay MOCK DATA bằng dữ liệu đặt lịch thật lấy từ session (do step 4 gửi sang).
      3. availableVouchers -> danh sách voucher AVAILABLE của khách.
      4. Nút "Xác nhận thanh toán" trong modal -> submit form POST tới
         MainController?action=processPayment (chính nơi tạo booking theo transaction ở trên).
    ============================================================
--%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    // Thông tin đơn (step 4 của booking gửi sang qua session)
    String orderPlate = "51G-123.45";       // booking vehicle
    String orderService = "Express Rinse";  // washService.getServiceName()
    String orderTime = "07/07/2026 · 08:00 - 08:30";
    int basePrice = 40000;                   // washService.getPrice()

    int currentPoints = 1250;                // loyalty.getCurrentPoints()
    int pointRate = 1000;                    // SystemConfig: 1 P = 1.000đ
    // Điểm sẽ cộng khi rửa xong (giá gốc / pointRate, có thể nhân bonus theo hạng ở backend)
    int pointsWillEarn = basePrice / pointRate;

    // Voucher AVAILABLE của khách: {mã, tên, số tiền giảm}
    String[][] availableVouchers = {
        {"SW-8F3K2", "Phiếu mua hàng 20.000 VNĐ", "20000"},
        {"SW-2QW9Z", "Miễn phí wax xe (giảm 30.000đ)", "30000"}
    };
    // ====================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thanh Toán - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-[#F8FAFC] text-slate-800 min-h-screen flex flex-col">

        <%-- ===== HEADER GỌN (không sidebar) ===== --%>
        <header class="bg-[#0F172A] text-white">
            <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
                <div class="flex items-center gap-2.5 font-bold">
                    <i class="fa-solid fa-car-side text-emerald-400"></i> SmartWash <span class="text-slate-500 font-normal">·</span> <span class="font-medium">Thanh toán</span>
                </div>
                <div class="text-xs text-slate-400 flex items-center gap-2">
                    <i class="fa-solid fa-lock text-emerald-400"></i> Giao dịch bảo mật · Nguyễn Văn A
                </div>
            </div>
        </header>

        <main class="flex-1 max-w-6xl w-full mx-auto px-6 py-8">

            <a href="<%=request.getContextPath()%>/MainController?action=customerBookingPage" class="inline-flex items-center gap-2 text-sm text-slate-400 hover:text-emerald-600 transition mb-6">
                <i class="fa-solid fa-arrow-left"></i> Quay lại xác nhận đặt lịch
            </a>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <%-- ============ CỘT TRÁI: THAO TÁC ============ --%>
                <div class="lg:col-span-2 space-y-8">

                    <%-- ===== PHƯƠNG THỨC THANH TOÁN (thẻ radio kiểu ZZZ) ===== --%>
                    <section>
                        <h2 class="text-lg font-bold text-slate-800 mb-4"><i class="fa-solid fa-wallet text-emerald-500 mr-2"></i>Phương thức thanh toán</h2>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4" id="methodGrid">
                            <%-- Option 1 (chọn sẵn) --%>
                            <label class="pay-method relative cursor-pointer">
                                <input type="radio" name="payMethod" value="VIETQR" class="peer sr-only" checked>
                                <div class="flex items-center justify-between rounded-2xl border-2 border-slate-200 bg-white px-5 py-4 transition peer-checked:border-emerald-500 peer-checked:bg-emerald-50">
                                    <span class="flex items-center gap-3 font-bold text-slate-700">
                                        <i class="fa-regular fa-circle-check text-xl text-slate-300 peer-checked:text-emerald-500 method-check"></i>
                                        Chuyển khoản / VietQR
                                    </span>
                                    <span class="w-10 h-10 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center"><i class="fa-solid fa-qrcode"></i></span>
                                </div>
                            </label>
                            <%-- Option 2 --%>
                            <label class="pay-method relative cursor-pointer">
                                <input type="radio" name="payMethod" value="ATM" class="peer sr-only">
                                <div class="flex items-center justify-between rounded-2xl border-2 border-slate-200 bg-white px-5 py-4 transition peer-checked:border-emerald-500 peer-checked:bg-emerald-50">
                                    <span class="flex items-center gap-3 font-bold text-slate-700">
                                        <i class="fa-regular fa-circle-check text-xl text-slate-300 peer-checked:text-emerald-500 method-check"></i>
                                        Thẻ ATM nội địa
                                    </span>
                                    <span class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-credit-card"></i></span>
                                </div>
                            </label>
                        </div>
                        <p class="text-xs text-slate-400 mt-3"><i class="fa-solid fa-circle-info mr-1"></i> Bản demo: chọn phương thức rồi bấm thanh toán để hoàn tất. Cổng thanh toán thật (quét QR/nhập thẻ) sẽ bổ sung sau.</p>
                    </section>

                    <%-- ===== ƯU ĐÃI: VOUCHER + ĐIỂM ===== --%>
                    <section>
                        <h2 class="text-lg font-bold text-slate-800 mb-4"><i class="fa-solid fa-tags text-emerald-500 mr-2"></i>Ưu đãi &amp; điểm thưởng</h2>

                        <%-- Chọn voucher --%>
                        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 mb-4">
                            <label class="block text-sm font-bold text-slate-600 mb-2"><i class="fa-solid fa-ticket text-emerald-500 mr-1.5"></i>Voucher đã đổi</label>
                            <select id="voucherSelect" onchange="recalc()" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/30 focus:border-emerald-400 transition">
                                <option value="0">Không dùng voucher</option>
                                <% for (String[] v : availableVouchers) { %>
                                <option value="<%= v[2] %>"><%= v[1] %> (−<%= String.format("%,d", Integer.parseInt(v[2])) %>đ)</option>
                                <% } %>
                            </select>
                        </div>

                        <%-- Dùng điểm --%>
                        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
                            <div class="flex items-center justify-between mb-3">
                                <label class="text-sm font-bold text-slate-600"><i class="fa-solid fa-coins text-amber-500 mr-1.5"></i>Dùng điểm (1 P = <%= String.format("%,d", pointRate) %>đ)</label>
                                <%-- Công tắc bật/tắt dùng điểm --%>
                                <button type="button" id="pointToggle" onclick="togglePoints()" class="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-300 transition">
                                    <span class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition translate-x-1"></span>
                                </button>
                            </div>
                            <div id="pointSliderWrap" class="hidden">
                                <input type="range" id="pointSlider" min="0" max="0" value="0" step="1" oninput="recalc()"
                                       class="w-full accent-emerald-500">
                                <div class="flex justify-between text-xs mt-2">
                                    <span class="text-slate-400">Đang có <%= String.format("%,d", currentPoints) %> P</span>
                                    <span class="font-bold text-amber-600"><span id="pointUsedLabel">0</span> P → −<span id="pointDiscountLabel">0</span>đ</span>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>

                <%-- ============ CỘT PHẢI: TÓM TẮT ĐƠN ============ --%>
                <aside class="lg:col-span-1">
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sticky top-8">
                        <h2 class="text-base font-bold text-slate-800 mb-4">Tóm tắt đơn</h2>

                        <div class="space-y-3 text-sm">
                            <div class="flex justify-between"><span class="text-slate-500">Xe</span><span class="font-bold text-slate-700"><%= orderPlate %></span></div>
                            <div class="flex justify-between"><span class="text-slate-500">Dịch vụ</span><span class="font-bold text-slate-700"><%= orderService %></span></div>
                            <div class="flex justify-between"><span class="text-slate-500">Thời gian</span><span class="font-bold text-slate-700 text-right"><%= orderTime %></span></div>
                        </div>

                        <div class="border-t border-slate-100 my-4"></div>

                        <div class="space-y-2.5 text-sm">
                            <div class="flex justify-between"><span class="text-slate-500">Giá gốc</span><span class="font-medium text-slate-700"><%= String.format("%,d", basePrice) %>đ</span></div>
                            <div class="flex justify-between text-emerald-600" id="rowVoucher"><span>Voucher</span><span>−<span id="voucherDiscount">0</span>đ</span></div>
                            <div class="flex justify-between text-amber-600" id="rowPoint"><span>Điểm thưởng</span><span>−<span id="pointDiscount">0</span>đ</span></div>
                        </div>

                        <div class="border-t border-slate-200 my-4"></div>

                        <div class="flex items-baseline justify-between">
                            <span class="text-sm font-bold text-slate-700">Tổng thanh toán</span>
                            <span class="text-2xl font-black text-[#464BE5]" id="grandTotal"><%= String.format("%,d", basePrice) %>đ</span>
                        </div>

                        <div class="bg-amber-50 border border-amber-100 rounded-xl px-4 py-3 mt-4 text-xs text-amber-700 flex items-center gap-2">
                            <i class="fa-solid fa-gift"></i> <span>+<%= pointsWillEarn %> P sẽ được cộng sau khi rửa xe hoàn tất</span>
                        </div>

                        <button onclick="openConfirm()" class="w-full mt-5 bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3.5 rounded-xl transition shadow-md shadow-emerald-500/30 flex items-center justify-center gap-2">
                            <i class="fa-solid fa-lock"></i> Thanh toán <span id="btnTotal"><%= String.format("%,d", basePrice) %>đ</span>
                        </button>
                        <p class="text-[11px] text-slate-400 text-center mt-3">Lịch đặt xe chỉ được tạo sau khi thanh toán thành công.</p>
                    </div>
                </aside>
            </div>
        </main>

        <%-- ===== MODAL XÁC NHẬN THANH TOÁN ===== --%>
        <div id="confirmModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
            <div id="confirmContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                <div class="p-8 text-center">
                    <div class="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
                        <i class="fa-solid fa-shield-halved text-2xl text-emerald-500"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-800">Xác nhận thanh toán</h3>
                    <p class="text-sm text-slate-500 mt-2">Bạn sắp thanh toán <span id="confirmAmount" class="font-bold text-[#464BE5]"></span> bằng <span id="confirmMethod" class="font-bold text-slate-700"></span>.</p>
                    <p class="text-xs text-slate-400 mt-2">Sau khi thanh toán thành công, lịch đặt xe của bạn mới được tạo.</p>
                </div>
                <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                    <button onclick="closeConfirm()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                    <%-- TODO BACKEND: đổi thành submit form POST tới action=processPayment (tạo booking theo transaction) --%>
                    <button onclick="fakePay()" class="flex-1 px-4 py-2.5 rounded-xl bg-emerald-500 text-white font-bold hover:bg-emerald-600 transition">Xác nhận thanh toán</button>
                </div>
            </div>
        </div>

        <%-- ===== MODAL ĐANG XỬ LÝ + THÀNH CÔNG ===== --%>
        <div id="successModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
            <div id="successContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                <%-- Trạng thái đang xử lý --%>
                <div id="processingState" class="p-10 text-center">
                    <i class="fa-solid fa-spinner fa-spin text-4xl text-emerald-500 mb-4"></i>
                    <p class="text-slate-600 font-medium">Đang xử lý thanh toán...</p>
                </div>
                <%-- Trạng thái thành công --%>
                <div id="successState" class="hidden">
                    <div class="p-8 text-center">
                        <div class="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
                            <i class="fa-solid fa-check text-3xl text-emerald-500"></i>
                        </div>
                        <h3 class="text-lg font-bold text-slate-800">Thanh toán thành công!</h3>
                        <p class="text-sm text-slate-500 mt-2">Lịch đặt xe của bạn đã được tạo.</p>
                        <div class="bg-slate-50 rounded-xl p-4 mt-5 text-sm space-y-2 text-left">
                            <div class="flex justify-between"><span class="text-slate-500">Mã đặt lịch</span><span class="font-mono font-bold text-slate-700">#SW260707</span></div>
                            <div class="flex justify-between"><span class="text-slate-500">Dịch vụ</span><span class="font-bold text-slate-700"><%= orderService %></span></div>
                            <div class="flex justify-between"><span class="text-slate-500">Thời gian</span><span class="font-bold text-slate-700"><%= orderTime %></span></div>
                        </div>
                    </div>
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100">
                        <%-- Về đúng trang Đặt Lịch ban đầu --%>
                        <a href="<%=request.getContextPath()%>/MainController?action=customerBookingPage"
                           class="block w-full text-center px-4 py-3 rounded-xl bg-emerald-500 text-white font-bold hover:bg-emerald-600 transition">
                            Về trang Đặt Lịch
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // ================= CẤU HÌNH TỪ SERVER =================
            const BASE_PRICE = <%= basePrice %>;
            const CURRENT_POINTS = <%= currentPoints %>;
            const POINT_RATE = <%= pointRate %>;

            const fmt = n => n.toLocaleString('vi-VN') + 'đ';

            // ================= HIGHLIGHT THẺ PHƯƠNG THỨC (peer-checked của Tailwind CDN không đổi màu icon con nên xử lý tay) =================
            const methodInputs = document.querySelectorAll('input[name="payMethod"]');
            function refreshMethodUI() {
                document.querySelectorAll('.pay-method').forEach(m => {
                    const checked = m.querySelector('input').checked;
                    const box = m.querySelector('div');
                    const check = m.querySelector('.method-check');
                    box.classList.toggle('border-emerald-500', checked);
                    box.classList.toggle('bg-emerald-50', checked);
                    box.classList.toggle('border-slate-200', !checked);
                    check.classList.toggle('text-emerald-500', checked);
                    check.classList.toggle('text-slate-300', !checked);
                    check.classList.toggle('fa-circle-check', true);
                });
            }
            methodInputs.forEach(i => i.addEventListener('change', refreshMethodUI));
            refreshMethodUI();

            // ================= DÙNG ĐIỂM: bật/tắt + giới hạn thanh kéo =================
            let usePoints = false;
            function togglePoints() {
                usePoints = !usePoints;
                const toggle = document.getElementById('pointToggle');
                const knob = toggle.querySelector('span');
                toggle.classList.toggle('bg-emerald-500', usePoints);
                toggle.classList.toggle('bg-slate-300', !usePoints);
                knob.classList.toggle('translate-x-6', usePoints);
                knob.classList.toggle('translate-x-1', !usePoints);
                document.getElementById('pointSliderWrap').classList.toggle('hidden', !usePoints);
                if (!usePoints) document.getElementById('pointSlider').value = 0;
                recalc();
            }

            // ================= TÍNH LẠI TỔNG TIỀN =================
            function recalc() {
                const voucherDiscount = parseInt(document.getElementById('voucherSelect').value) || 0;
                // Số điểm tối đa được dùng = phần còn lại sau khi trừ voucher, và không vượt quá điểm đang có
                const remainAfterVoucher = Math.max(0, BASE_PRICE - voucherDiscount);
                const maxPointsByMoney = Math.floor(remainAfterVoucher / POINT_RATE);
                const maxPoints = Math.min(CURRENT_POINTS, maxPointsByMoney);

                const slider = document.getElementById('pointSlider');
                slider.max = maxPoints;
                if (parseInt(slider.value) > maxPoints) slider.value = maxPoints;

                const pointsUsed = usePoints ? parseInt(slider.value) : 0;
                const pointDiscount = pointsUsed * POINT_RATE;

                const total = Math.max(0, BASE_PRICE - voucherDiscount - pointDiscount);

                // Cập nhật giao diện
                document.getElementById('voucherDiscount').textContent = voucherDiscount.toLocaleString('vi-VN');
                document.getElementById('pointDiscount').textContent = pointDiscount.toLocaleString('vi-VN');
                document.getElementById('pointUsedLabel').textContent = pointsUsed;
                document.getElementById('pointDiscountLabel').textContent = pointDiscount.toLocaleString('vi-VN');
                document.getElementById('grandTotal').textContent = fmt(total);
                document.getElementById('btnTotal').textContent = fmt(total);

                // Ẩn dòng giảm giá khi = 0 cho gọn
                document.getElementById('rowVoucher').style.display = voucherDiscount > 0 ? '' : 'none';
                document.getElementById('rowPoint').style.display = pointDiscount > 0 ? '' : 'none';
            }
            recalc();

            // ================= MODAL XÁC NHẬN =================
            const cModal = document.getElementById('confirmModal');
            const cContent = document.getElementById('confirmContent');
            function openConfirm() {
                document.getElementById('confirmAmount').textContent = document.getElementById('btnTotal').textContent;
                const method = document.querySelector('input[name="payMethod"]:checked').value;
                document.getElementById('confirmMethod').textContent = method === 'VIETQR' ? 'Chuyển khoản / VietQR' : 'Thẻ ATM nội địa';
                cModal.classList.remove('hidden');
                setTimeout(() => { cModal.classList.remove('opacity-0'); cContent.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closeConfirm() {
                cModal.classList.add('opacity-0');
                cContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => cModal.classList.add('hidden'), 300);
            }
            cModal.addEventListener('click', e => { if (e.target === cModal) closeConfirm(); });

            // ================= GIẢ LẬP THANH TOÁN =================
            // Demo UI: đóng modal xác nhận -> hiện "đang xử lý" -> "thành công".
            // Backend thật: nút "Xác nhận thanh toán" submit form, Controller tạo booking theo transaction
            // rồi forward sang trang/khối thành công này.
            const sModal = document.getElementById('successModal');
            const sContent = document.getElementById('successContent');
            function fakePay() {
                closeConfirm();
                sModal.classList.remove('hidden');
                setTimeout(() => { sModal.classList.remove('opacity-0'); sContent.classList.replace('scale-95', 'scale-100'); }, 10);
                document.getElementById('processingState').classList.remove('hidden');
                document.getElementById('successState').classList.add('hidden');
                setTimeout(() => {
                    document.getElementById('processingState').classList.add('hidden');
                    document.getElementById('successState').classList.remove('hidden');
                }, 1600);
            }
        </script>
    </body>
</html>
