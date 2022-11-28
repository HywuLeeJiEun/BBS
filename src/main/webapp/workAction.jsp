<%@page import="java.util.Arrays"%>
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
<title>Baynex-worksAction</title>
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
		
		//user 정보를 불러옴. (이름)
		String name = request.getParameter("user");
		//name을 통해 id를 가져옴.
		UserDAO user = new UserDAO();
		String userid = user.getId(name);
		
		//userid를 통해 manager를 불러옴. 배열형태로 받아와짐.
		String workSet;
		ArrayList<String> code = user.getCode(id); //코드 리스트 출력
		List<String> works = new ArrayList<String>();
		
		
		if(code == null) {
			workSet = "";
		}  else {
			for(int i=0; i < code.size(); i++) {
				
				String number = code.get(i);
				works.add(number); //즉, work 리스트에 모두 담겨 저장됨
			}
		}
	
		
		// 추가할 work가 있는지 확인. 또한 이에 대한 keycode를 파악.
		// 코드 넘버를 가져옴.
		String work = request.getParameter("workValue");
		String codeNumber = "";
		
		if(works.contains(work)) {
			codeNumber = String.join(",",works); 
			
			PrintWriter script = response.getWriter();
			script.println("<script>");
			//script.println("alert('이미 담당하고 있는 업무입니다.')");
			script.println("location.href='workChange.jsp'");
			script.println("</script>");
		} else {
			works.add(work);
			codeNumber = String.join(",",works); 
		}
		
		 //update를 진행함.
	 	int result = user.UpdateManager(codeNumber, name);
		
		if(result == -1) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다.')");
			script.println("history.back()");
			script.println("</script>");
		} else {
			if(code != null) {
				if(code.size() == 10) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('담당 업무는 최대 10개를 초과할 수 없습니다.')");
				script.println("history.back()");
				script.println("</script>");
				} else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				//script.println("alert('정삭적으로 추가 되었습니다.')");
				script.println("location.href='workChange.jsp'");
				script.println("</script>");
				}
			}
			PrintWriter script = response.getWriter();
			script.println("<script>");
			//script.println("alert('정삭적으로 추가 되었습니다.')");
			script.println("location.href='workChange.jsp'");
			script.println("</script>");
		} 

	%>

</body>
</html>