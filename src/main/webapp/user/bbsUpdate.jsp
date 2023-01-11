<%@page import="java.util.Arrays"%>
<%@page import="java.util.Collections"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="user.User"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.tomcat.util.buf.StringUtils"%>
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
<link rel="stylesheet" href="../css/css/bootstrap.css">
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<title>RMS</title>
<link href="../css/index.css" rel="stylesheet" type="text/css">
</head>



<body>
	<!--  ********* 세션(session)을 통한 클라이언트 정보 관리 *********  -->
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
			script.println("location.href='../login.jsp'");
			script.println("</script>");
		}
		
		// 유효한 글이라면 구체적인 정보를 'bbs'라는 인스턴스에 담는다
		int bbsid = new BbsDAO().getMaxbbs(id);
		Bbs bbs = new BbsDAO().getBbs(bbsid);
		
		if(bbsid == -1){ //유효한 글이 없다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/user/main.jsp'");
			script.println("</script>");
		}
		
		UserDAO userDAO = new UserDAO();
		BbsDAO bbsDAO = new BbsDAO();
		
		String DDline = bbs.getBbsDeadline();
		//String DDline = "2022-12-19";
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		LocalDate date = LocalDate.parse(DDline, formatter);
		date = date.plusWeeks(1); //일주일을 더하는 것.
		
		//현재날짜 구하기
		LocalDate nowdate = LocalDate.now();
		String now = nowdate.format(formatter);
		
		String rk = userDAO.getRank((String)session.getAttribute("id"));
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		String workSet ="";
		
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
		
		//erp 자료 가져오기
		ArrayList<String> list = bbsDAO.geterpbbs(bbs.getBbsID());
		
		// 사용자 정보 담기
		User user = userDAO.getUser(name);
		String password = user.getPassword();
		String rank = user.getRank();
		//이메일  로직 처리
		String Staticemail = user.getEmail();
		String[] email = Staticemail.split("@");
		
		String pl = userDAO.getpl(id); //web, erp pl을 할당 받았는지 확인! 
		
		//bbsID를 통한 작성 기능 제공
		ArrayList<String>  AllbbsID = bbsDAO.signgetBbsID(pl); //bbsID를 가져옴!
		String inbbsID = String.join(",",AllbbsID);
		
		
		//데이터를 쪼개어 생성함!
		//금주 업무 실적 - 업무내용
		//1. 특수문자로 변환하여 스트링 만들기
		String rp = "";
		String[] a = bbs.getBbsContent().split("\r\n");
		for(int i=0; i < a.length; i++) {
			if(a[i].substring(0).indexOf('-') > -1 && a[i].substring(0).indexOf('-') < 1) {
				String y = a[i].replaceAll("\r\n","¿");
				y = y.replaceAll("\r\n","¿");
				rp += y.replaceFirst("-","§") + "¿";
			}else {
				String y = a[i].replaceAll("\r\n","¿");
				rp += y.replaceAll("\r\n","") + "¿";
			}
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] con = rp.split("§");
		for(int i=0; i<con.length; i++) {
			String del = con[i];
			con[i] = del.replaceFirst(".$","");
			con[i] = del.replaceFirst(".$","").replaceAll("¿","\r\n");
		}
		ArrayList<String> acon = new ArrayList<String>();
		Collections.addAll(acon, con);
		acon.removeAll(Arrays.asList("",null));
		String[] content = acon.toArray(new String [acon.size()]);
		// 2-2. 맨앞 '-' 추가
		String[] bbscontent = new String[content.length];
		for(int i=0; i < content.length; i++) {
			bbscontent[i] = "-" + content[i];
		}
		
		
		//금주 업무 실적 - 접수일
		//1. 특수문자로 변환하여 스트링 만들기
		String srp = "";
		String[] sa = bbs.getBbsStart().split("\r\n");
		for(int i=0; i < sa.length; i++) {
				String y = sa[i].replaceAll("\r\n","");
				srp += y.replaceAll("\r\n","") + "\r\n";
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] sta = srp.split("\r\n");
		ArrayList<String> star = new ArrayList<String>();
		Collections.addAll(star, sta);
		star.removeAll(Arrays.asList("",null));
		String[] bbsstart = star.toArray(new String [star.size()]);
		
		
		//금주 업무 실적 - 완료목표일
		//1. 특수문자로 변환하여 스트링 만들기
		String trp = "";
		String[] ta = bbs.getBbsTarget().split("\r\n");
		for(int i=0; i < ta.length; i++) {
				String y = ta[i].replaceAll("\r\n","");
				trp += y.replaceAll("\r\n","") + "\r\n";
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] tar = trp.split("\r\n");
		ArrayList<String> targ = new ArrayList<String>();
		Collections.addAll(targ, tar);
		targ.removeAll(Arrays.asList("",null));
		String[] bbstarget = targ.toArray(new String [targ.size()]);
		
		
		//금주 업무 실적 - 진행율,완료일
		//1. 특수문자로 변환하여 스트링 만들기
		String erp = "";
		String[] ea = bbs.getBbsEnd().split("\r\n");
		for(int i=0; i < ea.length; i++) {
				String y = ea[i].replaceAll("\r\n","");
				erp += y.replaceAll("\r\n","") + "\r\n";
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] en = erp.split("\r\n");
		ArrayList<String> end = new ArrayList<String>();
		Collections.addAll(end, en);
		end.removeAll(Arrays.asList("",null));
		String[] ends = end.toArray(new String [end.size()]);
		// 2-2. 맨앞 '-' 추가
		String[] bbsend = new String[ends.length];
		for(int i=0; i < ends.length; i++) {
			bbsend[i] = ends[i];
		}
		
		
		//차주 업무 계획 - 업무 내용
		//1. 특수문자로 변환하여 스트링 만들기
		String nrp = "";
		String[] na = bbs.getBbsNContent().split("\r\n");
		for(int i=0; i < na.length; i++) {
			if(na[i].substring(0).indexOf('-') > -1 && na[i].substring(0).indexOf('-') < 1) {
				String y = na[i].replaceAll("\r\n","¿");
				y = y.replaceAll("\r\n","¿");
				nrp += y.replaceFirst("-","§") + "¿";
			}else {
				String y = na[i].replaceAll("\r\n","¿");
				nrp += y.replaceAll("\r\n","") + "¿";
			}
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] ncon = nrp.split("§");
		for(int i=0; i<ncon.length; i++) {
			String del = ncon[i];
			ncon[i] = del.replaceFirst(".$","").replaceAll("¿","\r\n");
		}
		ArrayList<String> nacon = new ArrayList<String>();
		Collections.addAll(nacon, ncon);
		nacon.removeAll(Arrays.asList("",null));
		String[] ncontent = nacon.toArray(new String [nacon.size()]);
		// 2-2. 맨앞 '-' 추가
		String[] bbsncontent = new String[ncontent.length];
		for(int i=0; i < ncontent.length; i++) {
			bbsncontent[i] = "-" + ncontent[i];
		}
		
		
		//차주 업무 계획 - 접수일
		//1. 특수문자로 변환하여 스트링 만들기
		String nsrp = "";
		String[] nsa = bbs.getBbsNStart().split("\r\n");
		for(int i=0; i < nsa.length; i++) {
				String y = nsa[i].replaceAll("\r\n","");
				nsrp += y.replaceAll("\r\n","") + "\r\n";
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] nsta = nsrp.split("\r\n");
		ArrayList<String> nstar = new ArrayList<String>();
		Collections.addAll(nstar, nsta);
		nstar.removeAll(Arrays.asList("",null));
		String[] bbsnstart = nstar.toArray(new String [nstar.size()]);

		
		
		//차주 업무 계획 - 완료 목표일
		//1. 특수문자로 변환하여 스트링 만들기
		String ntrp = "";
		String[] nta = bbs.getBbsNTarget().split("\r\n");
		for(int i=0; i < nta.length; i++) {
				String y = nta[i].replaceAll("\r\n","");
				ntrp += y.replaceAll("\r\n","") + "\r\n";
		}
		//2. 가공
		// 2-1. 공백 제거 (빈 배열 제거)
		String[] ntar = ntrp.split("\r\n");
		ArrayList<String> ntarg = new ArrayList<String>();
		Collections.addAll(ntarg, ntar);
		ntarg.removeAll(Arrays.asList("",null));
		String[] bbsntarget = ntarg.toArray(new String [ntarg.size()]);
		
		
		//erp 자료 가져오기
		ArrayList<String> erplist = bbsDAO.geterpbbs(bbs.getBbsID());
		
		
	%>

	<c:set var="works" value="<%= works %>" />
	<input type="hidden" id="work" value="<c:out value='${works}'/>">
	
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
							<li  class="active"><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
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
								<li><a href="summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/BBS/pl/bbsRkwrite.jsp?bbsID=<%=inbbsID%>">작성</a></li>
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
	
	<!-- ********** 게시판 글쓰기 양식 영역 ********* -->
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
				<form method="post" action="/BBS/user/action/mainAction.jsp" id="main" name="main">
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="5" style="background-color: #eeeeee; text-align: center;" data-toggle="tooltip" data-placement="top" title="가장 최근에 제출된 보고의 내용을 불러옵니다." >주간보고 작성</th>
							</tr>
						</thead>
						<tbody id="tbody">
							<tr>
									<td colspan="2"> 
									주간보고 명세서 <input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value=<%= bbs.getBbsTitle().replaceAll(" ","&nbsp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll("\n","<br>") %>></td>
									<td colspan="1"></td>
									<td colspan="2">  주간보고 제출일 <input type="date" max="9999-12-31" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= date %>"></td>
							</tr>
									<tr>
										<th colspan="5" style="background-color: #D4D2FF;" align="center">금주 업무 실적</th>
									</tr>
									<tr style="background-color: #FFC57B;">
										<!-- <th width="6%">|  담당자</th> -->
										<th width="50%">| &nbsp; 업무내용</th>
										<th width="15%">| &nbsp; 접수일</th>
										<th width="15%">| &nbsp; 완료목표일</th>
										<th width="10%">| &nbsp;&nbsp; 진행율<br>&nbsp;&nbsp;&nbsp;&nbsp;/완료일</th>
										<th></th>
									</tr>
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= name %></textarea>
											<textarea style="display:none" id="len"><%= bbscontent.length %></textarea>
											<textarea style="display:none" id="nlen"><%= bbsncontent.length %></textarea></td> 
									</tr>
									<%
									for(int i=0; i < bbscontent.length; i++) {
										if(i==0) { //처음 시작일땐,
									%>
									<tr>
										 <td>
											 <textarea wrap="hard" class="textarea con" id="bbsContent" required style="height:45px;width:80%; border:none; resize:none " placeholder="업무내용" name="bbsContent<%= i %>"><%= bbscontent[i] %></textarea></td>
										 <td><textarea wrap="hard" class="textarea" id="bbsStart" style="height:45px; width:100%; border:none; resize:none"  placeholder="접수일" required name="bbsStart<%= i %>" ><%= bbsstart[i] %></textarea></td>
										 <td><textarea wrap="hard" class="textarea" id="bbsTarget" style="height:45px; width:100%; border:none; resize:none"  placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget<%= i %>" ><%= bbstarget[i] %></textarea></td>	
										 <td><textarea wrap="hard" class="textarea" id="bbsEnd" style="height:45px; width:100%; border:none; resize:none"  placeholder="진행율&#13;&#10;/완료일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd<%= i %>" ><%= bbsend[i] %></textarea></td>
										 <td><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button></td>
									</tr>
									<%
										} else {
									%>
										<tr>
											 <td><textarea wrap="hard" class="textarea con" id="bbsContent" required style="height:45px;width:80%; border:none; resize:none " placeholder="업무내용" name="bbsContent<%= i %>"><%= bbscontent[i] %></textarea></td>
											 <td><textarea wrap="hard" class="textarea" id="bbsStart" style="height:45px; width:100%; border:none; resize:none"  placeholder="접수일" required name="bbsStart<%= i %>" ><%= bbsstart[i] %></textarea></td>
										 	 <td><textarea wrap="hard" class="textarea" id="bbsTarget" style="height:45px; width:100%; border:none; resize:none"  placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget<%= i %>" ><%= bbstarget[i] %></textarea></td>
										 	 <td><textarea wrap="hard" class="textarea" id="bbsEnd" style="height:45px; width:100%; border:none; resize:none"  placeholder="진행율&#13;&#10;/완료일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd<%= i %>" ><%= bbsend[i] %></textarea></td>
											 <td><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button></td>
										</tr>
									<%
										}
									}
									%>
									</tbody>
								</table>
									<div id="wrapper" style="width:100%; text-align: center;">
										<button type="button" style="margin-bottom:15px; margin-right:30px" onclick="addRow()" class="btn btn-primary"> + </button>
									</div>	 			


				<!-- 차주 업무 계획  -->
				<table class="table" id="bbsNTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
				<thead>
				</thead>
				<tbody id="tbody">
							<tr>
								<th colspan="5" style="background-color: #D4D2FF;" align="center">차주 업무 계획</th>
							</tr>
							<tr style="background-color: #FFC57B;">
								<th width="50%">| &nbsp; 업무내용</th>
								<th width="15%">| &nbsp; 접수일</th>
								<th width="15%">| &nbsp; 완료목표일</th>
								<th></th>
								<th></th>
							</tr>
							<%
							for(int i=0; i < bbsncontent.length; i++) {
								if(i==0) {
							%>
							<tr>
								 <td><textarea wrap="hard" class="textarea ncon" id="bbsNContent0" required style="height:45px;width:80%; border:none; resize:none" placeholder="업무내용" name="bbsNContent0"><%= bbsncontent[i] %></textarea></td>
								  <td><textarea wrap="hard" class="textarea" id="bbsNStart0" style="height:45px; width:100%; border:none; resize:none"  placeholder="접수일" required name="bbsNStart0" ><%= bbsnstart[i] %></textarea></td>
								 <td><textarea wrap="hard" class="textarea" id="bbsNTarget0" style="height:45px; width:100%; border:none; resize:none"  placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget0" ><%= bbsntarget[i] %></textarea></td>
								 <td></td>
								<td><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delNRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>
							</tr>
							<%
								} else {
							%>
							<tr>
								 <td><textarea wrap="hard" class="textarea ncon" id="bbsNContent<%= i %>" required style="height:45px;width:80%; border:none; resize:none" placeholder="업무내용" name="bbsNContent<%= i %>"><%= bbsncontent[i] %></textarea></td>
								  <td><textarea wrap="hard" class="textarea" id="bbsNStart<%= i %>" style="height:45px; width:100%; border:none; resize:none"  placeholder="접수일" required name="bbsNStart<%= i %>" ><%= bbsnstart[i] %></textarea></td>
								 <td><textarea wrap="hard" class="textarea" id="bbsNTarget<%= i %>" style="height:45px; width:100%; border:none; resize:none"  placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget<%= i %>" ><%= bbsntarget[i] %></textarea></td>
								  <td></td>
								  <td><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delNRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>
							</tr>
							<%
								}
							}
							%>
							</tbody>
						</table>
						<div id="wrapper" style="width:100%; text-align: center;">
								<button type="button" style="margin-bottom:5px; margin-top:5px; margin-right:35px; margin-bottom:20px" onclick="addNRow()" class="btn btn-primary"> + </button>
						</div>
						
						<!-- erp_bbs에 자료가 있는 경우 하단 출력! -->
						<table class="table" id="accountTable" style="margin-bottom:50px; display:none">
							<tbody id="tbody">
								<tr>
									<th colspan="5" style="background-color: #ccffcc; border:none;" align="center">ERP 디버깅 권한 신청 처리 현황</th>
								</tr>
								<tr style="background-color: #FF9933; border: 1px solid">
									<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date <textarea class="textarea" id="erp_id" style="display:none" name="erp_id"></textarea></th>
									<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
									<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
									<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
									<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
								</tr>
						<tr>
							<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white"> <textarea style="display:none" id="elen"></textarea>
							  <textarea class="textarea" style="display:none" name="erp_size"></textarea>
							  <textarea class="textarea" id="erp_date0" style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date0"></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_user0" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user0"></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea"  id="erp_stext0" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext0"></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_authority0" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority0"></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_division0" style=" width:130px; border:none; resize:none " placeholder="구분(일반/긴급)" name="erp_division0"></textarea></td>
						</tr>
					</tbody>
				</table>
				<div id="wrapper_account" style="width:100%; text-align: center; display:none;">
					<button type="button" style="margin-bottom:15px; margin-right:30px" onclick="addRowAccount()" class="btn btn-primary"> + </button>
				</div>
				
				<!-- 계정 관리 끝 -->
					<div id="wrapper" style="width:100%; text-align: center;">
						<!-- 저장 버튼 생성 -->
						<button type="button" id="save" style="margin-bottom:50px; margin-left:20px" class="btn btn-primary pull-right" onclick="saveData()" data-toggle="tooltip" data-placement="bottom" title="작성된 내용을 저장합니다."> 저장 </button>									
						<button type="button" style="margin-bottom:50px" class="btn btn-info pull-right" onClick="empty()" data-toggle="tooltip" data-placement="bottom" title="작성된 내용을 지웁니다."> 비우기 </button>	
						<button type="Submit" id="save_sub" style="margin-bottom:50px; display:none" class="btn btn-primary pull-right"> 저장 </button>	
					</div>						
				</form>
			</div>
		</div>

	<!-- 현재 날짜에 대한 데이터 -->
	<textarea class="textarea" id="now" style="display:none " name="now"><%= now %></textarea>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	

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
	var trCnt = parseInt(document.getElementById("len").value);
	var conName = document.getElementsByClassName('con');
	var con = conName[conName.length-1].getAttribute('name');
		con = Number(con.replace('bbsContent',''));
		function addRow() {
			var work = "";
			var strworks ="";
			
			work = document.getElementById("work").value;
			work = work.replace("[","");
			work = work.replace("]","");
			work = work.replace(/\n/g,"");
			work = work.split(',');
			
			/* console.log(work); 
			console.log(work.length);  */
			
			// 테이블 개수 구하기
			
			
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			 	//console.log(work[count]);
			} 
				//var trCnt = $('#bbsTable tr').length;
				//var trCnt = parseInt(document.getElementById("len").value) + parseInt($('#bbsTable tr').length) + 1 - parseInt($('#bbsTable tr').length);
				
				//console.log(trCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				if(trCnt < 30) {
				
				var now = document.getElementById("now").value;
				// trCnt 대신, class="con"을 통해 name을 구해 가장 큰 name을 기준으로 숫자를 추출함!
					con += 1;
		    	 var innerHtml = "";
		            innerHtml += '<tr>';
		            innerHtml += '    <td>';
	            	innerHtml += '<div style="float:left">';
		            innerHtml += '     <select name="jobs'+con+'" id="jobs'+con+'" style="height:45px; width:95px; text-align-last:center;">';
		            innerHtml += '			<option> [시스템] </option>';
		            innerHtml += strworks; 
		            innerHtml += '  <option> 기타 </option>';
		            innerHtml += ' </select>';
		            innerHtml += ' </div>';
		            innerHtml += ' <div style="float:left">';
		            innerHtml += ' <textarea class="textarea con" wrap="hard" id="bbsContent'+con+'" required style="height:45px;width:180%; border:none; resize:none" placeholder="업무내용" name="bbsContent'+con+'"></textarea>';
		            innerHtml += '  </div> </td>';
		            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsStart'+con+'" class="form-control" placeholder="접수일" name="bbsStart'+con+'"  value="'+now+'"></td>';
		            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget'+con+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsTarget'+con+'" ></td>';
		            innerHtml += '  <td><textarea class="textarea" id="bbsEnd'+con+'" style="height:45px; resize:none; width:100%; border:none;"  data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다."  placeholder="진행율\n/완료일" name="bbsEnd'+con+'" ></textarea></td>'; 
		            innerHtml += '    <td>';
		            innerHtml += '<button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button>';
		            innerHtml += '    </td>';
		            innerHtml += '</tr>'; 
		            trCnt += 1;
		            $('#bbsTable > tbody:last').append(innerHtml);
			   
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}
		};
	</script>
	
	<script>
	$(document).on("click","button[name=delRow]", function() {
		var trHtml = $(this).parent().parent();
		trHtml.remove();
		trCnt --;
	});
	</script>
	
	
	<script>
	var trNCnt = parseInt(document.getElementById("nlen").value);
	var nconName = document.getElementsByClassName('ncon');
	var ncon= nconName[nconName.length-1].getAttribute('name');
		ncon = Number(ncon.replace('bbsNContent',''));
		function addNRow() {
			var work = "";
			var strworks ="";
			
			work = document.getElementById("work").value;
			work = work.replace("[","");
			work = work.replace("]","");
			work = work.replace(/\n/g,"");
			work = work.split(',');
				
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			} 
				//var trNCnt = parseInt(document.getElementById("nlen").value) + parseInt($('#bbsNTable tr').length) + 1 - parseInt($('#bbsNTable tr').length);
				
				if(trNCnt < 30) {
				//console.log(trNCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				var now = document.getElementById("now").value;
				
				ncon += 1;
					var innerHtml = "";
		            innerHtml += '<tr>';
		            innerHtml += '    <td>';
	            	innerHtml += '<div style="float:left">';
		            innerHtml += '     <select name="njobs'+ncon+'" id="njobs'+ncon+'" style="height:45px; width:95px; text-align-last:center;">';
		            innerHtml += '			<option> [시스템] </option>';
		            innerHtml += strworks; 
		            innerHtml += '  <option> 기타 </option>';
		            innerHtml += ' </select>';
		            innerHtml += ' </div>';
		            innerHtml += ' <div style="float:left">';
		            innerHtml += ' <textarea wrap="hard" class="textarea ncon" id="bbsNContent'+ncon+'" required style="height:45px;width:180%; resize:none; border:none; " placeholder="업무내용" name="bbsNContent'+ncon+'"></textarea>';
		            innerHtml += '  </div> </td>';
		            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNStart'+ncon+'" class="form-control" placeholder="접수일" name="bbsNStart'+ncon+'" value="'+now+'"></td>';
		            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget'+ncon+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsNTarget'+ncon+'" ></td>';
		            innerHtml += '<td></td>';
		            innerHtml += '<td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button>';
		            innerHtml += '    </td>';
		            innerHtml += '</tr>'; 
		            trNCnt += 1;
		            $('#bbsNTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}
		
		};
	</script>
	
	<script>
		$(document).on("click","button[name=delNRow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trNCnt --;
		});
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
	});
	</script>
	
	<!-- 모달 update를 위한 history 감지 -->
	<script>
	window.onpageshow = function(event){
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)){ //history.back 감지
			location.reload();
		}
	};
	</script>
	
	
	<textarea class="textarea" id="workSet" name="workSet" style="display:none;" readonly><%= workSet %></textarea>
	<script>
	//'계정관리' 업무를 담당하고 있다면, 
	$(document).ready(function() {
		var workSet = document.getElementById("workSet").value;
		if(workSet.indexOf("계정관리") > -1) {
			// accountTable 보이도록 설정
			document.getElementById("accountTable").style.display="block";
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	var trACnt = 1;
	//'계정관리' 업무를 추가함.
	function addRowAccount() {
		//var trACnt = $("#accountTable tr").length; // 기본을 2로 잡음!
		//var trACnt = parseInt(document.getElementById("elen").value) + parseInt($('#accountTable tr').length) + 1 - parseInt($('#accountTable tr').length);
		
		//console.log(trACnt);
		if(trACnt < 2) {//최대 5개까지 증진
		var innerHtml = "";
		innerHtml += '<tr>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">';
		innerHtml += '<textarea class="textarea" id="erp_date'+trACnt+'"  style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date'+trACnt+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px"> ';
		innerHtml += '<textarea class="textarea" id="erp_user'+trACnt+'"  style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user'+trACnt+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" id="erp_stext'+trACnt+'"  style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext'+trACnt+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" id="erp_authority'+trACnt+'"  style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority'+trACnt+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" id="erp_division'+trACnt+'"  style=" width:130px; border:none; resize:none" placeholder="구분(일반/긴급)" name="erp_division'+trACnt+'"></textarea></td>';
		innerHtml +='</tr>';
		trACnt += 1;
		$('#accountTable > tbody:last').append(innerHtml);
		} else {
			alert("계정관리 업무는 최대 2개까지 작성 가능합니다.");
			}
	};
	</script>
	
	
	<script>
	/* document.main.addEventListener("keydown", evt => {
		if((evt.keyCode || evt.which) === 13) {
			evt.preventDefault();
		}
	}); */
	// 데이터 보내기 (몇줄을 사용하는지!) <trCnt, trNCnt>
   // $(document).on('click', "#id" ,function(){
	//$("#save").on('click',function(){
	function saveData() {
		var innerHtml = "";
		innerHtml += '<tr style="display:none">';
		innerHtml += '<td><textarea class="textarea" id="trCnt" name="trCnt" readonly>'+trCnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="trNCnt" name="trNCnt" readonly>'+trNCnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="trACnt" name="trACnt" readonly>'+trACnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="con" name="con" readonly>'+con+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="ncon" name="ncon" readonly>'+ncon+'</textarea></td>';
		innerHtml += '</tr>';
        $('#bbsNTable > tbody> tr:last').append(innerHtml);
        
        //document.getElementById('save_sub').click;
        $("#save_sub").trigger("click");
    }
	
	function empty() {
		var check = confirm("작성된 내용이 삭제됩니다. 정말 비우시겠습니까?");
		if(check ){
			location.href='/BBS/user/bbsUpdate_empty.jsp';
		}
	}
	</script>
	
	
	<!-- 	//$("#save").find('[type="submit"]').trigger('click') {
	//$("#save").on('mousedown',function(){
	
	//var form = $('#main')[0]; // DOM 객체인 form tag를 받아옴.
	
	//form.addEventListner('submit',function(event) {
		//event.preventDefault(); // 기본 동작인 submit 중단
		
		
		 // 강제 submit 버튼 클릭
        //document.getElementById('save_sub').click;
		//$('#main').submit();
		//form.submit(); -->
</body>