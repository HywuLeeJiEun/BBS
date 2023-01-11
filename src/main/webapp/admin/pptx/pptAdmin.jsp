<%@page import="java.util.ArrayList"%>
<%@page import="bbs.BbsDAO"%>
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
<title>Insert title here</title>
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
</head>
<body>

<%
	// sumad_id에 해당하는 bbsDeadline
	String bbsDeadline = request.getParameter("bbsDeadline");
	//e_state, w_state => 색상표
	//String e_color = request.getParameter("ecolor");
	//String w_color = request.getParameter("wcolor");
	String e_state = request.getParameter("ecolor");//"#ff0000";
	String w_state = request.getParameter("wcolor");//"#ffff00";
	
	// erp_bbs가 있다면, 데이터를 저장함!
	BbsDAO bbsDAO = new BbsDAO();
	ArrayList<String> list = bbsDAO.geterpid(bbsDeadline);
	//데이터가 여러개 있다면 쪼개어 저장함

	
	String templatePath = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\SummaryAD.jrxml";
	//String templatePath = "D:\\git\\BBS\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\sample_bbs.jrxml";
	//String templatePath = "D:\\workspace\\sample\\sample_bbs.jrxml";
	//String templatePath2 = "D:\\workspace\\sample\\sample_bbs.jasper";
	//String templatePath = "D:\\workspace\\BBS_test_backup\\src\\main\\webapp\\WEB-INF\\reports\\sample_bbs.jrxml";
	// 출력할 PDF 파일 경로
	//String destPath = "C:\\1.pptx";
	
	Connection conn = null;
	
	try {
	 // (1)템플레이트 XML 컴파일 (여기가 안됨!) => 이게 결국 .jasper를 불러오기 위함!! (jrxml을 컴파일 한 것이 jasper)
	 //JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 
	
	 // (2)파라메타 생성	  
	 String logo = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 Map<String,Object> paramMap = new HashMap<String,Object>();
	
	 paramMap.put("deadLine",bbsDeadline);	  
	 paramMap.put("logo",logo);
	 paramMap.put("e_state",e_state);
	 paramMap.put("w_state",w_state);
	 
	 //erp 데이터를 저장함
	 String a = "erp_date";
	 String b = "erp_user";
	 String c = "erp_stext";
	 String d = "erp_authority";
	 String e = "erp_division";
	 
	 if(list.size() != 0) {
			String[] erp_date = list.get(1).split("\r\n");
			String[] erp_user = list.get(2).split("\r\n");
			String[] erp_stext = list.get(3).split("\r\n");
			String[] erp_authority = list.get(4).split("\r\n");
			String[] erp_division = list.get(5).split("\r\n");
		 
		 if (erp_date.length == 1) { //만약, 데이터가 1개라면
			 paramMap.put(a+0,erp_date[0]);	  
			 paramMap.put(b+0,erp_user[0]);	  
			 paramMap.put(c+0,erp_stext[0]);	  
			 paramMap.put(d+0,erp_authority[0]);  
			 paramMap.put(e+0,erp_division[0]);	 
			 paramMap.put(a+1," ");	  
			 paramMap.put(b+1," ");	  
			 paramMap.put(c+1," ");	  
			 paramMap.put(d+1," ");  
			 paramMap.put(e+1," ");	
		 } else {
			 for(int i=0; i < erp_date.length; i++) {
				 paramMap.put(a+i,erp_date[i]);	  
				 paramMap.put(b+i,erp_user[i]);	  
				 paramMap.put(c+i,erp_stext[i]);	  
				 paramMap.put(d+i,erp_authority[i]);  
				 paramMap.put(e+i,erp_division[i]);	  
			 }
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
	 
	 // (3)데이타소스 생성
	 Class.forName("org.mariadb.jdbc.Driver");
	 conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/bbs", "root","7471350");
	
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

<%= list.size() %>
</body>
</html>