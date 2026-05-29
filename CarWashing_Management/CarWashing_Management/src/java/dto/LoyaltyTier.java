package dto;

import java.io.Serializable;

public class LoyaltyTier implements Serializable {
    private int tierId;
    private String tierName;
    private int minWashCount;
    private double minTotalSpent;
    private double basePointRate;
    private double bonusPointRate; 
    private int bookingWindowDays;
    private int priorityLevel;
    private boolean hasPriorityQueue; 
    private boolean freeUpgradeMonthly; 
    private boolean freeWashMonthly;    
    private boolean isActive;

    public LoyaltyTier() {
    }

    public int getTierId() {
        return tierId;
    }

    public String getTierName() {
        return tierName;
    }

    public int getMinWashCount() {
        return minWashCount;
    }

    public double getMinTotalSpent() {
        return minTotalSpent;
    }

    public double getBasePointRate() {
        return basePointRate;
    }

    public double getBonusPointRate() {
        return bonusPointRate;
    }

    public int getBookingWindowDays() {
        return bookingWindowDays;
    }

    public int getPriorityLevel() {
        return priorityLevel;
    }

    public boolean isHasPriorityQueue() {
        return hasPriorityQueue;
    }

    public boolean isFreeUpgradeMonthly() {
        return freeUpgradeMonthly;
    }

    public boolean isFreeWashMonthly() {
        return freeWashMonthly;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setTierId(int tierId) {
        this.tierId = tierId;
    }

    public void setTierName(String tierName) {
        this.tierName = tierName;
    }

    public void setMinWashCount(int minWashCount) {
        this.minWashCount = minWashCount;
    }

    public void setMinTotalSpent(double minTotalSpent) {
        this.minTotalSpent = minTotalSpent;
    }

    public void setBasePointRate(double basePointRate) {
        this.basePointRate = basePointRate;
    }

    public void setBonusPointRate(double bonusPointRate) {
        this.bonusPointRate = bonusPointRate;
    }

    public void setBookingWindowDays(int bookingWindowDays) {
        this.bookingWindowDays = bookingWindowDays;
    }

    public void setPriorityLevel(int priorityLevel) {
        this.priorityLevel = priorityLevel;
    }

    public void setHasPriorityQueue(boolean hasPriorityQueue) {
        this.hasPriorityQueue = hasPriorityQueue;
    }

    public void setFreeUpgradeMonthly(boolean freeUpgradeMonthly) {
        this.freeUpgradeMonthly = freeUpgradeMonthly;
    }

    public void setFreeWashMonthly(boolean freeWashMonthly) {
        this.freeWashMonthly = freeWashMonthly;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
    
    
}