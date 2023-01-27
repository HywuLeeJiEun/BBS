<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsrept.rmsedps"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="user.UserDAO"%>
<%@page import="rms.erp"%>
<%@page import="user.User"%>
<%@page import="rms.RmsDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.OutputStream"%>
<%@page import="net.sf.jasperreports.swing.JRViewer"%>
<%@page import="javax.swing.JFrame"%>
<%@page import="net.sf.jasperreports.export.SimplePptxReportConfiguration"%>
<%@page import="net.sf.jasperreports.export.SimplePptxExporterConfiguration"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="net.sf.jasperreports.export.SimpleOutputStreamExporterOutput"%>
<%@page import="net.sf.jasperreports.export.SimpleExporterInput"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page import="javax.management.remote.JMXServerErrorException"%>
<%@page import="java.io.File"%>
<%@page import="net.sf.jasperreports.engine.export.ooxml.JRPptxExporter"%>
<%@page import="java.sql.SQLException"%>
<%@page import="net.sf.jasperreports.engine.JasperExportManager"%>
<%@page import="net.sf.jasperreports.engine.JasperFillManager"%>
<%@page import="net.sf.jasperreports.engine.JasperPrint"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import= "net.sf.jasperreports.engine.DefaultJasperReportsContext" %>
<%@page import= "net.sf.jasperreports.*" %>
<%@page import="net.sf.jasperreports.engine.*"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
</head>
<body>

<%
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)

	// RMSSUMM에 해당하는 rms_dl
	String rms_dl = request.getParameter("rms_dl");
	//e_state, w_state => 색상표
	//String e_color = request.getParameter("ecolor");
	//String w_color = request.getParameter("wcolor");
	String e_state = request.getParameter("ecolor");//"#ff0000";
	String w_state = request.getParameter("wcolor");//"#ffff00";
	
	// erp_bbs가 있다면, 데이터를 저장함!
	//erp 데이터가 있는지 확인
	ArrayList<rmsedps> erp_list = rms.geterp(rms_dl);
	
	//summary 데이터를 불러옴.
	//rms_dl로 검색하여 해당 데이터를 가져옴.
	//ERP
		//금주
	ArrayList<rmssumm> etlist = sumDAO.getSumDiv("ERP", rms_dl, "T");
		//차주
	ArrayList<rmssumm> enlist = sumDAO.getSumDiv("ERP", rms_dl, "N");
	
	//WEB
		//금주
	ArrayList<rmssumm> wtlist = sumDAO.getSumDiv("WEB", rms_dl, "T");
		//차주
	ArrayList<rmssumm> wnlist = sumDAO.getSumDiv("WEB", rms_dl, "N");
	
	
	String templatePath = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\SummaryAD.jrxml";
	Connection conn = null;
	
	try {
	 // (1)템플레이트 XML 컴파일 (여기가 안됨!) => 이게 결국 .jasper를 불러오기 위함!! (jrxml을 컴파일 한 것이 jasper)
	 //JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 
	
	 // (2)파라메타 생성	  
	 String logo = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 Map<String,Object> paramMap = new HashMap<String,Object>();
	
	 paramMap.put("deadLine",rms_dl);	  
	 paramMap.put("logo",logo);
	 paramMap.put("e_state",e_state);
	 paramMap.put("w_state",w_state);
	 
	 //erp 데이터를 저장함
	 String a = "erp_date";
	 String b = "erp_user";
	 String c = "erp_stext";
	 String d = "erp_authority";
	 String e = "erp_division";
	 
	 if(erp_list.size() != 0) {
		 for(int i=0; i < erp_list.size(); i++) {
			 paramMap.put(a+i,erp_list.get(i).getErp_date());	  
			 paramMap.put(b+i,erp_list.get(i).getErp_user());	  
			 paramMap.put(c+i,erp_list.get(i).getErp_text());	  
			 paramMap.put(d+i,erp_list.get(i).getErp_anum());  
			 paramMap.put(e+i,erp_list.get(i).getErp_div());	  
		 }
	 } else { //만약, erp 데이터가 없다면!
		 paramMap.put(a+0," ");	  
		 paramMap.put(b+0," ");	  
		 paramMap.put(c+0," ");	  
		 paramMap.put(d+0," ");  
		 paramMap.put(e+0," ");	 
		 paramMap.put(a+1," ");	  
		 paramMap.put(b+1," ");	  
		 paramMap.put(c+1," ");	  
		 paramMap.put(d+1," ");  
		 paramMap.put(e+1," ");	
	 }
	 
	 //sum - erp데이터 저장
	 paramMap.put("etsum_con",etlist.get(0).getSum_con());
	 paramMap.put("etsum_enta",etlist.get(0).getSum_enta());
	 paramMap.put("etsum_pro",etlist.get(0).getSum_pro());
	 paramMap.put("etsum_note",etlist.get(0).getSum_note());
	 
	 paramMap.put("ensum_con",enlist.get(0).getSum_con());
	 paramMap.put("ensum_enta",enlist.get(0).getSum_enta());
	 paramMap.put("ensum_note",enlist.get(0).getSum_note());
	 
	 //sum - web데이터 저장
	 paramMap.put("wtsum_con",wtlist.get(0).getSum_con());
	 paramMap.put("wtsum_enta",wtlist.get(0).getSum_enta());
	 paramMap.put("wtsum_pro",wtlist.get(0).getSum_pro());
	 paramMap.put("wtsum_note",wtlist.get(0).getSum_note());
	 
	 paramMap.put("wnsum_con",wnlist.get(0).getSum_con());
	 paramMap.put("wnsum_enta",wnlist.get(0).getSum_enta());
	 paramMap.put("wnsum_note",wnlist.get(0).getSum_note());
	 
	 
	 // (3)데이타소스 생성
	 Class.forName("org.mariadb.jdbc.Driver");
	 conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/rms", "root","7471350");
	
	 // (4)데이타의 동적 바인드
	 JasperPrint print = JasperFillManager.fillReport(jasperReport, paramMap, conn);
	
	 // (5) Ppt로 출력
	 //JasperExportManager.exportReportToPdfFile(print, destPath);	
	
	 JRPptxExporter pptxExporter = new JRPptxExporter();
	 pptxExporter.setExporterInput(new SimpleExporterInput(print));
	 //pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("D:\\git\\BBS\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\주간보고_sample.pptx")));
	 pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx")));
	 
	 // frame으로 출력
	 /* JFrame frame = new JFrame("Report");
	 frame.getContentPane().add(new JRViewer(print));
	 frame.pack();
	 frame.setVisible(true); */
	 
	 
	 pptxExporter.exportReport();
     
	} catch (Exception ex) {
	     ex.printStackTrace();
	
	}
	
	String fileName = "요약본_sample.pptx";
	String downLoadFile = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\" + fileName;
	
	File file = new File(downLoadFile);
	FileInputStream in = new FileInputStream(downLoadFile);
	
	fileName = new String(fileName.getBytes("utf-8"), "8859_1");
	
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
	
	out.clear();
	out = pageContext.pushBody();
	
	OutputStream os = response.getOutputStream();
	
	int length;
	byte[] b = new byte[(int)file.length()];
	
	while ((length = in.read(b)) >0) {
		os.write(b,0,length);
	}
	
	os.flush();   
%>



</body>
</html>