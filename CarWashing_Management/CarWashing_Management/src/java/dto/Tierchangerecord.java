package dto;

import java.sql.Timestamp;

/**
 * Map 1 dòng của bảng TierChangeLog, có JOIN sẵn vài field để hiển thị
 * (accountName, oldTierName, newTierName) - không cần DAO gọi tới đâu lấy thêm.
 */
public class TierChangeRecord {

    private int logId;
    private int accountId;
    private String accountName;
    private String oldTierName;
    private String newTierName;
    private boolean upgrade; // true = lên hạng, false = xuống hạng (so PriorityLevel cũ/mới)
    private Timestamp changedAt;

    public TierChangeRecord() {
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getAccountName() {
        return accountName;
    }

    public void setAccountName(String accountName) {
        this.accountName = accountName;
    }

    public String getOldTierName() {
        return oldTierName;
    }

    public void setOldTierName(String oldTierName) {
        this.oldTierName = oldTierName;
    }

    public String getNewTierName() {
        return newTierName;
    }

    public void setNewTierName(String newTierName) {
        this.newTierName = newTierName;
    }

    public boolean isUpgrade() {
        return upgrade;
    }

    public void setUpgrade(boolean upgrade) {
        this.upgrade = upgrade;
    }

    public Timestamp getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(Timestamp changedAt) {
        this.changedAt = changedAt;
    }
}