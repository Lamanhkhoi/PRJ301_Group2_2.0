package service;

import dbutils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * LOYALTY ENGINE - phụ trách: Point, Tier, tích/trừ điểm, đổi thưởng.
 *
 * 3 hàm ĐANG DÙNG (earnPoints, redeemReward, recalculateAllTiers) là các "cửa"
 * mà module khác (Payment - Người 1) sẽ gọi vào. Không ai được tự ý INSERT/
 * UPDATE trực tiếp vào CustomerLoyalty / LoyaltyPointTransactions /
 * RewardRedemptions ngoài các hàm này, để đảm bảo logic điểm luôn nhất quán.
 *
 * handleBookingCancelled() đã @Deprecated - xem chi tiết lý do ngay tại hàm đó.
 *
 * *** LƯU Ý DB: migration_loosen_points_check.sql (nới CHECK constraint) vẫn
 * cần giữ nguyên dù handleBookingCancelled() không còn dùng - vì bản thân việc
 * nới lỏng constraint không gây hại gì, và có thể vẫn cần cho những trường hợp
 * khác trong tương lai. ***
 */
public class LoyaltyService {

    /**
     * @deprecated KHÔNG CÒN DÙNG (quyết định của nhóm - chính sách đền bù hủy
     * lịch đã thay đổi hoàn toàn). GIỮ LẠI CODE để tham khảo/phòng khi chính
     * sách đổi lại, nhưng KHÔNG được gọi hàm này ở bất kỳ đâu trong code mới.
     *
     * LÝ DO: trước đây hàm này cấp 1 voucher giảm 100% khi khách hủy lịch hợp
     * lệ. Nhóm đã đổi chính sách: khi khách Cancel HOẶC No-Show, KHÔNG cấp
     * voucher đền bù nữa, và CŨNG KHÔNG cộng thêm điểm mới nào - điểm khách đã
     * nhận từ lúc thanh toán (qua earnPoints(), chạy độc lập tại thời điểm
     * thanh toán, không phụ thuộc booking sau này có bị hủy hay không) đơn
     * giản là KHÔNG bị thu hồi lại, và đó là toàn bộ "đền bù". Vì vậy, khi 1
     * booking chuyển sang Cancelled hoặc NoShow, phía gọi (CancelBookingController
     * hoặc tương đương) KHÔNG CẦN gọi bất kỳ hàm nào của LoyaltyService cả -
     * không có việc gì để làm ở tầng Loyalty trong tình huống này nữa.
     *
     * Gọi khi 1 Booking chuyển sang trạng thái 'Cancelled' (khách tự hủy hợp lệ trong 24h).
     * KHÔNG được gọi hàm này cho trạng thái 'NoShow' - NoShow không được đền bù.
     *
     * Việc cộng điểm KHÔNG nằm trong hàm này: nếu booking này trước đó có thanh toán
     * thật, điểm đã được cộng từ lúc earnPoints() chạy (lúc thanh toán thành công) rồi.
     * Hàm này chỉ lo phần "đền 1 lần rửa free":
     *   1. Snapshot đúng TotalAmount của booking bị hủy.
     *   2. Tạo 1 dòng Rewards "ẩn" riêng cho lần đền bù này (IsActive = 0, không lên
     *      catalog cho khách tự đổi, PointsRequired = 0 vì hệ thống tự cấp).
     *   3. Cấp thẳng 1 dòng RewardRedemptions cho khách (PointsUsed = 0, Status = Available).
     * Cả 3 bước bọc trong 1 transaction - lỗi bước nào rollback hết, tránh tạo Reward
     * mồ côi (không có Redemption đi kèm) hoặc ngược lại.
     *
     * @param bookingId  booking vừa bị hủy
     * @param customerId khách sở hữu booking đó (CustomerId, không phải AccountId)
     * @return true nếu tạo đền bù thành công
     */
    @Deprecated
    public boolean handleBookingCancelled(int bookingId, int customerId) {
        Connection cn = null;
        PreparedStatement pstGetAmount = null;
        PreparedStatement pstInsertReward = null;
        PreparedStatement pstInsertRedemption = null;
        ResultSet rsAmount = null;
        ResultSet rsGeneratedKey = null;

        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false); // Bắt đầu transaction

