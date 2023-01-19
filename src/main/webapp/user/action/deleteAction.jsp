<%@page import="rms.rms_this"%>
<%@page import="rms.RmsDAO"%>
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
		// 현재 세션 상태를 체크한다
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		}
		
		String bbsDeadline = request.getParameter("bbsDeadline");
		if(bbsDeadline == null || bbsDeadline.isEmpty()){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		}
				
				
		RmsDAO rms = new RmsDAO();
		ArrayList<rms_this> tlist = rms.gettrms(bbsDeadline, id);
				
		//작성자 확인
		if(!id.equals(tlist.get(0).getUserID())) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('삭제 권한이 없습니다. 사용자를 확인해주십시오.')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		} else{
			// 글 삭제 로직을 수행한다
			int n = rms.tdelete(id, bbsDeadline);
			int nn = rms.ldelete(id, bbsDeadline);
			int an = rms.edelete(id, bbsDeadline);
			
			if(n == -1 && nn == -1 && an == -1) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('삭제가 정상적으로 이루어지지 않았습니다. 관리자에게 문의 바랍니다.')");
					script.println("location.href='/BBS/user/bbs.jsp'");
					script.println("</script>");
				}
				else {
					// 수정 및 제출 가능한 list가 없다면,
					if(tlist.size() == 0) {
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('정상적으로 보고가 제거 되었습니다.')");
						script.println("alert('수정 및 제출 가능한 주간보고가 없습니다. 조회페이지로 이동합니다.')");
						script.println("location.href='/BBS/user/bbs.jsp'");
						script.println("</script>");
					} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('정상적으로 보고가 제거 되었습니다.')");
					script.println("location.href='/BBS/user/bbsUpdateDelete.jsp'");
					script.println("</script>");
					}
				}
			}
			
	
	
	%>
</body>
</html>