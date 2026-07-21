package util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class DateRangeUtil {

    public enum FilterType {
        WEEK, MONTH, QUARTER, YEAR
    }

    // Chuyển từ chuỗi HTTP sang enum
    public static FilterType parseFilterType(String value) {
        if (value == null) {
            return FilterType.WEEK;
        }
        switch (value.trim().toLowerCase()) {
            case "month":
                return FilterType.MONTH;
            case "quarter":
                return FilterType.QUARTER;
            case "year":
                return FilterType.YEAR;
            case "week":
            default:
                return FilterType.WEEK;
        }
    }

    // Trả về [ngày bắt đầu, ngày kết thúc] của khoảng thời gian tương ứng với filter,
    public static LocalDate[] getRange(FilterType type, LocalDate referenceDate) {
        switch (type) {
            case WEEK:
                LocalDate monday = getMondayOfWeek(referenceDate);
                return new LocalDate[]{monday, monday.plusDays(6)};

            case MONTH:
                LocalDate firstDayOfMonth = referenceDate.withDayOfMonth(1);    // Hàm có sẵn của LocalDate, ép ngày về mùng 1, giữ nguyên tháng/năm
                LocalDate lastDayOfMonth = firstDayOfMonth.plusMonths(1).minusDays(1);
                return new LocalDate[]{firstDayOfMonth, lastDayOfMonth};

            case QUARTER:
                int quarterIndex = (referenceDate.getMonthValue() - 1) / 3;     // Tính quý: 0 = quý 1 (Tháng 1-3)
                int startMonth = quarterIndex * 3 + 1;
                LocalDate quarterStart = LocalDate.of(referenceDate.getYear(), startMonth, 1);
                LocalDate quarterEnd = quarterStart.plusMonths(3).minusDays(1);
                return new LocalDate[]{quarterStart, quarterEnd};

            case YEAR:
                LocalDate yearStart = LocalDate.of(referenceDate.getYear(), 1, 1);
                LocalDate yearEnd = LocalDate.of(referenceDate.getYear(), 12, 31);
                return new LocalDate[]{yearStart, yearEnd};

            default:
                throw new IllegalArgumentException("FilterType không hợp lệ: " + type);
        }
    }

    // Trả về danh sách các "bucket" (đơn vị chia nhỏ trên trục X) cho biểu đồ
    public static List<PeriodBucket> getBuckets(FilterType type, LocalDate referenceDate) {
        List<PeriodBucket> buckets = new ArrayList<>();
        LocalDate[] range = getRange(type, referenceDate);
        LocalDate rangeStart = range[0];
        LocalDate rangeEnd = range[1];

        switch (type) {
            case WEEK: {
                for (LocalDate d = rangeStart; !d.isAfter(rangeEnd); d = d.plusDays(1)) {
                    buckets.add(new PeriodBucket(getVietnameseWeekdayLabel(d.getDayOfWeek()), d, d));
                }
                break;
            }

            case MONTH: {
                for (LocalDate d = rangeStart; !d.isAfter(rangeEnd); d = d.plusDays(1)) {
                    buckets.add(new PeriodBucket(String.valueOf(d.getDayOfMonth()), d, d));
                }
                break;
            }

            case QUARTER: {
                int weekIndex = 1;
                LocalDate cursor = rangeStart;
                while (!cursor.isAfter(rangeEnd)) {
                    LocalDate weekStart = cursor;
                    LocalDate mondayOfCursorWeek = getMondayOfWeek(cursor);
                    LocalDate weekEndCandidate = mondayOfCursorWeek.plusDays(6);
                    LocalDate weekEnd = weekEndCandidate.isAfter(rangeEnd) ? rangeEnd : weekEndCandidate;
                    buckets.add(new PeriodBucket("Tuần " + weekIndex, weekStart, weekEnd));
                    weekIndex++;
                    cursor = weekEnd.plusDays(1);
                }
                break;
            }

            case YEAR: {
                for (int month = 1; month <= 12; month++) {
                    LocalDate monthStart = LocalDate.of(rangeStart.getYear(), month, 1);
                    LocalDate monthEnd = monthStart.plusMonths(1).minusDays(1);
                    buckets.add(new PeriodBucket("Tháng " + month, monthStart, monthEnd));
                }
                break;
            }
        }

        return buckets;
    }

    // Trả về ngày prev hoặc next
    public static LocalDate shiftPeriod(FilterType type, LocalDate referenceDate, int direction) {
        switch (type) {
            case WEEK:
                return referenceDate.plusWeeks(direction);
            case MONTH:
                return referenceDate.plusMonths(direction);
            case QUARTER:
                return referenceDate.plusMonths(3L * direction);
            case YEAR:
                return referenceDate.plusYears(direction);
            default:
                throw new IllegalArgumentException("FilterType không hợp lệ: " + type);
        }
    }

    public static LocalDate today() {
        return LocalDate.now();
    }

    public static LocalDate getMondayOfWeek(LocalDate date) {
        long daysFromMonday = date.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue(); // DayOfWeek().getValue() trả về số thứ tự: Thứ 2 = 1,...
        return date.minusDays(daysFromMonday);
    }

    public static String getVietnameseWeekdayLabel(DayOfWeek dayOfWeek) {
        switch (dayOfWeek) {
            case MONDAY:
                return "Thứ 2";
            case TUESDAY:
                return "Thứ 3";
            case WEDNESDAY:
                return "Thứ 4";
            case THURSDAY:
                return "Thứ 5";
            case FRIDAY:
                return "Thứ 6";
            case SATURDAY:
                return "Thứ 7";
            case SUNDAY:
            default:
                return "Chủ Nhật";
        }
    }

    /*
      1 đơn vị chia nhỏ trên trục X của biểu đồ,
      kèm theo khoảng ngày [start, end] tương ứng để DAO dùng lọc dữ liệu.
    */
    public static class PeriodBucket {

        private final String label;
        private final LocalDate start;
        private final LocalDate end;

        public PeriodBucket(String label, LocalDate start, LocalDate end) {
            this.label = label;
            this.start = start;
            this.end = end;
        }

        public String getLabel() {
            return label;
        }

        public LocalDate getStart() {
            return start;
        }

        public LocalDate getEnd() {
            return end;
        }

        public long getDayCount() {
            return ChronoUnit.DAYS.between(start, end) + 1;
        }
    }
}
