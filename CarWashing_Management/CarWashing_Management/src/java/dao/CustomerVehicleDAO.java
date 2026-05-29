package dao;

import dbutils.DBContext;
import dto.Customer;
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
                        + "  FROM [AutoWashProDB].[dbo].[CustomerVehicles]\n"
                        + "  WHERE CustomerID = ?";
                PreparedStatement st = cn.prepareStatement(sql);
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
                st.setBoolean(6, v.getIsDefault());
                st.setBoolean(7, v.getIsActive());
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
    public int updateVehicle(int id, String licenseplate, String brand, String model, String color, Boolean isDefault) {
        int rs = 0;
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "update dbo.CustomerVehicles\n"
                        + "set LicensePlate = ?,VehicleBrand = ?, VehicleModel = ?, VehicleColor = ?, IsDefault = ? where VehicleID = ?";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setString(1, licenseplate);
                st.setString(2, brand);
                st.setString(3, model);
                st.setString(4, color);
                st.setBoolean(5, isDefault);
                st.setInt(6, id);
                rs = st.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rs;
    }
    
    //xoa vehicle
    public int removeVehicle(int id, Boolean isActive) {
        int rs = 0;
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "update dbo.CustomerVehicles\n"
                        + "set IsActive = ? where VehicleID = ?";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setBoolean(1, isActive);
                st.setInt(2, id);
                rs = st.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rs;
    }
    
    //ham search vehicle
    
    
}
