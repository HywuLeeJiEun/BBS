<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
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
		
				
		//해당 'bbsID'에 대한 게시글을 가져온 다음 세션을 통하여 작성자 본인이 맞는지 체크한다
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		String name = new BbsDAO().name(id);
		
		
		//ERP가 있다면, update 진행
		//erp data 하나의 string으로 만들기
		String erp_date ="";
		String erp_user ="";
		String erp_stext = "";
		String erp_authority ="";
		String erp_division = "";
		int erp_size = 0; 
		if(request.getParameter("erp_size") != null) {
			erp_size = Integer.parseInt(request.getParameter("erp_size"));
		}
		int erp_id = 0;
		if(request.getParameter("erp_id") != null) {
			erp_id = Integer.parseInt(request.getParameter("erp_id"));
		}
		for(int i=0; i< erp_size; i++) {
			String a = "erp_date";
			erp_date += request.getParameter(a+i) + "\r\n";
			String b = "erp_user";
			erp_user += request.getParameter(b+i) + "\r\n";
			String c = "erp_stext";
			erp_stext += request.getParameter(c+i) + "\r\n";
			String d = "erp_authority";
			erp_authority += request.getParameter(d+i) + "\r\n";
			String e = "erp_division";
			erp_division += request.getParameter(e+i) + "\r\n";
			
		}
		
		  if(!id.equals(bbs.getUserID()) && !rk.equals("부장") && !rk.equals("차장") && !rk.equals("관리자")) {
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
				
				int result = bbsDAO.update(bbsID, request.getParameter("bbsManager"), request.getParameter("bbsTitle"), request.getParameter("bbsContent"), request.getParameter("bbsStart"), request.getParameter("bbsTarget"), request.getParameter("bbsEnd"), request.getParameter("bbsNContent"), request.getParameter("bbsNStart"), request.getParameter("bbsNTarget"), date, name);
				
				if((erp_date != "" || erp_user != "") && result != -1) { // 즉, bbs 수정에 성공하고 erp_bbs 데이터가 비어있지 않다면,
					int result_erp = bbsDAO.erp_update(erp_date, erp_user, erp_stext, erp_authority, erp_division, erp_id);
					if(result_erp == -1) {
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('erp 디버깅 권한신청 처리현황 저장에 실패하였습니다.')");
						script.println("history.back()");
						script.println("</script>");
					} else {
						// Update 제한을 풀어둠!! (수정이 완료되면)
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('보고가 정상적으로 수정되었습니다.')");
						script.println("location.href='bbs.jsp'");
						script.println("</script>");
					}
				} else {
					// 데이터베이스 오류인 경우
					if(result == -1){
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('글 수정하기에 실패했습니다')");
						script.println("history.back()");
						script.println("</script>");
					// 글 수정이 정상적으로 실행되면 알림창을 띄우고 게시판 메인으로 이동한다
					}else {
						// Update 제한을 풀어둠!! (수정이 완료되면)
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('보고가 정상적으로 수정되었습니다.')");
						script.println("location.href='bbs.jsp'");
						script.println("</script>");
					}
				}
			}
		} 

	%>
	<a><%= erp_id %></a><br>
	<a><%= erp_size %></a><br>
	<a><%= erp_date %></a><br>
	<a><%= erp_user %></a><br>
	<a><%= erp_stext %></a><br>
	<a><%= erp_authority %></a><br>
	<a><%= erp_division %></a><br>
</body>
</html>