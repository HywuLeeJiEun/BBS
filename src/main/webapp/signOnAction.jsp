<%@page import="java.io.PrintWriter"%>
<%@page import="bbs.BbsDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>

<% 
		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}

		int bbsID = 0;
		if(request.getParameter("bbsID") != null){
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		
		int trCnt= 0; // 2라면, 마지막 작업임!
 		if(request.getParameter("trCnt") != null){
			trCnt = Integer.parseInt(request.getParameter("trCnt"));
		}
		
		
		
		BbsDAO bbs = new BbsDAO();
		bbs.SignAction(bbsID);
		
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('승인(제출)이 완료되었습니다.')");
		if(trCnt == 2) { // 마지막 승인이므로, 더이상 승인할 것이 없음!
			script.println("alert('모든 보고가 승인(또는 마감)처리 되었습니다.')");
			script.println("location.href='bbs.jsp'");
		} else {
		script.println("location.href='signOn.jsp'");
		}
		script.println("</script>");
%>



<a><%= bbsID %></a> 
</body>
</html>