            // ===== BƯỚC 1: Snapshot số tiền THẬT SỰ đã trả cho booking này =====
            // ĐÃ SỬA LỖ HỔNG: trước đây dùng Bookings.TotalAmount (giá gốc) làm mốc đền bù,
            // không kiểm tra khách có thật sự mất tiền hay không -> có thể bị khai thác:
            // trả tiền thật cho lần A -> hủy -> nhận voucher đền bù -> dùng voucher đó đặt
            // lần B (trả 0đ thật) -> hủy tiếp B -> lại nhận thêm voucher mới (dù B vốn đã
            // miễn phí) -> lặp vô hạn, chỉ cần trả tiền thật đúng 1 lần duy nhất ban đầu.
            // Sửa bằng 2 thay đổi:
            //   1. Dùng Payments.FinalAmount (tiền THẬT đã trả, sau khi trừ voucher/khuyến mãi)
            //      làm mốc đền bù, thay vì giá gốc - công bằng hơn cho cả trường hợp bình thường.
            //   2. Nếu FinalAmount = 0 (booking này vốn đã được thanh toán hoàn toàn bằng voucher
            //      trước đó, khách không mất tiền thật) -> KHÔNG cấp voucher đền bù mới, chặn
            //      đứng vòng lặp ngay tại gốc.
            String sqlGetAmount = "SELECT p.FinalAmount FROM Bookings b "
                    + "JOIN Payments p ON p.BookingId = b.BookingId AND p.IsPaid = 1 "
                    + "WHERE b.BookingId = ?";
            pstGetAmount = cn.prepareStatement(sqlGetAmount);
            pstGetAmount.setInt(1, bookingId);
            rsAmount = pstGetAmount.executeQuery();

            if (!rsAmount.next()) {
                cn.rollback();
                return false; // Không tìm thấy booking đã thanh toán thật - không tự chế dữ liệu
            }
            double snapshotAmount = rsAmount.getDouble("FinalAmount");

            if (snapshotAmount <= 0) {
                cn.rollback();
                System.out.println("handleBookingCancelled(): Booking #" + bookingId
                        + " có FinalAmount = 0 (đã miễn phí từ trước) - KHÔNG cấp thêm voucher đền bù"
                        + " để tránh vòng lặp hủy liên tục sinh voucher vô hạn.");
                return true; // Xử lý đúng quy trình, chỉ là không có gì để đền bù - không phải lỗi
            }

            // ===== BƯỚC 2: Tạo dòng Reward riêng cho lần đền bù này =====
            // DiscountPercent = 100 + MaxDiscountAmount = đúng giá gói đã hủy
            // => free tuyệt đối cho đúng gói đó, chọn gói đắt hơn lần sau thì trả phần chênh.
            String sqlInsertReward = "INSERT INTO Rewards "
                    + "(RewardName, Description, PointsRequired, DiscountPercent, MinBillAmount, MaxDiscountAmount, IsActive) "
                    + "VALUES (?, ?, 0, 100, 0, ?, 0)"; // IsActive = 0 -> ẩn khỏi catalog khách
            pstInsertReward = cn.prepareStatement(sqlInsertReward, Statement.RETURN_GENERATED_KEYS);
            pstInsertReward.setString(1, "[Đền bù hủy lịch #" + bookingId + "]");
            pstInsertReward.setString(2, "Miễn phí 1 lần rửa xe do hủy lịch hợp lệ trong 24h. "
                    + "Giới hạn tối đa " + String.format("%,.0f", snapshotAmount) + " VNĐ (đúng giá gói đã hủy).");
            pstInsertReward.setDouble(3, snapshotAmount);

