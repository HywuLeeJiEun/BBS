<%@page import="rms.rms_this"%>
<%@page import="rms.rms_next"%>
<%@page import="rms.RmsDAO"%>
<%@page import="user.UserDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>

<% 
		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		UserDAO userDAO = new UserDAO();
		String id = null;
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
			String bbsDeadline = request.getParameter("bbsDeadline");
			String workSet = request.getParameter("workset");
			//String name = request.getParameter("name");
			String name = userDAO.getName(id);
			
			RmsDAO rms = new RmsDAO();
			int num = rms.lastSign(id, "승인", bbsDeadline);
			
			//rms에 통합 저장 진행
			//1. rms에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
			int rmsData = rms.getRms(bbsDeadline, id);
			if(rmsData == 0) { //작성된 기록이 없다!
				//2. rms 데이터 생성
					//데이터 불러오기 (this, next)
				ArrayList<rms_this> rms_this = rms.gettrms(bbsDeadline, id);
				ArrayList<rms_next> rms_next = rms.getlrms(bbsDeadline, id);
				
					//데이터 가공하기
					String bbsManager = workSet + name;
					String bbsContent = "";
					String bbsStart = "";
					String bbsTarget = "";
					String bbsEnd = "";
					String bbsNContent = "";
					String bbsNStart = "";
					String bbsNTarget = "";
					//금주 업무 (this)
					for(int j=0; j < rms_this.size(); j++) {
						//content, ncotent의 줄바꿈 개수만큼 추가함
						int anum = rms_this.get(j).getBbsContent().split("\r\n").length-1;
						if(j < rms_this.size()-1) {
							 bbsContent += rms_this.get(j).getBbsContent() + "\r\n";
							 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/") + "\r\n";
							 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
							 	bbsTarget += "[보류]" + "\r\n";
							 } else {
								 if(rms_this.get(j).getBbsTarget().length() > 5) {
								 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/") + "\r\n";
								 }else {
									 bbsTarget += "[보류]" + "\r\n";
								 }
							 }
							 bbsEnd += rms_this.get(j).getBbsEnd() + "\r\n";
							
							 for(int k=0;k < anum; k ++) {
								 bbsStart +="\r\n";
								 bbsTarget +="\r\n";
								 bbsEnd +="\r\n";
							 }
						} else {
							bbsContent += rms_this.get(j).getBbsContent();
							 bbsStart += rms_this.get(j).getBbsStart().substring(5).replace("-","/");
							 if(rms_this.get(j).getBbsTarget() == null || rms_this.get(j).getBbsTarget().isEmpty()) {
								 bbsTarget += "[보류]";
							 } else {
								 if(rms_this.get(j).getBbsTarget().length() > 5) {
								 bbsTarget += rms_this.get(j).getBbsTarget().substring(5).replace("-","/");
								 } else { 
									 bbsTarget += "[보류]";
								 }
							 }
							 bbsEnd += rms_this.get(j).getBbsEnd();
							 for(int k=0;k < anum; k ++) {
								 bbsStart +="\r\n";
								 bbsTarget +="\r\n";
								 bbsEnd +="\r\n";
							 }
						}
					}
					//차주 (next)
					for(int j=0; j < rms_next.size(); j++) {
						//content, ncotent의 줄바꿈 개수만큼 추가함
						int nnum = rms_next.get(j).getBbsNContent().split("\r\n").length-1;
						if(j < rms_next.size()-1) {
							 bbsNContent += rms_next.get(j).getBbsNContent() + "\r\n";
							 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/") + "\r\n";
							 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
								 bbsNTarget += "[보류]" + "\r\n";
							 } else {
								 if(rms_next.get(j).getBbsNTarget().length() > 5) {
								 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/") + "\r\n";
								 } else {
									 bbsNTarget += "[보류]" + "\r\n";
								 }
							 }
							 for (int h=0; h < nnum; h++) {
								 bbsNStart += "\r\n";
								 bbsNTarget += "\r\n";
							 }
						} else {
							 bbsNContent += rms_next.get(j).getBbsNContent();
							 bbsNStart += rms_next.get(j).getBbsNStart().substring(5).replace("-","/");
							 if(rms_next.get(j).getBbsNTarget() == null || rms_next.get(j).getBbsNTarget().isEmpty()) {
								 bbsNTarget += "[보류]";
							 } else {
								 if(rms_next.get(j).getBbsNTarget().length() > 5){
								 bbsNTarget += rms_next.get(j).getBbsNTarget().substring(5).replace("-","/");
								 }else {
									 bbsNTarget += "[보류]";
								 }
							 }
							 for (int h=0; h < nnum; h++) {
								 bbsNStart += "\r\n";
								 bbsNTarget += "\r\n";
							 }
						}
					}
			//3. 데이터 저장하기
			int rmsSuc = rms.rmswrite(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
			}
			
			//updatedelete에 목록이 있는지 확인
			//rms_last -> 목록 불러오기 (사용자)
			// [bbsDeadline, sign, pluser]
			ArrayList<rms_next> llist = rms.getlastSign(id,"미승인",1);
			
			if(num == -1) { //오류
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
				script.println("location.href='../bbs.jsp'");
				script.println("</script>");
			} else {
				if(llist.size() == 0) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('제출이 완료되었습니다.')");
					script.println("alert('주간보고가 모두 제출되었습니다. \\n조회 페이지로 이동합니다.')");
					script.println("location.href='../bbs.jsp'");
					script.println("</script>");
				} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('제출이 완료되었습니다.')");
					script.println("location.href='../bbsUpdateDelete.jsp'");
					script.println("</script>");
				}
				
			}
		}
%>



</body>
</html>