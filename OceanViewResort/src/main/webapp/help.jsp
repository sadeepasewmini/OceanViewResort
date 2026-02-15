<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // 1. Session Access Control
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Help Center | Ocean View Resort</title>
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
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-canvas); 
            margin: 0; 
            display: flex; 
            color: var(--text-main); 
        }

        /* Sidebar Navigation Container */
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
        
        /* Layout Content Area */
        .content-area { 
            margin-left: 280px; 
            padding: 40px; 
            width: 100%; 
            box-sizing: border-box; 
        }

        /* Knowledge Base Components */
        .search-section { 
            background: var(--white); 
            padding: 30px; 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            margin-bottom: 30px; 
            text-align: center; 
        }
        
        #help-search { 
            width: 60%; 
            padding: 14px 20px; 
            border: 1.5px solid var(--border); 
            border-radius: 10px; 
            font-size: 0.95rem; 
            outline: none; 
            transition: 0.2s; 
        }
        #help-search:focus { border-color: var(--brand-primary); box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1); }

        .help-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }
        .help-card { 
            background: var(--white); 
            padding: 25px; 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            transition: 0.2s; 
            border-top: 4px solid var(--brand-primary); 
        }
        .help-card:hover { transform: translateY(-4px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
        .badge { background: #eff6ff; color: var(--brand-primary); padding: 5px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        
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
            <h1 style="margin:0; font-size: 1.875rem;">Staff Knowledge Base</h1>
            <p style="color: var(--text-muted);">Operational guidelines for the Ocean View Management System.</p>
        </header>

        <div class="search-section">
            <input type="text" id="help-search" placeholder="Search operational guidelines (e.g. 'check-in', 'mysql')...">
        </div>

        <div id="help-container" class="help-grid">
            </div>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Updated documentation mapping aligned with resort project
            const helpData = [
                { cat: "Security", title: "Authentication", desc: "Sessions are role-based. Admins manage inventory; Staff focus on guest check-ins." },
                { cat: "Database", title: "Reservation Records", desc: "All data is saved to MySQL. Ensure legal name and residential address accuracy." },
                { cat: "Operations", title: "Room Assignment", desc: "Select units from live inventory. Booking a room automatically updates status to 'Occupied'." },
                { cat: "Finance", title: "Billing Calculations", desc: "Totals are generated via (Price per Night × Stay Duration). Update 'Payment Status' upon settlement." },
                { cat: "Troubleshooting", title: "Connectivity Issues", desc: "If database errors occur, verify that your local MySQL server service is active." }
            ];

            const container = document.getElementById("help-container");
            const searchInput = document.getElementById("help-search");

            function renderHelp(data) {
                container.innerHTML = "";
                if(data.length === 0) {
                    container.innerHTML = "<p style='grid-column: 1/-1; text-align:center; color:var(--text-muted);'>No matching support documents found.</p>";
                    return;
                }
                data.forEach(item => {
                    const card = document.createElement("div");
                    card.className = "help-card";
                    card.innerHTML = `<span class="badge">${item.cat}</span><h3 style="margin-top:15px; font-size:1.1rem;">${item.title}</h3><p style="color:var(--text-muted); font-size:0.9rem; line-height:1.6;">${item.desc}</p>`;
                    container.appendChild(card);
                });
            }

            renderHelp(helpData);

            searchInput.addEventListener("keyup", (e) => {
                const term = e.target.value.toLowerCase();
                const filtered = helpData.filter(i => 
                    i.title.toLowerCase().includes(term) || 
                    i.cat.toLowerCase().includes(term) || 
                    i.desc.toLowerCase().includes(term)
                );
                renderHelp(filtered);
            });
        });
    </script>
</body>
</html>