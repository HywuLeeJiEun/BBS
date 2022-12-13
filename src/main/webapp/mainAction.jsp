<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="bbs.BbsDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="bbs" class="bbs.Bbs" scope="page" />
<jsp:setProperty name="bbs" property="bbsTitle" />
<jsp:setProperty name="bbs" property="bbsManager" />
<jsp:setProperty name="bbs" property="bbsContent" />
<jsp:setProperty name="bbs" property="bbsStart" />
<jsp:setProperty name="bbs" property="bbsTarget" />
<jsp:setProperty name="bbs" property="bbsEnd" />
<jsp:setProperty name="bbs" property="bbsNContent" />
<jsp:setProperty name="bbs" property="bbsNStart" />
<jsp:setProperty name="bbs" property="bbsNTarget" />
<jsp:setProperty name="bbs" property="bbsDeadline" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Baynex-insert</title>
</head>
<body>
	<%
	
		// 현재 세션 상태를 체크한다
		String id = null;
		
		String NContent = null;
		String NStart = null;
		String NTarget = null;
		
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='login.jsp'");
			script.println("</script>");
		}
		
		// 저장할 내용을 담을 리스트 생성
		String getbbscontent = "";
		String getbbsstart = "";
		String getbbstarget = "";
		String getbbsend = "";

		String getbbsncontent = "";
		String getbbsnstart = "";
		String getbbsntarget = "";

		List<String> bbscontent = new ArrayList<String>();
		List<String> bbsstart = new ArrayList<String>();
		List<String> bbstarget = new ArrayList<String>();
		List<String> bbsend = new ArrayList<String>();

		List<String> bbsncontent = new ArrayList<String>();
		List<String> bbsnstart = new ArrayList<String>();
		List<String> bbsntarget = new ArrayList<String>();
		
		// 몇번 반복하는지!
		String trCnt = null;
		if(request.getParameter("trCnt") != null){
			trCnt = request.getParameter("trCnt");
		} 
		if(trCnt == null) {
			trCnt = "6";
		}
		
		String trNCnt = null;
		if(request.getParameter("trNCnt") != null){
			trNCnt = request.getParameter("trNCnt");
		}
		if(trNCnt == null) {
			trNCnt = "3";
		}
		
		
		for(int i=5; i< Integer.parseInt(trCnt); i++) { //trCnt 개수만큼 반복 
			//금주 업무 내용 + select box
			String a = "bbsContent";
			String jobs = "jobs";
			// -[담당업무] CONTENT 내용~ 으로 나오도록 함.
			if(request.getParameter(a+((i-5)+5)) != null) { // 값이 비어있지 않다면,
				if(!request.getParameter(jobs+((i-5)+5)).contains("시스템") && !request.getParameter(jobs+((i-5)+5)).contains("기타")) { //시스템이나 기타가 아니라면,
			bbscontent.add("- ["+ request.getParameter(jobs+((i-5)+5)) +"] " + request.getParameter(a+(i+5)));
				}else {
					bbscontent.add("- " + request.getParameter(a+((i-5)+5)));
				}
			} else {
			bbscontent.add(request.getParameter(a+((i-5)+5)));
			//bbscontent.removeAll(Arrays.asList("",null)); // 없는 배열을 삭제함!! (null 제거)
			}
			getbbscontent = String.join("&#10;&#10;",bbscontent); // 각 배열 요소마다 줄바꿈 하여 넣음.
			getbbscontent = getbbscontent.replace("\r\n","&#10;"); // String 내부의 줄바꿈을 표현
			
			//금주 접수일 (date)
			String b = "bbsStart";
			String date = request.getParameter(b+((i-5)+5));
			String[] adddate = date.split("-");
			String start = adddate[1] +"/"+ adddate[2];
			bbsstart.add(start);
			//bbsstart.removeAll(Arrays.asList("",null));
			getbbsstart = String.join(",",bbsstart);
			getbbsstart = getbbsstart.replace("\r\n","&#10;");
			
			//금주 완료 목표일 (null) (date)
			String c = "bbsTarget";
			if(request.getParameter(c+((i-5)+5)).isEmpty() || request.getParameter(c+((i-5)+5)) == null) {
				bbstarget.add("[보류]");
			} else {
				String datec = request.getParameter(c+((i-5)+5));
				String[] adddatec = datec.split("-");
				String target = adddatec[1]+"/"+adddatec[2];
				bbstarget.add(target);
			}
			//bbstarget.removeAll(Arrays.asList("",null));
			getbbstarget = String.join(",",bbstarget);
			getbbstarget = getbbstarget.replace("\r\n","&#10;"); 
			
			//금주 진행율/완료일 (null)
			String d = "bbsEnd";
			if(request.getParameter(d+((i-5)+5)).isEmpty() || request.getParameter(d+((i-5)+5)) == null) {
				bbsend.add("[보류]");
			} else {
			bbsend.add(request.getParameter(d+((i-5)+5)));
			}
			//bbsend.removeAll(Arrays.asList("",null));
			getbbsend = String.join(",",bbsend);
			getbbsend = getbbsend.replace("\r\n","&#10;");
			
			
		}
		
		for(int i=2; i< Integer.parseInt(trNCnt); i++) { //trNCnt 개수만큼 반복 
			// << 차주 >> 
			String jobs = "jobs";
			//차주 업무 내용
			String e = "bbsNContent";
			if(request.getParameter(e+((i-2)+2)) != null) {
				if(!request.getParameter(jobs+((i-2)+2)).contains("시스템") && !request.getParameter(jobs+((i-2)+2)).contains("기타")) {
			bbsncontent.add("- ["+ request.getParameter(jobs+((i-2)+2)) + "] " + request.getParameter(e+((i-2)+2)));
				} else {
					bbsncontent.add("- " + request.getParameter(e+((i-2)+2)));
				}
			} else {
				bbsncontent.add(request.getParameter(e+((i-2)+2)));
				//bbsncontent.removeAll(Arrays.asList("",null));
			}
			getbbsncontent = String.join("&#10;&#10;",bbsncontent);
			getbbsncontent = getbbsncontent.replace("\r\n","&#10;");

			
			//차주 접수일 (date)
			String f = "bbsNStart";
			String datef = request.getParameter(f+((i-2)+2));
			String[] adddatef = datef.split("-");
			String nstart = adddatef[1]+"/"+adddatef[2];
			bbsnstart.add(nstart);
			//bbsnstart.removeAll(Arrays.asList("",null));
			getbbsnstart = String.join(",",bbsnstart);
			getbbsnstart = getbbsnstart.replace("\r\n","&#10;"); 
			
			
			//차주 완료 목표일 (null) (date)
			String g = "bbsNTarget";
			if(request.getParameter(g+((i-2)+2)).isEmpty() || request.getParameter(g+((i-2)+2)) == null){
				bbsntarget.add("[보류]");
			}else {
				String dateg = request.getParameter(g+((i-2)+2));
				String[] adddateg = dateg.split("-");
				String ntarget = adddateg[1]+"/"+adddateg[2];
				bbsntarget.add(ntarget);
			}
			//bbsntarget.removeAll(Arrays.asList("",null));
			getbbsntarget = String.join(",",bbsntarget);
			getbbsntarget = getbbsntarget.replace("\r\n","&#10;"); 
		}
		
	%>
		<form id="post_item" method="post" action="mainActionComplete.jsp">
			<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
				<tbody id="tbody">
					<tr id="tr">
						<td><textarea class="textarea" id="manager" name="manager" readonly><%= bbs.getBbsManager() %></textarea></td>
						<td><textarea class="textarea" id="title" name="title" readonly><%= bbs.getBbsTitle() %></textarea></td>
						<td><textarea class="textarea" id="bbsDeadline" name="bbsDeadline" readonly><%= bbs.getBbsDeadline() %></textarea></td>
						<td><textarea class="textarea" id="getbbscontent" name="getbbscontent" readonly><%= getbbscontent %></textarea></td>
						<td><textarea class="textarea" id="getbbsstart" name="getbbsstart" readonly><%= getbbsstart %></textarea></td>
						<td><textarea class="textarea" id="getbbstarget" name="getbbstarget" readonly><%= getbbstarget %></textarea></td>
						<td><textarea class="textarea" id="getbbsend" name="getbbsend" readonly><%= getbbsend %></textarea></td>
						<td><textarea class="textarea" id="getbbsncontent" name="getbbsncontent" readonly><%= getbbsncontent %></textarea></td>
						<td><textarea class="textarea" id="getbbsnstart" name="getbbsnstart" readonly><%= getbbsnstart %></textarea></td>
						<td><textarea class="textarea" id="getbbsntarget" name="getbbsntarget" readonly><%= getbbsntarget %></textarea></td>
						<!-- <button id="save" onclick="handleButtonOnclick()"> + </button> -->
					</tr>
				</tbody>
			</table>
			<button type="button" id="save" style="margin-bottom:15px; margin-right:30px" onclick="addRow()" class="btn btn-primary"> + </button>
		</form>

	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
 	
	<%
	// <<<<<<<<<<<<< 금주 컨텐츠 >>>>>>>>>>>>>>>>>>>
	List<String> b = new ArrayList<String>();
	for(int i=0; i < 30;  i++) {
		String a = "bbsContent";
		b.add(request.getParameter(a+(i+5)));
		b.removeAll(Arrays.asList("",null));
	}
	%>
	<c:set var="content" value="<%= b %>"/>
	<input type="hidden" id="value" value="<c:out value='${content}' />">
	
	<script>
	var numliststr = "";
	var numlist = [];
	var value = [];
	value = document.getElementById("value").value;
	value = value.replace("[","");
	value = value.replace("]","");
	value = value.split(',');
	
	for(var i=0; i < value.length; i++ ) {
		var content = value[i];		
		var rows = content.split('\n').length;
		numlist.push(rows); // content의 줄바꿈 갯수
	}
	numliststr = numlist.join(',');
	</script>
	
	
	<%
	// <<<<<<<<<<<<<< 차주 컨텐츠 >>>>>>>>>>>>>>.
	List<String> c = new ArrayList<String>();
	for(int i=0; i < 30;  i++) {
		String d = "bbsNContent";
		c.add(request.getParameter(d+(i+2)));
		c.removeAll(Arrays.asList("",null));
	}
	%>
	<c:set var="ncontent" value="<%= c %>"/>
	<input type="hidden" id="nvalue" value="<c:out value='${ncontent}' />">
	
	<script>
	var nnumliststr = "";
	var nnumlist = [];
	var nvalue = [];
	nvalue = document.getElementById("nvalue").value;
	nvalue = nvalue.replace("[","");
	nvalue = nvalue.replace("]","");
	nvalue = nvalue.split(',');
	
	for(var i=0; i < nvalue.length; i++ ) {
		var ncontent = nvalue[i];		
		var nrows = ncontent.split('\n').length;
		nnumlist.push(nrows); // content의 줄바꿈 갯수
	}
	nnumliststr=nnumlist.join(',');
	</script>

	<script>
	$(window).on('load', function() {
		document.getElementById("save").click();
		
		/* $('#post_item').submit(); */
	});
	
	function addRow() {
		var innerHtml = "";
		innerHtml += '<td><textarea class="textarea" id="numlist" name="numlist" readonly>'+ numliststr +'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="nnumlist" name="nnumlist" readonly>'+ nnumliststr +'</textarea></td>';
		
		$('#bbsTable > tbody > tr:last').append(innerHtml);
		$('#post_item').submit();
	} 
	</script>   

	 
	 <a> <%= trCnt %> </a>
	 <a> <%= trNCnt %> </a> 
</body>
</html>