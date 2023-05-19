<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%
	request.setCharacterEncoding("utf-8");
	
	// 세션 유효성검사
	if(session.getAttribute("loginMemeberId") != null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}
	
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	
	System.out.println(memberId + "<--- stmt memberId");
	System.out.println(memberPw + "<--- stmt memberPw");
	
	//db 연동
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
		
	// db연동 변수
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "<--- conn");
	
	String sql="";
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	/* 쿼리문
		select member_id memberId, from member where member_id = ? and member_pw = PASSWORD(?)
	*/
	sql = "select member_id memberId from member where member_id = ? and member_pw = PASSWORD(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	rs = stmt.executeQuery();
	
	System.out.println(stmt + "<--- stmt loginAction");
	System.out.println(rs + "<--- rs loginAction");
	
	if(rs.next()) { // 로그인 성공
		session.setAttribute("loginMemberId", rs.getString("memberId"));
		System.out.println("로그인 성공 세션정보 :" + session.getAttribute("loginMemberId") + "<--- loginAction");
	} else { // 로그인 실패
		System.out.println("로그인 실패 <--- loginAction");
	}
	
	response.sendRedirect(request.getContextPath()+"/login.jsp");
%>
