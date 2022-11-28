<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="user.UserDAO"%>
<%@page import="bbs.Bbs"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<% request.setCharacterEncoding("utf-8"); %>   
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/functions" %>

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
	<%
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		int week = 0; //기본은 0으로 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'week'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'week'변수에 저장한다
		if(request.getParameter("week") != null){
			week = Integer.parseInt(request.getParameter("week"));
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
			<a class="navbar-brand" href="bbsUpdate.jsp">Baynex 주간보고</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li class="active"><a href="bbsUpdate.jsp">주간보고</a></li>
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
						<li><a href="logoutAction.jsp">로그아웃</a></li>
			</ul>
			<%
				}
			
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
					works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
				}
				
				workSet = String.join("/",works);


			}
			%>
		</div>
	</nav>
	
	
	
	<!-- ********** 게시판 글쓰기 양식 영역 ********* -->

		<div class="container-fluid">
			<div class="row">
				<div class="col-xs-2" align="right">
						<button class="btn btn-default btn-lg" type="button" style="margin-top:150%;margin-right:20%" data-toggle="tooltip" title="지난 주간보고" onclick="location.href='lastWeek.jsp?week=<%=week%>'"> < </button>
				</div>
				
				<!-- ******* 이전 게시글 버튼 ******* -->
				<div class="col-xs-8">
					<form method="post" action="bbsUpdateAction.jsp">
							
						<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
							<thead>
								<tr>
									<th colspan="3" style=" text-align: center; color:blue "></th>
								</tr>
							</thead>
						</table>

					
						<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
							<thead>
								<tr>
									<th colspan="5" style="background-color: #eeeeee; text-align: center;">BBS 주간보고 작성</th>
								</tr>
							</thead>
							<tbody>
								<tr>
										<td colspan="1"> 주간보고 명세서 </td>
										<td align="center" colspan="2"><input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= bbs.getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %>"></td>
										<td colspan="1">  주간보고 제출일 </td>
										<td align="center" colspan="1"><input type="date" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= date %>"></td>
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
										<!-- (구분/담당자는 처음 작성하는 사람을 위하여 유지) 추후 userName과 연결 -->
									 <td><textarea class="textarea"  style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50"><%= workSet %>&#10;<%= bbs.getUserName() %></textarea></td>
									 <td><textarea class="textarea" id="bbsContent" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsContent"><%= bbs.getBbsNContent() %></textarea></td>
									 <td><textarea class="textarea" id="bbsStart" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsStart" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNStart() %></textarea></td>
									 <td><textarea class="textarea" id="bbsTarget" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsTarget" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNTarget() %></textarea></td>	
									 <td><textarea class="textarea" id="bbsEnd" required style="height:180px; width:100%; border:none;" placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
													.replace(/[^0-9./.\s.%.-]/g, '')
													.replace(/(\..*)\./g, '$1');"></textarea></td>									
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
											 <td><input type="date" style="height:45px; width:auto;" id="start_add" class="form-control" placeholder="접수일" name="start_add" ></td>
											 <td><input type="date" style="height:45px; width:auto;" id="target_add" class="form-control" placeholder="완료목표일" name="target_add"></td>	
											 <td><textarea class="textarea" id="end_add" style="height:45px; width:100%; border:none" maxlength="5" placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
													.replace(/[^0-9./.\s.%.-]/g, '')
													.replace(/(\..*)\./g, '$1');"></textarea></td>	
										</tr>
										<tr>
											<td colspan="5"><button type="button" style="margin-bottom:5px;margin-top:5px; margin-left:15px" onclick="textAdd()" class="btn btn-primary pull-right"> 추가 </button>
															<button type="button" style="margin-bottom:5px;margin-top:5px" onclick="textRe()" class="btn btn-info pull-right"> 초기화 </button></td>
										</tr>	
										
										<tr>
										
										</tr>
								
								
								<tr>
									<th colspan="5" style="background-color: #D4D2FF;" align="center">차주 업무 실적</th>
								</tr>
								<tr style="background-color: #FFC57B;">
										<th width="6%">|  담당자</th>
										<th width="33%">| &nbsp; 업무내용</th>
										<th width="1%">| &nbsp; 접수일</th>
										<th width="1%">| &nbsp; 완료목표일</th>
									</tr>
								<tr align="center">	
									 <td><textarea class="textarea"  style="height:180px; width:100%; border:none;" placeholder="구분/담당자" maxlength="50" ><%= workSet %>&#10;<%= bbs.getUserName() %></textarea></td>
									 <td><textarea class="textarea" id="bbsNContent" required style="height:180px;width:100%; border:none;" placeholder="업무내용" name="bbsNContent" ></textarea></td>
									 <td><textarea class="textarea" id="bbsNStart" required style="height:180px; width:100%; border:none;" placeholder="접수일" name="bbsNStart" oninput="this.value = this.value
													.replace(/[^0-9./.\s.-]/g, '')
													.replace(/(\..*)\./g, '$1');"></textarea></td>
									 <td><textarea class="textarea" id="bbsNTarget" required style="height:180px; width:100%; border:none;" placeholder="완료목표일" name="bbsNTarget" oninput="this.value = this.value
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
										 <td><input type="date" style="height:45px; width:auto;" id="nstart_add" class="form-control" placeholder="접수일" name="nstart_add" ></td>
										 <td><input type="date" style="height:45px; width:auto;" id="ntarget_add" class="form-control" placeholder="완료목표일" name="ntarget_add"></td>	
										 <td colspan="5"><button type="button" style="margin-bottom:5px; margin-top:5px; margin-left:15px" onclick="textNAdd()" class="btn btn-primary pull-right"> 추가 </button>
										 				 <button type="button" style="margin-bottom:5px;margin-top:5px" onclick="textNRe()" class="btn btn-info pull-right"> 초기화 </button></td>	
									</tr>
							</tbody>
						</table>
						<!-- 제출 버튼 생성 -->
						<a href="main.jsp" class="btn btn-info">새로 작성하기</a>
						<a href="bbsUpdate.jsp" class="btn btn-light">돌아가기</a>
						<button type="submit" style="margin-bottom:50px" class="btn btn-primary pull-right"> 저장 </button>
					</form>
				</div>
				
				<!-- ******* 이후 게시글 버튼 ******* -->
				<div class="col-xs-1" align="left">

				</div>
			</div>
		</div>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
	<script>
	$(document).ready(function(){
		$('[data-toggle="tooltip"]').tooltip();
	});
	
	</script>
	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('input keyup input focusin focusout blur change mousemove', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input focusin focusout blur change mousemove', function() {resizeTextarea(this); });
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
	// 차주 업무 실적 추가 script
	function textNAdd() {
		var ntarget = document.getElementById("njobs");
		var noption = ntarget.options[ntarget.selectedIndex].text;
		var ncadd = document.getElementById('ncontent_add').value;
		
		// 줄바꿈 확인 개수
		var lb_ncadd = ncadd.split("\n").length -1;
		
		if(noption === "담당 업무 선택") {
			alert("(차주) 담당 업무 선택이 완료되지 않았습니다.");
			return false;
		}
		if($("#ncontent_add").val() == "") {
			alert("(차주) 업무 내용이 입력되지 않았습니다.");
			$("#ncontent_add").focus();
			return false;
		} 
		if(noption === "무관") {
			document.getElementById('bbsNContent').value += '-' + ' ' + ncadd + '\n';
		} else {
		document.getElementById('bbsNContent').value +=  '-' + '[' + noption + ']'+ ' ' + ncadd + '\n';
		}
		
		var nsadd = document.getElementById('nstart_add').value;
		var nwords = nsadd.split("-");
		if(nwords == "") {
				alert('(차주) 접수일 미입력으로 --- 표시됩니다.');
				document.getElementById('bbsNStart').value += '---' + '\n';
				for(var i=0; i < lb_ncadd; i++) {
					document.getElementById('bbsNStart').value += '\n';
				}
		} else {
			document.getElementById('bbsNStart').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_ncadd; i++) {
				document.getElementById('bbsNStart').value += '\n';
			}
		}

		var ntadd = document.getElementById('ntarget_add').value;
		var nword = ntadd.split("-");
		if(nword == "") {
				alert("(차주) 목표일 미입력으로 --- 표시됩니다.");
				document.getElementById('bbsNTarget').value += '---' + '\n';
				for(var i=0; i < lb_ncadd; i++) {
					document.getElementById('bbsNTarget').value += '\n';
			}
		} else {
			document.getElementById('bbsNTarget').value += words[1] + '/' + words[2] + '\n';
			for(var i=0; i < lb_ncadd; i++) {
				document.getElementById('bbsNTarget').value += '\n';
			}
		}
		
 		var sndown = $("textarea").prop('scrollHeight');
		$("textarea").scrollTop(sndown); 
	};
	</script>
		<script>
	function textNRe() {
		document.getElementById("njobs").value="담당 업무 선택";
		document.getElementById('ncontent_add').value="";
		document.getElementById('nstart_add').value="";
		document.getElementById('ntarget_add').value="";
		document.getElementById('nend_add').value="";
	}
	</script>
	
</body>