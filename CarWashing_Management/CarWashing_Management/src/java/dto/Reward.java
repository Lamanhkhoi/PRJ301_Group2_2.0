package dto;

// Chứa thông tin về danh sách phần thưởng trong hệ thống.
import java.util.Date;

public class Reward {

    private int rewardId;
    private String rewardName;
    private String description;
    private int pointsRequired;
    private double discountPercent;
    private double minBillAmount;
    private double maxDiscountAmount;
    private boolean active;
    private Date createdAt;

    public Reward() {
    }

    public Reward(int rewardId, String rewardName, String description, int pointsRequired, double discountPercent, double minBillAmount, double maxDiscountAmount, boolean active, Date createdAt) {
        this.rewardId = rewardId;
        this.rewardName = rewardName;
        this.description = description;
        this.pointsRequired = pointsRequired;
        this.discountPercent = discountPercent;
        this.minBillAmount = minBillAmount;
        this.maxDiscountAmount = maxDiscountAmount;
        this.active = active;
        this.createdAt = createdAt;
    }

    public int getRewardId() {
        return rewardId;
    }

    public void setRewardId(int rewardId) {
        this.rewardId = rewardId;
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

    public int getPointsRequired() {
        return pointsRequired;
    }

    public void setPointsRequired(int pointsRequired) {
        this.pointsRequired = pointsRequired;
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

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

}
