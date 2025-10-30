<%@ page import="java.sql.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Processing Borrow Request</title>
    <link rel="stylesheet" href="style.css" />
  </head>
  <body>
    <div class="top-div">
      <div class="logo">Community Library</div>
      <nav class="nav">
        <a href="index.html">Home</a>
        <a href="books.jsp">Available Books</a>
        <a href="borrow.html" class="active">Borrow</a>
      </nav>
    </div>

    <div class="info-div">
      <div class="container">
        <%
          request.setCharacterEncoding("UTF-8");

          String name = request.getParameter("fullName");
          String email = request.getParameter("email");
          String bookIdStr = request.getParameter("bookId");
          String borrowDate = request.getParameter("borrowDate");

          // Validate inputs
          if (name == null || email == null || bookIdStr == null || borrowDate == null ||
              name.trim().isEmpty() || email.trim().isEmpty() || bookIdStr.trim().isEmpty() || borrowDate.trim().isEmpty()) {
        %>
            <h3>Missing Data</h3>
            <p>All fields are required. <a href="borrow.html">Go back</a></p>
        <%
            return;
          }

          int bookId = -1;
          try {
            bookId = Integer.parseInt(bookIdStr.trim());
          } catch (NumberFormatException nfe) {
        %>
            <h3>Invalid Book ID</h3>
            <p>Book ID must be numeric. <a href="borrow.html">Go back</a></p>
        <%
            return;
          }

          // Database info (UPDATE THESE!)
          String url = "jdbc:mysql://localhost:3306/library_db?useSSL=false&allowPublicKeyRetrieval=true";
          String user = "root";        // ✅ Your MySQL username
          String password = "root123"; // ✅ Your MySQL password

          Connection conn = null;
          PreparedStatement pstmt = null;
          ResultSet rs = null;

          try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            // 1️⃣ Check if book exists and is available
            String checkQuery = "SELECT Status FROM books WHERE BookID = ?";
            pstmt = conn.prepareStatement(checkQuery);
            pstmt.setInt(1, bookId);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
        %>
              <h3>Book Not Found</h3>
              <p>No book with ID <%= bookId %> exists. <a href="borrow.html">Go back</a></p>
        <%
            } else {
              String status = rs.getString("Status");

              if (!"Available".equalsIgnoreCase(status != null ? status : "")) {
        %>
                <h3>Book Not Available</h3>
                <p>
                  Book ID <%= bookId %> is currently "<%= status %>".
                  <a href="books.jsp">View books</a>
                </p>
        <%
              } else {
                rs.close();
                pstmt.close();

                // 2️⃣ Update book status
                String updateQuery = "UPDATE books SET Status = 'Borrowed' WHERE BookID = ?";
                pstmt = conn.prepareStatement(updateQuery);
                pstmt.setInt(1, bookId);
                int rowsUpdated = pstmt.executeUpdate();

                if (rowsUpdated > 0) {
        %>
                  <h3>Success!</h3>
                  <p>
                    Book ID <%= bookId %> has been marked as
                    <strong>Borrowed</strong>. Thank you,
                    <%= StringEscapeUtils.escapeHtml4(name) %>.
                  </p>
                  <p><a href="books.jsp">View Books</a></p>
        <%
                  // 3️⃣ Log borrow request
                  try (PreparedStatement logStmt = conn.prepareStatement(
                        "INSERT INTO borrow_requests (BookID, FullName, Email, BorrowDate, RequestedAt) VALUES (?, ?, ?, ?, NOW())")) {
                    logStmt.setInt(1, bookId);
                    logStmt.setString(2, name);
                    logStmt.setString(3, email);
                    logStmt.setString(4, borrowDate);
                    logStmt.executeUpdate();
                  } catch (Exception ex2) { /* optional logging */ }
                } else {
        %>
                  <h3>Update Failed</h3>
                  <p>Could not update status. Try again. <a href="borrow.html">Go back</a></p>
        <%
                }
              }
            }
          } catch (Exception ex) {
        %>
            <h3>Error</h3>
            <p>Exception: <%= ex.getMessage() %></p>
        <%
          } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
          }
        %>
      </div>
    </div>
  </body>
</html>
