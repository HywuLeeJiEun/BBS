<%@page import="java.util.Calendar"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="bbs.Bbs"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<% request.setCharacterEncoding("utf-8"); %>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<title>Baynex 주간보고</title>
</head>
<body id="weekreport">
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="css/js/bootstrap.js"></script>



		<%
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		int pageNumber = 1; //기본은 1 페이지를 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'pageNumber'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'pageNumber'변수에 저장한다
		if(request.getParameter("pageNumber") != null){
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		int bbsID = 1;
		


	//(월요일) 제출 날짜 확인
	UserDAO userDAO = new UserDAO();
			String mon = "";
			String day ="";
			
			Calendar cal = Calendar.getInstance(); 
			Calendar cal2 = Calendar.getInstance(); //오늘 날짜 구하기
			SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd");
			
			cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
			//cal.add(Calendar.DATE, 7); //일주일 더하기
			
			 // 비교하기 cal.compareTo(cal2) => 월요일이 작을 경우 -1, 같은 날짜 0, 월요일이 더 큰 경우 1 
			 if(cal.compareTo(cal2) == -1) {
				 //월요일이 해당 날짜보다 작다.
				 cal.add(Calendar.DATE, 7);
				 
				 mon = dateFmt.format(cal.getTime());
				day = dateFmt.format(cal2.getTime());
			 } else { // 월요일이 해당 날짜보다 크거나, 같다 
				 mon = dateFmt.format(cal.getTime());
				day = dateFmt.format(cal2.getTime());
			 }
			 
			 String bbsDeadline = mon;
			 
			//pl 리스트 확인
				String work = userDAO.getpl(id); //현재 접속 유저의 pl(web, erp)를 확인함!
				ArrayList<String> plist = userDAO.getpluser(work); //pl 관련 유저의 아이디만 출력
				String[] pllist = plist.toArray(new String[plist.size()]);
	
	BbsDAO bbsDAO = new BbsDAO(); // 인스턴스 생성
	ArrayList<Bbs> list = bbsDAO.getList(pageNumber, bbsDeadline, pllist); 
	%>

<a><%= list.get(0).getBbsID() %></a>
<a><%= pllist[0] %></a>
<a><%= work %></a>
<a><%= plist.size()%></a>
<%-- <a><%= active %></a>
<a>(<%= del %>)</a> --%>


</body>
</html>