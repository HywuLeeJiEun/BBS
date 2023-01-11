<%@page import="user.UserDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bbs.Bbs"%>
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
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
					if(id == null){
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
						script.println("location.href='../../login.jsp'");
						script.println("</script>");
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
		UserDAO userDAO = new UserDAO();
		Bbs bbslist = new BbsDAO().getBbs(bbsID);
		String name = userDAO.getName(id);
		ArrayList<Bbs> list = bbs.getNoneSignSearch(1, name);
		
		String bbsContent = bbslist.getBbsContent() + "\r\n";
		String bbsStart = bbslist.getBbsStart() + "\r\n";
		String bbsTarget = bbslist.getBbsTarget() + "\r\n";
		String bbsEnd = bbslist.getBbsEnd() + "\r\n";
		String bbsNContent = bbslist.getBbsNContent() + "\r\n";
		String bbsNStart = bbslist.getBbsNStart() + "\r\n";
		String bbsNTarget = bbslist.getBbsNTarget() + "\r\n";
		
		bbs.SignAction(bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, bbsID);
		
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('승인(제출)이 완료되었습니다.')");
		if(list.size() == 0) { // 마지막 승인이므로, 더이상 승인할 것이 없음!
			script.println("alert('주간보고가 모두 제출되어 조회 페이지로 이동합니다.')");
			script.println("location.href='/BBS/user/bbs.jsp'");
		} else {
		script.println("location.href='/BBS/user/bbsUpdateDelete.jsp'");
		}
		script.println("</script>");
%>



<a><%= bbsID %></a> 
</body>
</html>