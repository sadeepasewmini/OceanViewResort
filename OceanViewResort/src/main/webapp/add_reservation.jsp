<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Room, com.oceanview.dao.RoomDAO, java.util.List"%>
<%
    // 1. Session Access Control: Both Admin and Staff can access
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    RoomDAO roomDAO = new RoomDAO();
    List<Room> allRooms = roomDAO.getAllRooms();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>New Booking | Ocean View Resort</title>
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
            --success: #10b981;
            --error: #ef4444;
        }

        body { font-family: 'Inter', sans-serif; background: var(--bg-canvas); margin: 0; display: flex; color: var(--text-main); }

        /* Sidebar Navigation Container */
        .sidebar { width: 280px; height: 100vh; background: var(--brand-dark); color: white; position: fixed; display: flex; flex-direction: column; }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; padding: 14px 30px; color: #94a3b8; text-decoration: none; transition: 0.2s; border-left: 4px solid transparent; }
        .nav-item:hover, .nav-item.active { background: #1e293b; color: white; border-left-color: var(--brand-primary); }
        
        /* Layout Structure */
        .content-area { margin-left: 280px; padding: 40px; width: 100%; box-sizing: border-box; }

        /* Form Container */
        .form-section { background: var(--white); border-radius: 12px; border: 1px solid var(--border); max-width: 800px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); overflow: hidden; }
        .form-header { padding: 24px 30px; border-bottom: 1px solid var(--border); background: #f8fafc; }
        .form-body { padding: 30px; }

        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
        .full-width { grid-column: span 2; }

        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 0.875rem; color: var(--brand-dark); }
        input, select { width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; box-sizing: border-box; font-size: 0.95rem; font-family: inherit; }
        input:read-only { background-color: #f8fafc; color: var(--text-muted); cursor: not-allowed; }

        .status-msg { font-size: 0.85rem; margin-top: 6px; font-weight: 600; }
        .btn-submit { background-color: var(--brand-primary); color: white; border: none; padding: 14px 28px; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: 0.2s; width: 100%; }
        .btn-submit:disabled { background-color: #cbd5e1; cursor: not-allowed; }

        /* Error Alert Banner */
        .alert-error { background-color: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 16px; border-radius: 8px; margin-bottom: 30px; max-width: 800px; }
        .logout-link { padding: 20px 30px; color: #fca5a5; text-decoration: none; font-weight: 600; font-size: 0.9rem; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary);">RESOURCE MANAGEMENT</small>
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
            <h1 style="margin:0; font-size: 1.875rem;">Secure Reservation</h1>
            <p style="color: var(--text-muted);">Allocate resort resources and confirm guest bookings.</p>
        </header>

        <% 
            String error = request.getParameter("error");
            if ("room_taken".equals(error)) { 
        %>
            <div class="alert-error">
                <strong>⚠️ Room Overlap Conflict:</strong> That room is already reserved for the selected dates.
            </div>
        <% } %>

        <div class="form-section">
            <div class="form-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Booking Terminal</h3>
            </div>
            <div class="form-body">
                <form action="ReservationServlet" method="post" id="reservationForm">
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label>Guest ID Number (NIC/Passport)</label>
                            <input type="text" id="idNumber" name="idNumber" onblur="lookupGuest()" placeholder="Verify guest to unlock form..." required>
                            <div id="statusMsg" class="status-msg"></div>
                        </div>

                        <div class="form-group">
                            <label>Guest Name</label>
                            <input type="text" id="name" name="guestName" readonly>
                        </div>

                        <div class="form-group">
                            <label>Contact Number</label>
                            <input type="text" id="contact" name="contactNumber" readonly>
                        </div>

                        <input type="hidden" id="address" name="address">

                        <div class="form-group full-width">
                            <label>Select Room:</label>
                            <select id="roomNo" name="roomNo" onchange="syncRoomType(this)" required disabled>
                                <option value="">-- Choose Available Room --</option>
                                <% for(Room r : allRooms) { 
                                    boolean isOccupied = "Occupied".equalsIgnoreCase(r.getStatus());
                                %>
                                    <option value="<%= r.getRoomNumber() %>" 
                                            data-type="<%= r.getRoomType() %>"
                                            <%= isOccupied ? "style='color:#94a3b8' disabled" : "" %>>
                                        Room <%= r.getRoomNumber() %> (<%= r.getRoomType() %>) <%= isOccupied ? "[OCCUPIED]" : "" %>
                                    </option>
                                <% } %>
                            </select>
                            <input type="hidden" id="roomType" name="roomType">
                        </div>

                        <div class="form-group">
                            <label>Check-In Date</label>
                            <input type="date" id="checkIn" name="checkIn" required disabled>
                        </div>

                        <div class="form-group">
                            <label>Check-Out Date</label>
                            <input type="date" id="checkOut" name="checkOut" required disabled>
                        </div>
                    </div>

                    <div style="margin-top: 20px;">
                        <button type="submit" id="submitBtn" class="btn-submit" disabled>
                            Process Reservation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

<script>
function syncRoomType(select) {
    const selectedOption = select.options[select.selectedIndex];
    document.getElementById('roomType').value = selectedOption.getAttribute('data-type') || "";
}

function lookupGuest() {
    const id = document.getElementById('idNumber').value.trim();
    const msg = document.getElementById('statusMsg');
    const btn = document.getElementById('submitBtn');
    const fields = ['roomNo', 'checkIn', 'checkOut'];

    if (id.length < 5) return;

    const url = '<%= request.getContextPath() %>/GetGuestServlet?idNumber=' + encodeURIComponent(id);

    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.found) {
                document.getElementById('name').value = data.name;
                document.getElementById('contact').value = data.contact;
                document.getElementById('address').value = data.address;
                
                msg.innerText = "✓ Verified Guest: " + data.name;
                msg.style.color = "var(--success)";
                
                fields.forEach(f => document.getElementById(f).disabled = false);
                btn.disabled = false;
            } else {
                msg.innerText = "✗ Guest not registered. Register them first.";
                msg.style.color = "var(--error)";
                fields.forEach(f => document.getElementById(f).disabled = true);
                btn.disabled = true;
            }
        })
        .catch(err => {
            msg.innerText = "⚠ System error connecting to registry.";
            msg.style.color = "orange";
        });
}
</script>
</body>
</html>