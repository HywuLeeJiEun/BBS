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
		String[] content = con.split("\r\n|&#10;"); // - ~~~, ~~~,  - ~~ ...
		// 맨앞 -를 다른 문자로 치환하기
		String rp = "";
		for(int i=0; i<content.length; i++) {
			if(content[i].substring(0).indexOf("-") > -1){ //맨 앞이 -라면,
				String a = content[i].replaceAll("\r\n","");
				a = a.replaceAll("&#10;","");
				rp += a.replaceFirst("-","§") + "\r\n";
			} else {
				String a = content[i].replaceAll("\r\n","");
				rp += a.replaceAll("&#10;","") +"\r\n"; // 해당 rp에 § 저장된다! 
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
			en += list.get(i).getBbsEnd().replace("&#10;","§");
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
				a = a.replaceAll("&#10;","");
				nrp += a.replaceFirst("-","§") + "\r\n";
			} else {
				String a = ncontent[i].replaceAll("\r\n","");
				nrp += a.replaceAll("&#10;","") +"\r\n"; // 해당 rp에 § 저장된다! 
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
			nen += list.get(i).getBbsNTarget().replace("&#10;","§");
		}
		// end 자르기
		String[] ntarget = nen.split("§");
		//공백 제거
		ArrayList<String> narr = new ArrayList<String>();
		Collections.addAll(narr, ntarget);
		narr.removeAll(Arrays.asList("",null));
		String[] ncomtarget = narr.toArray(new String[narr.size()]);
		
		String work = userDAO.getpl(id); //현재 접속 유저의 pl(web, erp)를 확인함!
		
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
							<li><a href="bbsUpdateDelete.jsp">수정/삭제</a></li>
							<li><a href="signOn.jsp">승인(제출)</a></li>
						</ul>
					</li>
						<%
							if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">요약본<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li class="active"><a href="bbsRk.jsp">조회</a></li>
								<li><a href="bbsRkwrite.jsp">작성</a></li>
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
					if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
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
	
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black "> 요약본(Summary) - [<%= work  %>] 내용을 선택하여  주십시오.</th>
				</tr>
			</thead>
		</table>
	</div>
	<br>
	
	<!-- 목록 조회 table -->
	<div class="container">
	<form method="post" action="bbsRkAction.jsp" id="Rkwrite">
		<div class="row">
			<div class="col-6 col-md-6">
				<table id="Table" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="3"style="background-color:#D4D2FF; align:left"> &nbsp;금주 업무 실적 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B;">
							<th width="60%">|&nbsp;업무 내용</th>
							<th width="20%">|&nbsp;완료일</th>
							<th width="20%">|&nbsp;&nbsp;<input type="checkbox" style="zoom:2.0;" name="chk" value="selectall" data-toggle="tooltip" data-placement="bottom" title="전체 선택" onclick="selectAll(this)"></th>
						</tr>
						
						<%
						for(int i=0; i< comcontent.length; i++) { //content의 길이가 더 길 수 있음!
						%>
						<tr>
							<td style="text-align: left;">
								<textarea name="content<%=i%>" id="content<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= comcontent[i].replaceAll("(\n\r|\r\n|\n|\r)$","") %></textarea>
							</td>
							<td style="text-align: left;">
								<textarea name="end<%=i%>" id="end<%=i%>" rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= comend[i] %></textarea>
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
							<th colspan="3"style="background-color:#D4D2FF; align:left"> &nbsp;차주 업무 계획 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B;">
							<th width="60%">|&nbsp;업무 내용</th>
							<th width="20%" >|&nbsp;완료예정</th>
							<th width="20%">|&nbsp;&nbsp;<input type="checkbox" name="
" style="zoom:2.0;" value="selectall" data-toggle="tooltip" data-placement="bottom" title="전체 선택" onclick="nselectAll(this)"></th>
						</tr>
						<%
						for(int i=0; i< ncomcontent.length; i++) { //content의 길이가 더 길 수 있음!
						%>
						<tr>
							<td style="text-align: left;">
								<textarea name="ncontent<%=i%>" id="ncontent<%=i%>" rows="2" style="resize: none; height:30px; width:300px;"><%= ncomcontent[i].replaceAll("(\n\r|\r\n|\n|\r)$","") %></textarea>
							</td>
							<td style="text-align: left;">
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
		<a type="button" class="btn btn-primary pull-right" id="save">선택</a>
	</div>
	<br><br><br>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
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
	
	<!-- 밖으로 나가서 클릭시, 사라지도록 지정 -->
	<script>
	$("#jb-title").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#jb-title");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});

	
	$("#plist").on('mouseover', function() {
		var con = document.getElementById("plist_list");
			con.style.display = 'block';
	});
	$("#plist").on('mouseout', function() {
		var con = document.getElementById("plist_list");
			con.style.display = 'none';	
	});
	
	
	$("#noSublist").on('mouseover', function() {
		var con = document.getElementById("noSublist_list");
			con.style.display = 'block';
	});
	$("#noSublist").on('mouseout', function() {
		var con = document.getElementById("noSublist_list");
			con.style.display = 'none';
	});
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
			innerHtml += '<td><textarea class="textarea" id="content" name="content" readonly>'+ content +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="end" name="end" readonly>'+ end +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="ncontent" name="ncontent" readonly>'+ ncontent +'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="ntarget" name="ntarget" readonly>'+ ntarget +'</textarea></td>';
			
			$('#Table > tbody > tr:last').append(innerHtml);
			$('#Rkwrite').submit();
		})
	});
	


	</script>
</body>
</html>