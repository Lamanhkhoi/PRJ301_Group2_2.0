package dao;

import dbutils.DBContext;
import dto.Vehicle;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/* Hàm  getVehiclesByCustomerId(int customerId)
        searchVehicles(int customerId, String keyword)
        addVehicle(CustomerVehicleDTO vehicle)
        updateVehicle(CustomerVehicleDTO vehicle)
        deleteVehicle(int vehicleId)
 */
public class CustomerVehicleDAO {

    public List<Vehicle> getAllVehicles(int custid) {
        List<Vehicle> result = new ArrayList<>();
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "SELECT [VehicleID]\n"
                        + "      ,[CustomerID]\n"
                        + "      ,[LicensePlate]\n"
                        + "      ,[VehicleBrand]\n"
                        + "      ,[VehicleModel]\n"
                        + "      ,[VehicleColor]\n"
                        + "      ,[IsDefault]\n"
                        + "      ,[IsActive]\n"
                        + "      ,[CreatedAt]\n"
                        + "  FROM [CustomerVehicles]\n"
                        + "  WHERE CustomerID = ? AND IsActive = 1";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setInt(1, custid);
                ResultSet table = st.executeQuery();
                if (table != null) {
                    while (table.next()) {
                        int id = table.getInt("VehicleID");
                        String liPlate = table.getString("LicensePlate");
                        String brand = table.getString("VehicleBrand");
                        String model = table.getString("VehicleModel");
                        String color = table.getString("VehicleColor");
                        Boolean isDefault = table.getBoolean("IsDefault");
                        Boolean isActive = table.getBoolean("IsActive");
                        Date date = table.getDate("CreatedAt");
                        Vehicle c = new Vehicle(id, custid, liPlate, brand, model, color, isDefault, isActive, date);
                        result.add(c);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return result;
    }

    //ham add vehicle
    public int addVehicle(Vehicle v) {
        int result = 0;
        Connection cn = null;
        try {
            //buoc 1: make connection
            cn = DBContext.getConnection();
            if (cn != null) {
                //buoc2: viet sql
                String sql = "insert dbo.CustomerVehicles([CustomerId],[LicensePlate],[VehicleBrand],[VehicleModel],[VehicleColor],[IsDefault],[IsActive],[CreatedAt]) values(?,?,?,?,?,?,?,?)";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setInt(1, v.getCustomerId());
                st.setString(2, v.getLicensePlate());
                st.setString(3, v.getBrand());
                st.setString(4, v.getModel());
                st.setString(5, v.getColor());
                st.setBoolean(6, false);
                st.setBoolean(7, true);
                st.setDate(8, new Date(System.currentTimeMillis()));
                result = st.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return result;
    }

    //ham nay de sua car
    public int updateVehicle(int id, String licenseplate, String brand, String model, String color) { //, Boolean isDefault
        int rs = 0;
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "update dbo.CustomerVehicles\n"
                        + "set LicensePlate = ?,VehicleBrand = ?, VehicleModel = ?, VehicleColor = ? where VehicleID = ?"; //, IsDefault = ?
                PreparedStatement st = cn.prepareStatement(sql);
                st.setString(1, licenseplate);
                st.setString(2, brand);
                st.setString(3, model);
                st.setString(4, color);
//                st.setBoolean(5, isDefault);
                st.setInt(5, id);
                rs = st.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return rs;
    }

    //xoa vehicle
    public int removeVehicle(int id) {
        int rs = 0;
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "update dbo.CustomerVehicles\n"
                        + "set IsActive = 0 where VehicleID = ? and IsActive = 1";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setInt(1, id);
                rs = st.executeUpdate();
                cn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rs;
    }

    //ham lay xe thong qua bien so xe
    public Vehicle getVehicle(String liPlate) {
        Vehicle result = null;
        Connection cn = null;
        try {
            //buoc 1: make connection
            cn = DBContext.getConnection();
            if (cn != null) {
                //buoc2: viet sql
                String sql = "SELECT [VehicleID]\n"
                        + "      ,[CustomerID]\n"
                        + "      ,[LicensePlate]\n"
                        + "      ,[VehicleBrand]\n"
                        + "      ,[VehicleModel]\n"
                        + "      ,[VehicleColor]\n"
                        + "      ,[IsDefault]\n"
                        + "      ,[IsActive]\n"
                        + "      ,[CreatedAt]\n"
                        + "  FROM [CustomerVehicles]\n"
                        + "  WHERE LicensePlate = ? AND IsActive = 1";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setString(1, liPlate);
                ResultSet table = st.executeQuery();
                //buoc 3:doc data trong bien table
                while (table.next()) {
                    int vehicleId = table.getInt("VehicleID");
                    int cusid = table.getInt("CustomerID");
                    String brand = table.getString("VehicleBrand");
                    String model = table.getString("VehicleModel");
                    String color = table.getString("VehicleColor");
                    Boolean isDefault = table.getBoolean("IsDefault");
                    Boolean isActive = table.getBoolean("IsActive");
                    Date createDate = table.getDate("CreatedAt");

                    result = new Vehicle(vehicleId, cusid, liPlate, brand, model, color, isDefault, isActive, createDate);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return result;
    }

    public Vehicle getVehicleById(int id) {
        Vehicle result = null;
        Connection cn = null;
        try {
            //buoc 1: make connection
            cn = DBContext.getConnection();
            if (cn != null) {
                //buoc2: viet sql
                String sql = "SELECT [VehicleID]\n"
                        + "      ,[CustomerID]\n"
                        + "      ,[LicensePlate]\n"
                        + "      ,[VehicleBrand]\n"
                        + "      ,[VehicleModel]\n"
                        + "      ,[VehicleColor]\n"
                        + "      ,[IsDefault]\n"
                        + "      ,[IsActive]\n"
                        + "      ,[CreatedAt]\n"
                        + "  FROM [CustomerVehicles]\n"
                        + "  WHERE VehicleID = ? AND IsActive = 1";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setInt(1, id);
                ResultSet table = st.executeQuery();
                //buoc 3:doc data trong bien table
                while (table.next()) {
                    int vehicleId = table.getInt("VehicleID");
                    int cusid = table.getInt("CustomerID");
                    String liPlate = table.getString("LicensePlate");
                    String brand = table.getString("VehicleBrand");
                    String model = table.getString("VehicleModel");
                    String color = table.getString("VehicleColor");
                    Boolean isDefault = table.getBoolean("IsDefault");
                    Boolean isActive = table.getBoolean("IsActive");
                    Date createDate = table.getDate("CreatedAt");

                    result = new Vehicle(vehicleId, cusid, liPlate, brand, model, color, isDefault, isActive, createDate);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return result;
    }
    //ham search
    public List<Vehicle> searchVehicles(
            int customerId,
            String plate,
            String brand,
            String model,
            String color) {

        List<Vehicle> list = new ArrayList<>();

        Connection cn = null;

        try {

            cn = DBContext.getConnection();

            String sql
                    = "SELECT * "
                    + "FROM CustomerVehicles "
                    + "WHERE CustomerID = ? ";

            if (plate != null && !plate.trim().isEmpty()) {
                sql += " AND LicensePlate LIKE ? ";
            }

            if (brand != null && !brand.trim().isEmpty()) {
                sql += " AND VehicleBrand LIKE ? ";
            }

            if (model != null && !model.trim().isEmpty()) {
                sql += " AND VehicleModel LIKE ? ";
            }

            if (color != null && !color.trim().isEmpty()) {
                sql += " AND VehicleColor LIKE ? ";
            }

            sql += " AND IsActive = 1";

            PreparedStatement st = cn.prepareStatement(sql);

            int index = 1;

            st.setInt(index++, customerId);

            if (plate != null && !plate.trim().isEmpty()) {
                st.setString(index++, "%" + plate + "%");
            }

            if (brand != null && !brand.trim().isEmpty()) {
                st.setString(index++, "%" + brand + "%");
            }

            if (model != null && !model.trim().isEmpty()) {
                st.setString(index++, "%" + model + "%");
            }

            if (color != null && !color.trim().isEmpty()) {
                st.setString(index++, "%" + color + "%");
            }

            ResultSet rs = st.executeQuery();

            while (rs.next()) {

                Vehicle v = new Vehicle(
                        rs.getInt("VehicleID"),
                        rs.getInt("CustomerID"),
                        rs.getString("LicensePlate"),
                        rs.getString("VehicleBrand"),
                        rs.getString("VehicleModel"),
                        rs.getString("VehicleColor"),
                        rs.getBoolean("IsDefault"),
                        rs.getBoolean("IsActive"),
                        rs.getDate("CreatedAt"));

                list.add(v);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
