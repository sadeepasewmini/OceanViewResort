<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.model.Room, com.oceanview.dao.ReservationDAO, com.oceanview.dao.RoomDAO, java.util.List" %>
<%
    // 1. Session Access Control: Ensures only logged-in users access the registry
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Specialized Data Retrieval
    ReservationDAO resDAO = new ReservationDAO();
    RoomDAO roomDAO = new RoomDAO();
    List<Reservation> allReservations = resDAO.selectAllReservations();
    
    // 3. Capture status messages from redirects
    String status = request.getParameter("status");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Guest Registry | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --bg-canvas: #f1f5f9;
            --white: #ffffff;
            --border: #e2e8f0;
            --danger: #ef4444;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-canvas); 
            margin: 0; 
            display: flex; 
            color: var(--text-main); 
        }

        /* Sidebar Navigation - Synchronized Design */
        .sidebar { 
            width: 280px; 
            height: 100vh; 
            background: var(--brand-dark); 
            color: white; 
            position: fixed; 
            display: flex; 
            flex-direction: column; 
        }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { 
            display: flex; 
            align-items: center; 
            padding: 14px 30px; 
            color: #94a3b8; 
            text-decoration: none; 
            transition: 0.2s; 
            border-left: 4px solid transparent; 
        }
        .nav-item:hover, .nav-item.active { 
            background: #1e293b; 
            color: white; 
            border-left-color: var(--brand-primary); 
        }
        
        /* Layout Structure */
        .content-area { 
            margin-left: 280px; 
            padding: 40px; 
            width: 100%; 
            box-sizing: border-box; 
        }

        /* Notifications */
        .alert { padding: 14px 20px; border-radius: 8px; margin-bottom: 30px; font-weight: 600; font-size: 0.9rem; }
        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

        /* Registry Table Section */
        .table-section { 
            background: var(--white); 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            overflow: hidden; 
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); 
        }
        .table-header { padding: 20px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; }
        #searchBar { padding: 10px 16px; border: 1px solid var(--border); border-radius: 8px; width: 300px; font-family: inherit; }

        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 18px 20px; text-align: left; font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; border-bottom: 1px solid var(--border); }
        td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.95rem; }
        
        .btn-checkout { background-color: var(--danger); color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-weight: 600; transition: 0.2s; }
        .btn-checkout:hover { opacity: 0.9; }
        
        .logout-link { padding: 20px 30px; color: #fca5a5; text-decoration: none; font-weight: 600; font-size: 0.9rem; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary);">RESOURCE MANAGEMENTT</small>
        </div>
        <nav class="nav-menu">
            <a href="staff_dashboard.jsp" class="nav-item active">Operational Overview</a>
            <a href="staff_guest.jsp" class="nav-item">Guest Registration</a> 
            <a href="add_reservation.jsp" class="nav-item">New Booking</a> 
            <a href="view_reservations.jsp" class="nav-item">Guest Registry</a>
            <a href="view_bills.jsp" class="nav-item">Billing Center</a>
            
            <div style="margin-top: 20px; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 10px;">
                <a href="help.jsp" class="nav-item">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 12px;">
                        <circle cx="12" cy="12" r="10"></circle>
                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                    Help & Support
                </a>
        </nav>
        <a href="LogoutServlet" class="logout-link">Sign Out</a>
    </aside>

    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0; font-size: 1.875rem;">Guest Registry</h1>
            <p style="color: var(--text-muted);">Monitor current occupancy and process guest check-outs.</p>
        </header>

        <% if ("checkedout".equals(status)) { %>
            <div class="alert alert-success">✓ Checkout complete. Room inventory has been updated to 'Available'.</div>
        <% } else if ("true".equals(error)) { %>
            <div class="alert alert-error">⚠ System Error: Could not finalize check-out. Please check database connectivity.</div>
        <% } %>

        <div class="table-section">
            <div class="table-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Active Reservation Logs</h3>
                <input type="text" id="searchBar" onkeyup="filterTable()" placeholder="Filter by guest name...">
            </div>

            <table id="resTable">
                <thead>
                    <tr>
                        <th>Ref ID</th>
                        <th>Guest</th>
                        <th>Room</th>
                        <th>Duration</th>
                        <th style="text-align: right;">Operations</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (allReservations != null && !allReservations.isEmpty()) { 
                        for(Reservation res : allReservations) { %>
                        <tr>
                            <td style="font-family: monospace; font-weight: 700; color: var(--brand-primary);">#<%= res.getReservationNumber() %></td>
                            <td><strong><%= res.getGuestName() %></strong></td>
                            <td>Unit <%= res.getRoomNumber() %></td>
                            <td style="font-size: 0.85rem; color: var(--text-muted);"><%= res.getCheckInDate() %> &rarr; <%= res.getCheckOutDate() %></td>
                            <td style="text-align: right;">
                                <form action="CheckoutServlet" method="POST" style="margin:0;" onsubmit="return confirm('Release Room <%= res.getRoomNumber() %> and finalize guest stay?')">
                                    <input type="hidden" name="resId" value="<%= res.getReservationNumber() %>">
                                    <input type="hidden" name="roomNo" value="<%= res.getRoomNumber() %>">
                                    <button type="submit" class="btn-checkout">Checkout</button>
                                </form>
                            </td>
                        </tr>
                    <%  } 
                    } else { %>
                        <tr><td colspan="5" style="text-align:center; padding: 50px; color: var(--text-muted);">No active occupancy records found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

    <script>
        function filterTable() {
            let input = document.getElementById("searchBar"), filter = input.value.toUpperCase();
            let tr = document.getElementById("resTable").getElementsByTagName("tr");
            for (let i = 1; i < tr.length; i++) {
                let td = tr[i].getElementsByTagName("td")[1];
                if (td) tr[i].style.display = (td.textContent || td.innerText).toUpperCase().indexOf(filter) > -1 ? "" : "none";
            }
        }
    </script>
</body>
</html>