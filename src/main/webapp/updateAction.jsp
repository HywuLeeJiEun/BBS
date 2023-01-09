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
		
		//num, numlist를 가공해야함 (만약 기존 data가 사라진다면, 해당 num 또한 제거)
		int num = Integer.parseInt(request.getParameter("num"));
		int nnum = Integer.parseInt(request.getParameter("nnum"));
		String numl = request.getParameter("numlist");
		String nnuml = request.getParameter("nnumlist");
		ArrayList<String> numli = new ArrayList<String>(Arrays.asList(numl.split("&")));
		ArrayList<String> nnumli = new ArrayList<String>(Arrays.asList(nnuml.split("&")));
		
		//con, ncon -> bbsContent(con) <-
		int con = Integer.parseInt(request.getParameter("con"));
		int ncon = Integer.parseInt(request.getParameter("ncon"));
		
		// 몇번 반복하는지!
		String trCnt = null;
		if(request.getParameter("trCnt") != null){
			trCnt = request.getParameter("trCnt");
		} 
		if(trCnt == null) {
			trCnt = "1";
		}
		
		String trNCnt = null;
		if(request.getParameter("trNCnt") != null){
			trNCnt = request.getParameter("trNCnt");
		}
		if(trNCnt == null) {
			trNCnt = "1";
		}
		
		for(int i=0; i< Integer.parseInt(trCnt)+1+con; i++) { //trCnt 개수만큼 반복 
			//금주 업무 내용 + select box
			String a = "bbsContent";
			String jobs = "jobs";
			// -[담당업무] CONTENT 내용~ 으로 나오도록 함.
			if(request.getParameter(a+i) != null) { 
			if(request.getParameter(a+i) != null && request.getParameter(jobs+i) != null) { // 값이 비어있지 않다면,
				if(!request.getParameter(jobs+i).contains("시스템") && !request.getParameter(jobs+i).contains("기타")) { //시스템이나 기타가 아니라면,
			bbscontent.add("- ["+ request.getParameter(jobs+i) +"] " + request.getParameter(a+i));
				}else {
					bbscontent.add("- " + request.getParameter(a+i));
				}
			} else {
			bbscontent.add(request.getParameter(a+i));
			//bbscontent.removeAll(Arrays.asList("",null)); // 없는 배열을 삭제함!! (null 제거)
			}
			getbbscontent = String.join("\r\n",bbscontent); // 각 배열 요소마다 줄바꿈 하여 넣음.
			//getbbscontent = getbbscontent.replace("\r\n","/r/n"); // String 내부의 줄바꿈을 표현
			} else { // 0~num 개수안에서만 이뤄지므로, 해당 내용 제거
				if(numli.size() < num) {
					num -= 1; //개수를 하나 삭제함 
					numli.set(i, ""); //빈값으로 만들기
				}
			}
			
			//금주 접수일 (date)
			String b = "bbsStart";
			String date = request.getParameter(b+i);
			//String[] adddate = date.split("-");
			//start = adddate[1] +"/"+ adddate[2];
			// 양식 2022-11-14 	
			String start ="";
			if(date != null) {
				if(date.length() > 5) {
					start = date.substring(5); // 5번쨰 이후부터 출력 11-14 
					String finalstart = start.replace("-","/");
					bbsstart.add(finalstart);
				} else {
					bbsstart.add(date);
				}
				//bbsstart.removeAll(Arrays.asList("",null));
				getbbsstart = String.join("§",bbsstart);
				//getbbsstart = getbbsstart.replace("\r\n","/r/n");
			}
			
			//금주 완료 목표일 (null) (date)
			String c = "bbsTarget";
			if(request.getParameter(a+i) != null) {
				if(request.getParameter(c+i).isEmpty() || request.getParameter(c+i) == null) {
					bbstarget.add("[보류]");
				} else {
					String datec = request.getParameter(c+i);
					String target ="";
					if(datec.length() > 5) {
						target = datec.substring(5);
						String finaltarget = target.replace("-", "/");
						bbstarget.add(finaltarget);
					}else {
						bbstarget.add(datec);
					}
				}
			//bbstarget.removeAll(Arrays.asList("",null));
			getbbstarget = String.join("§",bbstarget);
			//getbbstarget = getbbstarget.replace("\r\n","/r/n"); 
			}
			
			//금주 진행율/완료일 (null)
			String d = "bbsEnd";
			if(request.getParameter(a+i) != null) {
				if(request.getParameter(d+i).isEmpty() || request.getParameter(d+i) == null) {
					bbsend.add("[보류]");
				} else {
				bbsend.add(request.getParameter(d+i));
				}
				//bbsend.removeAll(Arrays.asList("",null));
				getbbsend = String.join("§",bbsend);
				//getbbsend = getbbsend.replace("\r\n","/r/n");	
				}
			}
		
		for(int i=0; i< Integer.parseInt(trNCnt)+1+ncon; i++) { //trNCnt 개수만큼 반복 
			// << 차주 >> 
			String jobs = "njobs";
			//차주 업무 내용
			String e = "bbsNContent";
			if(request.getParameter(e+i) != null) { //만약 기존 데이터가 삭제됐다면! (0~num 개수만큼)
				
			if(request.getParameter(e+i) != null && request.getParameter(jobs+i) != null) {
				if(!request.getParameter(jobs+i).contains("시스템") && !request.getParameter(jobs+i).contains("기타")) {
			bbsncontent.add("- ["+ request.getParameter(jobs+i) + "] " + request.getParameter(e+i));
				} else {
					bbsncontent.add("- " + request.getParameter(e+i));
				}
			} else {
				bbsncontent.add(request.getParameter(e+i));
				//bbsncontent.removeAll(Arrays.asList("",null));
			}
			getbbsncontent = String.join("\r\n",bbsncontent);
			//getbbsncontent = getbbsncontent.replace("\r\n","/r/n");
			}else { // 0~nnum 개수안에서만 이뤄지므로, 해당 내용 제거
				if(nnumli.size() < nnum) {
				nnum -= 1; //개수를 하나 삭제함 
				nnumli.set(i, ""); //빈값으로 만들기
				}
			}
				
			//차주 접수일 (date)
			String f = "bbsNStart";
			String datef = request.getParameter(f+i);
			
			String nstart ="";
			if(datef != null) {
			if(datef.length() > 5) {
			nstart= datef.substring(5);
			String finalnstart = nstart.replace("-", "/");
			bbsnstart.add(finalnstart);
			} else {
				bbsnstart.add(datef);
			}
			//bbsnstart.removeAll(Arrays.asList("",null));
			getbbsnstart = String.join("§",bbsnstart);
			//getbbsnstart = getbbsnstart.replace("\r\n","/r/n"); 
			}
			
			//차주 완료 목표일 (null) (date)
			String g = "bbsNTarget";
			if(request.getParameter(e+i) != null) {
			if(request.getParameter(g+i).isEmpty() || request.getParameter(g+i) == null){
				bbsntarget.add("[보류]");
			}else {
				String dateg = request.getParameter(g+i);
				String ntarget ="";
				if(dateg.length() > 5) {
					ntarget = dateg.substring(5);
					String finalntarget = ntarget.replace("-", "/");
					bbsntarget.add(finalntarget);
				}else {
					bbsntarget.add(dateg);
				}
			}
			//bbsntarget.removeAll(Arrays.asList("",null));
			getbbsntarget = String.join("§",bbsntarget);
			//getbbsntarget = getbbsntarget.replace("\r\n","/r/n"); 
		}
		}
		
		
		//만약, ERP 디버깅 데이터가  들어왔다면
		int trACnt = 0;
		if(!request.getParameter("trACnt").isEmpty() && !request.getParameter("trACnt").equals("undefined")) {
			trACnt = Integer.parseInt(request.getParameter("trACnt"));
		}
		String erp_date = "";
		String erp_user = "";
		String erp_stext = "";
		String erp_authority ="";
		String erp_division = "";
	
		for(int i=0; i < trACnt; i++) { 
			String a = "erp_date";
			erp_date += request.getParameter(a+(i)) + "\r\n";
			String b = "erp_user";
			erp_user += request.getParameter(b+(i)) + "\r\n";
			String c = "erp_stext";
			erp_stext += request.getParameter(c+(i)) + "\r\n";
			String d = "erp_authority";
			erp_authority += request.getParameter(d+(i)) + "\r\n";
			String e = "erp_division";
			erp_division += request.getParameter(e+(i)) + "\r\n";
		} 
		
		//nnumlist 저장
		numli.removeAll(Arrays.asList("",null));
		nnumli.removeAll(Arrays.asList("",null));
		String numlist = String.join("&",numli);
		String nnumlist = String.join("&",nnumli);
		
	%>
	<a> <%= trNCnt %></a>
	<a> <%= num %></a><br>	
	<a> <%= numlist %></a><br>	
	<a> <%= nnum %></a><br>	
	<a> <%= nnumlist %></a><br>
	
		<form id="post_item" method="post" action="updateActionComplete.jsp">
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
						
						<td><textarea class="textarea" id="erp_date" name="erp_date" readonly><%= erp_date %></textarea></td>
						<td><textarea class="textarea" id="erp_user" name="erp_user" readonly><%= erp_user %></textarea></td>
						<td><textarea class="textarea" id="erp_stext" name="erp_stext" readonly><%= erp_stext %></textarea></td>
						<td><textarea class="textarea" id="erp_authority" name="erp_authority" readonly><%= erp_authority %></textarea></td>
						<td><textarea class="textarea" id="erp_division" name="erp_division" readonly><%= erp_division %></textarea></td>
						<td><textarea style="display:none" name="num"><%= num %></textarea>
						<textarea style="display:none" name="nnum"><%= nnum %></textarea>
						<textarea style="display:none" name="numlist"><%= numlist %></textarea>
						<textarea style="display:none" name="nnumlist"><%= nnumlist %></textarea></td>
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
	String finalb="";
	for(int i=5; i < Integer.parseInt(trCnt);  i++) {
		String a = "bbsContent";
		b.add(request.getParameter(a+i));
		b.removeAll(Arrays.asList("",null));
		finalb = String.join("§",b);
		//finalb = finalb.replace("\r\n","/r/n");
	}
	%>
	<textarea><%= finalb  %></textarea><br>
	<textarea><%= b %></textarea>
	<textarea><%= getbbscontent %></textarea>
	<c:set var="content" value="<%= finalb %>"/>
	<input type="hidden" id="value" value="<c:out value='${content}' />">
	

	
	
	<%
	// <<<<<<<<<<<<<< 차주 컨텐츠 >>>>>>>>>>>>>>.
	String finald = "";
	List<String> c = new ArrayList<String>();
	for(int i=2; i < Integer.parseInt(trNCnt);  i++) {
		String d = "bbsNContent";
		c.add(request.getParameter(d+i));
		c.removeAll(Arrays.asList("",null));
		finald = String.join("§",c);
		//finald = finald.replace("\r\n","/r/n");
	}
	%>
	<c:set var="ncontent" value="<%= finald %>"/>
	<input type="hidden" id="nvalue" value="<c:out value='${ncontent}' />">
	


	<script>
	$(window).on('load', function() {
		document.getElementById("save").click();
		
	});
	
	function addRow() {
		$('#post_item').submit();
	}    
	</script> 

	 
	 <a> <%= b %> </a>
	 <a> <%= trNCnt %> </a> 
</body>
</html>