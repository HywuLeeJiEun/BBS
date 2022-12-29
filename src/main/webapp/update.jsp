<%@page import="user.User"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
<link rel="stylesheet" href="css/index.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link href="css/index.css" rel="stylesheet" type="text/css">
<title>RMS</title>
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
		UserDAO userDAO = new UserDAO();
		String name = userDAO.getName(id);

		
			// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			String dl = bbsDAO.getDLS(bbsID);
			if(dl.isEmpty()) { //삭제 되어 비어있다면,
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('게시글이 제거되거나 수정되었을 수 있습니다. 확인하여 주십시오.')");
				script.println("history.back()");
				script.println("</script>");
			}
			Date time = new Date();
			String timenow = dateFormat.format(time);

			Date dldate = dateFormat.parse(dl);
			Date today = dateFormat.parse(timenow);
			
	
	
		
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
						works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
					}
					
					workSet = String.join("/",works);


				}
				
				String rk = userDAO.getRank((String)session.getAttribute("id"));
	
				
				// 사용자 정보 담기
				User user = userDAO.getUser(name);
				String password = user.getPassword();
				String rank = user.getRank();
				//이메일  로직 처리
				String Staticemail = user.getEmail();
				String[] email = Staticemail.split("@");
				
				String pl = userDAO.getpl(id); //web, erp pl을 할당 받았는지 확인! 
				
				//erp 자료 가져오기
				ArrayList<String> list = bbsDAO.geterpbbs(bbsID);
	%>
	<c:set var="bbsID" value="<%= bbsID %>" />
	<input type="hidden" id="bbsId" value="<c:out value='${bbsID}' />">
	
	
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
			<a class="navbar-brand" href="bbs.jsp">Report Management System</a>
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
							<li><a href="bbs.jsp">조회</a></li>
							<% if(!rk.equals("실장")) { %>
							<li><a href="bbsUpdate.jsp">작성</a></li>
							<li class="active"><a href="bbsUpdateDelete.jsp">수정/삭제</a></li>
							<li><a href="signOn.jsp">승인(제출)</a></li>
							<% } %>
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= pl %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
						
							<ul class="dropdown-menu">
								<li><a href="bbsRk.jsp">작성</a></li>
								<li><a href="summaryRk.jsp">제출 목록</a></li>
							</ul>
						<%
						 }
						%>
							</li>
						<%
							if(rk.equals("실장") || rk.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">요약본(Admin)<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><a href="bbsRkAdmin.jsp">조회</a></li>
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
					if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자") || rk.equals("실장")) {
					%>
						<li><a href="#UserUpdateModal">개인정보 수정</a></li>
						<li><a href="workChange.jsp">담당업무 변경</a></li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a>
						
						</li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
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
		     <form method="post" action="ModalUpdateAction.jsp" id="modalform">
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
				<form method="post" action="updateAction.jsp?bbsID=<%= bbsID %>">
					<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
						<thead>
							<tr>
								<%
								if(id.equals(bbs.getUserID()) || rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
									if(dldate.after(today)){
										if(bbs.getSign().equals("미승인")) {
								%>
								<th colspan="5" style=" text-align: center; color:blue ">주간보고를 수정하고 있습니다.</th>
								<%
										}
									}
								}
								%>
							</tr>
						</thead>
					</table>
					
					<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="5" style="background-color: #eeeeee; text-align: center;">baynex 주간보고 작성</th>
							</tr>
						</thead>
						<tbody>
							<tr>
									<td colspan="1"> 주간보고 명세서 </td>
									<td align="center" colspan="2"><input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= bbs.getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>"></td>
									<td colspan="1"> 보고 제출일 </td>
									<td align="center" colspan="1"><input type="date" required class="form-control" readonly placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= bbs.getBbsDeadline() %>"></td>
							<tr>
							
								
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
								<tr align="center" style="background-color: white">	
										<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
									 <td><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50" readonly ><%=bbs.getBbsManager() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsContent"><%= bbs.getBbsContent() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsStart" id="bbsStart"><%= bbs.getBbsStart() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsTarget" id="bbsTarget"><%= bbs.getBbsTarget() %></textarea></td>	
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="진행율/완료일" name="bbsEnd"><%= bbs.getBbsEnd() %></textarea></td>									
								</tr>	
								<tr align="center">	
										<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
									 <td><input type=text readonly  style="height:5px; width:100%; border:none;"  maxlength="50"></td>
									 <td><input type=text readonly style="height:5px;width:100%; border:none;" ></td>
									 <td><input type=text readonly style="height:5px; width:100%; border:none;"  ></td>
									 <td><input type=text readonly style="height:5px; width:100%; border:none;"  ></td>	
									 <td><input type=text readonly style="height:5px; width:100px; border:none;" ></td>									
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
								<tr align="center" style="background-color: white">	
									 <td><textarea class="textarea" style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50" readonly ><%=bbs.getBbsManager() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsNContent" ><%= bbs.getBbsNContent() %></textarea></td>
									 <%-- <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsNStart" id="bbsNStart" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNStart() %></textarea></td> --%>
									<td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsNStart" id="bbsNStart"><%= bbs.getBbsNStart() %></textarea></td>
									 <td><textarea class="textarea" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsNTarget" id="bbsNTarget"><%= bbs.getBbsNTarget() %></textarea></td>										
								</tr>
								<tr align="center">	
										 <td><input class="textarea" id="content_add" style="height:5px;width:150px;border:none;" readonly ></td>
										 <td><input class="textarea" id="content_add" style="height:5px;width:100%;border:none;" readonly ></td>
										 <td><input class="textarea" style="height:5px; width:100px;border:none;" class="form-control"  readonly></td>
										 <td><input class="textarea" style="height:5px; width:100px;border:none;" id="target_add" class="form-control" readonly></td>	
										 <td><input class="textarea" style="height:5px; width:100px;border:none;" id="target_add" class="form-control" readonly></td>
									</tr>
									<%
									if(list.size() == 0) {
									%>	
									<tr>
									 <td colspan="5" >
										<%
										if(id.equals(bbs.getUserID()) || rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
											if(dldate.after(today)){
												if(bbs.getSign().equals("미승인")) {
										%>
											<a onclick="return confirm('해당 게시글을 삭제하시겠습니까?')"
											href="deleteAction.jsp?bbsID=<%= bbsID %>" class="btn btn-danger pull-left">삭제</a>
											
											<input type="submit" id="update" style="margin-bottom:5px" class="btn btn-success pull-right" value="수정"> 
										<%
												}
											}
										}
										%>
									</td>	
								</tr>
								<% } %>
					</tbody>
				</table>
				
				<!-- erp_bbs에 자료가 있는 경우 하단 출력! -->
				<%
						if(list.size() != 0) { //erp가 비어있지 않다면, 하단 출력
							String[] erp_date = list.get(1).split("\r\n");
							String[] erp_user = list.get(2).split("\r\n");
							String[] erp_stext = list.get(3).split("\r\n");
							String[] erp_authority = list.get(4).split("\r\n");
							String[] erp_division = list.get(5).split("\r\n");
						%>
				<table>
					<tbody>
						<tr>
							<th colspan="2" style="background-color: #ccffcc;" align="center">ERP 디버깅 권한 신청 처리 현황</th>
						</tr>
						<tr style="background-color: #FF9933; border: 1px solid">
							<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date <textarea class="textarea" id="erp_id" style="display:none" name="erp_id"><%= list.get(0) %></textarea></th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
							<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
						</tr>
						<%
						for (int i=0; i < erp_date.length; i++) {
						%>
						<tr>
							<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white"> 
							  <textarea class="textarea" style="display:none" name="erp_size"><%= erp_date.length %></textarea>
							  <textarea class="textarea" id="erp_date<%= i %>" style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date<%= i %>"><%= erp_date[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_user<%= i %>" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user<%= i %>"><%= erp_user[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_stext<%= i %>" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext<%= i %>"><%= erp_stext[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_authority<%= i %>" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority<%= i %>"><%= erp_authority[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_division<%= i %>" style=" width:130px; border:none; resize:none " placeholder="구분(일반/긴급)" name="erp_division<%= i %>"><%= erp_division[i] %></textarea></td>
						</tr>
						<%
						}
						%>
						<tr style="margin-top:20%;">
							 <td colspan="5" style="margin-top:100px" >
								<%
								if(id.equals(bbs.getUserID()) || rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
									if(dldate.after(today)){
										if(bbs.getSign().equals("미승인")) {
								%>
									<a onclick="return confirm('해당 게시글을 삭제하시겠습니까?')"
									href="deleteAction.jsp?bbsID=<%= bbsID %>" class="btn btn-danger pull-left" style="margin-bottom:100px; margin-top:30px">삭제</a>
									
									<input type="submit" id="update" style="margin-bottom:100px; margin-top:30px" class="btn btn-success pull-right" value="수정"> 
								<%
										}
									}
								}
								%>
							</td>	
						</tr>
					</tbody>
				</table>
				<%
					}
				%>
			</form>
		</div>
	</div>
	

	
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
	
	<!-- <script>
		//textarea 접수일 ... 유효성 검사
		$(document.getElementById("bbsStart")).on('input', function() {
			// ### 접수일 처리
			var bbsst = document.getElementById("bbsStart").value;
			var bbssta = bbsst.split("\n"); //줄바꿈으로 분리
			
				for(var i=0; i < bbssta.length; i++) { //bbssta = 10/21 같은 형태
					if(bbssta[i].length > 5) {
						alert("(접수일) 최대 5글자까지만 작성 가능합니다!");
					}
					if(bbssta[i].includes('/') == true) {
						var a = bbssta[i].split("/");
						var num1 = Number(a[0]);
						var num2 = Number(a[1]);
						if(num1 > 13 || num2 > 32) {
							alert("(접수일) 유효한 월/일을 작성해주십시오.");
							$("#bbsStart").focus();
						}
								
					// 이부분이 문제 '-'의 개수세기가 원활하게 진행되지 않음!
					} else if(bbssta[i].includes('-') == true){
						var count = 0;
						var searchChar = "-"; //찾고자하는 문자
						var pos = bbssta[i].indexOf(searchChar); //pos는 0의 값
						
						while (pos != -1) {
							count++;
							pos = bbssta[i].indexOf(searchChar, pos + 1);
						}
						if(count > 3) {
							alert("(접수일) 보류는 최대 3개까지만 표현합니다. (-)");
							$("#bbsStart").focus();
						} 		
					} else {
						 if(bbssta[i].length > 2) {
							 alert("(접수일) 월/일 형태 또는 -로 작성되어야 합니다.");
								$("#bbsStart").focus();
						 }
					}
	
			}
		});
	</script>
	
	<script>
		//textarea 완료목표일 ... 유효성 검사
		$(document.getElementById("bbsTarget")).on('input', function() {
			// ### 접수일 처리
			var bbsst = document.getElementById("bbsTarget").value;
			var bbssta = bbsst.split("\n"); //줄바꿈으로 분리
			
				for(var i=0; i < bbssta.length; i++) { //bbssta = 10/21 같은 형태
					if(bbssta[i].length > 5) {
						alert("(목표일) 최대 5글자까지만 작성 가능합니다!");
					}
					if(bbssta[i].includes('/') == true) {
						var a = bbssta[i].split("/");
						var num1 = Number(a[0]);
						var num2 = Number(a[1]);
						if(num1 > 13 || num2 > 32) {
							alert("(목표일) 유효한 월/일을 작성해주십시오.");
							$("#bbsTarget").focus();
						}
								
					// 이부분이 문제 '-'의 개수세기가 원활하게 진행되지 않음!
					} else if(bbssta[i].includes('-') == true){
						var count = 0;
						var searchChar = "-"; //찾고자하는 문자
						var pos = bbssta[i].indexOf(searchChar); //pos는 0의 값
						
						while (pos != -1) {
							count++;
							pos = bbssta[i].indexOf(searchChar, pos + 1);
						}
						if(count > 3) {
							alert("(목표일) 보류는 최대 3개까지만 표현합니다. (-)");
							$("#bbsTarget").focus();
						} 		
					} else {
						 if(bbssta[i].length > 2) {
							 alert("(목표일) 월/일 형태 또는 -로 작성되어야 합니다.");
								$("#bbsTarget").focus();
						 }
					}
	
			}
		});
	</script>
	
	<script>
		//textarea 진행율/완료일 ... 유효성 검사
		$(document.getElementById("bbsEnd")).on('input', function() {
			// ### 접수일 처리
			var bbsst = document.getElementById("bbsEnd").value;
			var bbssta = bbsst.split("\n"); //줄바꿈으로 분리
			
			for(var i=0; i < bbssta.length; i++) { //bbssta = 10/21, 100% 같은 형태
				if(bbssta[i].length > 5) {
					alert("(진행율) 최대 5글자까지만 작성 가능합니다!");
					$("#bbsEnd").focus();
				}
				if(bbssta[i].includes('/') == true) {
					var a = bbssta[i].split("/");
					var num1 = Number(a[0]);
					var num2 = Number(a[1]);
					if(num1 > 13 || num2 > 32) {
						alert("(진행율) 유효한 월/일을 작성해주십시오.");
						$("#bbsEnd").focus();
					}
							
				// 이부분이 문제 '-'의 개수세기가 원활하게 진행되지 않음!
				} if(bbssta[i].includes('%') == true){ //%가 포함 되었는가?
					var a = bbssta[i].split("%");
					var one = Number(a[0]); 
					var two = a[1]; //a[1]뒤에 문자가 오지 않도록 함!
					var count = 0;
					if(one > 100) {
						alert("(진행율) 0% ~ 100% 이내여야 합니다.");
						$("#bbsEnd").focus();
					}
					
					if(two != "") {
						alert("(진행율) %로 마무리 되어야 합니다. (ex> 100%)");
						$("#bbsEnd").focus();
					}
					
					var searchChar = "%"; //찾고자하는 문자
					var pos = bbssta[i].indexOf(searchChar); //pos는 0의 값
					while (pos != -1) {
						count++;
						pos = bbssta[i].indexOf(searchChar, pos + 1);
					}
					if(count > 1) {
						alert("(진행율) %는 최대 1개까지만 표현 가능합니다. (%)");
						$("#bbsEnd").focus();
					}
				} else {
					if(bbssta[i].includes('/') == false && bbssta[i].includes('%') == false) {
						if(bbssta[i].length > 3) {
							 alert("(진행율) 월/일 형태 또는 % 형태로 작성되어야 합니다.");
								$("#bbsEnd").focus();
						 }
					}
				}
			}
		});
	</script>
	
	<script>
		//textarea (차주)접수일 ... 유효성 검사
		$(document.getElementById("bbsNStart")).on('input', function() {
			// ### 접수일 처리
			var bbsst = document.getElementById("bbsNStart").value;
			var bbssta = bbsst.split("\n"); //줄바꿈으로 분리
			
				for(var i=0; i < bbssta.length; i++) { //bbssta = 10/21 같은 형태
					if(bbssta[i].length > 5) {
						alert("(차주(접수일)) 최대 5글자까지만 작성 가능합니다!");
					}
					if(bbssta[i].includes('/') == true) {
						var a = bbssta[i].split("/");
						var num1 = Number(a[0]);
						var num2 = Number(a[1]);
						if(num1 > 13 || num2 > 32) {
							alert("(차주(접수일)) 유효한 월/일을 작성해주십시오.");
							$("#bbsNStart").focus();
						}
								
					// 이부분이 문제 '-'의 개수세기가 원활하게 진행되지 않음!
					} else if(bbssta[i].includes('-') == true){
						var count = 0;
						var searchChar = "-"; //찾고자하는 문자
						var pos = bbssta[i].indexOf(searchChar); //pos는 0의 값
						
						while (pos != -1) {
							count++;
							pos = bbssta[i].indexOf(searchChar, pos + 1);
						}
						if(count > 3) {
							alert("(차주(접수일)) 보류는 최대 3개까지만 표현합니다. (-)");
							$("#bbsNStart").focus();
						} 		
					} else {
						 if(bbssta[i].length > 2) {
							 alert("(차주(접수일)) 월/일 형태 또는 -로 작성되어야 합니다.");
								$("#bbsNStart").focus();
						 }
					}
	
			}
		});
	</script>
	
	<script>
		//textarea (차주)완료목표일 ... 유효성 검사
		$(document.getElementById("bbsNTarget")).on('input', function() {
			// ### 접수일 처리
			var bbsst = document.getElementById("bbsNTarget").value;
			var bbssta = bbsst.split("\n"); //줄바꿈으로 분리
			
				for(var i=0; i < bbssta.length; i++) { //bbssta = 10/21 같은 형태
					if(bbssta[i].length > 5) {
						alert("(차주(목표일)) 최대 5글자까지만 작성 가능합니다!");
					}
					if(bbssta[i].includes('/') == true) {
						var a = bbssta[i].split("/");
						var num1 = Number(a[0]);
						var num2 = Number(a[1]);
						if(num1 > 13 || num2 > 32) {
							alert("(차주(목표일)) 유효한 월/일을 작성해주십시오.");
							$("#bbsNStart").focus();
						}
								
					// 이부분이 문제 '-'의 개수세기가 원활하게 진행되지 않음!
					} else if(bbssta[i].includes('-') == true){
						var count = 0;
						var searchChar = "-"; //찾고자하는 문자
						var pos = bbssta[i].indexOf(searchChar); //pos는 0의 값
						
						while (pos != -1) {
							count++;
							pos = bbssta[i].indexOf(searchChar, pos + 1);
						}
						if(count > 3) {
							alert("(차주(목표일)) 보류는 최대 3개까지만 표현합니다. (-)");
							$("#bbsNTarget").focus();
						} 		
					} else {
						 if(bbssta[i].length > 2) {
							 alert("(차주(목표일)) 월/일 형태 또는 -로 작성되어야 합니다.");
								$("#bbsNTarget").focus();
						 }
					}
	
			}
		});
	</script> -->
	
	
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