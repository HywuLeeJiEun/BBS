<%@page import="sum.Sum"%>
<%@page import="rms.RmsDAO"%>
<%@page import="sum.SumDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>
	<%
	UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
	RmsDAO rms = new RmsDAO();
	SumDAO sumDAO = new SumDAO();
	
	// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	String id = null;
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	if(id == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인이 필요한 서비스입니다.')");
		script.println("location.href='../../login.jsp'");
		script.println("</script>");
	}
		
	// String 가져오기
	String pl = request.getParameter("pl");
	String bbsDeadline = request.getParameter("bbsDeadline");
	String bbsContent = request.getParameter("content");
	String bbsEnd = request.getParameter("end");
	String progress = request.getParameter("progress");
	String statecolor = request.getParameter("color"); //색상 가져오기
	String state = "";
	if(statecolor.equals("rgb(0, 255, 0)")) {
		state = "완료";
	}else if(statecolor.equals("rgb(255, 255, 0)")) {
		state = "진행중";
	} else {
		state = "미완료(문제)";
	}
	String note = request.getParameter("note");
	String bbsNContent = request.getParameter("ncontent");
	String bbsNTarget = request.getParameter("ntarget");
	String nnote = request.getParameter("nnote");
	//String sign = "미승인";
	java.sql.Timestamp summaryDate = rms.getDateNow();
	//pl 리스트 확인
	String work = userDAO.getpl(id); //현재 접속 유저의 pl(web, erp)를 확인함!
	//userName 확인
	String name = userDAO.getName(id);

	
	int num = sumDAO.SummaryWrite(id, bbsDeadline, work, bbsContent, bbsEnd, progress, state, note, bbsNContent, bbsNTarget, nnote, summaryDate, name);
	
	if(num==-1){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('정상적으로 요약본이 제출되었습니다.')");
		script.println("location.href='../summaryRk.jsp'");
		script.println("</script>");
	} 
	%>

	
	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
 	

</body>
</html>