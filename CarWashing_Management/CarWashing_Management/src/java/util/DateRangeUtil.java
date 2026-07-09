package util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * Tiện ích tính khoảng thời gian và các "bucket" (đơn vị chia nhỏ trên trục X)
 * cho 4 loại filter của Admin Dashboard: Tuần / Tháng / Quý / Năm.
 *
 * Dùng chung cho mọi Servlet/DAO của Dashboard -- tránh lặp code tính ngày ở nhiều nơi.
 * Không đụng tới bảng DB nào, chỉ xử lý thuần logic ngày tháng (java.time).
 */
public class DateRangeUtil {

    public enum FilterType {
        WEEK, MONTH, QUARTER, YEAR
    }

    /**
     * Parse chuỗi filter từ request param (VD: "week", "month", "quarter", "year")
     * thành FilterType. Nếu không hợp lệ hoặc null, mặc định trả về WEEK.
     */
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

    /**
     * Trả về [ngày bắt đầu, ngày kết thúc] của khoảng thời gian tương ứng với filter,
     * tính theo ngày tham chiếu (thường truyền vào LocalDate.now()).
     *
     * - WEEK    = Thứ 2 -> Chủ Nhật chứa referenceDate
     * - MONTH   = ngày 1 -> ngày cuối cùng của tháng chứa referenceDate
     * - QUARTER = 3 tháng chứa referenceDate (Q1: T1-T3, Q2: T4-T6, Q3: T7-T9, Q4: T10-T12)
     * - YEAR    = 01/01 -> 31/12 của năm chứa referenceDate
     */
    public static LocalDate[] getRange(FilterType type, LocalDate referenceDate) {
        switch (type) {
            case WEEK:
                LocalDate monday = getMondayOfWeek(referenceDate);
                return new LocalDate[]{monday, monday.plusDays(6)};

            case MONTH:
                LocalDate firstDayOfMonth = referenceDate.withDayOfMonth(1);
                LocalDate lastDayOfMonth = firstDayOfMonth.plusMonths(1).minusDays(1);
                return new LocalDate[]{firstDayOfMonth, lastDayOfMonth};

            case QUARTER:
                int quarterIndex = (referenceDate.getMonthValue() - 1) / 3;   // 0,1,2,3
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

    /**
     * Trả về danh sách các "bucket" (đơn vị chia nhỏ trên trục X) cho biểu đồ,
     * tương ứng với từng loại filter:
     *
     * - WEEK    -> 7 bucket, mỗi bucket 1 ngày,  label = "Thứ 2".."Chủ Nhật"
     * - MONTH   -> 1 bucket / ngày trong tháng,  label = "1".."31" (số ngày)
     * - QUARTER -> 1 bucket / tuần trong quý,    label = "Tuần 1".."Tuần N"
     * - YEAR    -> 1 bucket / tháng trong năm,   label = "Tháng 1".."Tháng 12"
     *
     * Mỗi bucket có [bucketStart, bucketEnd] (inclusive) để DAO dùng làm điều kiện
     * WHERE khi gom nhóm (SUM/COUNT) dữ liệu cho đúng khoảng đó, kể cả khi không có
     * dữ liệu nào trong khoảng (DAO tự set value = 0 cho bucket đó).
     */
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
                    // Cắt bucket cuối cùng lại đúng ranh giới của quý (không vượt quá rangeEnd)
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

    /**
     * Trả về "ngày tham chiếu" mới sau khi dịch chuyển 1 đơn vị kỳ (trước/sau),
     * dùng cho 2 nút "Kỳ trước" / "Kỳ sau" trên Dashboard.
     *
     * direction: -1 = lùi về kỳ trước, +1 = tiến tới kỳ sau
     * - WEEK    -> dịch 7 ngày
     * - MONTH   -> dịch 1 tháng (giữ nguyên ngày trong tháng nếu có thể)
     * - QUARTER -> dịch 3 tháng
     * - YEAR    -> dịch 1 năm
     *
     * Ngày trả về chỉ cần "rơi vào" kỳ mới -- getRange()/getBuckets() sẽ tự tính lại
     * đúng ngày đầu/cuối của kỳ chứa ngày này.
     */
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

    /**
     * Trả về "ngày tham chiếu" của kỳ hiện tại (dùng cho nút "Hôm nay" trên Dashboard).
     */
    public static LocalDate today() {
        return LocalDate.now();
    }

    /**
     * Trả về ngày Thứ 2 của tuần chứa "date" (tuần bắt đầu từ Thứ 2 -> Chủ Nhật).
     */
    public static LocalDate getMondayOfWeek(LocalDate date) {
        long daysFromMonday = date.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue();
        return date.minusDays(daysFromMonday);
    }

    /**
     * Đổi DayOfWeek sang nhãn tiếng Việt: Thứ 2, Thứ 3, ..., Thứ 7, Chủ Nhật.
     */
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

    /**
     * 1 đơn vị chia nhỏ trên trục X của biểu đồ (VD: 1 ngày, 1 tuần, hoặc 1 tháng),
     * kèm theo khoảng ngày [start, end] (inclusive) tương ứng để DAO dùng lọc dữ liệu.
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

        /** Số ngày trong bucket này (inclusive), dùng để kiểm tra nhanh nếu cần. */
        public long getDayCount() {
            return ChronoUnit.DAYS.between(start, end) + 1;
        }
    }
}