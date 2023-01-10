<%@page import="java.util.Arrays"%>
<%@page import="java.util.Calendar"%>
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

	String a = request.getParameter("a");
	
	String[] b = a.split("\r\n");
	
	%>
<form action="test_submit.jsp" method="post">
<textarea wrap="hard"><%= a %></textarea>
<input type="submit">
</form>
<br>
<a><%= b.length %></a>
<br>

<%
	for(int i=0; i < b.length; i++) {
%>
	<a><%= b[i] %></a><br>
<% 
	}
%>

</body>
</html>