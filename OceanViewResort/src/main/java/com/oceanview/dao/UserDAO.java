package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DatabaseConfig;
import com.oceanview.util.PasswordHasher; 
import java.sql.*;

public class UserDAO {

    // Function 1: User Authentication (Login) [cite: 20]
    public User authenticate(String username, String password) {
        User user = null;
        // Check Admin table first, then Staff table
        user = checkTable("admins", username, password);
        if (user == null) {
            user = checkTable("staff", username, password);
        }
        return user;
    }

    private User checkTable(String tableName, String user, String pass) {
        String sql = "SELECT * FROM " + tableName + " WHERE username = ? AND password = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, pass);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUsername(rs.getString("username"));
                u.setRole(rs.getString("role"));
                return u;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Task: Admin User Management - Registering to separate tables 
    public boolean registerUser(User user) throws SQLException {
        String tableName = user.getRole().equalsIgnoreCase("ADMIN") ? "admins" : "staff";
        String sql = "INSERT INTO " + tableName + " (username, password, role) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Step 1: HASH THE PASSWORD BEFORE SAVING
            // Converts raw text into a secure hash string.
            String secureHash = PasswordHasher.hashPassword(user.getPassword());
            
            ps.setString(1, user.getUsername());
            ps.setString(2, secureHash); // Save the scrambled hash
            ps.setString(3, user.getRole().toUpperCase());
            
            return ps.executeUpdate() > 0;
        }
    }
}