            if (pstInsertReward.executeUpdate() == 0) {
                cn.rollback();
                return false;
            }

            rsGeneratedKey = pstInsertReward.getGeneratedKeys();
            if (!rsGeneratedKey.next()) {
                cn.rollback();
                return false;
            }
            int newRewardId = rsGeneratedKey.getInt(1);

            // ===== BƯỚC 3: Cấp thẳng voucher cho khách - không trừ điểm =====
            String sqlInsertRedemption = "INSERT INTO RewardRedemptions "
                    + "(CustomerId, RewardId, PointsUsed, Status, RedeemedAt) "
                    + "VALUES (?, ?, 0, N'Available', ?)";
            pstInsertRedemption = cn.prepareStatement(sqlInsertRedemption);
            pstInsertRedemption.setInt(1, customerId);
            pstInsertRedemption.setInt(2, newRewardId);
            pstInsertRedemption.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));

            if (pstInsertRedemption.executeUpdate() == 0) {
                cn.rollback();
                return false;
            }

            cn.commit(); // Cả 2 INSERT thành công mới lưu thật
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (cn != null) cn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try { if (rsAmount != null) rsAmount.close(); } catch (Exception e) {}
            try { if (rsGeneratedKey != null) rsGeneratedKey.close(); } catch (Exception e) {}
            try { if (pstGetAmount != null) pstGetAmount.close(); } catch (Exception e) {}
            try { if (pstInsertReward != null) pstInsertReward.close(); } catch (Exception e) {}
            try { if (pstInsertRedemption != null) pstInsertRedemption.close(); } catch (Exception e) {}
            try {
                if (cn != null) {
                    cn.setAutoCommit(true); // Trả connection về trạng thái bình thường trước khi đóng
                    cn.close();
                }
            } catch (Exception e) {}
        }
    }

    /**
     * Gọi khi Payments.IsPaid chuyển thành 1 (thanh toán thành công) - do Người 1 gọi
     * ngay trong transaction tạo Booking + Payment lúc processPayment.
     *
     * Điểm tính trên FinalAmount (giá SAU khi trừ voucher/khuyến mãi), không phải
     * TotalAmount gốc. Nhờ vậy nếu khách dùng voucher đền bù che 100% (FinalAmount = 0)
     * thì totalPoints tự động ra 0 - đúng nguyên tắc "có trả tiền mới có điểm",
     * không cần viết if riêng cho trường hợp đó.
     *
     * @param accountId     chủ tài khoản (CustomerLoyalty/LoyaltyPointTransactions dùng AccountId)
     * @param bookingId     booking vừa thanh toán xong
     * @param finalAmount   Payments.FinalAmount của booking đó
     * @param bonusPointRate  bonus theo hạng hiện tại của khách (LoyaltyTiers.BonusPointRate,
     *                        vd 0.10 cho hạng Bạc) - bên gọi tự JOIN CustomerLoyalty + LoyaltyTiers
     *                        rồi truyền vào, hàm này không tự tra hạng để giữ trách nhiệm rõ ràng.
     * @return true nếu xử lý thành công (kể cả trường hợp 0 điểm, vẫn coi là thành công)
     */
    public boolean earnPoints(int accountId, int bookingId, double finalAmount, double bonusPointRate) {
        Connection cn = null;
        PreparedStatement pstEarn = null;
        PreparedStatement pstUpdateLoyalty = null;

        // BasePointRate mặc định 1 điểm = 1.000đ (khớp DF_LoyaltyTiers_BasePointRate = 0.001)
        int basePoints = (int) (finalAmount / 1000);
        int bonusPoints = (int) (basePoints * bonusPointRate);
        int totalPoints = basePoints + bonusPoints;

        if (totalPoints <= 0) {
            return true; // Không có gì để cộng (vd FinalAmount = 0) - không phải lỗi
        }

        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            // Ghi sổ cái lịch sử điểm - hết hạn sau 12 tháng kể từ ngày earn
            String sqlEarn = "INSERT INTO LoyaltyPointTransactions "
                    + "(AccountId, BookingId, PointsChange, TransactionType, ExpiresAt, Description) "
                    + "VALUES (?, ?, ?, N'Earn', DATEADD(MONTH, 12, SYSDATETIME()), ?)";
            pstEarn = cn.prepareStatement(sqlEarn);
            pstEarn.setInt(1, accountId);
            pstEarn.setInt(2, bookingId);
            pstEarn.setInt(3, totalPoints);
            pstEarn.setString(4, "Cộng điểm từ Booking #" + bookingId);
            pstEarn.executeUpdate();

            // Cập nhật số dư tổng
            String sqlUpdate = "UPDATE CustomerLoyalty SET "
                    + "CurrentPoints = CurrentPoints + ?, "
                    + "LifetimeEarnedPoints = LifetimeEarnedPoints + ?, "
                    + "UpdatedAt = SYSDATETIME() "
                    + "WHERE AccountId = ?";
            pstUpdateLoyalty = cn.prepareStatement(sqlUpdate);
            pstUpdateLoyalty.setInt(1, totalPoints);
            pstUpdateLoyalty.setInt(2, totalPoints);
            pstUpdateLoyalty.setInt(3, accountId);
            int rowsUpdated = pstUpdateLoyalty.executeUpdate();

            // QUAN TRỌNG: nếu 0 dòng bị ảnh hưởng nghĩa là AccountId này chưa có hồ sơ
            // trong CustomerLoyalty (vd tài khoản Admin, hoặc khách chưa được khởi tạo
            // hồ sơ loyalty). Không được coi đây là thành công - nếu không sẽ ghi "khống"
            // vào sổ cái LoyaltyPointTransactions trong khi số dư thật không hề nhích.
            if (rowsUpdated == 0) {
                cn.rollback();
                System.err.println("earnPoints() THẤT BẠI: AccountId=" + accountId
                        + " không có dòng trong CustomerLoyalty. Đã rollback, không ghi gì cả.");
                return false;
            }

            cn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (cn != null) cn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try { if (pstEarn != null) pstEarn.close(); } catch (Exception e) {}
            try { if (pstUpdateLoyalty != null) pstUpdateLoyalty.close(); } catch (Exception e) {}
            try {
                if (cn != null) {
                    cn.setAutoCommit(true);
                    cn.close();
                }
            } catch (Exception e) {}
        }
    }

    /**
     * Đổi 1 reward trong catalog lấy voucher - do khách chủ động bấm "Đổi ngay"
     * ở customer_rewards.jsp. KHÁC handleBookingCancelled() (hệ thống tự cấp,
     * không tốn điểm thật) - hàm này TRỪ ĐIỂM THẬT của khách.
     *
     * Luồng transaction (lỗi bước nào rollback hết):
     *   1. Đọc lại Reward + CurrentPoints TRỰC TIẾP TỪ DB để kiểm tra (không tin
     *      số điểm/trạng thái phía client gửi lên - client có thể bị sửa hoặc cũ).
     *   2. Cấp voucher trước (INSERT RewardRedemptions, lấy RedemptionId vừa tạo).
     *   3. Trừ điểm + ghi sổ cái 'Redeem' (gắn kèm RedemptionId ở bước 2 để
     *      audit trail nối được voucher với đúng giao dịch trừ điểm nào).
     *
     * @param accountId  dùng để trừ điểm (CustomerLoyalty/LoyaltyPointTransactions khóa theo AccountId)
     * @param customerId dùng để gắn chủ sở hữu voucher (RewardRedemptions khóa theo CustomerId - KHÁC accountId)
     * @param rewardId   reward khách muốn đổi
     * @return "OK" nếu thành công, hoặc thông báo lỗi cụ thể để hiển thị cho khách
     */
    public String redeemReward(int accountId, int customerId, int rewardId) {
        Connection cn = null;
        PreparedStatement pstCheckReward = null, pstCheckPoints = null,
                pstInsertRedemption = null, pstDeduct = null, pstLog = null;
        ResultSet rsReward = null, rsPoints = null, rsGeneratedKey = null;

        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            // ===== BƯỚC 1a: Đọc lại Reward THẬT từ DB =====
            pstCheckReward = cn.prepareStatement(
                    "SELECT PointsRequired, IsActive FROM Rewards WHERE RewardId = ?");
            pstCheckReward.setInt(1, rewardId);
            rsReward = pstCheckReward.executeQuery();
            if (!rsReward.next()) {
                cn.rollback();
                return "Phần thưởng không tồn tại";
            }
            int pointsRequired = rsReward.getInt("PointsRequired");
            boolean isActive = rsReward.getBoolean("IsActive");
            if (!isActive) {
                cn.rollback();
                return "Phần thưởng này hiện không còn khả dụng";
            }

            // ===== BƯỚC 1b: Đọc lại điểm hiện có THẬT từ DB =====
            pstCheckPoints = cn.prepareStatement(
                    "SELECT CurrentPoints FROM CustomerLoyalty WHERE AccountId = ?");
            pstCheckPoints.setInt(1, accountId);
            rsPoints = pstCheckPoints.executeQuery();
            if (!rsPoints.next()) {
                cn.rollback();
                return "Tài khoản chưa có hồ sơ điểm thưởng";
            }
            int currentPoints = rsPoints.getInt("CurrentPoints");
            if (currentPoints < pointsRequired) {
                cn.rollback();
                return "Không đủ điểm để đổi";
            }

            // ===== BƯỚC 2: Cấp voucher trước, lấy RedemptionId vừa sinh =====
            pstInsertRedemption = cn.prepareStatement(
                    "INSERT INTO RewardRedemptions (CustomerId, RewardId, PointsUsed, Status) "
                            + "VALUES (?, ?, ?, N'Available')",
                    Statement.RETURN_GENERATED_KEYS);
            pstInsertRedemption.setInt(1, customerId);
            pstInsertRedemption.setInt(2, rewardId);
            pstInsertRedemption.setInt(3, pointsRequired);
            if (pstInsertRedemption.executeUpdate() == 0) {
                cn.rollback();
                return "Không thể tạo voucher";
            }
            rsGeneratedKey = pstInsertRedemption.getGeneratedKeys();
            if (!rsGeneratedKey.next()) {
                cn.rollback();
                return "Không thể tạo voucher";
            }
            int newRedemptionId = rsGeneratedKey.getInt(1);

            // ===== BƯỚC 3: Trừ điểm + ghi sổ cái (gắn RedemptionId để audit trail đầy đủ) =====
            pstDeduct = cn.prepareStatement(
                    "UPDATE CustomerLoyalty SET CurrentPoints = CurrentPoints - ?, "
                            + "LifetimeRedeemedPoints = LifetimeRedeemedPoints + ?, UpdatedAt = SYSDATETIME() "
                            + "WHERE AccountId = ?");
            pstDeduct.setInt(1, pointsRequired);
            pstDeduct.setInt(2, pointsRequired);
            pstDeduct.setInt(3, accountId);
            if (pstDeduct.executeUpdate() == 0) {
                cn.rollback();
                return "Không thể trừ điểm (tài khoản không hợp lệ)";
            }

            pstLog = cn.prepareStatement(
                    "INSERT INTO LoyaltyPointTransactions (AccountId, RedemptionId, PointsChange, TransactionType, Description) "
                            + "VALUES (?, ?, ?, N'Redeem', ?)");
            pstLog.setInt(1, accountId);
            pstLog.setInt(2, newRedemptionId);
            pstLog.setInt(3, -pointsRequired);
            pstLog.setString(4, "Đổi thưởng #" + rewardId + " (Redemption #" + newRedemptionId + ")");
            pstLog.executeUpdate();

            cn.commit();
            return "OK";

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (cn != null) cn.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return "Có lỗi hệ thống, vui lòng thử lại";
        } finally {
            try { if (rsReward != null) rsReward.close(); } catch (Exception e) {}
            try { if (rsPoints != null) rsPoints.close(); } catch (Exception e) {}
            try { if (rsGeneratedKey != null) rsGeneratedKey.close(); } catch (Exception e) {}
            try { if (pstCheckReward != null) pstCheckReward.close(); } catch (Exception e) {}
            try { if (pstCheckPoints != null) pstCheckPoints.close(); } catch (Exception e) {}
            try { if (pstInsertRedemption != null) pstInsertRedemption.close(); } catch (Exception e) {}
            try { if (pstDeduct != null) pstDeduct.close(); } catch (Exception e) {}
            try { if (pstLog != null) pstLog.close(); } catch (Exception e) {}
            try {
                if (cn != null) {
                    cn.setAutoCommit(true);
                    cn.close();
                }
            } catch (Exception e) {}
        }
    }

    /**
     * Chạy ĐỊNH KỲ (batch - vd cron hàng đêm/hàng tháng, KHÔNG chạy real-time
     * ngay sau mỗi booking - theo đúng quyết định của nhóm) để xét lại hạng
     * cho TẤT CẢ khách hàng cùng lúc, cả lên hạng lẫn xuống hạng.
     *
     * KHÔNG dùng CustomerLoyalty.TotalWashCount/TotalSpent để xét hạng - 2 cột
     * này đang cộng dồn CẢ ĐỜI và hiện KHÔNG có bất kỳ đoạn code nào cập nhật
     * chúng (có thể là cột chưa hoàn thiện từ thiết kế ban đầu - nhãn UI ghi
     * "Trong Năm" nhưng tên cột lại nghe như cả đời, đang mâu thuẫn - cần
     * người phụ trách Dashboard xác nhận lại). Hàm này tính lại TRỰC TIẾP từ
     * Bookings + Payments trong đúng N tháng gần nhất mỗi lần chạy, để việc
     * xuống hạng phản ánh đúng hoạt động GẦN ĐÂY như đã chốt, không phụ
     * thuộc 2 cột đó.
     *
     * Chỉ tính booking đã BookingStatus='Completed' VÀ đã thanh toán
     * (Payments.IsPaid=1). Lọc theo cửa sổ thời gian dùng CompletedAt (thời
     * điểm rửa xong THẬT), không dùng BookingDate (chỉ là ngày đặt lịch dự
     * kiến, có thể khác ngày rửa thật). Số tiền tính vào ngưỡng chi tiêu là
     * Payments.FinalAmount (số tiền THẬT SỰ thu được sau khi trừ voucher/
     * khuyến mãi), không phải Bookings.TotalAmount (giá gốc trước giảm).
     *
     * KHÔNG TỰ ĐỘNG LỊCH CHẠY - hàm này chỉ thực thi khi được gọi. Cần quyết
     * định riêng cơ chế gọi định kỳ (nút bấm tay của Admin, hay 1 scheduled
     * task) - đây là quyết định hạ tầng, chưa thuộc phạm vi hàm này.
     *
     * MỖI LẦN 1 TÀI KHOẢN ĐỔI HẠNG, tự động ghi 1 dòng vào TierChangeLog
     * (AccountId, OldTierId, NewTierId, ChangedAt) ngay trong cùng câu UPDATE
     * bằng OUTPUT INTO - để Admin tra cứu lại được CHÍNH XÁC ai đổi hạng, từ
     * đâu sang đâu, lúc nào (không chỉ biết tổng số người đổi hạng).
     *
     * @param windowMonths số tháng nhìn lại (khuyến nghị 12, khớp hạn dùng điểm)
     * @return số tài khoản có hạng bị thay đổi trong lần chạy này,
     *         hoặc -1 nếu có lỗi khi chạy (phân biệt với 0 = chạy ổn nhưng không ai đổi hạng)
     */
    public int recalculateAllTiers(int windowMonths) {
        Connection cn = null;
        PreparedStatement pst = null;

        String sql = "WITH TierCalc AS ( "
                + "    SELECT cl.AccountId, cl.CurrentTierId, "
                + "           COALESCE(( "
                + "               SELECT TOP 1 t.TierId FROM LoyaltyTiers t "
                + "               WHERE recent.RecentWashCount >= t.MinWashCount "
                + "                  OR recent.RecentSpent    >= t.MinTotalSpent "
                + "               ORDER BY t.MinWashCount DESC, t.MinTotalSpent DESC "
                // ĐÃ SỬA: KHÔNG hardcode 0 làm fallback "Member" nữa - trước đây giả định
                // TierId đánh số từ 0 (Member=0), nhưng DB có thể đánh số từ 1 (IDENTITY(1,1)
                // mặc định) tùy máy/bản seed. Tra động tier có MinWashCount+MinTotalSpent thấp
                // nhất (chính là Member) làm fallback, không phụ thuộc số ID cụ thể là bao nhiêu.
                + "           ), (SELECT TOP 1 TierId FROM LoyaltyTiers ORDER BY MinWashCount ASC, MinTotalSpent ASC)) AS NewTierId "
                + "    FROM CustomerLoyalty cl "
                + "    JOIN Customers cust ON cust.AccountId = cl.AccountId "
                + "    CROSS APPLY ( "
                + "        SELECT ISNULL(COUNT(b.BookingId), 0) AS RecentWashCount, "
                + "               ISNULL(SUM(p.FinalAmount), 0) AS RecentSpent "
                + "        FROM Bookings b "
                + "        JOIN Payments p ON p.BookingId = b.BookingId AND p.IsPaid = 1 "
                + "        WHERE b.CustomerId = cust.CustomerId "
                + "          AND b.BookingStatus = N'Completed' "
                + "          AND b.CompletedAt >= DATEADD(MONTH, ?, SYSDATETIME()) "
                + "    ) recent "
                + ") "
                + "UPDATE CustomerLoyalty "
                + "SET CurrentTierId = tc.NewTierId, LastTierUpdatedAt = SYSDATETIME() "
                // OUTPUT INTO: ghi log NGAY TRONG câu UPDATE này - deleted.CurrentTierId là giá
                // trị TRƯỚC khi đổi, inserted.CurrentTierId là giá trị SAU khi đổi. Atomic tuyệt
                // đối, không có khoảng hở giữa lúc đọc giá trị cũ và lúc UPDATE (khác với việc
                // SELECT trước rồi UPDATE sau bằng 2 câu lệnh riêng, có thể bị race condition).
                + "OUTPUT inserted.AccountId, deleted.CurrentTierId, inserted.CurrentTierId, SYSDATETIME() "
                + "INTO TierChangeLog (AccountId, OldTierId, NewTierId, ChangedAt) "
                + "FROM CustomerLoyalty cl "
                + "JOIN TierCalc tc ON tc.AccountId = cl.AccountId "
                + "WHERE tc.NewTierId <> tc.CurrentTierId";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setInt(1, -windowMonths); // DATEADD lùi về quá khứ nên truyền số âm
            return pst.executeUpdate(); // = số dòng CurrentTierId thực sự đổi
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        } finally {
            try { if (pst != null) pst.close(); } catch (Exception e) {}
            try { if (cn != null) cn.close(); } catch (Exception e) {}
        }
    }
}