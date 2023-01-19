<%@page import="javax.swing.RepaintManager"%>
<%@page import="sum.Sum"%>
<%@page import="sum.SumDAO"%>
<%@page import="rms.rms_next"%>
<%@page import="rms.rms_this"%>
<%@page import="rms.RmsDAO"%>
<%@page import="rms.rms_next"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.Objects"%>
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
		
		// 로그인 사용자의 랭크 가져오기
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
		
		//pl 리스트 확인
		String work = userDAO.getpl(id); //현재 접속 유저의 pl(web, erp)를 확인함!
		
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
		if(request.getParameter("bbsDeadline") != null || !request.getParameter("bbsDeadline").isEmpty()) {
			bbsDeadline = request.getParameter("bbsDeadline");
		}
		
		//마감기간이 지난 보고의 요약본은 작성할 수 없음!
			//해당 bbsDeadline으로 조회하여 sign이 마감인 경우,
		String getSign = rms.getSignNext(bbsDeadline);
		if(getSign.equals("마감")) {
			/* PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('제출 기한이 지나 작성이 불가합니다.')");
			script.println("location.href='/BBS/pl/bbsRk.jsp'");
			script.println("</script>"); */
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
		
		
		//만약 이미 해당 날짜로 요약본이 작성되어 있다면, 뒤로 돌려보냄!
		SumDAO sumDAO = new SumDAO();
		ArrayList<Sum> list = sumDAO.getlistSum(bbsDeadline, work);
		if(list.size() != 0){ //데이터가 있다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('해당 날짜로 제출된 요약본이 있습니다. \\n수정 및 삭제 페이지로 이동합니다.')");
			script.println("location.href='/BBS/pl/summaryUpdateDelete.jsp'");
			script.println("</script>");
		}
		
		//만약 제출자가 전체 인원보다 적을 경우, 경고창을 띄움!
		ArrayList<String> plist = userDAO.getpluser(work); //pl 관련 유저의 아이디만 출력
		
		//RMS 내용 가져오기!
		//해당 주차로 제출된 RMS 내용 찾기 (nav바)
		// 모든 내용 (pageNumber가 없음!)이기에 full을 통해 검색함!
		ArrayList<rms_next> llist = rms.getlastSignRkfullSelect(bbsDeadline, work);
		
		String[] userID = new String[llist.size()];
		
		for(int i=0; i < llist.size(); i++) {
			userID[i] = llist.get(i).getUserID();
		}
		
		ArrayList<rms_this> tlist = rms.getthisSignRkfullSelect(bbsDeadline, userID);
		
		//사용자 ID -> 사용자 name으로 전환
		ArrayList<rms_next> flist = rms.getlastSignRkfull(bbsDeadline, work);
		
		String userName ="";
		for (int i=0; i < flist.size(); i++) {
			if(i < flist.size() -1) {
				userName += userDAO.getName(flist.get(i).getUserID()) + ", ";
			} else {
				userName +=  userDAO.getName(flist.get(i).getUserID());
			}
		}
		
		
		// 미제출자 인원 계산 ()
		int psize = plist.size(); //pl 담당 유저
		int lsize = flist.size();
		int noSub =  psize - lsize;
		
		//해당 인원 전원 불러오기 (이름으로 변경)
		ArrayList<String> username = new ArrayList<String>();
		for(int i=0; i<plist.size(); i++) {
			String a = userDAO.getName(plist.get(i)); //user 이름을 도출.
			username.add(a);	
		}
		String[] usernamedata = username.toArray(new String[username.size()]);
		Arrays.sort(usernamedata);
		
		String userdata = String.join(", ", usernamedata);
		
		
		//미제출자 인원
		ArrayList<String> noSubname = new ArrayList<String>();
		ArrayList<String> Subname = new ArrayList<String>();

		//제출한 RMS 도출
		for(int i=0; i<flist.size(); i++) {
			Subname.add(flist.get(i).getUserID()); //제출한 user id 도출. (일반 list(10개 제한이 걸림)가 아닌, 모든 제출자를 확인해야함!)
			//bbsId.add(Integer.toString(flist.get(i).getBbsID()));
		}
		for(int i=0; i<Subname.size(); i++) {
			plist.remove(Subname.get(i));
		}
		//제출 안한 인원 찾기
		for(int i=0; i<plist.size(); i++) {
			String b = userDAO.getName(plist.get(i)); //user 이름을 도출.
			noSubname.add(b);	
		}
		
		String[] nousernamedata = noSubname.toArray(new String[noSubname.size()]);
		Arrays.sort(nousernamedata);
		
		String nouserdata = String.join(", ", nousernamedata);
		
		//alert가 넘어오면 경고창 미표시, 넘어오지 않으면 표시!
		String alert = request.getParameter("alert");
		if(alert == null || alert.isEmpty()) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('주간보고 제출이 확인되지 않은 사용자가 있습니다\n작성에 유의해주시기 바랍니다.')");
			//script.println("location.href='../login.jsp'");
			script.println("</script>");
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
								if(work !="" || !work.isEmpty()) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= work %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><h5 style="background-color: #e7e7e7; height:40px; margin-top:-20px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= work %></h5></li>
								<li><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= work %> Summary</h5></li>
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
	
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-html="true" data-placement="bottom" title="제출자: <%= userName %> <br> 제출 인원: <%= flist.size() %> "> <%= work  %> 요약본 작성
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
	<%	
	if(noSub != 0) {
	%>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:blue; font-size:13px " data-toggle="tooltip" data-html="true" data-placement="bottom" title="미제출자: <%= nouserdata %> <br> 미제출 인원: <%= noSub %> "> 미제출 인원이 존재합니다
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
	<%
	}
	%>
			</thead>
		</table>
	</div>
	<br>
	

	
	<!-- 목록 조회 table -->
	<div class="container">
	<form method="post" action="/BBS/pl/bbsRkwriteFinal.jsp" id="Rkwrite">
		<div class="row">
			<div class="col-6 col-md-6">
				<table id="Table" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="3"style="background-color:#D4D2FF; align:left; font-size:15px"> &nbsp;금주 업무 실적 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; border: 1px solid; border-top: 1px solid #ffffff">
							<th width="55%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">업무 내용</th>
							<th width="15%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">완료일</th>
							<th width="25%" style="border: 1px solid #ffffff; font-size:13px" class="text-center"><input type="checkbox" style="zoom:2.0;" name="chk" value="selectall" onclick="selectAll(this)"></th>
						</tr>
						
						<%
						//금주 업무 내용을 나열!
						for(int i=0; i< tlist.size(); i++) { //content
							//content의 "-" 제거하기
							String bbsContent = "";
							if(tlist.get(i).getBbsContent().indexOf('-') > -1 && tlist.get(i).getBbsContent().indexOf('-') < 2) { //맨 앞이 - 라면,
								bbsContent = tlist.get(i).getBbsContent().replaceFirst("-", "");
							} else { //bbsContent의 앞에 '-'이 없거나, 또는 빈칸일때 -> 이 경우는 저장부터 문제가 발생하는 경우!
								bbsContent = tlist.get(i).getBbsContent();
							}
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="content<%=i%>" id="content<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= bbsContent %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="end<%=i%>" id="end<%=i%>" rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= tlist.get(i).getBbsEnd() %></textarea>
								<textarea name="bbsDeadline" id="bbsDeadline" rows="1" style="resize: none; height:30px; width:60px; text-align: center; display:none"><%= bbsDeadline %></textarea>
							</td>
							<td>
								<input type="checkbox" name="chk" id="chk<%=i%>" style="zoom:2.0;" value="<%= i %>">
							</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
			
			<!-- 차주 업무 계획 -->
			<div class="col-6 col-md-6">
				<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="3"style="background-color:#ff9900; align:left"> &nbsp;차주 업무 계획 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; border: 1px solid; border-top: 1px solid #ffffff">
							<th width="60%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">업무 내용</th>
							<th width="20%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">완료예정</th>
							<th width="20%" style="border: 1px solid #ffffff; font-size:13px" class="text-center"><input type="checkbox" name="
" style="zoom:2.0;" value="selectall" onclick="nselectAll(this)"></th>
						</tr>
						<%
						//차주 업무 목록
						for(int i=0; i< llist.size(); i++) { 
							
							//content의 "-" 제거하기
							String bbsNContent = "";
							if(llist.get(i).getBbsNContent().indexOf('-') > -1 && llist.get(i).getBbsNContent().indexOf('-') < 2) { //맨 앞이 - 라면,
								bbsNContent = llist.get(i).getBbsNContent().replaceFirst("-", "");
							} else { //bbsContent의 앞에 '-'이 없거나, 또는 빈칸일때 -> 이 경우는 저장부터 문제가 발생하는 경우!
								bbsNContent = llist.get(i).getBbsNContent();
							}
							
							//bbsNTarget이 가공되지 않음!
							//해당 데이터 가공하여 출력하기!
							String bbsNTarget = "";
							if(llist.get(i).getBbsNTarget().isEmpty()) { //보류 표시
								bbsNTarget = "[보류]";
							} else { //데이터가 들어가 있는 경우 (ex> 2023-01-16) ...
								bbsNTarget = llist.get(i).getBbsNTarget().substring(5);
								bbsNTarget = bbsNTarget.replace("-", "/");
							}
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="ncontent<%=i%>" id="ncontent<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= bbsNContent %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="ntarget<%=i%>" id="ntarget<%=i%>" rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= bbsNTarget %></textarea>
							</td>
							<td>
								<input type="checkbox" name="nchk" id="nchk<%=i%>" style="zoom:2.0;" value="<%= i %>">
							</td>
						</tr>
						<%
						}
						%> 
	
					</tbody>
				</table>
			</div>
			</div>
		</form>
		<a type="button" style="width:50px" class="btn btn-primary pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="선택된 내용으로 요약본 생성" id="save" >선택</a>
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
		$("textarea").on('propertychange input keyup keydown focusin focusout blur mousemove', function() {
			//var offset = this.offsetHeight - this.clientHeight;
			//var resizeTextarea = function(el) {
				//$(el).css('height','auto').css('height',el.scrollHeight + offset);
				$(this).height(2).height($(this).prop('scrollHeight'));
			//};
			//$(this).on('propertychange keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
			
		});
	</script>	
	
	<script>
	//체크박스 이벤트
	/* function OnSave() {
		var chk = document.querySelectorAll('input[name="chk"]:checked').length; // 몇개의  chk가 눌렸는지 확인
		 for(var i=0; i < chk; i++) {
			
		} 
		alert('총 '+chk+'개의 줄을 선택하셨습니다. 다음으로 넘어갑니다.')
	} */
	
	//클릭시, 체크박스 전체 선택
	function selectAll(selectAll){
		var checkboxes = document.getElementsByName('chk');
		
		checkboxes.forEach((checkbox) => {
			checkbox.checked = selectAll.checked;
		})
	}
	
	function nselectAll(selectAll){
		var checkboxes = document.getElementsByName('nchk');
		
		checkboxes.forEach((checkbox) => {
			checkbox.checked = selectAll.checked;
		})
	}
	</script>
	
	<script>
	// 데이터 송신
	//해당 배열에 저장(몇번인지!)
	var chk_arr = [];
	var nchk_arr = [];
	
	var content ="";
	var end ="";
	var ncontent ="";
	var ntarget ="";
	
	$(document).ready(function() {
		$('#save').click(function () {
			//alert($("input[type=checkbox][name=chk]:checked").val());	
			$("input[type=checkbox][name=chk]:checked").each(function(){
				var chk = $(this).val();
			chk_arr.push(chk);
			})
			
			$("input[type=checkbox][name=nchk]:checked").each(function(){
				var nchk = $(this).val();
			nchk_arr.push(nchk);
			})
			
			//alert(chk_arr);
			//alert(nchk_arr);
			
			if(chk_arr == null || chk_arr =="") {
				alert('금주 업무 실적 중, 내용이 선택되지 않았습니다. \n1개 이상을 선택하여 주십시오.');
			}else if(nchk_arr == null || nchk_arr =="") {
				alert('차주 업무 계획 중, 내용이 선택되지 않았습니다. \n1개 이상을 선택하여 주십시오.');
			} else {
			
			//데이터를 다른 페이지로 보냄!
			// ((금주 업무 내용 / 완료일))
			for(var i=0; i < chk_arr.length; i++) {
				var a = "#content"+chk_arr[i];
				var b = "#end"+chk_arr[i];
				//금주 업무 실적에 대한 내용 넣기
				content += $(a).val() + "§";
				end += $(b).val() + "§";
			}
			
			// ((차주 업무 내용 / 목표일))
			for(var i=0; i < nchk_arr.length; i++) {
				var a = "#ncontent"+nchk_arr[i];
				var b = "#ntarget"+nchk_arr[i];
				//금주 업무 실적에 대한 내용 넣기
				ncontent += $(a).val() + "§";
				ntarget += $(b).val() + "§";
			}
			
			//alert(content);
			//alert(end);
			//alert(ncontent);
			//alert(ntarget);
			
			// 데이터 넘기기 
			var innerHtml = "";
			//innerHtml += '<td><textarea class="textarea" id="chk_arr" name="chk_arr" readonly>'+ chk_arr +'</textarea></td>';
			//innerHtml += '<td><textarea class="textarea" id="nchk_arr" name="nchk_arr" readonly>'+ nchk_arr +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="content" name="content" readonly>'+ content +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="end" name="end" readonly>'+ end +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="ncontent" name="ncontent" readonly>'+ ncontent +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="ntarget" name="ntarget" readonly>'+ ntarget +'</textarea></td>';
			
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#Rkwrite').submit(); 
			}
		})
	});
	


	</script>
</body>
</html>