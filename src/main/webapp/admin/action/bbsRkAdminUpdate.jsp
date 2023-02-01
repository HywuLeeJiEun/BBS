<%@page import="rmssumm.RmssummDAO"%>
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
	}
		
	// String 가져오기
	String rms_dl = request.getParameter("rms_dl");
	String sign = request.getParameter("sign");

	//ERP
	String econtent = request.getParameter("econtent");
	String eend = request.getParameter("eend");
	String eprogress = request.getParameter("eprogress");
	String estatecolor = request.getParameter("ecolor");
	String estate = "";
	if(estatecolor.equals("rgb(0, 255, 0)")) {
		estate = "완료";
	}else if(estatecolor.equals("rgb(255, 255, 0)")) {
		estate = "진행중";
	} else {
		estate = "미완료(문제)";
	} 
	String enote = request.getParameter("enote");
	String encontent = request.getParameter("encontent");
	String entarget = request.getParameter("entarget");
	String ennote = request.getParameter("ennote");
	
	//WEB
	String wcontent = request.getParameter("wcontent");
	String wend = request.getParameter("wend");
	String wprogress = request.getParameter("wprogress");
	String wstatecolor = request.getParameter("wcolor");
	String wstate = "";
	if(wstatecolor.equals("rgb(0, 255, 0)")) {
		wstate = "완료";
	}else if(wstatecolor.equals("rgb(255, 255, 0)")) {
		wstate = "진행중";
	} else {
		wstate = "미완료(문제)";
	}
	String wnote = request.getParameter("wnote");
	String wncontent = request.getParameter("wncontent");
	String wntarget = request.getParameter("wntarget");
	String wnnote = request.getParameter("wnnote");
	java.sql.Timestamp summaryDate = rms.getDateNow();
	
	
	//데이터 수정하기 (erp)
		//금주
	int etupdate = sumDAO.updateSum(econtent, eend, eprogress, estate, enote, sign, summaryDate, id, "ERP", rms_dl, "T");
		//차주
	int enupdate = sumDAO.updateSum(encontent, entarget, null, null, ennote, sign, summaryDate, id, "ERP", rms_dl, "N");
	//데이터 수정하기 (web)
		//금주
	int wtupdate = sumDAO.updateSum(wcontent, wend, wprogress, wstate, wnote, sign, summaryDate, id, "WEB", rms_dl, "T");
		//차주
	int wnupdate = sumDAO.updateSum(wncontent, wntarget, null, null, wnnote, sign, summaryDate, id, "WEB", rms_dl, "N");
	
	//int erp = sumDAO.updateSum(bbsDeadline, "ERP", econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, sign, summaryDate, id);
	//int web = sumDAO.updateSum(bbsDeadline, "WEB", wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, summaryDate, id);
	
	
	if(etupdate == -1 || enupdate == -1) { //erp 데이터 저장에 문제 발생!
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('ERP 데이터 저장에 문제가 발생하였습니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else if(wtupdate == -1 || wnupdate == -1) { //web 데이터 저장에 문제 발생!
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('WEB 데이터 저장에 문제가 발생하였습니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else {
		//정상적으로 모두 수정되었을 경우,
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('요약본이 수정이 완료되었습니다.')");
		script.println("location.href='../summaryadRk.jsp'");
		script.println("</script>");
	}
	
	
	%>

 	

</body>
</html>