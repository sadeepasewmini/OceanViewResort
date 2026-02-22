package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DatabaseConfig;
import com.oceanview.util.PasswordHasher; 
import java.sql.*;

public class AdminDAO {

    /**
     * Registers a new user with a hashed password.
     */
	public boolean registerUser(User user) throws SQLException {
	    String tableName = user.getRole().equalsIgnoreCase("ADMIN") ? "admins" : "staff";
	    String sql = "INSERT INTO " + tableName + " (username, password, role) VALUES (?, ?, ?)";
	    
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
     * Updates credentials, ensuring the new password is also hashed.
     */
    public boolean updateUser(User user) throws SQLException {
        String tableName = user.getRole().equalsIgnoreCase("ADMIN") ? "admins" : "staff";
        String sql = "UPDATE " + tableName + " SET password = ?, role = ? WHERE username = ?";
        
       
    }
}