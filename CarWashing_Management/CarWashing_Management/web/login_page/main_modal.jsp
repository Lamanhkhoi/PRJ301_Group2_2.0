<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (request.getAttribute("javax.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }
%>

<div id="authModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-[#111827]/60 backdrop-blur-md transition-all duration-300 opacity-0">
    <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md mx-4 relative overflow-hidden transform scale-95 transition-transform duration-300" id="modalContent">

        <button onclick="closeAuthModal()" class="absolute top-4 right-4 text-gray-400 hover:text-gray-800 transition z-10">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>

        <div id="loginView" class="transition-all duration-500">
            <jsp:include page="login_view.jsp" />
        </div>

        <div id="registerView" class="hidden transition-all duration-500">
            <jsp:include page="register_view.jsp" />
        </div>

    </div>
</div>

<script>
    const authModal = document.getElementById('authModal');
    const modalContent = document.getElementById('modalContent');
    const loginView = document.getElementById('loginView');
    const registerView = document.getElementById('registerView');

    function openAuthModal() {
        authModal.classList.remove('hidden');
        setTimeout(() => {
            authModal.classList.remove('opacity-0');
            modalContent.classList.remove('scale-95');
            modalContent.classList.add('scale-100');
        }, 10);
    }

    function closeAuthModal() {
        authModal.classList.add('opacity-0');
        modalContent.classList.remove('scale-100');
        modalContent.classList.add('scale-95');
        setTimeout(() => {
            authModal.classList.add('hidden');
            toggleAuthView('login');
        }, 300);
    }

    function toggleAuthView(viewName) {
        if (viewName === 'register') {
            loginView.classList.add('hidden');
            registerView.classList.remove('hidden');
        } else {
            registerView.classList.add('hidden');
            loginView.classList.remove('hidden');
        }
    }

    // Xử lý hiển thị thông báo lỗi tự động khi Load trang
    window.addEventListener("load", function () {
        const serverError = "${requestScope.errorMessage}";
        const showRegister = "${requestScope.SHOW_REGISTER}";

        if (serverError && serverError.trim() !== "") {
            openAuthModal();
            
            if (showRegister === "true") {
                // Nếu lỗi từ việc Đăng ký
                toggleAuthView('register');
                const regErrorDiv = document.getElementById('registerErrorMsg');
                if (regErrorDiv) {
                    regErrorDiv.innerText = serverError;
                    regErrorDiv.classList.remove('hidden');
                }
            } else {
                // Nếu lỗi từ việc Đăng nhập
                toggleAuthView('login');
                const loginErrorDiv = document.getElementById('loginErrorMsg');
                if (loginErrorDiv) {
                    loginErrorDiv.innerText = serverError;
                    loginErrorDiv.classList.remove('hidden');
                }
            }
        }
    });
</script>