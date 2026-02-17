package com.oceanview.dao;

import com.oceanview.model.Guest;
import com.oceanview.util.DatabaseConfig;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Guest Management.
 * Handles registration, registry listing, and retrieval.
 */
public class GuestDAO {

    /**
     * Retrieves all guests for the registry table in add_reservation.jsp.
     */
    public List<Guest> selectAllGuests() {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests"; 
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Guest g = new Guest();
                // Ensure these column names match your MySQL table schema
                g.setIdNumber(rs.getString("id_number"));
                g.setName(rs.getString("name"));
                g.setContactNumber(rs.getString("contact_number"));
                g.setAddress(rs.getString("address"));
                guests.add(g);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guests;
    }

    /**
     * Inserts a new guest into the database.
     */
    public boolean addGuest(Guest guest) throws SQLException {
        String sql = "INSERT INTO guests (id_number, name, contact_number, address) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, guest.getIdNumber());
            ps.setString(2, guest.getName());
            ps.setString(3, guest.getContactNumber());
            ps.setString(4, guest.getAddress());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw e; 
        }
    }

    /**
     * Finds a guest by their ID Number (NIC/Passport).
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