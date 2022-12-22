<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="bbs.BbsDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="bbs" class="bbs.Bbs" scope="page" />
<jsp:setProperty name="bbs" property="bbsTitle" />
<jsp:setProperty name="bbs" property="bbsManager" />
<jsp:setProperty name="bbs" property="bbsContent" />
<jsp:setProperty name="bbs" property="bbsStart" />
<jsp:setProperty name="bbs" property="bbsTarget" />
<jsp:setProperty name="bbs" property="bbsEnd" />
<jsp:setProperty name="bbs" property="bbsNContent" />
<jsp:setProperty name="bbs" property="bbsNStart" />
<jsp:setProperty name="bbs" property="bbsNTarget" />
<jsp:setProperty name="bbs" property="bbsDeadline" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>
	<%
	UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
	BbsDAO bbsDAO = new BbsDAO();
	
	// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	String id = null;
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	if(id == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인이 필요한 서비스입니다.')");
		script.println("location.href='login.jsp'");
		script.println("</script>");
	}
		
	// String 가져오기
	int sum_id = Integer.parseInt(request.getParameter("sum_id"));
	String pl = request.getParameter("pl");
	String sign = request.getParameter("sign");
	if(sign == null || sign.equals("")) {
		sign = "미승인";
	}
	
	if(sign.equals("승인") || sign.equals("마감")) {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('승인 및 마감 상태에서는 삭제가 불가합니다.')");
		script.println("history.back();'");
		script.println("</script>");
	} else {
	
		int num = bbsDAO.deleteSum(sum_id);
		
		if(num==-1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본(summary)이 삭제 되었습니다.')");
			script.println("location.href='summaryRk.jsp'");
			script.println("</script>");
		}  
	}
	%>

<%-- 	<textarea><%= bbsDeadline %></textarea><br>  --%>
	
	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
 	

</body>
</html>