<%@page import="rms.rms_next"%>
<%@page import="rms.rms_this"%>
<%@page import="rms.RmsDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>
	<%
	
		// 현재 세션 상태를 체크한다
		String id = null;
		
		String NContent = null;
		String NStart = null;
		String NTarget = null;
		
		//생성된 마지막 content의 수
		int con = Integer.parseInt(request.getParameter("con"));
		int ncon = Integer.parseInt(request.getParameter("ncon"));
		int acon = Integer.parseInt(request.getParameter("acon"));
		
		//줄 개수
		int trCnt = Integer.parseInt(request.getParameter("trCnt"));
		int trNCnt = Integer.parseInt(request.getParameter("trNCnt"));
		int trACnt = Integer.parseInt(request.getParameter("trACnt"));
		
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		} else {
		UserDAO userDAO = new UserDAO();
		String pluser = "";
		if(userDAO.getpluserunder(id) != null) { // 비어있지 않다면,
			pluser = userDAO.getpluserunder(id);
		}
		String name = userDAO.getName(id);
		
		
		// 필요한 데이터 추출
		RmsDAO rms = new RmsDAO();
		String bbsDeadline = request.getParameter("bbsDeadline");		
		String bbsTitle = request.getParameter("bbsTitle");
		java.sql.Timestamp date = rms.getDateNow();
		
		//updatedelete에 목록이 있는지 확인
		//rms_last -> 목록 불러오기 (사용자)
		// [bbsDeadline, sign, pluser]
		ArrayList<rms_next> llist = rms.getlastSign(id,"미승인",1);
		
		int n = 0;
		int nn = 0;
		int an = 0;
		
		//데이터 삭제
		int tdel = rms.tdelete(id, bbsDeadline);
		int ldel = rms.ldelete(id, bbsDeadline);
		rms.edelete(id, bbsDeadline);
		
				
			// << 금주 데이터 저장 >> - rms_this
			for(int i=0; i < trCnt; i++) {
				String a = "bbsContent";
				String jobs = "jobs";
				//줄바꿈 세기
				int num = 0;
				
				//bbscontent
				String bbscontent = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(a+i) != null && request.getParameter(jobs+i) != null) { // 값이 비어있지 않다면,
						if(!request.getParameter(jobs+i).contains("시스템") && !request.getParameter(jobs+i).contains("기타")) { //시스템이나 기타가 아니라면,
							bbscontent = "- ["+ request.getParameter(jobs+i) +"] " + request.getParameter(a+i);
							//줄바꿈 세기
							num = bbscontent.split("\r\n").length-1;
						}else {
							if(request.getParameter(a+i).indexOf('-') > -1 && request.getParameter(a+i).indexOf('-') < 2) {
								bbscontent = request.getParameter(a+i);
							} else {
								bbscontent = "- " + request.getParameter(a+i);
							}
							//줄바꿈 세기
							num = bbscontent.split("\r\n").length-1;
						}
					} else { //job 선택이 없는 경우!
						bbscontent = request.getParameter(a+i);
						//줄바꿈 세기
						num = bbscontent.split("\r\n").length-1;
					}
				}
				
				//bbsstart - 접수일 (not null)
				String b = "bbsStart";
				String bbsstart ="";
				if(request.getParameter(a+i) != null) {
					bbsstart = request.getParameter(b+i);
				}
				
				
				//bbstarget - 완료목표일 
				String c = "bbsTarget";
				String bbstarget = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(c+i).isEmpty() || request.getParameter(c+i) == null) {
						bbstarget = "";
					} else {
						bbstarget = request.getParameter(c+i);
					}
				}
				
				//bbsend - 진행율/완료일
				String d = "bbsEnd";
				String bbsend = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(d+i).isEmpty() || request.getParameter(d+i) == null) {
						bbsend = "[보류]";
						
					} else {
						bbsend = request.getParameter(d+i);	
					}
					
					//줄바꿈 제거(임의 변경을 최소화 하기 위함)
					bbsend = bbsend.replaceAll("\r\n", "");

				}
				
				
				//update 작업 진행 (rms_this)
				if(request.getParameter(a+i) != null) { //해당 데이터가 비어있지 않고 모두 들어있다면!
					// write_rms_this
					int numlist = rms.write_rms_this(id, bbsDeadline, bbsTitle, date, bbscontent, bbsstart, bbstarget, bbsend);
					if(numlist == -1) { //데이터 저장 오류
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('(금주)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
						script.println("history.back();");
						script.println("</script>");
						n = -1;
					}
				}
			} 
			
			
			// << 차주 데이터 저장 >> - rms_last
			for(int i=0; i < trNCnt; i++) {
				String a = "bbsNContent";
				String jobs = "njobs";
				//줄바꿈 세기
				int num = 0;
				
				//bbscontent
				String bbscontent = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(a+i) != null && request.getParameter(jobs+i) != null) { // 값이 비어있지 않다면,
						if(!request.getParameter(jobs+i).contains("시스템") && !request.getParameter(jobs+i).contains("기타")) { //시스템이나 기타가 아니라면,
							bbscontent = "- ["+ request.getParameter(jobs+i) +"] " + request.getParameter(a+i);
							//줄바꿈 세기
							num = bbscontent.split("\r\n").length-1;
						}else {
							if(request.getParameter(a+i).indexOf('-') > -1 && request.getParameter(a+i).indexOf('-') < 2) {
								bbscontent = request.getParameter(a+i);
							} else {
								bbscontent = "- " + request.getParameter(a+i);
							}
							//줄바꿈 세기
							num = bbscontent.split("\r\n").length-1;
						}
					} else { //job 선택이 없는 경우!
						bbscontent = request.getParameter(a+i);
						//줄바꿈 세기
						num = bbscontent.split("\r\n").length-1;
					}
				}
				
				//bbsstart - 접수일 
				String b = "bbsNStart";
				String bbsstart ="";
				if(request.getParameter(a+i) != null) {
					bbsstart = request.getParameter(b+i);

				}
				
				//bbstarget - 완료목표일 (null 이라면 [보류])
				String c = "bbsNTarget";
				String bbstarget = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(c+i).isEmpty() || request.getParameter(c+i) == null) {
						bbstarget = "";
					} else {
						bbstarget = request.getParameter(c+i);	
					}

				}
				
				// 저장에 오류가 없는지 확인!
				if(request.getParameter(a+i) != null) { //해당 데이터가 비어있지 않고 모두 들어있다면!
					// write_rms_last
					int numlist = rms.write_rms_next(id, bbsDeadline, bbscontent, bbsstart, bbstarget, pluser);
					if(numlist == -1) { //데이터 저장 오류가 발생하면, 데이터 삭제
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('(차주)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
						script.println("history.back();");
						script.println("</script>");
						nn = -1;
					} 
				} 
			}
			
			//<< erp data 처리 >>
			String a="erp_date";
			String b="erp_user";
			String c="erp_stext";
			String d="erp_authority";
			String e="erp_division";
			//ERP 데이터가 있다면,
			//데이터를 삭제하고 다시 생성하는 방식으로 진행 -.
			//erp 데이터 미리 삭제
			an = rms.edelete(id, bbsDeadline);
			if(an == -1){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('erp 처리에 문제가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
				script.println("history.back();");
				script.println("</script>");
			} else {
				for(int i=0; i< trACnt; i++){
					//edate 처리
					if(request.getParameter(a+i).length() != 0) {	//데이터가 존재한다면, 모두 포함되어 있음!
						String edate=request.getParameter(a+i);
						String euser=request.getParameter(b+i);
						String etext=request.getParameter(c+i);
						String eau=request.getParameter(d+i);
						String ediv=request.getParameter(e+i);
						//erp 테이블에 저장
						int numelist = rms.write_erp(id, bbsDeadline, edate, euser, etext, eau, ediv);
						if(numelist == -1) { //데이터 저장 오류가 발생하면, 데이터 삭제
							PrintWriter script = response.getWriter();
							script.println("<script>");
							script.println("alert('(erp)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
							script.println("history.back();");
							script.println("</script>");
							an = -1;
						} 
					} 
				}
			}
			
			
			if(n != -1 && nn != -1 && llist.size() != 0) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('수정이 완료되었습니다.')");
				script.println("location.href='../bbsUpdateDelete.jsp'");
				script.println("</script>");
			} else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('수정이 완료되었습니다.')");
				script.println("alert('주간보고가 모두 제출되었습니다. \\n조회 페이지로 이동합니다.')");
				script.println("location.href='../bbs.jsp'");
				script.println("</script>");
			}
		}

	%>



</body>
</html>