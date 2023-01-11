<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
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
<title>Baynex-delete</title>
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
		
		int bbsID = 0;
		if(request.getParameter("bbsID") != null){
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		if(bbsID == 0){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		}
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
				String workSet;
				
				UserDAO userDAO = new UserDAO();
				String rk = userDAO.getRank((String)session.getAttribute("id"));
				ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력
				List<String> works = new ArrayList<String>();
				
				if(code == null) {
					workSet = "";
				} else {
					for(int i=0; i < code.size(); i++) {
						
						String number = code.get(i);
						// code 번호에 맞는 manager 작업을 가져와 저장해야함!
						String manager = userDAO.getManager(number);
						works.add(manager+"\n"); //즉, work 리스트에 모두 담겨 저장됨
					}
					
					workSet = String.join("/",works);


				}
				
				
		BbsDAO bbsDAO = new BbsDAO();		
		String name = userDAO.getName(id);
		ArrayList<Bbs> list = bbsDAO.getNoneSignSearch(1, name);
				
		//해당 'bbsID'에 대한 게시글을 가져온 다음 세션을 통하여 작성자 본인이 맞는지 체크한다
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		if(!id.equals(bbs.getUserID()) && !rk.equals("부장") && !rk.equals("차장") && !rk.equals("관리자")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('삭제 권한이 없습니다. 사용자를 확인해주십시오.')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		} else{
			// 글 삭제 로직을 수행한다
			int result = bbsDAO.delete(bbsID);
			
			if(result != -1) {
				int result_erp = bbsDAO.delete_erp(bbsID);
				if(result_erp == -1) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('erp 디버깅 권한신청에 대한 삭제가 정상적으로 이뤄지지 않았습니다. 관리자에게 문의바랍니다.')");
					script.println("location.href='/BBS/user/bbs.jsp'");
					script.println("</script>");
				}
				else {
					if(list.size() == 0) {
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
			
			// 데이터베이스 오류인 경우
			if(result == -1){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다. 관리자에게 문의바랍니다.')");
				script.println("history.back()");
				script.println("</script>");
			// 글 삭제가 정상적으로 실행되면 알림창을 띄우고 게시판 메인으로 이동한다
			}else {
				if(list.size() == 0) {
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