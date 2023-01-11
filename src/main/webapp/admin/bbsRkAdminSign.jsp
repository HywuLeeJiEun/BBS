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
	String sign = "승인";
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
	
	//sumad_id 구하기
	int sumad_id = Integer.parseInt(bbsDAO.getSumAdminid(bbsDeadline));
	java.sql.Timestamp SumadDate = bbsDAO.getDateNow();
	String sumadUpdate = bbsDAO.name(id);
	
	int erp = bbsDAO.updateSum(esum_id, econtent, eend, eprogress, estate, enote, encontent, entarget, bbsDeadline, ennote, sign, SumadDate, sumadUpdate);
	int web = bbsDAO.updateSum(wsum_id, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, bbsDeadline, wnnote, sign, SumadDate, sumadUpdate);
	
	int num = bbsDAO.SummaryAdminUpdate(sumad_id,econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, bbsDeadline, SumadDate);
	
	if(num==-1){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('정상적으로 요약본(summary)이 저장 되었습니다.')");
		script.println("location.href='summaryadRk.jsp'");
		script.println("</script>");
	} 
	%>
	<%-- <textarea> <%= estatecolor %></textarea><br> 
	1<textarea> <%= bbsDeadline %></textarea><br> 
	2<textarea> <%= sign %></textarea><br> 
	3<textarea> <%= econtent %></textarea><br> 
	4<textarea> <%= eend %></textarea><br> 
	5<textarea> <%= eprogress  %></textarea><br> 
	6<textarea> <%= estate  %></textarea><br>
	7<textarea> <%= enote  %></textarea><br> 
	8<textarea> <%=  encontent %></textarea><br> 
	9<textarea> <%= entarget  %></textarea><br> 
	10<textarea> <%= ennote  %></textarea><br> 
	11<textarea> <%= wcontent  %></textarea><br> 
	12<textarea> <%= wend  %></textarea><br> 
	13<textarea> <%=  wprogress %></textarea><br> 
	14<textarea> <%= wstate  %></textarea><br> 
	15<textarea> <%=  wnote %></textarea><br> 
	16<textarea> <%=  wncontent %></textarea><br> 
	17<textarea> <%= wntarget  %></textarea><br> 
	18<textarea> <%= wnnote  %></textarea><br>  --%>
	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
 	

</body>
</html>