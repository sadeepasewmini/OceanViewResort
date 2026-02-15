<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.dao.ReservationDAO, java.util.List"%>
<%
    // 1. Session Security: Restricted to ADMIN role
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }

    // 2. Data Retrieval
    ReservationDAO resDAO = new ReservationDAO();
    List<Reservation> allReservations = resDAO.selectAllReservations();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Financial Audit | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --bg-canvas: #f1f5f9;
            --success: #059669;
            --warning: #9a3412;
        }

        body { font-family: 'Inter', sans-serif; background: var(--bg-canvas); margin: 0; display: flex; color: var(--text-main); -webkit-font-smoothing: antialiased; }

        /* Sidebar Navigation */
        .sidebar { width: 280px; height: 100vh; background: var(--brand-dark); color: white; position: fixed; display: flex; flex-direction: column; }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; padding: 14px 30px; color: #94a3b8; text-decoration: none; transition: 0.2s; border-left: 4px solid transparent; font-weight: 500; }
        .nav-item:hover, .nav-item.active { background: #1e293b; color: white; border-left-color: var(--brand-primary); }
        
        .content-area { margin-left: 280px; padding: 40px; width: calc(100% - 280px); box-sizing: border-box; }

        /* Table Components */
        .table-section { background: white; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 15px 20px; text-align: left; font-size: 0.75rem; color: #64748b; border-bottom: 1px solid #e2e8f0; text-transform: uppercase; letter-spacing: 0.05em; }
        td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; vertical-align: middle; }
        tr:hover td { background-color: #fafafa; }

        /* Dynamic Status Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 4px; }
        .badge-paid { background: #dcfce7; color: var(--success); }
        .badge-pending { background: #fff7ed; color: var(--warning); }
        
        .amount-text { font-weight: 700; color: var(--brand-dark); }
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
        <header style="margin-bottom: 40px;">
            <h1 style="margin:0; font-size: 1.875rem;">Financial Audit Logs</h1>
            <p style="color: var(--text-muted); margin-top: 4px;">Monitoring resort revenue streams and payment verification status.</p>
        </header>

        <div class="table-section">
            <table>
                <thead>
                    <tr>
                        <th>Guest Name</th>
                        <th>Room Unit</th>
                        <th>Total Bill (LKR)</th>
                        <th>Payment Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (allReservations != null && !allReservations.isEmpty()) { 
                        for(Reservation res : allReservations) { 
                            // 3. Dynamic Status Logic: Checks DB for "Paid"
                            boolean isPaid = "Paid".equalsIgnoreCase(res.getPaymentStatus()); 
                    %>
                    <tr>
                        <td>
                            <div style="font-weight: 600; color: var(--brand-dark);"><%= res.getGuestName() %></div>
                            <div style="font-size: 0.75rem; color: var(--text-muted);">Ref: RES-<%= res.getReservationNumber() %></div>
                        </td>
                        <td>
                            <span style="color: var(--brand-primary); font-weight: 600;">Unit <%= res.getRoomNumber() %></span>
                        </td>
                        <td class="amount-text">
                            <%= String.format("%.2f", res.getTotalBill()) %>
                        </td>
                        <td>
                            <%-- The badge style toggles automatically based on the 'payment_status' column --%>
                            <span class="badge <%= isPaid ? "badge-paid" : "badge-pending" %>">
                                <% if(isPaid) { %>
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                <% } %>
                                <%= isPaid ? "Paid" : "Pending" %>
                            </span>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="4" style="text-align:center; padding:60px; color:var(--text-muted);">No financial records found in the system.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>