/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dbutils.DBContext;
import dto.Vehicle;
import dto.WashService;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author LENOVO
 */
public class WashServiceDAO {

    public List<WashService> getAllServices() {
        List<WashService> result = new ArrayList<>();
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "SELECT [ServiceId]\n"
                        + "      ,[ServiceName]\n"
                        + "      ,[Description]\n"
                        + "      ,[Price]\n"
                        + "      ,[EstimatedMinutes]\n"
                        + "      ,[IsActive]\n"
                        + "  FROM [AutoCarWashingDB].[dbo].[WashServices]";
                PreparedStatement st = cn.prepareStatement(sql);
                ResultSet table = st.executeQuery();
                if (table != null) {
                    while (table.next()) {
                        int id = table.getInt("ServiceId");
                        String name = table.getString("ServiceName");
                        String discription = table.getString("Description");
                        double price = table.getDouble("Price");
                        int minutes = table.getInt("EstimatedMinutes");
                        boolean isActive = table.getBoolean("IsActive");
                        WashService service = new WashService(id, name, discription, price, minutes, isActive);
                        result.add(service);
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
    
    public WashService getServiceById(int id) {
        WashService result = null;
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                String sql = "SELECT [ServiceId]\n"
                        + "      ,[ServiceName]\n"
                        + "      ,[Description]\n"
                        + "      ,[Price]\n"
                        + "      ,[EstimatedMinutes]\n"
                        + "      ,[IsActive]\n"
                        + "  FROM [AutoCarWashingDB].[dbo].[WashServices] WHERE [ServiceId] = ?";
                PreparedStatement st = cn.prepareStatement(sql);
                st.setInt(1, id);
                ResultSet table = st.executeQuery();
                if (table != null) {
                    while (table.next()) {
                        String name = table.getString("ServiceName");
                        String discription = table.getString("Description");
                        double price = table.getDouble("Price");
                        int minutes = table.getInt("EstimatedMinutes");
                        boolean isActive = table.getBoolean("IsActive");
                        result = new WashService(id, name, discription, price, minutes, isActive);
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
}
