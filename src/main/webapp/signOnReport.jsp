<%@page import="user.User"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="user.UserDAO"%>
<%@page import="org.mariadb.jdbc.internal.failover.tools.SearchFilter"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<title>RMS</title>
<link href="css/index.css" rel="stylesheet" type="text/css">

</head>
<body id="weekreport">
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>


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
		
		// bbsID를 초기화 시키고
		// 'bbsID'라는 데이터가 넘어온 것이 존재한다면 캐스팅을 하여 변수에 담는다
		int bbsID = 0;
		if(request.getParameter("bbsID") != null){
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		
		// 만약 넘어온 데이터가 없다면
		if(bbsID == 0){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='bbs.jsp'");
			script.println("</script");
		}
		
		// 유효한 글이라면 구체적인 정보를 'bbs'라는 인스턴스에 담는다
		BbsDAO bbsDAO = new BbsDAO();
		Bbs bbs = new BbsDAO().getBbs(bbsID);
		UserDAO userDAO = new UserDAO();
		String name = userDAO.getName(id);

		
			// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			String dl = bbsDAO.getDLS(bbsID);
			if(dl.isEmpty()) { //삭제 되어 비어있다면,
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('게시글이 제거되거나 수정되었을 수 있습니다. 확인하여 주십시오.')");
				script.println("history.back()");
				script.println("</script>");
			}
			Date time = new Date();
			String timenow = dateFormat.format(time);

			Date dldate = dateFormat.parse(dl);
			Date today = dateFormat.parse(timenow);
			
	
	
		
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
				works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
			}
			
			workSet = String.join("/",works);


		}
		
		String rk = userDAO.getRank((String)session.getAttribute("id"));
		
		// 사용자 정보 담기
		User user = userDAO.getUser(name);
		String password = user.getPassword();
		String rank = user.getRank();
		//이메일  로직 처리
		String Staticemail = user.getEmail();
		String[] email = Staticemail.split("@");
	%>
	
	
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
							<li class="active"><a href="signOn.jsp">승인(제출)</a></li>
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
								<li><a href="bbsRk.jsp">작성</a></li>
								<li><a href="summaryRk.jsp">제출 목록</a></li>
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
	
	
	
	
<div class="container-fluid" style="margin-left:15%">
<table id="JR_PAGE_ANCHOR_0_1" role="none" class="jrPage" data-jr-height="595" style="empty-cells: show; width: 70%; border-collapse: collapse; background-color: white; top:5%; ">
<tr role="none" valign="top" style="height:0">
<td style="width:70px"></td>
<td style="width:3px"></td>
<td style="width:1px"></td>
<td style="width:46px"></td>
<td style="width:238px"></td>
<td style="width:1px"></td>
<td style="width:50px"></td>
<td style="width:50px"></td>
<td style="width:19px"></td>
<td style="width:31px"></td>
<td style="width:4px"></td>
<td style="width:47px"></td>
<td style="width:1px"></td>
<td style="width:223px"></td>
<td style="width:50px"></td>
<td style="width:46px"></td>
<td style="width:4px"></td>
<td style="width:1px"></td>
<td style="width:16px"></td>
</tr>
<tr valign="top" style="height:23px">
<td colspan="24">
</td>
</tr>
<tr valign="top" style="height:30px">
<td>
</td>
<td colspan="14" style="text-indent: 0px; text-align: left;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 24px; line-height: 2; font-weight: bold;"><%= bbs.getBbsTitle() %></span></td>
<td colspan="10">
</td>
</tr>
<tr valign="top" style="height:5px">
<td>
</td>
<td colspan="15" style="border-top: 1px solid #000000; ">
</td>
<td colspan="3">
</td>
</tr>
<tr valign="top" style="height:9px">
<td colspan="19">
</td>
</tr>
<tr valign="top" style="height:30px">
<td colspan="3">
</td>
<td colspan="7" style="background-color: #C7CDFD; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 20px; line-height: 1.3300781; font-weight: bold;">금주 업무 실적</span></td>
<td>
</td>
<td colspan="7" style="background-color: #C7CDFD; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 20px; line-height: 1.3300781; font-weight: bold;">차주 업무 계획</span></td>
<td>
</td>
</tr>
<tr valign="top" style="height:3px">
<td colspan="19">
</td>
</tr>

