package dao;

import dbutils.DBContext;
import dto.TierChangeRecord;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO CHỈ ĐỌC cho bảng TierChangeLog. Việc GHI vào bảng này nằm hoàn toàn
 * trong LoyaltyService.recalculateAllTiers() (qua OUTPUT INTO ngay trong
 * câu UPDATE) - DAO này không có hàm ghi nào cả, đúng nguyên tắc chỉ 1 nơi
 * ghi dữ liệu.
 */
public class TierChangeLogDAO {

    /**
     * Lấy N dòng lịch sử đổi hạng gần nhất, mới nhất lên đầu.
     * @param limit số dòng tối đa muốn lấy (vd 20)
     */
    public List<TierChangeRecord> getRecentChanges(int limit) {
        List<TierChangeRecord> list = new ArrayList<>();

        String sql = "SELECT TOP (?) tcl.LogId, tcl.AccountId, a.FullName, "
                + "       ot.TierName AS OldTierName, ot.PriorityLevel AS OldPriority, "
                + "       nt.TierName AS NewTierName, nt.PriorityLevel AS NewPriority, "
                + "       tcl.ChangedAt "
                + "FROM TierChangeLog tcl "
                + "JOIN Accounts a ON a.AccountId = tcl.AccountId "
                + "JOIN LoyaltyTiers ot ON ot.TierId = tcl.OldTierId "
                + "JOIN LoyaltyTiers nt ON nt.TierId = tcl.NewTierId "
                + "ORDER BY tcl.ChangedAt DESC";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TierChangeRecord r = new TierChangeRecord();
                    r.setLogId(rs.getInt("LogId"));
                    r.setAccountId(rs.getInt("AccountId"));
                    r.setAccountName(rs.getString("FullName"));
                    r.setOldTierName(rs.getString("OldTierName"));
                    r.setNewTierName(rs.getString("NewTierName"));
                    r.setUpgrade(rs.getInt("NewPriority") > rs.getInt("OldPriority"));
                    r.setChangedAt(rs.getTimestamp("ChangedAt"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}