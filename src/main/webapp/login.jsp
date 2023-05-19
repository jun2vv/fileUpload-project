<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>로그인 창</h1>
	<a href="<%=request.getContextPath() %>/boardList.jsp">리스트보기</a>
	<%
		if(session.getAttribute("loginMemberId") == null) {
	%>
			<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
				<table>
					<tr>
						<th>아이디</th>
						<td>
							<input type="text" name="memberId">
						</td>
					</tr>
					<tr>
						<th>비밀번호</th>
						<td>
							<input type="password" name="memberPw">
						</td>
					</tr>
				</table>
				<button type="submit">로그인</button>
			</form>	
	<% 	
		} else {
	%>
			<h2><%=session.getAttribute("loginMemberId")%>님</h2>
	<% 		
		}
	%>
</body>
</html>