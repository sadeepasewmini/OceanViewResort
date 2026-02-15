<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.dao.ReservationDAO, java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (!"ADMIN".equalsIgnoreCase(user.getRole()) && !"STAFF".equalsIgnoreCase(user.getRole()))) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }

    ReservationDAO resDAO = new ReservationDAO();
    List<Reservation> allReservations = resDAO.selectAllReservations();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reservations Management | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --bg-canvas: #f1f5f9;
            --status-occupied: #ef4444;
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg-canvas); margin: 0; display: flex; color: var(--text-main); }
        .sidebar { width: 280px; height: 100vh; background: var(--brand-dark); color: white; position: fixed; display: flex; flex-direction: column; }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; padding: 14px 30px; color: #94a3b8; text-decoration: none; transition: 0.2s; border-left: 4px solid transparent; }
        .nav-item.active { background: #1e293b; color: white; border-left-color: var(--brand-primary); }
        .content-area { margin-left: 280px; padding: 40px; width: 100%; box-sizing: border-box; }
        
        .table-section { background: white; border-radius: 12px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 18px 20px; text-align: left; font-size: 0.75rem; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; }
        td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.95rem; }
        .btn-action { padding: 8px 14px; border-radius: 6px; text-decoration: none; font-size: 0.85rem; font-weight: 600; cursor: pointer; border: none; }
        .btn-edit { background: #eff6ff; color: var(--brand-primary); margin-right: 5px; }
        .btn-delete { background: #fef2f2; color: var(--status-occupied); }
    </style>
</head>
<body>
     <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary);">RESOURCE MANAGEMENT</small>
        </div>
        <nav class="nav-menu">
             <a href="admin_dashboard.jsp" class="nav-item active">Dashboard Overview</a>
            <a href="reservations_management.jsp" class="nav-item">Reservations Management</a>
            <a href="payment_logs.jsp" class="nav-item">Financial Management</a> 
            <a href="admin_guest.jsp" class="nav-item">Guest Registration</a> 
            <a href="manage_users.jsp" class="nav-item">Staff Management</a> 
            <a href="admin_reports.jsp" class="nav-item">Reports</a>
            <a href="add_rooms.jsp" class="nav-item">Room Inventory</a>
        </nav>
        <div style="padding: 20px;"><a href="LogoutServlet" style="color:#fca5a5; text-decoration:none; font-weight:600;">Sign Out</a></div>
    </aside>

    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0;">Reservations Management</h1>
            <p style="color: var(--text-muted);">View, modify, or terminate active resort bookings.</p>
        </header>

        <div class="table-section">
            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Guest Name</th>
                        <th>Room No.</th>
                        <th>Stay Duration</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (allReservations != null && !allReservations.isEmpty()) { 
                        for(Reservation res : allReservations) { 
                    %>
                    <tr>
                        <td style="font-family: monospace; font-weight: 700; color: var(--brand-primary);">
                            RES-<%= res.getReservationNumber() %>
                        </td>
                        <td><strong><%= res.getGuestName() %></strong></td>
                        <td>Unit <%= res.getRoomNumber() %></td>
                        <td style="font-size: 0.85rem; color: var(--text-muted);">
                            <%= res.getCheckInDate() %> — <%= res.getCheckOutDate() %>
                        </td>
                        <td>
                            <a href="edit_reservation.jsp?id=<%= res.getReservationNumber() %>" class="btn-action btn-edit">Edit</a>
                            <% if("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                            <form action="DeleteReservationServlet" method="POST" style="display:inline;" 
                                  onsubmit="return confirm('Release Room <%= res.getRoomNumber() %>?');">
                                <input type="hidden" name="resId" value="<%= res.getReservationNumber() %>">
                                <input type="hidden" name="roomNo" value="<%= res.getRoomNumber() %>">
                                <button type="submit" class="btn-action btn-delete">Remove</button>
                            </form>
                            <% } %>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="5" style="text-align:center; padding:50px; color:var(--text-muted);">No active reservations found in the system.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>