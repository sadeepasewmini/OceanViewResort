package com.oceanview.controller;

import com.oceanview.dao.GuestDAO;
import com.oceanview.model.Guest;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * API Endpoint to fetch guest details by ID Number for the Ocean View Resort project.
 * This resolves the "System error during verification" by providing a valid mapping.
 */
@WebServlet("/GetGuestServlet")
public class GetGuestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private GuestDAO guestDAO;

    @Override
    public void init() {
        // Initialize the DAO to handle database queries
        guestDAO = new GuestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Capture the ID Number sent from the JSP fetch() call
        String idNumber = request.getParameter("idNumber");
        
        // 2. Configure response headers for JSON output
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 3. Search the database using the Guest's Primary Key
        Guest guest = guestDAO.getGuestById(idNumber);

        // 4. Construct the JSON response
        if (guest != null) {
            // Guest found: Send details back to auto-fill the form
            out.print("{");
            out.print("\"found\": true,");
            out.print("\"name\": \"" + escapeJson(guest.getName()) + "\",");
            out.print("\"contact\": \"" + escapeJson(guest.getContactNumber()) + "\",");
            out.print("\"address\": \"" + escapeJson(guest.getAddress()) + "\"");
            out.print("}");
        } else {
            // Guest not found: Allow for new registration
            out.print("{\"found\": false}");
        }
        
        out.flush();
    }

    /**
     * Helper method to prevent JSON breakage from special characters.
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"");
    }
}