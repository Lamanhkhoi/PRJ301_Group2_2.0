package dao;

import dbutils.DBContext;
import dto.LoyaltyPointTransaction;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng LoyaltyPointTransactions - phục vụ mục "Lịch sử điểm" trong
 * customer_loyalty.jsp (khối có filter chip Tất cả/Cộng điểm/Trừ điểm/Hết hạn
 * và phân trang).
 *
 * LƯU Ý QUAN TRỌNG khi gọi 2 hàm bên dưới:
 * Tham số filterType phải truyền ĐÚNG NGUYÊN VĂN 1 trong các giá trị:
 *     "ALL" (không lọc), "Earn", "Redeem", "Expire", "AdminAdjust"
 * Đây là chữ hoa/thường CHÍNH XÁC như CHECK constraint của bảng
 * (CK_LoyaltyPointTransactions_Type). Truyền sai chữ hoa/thường (vd "EARN"
 * thay vì "Earn") sẽ KHÔNG báo lỗi gì cả - câu SQL vẫn chạy, chỉ là kết quả
 * trả về rỗng một cách âm thầm. Nên set hằng số ở tầng Controller/JSP thay vì
 * gõ tay chuỗi mỗi lần gọi, để tránh gõ sai.
 *
 * UI hiện tại (customer_loyalty.jsp) chỉ có 3 chip lọc: Cộng/Trừ/Hết hạn,
 * chưa có chip riêng cho "AdminAdjust" - loại này chỉ hiện khi lọc "Tất cả".
 * Nếu sau này cần chip riêng cho AdminAdjust thì chỉ cần thêm 1 nút, DAO này
 * đã hỗ trợ sẵn giá trị đó rồi, không cần sửa gì thêm ở đây.
 */
public class LoyaltyPointTransactionDAO {

    /**
     * Lấy 1 trang lịch sử điểm, đã tính sẵn số dư sau mỗi giao dịch.
     *
     * @param accountId  chủ sở hữu điểm
     * @param filterType "ALL" hoặc đúng 1 trong 4 giá trị TransactionType
     * @param page       số trang, bắt đầu từ 1 (không phải 0)
     * @param pageSize   số dòng mỗi trang (vd 5 hoặc 10)
     */
    public List<LoyaltyPointTransaction> getHistory(int accountId, String filterType, int page, int pageSize) {
        List<LoyaltyPointTransaction> list = new ArrayList<>();
        if (page < 1) page = 1;
        int offset = (page - 1) * pageSize;

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        // BƯỚC 1 (CTE "Running"): tính số dư lũy kế trên TOÀN BỘ lịch sử của accountId,
        //          CHƯA lọc theo loại giao dịch ở bước này - để số dư luôn đúng thực tế.
        // BƯỚC 2 (SELECT ngoài): mới lọc theo filterType để hiển thị, rồi phân trang.
        String sql = "WITH Running AS ( "
                + "    SELECT *, "
                + "           SUM(PointsChange) OVER (ORDER BY CreatedAt ASC, TransactionId ASC "
                + "                                    ROWS UNBOUNDED PRECEDING) AS BalanceAfter "
                + "    FROM LoyaltyPointTransactions "
                + "    WHERE AccountId = ? "
                + ") "
                + "SELECT * FROM Running "
                + "WHERE (? = 'ALL' OR TransactionType = ?) "
                + "ORDER BY CreatedAt DESC, TransactionId DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setInt(1, accountId);
            pst.setString(2, filterType);
            pst.setString(3, filterType);
            pst.setInt(4, offset);
            pst.setInt(5, pageSize);
            rs = pst.executeQuery();

            while (rs.next()) {
                LoyaltyPointTransaction t = new LoyaltyPointTransaction();
                t.setTransactionId(rs.getInt("TransactionId"));
                t.setAccountId(rs.getInt("AccountId"));

                int bookingId = rs.getInt("BookingId");
                t.setBookingId(rs.wasNull() ? null : bookingId);

                int redemptionId = rs.getInt("RedemptionId");
                t.setRedemptionId(rs.wasNull() ? null : redemptionId);

                t.setPointsChange(rs.getInt("PointsChange"));
                t.setTransactionType(rs.getString("TransactionType"));
                t.setExpiresAt(rs.getTimestamp("ExpiresAt"));
                t.setDescription(rs.getString("Description"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setBalanceAfter(rs.getInt("BalanceAfter"));

                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pst != null) pst.close(); } catch (Exception e) {}
            try { if (cn != null) cn.close(); } catch (Exception e) {}
        }
        return list;
    }

    /**
     * Đếm tổng số dòng khớp filter - dùng để tính tổng số trang cho phần phân trang.
     * filterType quy ước giống hệt getHistory().
     */
    public int countHistory(int accountId, String filterType) {
        int total = 0;
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT COUNT(*) AS Total FROM LoyaltyPointTransactions "
                + "WHERE AccountId = ? AND (? = 'ALL' OR TransactionType = ?)";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setInt(1, accountId);
            pst.setString(2, filterType);
            pst.setString(3, filterType);
            rs = pst.executeQuery();

            if (rs.next()) {
                total = rs.getInt("Total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pst != null) pst.close(); } catch (Exception e) {}
            try { if (cn != null) cn.close(); } catch (Exception e) {}
        }
        return total;
    }
}
