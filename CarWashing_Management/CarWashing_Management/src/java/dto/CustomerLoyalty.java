package dto;

import java.io.Serializable;

public class CustomerLoyalty implements Serializable {
    private int customerLoyaltyId;
    private int accountId;
    private int currentTierId;
    private int currentPoints;
    private double totalSpent;
    private int totalWashCount;
    private LoyaltyTier currentTierDetails; // Hai đối tượng chứa toàn bộ thông tin 
    private LoyaltyTier nextTierDetails;    // đặc quyền của Hạng Hiện Tại và Hạng Kế Tiếp (Next Reward)

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

    
}