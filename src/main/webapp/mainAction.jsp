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
<jsp:setProperty name="bbs" property="bbsEnd" />
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
		}else{
			
			// 입력이 안 된 부분이 있는지 체크한다 (금주 업무 실적과 title)
			if(bbs.getBbsTitle() == null){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('(Title) 주간보고 명세서가 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			}
			if(bbs.getBbsContent() == null) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('(금주) 업무 내용이 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			}
			if(bbs.getBbsStart() == null) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('(금주) 접수일이 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			}
			if(bbs.getBbsTarget() == null) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('(금주) 완료일목표일이 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			}
			if(bbs.getBbsEnd() == null) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('(금주)진행율/완료일이 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			}
			if(bbs.getBbsDeadline() == null) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('주간보고 제출일이 입력되지 않았습니다.')");
				script.println("history.back()");
				script.println("</script>");
			} else { 
			
			// 유효성 검사(날짜 타입으로 작성하되, 규격을 지키기 위함 - 즉, 한글이나 영문은 필요 없음!)
/* 			if(bbs.getBbsStart() >= 0x61 && bbs.getBbsStart() <= 0x7A) {
				
			} */
			
			
			if(bbs.getBbsNContent() == null){
				NContent=(String)(" ");
			}else{
				NContent =(String)bbs.getBbsNContent();
			}
			if(bbs.getBbsNStart() == null){
				NStart=(String)(" ");
			}else{
				NStart = (String)bbs.getBbsNStart();
			}
			if(bbs.getBbsNTarget() == null){
				NTarget=(String)(" ");
			}else{
				NTarget = (String)bbs.getBbsNTarget();
			} 
				
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
					
						int result = bbsDAO.write(id, bbs.getBbsManager(), bbs.getBbsTitle(), name, bbs.getBbsContent(), bbs.getBbsStart(), bbs.getBbsTarget(), bbs.getBbsEnd(), NContent, NStart, NTarget, bbs.getBbsDeadline());
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
							script.println("location.href='bbsUpdate.jsp'");
							script.println("</script>");
						}
					}
			}
		
		}
	
	%>
</body>
</html>