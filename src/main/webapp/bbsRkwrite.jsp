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

<title>RMS</title>
</head>

<body>
	<%
		UserDAO userDAO = new UserDAO(); //인스턴스 userDAO 생성
		BbsDAO bbsDAO = new BbsDAO();
		
		//bbsID 배열에 bbsid 담기!
		String rq = request.getParameter("bbsID");
		if(rq.equals("") && rq.isEmpty()) { //만약 bbsID가 넘어온 게 없다면!
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('요약본 작성이 가능한 주간보고가 없습니다.\\n승인 상태를 확인해주시길 바랍니다.')");
			script.println("history.back()");
			script.println("</script>");
		}
		String[] bbsID = rq.split(",");
		
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
		
		
		//bbs 가져오기
		ArrayList<Bbs> list = bbsDAO.getListBbs(bbsID);
		
		String con="";
		//업무내용(Content, NContent) / 시작일(Start, NStart) 나누기 ((list.size))
		// content 합치기
		for(int i=0; i<list.size(); i++) {  
			con += list.get(i).getBbsContent()+"\r\n"; //하나의 content
		}
		// content 자르기
		String[] content = con.split("\r\n"); // - ~~~, ~~~,  - ~~ ...
		// 맨앞 -를 다른 문자로 치환하기
		String rp = "";
		for(int i=0; i<content.length; i++) {
			if(content[i].substring(0).indexOf("-") > -1){ //맨 앞이 -라면,
				String a = content[i].replaceAll("\r\n","");
				a = a.replaceAll("\r\n","");
				rp += a.replaceFirst("-","§") + "\r\n";
			} else {
				String a = content[i].replaceAll("\r\n","");
				rp += a.replaceAll("\r\n","") +"\r\n"; // 해당 rp에 § 저장된다! 
			}
		}  
		String[] ccontent = rp.split("§");
		//공백제거
		ArrayList<String> arc = new ArrayList<String>();
		Collections.addAll(arc, ccontent);
		arc.removeAll(Arrays.asList("",null));
		String[] comcontent = arc.toArray(new String[arc.size()]); 
		
		//end 합치기
		String en ="";
		for(int i=0; i<list.size(); i++) { 
			en += list.get(i).getBbsEnd().replace("\r\n","§");
		}
		// end 자르기
		String[] end = en.split("§");
		//공백 제거
		ArrayList<String> arr = new ArrayList<String>();
		Collections.addAll(arr, end);
		arr.removeAll(Arrays.asList("",null));
		String[] comend = arr.toArray(new String[arr.size()]);
		
		
		//차주 Data
		String ncon="";
		//업무내용(Content, NContent) / 시작일(Start, NStart) 나누기 ((list.size))
		// content 합치기
		for(int i=0; i<list.size(); i++) {  
			ncon += list.get(i).getBbsNContent()+"\r\n"; //하나의 ncontent
		}
		// content 자르기
		String[] ncontent = ncon.split("\r\n|&#10;"); // - ~~~, ~~~,  - ~~ ...
		// 맨앞 -를 다른 문자로 치환하기
		String nrp = "";
		for(int i=0; i< ncontent.length; i++) {
			if(ncontent[i].substring(0).indexOf("-") > -1){ //맨 앞이 -라면,
				String a = ncontent[i].replaceAll("\r\n","");
				a = a.replaceAll("\r\n","");
				nrp += a.replaceFirst("-","§") + "\r\n";
			} else {
				String a = ncontent[i].replaceAll("\r\n","");
				nrp += a.replaceAll("\r\n","") +"\r\n"; // 해당 rp에 § 저장된다! 
			}
		}  
		String[] nccontent = nrp.split("§");
		//공백제거
		ArrayList<String> narc = new ArrayList<String>();
		Collections.addAll(narc, nccontent);
		narc.removeAll(Arrays.asList("",null));
		String[] ncomcontent = narc.toArray(new String[narc.size()]); 
		
		//NTarget 합치기
		String nen ="";
		for(int i=0; i<list.size(); i++) { 
			nen += list.get(i).getBbsNTarget().replace("\r\n","§");
		}
		// end 자르기
		String[] ntarget = nen.split("§");
		//공백 제거
		ArrayList<String> narr = new ArrayList<String>();
		Collections.addAll(narr, ntarget);
		narr.removeAll(Arrays.asList("",null));
		String[] ncomtarget = narr.toArray(new String[narr.size()]);
		
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
				 
				 
		// 이미 해당 날짜에 제출된 요약본이 있다면, 작성 불가!
		String sum_id =  bbsDAO.getSumid(bbsDeadline, work);
		if(sum_id != null && !sum_id.equals("")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('해당 요일로 작성된 요약본이 있습니다.')");
			//script.println("location.href='summaryRkUpdate.jsp?sum_id="+sum_id+"''");
			//script.println("location.href='summaryRkUpdate.jsp?sum_id='");
			script.println("location.href='summaryRk.jsp'");
			script.println("</script>");
		}
	
	
		// 제출자 이름 뽑기
		String subname = "";
		for(int i=0; i < list.size(); i ++) {
			if(i == list.size()-1) {
				subname += list.get(i).getUserName();
			} else {
			subname += list.get(i).getUserName() + ",";
			}		
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
							<li><a href="bbsUpdateDelete.jsp">수정 및 승인</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= work %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><a href="bbsRk.jsp"><%= work %> 조회</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= work %> Summary</h5></li>
								<li><a href="summaryRk.jsp">조회</a></li>
								<li class="active" id="summary_nav"><a href="#">작성</a></li>
								<li><a href="summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; Summary</h5></li>
								<li id="summary_nav"><a href="summaryRkSign.jsp">출력(pptx)</a></li>
							</ul>
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
					<th colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-html="true" data-placement="bottom" title="제출자: <%= subname %> <br> 제출 인원: <%= list.size() %> "> <%= work  %> 요약본 작성
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
			</thead>
		</table>
	</div>
	<br>
	
	<!-- 목록 조회 table -->
	<div class="container">
	<form method="post" action="bbsRkwriteFinal.jsp" id="Rkwrite">
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
						for(int i=0; i< comcontent.length; i++) { //content의 길이가 더 길 수 있음!
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="content<%=i%>" id="content<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= comcontent[i].replaceAll("(\n\r|\r\n|\n|\r)$","") %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="end<%=i%>" id="end<%=i%>" rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= comend[i] %></textarea>
								<textarea name="bbsDeadline" id="bbsDeadline" rows="1" style="resize: none; height:30px; width:60px; text-align: center; display:none"><%= list.get(0).getBbsDeadline() %></textarea>
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
						for(int i=0; i< ncomcontent.length; i++) { //content의 길이가 더 길 수 있음!
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="ncontent<%=i%>" id="ncontent<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= ncomcontent[i].replaceAll("(\n\r|\r\n|\n|\r)$","") %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="ntarget<%=i%>" id="ntarget<%=i%>" rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= ncomtarget[i] %></textarea>
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