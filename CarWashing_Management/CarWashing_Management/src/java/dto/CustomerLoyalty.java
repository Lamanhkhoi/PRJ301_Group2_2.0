package dto;

// Chứa thông tin tích lũy điểm và hạng thành viên hiện tại của khách.

import java.util.Date;

public class CustomerLoyalty {
    private int custLoyaltyId;
    private int accountId;
    private int curentTierId;
    private int currentPoints;
    private int earnedPoints;
    private int redeemedPoints;
    private int totalSpent;
    private int totalWashCount;
    private Date lastTierUpdatedAt;

    public CustomerLoyalty() {
    }

    public CustomerLoyalty(int custLoyaltyId, int accountId, int curentTierId, int currentPoints, int earnedPoints, int redeemedPoints, int totalSpent, int totalWashCount, Date lastTierUpdatedAt) {
        this.custLoyaltyId = custLoyaltyId;
        this.accountId = accountId;
        this.curentTierId = curentTierId;
        this.currentPoints = currentPoints;
        this.earnedPoints = earnedPoints;
        this.redeemedPoints = redeemedPoints;
        this.totalSpent = totalSpent;
        this.totalWashCount = totalWashCount;
        this.lastTierUpdatedAt = lastTierUpdatedAt;
    }

    public int getCustLoyaltyId() {
        return custLoyaltyId;
    }

    public void setCustLoyaltyId(int custLoyaltyId) {
        this.custLoyaltyId = custLoyaltyId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getCurentTierId() {
        return curentTierId;
    }

    public void setCurentTierId(int curentTierId) {
        this.curentTierId = curentTierId;
    }

    public int getCurrentPoints() {
        return currentPoints;
    }

    public void setCurrentPoints(int currentPoints) {
        this.currentPoints = currentPoints;
    }

    public int getEarnedPoints() {
        return earnedPoints;
    }

    public void setEarnedPoints(int earnedPoints) {
        this.earnedPoints = earnedPoints;
    }

    public int getRedeemedPoints() {
        return redeemedPoints;
    }

    public void setRedeemedPoints(int redeemedPoints) {
        this.redeemedPoints = redeemedPoints;
    }

    public int getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(int totalSpent) {
        this.totalSpent = totalSpent;
    }

    public int getTotalWashCount() {
        return totalWashCount;
    }

    public void setTotalWashCount(int totalWashCount) {
        this.totalWashCount = totalWashCount;
    }

    public Date getLastTierUpdatedAt() {
        return lastTierUpdatedAt;
    }

    public void setLastTierUpdatedAt(Date lastTierUpdatedAt) {
        this.lastTierUpdatedAt = lastTierUpdatedAt;
    }
    
    
}
