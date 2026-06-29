package dto;

import java.time.LocalDateTime;
import java.util.Date;

public class Booking {

    private int bookingId;
    private int customerId;
    private int vehicleId;
    private int serviceId;
    private Date bookingDate;
    private int slotNumber;
    private LocalDateTime actualCheckInTime;
    private LocalDateTime completeAt;
    private double totalAmount;
    private String bookingStatus;
    private String note;
    private String licensePlate;
    private String vehicleBrand;
    private String vehicleModel;
    private String serviceName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean canCancel;
    public Booking() {
    }

    public Booking(int bookingId, int customerId, int vehicleId, int serviceId, Date bookingDate, int slotNumber, LocalDateTime actualCheckInTime, LocalDateTime completeAt, double totalAmount, String bookingStatus, String note, String licensePlate, String vehicleBrand, String vehicleModel, String serviceName, LocalDateTime createdAt, LocalDateTime updatedAt, boolean canCancel) {
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.vehicleId = vehicleId;
        this.serviceId = serviceId;
        this.bookingDate = bookingDate;
        this.slotNumber = slotNumber;
        this.actualCheckInTime = actualCheckInTime;
        this.completeAt = completeAt;
        this.totalAmount = totalAmount;
        this.bookingStatus = bookingStatus;
        this.note = note;
        this.licensePlate = licensePlate;
        this.vehicleBrand = vehicleBrand;
        this.vehicleModel = vehicleModel;
        this.serviceName = serviceName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.canCancel = canCancel;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public Date getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(Date bookingDate) {
        this.bookingDate = bookingDate;
    }

    public int getSlotNumber() {
        return slotNumber;
    }

    public void setSlotNumber(int slotNumber) {
        this.slotNumber = slotNumber;
    }

    public LocalDateTime getActualCheckInTime() {
        return actualCheckInTime;
    }

    public void setActualCheckInTime(LocalDateTime actualCheckInTime) {
        this.actualCheckInTime = actualCheckInTime;
    }

    public LocalDateTime getCompleteAt() {
        return completeAt;
    }

    public void setCompleteAt(LocalDateTime completeAt) {
        this.completeAt = completeAt;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getVehicleBrand() {
        return vehicleBrand;
    }

    public void setVehicleBrand(String vehicleBrand) {
        this.vehicleBrand = vehicleBrand;
    }

    public String getVehicleModel() {
        return vehicleModel;
    }

    public void setVehicleModel(String vehicleModel) {
        this.vehicleModel = vehicleModel;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public boolean isCanCancel() {
        return canCancel;
    }

    public void setCanCancel(boolean canCancel) {
        this.canCancel = canCancel;
    }

    
}
