<%@page import="java.nio.file.Path"%>
<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="vo.*" %>
<%@ page import="java.io.*" %>
<%
	// 프로젝트아에 upload폴더의 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 1024 * 1024 * 100; // 파일최대사이즈 100Mbyte 
	
	// 원본 request를 객체를 cos api로 랩핑
	// new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	// MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다.
	
	// 업로드 파일의 type이 pdf파일이 아니면 return
	if(mreq.getContentType("boardFile").equals("application/pdf") == false) {
		// 이미 저장된 파일을 삭제
		System.out.println("pdf파일이 아닙니다");
		String saveFilename = mreq.getOriginalFileName("boardFile");
		File f = new File(dir + "\\" + saveFilename); // new File 경로(dir) + "/" + 저장파일이름(?)
		
		// f.객체 안에 dir + "\\" + saveFilename 이 없다면 삭제
		if(f.exists()) {
			f.delete();
			System.out.println(dir + "\\" + saveFilename + "파일삭제완료");
		}
		response.sendRedirect(request.getContextPath() +"/addBoard.jsp");
		return;
	}
	
	// 1) input type="text" 값반환 API
	String boardTitle = mreq.getParameter("boardTitle");
	String memberId = mreq.getParameter("memberId");
	
	System.out.println(boardTitle + "<--- boardTitle");
	System.out.println(memberId + "<--- memberId");
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	System.out.println(board.getBoardTitle() + "<--- board.getBoardTitle");
	System.out.println(board.getMemberId() + "<--- board.getMemberId");
	
	// 2) input type="file" 값(파일 메타 정보)반환 API(원본파일이름, 저장된파일이름, 컨텐츠타입)
	// --> board_file테이블 저장
	// 파일(바이너리)은 이미 MultipartRequest객체생성시(request랩핑시, 9라인) 먼저 저장
	String type = mreq.getContentType("boardFile");
	String originFilename = mreq.getOriginalFileName("boardFile");
	String saveFilename = mreq.getFilesystemName("boardFile");
	
	System.out.println(type + "<--- type");
	System.out.println(originFilename + "<--- originFilename");
	System.out.println(saveFilename + "<--- saveFilename");
	
	BoardFile boardFile = new BoardFile();
	// boardFile.setBoardNo(boardNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	System.out.println(boardFile.getType() + "<--- boardFile.getType");
	System.out.println(boardFile.getOriginFilename() + "<--- boardFile.getOriginFilename");
	System.out.println(boardFile.getSaveFilename() + "<--- boardFile.getSaveFilename");
	
	/*	board쿼리
		INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES(?, ?, now(), now())
		
		board_file쿼리
		INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate) VALUES(?, ?, ?, ?, ?, now())
	
		INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
		String sql = "INSERT 쿼리문";
		pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row = pstmt.executeUpdate(); // insert 쿼리 실행
		ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select쿼리를 진행
		int keyValue = 0;
		if(keyRs.next()){
			keyValue = rs.getInt(1);
	*/
	
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
	
	String boardSql="INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES(?, ?, now(), now())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	boardStmt.executeUpdate(); // board입력 후 키값저장
	
	// 생성된 키값 자동으로받아옴
	ResultSet keyRs = boardStmt.getGeneratedKeys();
	
	int boardNo = 0;
	if(keyRs.next()) {
		boardNo = keyRs.getInt(1);
	}
	
	String fileSql="INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', now())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	
	fileStmt.executeUpdate(); // board_file입력
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	
	
%>
