<%@page import="rms.erp"%>
<%@page import="rms.RmsDAO"%>
<%@page import="Sumad.SumadDAO"%>
<%@page import="Sumad.Sumad"%>
<%@page import="net.sf.jasperreports.engine.type.CalculationEnum"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.Arrays"%>
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
<%@ page import="bbs.BbsDAO" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="java.util.ArrayList" %>
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
		UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
		RmsDAO rms = new RmsDAO();
		SumadDAO sumadDAO = new SumadDAO();
		
		String rk = userDAO.getRank((String)session.getAttribute("id"));
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
		if(!rk.equals("실장") && !rk.equals("관리자")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		}
	
		String pl = userDAO.getpl(id);
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
		String[] email = Staticemail.split("@");
		
		
		//(월요일) 제출 날짜 확인
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
		 
		 //String bbsDeadline = mon; //Deadline은 '월'요일까지 포함된, 가장 가까운 월요일
		 String bbsDeadline = request.getParameter("bbsDeadline");
		 if(bbsDeadline == null || bbsDeadline.isEmpty()) {
			 PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('요약본을 찾을 수 없습니다.')");
				script.println("history.back();");
				script.println("</script>");
		 }
		

		// 최종 관리자로서, Pl(파트리더)가 작성한 요약본을 불러옴! 
		//String MaxbbsDeadline = bbsDAO.getDeadLineListSum();
		//summary_admin에서 데이터를 불러옴
		ArrayList<Sumad> sumad = sumadDAO.getlistSumad(bbsDeadline);
		
		
		
		String str = "미승인 - 관리자의 미승인 상태<br>";
		str += "승인 - 관리자가 확정한 상태<br>";
		str += "마감 - 기한이 지나 승인된 상태<br>";
		str += "보류 - 저장되지 않은 상태";
		
		
		//erp 데이터가 있는지 확인
		//id -> erp 작성을 담당하는 user의 ID를 가져와야함!
		String jobs = userDAO.getJobsCode("계정관리");
		String erp_id = userDAO.getIDManger(jobs);
		ArrayList<erp> erp_list = rms.geterp(bbsDeadline, erp_id);
	
		int Set = -1;
		//workSet에 숫자 넣기
		if(erp_list.size() != 0) {
			Set = 1;
		}
		%>
