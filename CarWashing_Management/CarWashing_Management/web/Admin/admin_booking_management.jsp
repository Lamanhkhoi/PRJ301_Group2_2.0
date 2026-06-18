<%@ include file="../includes/admin-auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.text.DecimalFormat"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Đơn Đặt Lịch - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                background-color: #F8FAFC;
            }
            .custom-scrollbar::-webkit-scrollbar {
                width: 6px;
                height: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-track {
                background: #F1F5F9;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #CBD5E1;
                border-radius: 4px;
            }
        </style>
    </head>
    <body class="text-slate-800 relative">

        <%            
            Map<Integer, List<Map<String, Object>>> slotMap = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("SLOT_MAP");

            // Định dạng tiền tệ VND bằng Java
            DecimalFormat df = new DecimalFormat("###,###,###");

            // Các biến đếm KPI
            int totalCount = request.getAttribute("TOTAL_COUNT") != null ? (Integer) request.getAttribute("TOTAL_COUNT") : 0;
            int pendingCount = request.getAttribute("PENDING_COUNT") != null ? (Integer) request.getAttribute("PENDING_COUNT") : 0;
            int checkedInCount = request.getAttribute("CHECKEDIN_COUNT") != null ? (Integer) request.getAttribute("CHECKEDIN_COUNT") : 0;
            int completedCount = request.getAttribute("COMPLETED_COUNT") != null ? (Integer) request.getAttribute("COMPLETED_COUNT") : 0;

            // Xử lý chuỗi ngày mặc định
            String searchLicensePlate = request.getParameter("searchLicensePlate") != null ? request.getParameter("searchLicensePlate") : "";
            String bookingDate = request.getParameter("bookingDate") != null ? request.getParameter("bookingDate") : (String) request.getAttribute("CURRENT_DATE_STR");
        %>

        <div class="flex h-screen overflow-hidden relative">

            <% request.setAttribute("ACTIVE_ADMIN", "quanly_datlich");%>
            <jsp:include page="/includes/sidebar_admin.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8 custom-scrollbar">
                    <div class="max-w-7xl mx-auto space-y-6">

                        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-900 tracking-tight">Bảng Điều Phối Lịch Rửa Xe</h1>
                                <p class="text-slate-500 text-sm mt-1">Giám sát và cập nhật trạng thái vận hành của 28 ca bằng mã nguồn Java Java.</p>
                            </div>

                            <form action="BookingManagementServlet" method="GET" class="flex flex-wrap items-center gap-3">
                                <div class="relative min-w-[260px]">
                                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                                    <input type="text" name="searchLicensePlate" value="<%= searchLicensePlate%>" 
                                           placeholder="Nhập biển số (Ví dụ: 59H hoặc 123)..." 
                                           class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-blue-500 focus:bg-white transition-all">
                                </div>

                                <div class="relative">
                                    <input type="date" name="bookingDate" value="<%= bookingDate%>"
                                           class="pl-4 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:border-blue-500 focus:bg-white text-slate-700 transition-all">
                                </div>

                                <button type="submit" class="bg-slate-900 hover:bg-slate-800 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-all">
                                    Lọc dữ liệu
                                </button>
                            </form>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600"><i class="fa-solid fa-calendar-days text-xl"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Tổng đơn hôm nay</span><span class="text-xl font-bold text-slate-800"><%= totalCount%> xe</span></div>
                            </div>
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600"><i class="fa-solid fa-spinner text-xl fa-spin"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Đang chờ (Pending)</span><span class="text-xl font-bold text-slate-800"><%= pendingCount%> xe</span></div>
                            </div>
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600"><i class="fa-solid fa-gears text-xl"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Đang trong buồng máy</span><span class="text-xl font-bold text-slate-800"><%= checkedInCount%> xe</span></div>
                            </div>
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600"><i class="fa-solid fa-circle-check text-xl"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Đã hoàn thành</span><span class="text-xl font-bold text-slate-800"><%= completedCount%> xe</span></div>
                            </div>
                        </div>

                        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                            <div class="overflow-x-auto custom-scrollbar">
                                <table class="w-full text-left border-collapse">
                                    <thead>
                                        <tr class="bg-slate-50 border-b border-slate-200 text-xs font-bold uppercase tracking-wider text-slate-500">
                                            <th class="py-4 px-6 text-center w-24 border-r border-slate-200">Khung Ca</th>
                                            <th class="py-4 px-6 min-w-[500px]">Thông tin chi tiết xe đặt lịch (Tối đa 3 vị trí/Ca)</th>
                                            <th class="py-4 px-6 w-44 text-center">Trạng thái hiện tại</th>
                                            <th class="py-4 px-6 w-60 text-center">Hành động của Admin</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-200 text-sm">

                                        <%
                                            for (int slot = 1; slot <= 28; slot++) {
                                                double startHour = 6.0 + (slot - 1) / 2.0;
                                                int hourPart = (int) startHour;
                                                String minutePart = (startHour % 1 == 0) ? "00" : "30";
                                                String timeString = hourPart + ":" + minutePart;

                                                // Lấy danh sách booking của ca hiện tại từ Map
                                                List<Map<String, Object>> bookingList = (slotMap != null) ? slotMap.get(slot) : null;
                                        %>

                                        <% for (int i = 0; i < 3; i++) {
                                                Map<String, Object> b = (bookingList != null && bookingList.size() > i) ? bookingList.get(i) : null;
                                                boolean hasBooking = (b != null);
                                        %>
                                        <tr class="hover:bg-slate-50/50 transition-colors">

                                            <% if (i == 0) {%>
                                            <td class="py-4 px-4 text-center font-semibold text-slate-700 bg-slate-50/70 border-r border-slate-200" rowspan="3">
                                                <div class="text-xs text-slate-400 font-medium">Ca <%= slot%></div>
                                                <div class="text-base font-bold text-slate-800 mt-0.5"><%= timeString%></div>
                                            </td>
                                            <% }%>

                                            <td class="py-4 px-6 <%= (i < 2) ? "border-b border-slate-100" : ""%>">
                                                <% if (hasBooking) {
                                                        String tierName = (String) b.get("TierName");
                                                        String note = (String) b.get("Note");
                                                        double totalAmount = (Double) b.get("TotalAmount");
                                                %>
                                                <div class="flex flex-col gap-1.5">
                                                    <div class="flex flex-col md:flex-row md:items-center justify-between gap-2">
                                                        <div>
                                                            <span class="inline-block px-2.5 py-1 bg-slate-900 text-white font-mono text-xs font-bold rounded-md shadow-sm mr-2"><%= b.get("LicensePlate")%></span>
                                                            <span class="font-semibold text-slate-900"><%= b.get("ServiceName")%></span>
                                                            <span class="text-xs font-bold text-blue-600 ml-1">(<%= df.format(totalAmount)%>đ)</span>
                                                        </div>
                                                        <div class="text-xs text-slate-500 flex items-center gap-1.5">
                                                            Khách: <span class="font-medium text-slate-700"><%= b.get("FullName")%></span>

                                                            <%
                                                                String tierClass = "bg-blue-50 text-blue-700";
                                                                String iconClass = "fa-user";
                                                                if ("Platinum".equals(tierName)) {
                                                                    tierClass = "bg-purple-100 text-purple-800";
                                                                    iconClass = "fa-gem";
                                                                } else if ("Gold".equals(tierName)) {
                                                                    tierClass = "bg-amber-100 text-amber-800";
                                                                    iconClass = "fa-crown";
                                                                } else if ("Silver".equals(tierName)) {
                                                                    tierClass = "bg-slate-100 text-slate-700";
                                                                }
                                                            %>
                                                            <span class="px-2 py-0.5 rounded text-[10px] font-bold <%= tierClass%>">
                                                                <i class="fa-solid <%= iconClass%> mr-0.5"></i><%= tierName%>
                                                            </span>
                                                        </div>
                                                    </div>

                                                    <% if (note != null && !note.trim().isEmpty()) {%>
                                                    <div class="text-xs bg-amber-50/70 border border-amber-100 text-amber-800 px-2.5 py-1 rounded-lg italic inline-flex items-center gap-1 max-w-max">
                                                        <i class="fa-solid fa-comment-dots text-amber-500"></i> Khách dặn: "<%= note%>"
                                                    </div>
                                                    <% } %>
                                                </div>
                                                <% } else { %>
                                                <span class="text-slate-400 italic text-xs tracking-wide"><i class="fa-solid fa-circle-dashed mr-1 text-slate-300"></i>Vị trí trống (Empty)</span>
                                                <% }%>
                                            </td>

                                            <td class="py-4 px-4 text-center <%= (i < 2) ? "border-b border-slate-100" : ""%>">
                                                <% if (hasBooking) {
                                                        String status = (String) b.get("BookingStatus");
                                                        String badgeColor = "";
                                                        String dotColor = "";
                                                        if ("Pending".equals(status)) {
                                                            badgeColor = "bg-amber-50 text-amber-700 border border-amber-200";
                                                            dotColor = "bg-amber-500";
                                                        } else if ("CheckedIn".equals(status)) {
                                                            badgeColor = "bg-blue-50 text-blue-700 border border-blue-200";
                                                            dotColor = "bg-blue-500";
                                                        } else if ("Completed".equals(status)) {
                                                            badgeColor = "bg-emerald-50 text-emerald-700 border border-emerald-200";
                                                            dotColor = "bg-emerald-500";
                                                        } else if ("Cancelled".equals(status)) {
                                                            badgeColor = "bg-slate-100 text-slate-500";
                                                            dotColor = "bg-slate-400";
                                                        } else if ("NoShow".equals(status)) {
                                                            badgeColor = "bg-red-50 text-red-700 border border-red-200";
                                                            dotColor = "bg-red-500";
                                                        }
                                                %>
                                                <span class="px-2.5 py-1 text-xs font-medium rounded-full inline-flex items-center gap-1 <%= badgeColor%>">
                                                    <span class="w-1.5 h-1.5 rounded-full <%= dotColor%>"></span>
                                                    <%= status%>
                                                </span>
                                                <% }%>
                                            </td>

                                            <td class="py-4 px-4 text-center <%= (i < 2) ? "border-b border-slate-100" : ""%>">
                                                <% if (hasBooking) {
                                                        String status = (String) b.get("BookingStatus");
                                                %>
                                                <div class="flex items-center justify-center gap-1.5">
                                                    <% if ("Pending".equals(status)) {%>
                                                    <a href="UpdateBookingStatus?id=<%= b.get("BookingId")%>&status=CheckedIn" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all"><i class="fa-solid fa-qrcode mr-1"></i>Check-in</a>
                                                    <% } else if ("CheckedIn".equals(status)) {%>
                                                    <a href="UpdateBookingStatus?id=<%= b.get("BookingId")%>&status=Completed" class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all"><i class="fa-solid fa-check-double mr-1"></i>Complete</a>
                                                    <% } else { %>
                                                    <span class="text-xs text-slate-400 italic"><i class="fa-solid fa-lock mr-0.5"></i>Khóa thao tác</span>
                                                    <% } %>
                                                </div>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>
                </div>
            </main>
        </div>
    </body>
</html>