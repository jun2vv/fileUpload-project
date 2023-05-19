<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>addBoard + file</title>
</head>
<body>
	<h1>자료 업로드</h1>
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" method = "post" enctype="multipart/form-data">
		<table>
			<!-- 자료 업로드 게시글 -->
			<tr>
				<th>board_title</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>
				</td>
			</tr>
			<!-- 로그인 아이디 -->
			<%
				String memberId = (String)session.getAttribute("loginMemberId");
			%>
			<tr>
				<th>member_id</th>
				<td>
					<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">
				</td>
			</tr>
			<!-- 파일 추가 -->
			<tr>
				<th>boardFile</th>
				<td>
					<!-- multple로 보내면 다수파일을 보낼 수 있지만 받아올때 배열을만들어 받아야한다 타입이 파일이면 복잡하다.  -->
					<input type="file" name="boardFile" required="required">
				</td>
			</tr>
		</table>
		<button type="submit">자료업로드</button>
	</form>
</body>
</html>