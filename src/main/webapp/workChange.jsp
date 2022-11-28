<%@page import="user.User"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="bbs.Bbs"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->

<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<title>Baynex 주간보고</title>
</head>



<body>
<%
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		//String workSet;
		//works 리스트에 저장됨!
		UserDAO userDAO = new UserDAO();
		ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력
		List<String> works = new ArrayList<String>();
		String str=" ";
		
		if(code == null) {
			str = "";
		} else {
			for(int i=0; i < code.size(); i++) {
				
				String number = code.get(i);
				// code 번호에 맞는 manager 작업을 가져와 저장해야함!
				String manager = userDAO.getManager(number);
				works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
			}
			
			//workSet = String.join("/",works);


		}
		
	%>

	
	
    <!-- ************ 상단 네비게이션바 영역 ************* -->
	<nav class="navbar navbar-default"> 
		<div class="navbar-header"> 
			<!-- 네비게이션 상단 박스 영역 -->
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<!-- 이 삼줄 버튼은 화면이 좁아지면 우측에 나타난다 -->
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="main.jsp">Baynex 주간보고</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="main.jsp">주간보고</a></li>
				<li><a href="bbs.jsp">제출목록</a></li>
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
						<li class="active"><a href="login.jsp">로그인</a></li>
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
							<li class="active"><a href="workChange.jsp">담당업무 변경</a></li>
							<li><a href="logoutAction.jsp">로그아웃</a></li>
						</ul>
					</li>
			</ul>
			<%
				}
			
				UserDAO user = new UserDAO();
			%>
		</div>
	</nav>
	
	<%
		// user 목록을 불러옴. 
		User info = user.getUser(user.getName(id));
	
		
		// 모든 업무 목록을 불러옴. ( ERP,HR, 의 형태로)
		ArrayList<String> jobs = new ArrayList<String>();
		jobs = user.getAlljobs();
		
		
		
		
		
	%>

	

	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<form method="post" name="search" action="workChangesearch.jsp">
				<table class="pull-left">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="userName">담당자</option>
						</select></td>
						<td><input type="text" class="form-control"
							placeholder="담당자 입력" name="searchText" maxlength="100" value="<%= user.getName(id) %>"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success">검색</button></td>
					</tr>

				</table>
			</form>
		</div>
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
		
	<div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
			<tr>
				<th colspan="5" style="text-align: center;"> 담당자 업무 변경 </th>
			</tr>
			<tr>
				<th colspan="5" style="text-align: center;">현재 [ <%= user.getName(id) %> ](님)의 담당 업무를 변경중입니다.</th>
			</tr>
			</table>
			
		</div>
	</div>
			
			
	<div class="container d-flex align-items-start" style="text-align:center;">
			<div class="flex-grow-1" style="display:inline-block; width:45%;">
				<table class="table" style="text-align: center; border: 1px solid #dddddd">
					<tr>
						<th colspan="2" style="text-align:center">담당업무</th>
					</tr>
					<%
						if(str.equals("")) {
							%>
							<tr>
								<td colspan="1" style="text-align:center"><input type=text style="border:0; width:50%; text-align:center" readonly value="담당 업무 해당이 없습니다."></td>
							</tr>
							<% 
						} else {
						// 직업의 개수 만큼 for문을 돌림.
							for(int i=0; i< works.size(); i++ ) {
	
					%>
					<tr>
						<td colspan="1" style="text-align:center;"><input type=text name="<%= i %>" style="border:0; width:50%; text-align:center" readonly value="<%= works.get(i) %>"></td>
						<td colspan="1"><a type="submit" style="margin-right:50%;border:none" class="btn btn-danger pull-left" href="workDeleteAction.jsp?work=<%= works.get(i) %>&user=<%= user.getName(id) %>" >삭제</a></td>
					</tr>
					<%
							} if (works.size() == 10) {
					%>
						<tr>
							<td colspan="2" style="text-align:center"><input type=text style="border:0; width:100%; text-align:center; color:blue" readonly value="업무 지정은 최대 10개까지만 가능합니다."></td>
						</tr>
					<%
							}
						}
					%>
				</table>
			</div>
			
			<div class="align-self-start" style="display:inline-block; width:5%">
				<table class="table" style="text-align: center; border: 1px solid #dddddd">
				</table>
			</div>
			
			<div class="align-slef-start" style="display:inline-block; width:45%;">
				<form method="post" action="workAction.jsp">
					<table class="table" style="text-align: center; border: 1px solid #dddddd">
						<tr>
							<th colspan="2" style="text-align:center"><input type=text name="user" style="border:0; width:15%; text-align:right" readonly value="<%= user.getName(id) %>">(님) 업무관리</th>
						</tr>
						<tr style="border:none">
							<td>
								<select id="workValue" class="form-control pull-right" name="workValue" onchange="selectValue()" style="margin-left:30px; width:70%; text-align-last:center;">
										<%
											for(int i=0; i<jobs.size(); i++) {
										%>
										<option value="<%= i %>"><%= jobs.get(i) %></option> 
										<%
											}
										%>
								</select>
							</td>
								<td><button type="submit" class="btn btn-primary pull-left" style="margin-light:50%;"  >추가</button></td>
						</tr>
						<% 
						for(int i=0; i<works.size()-1; i++) {
						%>
							<tr style="border:none">
								<td colspan="1" style="border:none"><button style="margin-right:30%;border:none; visibility:hidden" class="btn btn-danger" formaction=""> 가나다  </button></td>
							</tr>	
						<%
							} if (works.size() == 10) {
					%>
						<tr style="border:none">
							<td colspan="1" style="border:none"><button style="margin-right:30%;border:none; visibility:hidden" class="btn btn-danger" formaction=""> 가나다  </button></td>
						</tr>
					<%
							}
					%>
					</table>
				</form>
			</div>
	</div>
	
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	<%-- <script>
		function selectValue() {
			var obj = document.getElementById("workValue");
			var opt = "";
			job = [];
			
			for(var i=0; i < <%= jobs.size() %>; i++) {
				opt = document.createElement('option');
				opt.text = i;
				opt.value = jobs.get(i);
				obj.add(opt);
			}	
		}
	</script> --%>
</body>