package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DatabaseConfig;
import com.oceanview.util.PasswordHasher; 
import java.sql.*;

public class UserDAO {

    /**
     * User Authentication (Login).
     * Checks the Admins table first, then the Staff table.
     */
    public User authenticate(String username, String password) {
        User user = checkTable("admins", username, password);
        if (user == null) {
            user = checkTable("staff", username, password);
        }
        return user;
    }

    /**
     * Internal helper to verify hashed passwords using Java-side logic.
     */
    private User checkTable(String tableName, String username, String enteredPassword) {
        // 1. Search by username ONLY to retrieve the stored hash
        // Direct SQL string matching won't work with salted hashes.
        String sql = "SELECT username, password, role FROM " + tableName + " WHERE username = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // 2. Retrieve the secure 60-character hash from the database
                    String storedHash = rs.getString("password");
                    
                    // 3. VERIFY THE HASH IN JAVA
                    // The utility handles the salt math to see if the normal password matches the hash.
                    if (PasswordHasher.checkPassword(enteredPassword, storedHash)) {
                        User u = new User();
                        u.setUsername(rs.getString("username"));
                        u.setRole(rs.getString("role"));
                        return u; // Login Successful
                    }
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return null; // Login Failed
    }

    /**
     * Registers a new user with a hashed password.
     */
    public boolean registerUser(User user) throws SQLException {
        String tableName = user.getRole().equalsIgnoreCase("ADMIN") ? "admins" : "staff";
        String sql = "INSERT INTO " + tableName + " (username, password, role) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // HASH THE PASSWORD BEFORE SAVING
            // Converts raw text into a secure hash string for storage.
            String secureHash = PasswordHasher.hashPassword(user.getPassword());
            
            ps.setString(1, user.getUsername());
            ps.setString(2, secureHash); // Save the scrambled hash
            ps.setString(3, user.getRole().toUpperCase());
            
            return ps.executeUpdate() > 0;
        }
    }
}