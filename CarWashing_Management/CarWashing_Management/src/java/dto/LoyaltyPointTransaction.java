package dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Map 1-1 với bảng LoyaltyPointTransactions, cộng thêm 1 field TÍNH ĐỘNG
 * (balanceAfter) không tồn tại trong DB - do LoyaltyPointTransactionDAO tính
 * bằng SUM() OVER ngay trong câu SQL.
 */
public class LoyaltyPointTransaction implements Serializable {

    private int transactionId;
    private int accountId;
    private Integer bookingId;      // NULL nếu không phải cộng điểm từ 1 booking
    private Integer redemptionId;   // NULL nếu không phải trừ điểm để đổi voucher
    private int pointsChange;       // Dương = cộng điểm, Âm = trừ điểm
    private String transactionType; // ĐÚNG NHƯ DB: "Earn" / "Redeem" / "Expire" / "AdminAdjust"
    private Timestamp expiresAt;    // Chỉ có giá trị khi transactionType = "Earn"
    private String description;
    private Timestamp createdAt;

    // KHÔNG map cột DB - là số dư điểm NGAY SAU khi giao dịch này xảy ra,
    // tính trên TOÀN BỘ lịch sử (không bị ảnh hưởng bởi filter đang hiển thị)
    private int balanceAfter;

    public LoyaltyPointTransaction() {
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public Integer getRedemptionId() {
        return redemptionId;
    }

    public void setRedemptionId(Integer redemptionId) {
        this.redemptionId = redemptionId;
    }

    public int getPointsChange() {
        return pointsChange;
    }

    public void setPointsChange(int pointsChange) {
        this.pointsChange = pointsChange;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(int balanceAfter) {
        this.balanceAfter = balanceAfter;
    }
}
