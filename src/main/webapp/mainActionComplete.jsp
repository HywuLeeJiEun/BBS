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
<jsp:setProperty name="bbs" property="bbsNContent" />
<jsp:setProperty name="bbs" property="bbsNStart" />
<jsp:setProperty name="bbs" property="bbsNTarget" />
<jsp:setProperty name="bbs" property="bbsDeadline" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Baynex-insert</title>
</head>
<body>
	<%
	
		// 현재 세션 상태를 체크한다
		String id = null;
		
		String NContent = null;
		String NStart = null;
		String NTarget = null;
		
		
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		UserDAO userDAO = new UserDAO();
		String pluser = null;
		if(userDAO.getpluserunder(id) != null) { // 비어있지 않다면,
			pluser = userDAO.getpluserunder(id);
		}
			
		// 담을 데이터 가져오기 (get이 없으면 배열, get 이 있다면 string)
		String manager = request.getParameter("manager");
		String title = request.getParameter("title");
		String bbsDeadline = request.getParameter("bbsDeadline");
		String getbbscontent = request.getParameter("getbbscontent");
		String bbsstart = request.getParameter("getbbsstart");
		String bbstarget = request.getParameter("getbbstarget");
		String bbsend = request.getParameter("getbbsend");
		String getbbsncontent = request.getParameter("getbbsncontent");
		String bbsnstart = request.getParameter("getbbsnstart");
		String bbsntarget = request.getParameter("getbbsntarget");
		// String으로 가져옴.
		String numlist = request.getParameter("numlist");
		String nnumlist = request.getParameter("nnumlist");
		
		
		// 배열로 만들기
		String[] numarray = numlist.split("§");
		String[] nnumarray = nnumlist.split("§");
		
		String [] getbbsstart = bbsstart.split("§");
		String [] getbbstarget = bbstarget.split("§");
		String[] getbbsend = bbsend.split("§");
		String[] getbbsnstart = bbsnstart.split("§");
		String[] getbbsntarget = bbsntarget.split("§");
		
		
		
	//금주 업무 실적 줄바꿈
	for(int i=0; i < numarray.length; i++) { //numarray이 개수만큼, (가지고 있는 content의 요소)
		 for(int j=0; j < Integer.parseInt(numarray[i])-1; j++) { //줄바꿈의 개수만큼
				getbbsstart[i] += "\r\n"; // 줄바꿈 추가
				getbbstarget[i] += "\r\n"; // 줄바꿈 추가
				getbbsend[i] += "\r\n"; // 줄바꿈 추가
			}
			
		}
		
		//차주 업무 계획 줄바꿈
		for(int i=0; i < nnumarray.length; i++) { //numarray이 개수만큼, (가지고 있는 content의 요소)
			for(int j=0; j < Integer.parseInt(nnumarray[i])-1; j++) { //줄바꿈의 개수만큼
				getbbsnstart[i] += "\r\n"; // 줄바꿈 추가
				getbbsntarget[i] += "\r\n"; // 줄바꿈 추가
			} 
		} 

		// 모두 String으로 변환
		bbsstart = String.join("\r\n",getbbsstart);
		bbstarget = String.join("\r\n",getbbstarget);
		bbsend = String.join("\r\n",getbbsend);
		
		bbsnstart = String.join("\r\n",getbbsnstart);
		bbsntarget = String.join("\r\n",getbbsntarget); 
		
		
	    // 정상적으로 입력이 되었다면 글쓰기 로직을 수행한다
		BbsDAO bbsDAO = new BbsDAO();
		UserDAO user = new UserDAO();
		String name = user.getName(id);
		
		String dl = bbsDAO.getDL(bbs.getBbsDeadline(), id);
		if(dl != "") {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('해당 날짜로 저장된 주간보고가 있습니다.')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
		} else { 
		
			int result = bbsDAO.write(id, manager, title, name, getbbscontent, bbsstart, bbstarget, bbsend, getbbsncontent, bbsnstart, bbsntarget, bbsDeadline, pluser);
		// 데이터베이스 오류인 경우
		if(result == -1){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스에 오류가 있습니다.')");
			script.println("history.back()");
			script.println("</script>");
		// 글쓰기가 정상적으로 실행되면 알림창을 띄우고 게시판 메인으로 이동한다
		}else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('제출이 완료되었습니다.')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
			} 
		} 
		
	%>


<%-- <a> <%= Arrays.toString(getbbsntarget) %></a>
<a> <%= getbbsnstart.length %></a>
<a> <%= getbbsstart[0] %></a> --%>
<%-- <a> <%= bbsstart %> </a>
<a> <%= bbstarget %> </a>
<a> <%= bbsend %> </a> --%>
<a> <%= getbbscontent %></a>
</body>
</html>