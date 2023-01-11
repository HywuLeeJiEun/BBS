<%@page import="Sumad.Sumad"%>
<%@page import="java.util.ArrayList"%>
<%@page import="Sumad.SumadDAO"%>
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
		
		//이동을 위함
		SumadDAO sumadDAO = new SumadDAO();
		ArrayList<Sumad> afsumad = sumadDAO.getlistSumSign(); //미승인 상태만 불러옴!
		
		if(adnum != -1) {
			if(afsumad.size() == 0) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('승인(제출)이 완료되었습니다.')");
				script.println("alert('요약본이 모두 승인되었습니다. 조회 페이지로 이동합니다.')");
				script.println("location.href='/BBS/admin/summaryadRk.jsp'");
				script.println("</script>");
			}else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('승인(제출)이 완료되었습니다.')");
				script.println("history.back();");
				script.println("</script>");
			}
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