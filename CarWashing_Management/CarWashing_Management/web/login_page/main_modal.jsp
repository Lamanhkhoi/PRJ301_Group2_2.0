<%-- 
    Document   : login_modal.jsp
    Created on : May 28, 2026, 5:27:48 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

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

    const serverError = "${requestScope.errorMessage}";
    if (serverError && serverError.trim() !== "") {
        openAuthModal();
        const errorDiv = document.getElementById('loginErrorMsg');
        errorDiv.innerText = serverError;
        errorDiv.classList.remove('hidden');
    }
</script>
