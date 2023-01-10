<%@page import="java.text.Format"%>
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
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="css/index.css">
<style>
.ui-tooltip{
	white-space: pre-line;
}
.ui-tooltip-content {
	white-space: pre-line;
}
</style>
<title>RMS</title>
</head>


<body>
	<%
		UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
		BbsDAO bbsDAO = new BbsDAO();
		
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
			script.println("location.href='login.jsp'");
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
		 
		 String bbsDeadline = mon;
		

		
		 String pl = userDAO.getpl(id); 
		//저장된 summary를 받아 불러옴.
		String sum_id = request.getParameter("sum_id");
		ArrayList<String> list = bbsDAO.getlistSum(sum_id, pl);
		
		if(pl.equals("") || pl == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		String str = "미승인 - 관리자의 미승인 상태<br>";
		str += "승인 - 관리자가 확정한 상태<br>";
		str += "마감 - 기한이 지나 승인된 상태";
		
		
		// summary 둘러보기를 위한 week 표시
		int week = 0; 
		if(request.getParameter("week") != null) {
			week = Integer.parseInt(request.getParameter("week"));
		}
		
		String lastweek ="";
		String nextweek ="";
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
		if(!list.isEmpty() && list != null) {
		//week에 date 표시
		Date date = format.parse(list.get(9));
		
		Calendar cal3 = Calendar.getInstance();
		cal3.setTime(date);
		cal3.add(Calendar.DATE, -7);
		//지난주,
		lastweek = format.format(cal3.getTime());
		cal3.add(Calendar.DATE, 14);
		//다음주,
		nextweek = format.format(cal3.getTime());
		}
		int count = bbsDAO.getCountSum(pl)-1;
		
		String sign = "";
		
		//erp_bbs가 있는지 확인 
		String deadline = "";
		if(!list.isEmpty() && list != null) {
			deadline = list.get(9);
		} else {
			deadline = bbsDeadline;
		}
		ArrayList<String> erp = bbsDAO.geterpid(deadline);
		
		//summary_admin에 만약 저장되었다면, (내용이 있다면)
		String sumad_id = bbsDAO.getSumAdminid(bbsDeadline);
		ArrayList<String> sumad = bbsDAO.getlistSumad(sumad_id);
		
		//bbsID를 통한 작성 기능 제공
		ArrayList<String>  AllbbsID = bbsDAO.signgetBbsID(pl); //bbsID를 가져옴!
		String bbsID = String.join(",",AllbbsID);
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
							<li><a href="bbsUpdate.jsp">작성</a></li>
							<li><a href="bbsUpdateDelete.jsp">수정 및 제출</a></li>
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
								<li><a href="bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="bbsRkwrite.jsp?bbsID=<%=bbsID%>">작성</a></li>
								<li class="active"><a href="summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li id="summary_nav"><a href="summaryRkSign.jsp">조회 및 출력</a></li>
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
								<li><a href="summaryadRk.jsp">조회</a></li>
								<li><a href="summaryadAdmin.jsp">작성</a></li>
								<li><a href="summaryadUpdateDelete.jsp">수정 및 승인</a></li>
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

		
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " data-html="true" class="form-control" data-toggle="tooltip" data-placement="bottom" title="승인 및 마감 상태에선<br> 수정/삭제가 불가합니다.<br><br> 예외: 관리자가 데이터를 수정한 경우,<br> 삭제가 불가합니다." > <%= pl %> 요약본(Summary) </th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	<!-- 메인 게시글 영역 -->
	<%
	// 즉, summary가 없다면, 
	if(list.isEmpty() || list == null) {
	%>
	<br><br><br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" class="form-control" data-toggle="tooltip" data-placement="bottom" title="요약본 작성으로 이동하기" > <a href="bbsRk.jsp">작성된 요약본(Summary)이 없습니다. </a></th>
				</tr>
			</thead>
		</table>
	</div>
	
	<%
	} else {
		
		//기간이 지나면 sign에 '마감' 표시를 함. 
		String dl = (list.get(9));
		Date time = new Date();
		String timenow = format.format(time);
		
		Date dldate = format.parse(dl);
		Date today = format.parse(timenow);
		
		if(dldate.after(today)) { //현재 날짜가 마감일을 아직 넘지 않으면,
			sign = list.get(11);
		} else {
			sign="마감";
			// 데이터베이스에 마감처리 진행
			int a = bbsDAO.sumSign(Integer.parseInt(sum_id));
		}
	%>
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
	<form method="post" action="bbsRkUpdate.jsp" id="bbsRk">
		<div class="row">
			<div class="container">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>			
							<td style="background-color:#f9f9f9;" colspan="1" style="align:left;" >요약본</td>
							<td style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title=""> [<%= pl %>] - summary (<%= dl %>)</td>
							<td colspan="2"  style="background-color:#f9f9f9;"><textarea id="bbsDeadline" name="bbsDeadline" style="display:none"><%= list.get(9) %></textarea>
								<textarea id="pl" name="pl" style="display:none"><%= list.get(1) %></textarea> 
								<textarea id="sum_id" name="sum_id" style="display:none"><%= sum_id %></textarea>
								<textarea id="sign" name="sign" style="display:none"><%= sign %></textarea>
								<textarea id="state_value" name="state_value" style="display:none"><%= list.get(5) %></textarea></td>
							<td  style="background-color:#f9f9f9;" colspan="1" style="txet:center">승인</td>
							<td  style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title="<%= str %>" ><%= sign %></td>
						</tr>
						<tr>
							<td></td>
						</tr>
						<tr>
							<th colspan="6" style="background-color:#D4D2FF; align:left; border:none;" > &nbsp;금주 업무 실적</th>
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
							<td style="text-align: center; border: 1px solid"><%= list.get(1) %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="content" id="content" style="resize: none; width:100%; height:100px"><%= list.get(2) %></textarea></td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="end" id="end" style="resize: none; width:100%; height:100px"><%= list.get(3) %></textarea></td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="progress" id="progress" style="resize: none; width:100%; height:100px"><%= list.get(4) %></textarea></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="state"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="note" id="note" style="resize: none; width:100%; height:100px"><%= list.get(6) %></textarea></td>
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
							<th colspan="4" style="background-color:#FF9900; align:left; border:none" > &nbsp;차주 업무 계획</th>
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
							<td style="text-align: center; border: 1px solid"><textarea id="pl" name="pl" style="display:none"><%= list.get(1) %></textarea><%= list.get(1) %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid"><textarea required name="ncontent" id="ncontent" style="resize: none; width:100%; height:100px"><%= list.get(7) %></textarea></td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid"><textarea required name="ntarget" id="ntarget" style="resize: none; width:100%; height:100px"><%= list.get(8) %></textarea></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="nnote" id="nnote" style="resize: none; width:100%; height:100px"><%= list.get(10) %></textarea></td>
						</tr>
					</tbody>
				</table>
				
			<!-- erp_bbs가 존재한다면, (bbsDeadline에 해당하는) -->
			<!-- erp_bbs에 자료가 있는 경우 하단 출력! -->
				<%
						if(erp.size() != 0 && pl.equals("ERP")) { //erp가 비어있지 않다면, 하단 출력 (ERP 담당자에게만)
							String[] erp_date = erp.get(1).split("\r\n");
							String[] erp_user = erp.get(2).split("\r\n");
							String[] erp_stext = erp.get(3).split("\r\n");
							String[] erp_authority = erp.get(4).split("\r\n");
							String[] erp_division = erp.get(5).split("\r\n");
						%>
				<table style="margin-bottom:50px;">
					<tbody>
						<tr>
							<th colspan="5" style="background-color: #ccffcc; border:none" align="center" data-toggle="tooltip" title="해당 데이터는 수정이 불가합니다!">ERP 디버깅 권한 신청 처리 현황</th>
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
							  <textarea class="textarea" id="erp_date<%= i %>" style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date<%= i %>" readonly><%= erp_date[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_user<%= i %>" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user<%= i %>" readonly><%= erp_user[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_stext<%= i %>" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext<%= i %>" readonly><%= erp_stext[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_authority<%= i %>" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority<%= i %>" readonly><%= erp_authority[i] %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_division<%= i %>" style=" width:130px; border:none; resize:none " placeholder="구분(일반/긴급)" name="erp_division<%= i %>" readonly><%= erp_division[i] %></textarea></td>
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
		<%-- 	<div style="display:inline-block">
			<%
			//if(count != week) {
			%>
				<button class="btn btn-default btn-lg glyphicon glyphicon-chevron-left" type="button" style=" margin-left:45%; " data-toggle="tooltip" title="<%= lastweek %>" onclick="location.href='lastWeekRk.jsp?week=<%= week + 1 %>'"></button>
			<%
			//}
			%>
			</div> --%>
			<%-- <div style="display:inline-block">
				<button class="btn btn-default btn-lg glyphicon glyphicon-chevron-right" type="button" style=" margin-left:40%; " data-toggle="tooltip" title="<%= nextweek %>" onclick="location.href='lastWeekRk.jsp?week=<%= week %>'"></button>
			</div> --%>
				<button type="button" class="btn btn-primary pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="location.href='summaryUpdateDelete.jsp'">목록</button> 
			<%
			if(sign.equals("미승인")) {
				if(sumad_id == null || sumad_id.isEmpty()) { //sumad가 생기면, 삭제가 불가함!
			%>
				<button type="button" class="btn btn-danger pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="location.href='bbsRkDelete.jsp?sum_id=<%= sum_id %>'" class="form-control" data-toggle="tooltip" data-placement="bottom" title="관리자가 요약본을 저장할 경우, 삭제가 불가합니다.">삭제</button> 
			<% } %>
				<button type="button" class="btn btn-info pull-right" style="width:50px; text-align:center; align:center" id="update" name="update" onclick="update()">수정</button> 
			<%
			}
			%>
		</div>
	</form>
	</div>
	<br><br><br>	
<%
	}
%>
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	
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
		var con = document.getElementById("state_value").value; //완료, 진행중, 미완료(문제)
		var state = document.getElementById("state");
		if(con == "완료") {
			state.style.backgroundColor = "#00ff00";
		} else if (con =="진행중") {
			state.style.backgroundColor = "#ffff00";
		} else {
			state.style.backgroundColor = "#ff0000";
		}
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
	//$("#update").find('[type="submit"]').trigger('click') {
	//function update() {
	$("#update").on('click', function () {
		if(document.getElementById("progress").value == '' || document.getElementById("progress").value == null) {
			alert("금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		} else {
			if(con.style.backgroundColor == '' || con.style.backgroundColor == null) {
				alert("금주 업무 실적의 '상태'가 선택되지 않았습니다.");
			} else {
			var innerHtml = '<tr><td><textarea class="textarea" id="color" name="color" style="display:none">'+con.style.backgroundColor+'</textarea></td></tr>';
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#bbsRk').submit();
			}
		}
	});
	</script>
	
</body>
</html>