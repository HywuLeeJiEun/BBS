<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="bbs.Bbs"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<% request.setCharacterEncoding("utf-8"); %>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<title>Baynex 주간보고</title>
</head>
<body id="weekreport">
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="css/js/bootstrap.js"></script>



		<%
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		int pageNumber = 1; //기본은 1 페이지를 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'pageNumber'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'pageNumber'변수에 저장한다
		if(request.getParameter("pageNumber") != null){
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		int bbsID = 1;
		
		// 유효한 글이라면 구체적인 정보를 'bbs'라는 인스턴스에 담는다
				BbsDAO bbsDAO = new BbsDAO();
				
				UserDAO user = new UserDAO();
				
				
				String del = bbsDAO.getActionDeleteCheck(bbsID);
				//수정자가 있는지 확인함.
				int active = bbsDAO.getActive(bbsID); // 0이라면 없음, 1이라면 있음! (수정자가)
				if(active == 0) {
					bbsDAO.getActiveplus(1, bbsID); //숫자를 1로 변경함.
				} else if (active == -1){
					bbsDAO.getActiveRow(bbsID); //row를 추가하며 active를 1로 변경함.
				}else { // 1이거나, -1 일때,
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('현재 다른 사용자가 수정중입니다.')");
					script.println("history.back()");
					script.println("</script");
				}

	%>
	
	

<a><%= active %></a>
<a>(<%= del %>)</a>


</body>
</html>