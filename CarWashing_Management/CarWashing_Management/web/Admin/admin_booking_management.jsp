<%@page import="java.net.URLEncoder"%>
<%@ include file="../includes/admin-auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="dto.TimeSlot"%>
<%@page import="java.time.format.DateTimeFormatter"%>
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

        <%  Map<Integer, List<Map<String, Object>>> slotMap = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("SLOT_MAP");
            Map<Integer, TimeSlot> timeSlotMap = (Map<Integer, TimeSlot>) request.getAttribute("TIME_SLOT_MAP");
            DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("H:mm");
            DecimalFormat df = new DecimalFormat("###,###,###");

            int totalCount = request.getAttribute("TOTAL_COUNT") != null ? (Integer) request.getAttribute("TOTAL_COUNT") : 0;
            int pendingCount = request.getAttribute("PENDING_COUNT") != null ? (Integer) request.getAttribute("PENDING_COUNT") : 0;
            int checkedInCount = request.getAttribute("CHECKEDIN_COUNT") != null ? (Integer) request.getAttribute("CHECKEDIN_COUNT") : 0;
            int completedCount = request.getAttribute("COMPLETED_COUNT") != null ? (Integer) request.getAttribute("COMPLETED_COUNT") : 0;

            String searchLicensePlate = request.getParameter("searchLicensePlate") != null ? request.getParameter("searchLicensePlate") : "";
            String bookingDate = request.getAttribute("CURRENT_DATE_STR") != null ? (String) request.getAttribute("CURRENT_DATE_STR") : request.getParameter("bookingDate");

            // Nhận diện trạng thái lọc từ Servlet gửi sang
            boolean isFiltered = request.getAttribute("IS_FILTERED") != null ? (Boolean) request.getAttribute("IS_FILTERED") : false;
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
                                <p class="text-slate-500 text-sm mt-1">Giám sát và cập nhật trạng thái vận hành linh hoạt theo bộ lọc nâng cao.</p>
                            </div>

                            <form action="MainController?action=manageBooking" method="POST" class="flex flex-1 flex-col sm:flex-row items-stretch sm:items-center gap-3 max-w-3xl w-full md:w-auto">
                                <input type="hidden" name="action" value="manageBooking">                                
                                <div class="relative flex-1">
                                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                                    <input type="text" name="searchLicensePlate" value="<%= searchLicensePlate%>" 
                                           placeholder="Nhập biển số (Ví dụ: 59H hoặc 123)..." 
                                           class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-blue-500 focus:bg-white transition-all">
                                </div>

                                <div class="flex items-center gap-2 shrink-0">
                                    <div class="relative">
                                        <input type="date" name="bookingDate" value="<%= bookingDate%>"
                                               class="pl-4 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:border-blue-500 focus:bg-white text-slate-700 transition-all">
                                    </div>

                                    <button type="submit" class="bg-slate-900 hover:bg-slate-800 text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm transition-all whitespace-nowrap">
                                        Lọc dữ liệu
                                    </button>
                                </div>
                            </form>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600"><i class="fa-solid fa-calendar-days text-xl"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Kết quả tìm kiếm</span><span class="text-xl font-bold text-slate-800"><%= totalCount%> xe</span></div>
                            </div>
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600"><i class="fa-solid fa-spinner text-xl fa-spin"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Đang chờ (Pending)</span><span class="text-xl font-bold text-slate-800"><%= pendingCount%> xe</span></div>
                            </div>
                            <div class="bg-white p-5 rounded-2xl border border-slate-200 flex items-center gap-4 shadow-sm">
                                <div class="w-12 h-12 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600"><i class="fa-solid fa-gears text-xl"></i></div>
                                <div><span class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Trong buồng máy</span><span class="text-xl font-bold text-slate-800"><%= checkedInCount%> xe</span></div>
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
                                            <th class="py-4 px-6 min-w-[300px]">Thông tin xe & Dịch vụ</th>
                                            <th class="py-4 px-6 min-w-[200px]">Thông tin khách hàng</th>
                                            <th class="py-4 px-6 w-44 text-center">Trạng thái</th>
                                            <th class="py-4 px-6 w-50 text-center">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-200 text-sm">

                                        <%
                                            boolean dynamicRowHasData = false;
                                            for (int slot = 1; slot <= 28; slot++) {
                                                // Lấy giờ bắt đầu ca từ bảng TimeSlot (qua timeSlotMap) thay vì tính bằng thuật toán.
                                                // Đổi giờ ca sau này chỉ cần sửa dữ liệu trong DB, không cần sửa file JSP này.
                                                TimeSlot tsInfo = (timeSlotMap != null) ? timeSlotMap.get(slot) : null;
                                                String timeString = (tsInfo != null)
                                                        ? java.time.LocalTime.parse(tsInfo.getStartTime()).format(timeFormatter)
                                                        : "--:--";

                                                List<Map<String, Object>> bookingList = (slotMap != null) ? slotMap.get(slot) : null;
                                                int listSize = (bookingList != null) ? bookingList.size() : 0;

                                                // ================== NHÁNH 1: KHI CÓ LỌC BIỂN SỐ ==================
                                                if (isFiltered) {
                                                    if (listSize > 0) {
                                                        dynamicRowHasData = true;
                                                        for (int i = 0; i < listSize; i++) {
                                                            Map<String, Object> b = bookingList.get(i);
                                                            String tierName = (String) b.get("TierName");
                                                            String note = (String) b.get("Note");
                                                            double totalAmount = (Double) b.get("TotalAmount");
                                                            String status = (String) b.get("BookingStatus");
                                        %>
                                        <tr class="hover:bg-slate-50/50 transition-colors">
                                            <% if (i == 0) {%>
                                            <td class="py-4 px-4 text-center font-semibold text-slate-700 bg-slate-50/70 border-r border-slate-200" rowspan="<%= listSize%>">
                                                <div class="text-xs text-slate-400 font-medium">Ca <%= slot%></div>
                                                <div class="text-base font-bold text-slate-800 mt-0.5"><%= timeString%></div>
                                            </td>
                                            <% }%>

                                            <td class="py-4 px-6 <%= (i < listSize - 1) ? "border-b border-slate-100" : ""%>">
                                                <div class="flex flex-col gap-1">
                                                    <div>
                                                        <span class="inline-block px-2.5 py-1 bg-slate-900 text-white font-mono text-xs font-bold rounded-md shadow-sm"><%= b.get("LicensePlate")%></span>
                                                    </div>
                                                    <div class="font-semibold text-slate-900 text-sm mt-0.5"><%= b.get("ServiceName")%></div>
                                                    <div class="text-xs font-bold text-blue-600"><%= df.format(totalAmount)%>đ</div>

                                                    <% if (note != null && !note.trim().isEmpty()) {%>
                                                    <div class="text-xs bg-amber-50/70 border border-amber-100 text-amber-800 px-2 py-0.5 rounded-md italic inline-flex items-center gap-1 max-w-max mt-1">
                                                        <i class="fa-solid fa-comment-dots text-amber-500"></i> Dặn: "<%= note%>"
                                                    </div>
                                                    <% }%>
                                                </div>
                                            </td>

                                            <td class="py-4 px-6 <%= (i < listSize - 1) ? "border-b border-slate-100" : ""%>">
                                                <div class="flex flex-col gap-1.5 justify-center">
                                                    <div class="text-xs text-slate-500">
                                                        Khách: <span class="font-semibold text-slate-800 text-sm"><%= b.get("FullName")%></span>
                                                    </div>
                                                    <div>
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
                                                        <span class="px-2 py-0.5 rounded text-[10px] font-bold <%= tierClass%> inline-flex items-center">
                                                            <i class="fa-solid <%= iconClass%> mr-1"></i><%= tierName%>
                                                        </span>
                                                    </div>
                                                </div>
                                            </td>

                                            <td class="py-4 px-4 text-center <%= (i < listSize - 1) ? "border-b border-slate-100" : ""%>">
                                                <%
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
                                            </td>

                                            <td class="py-4 px-4 text-center <%= (i < listSize - 1) ? "border-b border-slate-100" : ""%>">
                                                <div class="flex items-center justify-center gap-1.5">
                                                    <% if ("Pending".equals(status)) {%>
                                                    <a href="MainController?action=updateBookingStatus&id=<%= b.get("BookingId")%>&status=CheckedIn&bookingDate=<%= bookingDate%>&searchLicensePlate=<%= URLEncoder.encode(searchLicensePlate, "UTF-8")%>" 
                                                       class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all">
                                                        <i class="fa-solid fa-qrcode mr-1"></i>Check-in
                                                    </a>
                                                    <% } else if ("CheckedIn".equals(status)) {%>
                                                    <a href="MainController?action=updateBookingStatus&id=<%= b.get("BookingId")%>&status=Completed&bookingDate=<%= bookingDate%>&searchLicensePlate=<%= URLEncoder.encode(searchLicensePlate, "UTF-8")%>" 
                                                       class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all">
                                                        <i class="fa-solid fa-check-double mr-1"></i>Complete
                                                    </a>
                                                    <% } else { %>
                                                    <span class="text-xs text-slate-400 italic"><i class="fa-solid fa-lock mr-0.5"></i>Khóa</span>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                            }
                                        } else {
                                            // ================== NHÁNH 2: MẶC ĐỊNH BÌNH THƯỜNG ==================
                                            for (int i = 0; i < 3; i++) {
                                                Map<String, Object> b = (bookingList != null && listSize > i) ? bookingList.get(i) : null;
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
                                                        String note = (String) b.get("Note");
                                                        double totalAmount = (Double) b.get("TotalAmount");
                                                %>
                                                <div class="flex flex-col gap-1">
                                                    <div>
                                                        <span class="inline-block px-2.5 py-1 bg-slate-900 text-white font-mono text-xs font-bold rounded-md shadow-sm"><%= b.get("LicensePlate")%></span>
                                                    </div>
                                                    <div class="font-semibold text-slate-900 text-sm mt-0.5"><%= b.get("ServiceName")%></div>
                                                    <div class="text-xs font-bold text-blue-600"><%= df.format(totalAmount)%>đ</div>

                                                    <% if (note != null && !note.trim().isEmpty()) {%>
                                                    <div class="text-xs bg-amber-50/70 border border-amber-100 text-amber-800 px-2 py-0.5 rounded-md italic inline-flex items-center gap-1 max-w-max mt-1">
                                                        <i class="fa-solid fa-comment-dots text-amber-500"></i> Dặn: "<%= note%>"
                                                    </div>
                                                    <% } %>
                                                </div>
                                                <% } else { %>
                                                <span class="text-slate-400 italic text-xs tracking-wide"><i class="fa-solid fa-circle-dashed mr-1 text-slate-300"></i>Vị trí trống (Empty)</span>
                                                <% }%>
                                            </td>

                                            <td class="py-4 px-6 <%= (i < 2) ? "border-b border-slate-100" : ""%>">
                                                <% if (hasBooking) {
                                                        String tierName = (String) b.get("TierName");
                                                %>
                                                <div class="flex flex-col gap-1.5 justify-center">
                                                    <div class="text-xs text-slate-500">
                                                        Khách: <span class="font-semibold text-slate-800 text-sm"><%= b.get("FullName")%></span>
                                                    </div>
                                                    <div>
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
                                                        <span class="px-2 py-0.5 rounded text-[10px] font-bold <%= tierClass%> inline-flex items-center">
                                                            <i class="fa-solid <%= iconClass%> mr-1"></i><%= tierName%>
                                                        </span>
                                                    </div>
                                                </div>
                                                <% } else { %>
                                                <span class="text-slate-300 italic text-xs">-</span>
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
                                                    <a href="MainController?action=updateBookingStatus&id=<%= b.get("BookingId")%>&status=CheckedIn&bookingDate=<%= bookingDate%>&searchLicensePlate=<%= URLEncoder.encode(searchLicensePlate, "UTF-8")%>" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all"><i class="fa-solid fa-qrcode mr-1"></i>Check-in</a>
                                                    <% } else if ("CheckedIn".equals(status)) {%>
                                                    <a href="MainController?action=updateBookingStatus&id=<%= b.get("BookingId")%>&status=Completed&bookingDate=<%= bookingDate%>&searchLicensePlate=<%= URLEncoder.encode(searchLicensePlate, "UTF-8")%>" class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-medium rounded-lg shadow-sm transition-all"><i class="fa-solid fa-check-double mr-1"></i>Complete</a>
                                                    <% } else { %>
                                                    <span class="text-xs text-slate-400 italic"><i class="fa-solid fa-lock mr-0.5"></i>Khóa</span>
                                                    <% } %>
                                                </div>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <%
                                                    }
                                                }
                                            } // Kết thúc vòng lặp 28 slots

                                            if (isFiltered && !dynamicRowHasData) {
                                        %>
                                        <tr>
                                            <td colspan="5" class="py-12 text-center text-slate-400 italic bg-white">
                                                <i class="fa-solid fa-folder-open text-3xl block mb-2 text-slate-300"></i>
                                                Không tìm thấy chiếc xe nào có biển số chứa ký tự "<%= searchLicensePlate%>" trong ngày được chọn.
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
        <div id="toastContainer" class="fixed top-5 right-5 z-50 flex flex-col gap-3 w-full max-w-sm">
            <%
                String alertType = (String) request.getAttribute("ALERT_TYPE");
                String alertMsg = (String) request.getAttribute("ALERT_MSG");
                if (alertType != null && alertMsg != null) {
                    String iconClass = "success".equals(alertType) ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation";
                    String bgIconColor = "success".equals(alertType) ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600";
                    String title = "success".equals(alertType) ? "Thành công" : "Thao tác thất bại";
            %>
            <div id="toastBox" class="flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border bg-white border-slate-100 w-full"
                 style="transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease; transform: translateX(120%); opacity: 0;">
                <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg <%= bgIconColor%>">
                    <i class="<%= iconClass%>"></i>
                </div>
                <div class="flex-1">
                    <h4 class="font-bold text-slate-800 text-sm"><%= title%></h4>
                    <p class="text-slate-500 text-xs mt-0.5"><%= alertMsg%></p>
                </div>
                <button onclick="closeServerToast(this)" class="text-slate-400 hover:text-slate-600 transition ml-2">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>
            <% }%>
        </div>
        <script>
            // HỆ THỐNG XỬ LÝ TOAST ALERT ĐỒNG BỘ 100% CỦA SERVER VÀ CLIENT
            const serverToast = document.getElementById('toastBox');
            if (serverToast) {
                setTimeout(() => {
                    serverToast.style.transform = "translateX(0)";
                    serverToast.style.opacity = "1";
                }, 100);
                setTimeout(() => {
                    closeServerToast(serverToast.querySelector('button'));
                }, 3800);
            }

            function closeServerToast(buttonElement) {
                const toastItem = buttonElement.closest('#toastBox');
                if (toastItem) {
                    toastItem.style.transform = "translateX(120%)";
                    toastItem.style.opacity = "0";
                    setTimeout(() => {
                        toastItem.remove();
                    }, 400);
                }
            }

            function showClientToast(type, title, message) {
                const container = document.getElementById('toastContainer');
                if (!container)
                    return;

                const iconClass = type === "success" ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation";
                const bgIconColor = type === "success" ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600";

                const toastHTML = `
                    <div class="flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border bg-white border-slate-100 w-full" 
                         style="transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease; transform: translateX(120%); opacity: 0;">
                        <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg \${bgIconColor}">
                            <i class="\${iconClass}"></i>
                        </div>
                        <div class="flex-1">
                            <h4 class="font-bold text-slate-800 text-sm">\${title}</h4>
                            <p class="text-slate-500 text-xs mt-0.5">\${message}</p>
                        </div>
                        <button onclick="closeClientToast(this)" class="text-slate-400 hover:text-slate-600 transition ml-2">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                `;

                container.insertAdjacentHTML('beforeend', toastHTML);
                const newToast = container.lastElementChild;

                setTimeout(() => {
                    newToast.style.transform = "translateX(0)";
                    newToast.style.opacity = "1";
                }, 50);

                setTimeout(() => {
                    closeClientToast(newToast.querySelector('button'));
                }, 3500);
            }

            function closeClientToast(buttonElement) {
                const toastItem = buttonElement.closest('div');
                if (toastItem) {
                    toastItem.style.transform = "translateX(120%)";
                    toastItem.style.opacity = "0";
                    setTimeout(() => {
                        toastItem.remove();
                    }, 400);
                }
            }
        </script>
    </body>
</html>