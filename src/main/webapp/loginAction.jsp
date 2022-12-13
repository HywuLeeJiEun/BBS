<%@page import="bbs.BbsDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="user.UserDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="user" class="user.User" scope="page" />
<!-- login post로부터 받아옴. -->
<jsp:setProperty name="user" property="id" />
<jsp:setProperty name="user" property="password" />
<%-- <jsp:setProperty name="user" property="name" /> --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>baynex-login</title>
</head>
<body>
	<%
		/* ********* 세션(session)을 통한 클라이언트 정보 관리 ********* */
		// 현재 세션 상태를 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인 완료시, 재로그인이 불가하게 함!
		if(id != null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('현재 로그인 중입니다.')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
		}
	
		
		// ************** 로그인을 담당하는 JSP 페이지 ***************
		UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
		BbsDAO bbsDAO = new BbsDAO();
		
		// DAO 내의 메소드를 실행시킴.
		int result = userDAO.login(user.getId(), user.getPassword());
		// bbs 이력을 확인해 보이는 페이지를 다르게 함.
		// int confirm = bbsDAO.getBbsRecord(session.getAttribute("id"));
		
		
		// 로그인 결과에 따른 반환값 설정 (1 - 성공, 0 - 틀림, -1 - 존재하지 않음. -2 - DB에러)
		if(result == 1){
			// 로그인에 성공하면 세션을 부여한다. 
			session.setAttribute("id", user.getId());
			//session.setMaxInactiveInterval(60 * 60); 
			
			
			// bbs 이력 확인
			int confirm = bbsDAO.getBbsRecord((String)session.getAttribute("id"));
			
			if(confirm == 1) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("location.href='bbs.jsp'");
				script.println("</script>");
			} else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("location.href='bbs.jsp'");
				script.println("</script>");
			}
		}else if(result == 0){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('비밀번호가 다릅니다. 확인해주십시오.')");
			script.println("history.back()");
			script.println("</script>");
			
		}else if(result == -1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('아이디가 존재하지 않습니다.')");
			script.println("history.back()");
			script.println("</script>");
			
		}else if(result == -2){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다.')");
			script.println("history.back()");
			script.println("</script>");
		}
	%>
	
</body>
</html>