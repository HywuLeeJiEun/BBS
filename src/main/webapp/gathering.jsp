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
						<li><a href="logoutAction.jsp">로그아웃</a></li>
			</ul>
			<%
				}
			%>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	


<%-- <div class="container">
		<div class="row">
			<form method="post" name="search" action="gathering.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField">
								<option value="bbsTitle">제목</option>
								<option value="userName">작성자</option>
						</select></td>
						<td><input type="text" class="form-control"
							placeholder="<%= request.getParameter("searchText") %>" name="searchText" maxlength="100" value="<%= request.getParameter("searchText") %>"></td>
						<!-- <td><button type="submit" class="btn btn-success">검색</button></td> -->
						<td><button type="submit" href="gathering.jsp" class="btn btn-warning pull-right">취합</button></td>
					</tr>

				</table>
			</form>
		</div>
	</div> --%>
	<br>
	
	
	
	<!-- 게시판 글 보기 양식 영역 시작 -->
	<div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<th colspan="2" style="background-color: #eeeeee; text-align: center;">취합 결과</th>
					</tr>
				</thead>
				
				<tbody>
					<%
						BbsDAO bbsDAO = new BbsDAO(); // 기존 bbs와 다른, Search를 위한 생성자 작성
						ArrayList<Bbs> list =  bbsDAO.getGathering(request.getParameter("searchField"),
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
						<th colspan="5" style="background-color: #DCFE42; text-align: left;"><br><font color="white"> &nbsp;Baynex-Outsourcing</font></th>
					</tr>		
					<tr>
							<td colspan="1">  주간보고 명세서 </td>
							<td align="center" colspan="2"><input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" readonly value="<%= list.get(i).getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>"></td>
							<td colspan="1">  주간보고 제출일 </td>
							<td align="center" colspan="1"><input type="date" readonly required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= list.get(i).getBbsDeadline() %>"></td>
					</tr>
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
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="구분/담당자" maxlength="50" readonly><%= list.get(i).getUserName() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px;width:100%; border:none" placeholder="업무내용" name="bbsContent" readonly ><%= list.get(i).getBbsContent() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="접수일" name="bbsStart" readonly ><%= list.get(i).getBbsStart() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="완료목표일" name="bbsTarget" readonly ><%= list.get(i).getBbsTarget() %></textarea></td>	
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="진행율/완료일" name="bbsEnd" readonly ><%= list.get(i).getBbsEnd() %></textarea></td>										
					</tr>
					<tr  align="center">	
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>
						 <td><input type="text" style="height:5px;width:100%; border:none;" disabled></td>
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>	
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>
	
					</tr>
					
					<tr>
						<th colspan="5" style="background-color: #D4D2FF;" align="center">차주 업무 계획</th>
					</tr>
					<tr style="background-color: #FFC57B;">
						<th width="6%">|  담당자</th>
						<th width="33%">| &nbsp; 업무내용</th>
						<th width="1%">| &nbsp; 접수일</th>
						<th width="1%">| &nbsp; 완료목표일</th>
					</tr>
					<tr align="center">	
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="구분/담당자" maxlength="50" readonly><%= list.get(i).getUserName() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px;width:100%; border:none" placeholder="업무내용" name="bbsContent" readonly ><%= list.get(i).getBbsNContent() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="접수일" name="bbsStart" readonly ><%= list.get(i).getBbsNStart() %></textarea></td>
						 <td><textarea class="textarea" style="height:180px; width:100%; border:none" placeholder="완료목표일" name="bbsTarget" readonly ><%= list.get(i).getBbsNTarget() %></textarea></td>									
					</tr>
					<tr  align="center">	
						 <td></td>
						 <td><input type="text" style="height:5px;width:100%; border:none;" disabled></td>
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>
						 <td><input type="text" style="height:5px; width:auto; border:none;" disabled></td>	

					</tr>
					<%
						}
					%>
				</tbody>
			</table>
			
<%-- 						<!-- 페이징 처리 영역 -->
			<%
				if(pageNumber != 1){
			%>
				<a href="gathering.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(bbsDAO.nextPage(pageNumber + 1)){
			%>
				<a href="gethering.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left">다음</a>
			<%
				}
			%>
			 --%>
			
			
			<a href="bbs.jsp" class="btn btn-primary pull-right">목록</a>
			<button class="btn btn-info pull-left" onclick="window.scrollTo({top:0 ,behavior:'smooth'});">상단으로</button>
			
<%-- 			<!-- 해당 글의 작성자가 본인이라면 수정과 삭제가 가능하도록 코드 추가 -->
			<%
				if(id != null && id.equals(bbs.getid())){
			%>
			<a href="update.jsp?bbsID=<%= bbsID %>" class="btn btn-primary">수정</a>
			<a onclick="return confirm('해당 게시글을 삭제하시겠습니까?')"
				href="deleteAction.jsp?bbsID=<%= bbsID %>" class="btn btn-danger">삭제</a>
			<%
				}
			%> --%>
		</div>
	</div>
	<!-- 게시판 글 보기 양식 영역 끝 -->
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('input keyup input focusin focusout blur change mousemove', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input focusin focusout blur change mousemove', function() {resizeTextarea(this); });
		});
	</script>
</body>
</html>