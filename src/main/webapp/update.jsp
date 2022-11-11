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

<!-- 화면 최적화 -->
<meta name="viewport" content="width-device-width", initial-scale="1">

<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="css/index.css">
<title>BBS</title>
</head>



<body>
	<%
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		
		// bbsID를 초기화 시키고
		// 'bbsID'라는 데이터가 넘어온 것이 존재한다면 캐스팅을 하여 변수에 담는다
		int bbsID = 0;
		if(request.getParameter("bbsID") != null){
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		
		// 만약 넘어온 데이터가 없다면
		if(bbsID == 0){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='bbs.jsp'");
			script.println("</script");
		}
		
		// 유효한 글이라면 구체적인 정보를 'bbs'라는 인스턴스에 담는다
		BbsDAO bbsDAO = new BbsDAO();
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		UserDAO user = new UserDAO();
		String name = user.getName(id);

		
			// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			String dl = bbsDAO.getDLS(bbsID);
			Date time = new Date();
			String timenow = dateFormat.format(time);

			Date dldate = dateFormat.parse(dl);
			Date today = dateFormat.parse(timenow);
			
	
	
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
				String workSet;
				
				UserDAO userDAO = new UserDAO();
				ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력
				List<String> works = new ArrayList<String>();
				
				if(code == null) {
					workSet = "";
				} else {
					for(int i=0; i < code.size(); i++) {
						
						String number = code.get(i);
						// code 번호에 맞는 manager 작업을 가져와 저장해야함!
						String manager = userDAO.getManager(number);
						works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
					}
					
					workSet = String.join("/",works);


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
			<a class="navbar-brand" href="main.jsp">BBS 주간보고</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="bbsUpdate.jsp">주간보고</a></li>
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
						<li><a href="logoutAction.jsp">로그아웃</a></li>
			</ul>
			<%
				}
			%>
		</div>
	</nav>
	
	
	
	<!-- ********** 게시판 글쓰기 양식 영역 ********* -->
		<div class="container">
			<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
				<thead>
					<tr>
						<%
						if(id != null && id.equals(bbs.getUserID()) && dldate.after(today)){
						%>
						<th colspan="3" style=" text-align: center; color:blue ">주간보고를 수정하고 있습니다.</th>
						<%
						}
						%>
					</tr>
				</thead>
			</table>
		</div>
		<div class="container">
			<div class="row">
				<form method="post" action="updateAction.jsp?bbsID=<%= bbsID %>">
					<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
							<thead>
								<tr>
									<th colspan="3" style=" text-align: center; color:blue "></th>
								</tr>
							</thead>
						</table>

					
						<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
							<thead>
								<tr>
									<th colspan="5" style="background-color: #eeeeee; text-align: center;">BBS 주간보고 작성</th>
								</tr>
							</thead>
							<tbody>
								<tr>
										<td colspan="1"> 주간보고 명세서 </td>
										<td align="center" colspan="2"><input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= bbs.getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>"></td>
										<td colspan="1">  주간보고 제출일 </td>
										<td align="center" colspan="1"><input type="date" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= bbs.getBbsDeadline() %>"></td>
								<tr>
									<th colspan="5" style="background-color: #D4D2FF;" align="center">금주 업무 실적</th>
								</tr>
								<tr style="background-color: #FFC57B;">
										<th width="6%">|  담당자</th>
										<th width="33%">| &nbsp; 업무내용</th>
										<th width="1%">| &nbsp; 접수일</th>
										<th width="1%">| &nbsp; 완료목표일</th>
										<th width="1%">| &nbsp; 진행율/완료일</th>
									</tr>
								<tr align="center">	
										<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
									 <td><textarea class="textarea" style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50"><%= workSet %>&#10;<%= bbs.getUserName() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsContent"><%= bbs.getBbsContent() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsStart" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsStart() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsTarget" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsTarget() %></textarea></td>	
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-.%]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsEnd() %></textarea></td>									
								</tr>	
										
										<tr>
										
										</tr>
								
								
								<tr>
									<th colspan="5" style="background-color: #D4D2FF;" align="center">차주 업무 실적</th>
								</tr>
								<tr style="background-color: #FFC57B;">
										<th width="6%">|  담당자</th>
										<th width="33%">| &nbsp; 업무내용</th>
										<th width="1%">| &nbsp; 접수일</th>
										<th width="1%">| &nbsp; 완료목표일</th>
									</tr>
								<tr align="center">	
									 <td><textarea class="textarea" style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50" ><%= workSet %>&#10;<%= bbs.getUserName() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsNContent" ><%= bbs.getBbsNContent() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsNStart" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNStart() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsNTarget" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNTarget() %></textarea></td>										
								</tr>
								<tr  align="center">	
											<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
										<!-- 	oninput을 활용하여 숫자와 특수문자(/)만 작성 가능하도록 구현 -->
										 <td></td>
										 <td><input type="text" style="height:5px;width:100%; border:none;" disabled></td>
										 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>
										 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>	
	
									</tr>
								<tr align="center">	
									 <td colspan="5" >
												
										<%
											if(id != null && id.equals(bbs.getUserID()) && dldate.after(today)){
										%>
											<a onclick="return confirm('해당 게시글을 삭제하시겠습니까?')"
											href="deleteAction.jsp?bbsID=<%= bbsID %>" class="btn btn-danger pull-left">삭제</a>
											
											<input type="submit" id="update" style="margin-bottom:5px" class="btn btn-success pull-right" value="수정"> 
										<%
											}
										%>
									</td>	
								</tr>
							</tbody>
					</table>
				</form>
			</div>
		</div>

	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('input keyup input focusin focusout blur change', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input focusin focusout blur change', function() {resizeTextarea(this); });
		});
	</script>
	
	<script>
	//단축키를 통한 저장 (shfit + s)
	var isShift = false;
	document.onkeyup = function(e) {
		if(e.which == 16)isShift = false;
	}
	document.onkeydown = function(e) {
		if(e.which == 16)isShift = true;
		if(e.which == 83 && isShift == true) {
			// shift와 s가 동시에 눌린다면,
			document.getElementById("update").click();
		}
	}
	</script>
	
</body>