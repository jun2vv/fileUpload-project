<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.sql.*"%>
<%
	System.out.println("boardList");

	// 페이징구현및 요청값분석
	int currentPage = 1;
	
		
	// db 연동
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
		
	// db연동 변수
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "<--- conn");
	
	/*	
		select b.board_title boardTitle, f.origin_filename originFilename
		from board b inner join board_file f
		on b.board_no = f.board_no
		order by b.createdate desc
	*/
	String sql="select b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.path path from board b inner join board_file f on b.board_no = f.board_no order by b.createdate desc";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>목록</h1>
	<a href="<%=request.getContextPath() %>/login.jsp">로그인 창</a>
	
	<%	// 로그인 한사람만 리스트 추가할 수 있도록
		if(session.getAttribute("loginMemberId") != null) {
	%>
			<a href="<%=request.getContextPath() %>/addBoard.jsp">리스트 추가</a>
	
	<% 	}
	%>
	<!--  로그인 안해도 리스트는 볼 수 있고 다운도가능 -->
	<table>
		<tr>
			<td>board_title</td>
			<td>originFilename</td>
			
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
				
		%>
				<tr>
					<td><%=(String)m.get("boardTitle") %></td>
					<td>
						<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
							<%=(String)m.get("originFilename") %>
						</a>
					</td>
				<%
					if(session.getAttribute("loginMemberId") != null) {
						
				%>
					<td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a></td>
					<td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
				<% 	}
				%>
				</tr>
		<% 	}
		%>
		
	</table>
</body>
</html>