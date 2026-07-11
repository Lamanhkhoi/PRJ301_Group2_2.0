package dto;

import java.sql.Timestamp;

/**
 * Map bảng RewardRedemptions - "kho voucher" của 1 khách hàng.
 * Có thêm vài field JOIN sẵn từ Rewards (rewardName, discountPercent...)
 * để customer_vouchers.jsp không phải query 2 lần.
 */
public class RewardRedemption {

    private int redemptionId;
    private int customerId;      // LƯU Ý: khóa theo CustomerId, KHÁC AccountId bên LoyaltyPointTransactions
    private int rewardId;
    private int pointsUsed;
    private Timestamp redeemedAt;
    private String status;       // "Available" / "Used" / "Expired"
    private Integer usedBookingId; // NULL nếu chưa dùng
    private Timestamp usedAt;

    // ===== Các field JOIN từ Rewards (không phải cột của bảng này) =====
    private String rewardName;
    private String description;
    private double discountPercent;
    private double minBillAmount;
    private double maxDiscountAmount;

    public RewardRedemption() {
    }

    public int getRedemptionId() {
        return redemptionId;
    }

    public void setRedemptionId(int redemptionId) {
        this.redemptionId = redemptionId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getRewardId() {
        return rewardId;
    }

    public void setRewardId(int rewardId) {
        this.rewardId = rewardId;
    }

    public int getPointsUsed() {
        return pointsUsed;
    }

    public void setPointsUsed(int pointsUsed) {
        this.pointsUsed = pointsUsed;
    }

    public Timestamp getRedeemedAt() {
        return redeemedAt;
    }

    public void setRedeemedAt(Timestamp redeemedAt) {
        this.redeemedAt = redeemedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getUsedBookingId() {
        return usedBookingId;
    }

    public void setUsedBookingId(Integer usedBookingId) {
        this.usedBookingId = usedBookingId;
    }

    public Timestamp getUsedAt() {
        return usedAt;
    }

    public void setUsedAt(Timestamp usedAt) {
        this.usedAt = usedAt;
    }

    public String getRewardName() {
        return rewardName;
    }

    public void setRewardName(String rewardName) {
        this.rewardName = rewardName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(double discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getMinBillAmount() {
        return minBillAmount;
    }

    public void setMinBillAmount(double minBillAmount) {
        this.minBillAmount = minBillAmount;
    }

    public double getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(double maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    /**
     * Mã voucher hiển thị cho khách (vd để đọc cho nhân viên lúc thanh toán).
     * KHÔNG PHẢI cột trong DB - bảng RewardRedemptions không có cột mã riêng,
     * nên sinh từ RedemptionId cho ngắn gọn, duy nhất, khỏi phải đổi schema.
     * Nếu sau này muốn mã ngẫu nhiên khó đoán hơn (thay vì tuần tự dễ đoán),
     * cần bàn với nhóm để thêm cột VoucherCode thật vào bảng.
     */
    public String getVoucherCode() {
        return "SW-" + String.format("%06d", redemptionId);
    }
}