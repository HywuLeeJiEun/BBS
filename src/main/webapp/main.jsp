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
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="css/index.css">
<title>Baynex 주간보고</title>
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
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		String workSet;
		
		UserDAO userDAO = new UserDAO();
		String rk = userDAO.getRank((String)session.getAttribute("id"));
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
			<a class="navbar-brand" href="main.jsp">Baynex 주간보고</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li class="active"><a href="main.jsp">주간보고</a></li>
				<li><a href="bbs.jsp">제출목록</a></li>
			</ul>
			
			
			
			<%
				// 로그인 하지 않았을 때 보여지는 화면
				if(id == null){
			%>
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">접속하기<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
						<li class="active"><a href="login.jsp">로그인</a></li>
					</ul>
				</li>
			</ul>
			
			
			<%
				// 로그인이 되어 있는 상태에서 보여주는 화면
				}else{
			%>
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
					%>
						<li><a href="workChange.jsp">담당업무 변경</a></li>
					
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
			<%
				}
			
				UserDAO user = new UserDAO();
			%>
		</div>
	</nav>
	
	
	
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
				<form method="post" action="mainAction.jsp">
					<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="5" style="background-color: #eeeeee; text-align: center;">baynex 주간보고 작성</th>
							</tr>
						</thead>
						<tbody>
							<tr>
									<td colspan="1"> 주간보고 명세서 </td>
									<td align="center" colspan="2"><input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="3.주간업무 실적 및 계획(AMS) - "></td>
									<td colspan="1">  주간보고 제출일 </td>
									<td align="center" colspan="1"><input type="date" max="9999-12-31" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" ></td>
							</tr>
							
								
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
									<tr align="center">
										<td><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:180px; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= user.getName(id) %></textarea></td>
										 <td><textarea class="textarea" id="bbsContent" required style="height:180px;width:100%; border:none; " placeholder="업무내용" name="bbsContent"></textarea></td>
										 <td><textarea class="textarea" id="bbsStart" required style="height:180px; width:100%; border:none; " placeholder="접수일" name="bbsStart"  oninput="this.value = this.value
												.replace(/[^0-9./.\s.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>
										 <td><textarea class="textarea" id="bbsTarget" required style="height:180px; width:100%; border:none; " placeholder="완료목표일" name="bbsTarget" oninput="this.value = this.value
												.replace(/[^0-9./.\s.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>	
										 <td><textarea class="textarea" id="bbsEnd" required style="height:180px; width:100%; border:none;"  placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>
									</tr>
									<tr align="center">	
											<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
										<!-- 	oninput을 활용하여 숫자와 특수문자(/)만 작성 가능하도록 구현 -->
										 <td>											 
										 	<select name="jobs" id="jobs" style="height:45px;">
												 <option> 담당 업무 선택 </option>
												 <%
												 for(int count=0; count < works.size(); count++) {
												 %>
												 	<option> <%= works.get(count) %> </option>
												 <%
												 }
												 %>
												 <option> 무관 </option>
											 </select>
										</td>
										 <td><textarea class="textarea" id="content_add" style="height:45px;width:100%;" placeholder="업무내용" name="bbsContent_add" ></textarea></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="start_add" class="form-control" placeholder="접수일" name="start_add" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="target_add" class="form-control" placeholder="완료목표일" name="target_add" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-]/g, '')
												.replace(/(\..*)\./g, '$1');"></td>	
										 <td><textarea class="textarea" id="end_add" style="height:45px; width:100%; border:none" maxlength="5" placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>	
									</tr>
									<tr>
										<td colspan="5"><button type="button" style="margin-bottom:5px;margin-top:5px; margin-left:15px" onclick="textAdd()" class="btn btn-primary pull-right"> 추가 </button>
														<button type="button" style="margin-bottom:5px;margin-top:5px" onclick="textRe()" class="btn btn-info pull-right"> 초기화 </button></td>
									</tr>
									
									<tr>
										<!-- <th colspan="5" style="background-color: #DCFE42; text-align: left;"><br><font color="white"> &nbsp;Baynex-Outsourcing</font></th> -->
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
									<tr align="center">
										<td><textarea class="textarea" required style="height:180px; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= user.getName(id) %></textarea></td>
										 <td><textarea class="textarea" required id="bbsNContent" style="height:180px;width:100%; border:none; " placeholder="업무내용" name="bbsNContent"></textarea></td>
										 <td><textarea class="textarea" required id="bbsNStart" style="height:180px; width:100%; border:none; " placeholder="접수일" name="bbsNStart"  oninput="this.value = this.value
												.replace(/[^0-9./.\s.-]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>
										 <td><textarea class="textarea" required id="bbsNTarget" style="height:180px; width:100%; border:none; " placeholder="완료목표일" name="bbsNTarget" oninput="this.value = this.value
												.replace(/[^0-9./.\s.-]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>	
									</tr>
									<tr align="center">	
											<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
										<!-- 	oninput을 활용하여 숫자와 특수문자(/)만 작성 가능하도록 구현 -->
										 <td>											 
										 	<select name="njobs" id="njobs" style="height:45px;">
												 <option> 담당 업무 선택 </option>
												 <%
												 for(int count=0; count < works.size(); count++) {
												 %>
												 	<option> <%= works.get(count) %> </option>
												 <%
												 }
												 %>
												 <option> 무관 </option>
											 </select>
										</td>
										 <td><textarea class="textarea" id="ncontent_add" style="height:45px;width:100%;" placeholder="업무내용" name="ncontent_add" ></textarea></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="nstart_add" class="form-control" placeholder="접수일" name="nstart_add" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="ntarget_add" class="form-control" placeholder="완료목표일" name="ntarget_add"></td>	
										 <td colspan="5"><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" onclick="textNAdd()" class="btn btn-primary pull-right"> 추가 </button>
										 				 <button type="button" style="margin-bottom:5px;margin-top:5px" onclick="textNRe()" class="btn btn-info pull-right"> 초기화 </button></td>	
									</tr>
						</tbody>
					</table>
					<!-- 저장 버튼 생성 -->
					<button type="button" onclick="location.href='main.jsp'" style="margin-bottom:50px" class="btn btn-info pull-left"> 전체 초기화 </button>
					<button type="submit" id="save" style="margin-bottom:50px" class="btn btn-primary pull-right"> 저장 </button>
				</form>
			</div>
		</div>


	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
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
	</script>
	
	<script>
	// 금주 업무 실적 추가 script
	function textAdd() {
		var target = document.getElementById("jobs");
		var option = target.options[target.selectedIndex].text;
		var cadd = document.getElementById('content_add').value;
		var sadd = document.getElementById('start_add').value;
		var words = sadd.split("-");
		var tadd = document.getElementById('target_add').value;
		var word = tadd.split("-");
		
		// 줄바꿈 확인 개수
		var lb_cadd = cadd.split("\n").length -1;
		
		if(option === "담당 업무 선택") {
			alert("(금주) 담당 업무 선택이 완료되지 않았습니다.");
			return false;
		}
		if($("#content_add").val() == "") {
			alert("(금주) 업무 내용이 입력되지 않았습니다.");
			$("#content_add").focus();
			return false;
		} 
		var eadd = document.getElementById('end_add').value;
		if($("#end_add").val() == "") {
			alert("(금주) 진행율이 입력되지 않았습니다.");
			$("#end_add").focus();
			return false;
		}
		document.getElementById('bbsEnd').value += eadd + '\n';
		for(var i=0; i < lb_cadd; i++) {
			document.getElementById('bbsEnd').value += '\n';
		}
		
		if(option === "무관") {
			document.getElementById('bbsContent').value += '-' + ' ' + cadd + '\n';
			
			
		} else {
		document.getElementById('bbsContent').value += '-' + '[' + option + ']'+ ' ' + cadd + '\n';
		}
		

		if(words == "") {
				alert('(금주) 접수일 미입력으로 (---)보류로 표시됩니다.');
				document.getElementById('bbsStart').value += '---' + '\n';
				for(var i=0; i < lb_cadd; i++) {
					document.getElementById('bbsStart').value += '\n';
				}
		} else {
			document.getElementById('bbsStart').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_cadd; i++) {
				document.getElementById('bbsStart').value += '\n';
			}
		}

		if(word == "") {
				alert("(금주) 목표일 미입력으로 (---)보류로 표시됩니다.");
				document.getElementById('bbsTarget').value += '---' + '\n';
				for(var i=0; i < lb_cadd; i++) {
					document.getElementById('bbsTarget').value += '\n';
				}
		} else {
			document.getElementById('bbsTarget').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_cadd; i++) {
				document.getElementById('bbsTarget').value += '\n';
			}
		}
		
		var sdown = $("textarea").prop('scrollHeight');
		$("textarea").scrollTop(sdown);
	};
	</script>
	<script>
	function textRe() {
		document.getElementById("jobs").value="담당 업무 선택";
		document.getElementById('content_add').value="";
		document.getElementById('start_add').value="";
		document.getElementById('target_add').value="";
		document.getElementById('end_add').value="";
	}
	function textNRe() {
		document.getElementById("njobs").value="담당 업무 선택";
		document.getElementById('ncontent_add').value="";
		document.getElementById('nstart_add').value="";
		document.getElementById('ntarget_add').value="";
		document.getElementById('nend_add').value="";
	}
	</script>
	
	<script>
	// 차주 업무 계획 추가 script
	function textNAdd() {
		var target = document.getElementById("njobs");
		var option = target.options[target.selectedIndex].text;
		var cadd = document.getElementById('ncontent_add').value;
		var sadd = document.getElementById('nstart_add').value;
		var words = sadd.split("-");
		var tadd = document.getElementById('ntarget_add').value;
		var word = tadd.split("-");
		
		// 줄바꿈 확인 개수
		var lb_cadd = cadd.split("\n").length -1;
		
		if(option === "담당 업무 선택") {
			alert("(차주) 담당 업무 선택이 완료되지 않았습니다.");
			return false;
		}
		if($("#ncontent_add").val() == "") {
			alert("(차주) 업무 내용이 입력되지 않았습니다.");
			$("#ncontent_add").focus();
			return false;
		} 
		
		if(option === "무관") {
			document.getElementById('bbsNContent').value += '-' + ' ' + cadd + '\n';
		} else {
		document.getElementById('bbsNContent').value += '-' + '[' + option + ']'+ ' ' + cadd + '\n';
		}
		

		if(words == "") {
				alert('(차주) 접수일 미입력으로 (---)보류로 표시됩니다.');
				document.getElementById('bbsNStart').value += '---' + '\n';
				for(var i=0; i < lb_cadd; i++) {
					document.getElementById('bbsNStart').value += '\n';
				}
		} else {
			document.getElementById('bbsNStart').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_cadd; i++) {
				document.getElementById('bbsNStart').value += '\n';
			}
		}

		if(word == "") {
				alert("(차주) 목표일 미입력으로 (---)보류로 표시됩니다.");
				document.getElementById('bbsNTarget').value += '---' + '\n';
				for(var i=0; i < lb_cadd; i++) {
					document.getElementById('bbsNTarget').value += '\n';
				}
		} else {
			document.getElementById('bbsNTarget').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_cadd; i++) {
				document.getElementById('bbsNTarget').value += '\n';
			}
		}
		
		var sdown = $("textarea").prop('scrollHeight');
		$("textarea").scrollTop(sdown);
	};
	</script>

	
<!-- 	<script>
	//단축키를 통한 저장 (shfit + ctrl + s)
	var isShift = false;
	document.onkeyup = function(e) {
		if(e.which == 16)isShift = false;아
	}
	document.onkeydown = function(e) {
		if(e.which == 16)isShift = true;
		if(e.which == 83 && isShift == true) {
			if(e.which == 17 && isShift == true) {
			// shift와 s가 동시에 눌린다면,
			document.getElementById("save").click();
			}
		}
	}
	</script> -->

</body>