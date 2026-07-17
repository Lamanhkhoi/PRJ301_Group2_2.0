package dto;

import java.sql.Timestamp;

public class Promotion {

    private int promotionId;
    private String promotionName;
    private String description;

    private double discountPercent;
    private double minBillAmount;
    private double maxDiscountAmount;

    private Timestamp startDate;
    private Timestamp endDate;

    private boolean active;

    private Timestamp createdAt;

    public Promotion() {
    }

    public Promotion(int promotionId,
            String promotionName,
            String description,
            double discountPercent,
            double minBillAmount,
            double maxDiscountAmount,
            Timestamp startDate,
            Timestamp endDate,
            boolean active,
            Timestamp createdAt) {

        this.promotionId = promotionId;
        this.promotionName = promotionName;
        this.description = description;
        this.discountPercent = discountPercent;
        this.minBillAmount = minBillAmount;
        this.maxDiscountAmount = maxDiscountAmount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.active = active;
        this.createdAt = createdAt;
    }

    public int getPromotionId() {
        return promotionId;
    }

    public void setPromotionId(int promotionId) {
        this.promotionId = promotionId;
    }

    public String getPromotionName() {
        return promotionName;
    }

    public void setPromotionName(String promotionName) {
        this.promotionName = promotionName;
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

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

}