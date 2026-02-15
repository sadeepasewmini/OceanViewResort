<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.dao.ReservationDAO, java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
    ReservationDAO resDAO = new ReservationDAO();
    List<Reservation> reservations = resDAO.selectAllReservations();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Center | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #2563eb; --dark: #0f172a; --bg: #f1f5f9; --success: #10b981; --warning: #f59e0b; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); margin: 0; display: flex; }
        .sidebar { width: 280px; height: 100vh; background: var(--dark); color: white; position: fixed; }
        .main { margin-left: 280px; padding: 50px; width: 100%; box-sizing: border-box; }
        .card { background: white; border-radius: 12px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 15px 20px; text-align: left; font-size: 0.75rem; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; }
        td { padding: 15px 20px; border-bottom: 1px solid #f1f5f9; }
        .badge { padding: 5px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        .badge-paid { background: #dcfce7; color: #166534; }
        .badge-pending { background: #fef3c7; color: #92400e; }
        .btn-pay { background: var(--primary); color: white; padding: 8px 15px; border-radius: 6px; text-decoration: none; border: none; cursor: pointer; font-weight: 600; font-size: 0.8rem; }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div style="padding: 40px 20px; text-align: center;"><h2>OCEAN VIEW</h2></div>
        </aside>
    <main class="main">
        <h1 style="margin: 0 0 30px 0;">Payment Verification Center</h1>
        <div class="card">
            <table>
                <thead>
                    <tr><th>ID</th><th>Guest Name</th><th>Amount Due</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                    <% if (reservations != null) { 
                        for(Reservation r : reservations) { %>
                    <tr>
                        <td style="font-family: monospace;">RES-<%= r.getReservationNumber() %></td>
                        <td><strong><%= r.getGuestName() %></strong></td>
                        <td>$<%= String.format("%.2f", r.getTotalBill()) %></td>
                        <td>
                            <span class="badge <%= "Paid".equalsIgnoreCase(r.getPaymentStatus()) ? "badge-paid" : "badge-pending" %>">
                                <%= r.getPaymentStatus() %>
                            </span>
                        </td>
                        <td>
                            <% if(!"Paid".equalsIgnoreCase(r.getPaymentStatus())) { %>
                                <form action="ProcessPaymentServlet" method="POST" style="margin:0;">
                                    <input type="hidden" name="resId" value="<%= r.getReservationNumber() %>">
                                    <button type="submit" class="btn-pay">Confirm Payment</button>
                                </form>
                            <% } else { %>
                                <span style="color: #94a3b8; font-size: 0.8rem;">Settled</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>