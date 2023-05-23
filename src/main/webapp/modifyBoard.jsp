<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.sql.*"%>	
<%
	// 로그인 요청값 검사
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}

	// boardList에서 요청한값
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));

	System.out.println(boardNo + "<--- modifyBoard boardNo");
	System.out.println(boardFileNo + "<--- modifyBoard boardFileNo");

	// db 연동
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
		
	
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "<--- conn");
	
	// 수정모델
	/*	수정쿼리
	select b.board_title boardTitle, f.origin_filename originFilename
	from board b inner join board_file f
	on b.board_no = f.board_no
	order by b.createdate desc
	*/
	String sql="select b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename from board b inner join board_file f on b.board_no = f.board_no WHERE b.board_no = ? and f.board_file_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,boardNo);
	stmt.setInt(2,boardFileNo);
	ResultSet rs = stmt.executeQuery();
		HashMap<String, Object> m = null;
	if(rs.next()) {
		m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
	}
	
	System.out.println(stmt + "<--- modifyBoard stmtl");
	System.out.println(rs + "<--- modifyBoard rs");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<body>
	<div class="container">
	<h1>board & boardFile 수정</h1>
	<a class="btn btn-success" href="<%=request.getContextPath() %>/boardList.jsp">뒤로가기</a>
	<form action="<%=request.getContextPath()%>/modifyBoardAction.jsp" method="post" enctype="multipart/form-data">
		<input type="hidden" name="boardNo" value="<%=(Integer)m.get("boardNo") %>">
		<input type="hidden" name="boardFileNo" value="<%=(Integer)m.get("boardFileNo") %>">
		
		<table class="table table-striped">
			<tr>
				<th>boardTitle</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"><%=m.get("boardTitle") %></textarea>
				</td>
			</tr>
			<tr>
				<th>boardFile(수정전 파일 : <%=m.get("originFilename")%></th>
				<td>
					<input type="file" name="boardFile">
				</td>
			</tr>
		</table>
			<button type="submit">수정</button>
	</form>
	</div>
</body>
</html>