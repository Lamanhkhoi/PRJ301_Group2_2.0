package dto;

// Chứa thông tin về danh sách phần thưởng trong hệ thống.

import java.util.Date;

public class Reward {
    private int rewardId;
    private String rewardName;
    private String description;
    private int requiredPoints;
    private String rewardType;
    private int discount;
    private int freeServiceId;
    private Boolean isActive;
    private Date createdAt;

    public Reward() {
    }

    public Reward(int rewardId, String rewardName, String description, int requiredPoints, String rewardType, int discount, int freeServiceId, Boolean isActive, Date createdAt) {
        this.rewardId = rewardId;
        this.rewardName = rewardName;
        this.description = description;
        this.requiredPoints = requiredPoints;
        this.rewardType = rewardType;
        this.discount = discount;
        this.freeServiceId = freeServiceId;
        this.isActive = isActive;
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

    public int getRequiredPoints() {
        return requiredPoints;
    }

    public void setRequiredPoints(int requiredPoints) {
        this.requiredPoints = requiredPoints;
    }

    public String getRewardType() {
        return rewardType;
    }

    public void setRewardType(String rewardType) {
        this.rewardType = rewardType;
    }

    public int getDiscount() {
        return discount;
    }

    public void setDiscount(int discount) {
        this.discount = discount;
    }

    public int getFreeServiceId() {
        return freeServiceId;
    }

    public void setFreeServiceId(int freeServiceId) {
        this.freeServiceId = freeServiceId;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    
}