<tr valign="top" style="height:37px">
<td colspan="2">
</td>
<td colspan="2" style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">구분/<br/>담당자</span></td>
<td colspan="2" style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">업무 내용</span></td>
<td style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">접수일</span></td>
<td style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">완료<br/>목표일</span></td>
<td colspan="2" style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">진행율<br/>완료일</span></td>
<td>
</td>
<td style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">구분/<br/>담당자</span></td>
<td colspan="2" style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">업무 내용</span></td>
<td style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">접수일</span></td>
<td colspan="2" style="background-color: #FFCC99; border: 1px solid #000000; text-indent: 0px;  vertical-align: middle;text-align: center;">
<span style="font-family: 맑은 고딕; color: #000000; font-size: 18px; line-height: 1.3300781; font-weight: bold;">완료<br/>목표일</span></td>
<td colspan="2">
</td>
</tr>

<!-- for문을 통해 출력 -->

<tr valign="top" align="center">
	<td colspan="2">
	</td>
   	 <td colspan="2" style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea" readonly id="bbsManager" name="bbsManager" style="resize:none; height:180px; width:100%; border:none; overflow:auto; vertical-align:top; text-align: center;" placeholder="구분/담당자"  readonly><%= bbs.getBbsManager() %></textarea></td>
	<td colspan="2" style=" border: 1px solid #000000; text-indent: 0px;  vertical-align:top;text-align: center;">
	<textarea class="textarea" readonly id="bbsContent" required style="resize:none; height:180px;width:100%; border:none;  " placeholder="업무내용" name="bbsContent"><%= bbs.getBbsContent() %></textarea></td>
	<td style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea" readonly id="bbsStart" required style="resize:none; height:180px; width:100%; border:none; text-align: center;" placeholder="접수일" name="bbsStart"  oninput="this.value = this.value
												.replace(/[^0-9./.\s.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsStart() %></textarea></td>
	<td style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea" readonly id="bbsTarget" required style="resize:none; height:180px; width:100%; border:none; text-align: center;" placeholder="완료목표일" name="bbsTarget" oninput="this.value = this.value
												.replace(/[^0-9./.\s.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsTarget() %></textarea></td>
	<td colspan="2" style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea" readonly id="bbsEnd" required style="resize:none; height:180px; width:100%; border:none; text-align: center;"  placeholder="진행율/완료일" name="bbsEnd" oninput="this.value = this.value
												.replace(/[^0-9./.\s.%.-.ㅂ.ㅗ.ㄹ.ㅠ]/g, '')
												.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsEnd() %></textarea></td>
	<td>
	</td>
	<td style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea"  readonly style="resize:none; height:180px; width:100%; border:none; overflow:auto; text-align: center;" placeholder="구분/담당자"   readonly><%= bbs.getBbsManager() %></textarea></td>
	<td colspan="2" style=" border: 1px solid #000000; text-indent: 0px;  vertical-align:top;text-align: center;">
	<textarea class="textarea" readonly required id="bbsNContent" style="resize:none; height:180px;width:100%; border:none; " placeholder="업무내용" name="bbsNContent"><%= bbs.getBbsNContent() %></textarea></td>
	<td style=" border: 1px solid #000000; text-indent: 0px;  vertical-align: top;text-align: center;">
	<textarea class="textarea" readonly required id="bbsNStart" style="resize:none; height:180px; width:100%; border:none; text-align: center;" placeholder="접수일" name="bbsNStart"  oninput="this.value = this.value
												.replace(/[^0-9./.\s.-]/g, '')
												.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNStart() %></textarea></td>
	<td colspan="2" style=" border: 1px solid #000000; text-indent: 0px;  vertical-align:top;text-align: center;">
	<textarea class="textarea" readonly required id="bbsNTarget" style="resize:none; height:180px; width:100%; border:none; text-align: center; " placeholder="완료목표일" name="bbsNTarget" oninput="this.value = this.value
												.replace(/[^0-9./.\s.-]/g, '')
												.replace(/(\..*)\./g, '$1');"><%= bbs.getBbsNTarget() %></textarea></td>
	<td colspan="2">
	
	</td>
</tr>
<tr  style="height:80px">
	<td colspan="15" style="margin-right:50px;">
		<a href="signOn.jsp" style="margin-left:130px;" class="btn btn-primary pull-right">목록</a>
	</td>
	<td>
		<button style="margin-left:20px;" class="btn btn-success pull-right" id="<%= bbs.getBbsID() %>" onclick="signOn_click(this.id);"> 승인 </button>
	</td>
	<td>
		<%-- <a class="btn btn-success pull-right" href="ppt.jsp?deadLine=<%= list.get(0).getBbsDeadline() %>">PPTX</a> --%>
	</td>
</tr>
<tr valign="top" style="height:30px">
<td>
</td>
</tr>
</table>
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
	function signOn_click(clicked_id) {
		var trCnt = $('#bbsTable tr').length; 
		//bbsID를 가져와 작업을 진행.
		location.href="signOnAction.jsp?bbsID="+clicked_id+"&trCnt="+trCnt;
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
	
	
</body>
</html>