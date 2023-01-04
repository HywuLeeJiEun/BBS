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
	String bbsDeadline = request.getParameter("bbsDeadline");
	String sign = request.getParameter("sign");
	//ERP
	int esum_id = Integer.parseInt(request.getParameter("esum_id"));
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
	int wsum_id = Integer.parseInt(request.getParameter("wsum_id"));
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
	java.sql.Timestamp SummaryDate = bbsDAO.getDateNow();
	String summaryUpdate = bbsDAO.name(id);
	
	
	int erp = bbsDAO.updateSum(esum_id, econtent, eend, eprogress, estate, enote, encontent, entarget, bbsDeadline, ennote, sign, SummaryDate, summaryUpdate);
	int web = bbsDAO.updateSum(wsum_id, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, bbsDeadline, wnnote, sign, SummaryDate, summaryUpdate);
	
	int num= -1;
	
	String sumad_id = bbsDAO.getSumAdminid(bbsDeadline);
	java.sql.Timestamp SumadDate = bbsDAO.getDateNow();
	String sumadUpdate = bbsDAO.name(id);
	
	if(sumad_id.equals("")) { //데이터가 없기 때문에 저장!  (insert)
		sign = "미승인";
		num = bbsDAO.SummaryAdminWrite(econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, bbsDeadline, SumadDate, sumadUpdate);
		if(num==-1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본이 저장 되었습니다.')");
			script.println("location.href='summaryadRk.jsp'");
			script.println("</script>");
		} 
	} else { //데이터가 이미 있으므로 수정! (update)
		num = bbsDAO.SummaryAdminUpdate(Integer.parseInt(sumad_id), econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, bbsDeadline, SumadDate);
		if(num==-1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본이 수정 되었습니다.')");
			script.println("location.href='summaryadRk.jsp'");
			script.println("</script>");
		} 
	} 
	
	
	%>
	<textarea><%=  summaryUpdate %></textarea>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
 	

</body>
</html>