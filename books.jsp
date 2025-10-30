<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Community Library - Available Books</title>
    <link rel="stylesheet" href="style.css" />
</head>
<body>
    <div class="top-division">
        <nav>
            <a href="index.html">Home</a>
            <a href="books.jsp" class="active">Available Books</a>
            <a href="borrow.html">Borrow</a>
        </nav>
    </div>

    <div class="information-division">
        <h2>Available Books</h2>

        <table class="books-table">
            <thead>
                <tr>
                    <th>Book ID</th>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Genre</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Database connection variables
                    String dbUrl = "jdbc:mysql://localhost:3306/library_db";
                    String dbUser = "root";
                    String dbPass = "root123";

                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;

                    try {
                        // 1. Load the JDBC driver
                        Class.forName("com.mysql.cj.jdbc.Driver");

                        // 2. Establish connection
                        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                        // 3. Create a statement
                        stmt = conn.createStatement();

                        // 4. Execute the query
                        String sql = "SELECT * FROM books";
                        rs = stmt.executeQuery(sql);

                        // 5. Loop through the result set
                        while (rs.next()) {
                            String status = rs.getString("Status");
                            String cssClass = status.equalsIgnoreCase("Available")
                                              ? "status-available"
                                              : "status-borrowed";
                %>
                            <tr>
                                <td><%= rs.getInt("BookID") %></td>
                                <td><%= rs.getString("Title") %></td>
                                <td><%= rs.getString("Author") %></td>
                                <td><%= rs.getString("Genre") %></td>
                                <td class="<%= cssClass %>"><%= status %></td>
                            </tr>
                <%
                        } // End of while loop
                    } catch (Exception e) {
                %>
                            <tr>
                                <td colspan="5">Error connecting to database: <%= e.getMessage() %></td>
                            </tr>
                <%
                    } finally {
                        // 6. Close resources
                        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
                        if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
                        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                    }
                %>
            </tbody>
        </table>
    </div>
</body>
</html>
