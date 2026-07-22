package util;

import dto.AdminDashboardData.ChartPoint;
import dto.AdminDashboardData.ServiceStat;
import java.util.List;

public class DashboardViewUtil {
    // Chuyển List<ChartPoint> thành 2 mảng JSON (labels, values) để nạp vào Chart.js.
    public static String chartLabelsJson(List<ChartPoint> points) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < points.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(points.get(i).getLabel().replace("\"", "\\\"")).append("\"");
        }
        return sb.append("]").toString();
    }

    public static String chartValuesJson(List<ChartPoint> points) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < points.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(points.get(i).getValue());
        }
        return sb.append("]").toString();
    }

    public static String serviceLabelsJson(List<ServiceStat> stats) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < stats.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(stats.get(i).getServiceName().replace("\"", "\\\"")).append("\"");
        }
        return sb.append("]").toString();
    }

    public static String serviceValuesJson(List<ServiceStat> stats) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < stats.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(stats.get(i).getBookingCount());
        }
        return sb.append("]").toString();
    }

    public static String statusBadgeClass(String status) {
        if (status == null) return "bg-slate-100 text-slate-600";
        switch (status) {
            case "Pending": return "bg-amber-100 text-amber-700";
            case "CheckedIn": return "bg-blue-100 text-blue-700";
            case "Completed": return "bg-emerald-100 text-emerald-700";
            case "NoShow": return "bg-rose-100 text-rose-700";
            default: return "bg-slate-100 text-slate-600";
        }
    }

    public static String statusLabel(String status) {
        if (status == null) return "--";
        switch (status) {
            case "Pending": return "Chờ xử lý";
            case "CheckedIn": return "Đang rửa";
            case "Completed": return "Hoàn tất";
            case "NoShow": return "Không đến";
            default: return status;
        }
    }
}
