<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.sql.*"%>
<%
	System.out.println("boardList");
	
	// 현재페이지 변수 및 요청값분석
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
		
	// db 연동
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "<--- conn");
	
	// 1)전체행개수 구하는 모델
	int totalRow = 0;
	String totalRowSql = " select count(*) from board";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	
	// 한페이지당 보여줄 행 개수
	int rowPerPage = 10;
	// 처음 출력될 행번호
	int beginRow = (currentPage -1) * rowPerPage +1;
	// 마지막 행번호
	int endRow = beginRow + (rowPerPage -1);

	if(endRow > totalRow) {
		endRow = totalRow;
	}
	
	System.out.println(totalRow + "<--- boardList totalRow");
	
	// 2) 리스트 모델
	/*	
		select b.board_title boardTitle, f.origin_filename originFilename
		from board b inner join board_file f
		on b.board_no = f.board_no
		order by b.createdate desc
	*/
	String sql="select b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.path path from board b inner join board_file f on b.board_no = f.board_no order by b.createdate desc limit ?, ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,beginRow);
	stmt.setInt(2,rowPerPage);
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
	
	System.out.println(stmt + "<--- boardList stmt");
	System.out.println(rs + "<--- boardList rs");
	System.out.println(list.size() + "<--- boardList list.size");
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
	<h1>목록</h1>
	<a class="btn btn-success" href="<%=request.getContextPath() %>/login.jsp">로그인 창</a>
	
	<%	// 로그인 한사람만 리스트 추가할 수 있도록
		if(session.getAttribute("loginMemberId") != null) {
	%>
			<a class="btn btn-info" href="<%=request.getContextPath() %>/addBoard.jsp">리스트 추가</a>
	
	<% 	}
	%>
	<!--  로그인 안해도 리스트는 볼 수 있고 다운도가능 -->
	<table class="table table-bordered">
		<tr>
			<td>board_title</td>
			<td>originFilename</td>
			<td>수정</td>
			<td>삭제</td>
			
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
					// 로그인한 사용자만 수정삭제 가능하도록
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
		<% 	
			// 페이지 네비게이션 페이징
			// 이전 1,2,3,4,5,6,7,8,9,10 다음 -> 이렇게 페이징할 수 있도록 값 구하기
			int pagePerPage = 10;
			/*	cp	minPage		maxPage
				1		1	~	10
				2		1	~	10
				10		1	~	10
				
				11		11	~	20
				12		11	~	20
				20		11	~	20
				
				((cp-1) / pagePerPage) * pagePerPage + 1 --> minPage
				minPage + (pagePerPgae -1) --> maxPage
				maxPage > lastPage --> maxPage = lastPage;
			*/
			// 마지막 페이지 구하기
			int lastPage = totalRow / rowPerPage;
			if(totalRow / rowPerPage != 0) {
				lastPage = lastPage+1;
			}
			// 최소페이지,최대페이지 구하기
			int minPage = ((currentPage-1) / pagePerPage) * pagePerPage + 1;
			int maxPage = minPage + (pagePerPage -1);
			if(maxPage > lastPage) {
				maxPage = lastPage;
			}
		%>
		
		<!-- 페이징 부분 -->
		<% 
			//  최소페이지가 1보다 작으면 아무것도 없다
			if(minPage > 1) {
		%>
				<!-- 이전페이지 -->
				<a href="<%=request.getContextPath() %>/boardList.jsp?currentPage=<%=minPage - pagePerPage%>">이전</a>
		<% 
			}
			// i = minPage, maxPage = 10//  1 <= 10   --> i++
			for(int i = minPage; i <= maxPage; i=i+1) {
				if(i == currentPage){
		%>
					<span style="color: red;"><%=i %></span>
		<% 
				} else {
		%>
				<!--  1~10, 11~20... 페이지 출력 -->
				<a href="<%=request.getContextPath() %>/boardList.jsp?currentPage=<%=i%>"><%=i %></a>	
		<%
				}
			}
			// maxPage가 마지막페이지랑 다르면 다음 10페이지 뒤로보낸다
			if(maxPage != lastPage){
		%>
				<!--  다음페이지 maxPage+1을해도 아래와 같다 -->
				<a href="<%=request.getContextPath() %>/boardList.jsp?currentPage=<%=minPage + pagePerPage%>">다음</a>
		<% 	}
		%>
	</div>	
</body>
</html>