<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
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
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="css/index.css">
<title>RMS</title>
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
		
		// 유효한 글이라면 구체적인 정보를 'bbs'라는 인스턴스에 담는다
				int bbsid = new BbsDAO().getMaxbbs(id);
				Bbs bbs = new BbsDAO().getBbs(bbsid);
				UserDAO user = new UserDAO();
				
				String DDline = bbs.getBbsDeadline();
				//String DDline = "2022-10-24";
				
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
				LocalDate date = LocalDate.parse(DDline, formatter);
				date = date.plusWeeks(1); //일주일을 더하는 것.
				
				String rk = user.getRank((String)session.getAttribute("id"));
				
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		String workSet;
		
		UserDAO userDAO = new UserDAO();
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
							<li class="active"><a href="bbs.jsp">조회</a></li>
							<li><a href="bbsUpdate.jsp">작성</a></li>
							<li><a href="bbsUpdateDelete.jsp">수정/삭제</a></li>
							<li><a href="signOn.jsp">승인(최종 제출)</a></li>
						</ul>
					</li>
				</ul>
			
			
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li><a href="bbs.jsp" style="color:#2E2E2E"><%= name %>(님)</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(rk.equals("부장") || rk.equals("차장") || rk.equals("관리자")) {
					%>
						<li><a href="logoutAction.jsp">개인정보 수정</a></li>
						<li><a href="workChange.jsp">담당업무 변경</a></li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a href="logoutAction.jsp">개인정보 수정</a></li>
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
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="5" style="background-color: #eeeeee; text-align: center;">주간보고 작성</th>
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
										<th width="10%">| &nbsp; 접수일</th>
										<th width="10%">| &nbsp; 완료목표일</th>
										<th width="10%">| &nbsp; 진행율<br>&nbsp;&nbsp;&nbsp;&nbsp;/완료일</th>
										<th></th>
									</tr>
									
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= bbs.getBbsManager()  %></textarea></td> 
									</tr>
									<tr>
										 <td>
										 	<div style="float:left">
											 <select name="jobs5" id="jobs5" style="height:45px;">
													 <option> [시스템] 선택 </option>
													 <%
													 for(int count=0; count < works.size(); count++) {
													 %>
													 	<option> <%= works.get(count) %> </option>
													 <%
													 }
													 %>
													 <option> 기타 </option>
												 </select>
											 </div>
											 <div style="float:left">
											 <textarea class="textarea" id="bbsContent" required style="height:45px;width:230%; border:none; " placeholder="업무내용" name="bbsContent5"></textarea>
											 </div>
										 </td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsStart" class="form-control" placeholder="접수일" name="bbsStart5" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget" class="form-control" placeholder="완료목표일" name="bbsTarget5" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-]/g, '')
												.replace(/(\..*)\./g, '$1');"></td>		
										 <td><textarea class="textarea" id="bbsEnd" required style="height:45px; width:100%; border:none;"  placeholder="진행율/완료일" name="bbsEnd5" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"></textarea></td>
												</tr>
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
								<th width="10%">| &nbsp; 접수일</th>
								<th width="10%">| &nbsp; 완료목표일</th>
								<th></th>
								<th></th>
							</tr>
							<tr>
								 <td>
								 	<div style="float:left">
									 <select name="jobs2" id="jobs2" style="height:45px;">
											 <option> [시스템] 선택 </option>
											 <%
											 for(int count=0; count < works.size(); count++) {
											 %>
											 	<option> <%= works.get(count) %> </option>
											 <%
											 }
											 %>
											 <option> 기타 </option>
										 </select>
									 </div>
									 <div style="float:left">
									 <textarea class="textarea" id="bbsNContent2" required style="height:45px;width:230%; border:none; " placeholder="업무내용" name="bbsNContent2"></textarea>
									 </div>
								 </td>
								 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsNStart2" class="form-control" placeholder="접수일" name="bbsNStart2" ></td>
								 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsNTarget2" class="form-control" placeholder="완료목표일" name="bbsNTarget2" oninput="this.value = this.value
										.replace(/[^0-9./.\s.%.-]/g, '')
										.replace(/(\..*)\./g, '$1');"></td>		
							</tr>
							</tbody>
						</table>
							<div id="wrapper" style="width:100%; text-align: center;">
								<button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" onclick="addNRow()" class="btn btn-primary"> + </button>
								<!-- 저장 버튼 생성 -->
								<button type="submit" id="save" style="margin-bottom:50px" class="btn btn-primary pull-right"> 저장 </button>									
							</div>					
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
				alert('(금주) 접수일 미입력으로 ---로 표시됩니다.');
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
				alert("(금주) 목표일 미입력으로 ---로 표시됩니다.");
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
				alert('(차주) 접수일 미입력으로 ---로 표시됩니다.');
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
				alert("(차주) 목표일 미입력으로 ---로 표시됩니다.");
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
	<script>
	function textRe() {
		document.getElementById("njobs").value="담당 업무 선택";
		document.getElementById('ncontent_add').value="";
		document.getElementById('nstart_add').value="";
		document.getElementById('ntarget_add').value="";
		document.getElementById('nend_add').value="";
	}
	</script> -->
	
	
	<script>
	
	</script>
	
	<script>
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
				var trCnt = $('#bbsTable tr').length;
				if(trCnt <= 35) {
				console.log(trCnt); // 버튼을 처음 눌렀을 때, 6 / 기본 5 -> + 누를 시, 1씩 증가
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="jobs'+Number(trCnt)+'" id="jobs'+Number(trCnt)+'" style="height:45px;">';
	            innerHtml += '			<option> [시스템] 선택 </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += '  <div style="float:left">';
	            innerHtml += ' <textarea class="textarea" id="bbsContent'+Number(trCnt)+'" required style="height:45px;width:230%; border:none; " placeholder="업무내용" name="bbsContent'+Number(trCnt)+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" required max="9999-12-31" style="height:45px; width:auto;" id="bbsStart'+Number(trCnt)+'" class="form-control" placeholder="접수일" name="bbsStart'+Number(trCnt)+'" ></td>';
	            innerHtml += ' <td><input type="date" required max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget'+Number(trCnt)+'" class="form-control" placeholder="완료목표일" name="bbsTarget'+Number(trCnt)+'" ></td>';
	            innerHtml += '  <td><textarea class="textarea" required id="bbsEnd'+Number(trCnt)+'" required style="height:45px; width:100%; border:none;"  placeholder="진행율/완료일" name="bbsEnd'+Number(trCnt)+'" ></textarea></td>'; 
	            innerHtml += '    <td>';
	            innerHtml += '<button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '</tr>'; 
	            
	            $('#bbsTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}
		}
	</script>
	
	<script>
	$(document).on("click","button[name=delRow]", function() {
		var trHtml = $(this).parent().parent();
		trHtml.remove();
	});
	</script>
	
	
	<script>
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
				var trNCnt = $('#bbsNTable tr').length;
				if(trNCnt <= 32) {
				console.log(trNCnt); // 버튼을 처음 눌렀을 때, 3 / 기본 2 -> + 누를 시, 1씩 증가
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="jobs'+Number(trNCnt)+'" id="jobs'+Number(trNCnt)+'" style="height:45px;">';
	            innerHtml += '			<option> [시스템] 선택 </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += '  <div style="float:left">';
	            innerHtml += ' <textarea class="textarea" id="bbsNContent'+Number(trNCnt)+'" required style="height:45px;width:230%; border:none; " placeholder="업무내용" name="bbsNContent'+Number(trNCnt)+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" required max="9999-12-31" style="height:45px; width:auto;" id="bbsNStart'+Number(trNCnt)+'" class="form-control" placeholder="접수일" name="bbsNStart'+Number(trNCnt)+'" ></td>';
	            innerHtml += ' <td><input type="date" required max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget'+Number(trNCnt)+'" class="form-control" placeholder="완료목표일" name="bbsNTarget'+Number(trNCnt)+'" ></td>';
	            innerHtml += '<td></td>'
	            innerHtml += '<td><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:100px" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '</tr>'; 
	            
	            $('#bbsNTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}

		}
	</script>
	
	<script>
	$(document).on("click","button[name=delNRow]", function() {
		var trHtml = $(this).parent().parent();
		trHtml.remove();
	});
	</script>
	
<%-- 	<%
	List<String> b = new ArrayList<String>();
	for(int i=0; i < 30;  i++) {
		String a = "bbsContent";
		b.add(request.getParameter(a+(i+5)));
	}
	%>
	<c:set var="content" value="<%= b %>"/>
	<input type="hidden" id="value" value="<c:out value='${content}' />">
	
	<script>
	/* for(var i=0; i< 30; i++) {
		var a = "bbsContent" + (i+5);
		var value = []; 
		value =	document.getElementById("bbsConetent5").value; // bbsContent(i)의 값 구하기
		value.removeAll(Arrays.asList("",null)); // 없는 배열을 삭제함!! (null 제거)
		var rows = []; 
		rows =	value.split('&#10;').length;
		console.log(rows); 

	} */
	var value = document.getElementById("value").value;
	var rows = value.split('&#10;').length;
	console.log(rows); 
	</script> --%>
	
</body>