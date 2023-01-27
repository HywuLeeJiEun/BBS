<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmssumr.RmssumrDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
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
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)
	
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
	} else {
		
		// String 가져오기
		String pl = request.getParameter("pl");
		String rms_dl = request.getParameter("rms_dl");
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
	
		
		//금주 저장
		int num = sumDAO.SummaryWrite(pl, rms_dl, bbsContent, bbsEnd, progress, state, note, "T", "미승인", summaryDate, id);
		//차주 저장
		int nnum = sumDAO.SummaryWrite(pl, rms_dl, bbsNContent, bbsNTarget, null, null, nnote, "N", "미승인", summaryDate, id);
		//(id, rms_dl, pl, bbsContent, bbsEnd, progress, state, note, bbsNContent, bbsNTarget, nnote, summaryDate, name);
		
		if(num == -1 || nnum == -1){
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
	}
	%>

	
	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
 	

</body>
</html>