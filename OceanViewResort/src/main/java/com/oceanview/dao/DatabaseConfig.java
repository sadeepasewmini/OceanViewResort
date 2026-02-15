package com.oceanview.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    // Standard connection for Ocean View Resort project
    private static String url = "jdbc:mysql://localhost:3306/OceanViewResort";
    private static String user = "root";
    private static String password = "sadeepa@#2000"; // Ensure this matches your local MySQL setup

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found");
        }
    }
}