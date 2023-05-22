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
	
	
	// 1) board_title 수정
	int boardNo = Integer.parseInt(mreq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mreq.getParameter("boardFileNo"));
	String boardTitle = mreq.getParameter("boardTitle");
	
	// 디버깅
	System.out.println(boardNo + "<---modifyBoardAction boardNo");
	System.out.println(boardFileNo + "<---modifyBoardAction boardFileNo");
	System.out.println(boardTitle + "<---modifyBoardAction boardTitle");
	
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
	
	// board_title만 변경 쿼리
	String boardSql = "UPDATE board SET board_title = ? WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1,boardTitle);
	boardStmt.setInt(2,boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	if(boardRow == 1) {
		System.out.println("board_title 변경");
	} else {
		System.out.println("board_title변경실패");
	}
	
	
	// 2) 이전 boardFile 삭제, 새로운 boardFile추가 테이블을 수정
	//mreq.getOriginalFileName("boardFile") 값이 null 이면 board테이블에 title만 수정
	if(mreq.getOriginalFileName("boardFile") != null) {
		System.out.println("수정파일있음");
		// 수정할 파일이 있으면 pdf파일인지 유효성 검사 pdf파일이 아니면 삭제
		if(mreq.getContentType("boardFile").equals("application/pdf") == false) {
			System.out.println("pdf파일이 아닙니다");
			String saveFilename = mreq.getOriginalFileName("boardFile");
			File f = new File(dir + "\\" + saveFilename); // new File 경로(dir) + "/" + 저장파일이름(?)
			
			// f.객체 안에 dir + "\\" + saveFilename 이 없다면 삭제
			if(f.exists()) {
				f.delete();
				System.out.println(dir + "\\" + saveFilename + "파일삭제완료");
			}
		} else { // pdf파일이면 이전파일은 삭제후 db수정
			String type = mreq.getContentType("boardFile");
			String originFilename = mreq.getOriginalFileName("boardFile");
			String saveFilename = mreq.getFilesystemName("boardFile");
			
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			// 이전파일 삭제
			String saveFilenameSql=" SELECT save_filename FROM board_file WHERE board_file_no = ?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String preSaveFilename = "";
			if(saveFilenameRs.next()){
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			
			File f = new File(dir + "/" + preSaveFilename);
			if(f.exists()) {
				f.delete();
			}
			// 수정된 파일의 정보로 db수정
			String boardFileSql = "UPDATE board_file SET origin_filename = ?, save_filename = ? WHERE board_file_no = ?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			int boardFileRow = boardFileStmt.executeUpdate();
			
			if(boardFileRow == 1) {
				System.out.println("board_file 변경완료");
			} else {
				System.out.println("board_file 변경실패");
			}
		}
	}
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");	
%>

