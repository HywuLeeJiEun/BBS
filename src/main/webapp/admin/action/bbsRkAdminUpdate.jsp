<%@page import="sum.SumDAO"%>
<%@page import="rms.RmsDAO"%>
<%@page import="Sumad.Sumad"%>
<%@page import="Sumad.SumadDAO"%>
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
	SumadDAO sumadDAO = new SumadDAO();
	
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
	String bbsDeadline = request.getParameter("bbsDeadline");
	String sign = request.getParameter("sign");
	if(sign.equals("보류")) {
		sign = "미승인";
	} 
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
	String summaryUpdate = userDAO.getName(id);
	
	//이동을 위함
	ArrayList<Sumad> afsumad = sumadDAO.getlistSumSign(); //미승인 상태만 불러옴!
	
	int erp = sumDAO.updateSum(bbsDeadline, "ERP", econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, sign, summaryDate, summaryUpdate);
	int web = sumDAO.updateSum(bbsDeadline, "WEB", wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, summaryDate, summaryUpdate);
	
	int num= -1;
	
	//sumad <- (summary_admin)에 저장되었는지 확인함!
	ArrayList<Sumad> sumad = sumadDAO.getlistSumad(bbsDeadline);
	
	if(sumad.size() == 0) { //데이터가 없기 때문에 저장!  (insert)
		num = sumadDAO.SummaryAdminWrite(id, bbsDeadline, econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, summaryDate, summaryUpdate);
		if(num==-1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else { 
			if(afsumad.size() == 0) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('정상적으로 요약본이 저장 되었습니다.')");
				script.println("alert('요약본이 모두 승인 처리 되었습니다. 조회페이지로 이동합니다.')");
				script.println("location.href='../summaryadRk.jsp'");
				script.println("</script>");
			} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본이 저장 되었습니다.')");
			script.println("location.href='../summaryadUpdateDelete.jsp'");
			script.println("</script>");
			}
		} 
	} else { //데이터가 이미 있으므로 수정! (update)  //sumad가 이미 저장됨
		num = sumadDAO.SummaryAdminUpdate(bbsDeadline, econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, summaryDate, userDAO.getName(id));
		if(num==-1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			if(afsumad.size() == 0) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('정상적으로 요약본이 저장 되었습니다.')");
				script.println("alert('요약본이 모두 승인 처리 되었습니다. 조회페이지로 이동합니다.')");
				script.println("location.href='../summaryadRk.jsp'");
				script.println("</script>");
			} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본이 저장 되었습니다.')");
			script.println("location.href='../summaryadUpdateDelete.jsp'");
			script.println("</script>");
			}
		} 
	} 
	
	
	%>

 	

</body>
</html>