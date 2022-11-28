<%@page import="java.sql.Timestamp"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="bbs.BbsDAO"%>
<%@page import="bbs.Bbs"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Baynex-update</title>
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
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		
		int bbsID = 0;
		if(request.getParameter("bbsID") != null){
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		if(bbsID == 0){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
		}
		//해당 'bbsID'에 대한 게시글을 가져온 다음 세션을 통하여 작성자 본인이 맞는지 체크한다
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		if(!id.equals(bbs.getUserID())){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('수정 권한이 없습니다. 사용자를 확인해주십시오.')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
		} else{
			// 입력이 안 됐거나 빈 값이 있는지 체크한다
			if(request.getParameter("bbsTitle") == null || request.getParameter("bbsContent") == null || request.getParameter("bbsStart") == null || request.getParameter("bbsTarget") == null || request.getParameter("bbsEnd") == null || request.getParameter("bbsNContent") == null || request.getParameter("bbsNStart") == null || request.getParameter("bbsNTarget") == null
				|| request.getParameter("bbsTitle").equals("") || request.getParameter("bbsContent").equals("") || request.getParameter("bbsStart").equals("") || request.getParameter("bbsTarget").equals("") || request.getParameter("bbsEnd").equals("")) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('입력되지 않은 사항이 있습니다.)");
				script.println("history.back()");
				script.println("</script>");
			}else{
				// 정상적으로 입력이 되었다면 글 수정 로직을 수행한다
				BbsDAO bbsDAO = new BbsDAO();
				java.sql.Timestamp date = bbsDAO.getDateNow();
				
				int result = bbsDAO.update(bbsID, request.getParameter("bbsManager"), request.getParameter("bbsTitle"), request.getParameter("bbsContent"), request.getParameter("bbsStart"), request.getParameter("bbsTarget"), request.getParameter("bbsEnd"), request.getParameter("bbsNContent"), request.getParameter("bbsNStart"), request.getParameter("bbsNTarget"), date);
				// 데이터베이스 오류인 경우
				if(result == -1){
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('글 수정하기에 실패했습니다')");
					script.println("history.back()");
					script.println("</script>");
				// 글 수정이 정상적으로 실행되면 알림창을 띄우고 게시판 메인으로 이동한다
				}else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('보고가 정상적으로 수정되었습니다.')");
					script.println("location.href='bbs.jsp'");
					script.println("</script>");
				}
			}
		}
	
	%>
</body>
</html>