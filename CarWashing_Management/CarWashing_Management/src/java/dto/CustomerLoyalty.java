package dto;

import java.io.Serializable;

public class CustomerLoyalty implements Serializable {
    private int customerLoyaltyId;
    private int accountId;
    private int currentTierId;
    private int currentPoints;
    private int lifetimeEarnedPoints;
    private int lifetimeRedeemedPoints;
    private double totalSpent;
    private int totalWashCount;
    private LoyaltyTier currentTierDetails; // Hai đối tượng chứa toàn bộ thông tin 
    private LoyaltyTier nextTierDetails;    // đặc quyền của Hạng Hiện Tại và Hạng Kế Tiếp (Next Reward)
    
    // Thêm các thuộc tính bổ trợ giao diện (Không map với DB nhưng dùng để truyền dữ liệu ra JSP)
    private String bgClass;
    private String textClass;
    private String labelClass;
    private String iconColor;
    private String iconClass;
    private String currentBenefits;
    private int washPercent;
    private int spentPercent;
    private int washOffset;
    private int spentOffset;

    public CustomerLoyalty() {
    }

    public int getCustomerLoyaltyId() {
        return customerLoyaltyId;
    }

    public int getAccountId() {
        return accountId;
    }

    public int getCurrentTierId() {
        return currentTierId;
    }

    public int getCurrentPoints() {
        return currentPoints;
    }

    public int getLifetimeEarnedPoints() {
        return lifetimeEarnedPoints;
    }

    public int getLifetimeRedeemedPoints() {
        return lifetimeRedeemedPoints;
    }

    public double getTotalSpent() {
        return totalSpent;
    }

    public int getTotalWashCount() {
        return totalWashCount;
    }

    public LoyaltyTier getCurrentTierDetails() {
        return currentTierDetails;
    }

    public LoyaltyTier getNextTierDetails() {
        return nextTierDetails;
    }

    public void setCustomerLoyaltyId(int customerLoyaltyId) {
        this.customerLoyaltyId = customerLoyaltyId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public void setCurrentTierId(int currentTierId) {
        this.currentTierId = currentTierId;
    }

    public void setCurrentPoints(int currentPoints) {
        this.currentPoints = currentPoints;
    }

    public void setLifetimeEarnedPoints(int lifetimeEarnedPoints) {
        this.lifetimeEarnedPoints = lifetimeEarnedPoints;
    }

    public void setLifetimeRedeemedPoints(int lifetimeRedeemedPoints) {
        this.lifetimeRedeemedPoints = lifetimeRedeemedPoints;
    }

    public void setTotalSpent(double totalSpent) {
        this.totalSpent = totalSpent;
    }

    public void setTotalWashCount(int totalWashCount) {
        this.totalWashCount = totalWashCount;
    }

    public void setCurrentTierDetails(LoyaltyTier currentTierDetails) {
        this.currentTierDetails = currentTierDetails;
    }

    public void setNextTierDetails(LoyaltyTier nextTierDetails) {
        this.nextTierDetails = nextTierDetails;
    }

    public String getBgClass() { return bgClass; }
    public void setBgClass(String bgClass) { this.bgClass = bgClass; }

    public String getTextClass() { return textClass; }
    public void setTextClass(String textClass) { this.textClass = textClass; }

    public String getLabelClass() { return labelClass; }
    public void setLabelClass(String labelClass) { this.labelClass = labelClass; }

    public String getIconColor() { return iconColor; }
    public void setIconColor(String iconColor) { this.iconColor = iconColor; }

    public String getIconClass() { return iconClass; }
    public void setIconClass(String iconClass) { this.iconClass = iconClass; }

    public String getCurrentBenefits() { return currentBenefits; }
    public void setCurrentBenefits(String currentBenefits) { this.currentBenefits = currentBenefits; }

    public int getWashPercent() { return washPercent; }
    public void setWashPercent(int washPercent) { this.washPercent = washPercent; }

    public int getSpentPercent() { return spentPercent; }
    public void setSpentPercent(int spentPercent) { this.spentPercent = spentPercent; }

    public int getWashOffset() { return washOffset; }
    public void setWashOffset(int washOffset) { this.washOffset = washOffset; }

    public int getSpentOffset() { return spentOffset; }
    public void setSpentOffset(int spentOffset) { this.spentOffset = spentOffset; }
}