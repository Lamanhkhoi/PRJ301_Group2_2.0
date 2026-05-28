package dto;

// Chứa thông tin xe và biển số xe (LicensePlate)

import java.util.Date;

public class CustomerVehicleDTO {
    private int vehicleId;
    private int customerId;
    private String licensePlate;
    private String brand;
    private String model;
    private String color;
    private String Type;
    private Boolean isDefault;
    private Boolean isActive;
    private Date createdAtt;

    public CustomerVehicleDTO() {
    }

    public CustomerVehicleDTO(int vehicleId, int customerId, String licensePlate, String brand, String model, String color, String Type, Boolean isDefault, Boolean isActive, Date createdAtt) {
        this.vehicleId = vehicleId;
        this.customerId = customerId;
        this.licensePlate = licensePlate;
        this.brand = brand;
        this.model = model;
        this.color = color;
        this.Type = Type;
        this.isDefault = isDefault;
        this.isActive = isActive;
        this.createdAtt = createdAtt;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getType() {
        return Type;
    }

    public void setType(String Type) {
        this.Type = Type;
    }

    public Boolean getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(Boolean isDefault) {
        this.isDefault = isDefault;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Date getCreatedAtt() {
        return createdAtt;
    }

    public void setCreatedAtt(Date createdAtt) {
        this.createdAtt = createdAtt;
    }
    
    
}
