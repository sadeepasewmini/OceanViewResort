package com.oceanview.dao;

import com.oceanview.model.Room;
import com.oceanview.util.DatabaseConfig; // Use consistent package for config
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * RoomDAO manages the resort inventory, pricing, and availability states.
 */
public class RoomDAO {

    /**
     * Adds a new room unit to the system inventory.
     */
    public boolean addRoom(Room room) throws SQLException {
        String sql = "INSERT INTO rooms (room_number, room_type, price_per_night, status) VALUES (?, ?, ?, 'Available')";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setDouble(3, room.getPrice());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Retrieves the nightly rate for a specific room unit.
     * Used by ReservationServlet to calculate dynamic totals.
     */
    public double getPriceByRoomNumber(String roomNo) {
        String sql = "SELECT price_per_night FROM rooms WHERE room_number = ?";
        double price = 0.0;

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, roomNo);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    price = rs.getDouble("price_per_night");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return price;
    }

    /**
     * Fetches the full inventory list for management views.
     */
    public List<Room> getAllRooms() throws SQLException {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms";
        try (Connection conn = DatabaseConfig.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                rooms.add(new Room(
                    rs.getString("room_number"), 
                    rs.getString("room_type"), 
                    rs.getDouble("price_per_night"), 
                    rs.getString("status")
                ));
            }
        }
        return rooms;
    }

    /**
     * Removes a room unit from the inventory.
     */
    public boolean deleteRoom(String roomNo) throws SQLException {
        String sql = "DELETE FROM rooms WHERE room_number = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNo);
            return ps.executeUpdate() > 0;
        }
    }
}