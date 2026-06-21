package dto;

import java.util.Date;

public class Admin {
    private int adminId;
    private int accountId;
    private Date createdAt;

    public Admin() {
    }

    public Admin(int AdminId, int AccountId, Date createdAt) {
        this.adminId = AdminId;
        this.accountId = AccountId;
        this.createdAt = createdAt;
    }

    public int getAdminId() {
        return adminId;
    }

    public int getAccountId() {
        return accountId;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setAdminId(int AdminId) {
        this.adminId = AdminId;
    }

    public void setAccountId(int AccountId) {
        this.accountId = AccountId;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
    
}
