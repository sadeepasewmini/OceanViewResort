package com.oceanview.dao;

import java.sql.*;
import java.util.*;

public class ReportDAO {
    // Function: Advanced Reporting for Hotel Occupancy 
    public Map<String, Integer> getOccupancyByRoomType() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT room_type, COUNT(*) as count FROM reservations GROUP BY room_type";
        
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                stats.put(rs.getString("room_type"), rs.getInt("count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }
}