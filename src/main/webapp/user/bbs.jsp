<%@page import="rms.rms_next"%>
<%@page import="rms.rms_this"%>
<%@page import="rms.RmsDAO"%>
<%@page import="java.util.List"%>
<%@page import="user.User"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="user.UserDAO"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.ArrayList" %>
<% request.setCharacterEncoding("utf-8"); %>



<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="../css/index.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<title>RMS</title>
</head>

<body>
	<%
		UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
		String rk = userDAO.getRank((String)session.getAttribute("id"));
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
			script.println("location.href='../login.jsp'");
			script.println("</script>");
		}
		if(rk.equals("실장") || rk.equals("관리자")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/admin/bbsAdmin.jsp'");
			script.println("</script>");
		}
	
		// ********** 담당자를 가져오기 위한 메소드 *********** 
				String workSet;
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
				
		String name = userDAO.getName(id);
		
		// 사용자 정보 담기
		User user = userDAO.getUser(name);
		String password = user.getPassword();
		String rank = user.getRank();
		//이메일  로직 처리
		String Staticemail = user.getEmail();
		String[] email;
		email = Staticemail.split("@");
		
		String pl = userDAO.getpl(id); //web, erp pl을 할당 받았는지 확인! 
	
		
		//기존 데이터 불러오기 (가장 최근에 작성된 rms 조회)
		RmsDAO rms = new RmsDAO();
		//rms_this -> 목록 불러오기 (사용자)
		// [bbsDeadline, bbsTitle, bbsDate]
		ArrayList<rms_this> tlist = rms.getthis(id, pageNumber);
		//rms_last -> 목록 불러오기 (사용자)
		// [bbsDeadline, sign, pluser]
		ArrayList<rms_next> llist = rms.getlast(id, pageNumber);
		
		//다음 페이지가 있는지 확인!
		ArrayList<rms_this> next_tlist = rms.getthis(id, pageNumber+1);
		
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
			<a class="navbar-brand" href="/BBS/user/bbs.jsp">Report Management System</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav navbar-left">
					<li class="dropdown">
						<a href="#" class="dropdown-toggle"
							data-toggle="dropdown" role="button" aria-haspopup="true"
							aria-expanded="false">주간보고<span class="caret"></span></a>
						<!-- 드랍다운 아이템 영역 -->	
						<ul class="dropdown-menu">
							<li class="active"><a href="/BBS/user/bbs.jsp">조회</a></li>
							<li><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
							<li><a href="/BBS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
								if(pl !="" || !pl.isEmpty()) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= pl %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><h5 style="background-color: #e7e7e7; height:40px; margin-top:-20px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %></h5></li>
								<li><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/BBS/pl/bbsRkwrite.jsp">작성</a></li>
								<li><a href="/BBS/pl/summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li id="summary_nav"><a href="/BBS/pl/summaryRkSign.jsp">조회 및 출력</a></li>
							</ul>
							</li>
						<%
								}
							}
						%>
						<%
							if(rk.equals("실장") || rk.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">summary<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><a href="/BBS/admin/summaryadRk.jsp">조회</a></li>
								<li><a href="/BBS/admin/summaryadAdmin.jsp">작성</a></li>
								<li><a href="/BBS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li>
								<!-- <li data-toggle="tooltip" data-html="true" data-placement="right" title="승인처리를 통해 제출을 확정합니다."><a href="bbsRkAdmin_backup.jsp">승인</a></li> -->
							</ul>
							</li>
						<%
							}
						%>
				</ul>
			
		
			
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li><a data-toggle="modal" href="#UserUpdateModal" style="color:#2E2E2E"><%= name %>(님)</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(rk.equals("부장") || rk.equals("실장") || rk.equals("관리자")) {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a></li>
						<li><a href="/BBS/admin/work/workChange.jsp">담당업무 변경</a></li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a>
						
						</li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	
	
	
	
	<!-- 모달 영역! -->
	   <div class="modal fade" id="UserUpdateModal" role="dialog">
		   <div class="modal-dialog">
		    <div class="modal-content">
		     <div class="modal-header">
		      <button type="button" class="close" data-dismiss="modal">×</button>
		      <h3 class="modal-title" align="center">개인정보 수정</h3>
		     </div>
		     <!-- 모달에 포함될 내용 -->
		     <form method="post" action="../ModalUpdateAction.jsp" id="modalform">
		     <div class="modal-body">
		     		<div class="row">
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">ID </label>
		     				<input type="text" maxlength="20" class="form-control" readonly style="width:100%" id="updateid" name="updateid"  value="<%= id %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
						<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label"> Password </label>
		     				<input type="password" maxlength="20" required class="form-control" style="width:100%" id="password" name="password" value="<%= password %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<i class="glyphicon glyphicon-eye-open" id="icon" style="right:20%; top:35px;" ></i>
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">name </label>
		     				<input type="text" maxlength="20" required class="form-control" style="width:100%" id="name" name="name"  value="<%= name %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">rank </label>
		     				<input type="text" required class="form-control" data-toggle="tooltip" data-placement="bottom" title="직급 변경은 관리자 권한이 필요합니다." readonly style="width:100%" id="rank" name="rank"  value="<%= rank %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-4 form-outline">
		     				<label class="col-form-label">email </label>
		     				<input type="text" maxlength="30" required class="form-control" style="width:100%" id="email" name="email"  value="<%= email[0] %>"> 
		     			</div>
		     			<div class="col-md-3" align="left" style="top:5px; right:20px">
		     				<label class="col-form-label" > &nbsp; </label>
		     				<div><i>@ s-oil.com</i></div>
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">duty </label>
		     				<input type="text" required class="form-control" readonly data-toggle="tooltip" data-placement="bottom" title="업무 변경은 관리자 권한이 필요합니다." style="width:100%" id="duty" name="duty" value="<%= workSet %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     		</div>	
		     </div>
		     <div class="modal-footer">
			     <div class="col-md-3" style="visibility:hidden">
     			</div>
     			<div class="col-md-6">
			     	<button type="submit" class="btn btn-primary pull-left form-control" id="modalbtn" >수정</button>
		     	</div>
		     	 <div class="col-md-3" style="visibility:hidden">
	   			</div>	
		    </div>
		    </form>
		   </div>
	  </div>
	</div>

		
		
	<!-- ***********검색바 추가 ************* -->
	<div class="container">
		<div class="row">
			<table class="pull-left" style="text-align: center; cellpadding:50px; width:60%" >
			<thead>
				<tr>
					<th style=" text-align: left" data-toggle="tooltip" data-html="true" data-placement="bottom" title=""> 
					<br><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i> 주간보고 목록 (개인)
				</th>
				</tr>
			</thead>
			</table>
			<form method="post" name="search" action="/BBS/user/searchbbs.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="bbsDeadline">제출일</option>
								<option value="bbsTitle">제목</option>
						</select></td>
						<td><input type="text" class="form-control"
							placeholder="검색어 입력" name="searchText" maxlength="100"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success">검색</button></td>
					</tr>

				</table>
			</form>
		</div>
	</div>
	<br>
	
	
	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table id="bbsTable" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<!-- <th style="background-color: #eeeeee; text-align: center;">번호</th> -->
						<th style="background-color: #eeeeee; text-align: center;">제출일</th>
						<th style="background-color: #eeeeee; text-align: center;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;제목</th>
						<th style="background-color: #eeeeee; text-align: center;">작성자</th>
						<th style="background-color: #eeeeee; text-align: center;">작성일(수정일)</th>
						<th style="background-color: #eeeeee; text-align: center;">담당</th>
						<th style="background-color: #eeeeee; text-align: center;">상태</th>
					</tr>
				</thead>
				<tbody>
					<%
						for(int i = 0; i < tlist.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							String dl = tlist.get(i).getBbsDeadline();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
					%>

						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= tlist.get(i).getBbsDeadline() %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/BBS/user/update.jsp?bbsDeadline=<%= tlist.get(i).getBbsDeadline() %>">
							<%= tlist.get(i).getBbsTitle() %></a></td>
						<td><%= name %></td>
						<td><%= tlist.get(i).getBbsDate().substring(0, 11) + tlist.get(i).getBbsDate().substring(11, 13) + "시"
							+ tlist.get(i).getBbsDate().substring(14, 16) + "분" %></td>
						<td><%= llist.get(i).getPluser() %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td>
						<%
						String sign = null;
						if(dldate.after(today) && llist.get(i).getSign().equals("승인")) { //현재 날짜가 마감일을 아직 넘지 않으면,
							//sign = list.get(i).getSign();
							sign="제출";
							//rms에 통합 저장 진행
							//1. rms에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getRms(tlist.get(i).getBbsDeadline(), id);
							if(rmsData == 0) { //작성된 기록이 없다!
								//2. rms 데이터 생성
									//데이터 불러오기 (this, next)
								ArrayList<rms_this> rms_this = rms.gettrms(tlist.get(i).getBbsDeadline(), id);
								ArrayList<rms_next> rms_next = rms.getlrms(tlist.get(i).getBbsDeadline(), id);
								
									//데이터 가공하기
									String bbsManager = workSet + name;
									String bbsContent = "";
									String bbsStart = "";
									String bbsTarget = "";
									String bbsEnd = "";
									String bbsNContent = "";
									String bbsNStart = "";
									String bbsNTarget = "";
									//금주 업무 (this)
									for(int j=0; j < rms_this.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int num = rms_this.get(j).getBbsContent().split("\r\n").length-1;
										if(j < rms_this.size()-1) {
											 bbsContent += rms_this.get(j).getBbsContent() + "\r\n";
											 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/") + "\r\n";
											 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
											 	bbsTarget += "[보류]" + "\r\n";
											 } else {
												 if(rms_this.get(j).getBbsTarget().length() > 5) {
												 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/") + "\r\n";
												 }else {
													 bbsTarget += "[보류]" + "\r\n";
												 }
											 }
											 bbsEnd += rms_this.get(j).getBbsEnd() + "\r\n";
											
											 for(int k=0;k < num; k ++) {
												 bbsStart +="\r\n";
												 bbsTarget +="\r\n";
												 bbsEnd +="\r\n";
											 }
										} else {
											bbsContent += rms_this.get(j).getBbsContent();
											 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/");
											 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
												 bbsTarget += "[보류]";
											 } else {
												 if(rms_this.get(j).getBbsTarget().length() > 5) {
												 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/");
												 } else { 
													 bbsTarget += "[보류]";
												 }
											 }
											 bbsEnd += rms_this.get(j).getBbsEnd();
											 for(int k=0;k < num; k ++) {
												 bbsStart +="\r\n";
												 bbsTarget +="\r\n";
												 bbsEnd +="\r\n";
											 }
										}
									}
									//차주 (next)
									for(int j=0; j < rms_next.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int nnum = rms_next.get(j).getBbsNContent().split("\r\n").length-1;
										if(j < rms_next.size()-1) {
											 bbsNContent += rms_next.get(j).getBbsNContent() + "\r\n";
											 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/") + "\r\n";
											 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
												 bbsNTarget += "[보류]" + "\r\n";
											 } else {
												 if(rms_next.get(j).getBbsNTarget().length() > 5) {
												 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/") + "\r\n";
												 } else {
													 bbsNTarget += "[보류]" + "\r\n";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += "\r\n";
												 bbsNTarget += "\r\n";
											 }
										} else {
											 bbsNContent += rms_next.get(j).getBbsNContent();
											 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/");
											 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
												 bbsNTarget += "[보류]";
											 } else {
												 if(rms_next.get(j).getBbsNTarget().length() > 5){
												 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/");
												 }else {
													 bbsNTarget += "[보류]";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += "\r\n";
												 bbsNTarget += "\r\n";
											 }
										}
									}
							//3. 데이터 저장하기
							int rmsSuc = rms.rmswrite(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
							}
						} else if(dldate.after(today) && llist.get(i).getSign().equals("미승인")) {
							//sign = list.get(i).getSign();
							sign="미제출";
						}else { // 미승인, 마감 상태일 경우엔 하단 진행.
							sign="마감";
							// 데이터베이스에 마감처리 진행
							int a = rms.lastSign(id, "마감",llist.get(i).getBbsDeadline());
							//rms에 통합 저장 진행
							//1. rms에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getRms(tlist.get(i).getBbsDeadline(), id);
							if(rmsData == 0) { //작성된 기록이 없다!
								//2. rms 데이터 생성
									//데이터 불러오기 (this, next)
								ArrayList<rms_this> rms_this = rms.gettrms(tlist.get(i).getBbsDeadline(), id);
								ArrayList<rms_next> rms_next = rms.getlrms(tlist.get(i).getBbsDeadline(), id);
								
									//데이터 가공하기
									String bbsManager = workSet + name;
									String bbsContent = "";
									String bbsStart = "";
									String bbsTarget = "";
									String bbsEnd = "";
									String bbsNContent = "";
									String bbsNStart = "";
									String bbsNTarget = "";
									//금주 업무 (this)
									for(int j=0; j < rms_this.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int num = rms_this.get(j).getBbsContent().split("\r\n").length-1;
										if(j < rms_this.size()-1) {
											 bbsContent += rms_this.get(j).getBbsContent() + "\r\n";
											 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/") + "\r\n";
											 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
											 	bbsTarget += "[보류]" + "\r\n";
											 } else {
												 if(rms_this.get(j).getBbsTarget().length() > 5) {
												 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/") + "\r\n";
												 }else {
													 bbsTarget += "[보류]" + "\r\n";
												 }
											 }
											 bbsEnd += rms_this.get(j).getBbsEnd() + "\r\n";
											
											 for(int k=0;k < num; k ++) {
												 bbsStart +="\r\n";
												 bbsTarget +="\r\n";
												 bbsEnd +="\r\n";
											 }
										} else {
											bbsContent += rms_this.get(j).getBbsContent();
											 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/");
											 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
												 bbsTarget += "[보류]";
											 } else {
												 if(rms_this.get(j).getBbsTarget().length() > 5) {
												 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/");
												 } else { 
													 bbsTarget += "[보류]";
												 }
											 }
											 bbsEnd += rms_this.get(j).getBbsEnd();
											 for(int k=0;k < num; k ++) {
												 bbsStart +="\r\n";
												 bbsTarget +="\r\n";
												 bbsEnd +="\r\n";
											 }
										}
									}
									//차주 (next)
									for(int j=0; j < rms_next.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int nnum = rms_next.get(j).getBbsNContent().split("\r\n").length-1;
										if(j < rms_next.size()-1) {
											 bbsNContent += rms_next.get(j).getBbsNContent() + "\r\n";
											 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/") + "\r\n";
											 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
												 bbsNTarget += "[보류]" + "\r\n";
											 } else {
												 if(rms_next.get(j).getBbsNTarget().length() > 5) {
												 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/") + "\r\n";
												 } else {
													 bbsNTarget += "[보류]" + "\r\n";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += "\r\n";
												 bbsNTarget += "\r\n";
											 }
										} else {
											 bbsNContent += rms_next.get(j).getBbsNContent();
											 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/");
											 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
												 bbsNTarget += "[보류]";
											 } else {
												 if(rms_next.get(j).getBbsNTarget().length() > 5){
												 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/");
												 }else {
													 bbsNTarget += "[보류]";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += "\r\n";
												 bbsNTarget += "\r\n";
											 }
										}
									}
							//3. 데이터 저장하기
							int rmsSuc = rms.rmswrite(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
							}
						}
						%>
						<%= sign %>
						</td>
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
				<a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(next_tlist.size() != 0){
			%>
				<a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			
			<!-- 글쓰기 버튼 생성 -->
			<a href="/BBS/user/bbsUpdate.jsp" class="btn btn-info pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="주간보고 작성">작성</a>
		</div>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 끝 -->
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchField');
			
		}
		
	
	</script>
	
    <!-- 보고 개수에 따라 버튼 노출 (list.size()) -->
	<script>
	var trCnt = $('#bbsTable tr').length; 
	
	if(trCnt < 11) {
		$('#next').hide();
	}
	</script>
	
	<!-- modal 내, password 보이기(안보이기) 기능 -->
		<script>
		$(document).ready(function(){
		    $('#icon').on('click',function(){
		    	console.log("hello");
		        $('#password').toggleClass('active');
		        if($('#password').hasClass('active')){
		            $(this).attr('class',"glyphicon glyphicon-eye-close")
		            $('#password').attr('type',"text");
		        }else{
		            $(this).attr('class',"glyphicon glyphicon-eye-open")
		            $('#password').attr('type','password');
		        }
		    });
		});
	</script>
	
	
	<!-- 모달 툴팁 -->
	<script>
		$(document).ready(function(){
			$('[data-toggle="tooltip"]').tooltip();
		});
	</script>
	
	
	<!-- 모달 submit -->
	<script>
	$('#modalbtn').click(function(){
		$('#modalform').text();
	})
	</script>
	
	<!-- 모달 update를 위한 history 감지 -->
	<script>
	window.onpageshow = function(event){
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)){ //history.back 감지
			location.reload();
		}
	}
	</script>
</body>
</html>