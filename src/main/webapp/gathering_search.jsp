<%@page import="java.util.List"%>
<%@page import="org.mariadb.jdbc.internal.failover.tools.SearchFilter"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
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
<script src="PptxGenJS/dist/pptxgen.bundle.js"></script>
<script src="PptxGenJS/libs/jszip.min.js"></script>
<script src="PptxGenJS/dist/pptxgen.min.js"></script>


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
			<!-- 상단 바에 제목이 나타나고 클릭하면 보고 작성 페이지로 이동한다 -->
			<a class="navbar-brand" href="bbsUpdate.jsp">Baynex 주간보고</a>
		</div>
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="bbsUpdate.jsp">주간보고</a></li>
				<li><a href="bbs.jsp">제출목록</a></li>
				<li class="active"><a href="gathering_search.jsp">취합하기</a></li>
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
						<li><a href="logoutAction.jsp">로그아웃</a></li>
			</ul>
			<%
				}
			%>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	
	
	<div class="card text-center">
 <!--  <div class="card-header">
    Featured
  </div>
  <div class="card-body">
    <h5 class="card-title">Special title treatment</h5>
    <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>
    <a href="#" class="btn btn-primary">Go somewhere</a>
  </div>
  <div class="card-footer text-muted">
    2 days ago
  </div> -->
  
  <div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
					<th colspan="5" style=" text-align: center; color:blue "></th>
				</tr>
			</thead>
		</table>
	</div>
	
	
  <div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
			<tr>
				<th colspan="5" style="text-align: center;"> DB data -> PPT로 변환 </th>
			</tr>
			<tr>
				<th colspan="5" style="text-align: center;">- - - <br>pptx 파일로 변경할 수 있습니다.<br><br>취합하고자 하는 날짜를 선택하여 주십시오. <br> - - -</th>
			</tr>
			</table>
			
		</div>
	</div>
</div>
	
	<!-- 조회할 Deadline 선택 -->
	<div class="card text-center">
		<% 
			BbsDAO bbsDAO = new BbsDAO();
			ArrayList<Bbs> list = bbsDAO.getDeadLineList();
		%>
		
			<form method="post" name="search" action="gathering.jsp">
				<select name="searchText" style="width:100px; height:35px" onchange="ChangeValue()">
				<%
				String searchField = "bbsDeadLine";
				for (int i=0; i < list.size(); i++) {
				%>
					<!-- for문을 돌림. -->
					<option value="<%= list.get(i).getBbsDeadline() %>"><%= list.get(i).getBbsDeadline() %></option>
				<%
					}
				%>
				</select>
				<button type="submit" style="margin:5px" class="btn btn-success"> 취합 </button>
			</form>
	</div>
	
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
					<th colspan="5" style=" text-align: center; color:blue "></th>
				</tr>
			</thead>
		</table>
	</div>

	
	
</body>

<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchText');
			
		}
	</script>
	
</html>