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
		BbsDAO bbs = new BbsDAO();

		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}

		int sumad_id = 0;
		if(request.getParameter("sumad_id") != null){
			sumad_id = Integer.parseInt(request.getParameter("sumad_id"));
		}
		
		String bbsDeadline = "";
		if(request.getParameter("bbsDeadline") != null) {
			bbsDeadline = request.getParameter("bbsDeadline");
		}
		
		//summary - erp, web id 검색 (bbsDeadline으로 검색하여 해당 작업 진행!)
		int erp_id = Integer.parseInt(bbs.getSumid(bbsDeadline, "ERP")); 
		int web_id = Integer.parseInt(bbs.getSumid(bbsDeadline, "WEB"));
		
		//sign을 승인으로 변경!
		//erp, web
		int e_num = bbs.sumSignOn(erp_id);
		int w_num = bbs.sumSignOn(web_id);
		//summary_admin
		int adnum = bbs.sumadSignOn(sumad_id);
		
		if(adnum != -1) {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('승인(제출)이 완료되었습니다.')");
		script.println("history.back();");
		script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
%>



</body>
</html>