package dto;

// Chứa thông tin đăng nhập, phân quyền (Role)

import java.util.Date;

public class Account {
    private int accountId;
    private String username;
    private String email;
    private String passwordHash;
    private String fullname;
    private String avaUrl;
    private String Role;
    private Boolean status;
    private Date createdAt;
    private Date updatedAt;
    private Date lastLoginAt;

    public Account() {
    }

    public Account(int accountId, String username, String email, String passwordHash, String fullname, String avaUrl, String Role, Boolean status, Date createdAt, Date updatedAt, Date lastLoginAt) {
        this.accountId = accountId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullname = fullname;
        this.avaUrl = avaUrl;
        this.Role = Role;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.lastLoginAt = lastLoginAt;
    }

    public int getAccountID() {
        return accountId;
    }

    public void setAccountID(int accountId) {
        this.accountId = accountId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public String getAvaUrl() {
        return avaUrl;
    }

    public void setAvaUrl(String avaUrl) {
        this.avaUrl = avaUrl;
    }

    public String getRole() {
        return Role;
    }

    public void setRole(String Role) {
        this.Role = Role;
    }

    public Boolean getStatus() {
        return status;
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Date getLastLoginAt() {
        return lastLoginAt;
    }

    public void setLastLoginAt(Date lastLoginAt) {
        this.lastLoginAt = lastLoginAt;
    }
    
    
}
