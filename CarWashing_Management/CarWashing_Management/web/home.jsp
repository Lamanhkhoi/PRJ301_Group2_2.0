<%-- 
    Document   : home
    Created on : May 28, 2026
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SmartWash - Rửa Xe Công Nghệ</title>

        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@700&family=Inter:wght@400;500&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/CSS/style.css">

        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            h1, h2, .font-heading {
                font-family: 'Montserrat', sans-serif;
            }
            .bg-primary {
                background-color: #464BE5;
            }
        </style>
    </head>
    <body class="bg-[#F4F7F6] text-[#111827]">

        <jsp:include page="includes/header.jsp" />

        <section class="relative flex items-center px-10 py-20 min-h-[80vh] overflow-hidden">
            <div class="absolute inset-0 z-0">
                <img src="<%=request.getContextPath()%>/image/background_CarWash.avif" class="w-full h-full object-cover" />
                <div class="absolute inset-0 bg-gradient-to-r from-[#111827] via-[#111827]/80 to-transparent"></div>
            </div>

            <div class="relative z-10 max-w-2xl text-white">
                <h1 class="text-5xl leading-tight mb-4 uppercase">
                    Rửa xe tự động <br> 
                    <span class="text-[#10B981]">thông minh</span> bằng AI
                </h1>
                <p class="text-lg text-gray-300 mb-8">
                    Sạch sâu, nhanh chóng, hoàn toàn tự động. Trải nghiệm dịch vụ chăm sóc xe hơi kỷ nguyên mới, tiết kiệm thời gian tối đa cho bạn.
                </p>
                <div class="flex gap-4">
                    <button onclick="openAuthModal('login')" class="px-8 py-3 bg-primary hover:bg-blue-700 text-white font-semibold rounded-lg shadow-lg transition duration-300">
                        Đặt lịch ngay
                    </button>
                    <a href="#quy-trinh" class="px-8 py-3 border border-white hover:bg-white hover:text-[#111827] text-white font-semibold rounded-lg transition duration-300">
                        Xem quy trình
                    </a>
                </div>
            </div>
        </section>

        <section class="py-20 bg-[#F4F7F6]">
            <div class="max-w-5xl mx-auto px-10 reveal">
                <div class="bg-white p-12 rounded-2xl shadow-xl text-center border-t-4 border-[#464BE5]">
                    <h2 class="text-3xl font-heading text-[#111827] mb-6">Chúng Tôi Là Ai?</h2>
                    <p class="text-lg text-[#9CA3AF] leading-relaxed max-w-3xl mx-auto">
                        SmartWash ra đời với sứ mệnh tái định nghĩa lại ngành dịch vụ chăm sóc xe hơi. 
                        Chúng tôi không chỉ rửa xe, chúng tôi ứng dụng công nghệ AI tự động hóa 100% 
                        để mang đến sự sạch sẽ hoàn hảo, bảo vệ lớp sơn tối đa và tiết kiệm từng phút giây quý giá của bạn.
                    </p>
                </div>
            </div>
        </section>

        <section class="py-20 bg-white" id="quy-trinh">
            <div class="max-w-6xl mx-auto px-10">
                <div class="text-center mb-16 reveal">
                    <h2 class="text-4xl font-heading text-[#111827]">Quy Trình Làm Sạch Tự Động</h2>
                    <p class="text-[#9CA3AF] mt-4 text-lg">3 bước siêu tốc cho chiếc xe bóng loáng</p>
                </div>

                <div class="flex flex-col gap-8">
                    <div class="flex items-center gap-8 bg-[#F4F7F6] p-8 rounded-xl reveal">
                        <div class="text-6xl font-heading text-[#464BE5] opacity-30">01</div>
                        <div>
                            <h3 class="text-2xl font-bold text-[#111827] mb-2">Quét Laser & Xịt Gầm Áp Lực Cao</h3>
                            <p class="text-[#9CA3AF]">Hệ thống AI quét form xe để điều chỉnh áp lực nước, đánh bay bùn đất phần gầm và bánh xe một cách an toàn nhất.</p>
                        </div>
                    </div>

                    <div class="flex items-center gap-8 bg-[#111827] text-white p-8 rounded-xl reveal">
                        <div class="text-6xl font-heading text-[#10B981] opacity-50">02</div>
                        <div>
                            <h3 class="text-2xl font-bold mb-2">Phủ Bọt Tuyết Nano & Chổi Mềm Cảm Biến</h3>
                            <p class="text-gray-400">Bọt tuyết độc quyền kết hợp hệ thống chổi mút EVA chạm nhẹ nhàng, làm sạch sâu mà không gây xước dăm.</p>
                        </div>
                    </div>

                    <div class="flex items-center gap-8 bg-[#F4F7F6] p-8 rounded-xl reveal">
                        <div class="text-6xl font-heading text-[#464BE5] opacity-30">03</div>
                        <div>
                            <h3 class="text-2xl font-bold text-[#111827] mb-2">Phủ Wax Bóng & Sấy Khô Đa Chiều</h3>
                            <p class="text-[#9CA3AF]">Lớp sáp bảo vệ được xịt đều trước khi hệ thống quạt gió công suất lớn sấy khô toàn bộ thân xe trong 60 giây.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="py-20 bg-[#111827]" id="uu-dai">
            <div class="max-w-6xl mx-auto px-10">
                <div class="text-center mb-16 reveal">
                    <h2 class="text-4xl font-heading text-white">Đặc Quyền Thành Viên</h2>
                    <p class="text-gray-400 mt-4 text-lg">Nâng hạng để nhận ưu đãi rửa xe không giới hạn</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    <div class="bg-white p-8 rounded-2xl shadow-lg text-center reveal">
                        <h3 class="text-xl font-bold text-[#9CA3AF] mb-4">MEMBER BẠC</h3>
                        <div class="text-4xl font-heading text-[#111827] mb-6">Giảm 10%</div>
                        <ul class="text-left text-[#9CA3AF] space-y-3 mb-8">
                            <li>✓ Tích điểm mỗi lần rửa</li>
                            <li>✓ Miễn phí hút bụi</li>
                            <li>✗ Ưu tiên đặt lịch</li>
                        </ul>
                        <button class="w-full py-3 border-2 border-[#111827] text-[#111827] font-bold rounded-lg hover:bg-[#111827] hover:text-white transition">Đăng Ký Ngay</button>
                    </div>

                    <div class="bg-gradient-to-b from-[#464BE5] to-blue-800 p-8 rounded-2xl shadow-2xl text-center transform scale-105 border-2 border-[#10B981] reveal">
                        <h3 class="text-xl font-bold text-[#10B981] mb-4">MEMBER VÀNG</h3>
                        <div class="text-4xl font-heading text-white mb-6">Giảm 25%</div>
                        <ul class="text-left text-gray-200 space-y-3 mb-8">
                            <li>✓ Tích điểm x2</li>
                            <li>✓ Miễn phí hút bụi & khử mùi</li>
                            <li>✓ Ưu tiên đặt lịch không xếp hàng</li>
                        </ul>
                        <button class="w-full py-3 bg-[#10B981] text-white font-bold rounded-lg hover:bg-green-600 transition">Nâng Hạng Vàng</button>
                    </div>

                    <div class="bg-white p-8 rounded-2xl shadow-lg text-center reveal">
                        <h3 class="text-xl font-bold text-[#111827] mb-4">MEMBER KIM CƯƠNG</h3>
                        <div class="text-4xl font-heading text-[#111827] mb-6">Miễn Phí</div>
                        <ul class="text-left text-[#9CA3AF] space-y-3 mb-8">
                            <li>✓ Rửa xe 1 lần/tháng miễn phí</li>
                            <li>✓ Full dịch vụ chăm sóc VIP</li>
                            <li>✓ Phòng chờ máy lạnh, cafe</li>
                        </ul>
                        <button class="w-full py-3 border-2 border-[#111827] text-[#111827] font-bold rounded-lg hover:bg-[#111827] hover:text-white transition">Trở Thành VIP</button>
                    </div>
                </div>
            </div>
        </section>

        <jsp:include page="includes/footer.jsp" />

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('active');
                        }
                    });
                }, {threshold: 0.15});

                const revealElements = document.querySelectorAll('.reveal');
                revealElements.forEach((el) => observer.observe(el));
            });
        </script>
    </body>
    <div id="authModal" class="fixed inset-0 z-[100] hidden flex items-center justify-center bg-[#111827]/80 backdrop-blur-sm transition-all duration-300 opacity-0">

        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md mx-4 relative overflow-hidden transform scale-95 transition-transform duration-300" id="authModalContent">

            <button onclick="closeAuthModal()" class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition z-50">
                <i class="fa-solid fa-xmark text-xl"></i>
            </button>

            <div id="loginView">
                <jsp:include page="login_page/login_view.jsp" />
            </div>

            <div id="registerView" class="hidden">
                <jsp:include page="login_page/register_view.jsp" />
            </div>

        </div>
    </div>

    <script>
        const authModal = document.getElementById('authModal');
        const authContent = document.getElementById('authModalContent');
        const loginView = document.getElementById('loginView');
        const registerView = document.getElementById('registerView');

        // Hàm mở Pop-up
        function openAuthModal(viewType) {
            authModal.classList.remove('hidden');
            setTimeout(() => {
                authModal.classList.remove('opacity-0');
                authContent.classList.remove('scale-95');
                authContent.classList.add('scale-100');
            }, 10);

            toggleAuthView(viewType); // Chọn form muốn hiện (login hoặc register)
        }

        // Hàm đóng Pop-up
        function closeAuthModal() {
            authModal.classList.add('opacity-0');
            authContent.classList.remove('scale-100');
            authContent.classList.add('scale-95');
            setTimeout(() => {
                authModal.classList.add('hidden');
            }, 300);
        }

        // Hàm chuyển đổi qua lại giữa Đăng nhập và Đăng ký
        function toggleAuthView(viewType) {
            if (viewType === 'login') {
                loginView.classList.remove('hidden');
                registerView.classList.add('hidden');
            } else if (viewType === 'register') {
                loginView.classList.add('hidden');
                registerView.classList.remove('hidden');
            }
        }

        // Bấm ra vùng nền đen bên ngoài cũng sẽ tự đóng Modal
        authModal.addEventListener('click', function (event) {
            if (event.target === authModal) {
                closeAuthModal();
            }
        });
    </script>
</html>