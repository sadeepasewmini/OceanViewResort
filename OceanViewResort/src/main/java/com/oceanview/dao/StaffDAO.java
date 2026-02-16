package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DatabaseConfig;
import com.oceanview.util.PasswordHasher; 
import java.sql.*;

/**
 * Data Access Object for Staff management.
 * Follows the AdminDAO pattern for consistent registration and updates.
 */
public class StaffDAO {

    /**
     * Registers a new staff member with a hashed password.
     * Directly targets the staff table.
     */
    public boolean registerStaff(User user) throws SQLException {
        // SQL targets the staff table specifically
        String sql = "INSERT INTO staff (username, password, role) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
   	         PreparedStatement ps = conn.prepareStatement(sql)) {
   	        
   	        // Transform 'normal' password into a secure 60-character hash
   	        String secureHash = PasswordHasher.hashPassword(user.getPassword());
   	        
   	        ps.setString(1, user.getUsername());
   	        ps.setString(2, secureHash); // Store ONLY the hash in the database
   	        ps.setString(3, user.getRole().toUpperCase());
   	        
   	        return ps.executeUpdate() > 0;
   	    }
   	}

    /**
     * Updates an existing staff member's credentials.
     * Ensures any new password provided is hashed before saving.
     */
    public boolean updateStaff(User user) throws SQLException {
        String sql = "UPDATE staff SET password = ?, role = ? WHERE username = ?";
        
        try (Connection conn = DatabaseConfig.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Step 1: HASH THE NEW PASSWORD
            String secureHash = PasswordHasher.hashPassword(user.getPassword());
            
            ps.setString(1, secureHash); // Update with the new hash
            ps.setString(2, user.getRole().toUpperCase());
            ps.setString(3, user.getUsername());
            
            return ps.executeUpdate() > 0;
        }
    }
}