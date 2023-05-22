<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.*" %>
<%@page import="java.sql.*"%>
<%@ page import="vo.*" %>

<%
	//프로젝트아에 upload폴더의 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 1024 * 1024 * 100; // 파일최대사이즈 100Mbyte 
	
	// 원본 request를 객체를 cos api로 랩핑
	// new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	// 요청값 변수
	int boardNo = Integer.parseInt(mreq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mreq.getParameter("boardFileNo"));
	
	// 디버깅
	System.out.println(boardNo + "<--- removeBoardAction boardNo");
	System.out.println(boardFileNo + "<--- removeBoardAction boardFileNo");
	
	//db 연동
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
		
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn + "<--- conn");

    // 삭제할 boardFile의 정보를 가져옴 
    // upload 폴더에 있는 파일이름은 save파일이기에 지워야할save_filename을 불러옴
    String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
    PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
    saveFilenameStmt.setInt(1, boardFileNo);
    ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
    
    // 지울 파일 변수선언
    String preSaveFilename = "";
    if (saveFilenameRs.next()) {
        preSaveFilename = saveFilenameRs.getString("save_filename");
    }

    // saveFilename를 삭제 하기위해 ioAPI에 있는 File 클래스 불러옴
    File f = new File(dir + "/" + preSaveFilename);
    if (f.exists()) {
        f.delete();
    }
	
	 // board 테이블에서 해당 board를 삭제
    String delBoardSql = "DELETE FROM board WHERE board_no = ?";
    PreparedStatement delBoardStmt = conn.prepareStatement(delBoardSql);
    delBoardStmt.setInt(1, boardNo);
	System.out.println(delBoardStmt + "<--- removeBoardAction delBoardStmt");
	
    int delRow = delBoardStmt.executeUpdate();

    if(delRow == 1) {
    	System.out.println("삭제완료");
    	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
    } else {
    	System.out.println("삭제실패");
    }
    
%>

