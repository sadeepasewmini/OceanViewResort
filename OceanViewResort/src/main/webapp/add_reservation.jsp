<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Guest, com.oceanview.model.Room, com.oceanview.dao.GuestDAO, com.oceanview.dao.RoomDAO, java.util.List" %>
<%
    // 1. Session Access Control
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Data Retrieval
    GuestDAO guestDAO = new GuestDAO();
    RoomDAO roomDAO = new RoomDAO();
    List<Guest> guestList = guestDAO.selectAllGuests();
    List<Room> allRooms = roomDAO.getAllRooms();

    // 3. Capture status messages
    String error = request.getParameter("error");
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

        .sidebar { width: 280px; height: 100vh; background: var(--brand-dark); color: white; position: fixed; display: flex; flex-direction: column; }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { display: flex; align-items: center; padding: 14px 30px; color: #94a3b8; text-decoration: none; transition: 0.2s; border-left: 4px solid transparent; }
        .nav-item:hover, .nav-item.active { background: #1e293b; color: white; border-left-color: var(--brand-primary); }
        
        .content-area { margin-left: 280px; padding: 40px; width: calc(100% - 280px); box-sizing: border-box; }

        .section-card { background: var(--white); border-radius: 12px; border: 1px solid var(--border); margin-bottom: 30px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); overflow: hidden; }
        .card-header { padding: 20px 30px; border-bottom: 1px solid var(--border); background: #f8fafc; display: flex; justify-content: space-between; align-items: center; }
        .card-body { padding: 30px; }

        /* Registry Table Styling */
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 15px 20px; text-align: left; font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; border-bottom: 1px solid var(--border); }
        td { padding: 15px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
        .btn-select { background: var(--brand-primary); color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; cursor: pointer; }

        /* Form Styling */
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
        .full-width { grid-column: span 2; }
        label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 0.875rem; color: var(--brand-dark); }
        input, select { width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; box-sizing: border-box; font-size: 0.95rem; font-family: inherit; }
        input:read-only { background-color: #f8fafc; color: var(--text-muted); cursor: not-allowed; }

        .btn-submit { background-color: var(--brand-primary); color: white; border: none; padding: 14px 28px; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: 0.2s; width: 100%; }
        .btn-submit:disabled { background-color: #cbd5e1; cursor: not-allowed; }

        .alert-error { background-color: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 16px; border-radius: 8px; margin-bottom: 30px; }
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
            <a href="staff_dashboard.jsp" class="nav-item">Operational Overview</a>
            <a href="staff_guest.jsp" class="nav-item">Guest Registration</a> 
            <a href="add_reservation.jsp" class="nav-item active">New Booking</a> 
            <a href="view_reservations.jsp" class="nav-item">Guest Registry</a>
            <a href="view_bills.jsp" class="nav-item">Billing Center</a>
        </nav>
        <a href="LogoutServlet" class="logout-link">Sign Out</a>
    </aside>

    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0; font-size: 1.875rem;">Secure Reservation</h1>
            <p style="color: var(--text-muted);">Step 1: Select a registered guest. Step 2: Finalize booking details.</p>
        </header>

        <% if ("room_taken".equals(error)) { %>
            <div class="alert-error"><strong>⚠️ Room Overlap Conflict:</strong> That room is already reserved for the selected dates.</div>
        <% } %>

        <div class="section-card">
            <div class="card-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Registered Guest Registry</h3>
                <input type="text" id="guestSearch" onkeyup="filterGuests()" placeholder="Search by name or NIC..." style="width:250px; padding:8px;">
            </div>
            <div style="max-height: 250px; overflow-y: auto;">
                <table id="guestTable">
                    <thead>
                        <tr>
                            <th>NIC/ID Number</th>
                            <th>Guest Name</th>
                            <th>Contact</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(Guest g : guestList) { %>
                        <tr>
                            <td><strong><%= g.getIdNumber() %></strong></td>
                            <td><%= g.getName() %></td>
                            <td><%= g.getContactNumber() %></td>
                            <td style="text-align: right;">
                                <button type="button" class="btn-select" 
                                        onclick="selectGuest('<%= g.getIdNumber() %>', '<%= g.getName() %>', '<%= g.getContactNumber() %>', '<%= g.getAddress() %>')">
                                    Add Reservation
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="section-card">
            <div class="card-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Booking Terminal</h3>
            </div>
            <div class="card-body">
                <form action="ReservationServlet" method="post" id="reservationForm">
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label>Selected Guest ID Number</label>
                            <input type="text" id="idNumber" name="idNumber" readonly required placeholder="Select a guest from the table above...">
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
                                    <option value="<%= r.getRoomNumber() %>" data-type="<%= r.getRoomType() %>"
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
                        <button type="submit" id="submitBtn" class="btn-submit" disabled>Process Reservation</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

<script>
// Logic to handle guest selection from the table
function selectGuest(id, name, contact, address) {
    document.getElementById('idNumber').value = id;
    document.getElementById('name').value = name;
    document.getElementById('contact').value = contact;
    document.getElementById('address').value = address;
    
    // Unlock reservation fields
    const fields = ['roomNo', 'checkIn', 'checkOut'];
    fields.forEach(f => document.getElementById(f).disabled = false);
    document.getElementById('submitBtn').disabled = false;
    
    // Scroll to form
    document.getElementById('reservationForm').scrollIntoView({ behavior: 'smooth' });
}

function syncRoomType(select) {
    const selectedOption = select.options[select.selectedIndex];
    document.getElementById('roomType').value = selectedOption.getAttribute('data-type') || "";
}

function filterGuests() {
    let input = document.getElementById("guestSearch"), filter = input.value.toUpperCase();
    let tr = document.getElementById("guestTable").getElementsByTagName("tr");
    for (let i = 1; i < tr.length; i++) {
        let tdName = tr[i].getElementsByTagName("td")[1];
        let tdId = tr[i].getElementsByTagName("td")[0];
        if (tdName || tdId) {
            let match = (tdName.textContent || tdName.innerText).toUpperCase().indexOf(filter) > -1 || 
                        (tdId.textContent || tdId.innerText).toUpperCase().indexOf(filter) > -1;
            tr[i].style.display = match ? "" : "none";
        }
    }
}
</script>
</body>
</html>