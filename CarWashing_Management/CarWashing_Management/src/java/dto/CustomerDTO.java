package dto;

// Chứa thông tin cá nhân khách hàng bao gồm cả PhoneNumber

import java.util.Date;

public class CustomerDTO {
    private int customerId;
    private int accountId;
    private String phone;
    private Date dob;
    private String gender;
    private String address;
    private Date createdAt;

    public CustomerDTO() {
    }

    public CustomerDTO(int customerId, int accountId, String phone, Date dob, String gender, String address, Date createdAt) {
        this.customerId = customerId;
        this.accountId = accountId;
        this.phone = phone;
        this.dob = dob;
        this.gender = gender;
        this.address = address;
        this.createdAt = createdAt;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    
}
