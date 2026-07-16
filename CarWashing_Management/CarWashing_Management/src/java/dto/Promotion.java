/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto;

import java.util.Date;

/**
 *
 * @author LENOVO
 */
public class Promotion {
    private int promotionId;
    private String promotionName;
    private String description;
    private double discountPercent;
    private double minBillAmount;
    private double maxDiscountAmount;
    private Date startDate;
    private Date endDate;
    private boolean active;
    private Date createAt;

    public Promotion() {
    }

    public Promotion(int promotionId, String promotionName, String description, double discountPercent, double minBillAmount, double maxDiscountAmount, Date startDate, Date endDate, boolean active, Date createAt) {
        this.promotionId = promotionId;
        this.promotionName = promotionName;
        this.description = description;
        this.discountPercent = discountPercent;
        this.minBillAmount = minBillAmount;
        this.maxDiscountAmount = maxDiscountAmount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.active = active;
        this.createAt = createAt;
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

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Date getCreateAt() {
        return createAt;
    }

    public void setCreateAt(Date createAt) {
        this.createAt = createAt;
    }
    
    
}
