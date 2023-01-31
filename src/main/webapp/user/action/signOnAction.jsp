<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
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
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		
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
			String rms_dl = request.getParameter("rms_dl");
			String workSet = request.getParameter("workset");
			String name = userDAO.getName(id);
			
			//데이터를 승인으로 변경함! 
			int num = rms.updateSign(id, "승인", rms_dl);
			
			//미승인된 rms를 찾아옴.		
			ArrayList<rmsrept> list = rms.getrmsSign(id, 1);
			
			if(num == -1) { //오류
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
				script.println("location.href='../bbs.jsp'");
				script.println("</script>");
			} else {
				if(list.size() == 0) {
					//rms에 통합 저장 진행
					//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
					int rmsData = rms.getPptxRms(rms_dl, id);
					if(rmsData == 0) { //작성된 기록이 없다!
						//2. rms 데이터 생성
							//데이터 불러오기 (this, next)
							//금주
							ArrayList<rmsrept> rms_this = rms.getRmsOne(rms_dl, id,"T");
							//차주
							ArrayList<rmsrept> rms_next = rms.getRmsOne(rms_dl, id,"N");
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
								int anum = rms_this.get(j).getRms_con().split("\r\n").length-1;
								if(j < rms_this.size()-1) {
									 bbsContent += rms_this.get(j).getRms_con() + "\r\n";
									 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/") + "\r\n";
									 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
									 	bbsTarget += "[보류]" + "\r\n";
									 } else {
										 if(rms_this.get(j).getRms_tar().length() > 5) {
										 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/") + "\r\n";
										 }else {
											 bbsTarget += "[보류]" + "\r\n";
										 }
									 }
									 bbsEnd += rms_this.get(j).getRms_end() + "\r\n";
									
									 for(int k=0;k < anum; k ++) {
										 bbsStart +="\r\n";
										 bbsTarget +="\r\n";
										 bbsEnd +="\r\n";
									 }
								} else {
									bbsContent += rms_this.get(j).getRms_con();
									 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/");
									 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
										 bbsTarget += "[보류]";
									 } else {
										 if(rms_this.get(j).getRms_tar().length() > 5) {
										 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/");
										 } else { 
											 bbsTarget += "[보류]";
										 }
									 }
									 bbsEnd += rms_this.get(j).getRms_end();
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
								int nnum = rms_next.get(j).getRms_con().split("\r\n").length-1;
								if(j < rms_next.size()-1) {
									 bbsNContent += rms_next.get(j).getRms_con() + "\r\n";
									 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/") + "\r\n";
									 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
										 bbsNTarget += "[보류]" + "\r\n";
									 } else {
										 if(rms_next.get(j).getRms_tar().length() > 5) {
										 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/") + "\r\n";
										 } else {
											 bbsNTarget += "[보류]" + "\r\n";
										 }
									 }
									 for (int h=0; h < nnum; h++) {
										 bbsNStart += "\r\n";
										 bbsNTarget += "\r\n";
									 }
								} else {
									 bbsNContent += rms_next.get(j).getRms_con();
									 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/");
									 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
										 bbsNTarget += "[보류]";
									 } else {
										 if(rms_next.get(j).getRms_tar().length() > 5){
										 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/");
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
					int rmsTSuc = rms.PptxRmsWrite(rms_this.get(0).getUser_id(), rms_this.get(0).getRms_dl(), rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
					int rmsNSuc = rms.PptxRmsWrite(rms_next.get(0).getUser_id(), rms_next.get(0).getRms_dl(), rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
					//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
					
						if(rmsTSuc == -1 || rmsNSuc == -1) {
							PrintWriter script = response.getWriter();
							script.println("<script>");
							script.println("alert('최종 저장에 문제가 발생하였습니다. 관리자에게 문의 바랍니다.')");
							script.println("location.href='../login.jsp'");
							script.println("</script>");
						}
					}
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