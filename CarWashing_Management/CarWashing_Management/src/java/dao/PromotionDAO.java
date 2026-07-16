/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dbutils.DBContext;
import dto.Promotion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author LENOVO
 */
public class PromotionDAO {

    public List<Promotion> getPromotions() {
        List<Promotion> list = new ArrayList<>();

        String sql = "SELECT [PromotionId], [PromotionName], [Description],\n"
                + "[DiscountPercent], [MinBillAmount], [MaxDiscountAmount],\n"
                + "[StartDate], [EndDate], [IsActive], [CreatedAt] \n"
                + "FROM Promotions WHERE IsActive = 1";

        try ( Connection cn = DBContext.getConnection();  PreparedStatement ps = cn.prepareStatement(sql)) {
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Promotion promo = new Promotion();
                    promo.setPromotionId(rs.getInt("PromotionId"));
                    promo.setPromotionName(rs.getString("PromotionName"));
                    promo.setDescription(rs.getString("Description"));
                    promo.setDiscountPercent(rs.getDouble("DiscountPercent"));
                    promo.setMinBillAmount(rs.getDouble("MinBillAmount"));
                    promo.setMaxDiscountAmount(rs.getDouble("MaxDiscountAmount"));
                    promo.setStartDate(rs.getDate("StartDate"));
                    promo.setEndDate(rs.getDate("EndDate"));
                    promo.setActive(rs.getBoolean("IsActive"));
                    promo.setCreateAt(rs.getDate("CreatedAt"));
                    list.add(promo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public double calculatePromoDiscount(int promotionId, double basePrice) {
        if (promotionId <= 0) {
            return 0.0;
        }

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        // Truy vấn lấy cấu hình giảm giá của Voucher từ bảng Rewards thông qua lượt đổi RewardRedemptions
        String sql = "SELECT DiscountPercent, MinBillAmount, MaxDiscountAmount FROM Promotions WHERE PromotionId = ? AND IsActive = 1";

        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, promotionId);
                rs = pst.executeQuery();

                if (rs.next()) {
                    double minBillAmount = rs.getDouble("MinBillAmount");
                    double discountPercent = rs.getDouble("DiscountPercent");
                    double maxDiscountAmount = rs.getDouble("MaxDiscountAmount");

                    // Điều kiện 1: Đơn hàng không đủ giá trị tối thiểu để áp dụng mã
                    if (basePrice < minBillAmount) {
                        return 0.0;
                    }

                    // Điều kiện 2: Tính số tiền giảm theo %
                    double calculatedDiscount = basePrice * (discountPercent / 100.0);

                    // Điều kiện 3: Giới hạn số tiền giảm tối đa nếu vượt ngưỡng
                    if (calculatedDiscount > maxDiscountAmount) {
                        calculatedDiscount = maxDiscountAmount;
                    }

                    return calculatedDiscount;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (pst != null) {
                    pst.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0.0;
    }
}
