<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<div class="container">
	<h1>로그인 창</h1>
	<a class="btn btn-success" href="<%=request.getContextPath() %>/boardList.jsp">리스트보기</a>
	<%
		if(session.getAttribute("loginMemberId") == null) {
	%>
			<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
				<table class="table table-bordered">
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
	</div>
</body>
</html>