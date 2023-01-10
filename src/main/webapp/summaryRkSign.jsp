<%@page import="Sumad.Sumad"%>
<%@page import="Sumad.SumadDAO"%>
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
<%@ page import="bbs.Bbs"%>
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
		
		 
		//pl 리스트 확인
		String work = userDAO.getpl(id); //현재 접속 유저의 pl(web, erp)를 확인함!
		ArrayList<String> plist = userDAO.getpluser(work); //pl 관련 유저의 아이디만 출력
		//제출한 사람만 남기기
		
		String[] pllist = plist.toArray(new String[plist.size()]); //해당 pllist를 바꿔야함! (제출한 사람만)
		
		
		BbsDAO bbsDAO = new BbsDAO(); // 인스턴스 생성
		SumadDAO sumadDAO = new SumadDAO();
		ArrayList<Bbs> list = bbsDAO.getList(pageNumber, bbsDeadline, pllist);
		ArrayList<Sumad> sumlist = sumadDAO.getlistSumAll();
		
		if(work.equals("") || work == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		if(list.size() == 0) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('제출된 요약본이 없습니다.')");
			//script.println("history.back();");
			script.println("</script>");
		}
		
		// 미제출자 인원 계산
		int psize = plist.size();
		int lsize = list.size();
		int noSub =  psize - lsize;
		
		//해당 인원 전원 불러오기
		ArrayList<String> username = new ArrayList<String>();
		for(int i=0; i<plist.size(); i++) {
			String userName = userDAO.getName(plist.get(i)); //user 이름을 도출.
			username.add(userName);	
		}
		String[] usernamedata = username.toArray(new String[username.size()]);
		Arrays.sort(usernamedata);
		
		String userdata = String.join(", ", usernamedata);
		
		
		//미제출자 인원
		ArrayList<String> noSubname = new ArrayList<String>();
		ArrayList<String> Subname = new ArrayList<String>();
		// 넘기기 위한 bbsID
		ArrayList<String> bbsId = new ArrayList<String>();
		//제출한 bbsID 찾기
		for(int i=0; i<list.size(); i++) {
			Subname.add(list.get(i).getUserID()); //제출한 user id 도출.
			bbsId.add(Integer.toString(list.get(i).getBbsID()));
		}
		for(int i=0; i<Subname.size(); i++) {
			plist.remove(Subname.get(i));
		}
		//제출 안한 인원 찾기
		for(int i=0; i<plist.size(); i++) {
			String userName = userDAO.getName(plist.get(i)); //user 이름을 도출.
			noSubname.add(userName);	
		}
		
		String[] nousernamedata = noSubname.toArray(new String[noSubname.size()]);
		Arrays.sort(nousernamedata);
		
		String nouserdata = String.join(", ", nousernamedata);
		
		//bbsID string으로 변환
		String bbsID = String.join(",",bbsId);
		
		String pl = userDAO.getpl(id); //web, erp pl을 할당 받았는지 확인! 
		
		String str = "승인 및 마감처리가 된 요약본을 <br>";
		str += "출력할 수 있습니다.";
		
		
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
								<li><a href="summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li class="active" id="summary_nav"><a href="summaryRkSign.jsp">조회 및 출력</a></li>
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

		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= str %>"> [ERP/WEB] 요약본 출력 
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table id="bbsTable" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<!-- <th style="background-color: #eeeeee; text-align: center;">번호</th> -->
						<th style="background-color: #eeeeee; text-align: center;">제출일</th>
						<th style="background-color: #eeeeee; text-align: center; text-align: left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;요약본 상세정보</th>
						<th style="background-color: #eeeeee; text-align: center;">작성자</th>
						<th style="background-color: #eeeeee; text-align: center;">작성일(수정일)</th>
						<th style="background-color: #eeeeee; text-align: center;">상태</th>
						<th style="background-color: #eeeeee; text-align: center;">pptx</th>
					</tr>
				</thead>
				<tbody>
					<%
					if(sumlist.size() != 0) {
						for(int i = 0; i < sumlist.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							
							//bbsDeadline 찾아오기
							String dl = sumlist.get(i).getBbsDeadline();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
					%>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= dl %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="bbsRkAdmin.jsp?sumad_id=<%= sumlist.get(i).getSumad_id() %>" data-toggle="tooltip" data-html="true" data-placement="bottom" title="미승인 상태인 경우, 수정 및 삭제가 가능합니다.">
							[ERP/WEB] - summary (<%= dl %>)</a></td>
						<td><%= sumlist.get(i).getSumadUpdate() %></td>
						<td><%= sumlist.get(i).getSumadDate().substring(0, 11) + sumlist.get(i).getSumadDate().substring(11, 13) + "시"
							+ sumlist.get(i).getSumadDate().substring(14, 16) + "분" %></td>
						
						<!-- 승인/미승인/마감 표시 -->
						<td>
						<%
						String sign = null;
						if(dldate.after(today)) { //현재 날짜가 마감일을 아직 넘지 않으면,
							sign = sumlist.get(i).getSign();
						} else {
							sign="마감";
							// 데이터베이스에 마감처리 진행
							int a = bbsDAO.sumadSign(Integer.parseInt(sumlist.get(i).getSumad_id()));
						}
						
						//색상 정의
						String e_state = "";
						String w_state = "";
						if(sumlist.get(i).getE_state().equals("완료")) {
							e_state = "#00ff00";
						} else if(sumlist.get(i).getE_state().equals("진행중")){
							e_state = "#ffff00";
						} else {
							e_state = "#ff0000";
						}
						if(sumlist.get(i).getW_state().equals("완료")) {
							w_state = "#00ff00";
						} else if(sumlist.get(i).getW_state().equals("진행중")){
							w_state = "#ffff00";
						} else {
							w_state = "#ff0000";
						}
						%>
						<%= sign %>
						</td>
						<td>
							<button class="btn btn-success" id="<%= sumlist.get(i).getSumad_id() %>" style="font-size:12px" onclick="location.href='pptAdmin.jsp?bbsDeadline=<%= sumlist.get(i).getBbsDeadline() %>&e_state=<%= e_state %>&w_state=<%= w_state %>'"> 출력 </button>
						</td>
					</tr>
					<%
						}
					} else {
					%>
						<tr valign="top" style="height:100px; border:none">
						</tr>
						<tr valign="bottom" style="height:120px; border:none" data-html="true" data-toggle="tooltip" data-placement="bottom" title="<%= bbsDeadline %>,<br>해당 날짜로 제출된 요약본이<br>없습니다.<br>관리자에게 문의바랍니다.">
							<th colspan="6" style=" text-align: center; color:black  ; border:none">승인 및 마감된 요약본 목록이 없습니다. <br><br><br><br></th>
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
				<a href="summaryRkSign.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(bbsDAO.nextPage(pageNumber + 1)){
			%>
				<a href="summaryRkSign.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			<%-- <a href="ppt.jsp?bbsDeadline=<%=list.get(0).getBbsDeadline()%>&pluser=<%= work %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력" id="pptx" type="button"> 요약 pptx</a> --%>
			<%-- <a href="summaryRk.jsp" style="width:90px;" class="btn btn-primary pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="<%= pl %> Summary 조회"> <%= pl %> 목록 </a>  --%>
			<a href="bbsRkwrite.jsp?bbsID=<%=bbsID%>" style="width:100px; margin-right:20px; display:none" class="btn btn-info pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="요약본(Summary) 작성" id="summary"> Summary</a>
		</div>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 끝 -->
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
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
	$("#summary_nav").on('mousedown', function() {
		//noSub -> 미제출자
		if(<%= noSub %> != 0) { //즉, 미제출자가 있다면!
			var go;
			go = confirm("미제출자가 있습니다. 작성 페이지로 넘어가시겠습니까?");
			
			if(go) { //출력 o
				document.getElementById("summary").click();
			} else { //출력 x
				
			}
		
		}
	});
	</script>

	
</body>
</html>