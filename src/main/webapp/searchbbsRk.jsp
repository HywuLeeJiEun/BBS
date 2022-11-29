<%@page import="user.UserDAO"%>
<%@page import="org.mariadb.jdbc.internal.failover.tools.SearchFilter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="java.util.ArrayList" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="css/index.css">
<title>Baynex 주간보고</title>
</head>

<body>
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
		
		UserDAO user = new UserDAO();
		String rk = user.getRank((String)session.getAttribute("id"));
	%>
	<nav class="navbar navbar-default"> <!-- 네비게이션 -->
		<div class="navbar-header"> 	<!-- 네비게이션 상단 부분 -->
			<!-- 네비게이션 상단 박스 영역 -->
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<!-- 이 삼줄 버튼은 화면이 좁아지면 우측에 나타난다 -->
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<!-- 상단 바에 제목이 나타나고 클릭하면 main 페이지로 이동한다 -->
			<% 
			BbsDAO bbsDAO = new BbsDAO();
			int confirm = bbsDAO.getBbsRecord((String)session.getAttribute("id"));
			
			if(confirm == 1 ) {%>
			<a class="navbar-brand" href="bbsUpdate.jsp">Baynex 주간보고</a>
			<% } else { %>
			<a class="navbar-brand" href="main.jsp">Baynex 주간보고</a>
			<% } %>
		</div>
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
			<% if(confirm == 1 ) { %>
				<li><a href="bbsUpdate.jsp">주간보고</a></li>
			<% } else { %>
				<li><a class="navbar-brand" href="main.jsp">주간보고</a></li>
			<% } %>
				<li class="active"><a href="bbs.jsp">제출목록</a></li>
			</ul>
			
			<%
				// 로그인 하지 않았을 때 보여지는 화면
				if(id == null){
			%>
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">접속하기<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
						<li><a href="login.jsp">로그인</a></li>
					</ul>
				</li>
			</ul>
			<%
				// 로그인이 되어 있는 상태에서 보여주는 화면
				}else{
			%>
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
					%>
						<li><a href="workChange.jsp">담당업무 변경</a></li>
					
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
			<%
				}
			%>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	
		
	<!-- ***********검색바 추가 ************* -->
	<%
		String category = request.getParameter("searchField");
		String str = request.getParameter("searchText");
		if(category == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('검색 내용이 비어있습니다.')");
			script.println("location.href='bbs.jsp'");
			script.println("</script>");
		}
		
		if(category.equals("bbsDeadline")) {
			int len = str.length();
			
			// 2글자 이상이며 -을 포함하지 않는다면, 
			if(len > 2 && str.contains("-") == false) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('날짜 형식은 - 을 갖추어야 합니다.')");
				script.println("location.href='bbs.jsp'");
				script.println("</script>");
			}
		}
	%>
	<div class="container">
		<div class="row">
			<form method="post" name="search" id="search" action="searchbbsRk.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="bbsDeadline" <%= category.equals("bbsDeadline")?"selected":""%>>제출일</option>
								<option value="bbsTitle" <%= category.equals("bbsTitle")?"selected":""%>>제목</option>
								<option value="userName" <%= category.equals("userName")?"selected":""%>>작성자</option>

						</select></td>
						<td>
							<input type="text" class="form-control"
							placeholder="" name="searchText" maxlength="100" value="<%= request.getParameter("searchText") %>"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success" formaction="searchbbsRk.jsp">검색</button></td>
						<%
						if (request.getParameter("searchField").equals("bbsDeadline")) { 
						%>
						<td><button type="submit" class="btn btn-warning pull-right" formaction="gathering.jsp" onclick="return submit2(this.form)">취합</button></td>
						<%
						}
						%>
					</tr>

				</table>
			</form>
		</div>
	</div>
	<br>
	
	
	<!-- # <검색된게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<th style="background-color: #eeeeee; text-align: center;">제출일</th>
						<th style="background-color: #eeeeee; text-align: center;">제목</th>
						<th style="background-color: #eeeeee; text-align: center;">작성자</th>
						<th style="background-color: #eeeeee; text-align: center;">작성일</th>
					</tr>
				</thead>
				<tbody>
					<%
						ArrayList<Bbs> list =  bbsDAO.getRkSearch(pageNumber ,category,
								request.getParameter("searchText"));
						
	 					if (list.size() == 0) {
							PrintWriter script = response.getWriter();
							script.println("<script>");
							script.println("alert('검색결과가 없습니다.')");
							script.println("location.href='bbs.jsp'");
							script.println("</script>");
						} 

						for(int i = 0; i < list.size(); i++){
					%>
					<tr>
						<td><%= list.get(i).getBbsDeadline() %></td>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
						<td><a href="update.jsp?bbsID=<%=list.get(i).getBbsID()%>"><%=list.get(i).getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;")
						.replaceAll(">", "&gt;").replaceAll("\n", "<br>")%></a></td>
						<td><%= list.get(i).getUserName() %></td>
						<td><%= list.get(i).getBbsDate().substring(0, 11) + list.get(i).getBbsDate().substring(11, 13) + "시"
							+ list.get(i).getBbsDate().substring(14, 16) + "분" %></td>			
					</tr>
					<%
						}
					%>
				</tbody>
			</table>
			
			<!-- 페이징 처리 영역 -->
			<%
				if(pageNumber != 1){
			%>
				<a href="searchbbs.jsp?pageNumber=<%=pageNumber - 1 %>&searchField=<%= category %>&searchText=<%= str %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(bbsDAO.nextPage(pageNumber + 1)){
			%>
				<a href="searchbbs.jsp?pageNumber=<%=pageNumber + 1 %>&searchField=<%= category %>&searchText=<%= str %>"
					class="btn btn-success btn-arraw-left">다음</a>
			<%
				}
			%>
			
			
			<a href="bbs.jsp" class="btn btn-primary pull-right">목록</a> 
		</div>
	</div>
	<!-- 게시판 메인 페이지 영역 끝 -->
	
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	<!-- <script>
		function submit2(frm) {
			frm.action='gathering.jsp';
			frm.submit();
			return true;
		}
	</script> -->
</body>
</html>