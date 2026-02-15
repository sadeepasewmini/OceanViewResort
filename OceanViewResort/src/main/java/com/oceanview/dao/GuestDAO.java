package com.oceanview.dao;

import com.oceanview.model.Guest;
import com.oceanview.util.DatabaseConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object for Guest Management.
 * Handles both registration and retrieval by ID Number (Primary Key).
 */
public class GuestDAO {

    /**
     * Inserts a new guest into the database.
     * @param guest The Guest model containing NIC/Passport (id_number), name, contact, and address.
     * @return true if insertion is successful.
     * @throws SQLException if the ID already exists or connection fails.
     */
    public boolean addGuest(Guest guest) throws SQLException {
        String sql = "INSERT INTO guests (id_number, name, contact_number, address) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, guest.getIdNumber());
            ps.setString(2, guest.getName());
            ps.setString(3, guest.getContactNumber());
            ps.setString(4, guest.getAddress());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw e; // Throwing allows the Servlet to catch specific issues like duplicates
        }
    }

    /**
     * Finds a guest by their ID Number (NIC/Passport).
     * Used for form auto-fill and server-side verification before reservations.
     * @param idNumber The primary key to search for.
     * @return A Guest object if found, otherwise null.
     */
    public Guest getGuestById(String idNumber) {
        Guest guest = null;
        String sql = "SELECT * FROM guests WHERE id_number = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idNumber);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    guest = new Guest();
                    guest.setIdNumber(rs.getString("id_number"));
                    guest.setName(rs.getString("name"));
                    guest.setContactNumber(rs.getString("contact_number"));
                    guest.setAddress(rs.getString("address"));
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return guest;
    }
}