<!-- erp가 존재하는 경우, 확인하기 -->
<textarea class="textarea" id="workSet" name="workSet" style="display:none"><%= Set %></textarea>

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
							<li><a href="/BBS/user/bbsAdmin.jsp">조회</a></li>
							<!-- <li><a href="bbsUpdate.jsp">작성</a></li>
							<li><a href="bbsUpdateDelete.jsp">수정/삭제</a></li>
							<li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자") || rk.equals("실장")) {
						%>
						<%
						 if (pl.equals("WEB") || pl.equals("ERP")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">요약본<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
						
							<ul class="dropdown-menu">
								<li><a href="/BBS/pl/bbsRk.jsp">작성</a></li>
							</ul>
						<%
						 }
						%>
							</li>
						<%
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
								<li class="active"><a href="/BBS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li>
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
					if(rk.equals("부장") || rk.equals("실장")||rk.equals("관리자")) {
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

		
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " class="form-control" data-toggle="tooltip" data-placement="bottom" title="승인(제출) 및 마감 처리시, 수정/삭제가 불가합니다." > [ERP/WEB] 요약본 수정 </th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	<!-- 목록 조회 table -->
	<div class="container" id="jb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="ecomplete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="eproceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="eincomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
		 </table>
	 </div>
	 <div class="container" id="wjb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="wcomplete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="wproceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="wincomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
		 </table>
	 </div>
	 
	<div class="container">
	<form method="post" action="/BBS/admin/action/bbsRkAdminUpdate.jsp" id="bbsRk">
		<div class="row">
			<div class="container">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>			
							<td style="background-color:#f9f9f9;" colspan="1" style="align:left;" >요약본</td>
							<td style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title=""> [ERP/WEB] - summary (<%= bbsDeadline %>)<textarea id="bbsDeadline" name="bbsDeadline" style="display:none"><%= bbsDeadline %></textarea></td>
							<td colspan="2"  style="background-color:#f9f9f9;"></td>
							<td  style="background-color:#f9f9f9;" colspan="1" style="txet:center">승인</td>
							<td  style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title="<%= str %>" ><%= sumad.get(0).getSign() %><textarea id="sign" name="sign" style="display:none"><%= sumad.get(0).getSign() %></textarea></td>
						</tr>
						<tr>
							<th colspan="6" style="background-color:#D4D2FF; align:left; border:none" > &nbsp;금주 업무 실적</th>
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
						<%
						if(sumad.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">ERP<textarea id="estate_value" name="estate_value" style="display:none"><%= sumad.get(0).getE_state() %></textarea></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="econtent" id="econtent" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_content() %></textarea></td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="eend" id="eend" style="resize: none; width:100%; height:100px"><%=sumad.get(0).getE_end() %></textarea></td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="eprogress" id="eprogress" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_progress() %></textarea></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="estate"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="enote" id="enote" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_note() %></textarea><textarea id="bbsDeadline" name="bbsDeadline" style="display:none"><%= bbsDeadline %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">ERP</td>
							<td colspan=5 style=" border: 1px solid"><br>해당 제출일로 작성된 ERP 요약본이 없습니다. </td>
						</tr>
						<%
						}
						if(sumad.size()!=0) {
						%>
						<tr>
							
							<!-- 구분 -->
							<td style="border: 1px solid; text-align: center; "><textarea id="wstate_value" name="wstate_value" style="display:none"><%= sumad.get(0).getW_state() %></textarea>WEB</td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="wcontent" id="wcontent" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_content() %></textarea></td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="wend" id="wend" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_end() %></textarea></td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="wprogress" id="wprogress" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_progress()%></textarea></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="wstate"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="wnote" id="wnote" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_note() %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">WEB</td>
							<td colspan=5 style=" border: 1px solid"><br>해당 제출일로 작성된 WEB 요약본이 없습니다. <br></td>
						</tr>
						<%
						}
						%>
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
							<th colspan="5" style="background-color:#FF9900; align:left; border:none" > &nbsp;차주 업무 계획</th>
						</tr>
					</thead>
					<tbody style="border: 1px solid">
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="10%" style="text-align: center; border: 1px solid">구분</th>
							<th width="40%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="10%" style="text-align: center; border: 1px solid">완료예정</th>
							<th width="50%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						<%
						if(sumad.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">ERP</td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="encontent" wrap="hard" id="encontent" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_ncontent() %></textarea></td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="entarget" id="entarget" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_ntarget() %></textarea></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="ennote" id="ennote" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getE_nnote() %></textarea></td>
						</tr>
						<%
						} else { 
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">ERP</td>
							<td colspan=3 style=" border: 1px solid"><br>해당 제출일로 작성된 ERP 요약본이 없습니다. </td>
						</tr>
						<% 
						}
						if(sumad.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">WEB</td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="wncontent" id="wncontent" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_ncontent() %></textarea></td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="wntarget" id="wntarget" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_ntarget() %></textarea></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="wnnote" id="wnnote" wrap="hard" style="resize: none; width:100%; height:100px"><%= sumad.get(0).getW_nnote() %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">WEB</td>
							<td colspan=3 style=" border: 1px solid"><br>해당 제출일로 작성된 WEB 요약본이 없습니다. </td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
				
				<%
				if(erp_list.size() != 0) {
				%>
				<!-- '계정 관리가 있을 경우, 생성' -->
				<table class="table" id="accountTable" style="text-align: center; cellpadding:50px; display:none;" >
					<tbody id="tbody">
					<tr>
						<th colspan="5" style="background-color: #ccffcc; border:none" align="center" data-toggle="tooltip" title="해당 데이터는 수정이 불가합니다!">ERP 디버깅 권한 신청 처리 현황</th>
					</tr>
					<tr style="background-color: #FF9933; border: 1px solid">
						<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date</th>
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
						<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
					</tr>
						<%
						for (int i=0; i < erp_list.size(); i++) {
						%>
					<tr>
						<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white"> 
						  <textarea class="textarea" readonly style="display:none" name="erp_size"><%= erp_list.size() %></textarea>
						  <textarea class="textarea"  readonly id="erp_date<%= i %>" style=" width:180px; border:none; resize:none" readonly placeholder="YYYY-MM-DD" name="erp_date<%= i %>"><%= erp_list.get(i).getE_date() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_user<%= i %>" style=" width:130px; border:none; resize:none" readonly  placeholder="사용자명" name="erp_user<%= i %>"><%= erp_list.get(i).getE_user() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_stext<%= i %>" wrap="hard" style=" width:300px; border:none; resize:none" readonly  placeholder="변경값" name="erp_stext<%= i %>"><%= erp_list.get(i).getE_text() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_authority<%= i %>" style=" width:130px; border:none; resize:none" readonly  placeholder="ERP권한신청서번호" name="erp_authority<%= i %>"><%= erp_list.get(i).getE_authority() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_division<%= i %>" style=" width:130px; border:none; resize:none " readonly  placeholder="구분(일반/긴급)" name="erp_division<%= i %>"><%= erp_list.get(i).getE_division() %></textarea></td>
					</tr>
					<%
						}
					%>
					</tbody>
				</table>
				<%
				}
				%>
			</div>
			<div class="container" style="display:inline-block">
			<%
			if(sumad.get(0).getSign().equals("미승인")) {
			%>
				<button type="button" class="btn btn-success pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="signOn()">승인</button> 
				<button type="button" class="btn btn-info pull-right" style="width:50px; text-align:center; align:center" onclick="update()">수정</button> 
		<%// } else if(bbsDAO.getSumAdminid(bbsDeadline).equals("")) { // 즉, 작성되지 않았다면!  %> 
				<!-- <button type="button" class="btn btn-primary pull-right" style="width:50px; text-align:center; align:center" onclick="update()">작성</button>  -->
		<% } %>
		<% if(sumad.get(0).getSign().equals("승인") || sumad.get(0).getSign().equals("마감")) {  //승인이나 마감 상태시에만 pptx로 출력 가능!%>
				<button type="button" class="btn btn-primary pull-right" style="width:50px; text-align:center; align:center; margin-left:20px" onClick="location.href='/BBS/admin/summaryadRk.jsp'">목록</button> 
				<button type="button" class="btn btn-success pull-right" style="width:50px; text-align:center; align:center" onclick="print()">pptx</button> 
				
		<% } %> 
		</div>
		</div>
	</form>
	</div>
	<br><br><br>	

	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	
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
		$("textarea").on('input keyup keydown focusin focusout blur mousemove', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
			
		});
	</script>	
	
	
	<script>
	// 상태 색상 지정
	$(document).ready(function() {
		var con = document.getElementById("estate_value").value; //완료, 진행중, 미완료(문제)
		var state = document.getElementById("estate");
		if(con == "완료") {
			state.style.backgroundColor = "#00ff00";
		} else if (con =="진행중") {
			state.style.backgroundColor = "#ffff00";
		} else {
			state.style.backgroundColor = "#ff0000";
		}
	
		var wcon = document.getElementById("wstate_value").value; //완료, 진행중, 미완료(문제)
		var wstate = document.getElementById("wstate");
		if(wcon == "완료") {
			wstate.style.backgroundColor = "#00ff00";
		} else if (wcon =="진행중") {
			wstate.style.backgroundColor = "#ffff00";
		} else {
			wstate.style.backgroundColor = "#ff0000";
		}
	});
	</script>
	
	<!-- e상태 선택을 위한 script -->
	<script>
	$("#estate").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#estate");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});
	
	var con = document.getElementById("estate");
	$("#ecomplete").on('click', function() {
			con.style.backgroundColor = "#00ff00";
	});
	
	$("#eproceeding").on('click', function() {
		con.style.backgroundColor = "#ffff00";
	});

	$("#eincomplete").on('click', function() {
		con.style.backgroundColor = "#ff0000";
	});
	</script>
	
	<!-- w상태 선택을 위한 script -->
	<script>
	$("#wstate").on('click', function() {
		var con = document.getElementById("wjb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#wstate");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("wjb-text").style.display = 'none';
		}
	});
	
	var wcon = document.getElementById("wstate");
	$("#wcomplete").on('click', function() {
			wcon.style.backgroundColor = "#00ff00";
	});
	
	$("#wproceeding").on('click', function() {
		wcon.style.backgroundColor = "#ffff00";
	});

	$("#wincomplete").on('click', function() {
		wcon.style.backgroundColor = "#ff0000";
	});
	</script>
	
	<script>
	//'erp_bbs'에 데이터가 있다면,
	$(document).ready(function() {
		var workSet = document.getElementById("workSet").value;
		if(workSet != -1) { // -1이 아니라면,
			// accountTable 보이도록 설정
			document.getElementById("accountTable").style.display="block";
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	function update() {
		if(document.getElementById("econtent") == null) { //ERP, WEB 내용이 없는 경우, 
			alert('불러올 ERP 요약본이 없습니다. 담당 파트리더에게 문의 바랍니다.');
		}
		if(document.getElementById("wcontent") == null) { //ERP, WEB 내용이 없는 경우, 
			alert('불러올 WEB 요약본이 없습니다. 담당 파트리더에게 문의 바랍니다.');
		}
		if(document.getElementById("eprogress").value == '' || document.getElementById("eprogress").value == null) {
			alert("ERP - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		} else if (document.getElementById("wprogress").value == '' || document.getElementById("wprogress").value == null) { 
			alert("WEB - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		}else {
			var innerHtml = '<td><textarea class="textarea" id="ecolor" name="ecolor" style="display:none">'+con.style.backgroundColor+'</textarea></td>';
				innerHtml += '<td><textarea class="textarea" id="wcolor" name="wcolor" style="display:none">'+wcon.style.backgroundColor+'</textarea></td>';
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#bbsRk').submit();
		}
	}
	</script>
	
	<script>
	var a = "<%=bbsDeadline%>";
	function signOn() {
		if(document.getElementById("eprogress").value == '' || document.getElementById("eprogress").value == null) {
			alert("ERP - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		} else if (document.getElementById("wprogress").value == '' || document.getElementById("wprogress").value == null) { 
			alert("WEB - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		}else {
			if(confirm("해당 요약본을 승인하시겠습니까? \n승인 처리시, 수정/삭제가 불가합니다.")) {
			var innerHtml = '<td><textarea class="textarea" id="ecolor" name="ecolor" style="display:none">'+con.style.backgroundColor+'</textarea></td>';
				innerHtml += '<td><textarea class="textarea" id="wcolor" name="wcolor" style="display:none">'+wcon.style.backgroundColor+'</textarea></td>';
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#bbsRk').attr("action","/BBS/admin/action/summaryadsignOnAction.jsp?bbsDeadline="+a).submit();
			} else {
				
			}
		}
	}
	</script>
	
	<script>
	function print() {
			var innerHtml = '<td><textarea class="textarea" id="ecolor" name="ecolor" style="display:none">'+con.style.backgroundColor+'</textarea></td>';
				innerHtml += '<td><textarea class="textarea" id="wcolor" name="wcolor" style="display:none">'+wcon.style.backgroundColor+'</textarea></td>';
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#bbsRk').attr("action","/BBS/admin/pptx/pptAdmin.jsp").submit();
		}
	</script>
	
</body>
</html>