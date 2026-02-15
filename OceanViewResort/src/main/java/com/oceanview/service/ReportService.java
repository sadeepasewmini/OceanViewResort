package com.oceanview.service;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import com.oceanview.dao.DatabaseConfig;

/**
 * Task B: Suitable set of reports for decision making
 */
public class ReportService {
    
    // Function: Occupancy/Revenue Report
    public Map<String, Double> getRevenueByRoomType() {
        Map<String, Double> reportData = new HashMap<>();
        String sql = "SELECT room_type, SUM(total_bill) as revenue FROM reservations GROUP BY room_type";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                reportData.put(rs.getString("room_type"), rs.getDouble("revenue"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reportData;
    }
}