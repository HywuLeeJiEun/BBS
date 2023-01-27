<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="sum.Sum"%>
<%@page import="sum.SumDAO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="user.User"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>

<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<link rel="stylesheet" href="../css/index.css">

<title>RMS</title>
</head>
<body>
<% 
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	
	// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	String id = null;
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	if(id == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인이 필요한 서비스입니다.')");
		script.println("location.href='../login.jsp'");
		script.println("</script>");
	}
	
	
	// ********** 담당자를 가져오기 위한 메소드 *********** 
	String workSet;
	ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력(rmsmgrs에 접근하여, task_num을 가져옴.)
	List<String> works = new ArrayList<String>();
	
	if(code.size() == 0) {
		//1. 담당 업무가 없는 경우,
		workSet = "";
	} else {
		//2. 담당 업무가 있는 경우
		for(int i=0; i < code.size(); i++) {
			//task_num을 받아옴.
			String task_num = code.get(i);
			// task_num을 통해 업무명을 가져옴.
			String manager = userDAO.getManager(task_num);
			works.add(manager+"\n"); //즉, work 리스트에 모두 담겨 저장됨
		}
		workSet = String.join("/",works);
	}
	
	// 사용자 정보 담기
	ArrayList<rmsuser> ulist = userDAO.getUser(id);
	String password = ulist.get(0).getUser_pwd();
	String name = ulist.get(0).getUser_name();
	String rank = ulist.get(0).getUser_rk();
	//이메일  로직 처리
	String Staticemail = ulist.get(0).getUser_em();
	String[] email;
	email = Staticemail.split("@");
	String pl = ulist.get(0).getUser_fd();
	String rk = ulist.get(0).getUser_rk();
	//사용자의 AU(Authority) 권한 가져오기 (일반/PL/관리자)
	String au = ulist.get(0).getUser_au();


	// 선택된 데이터 정보
	String content = request.getParameter("content");
	String end = request.getParameter("end");
	String ncontent = request.getParameter("ncontent");
	String ntarget = request.getParameter("ntarget");
	String rms_dl = request.getParameter("rms_dl");

	//데이터 가공
	content = content.replaceAll("§","\r\n");
    end = end.replaceAll("§","\r\n");
	ncontent = ncontent.replaceAll("§","\r\n");
	ntarget = ntarget.replaceAll("§","\r\n");
	rms_dl = rms_dl.replaceAll("§","\r\n"); 


	

	// 진행율 구하기 (정확히 구현하려면 - 상세 Data가 DB에 저장되어야 함.)
	String a = "[보류],12/31,12/30";
	String[] endlist = a.split(",");
	//String[] endlist = end.split("\r\n"); 
	for(int i=0; i<endlist.length; i++) {
		if(endlist[i].contains("보류")) {
			
		} else { //보류가 아닌, 날짜 형태라면
			//년도가 바뀔 가능성이 있는 달이라면, (12월 제출일 - 1월 완료 예정일인 경우 ...)
			//1. endlist가 1월인지 확인 -> 1월인 경우, monday의 월을 확인 (12월인 경우 ...)
			//2. monday의 년도 확인
			//3. endlist에게 monday보다 1년 추가하여 텍스트 제공 
			
			//기본적으로 년도가 바뀌지 않는다면,
			//1. endlist의 월 확인 (특수케이스 판별을 위함.)
			//2. 
		}
	}
	 
	// 진행율 및 상태 작성을 위한 완료일 분석
	if(end.contains("보류")) {
		
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
							<li><a href="/BBS/user/bbs.jsp">조회</a></li>
							<li><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
							<li><a href="/BBS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
								if(au.equals("PL")) {
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
								<li class="active" id="summary_nav"><a href="bbsRkwrite.jsp">작성</a></li>
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
	
	
	<!-- 메인 게시글 영역 -->
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th id="summary" colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-placement="bottom" title="제출일 : <%= rms_dl %>"> 요약본 작성 </th>
				</tr>
			</thead>
		</table>
	</div>
	<br>
	
	<!-- 목록 조회 table -->
	<div class="container" id="jb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="complete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="proceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="incomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
			 <%-- <tr>
			 	<td>업무 담당자 인원 : <%= plist.size() %></td>
			 </tr> --%> 
		 </table>
	 </div>
	 
	<div class="container">
	<form method="post" action="/BBS/pl/action/bbsRkAction.jsp" id="bbsRk">
		<div class="row">
			<div class="container">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>
							<td><textarea id="rms_dl" name="rms_dl" style="display:none"><%= rms_dl %></textarea> </td>
							<td><textarea id="pl" name="pl" style="display:none"><%= pl %></textarea> </td>
						</tr>
						<tr>
							<th colspan="2" style="background-color:#D4D2FF; align:left;" > &nbsp;금주 업무 실적</th>
						</tr>
						<tr>
							<td></td>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="10%" style="text-align: center; border: 1px solid">구분</th>
							<th width="40%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="10%" style="text-align: center; border: 1px solid">완료일</th>
							<th width="10%" style="text-align: center; border: 1px solid">진행율</th>
							<th width="5%" style="text-align: center; border: 1px solid">상태</th>
							<th width="25%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid"><%= pl %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="content" id="content" style="resize: none; width:100%; height:100px"><%= content %></textarea></td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="end" id="end" style="resize: none; width:100%; height:100px"><%= end %></textarea></td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="progress" id="progress" style="resize: none; width:100%; height:100px"></textarea></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="state"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="note" id="note" style="resize: none; width:100%; height:100px"></textarea></td>
						</tr>
						<tr>
							<td></td>
						</tr>
					</tbody>
				</table>
				
				<!-- 차주 업무 계획 테이블 -->
				<table  class="table" style="text-align: center;">
					<thead>
						<tr>
							<td></td>
						</tr>
						<tr>
							<th colspan="2" style="background-color:#FF9900; align:left;" > &nbsp;차주 업무 계획</th>
						</tr>
						<tr>
							<td></td>
						</tr>
					</thead>
					<tbody style="border: 1px solid">
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="10%" style="text-align: center; border: 1px solid">구분</th>
							<th width="40%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="10%" style="text-align: center; border: 1px solid">완료예정</th>
							<th width="50%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid"><%= pl %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="ncontent" id="ncontent" style="resize: none; width:100%; height:100px"><%= ncontent %></textarea></td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="ntarget" id="ntarget" style="resize: none; width:100%; height:100px"><%= ntarget %></textarea></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="nnote" id="nnote" style="resize: none; width:100%; height:100px"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</form>
	<button type="button" class="btn btn-primary pull-right" style="width:50px; text-align:center; align:center" onclick="save()">제출</button>
	</div>
	

<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchField');
			
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
	
	<script>
	// 자동 높이 확장 (textarea)
	$("textarea").on('propertychange input keyup keydown focusin focusout blur mousemove', function() {
		//var offset = this.offsetHeight - this.clientHeight;
		//var resizeTextarea = function(el) {
			//$(el).css('height','auto').css('height',el.scrollHeight + offset);
			$(this).height(2).height($(this).prop('scrollHeight'));
		//};
		//$(this).on('propertychange keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
		
	});
	</script>	


	<!-- 상태 선택을 위한 script -->
	<script>
	$("#state").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#state");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});
	
	var con = document.getElementById("state");
	$("#complete").on('click', function() {
			con.style.backgroundColor = "#00ff00";
	});
	
	$("#proceeding").on('click', function() {
		con.style.backgroundColor = "#ffff00";
	});

	$("#incomplete").on('click', function() {
		con.style.backgroundColor = "#ff0000";
	});
	
	// con.style.backgroundColor = ''; 이라면, 설정하시오! (경고)
	if(con.style.backgroundColor = '') {
		
	}
	</script>
	
	
	<script>
	function save() {
		if(document.getElementById("content").value == '' || document.getElementById("content").value == null) {
			alert("금주 업무 실적의 '업무 내용'이 작성되지 않았습니다.");
		} else {
			if(document.getElementById("end").value == '' || document.getElementById("end").value == null) {
				alert("금주 업무 실적의 '완료일'이 작성되지 않았습니다.");
			} else {
				if(document.getElementById("progress").value == '' || document.getElementById("progress").value == null) {
					alert("금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
				} else {
					if(con.style.backgroundColor == '' || con.style.backgroundColor == null) {
						alert("금주 업무 실적의 '상태'가 선택되지 않았습니다.");
					} else {
						//차주
						if(document.getElementById("ncontent").value == '' || document.getElementById("ncontent").value == null) {
							alert("차주 업무 계획의 '업무 내용'이 작성되지 않았습니다.");
						} else {
							if(document.getElementById("ntarget").value == '' || document.getElementById("ntarget").value == null) {
								alert("차주 업무 계획의 '완료예정'이 작성되지 않았습니다.");
							} else {
								var innerHtml = '<td><textarea class="textarea" id="color" name="color" style="display:none">'+con.style.backgroundColor+'</textarea></td>';
								$('#Table > tbody > tr:last').append(innerHtml);
								$('#bbsRk').submit();
							}
						}
					}
				}
			}
		}
	}
	</script>
	
</body>
</html>