<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Room, com.oceanview.dao.RoomDAO, java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }
    RoomDAO roomDAO = new RoomDAO();
    List<Room> roomList = roomDAO.getAllRooms();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Room Management | Ocean View Resort</title>
   
</head>
<body>
    <div class="container">
        <h2>Ocean View Resort - Room Inventory</h2>
        <a href="add_room.jsp" style="text-decoration: none; color: #007bff;">+ Add New Room</a>
        
        <table>
            <thead>
                <tr>
                    <th>Room No</th>
                    <th>Type</th>
                    <th>Price (LKR)</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for(Room r : roomList) { %>
                <tr>
                    <td><%= r.getRoomNumber() %></td>
                    <td><%= r.getRoomType() %></td>
                    <td><%= String.format("%.2f", r.getPrice()) %></td>
                    <td><%= r.getStatus() %></td>
                    <td>
                        <form action="RoomServlet" method="post" class="action-form" onsubmit="return confirm('Delete this room?')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="roomNo" value="<%= r.getRoomNumber() %>">
                            <button type="submit" class="btn-delete">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <br>
        <a href="admin_dashboard.jsp" style="text-decoration: none; color: #6c757d;">← Back to Dashboard</a>
    </div>
</body>
</html>