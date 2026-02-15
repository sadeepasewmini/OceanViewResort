<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.dao.ReservationDAO" %>
<%
    // 1. Session Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }

    String idParam = request.getParameter("id");
    Reservation res = null;
    ReservationDAO dao = new ReservationDAO();

    if (idParam != null) {
        try {
            int resId = Integer.parseInt(idParam);
            // Calling the newly defined DAO method
            res = dao.getReservationById(resId);
        } catch (NumberFormatException e) {
            response.sendRedirect("admin_dashboard.jsp?error=invalid_id");
            return;
        }
    }

    if (res == null) {
        response.sendRedirect("admin_dashboard.jsp?error=not_found");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Reservation | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #2563eb; --dark: #1e293b; --bg: #f8fafc; --text: #334155; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; justify-content: center; padding: 40px; color: var(--text); }
        .form-card { background: white; padding: 32px; border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); width: 100%; max-width: 450px; border: 1px solid #e2e8f0; }
        .field { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--dark); font-size: 0.875rem; }
        input { width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; box-sizing: border-box; font-size: 1rem; transition: border-color 0.2s; }
        input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1); }
        .btn { background: var(--primary); color: white; border: none; width: 100%; padding: 14px; cursor: pointer; border-radius: 8px; font-weight: 600; font-size: 1rem; margin-top: 10px; transition: opacity 0.2s; }
        .btn:hover { opacity: 0.9; }
        .cancel-link { display: block; text-align: center; margin-top: 20px; color: #64748b; text-decoration: none; font-size: 0.875rem; font-weight: 500; }
        .cancel-link:hover { color: var(--dark); }
    </style>
</head>
<body>
    <div class="form-card">
        <h2 style="margin: 0 0 8px 0; color: var(--dark);">Edit Reservation</h2>
        <p style="color: #64748b; font-size: 0.875rem; margin-bottom: 24px;">Editing Record: <strong>RES-<%= res.getReservationNumber() %></strong></p>
        
        <form action="UpdateReservationServlet" method="POST">
            <input type="hidden" name="reservationId" value="<%= res.getReservationNumber() %>">
            <input type="hidden" name="idNumber" value="<%= res.getIdNumber() %>">
            <input type="hidden" name="address" value="<%= res.getAddress() %>">
            <input type="hidden" name="totalBill" value="<%= res.getTotalBill() %>">

            <div class="field">
                <label>Guest Full Name</label>
                <input type="text" name="guestName" value="<%= res.getGuestName() %>" required>
            </div>
            
            <div class="field">
                <label>Contact Number</label>
                <input type="text" name="contactNumber" value="<%= res.getContactNumber() %>" required>
            </div>
            
            <div class="field">
                <label>Check-In Date</label>
                <input type="date" name="checkIn" value="<%= res.getCheckInDate() %>" required>
            </div>
            
            <div class="field">
                <label>Check-Out Date</label>
                <input type="date" name="checkOut" value="<%= res.getCheckOutDate() %>" required>
            </div>
            
            <button type="submit" class="btn">Update Reservation</button>
        </form>
        <a href="admin_dashboard.jsp" class="cancel-link">&larr; Back to Dashboard</a>
    </div>
</body>
</html>