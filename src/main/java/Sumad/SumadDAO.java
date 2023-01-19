package Sumad;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;


public class SumadDAO {
	private Connection conn;
	private ResultSet rs;
	
	//기본 생성자
	public SumadDAO() {
		try {
			String dbURL = "jdbc:mariadb://localhost:3306/rms";
			String dbID = "root";
			String dbPassword = "7471350";
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	//summary sum_id를 통해 내용 가져오기 (전체목록)
		public ArrayList<Sumad> getlistSumAll(){
			String sql =  "select * from summary_admin where sign='승인' or sign='마감' order by bbsDeadline desc";
					ArrayList<Sumad> list = new ArrayList<Sumad>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Sumad sum = new Sumad();
					sum.setUserID(rs.getString(1)); 
					sum.setBbsDeadline(rs.getString(2));
					sum.setE_content(rs.getString(3)); 
					sum.setE_end(rs.getString(4)); 
					sum.setE_progress(rs.getString(5)); 
					sum.setE_state(rs.getString(6)); 
					sum.setE_note(rs.getString(7)); 
					sum.setE_ncontent(rs.getString(8)); 
					sum.setE_ntarget(rs.getString(9)); 
					sum.setE_nnote(rs.getString(10));
					sum.setW_content(rs.getString(11)); 
					sum.setW_end(rs.getString(12)); 
					sum.setW_progress(rs.getString(13)); 
					sum.setW_state(rs.getString(14)); 
					sum.setW_note(rs.getString(15)); 
					sum.setW_ncontent(rs.getString(16)); 
					sum.setW_ntarget(rs.getString(17)); 
					sum.setW_nnote(rs.getString(18));
					sum.setSign(rs.getString(19));
					sum.setSumadDate(rs.getString(20));
					sum.setSumadUpdate(rs.getString(21));
					list.add(sum);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
		
		//summary sum_id를 통해 내용 가져오기 (전체목록)
		public ArrayList<Sumad> getlistSumAlllist(int pageNumber){
			String sql =  "select * from summary_admin order by bbsDeadline desc limit ?,10";
					ArrayList<Sumad> list = new ArrayList<Sumad>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				 pstmt.setInt(1, (pageNumber-1) * 10);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Sumad sum = new Sumad();
					sum.setUserID(rs.getString(1)); 
					sum.setBbsDeadline(rs.getString(2));
					sum.setE_content(rs.getString(3)); 
					sum.setE_end(rs.getString(4)); 
					sum.setE_progress(rs.getString(5)); 
					sum.setE_state(rs.getString(6)); 
					sum.setE_note(rs.getString(7)); 
					sum.setE_ncontent(rs.getString(8)); 
					sum.setE_ntarget(rs.getString(9)); 
					sum.setE_nnote(rs.getString(10));
					sum.setW_content(rs.getString(11)); 
					sum.setW_end(rs.getString(12)); 
					sum.setW_progress(rs.getString(13)); 
					sum.setW_state(rs.getString(14)); 
					sum.setW_note(rs.getString(15)); 
					sum.setW_ncontent(rs.getString(16)); 
					sum.setW_ntarget(rs.getString(17)); 
					sum.setW_nnote(rs.getString(18));
					sum.setSign(rs.getString(19));			
					sum.setSumadDate(rs.getString(20));
					sum.setSumadUpdate(rs.getString(21));
					list.add(sum);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
				
				
		//summary 내용 가져오기 (전체목록)
		public ArrayList<Sumad> getlistSumSign(){
			String sql =  "select * from summary_admin where sign='미승인' order by bbsDeadline desc";
					ArrayList<Sumad> list = new ArrayList<Sumad>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Sumad sum = new Sumad();
					sum.setUserID(rs.getString(1)); 
					sum.setBbsDeadline(rs.getString(2));
					sum.setE_content(rs.getString(3)); 
					sum.setE_end(rs.getString(4)); 
					sum.setE_progress(rs.getString(5)); 
					sum.setE_state(rs.getString(6)); 
					sum.setE_note(rs.getString(7)); 
					sum.setE_ncontent(rs.getString(8)); 
					sum.setE_ntarget(rs.getString(9)); 
					sum.setE_nnote(rs.getString(10));
					sum.setW_content(rs.getString(11)); 
					sum.setW_end(rs.getString(12)); 
					sum.setW_progress(rs.getString(13)); 
					sum.setW_state(rs.getString(14)); 
					sum.setW_note(rs.getString(15)); 
					sum.setW_ncontent(rs.getString(16)); 
					sum.setW_ntarget(rs.getString(17)); 
					sum.setW_nnote(rs.getString(18));
					sum.setSign(rs.getString(19));
					sum.setSumadDate(rs.getString(20));
					sum.setSumadUpdate(rs.getString(21));
					list.add(sum);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
		
		//summary_admin sumad_id를 통해 내용 가져오기 
		public ArrayList<Sumad> getlistSumad(String bbsDeadline){
			String sql =  "select * from summary_admin where bbsDeadline=? ";
					ArrayList<Sumad> list = new ArrayList<Sumad>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsDeadline);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Sumad sum = new Sumad();
					sum.setUserID(rs.getString(1)); 
					sum.setBbsDeadline(rs.getString(2));
					sum.setE_content(rs.getString(3)); 
					sum.setE_end(rs.getString(4)); 
					sum.setE_progress(rs.getString(5)); 
					sum.setE_state(rs.getString(6)); 
					sum.setE_note(rs.getString(7)); 
					sum.setE_ncontent(rs.getString(8)); 
					sum.setE_ntarget(rs.getString(9)); 
					sum.setE_nnote(rs.getString(10));
					sum.setW_content(rs.getString(11)); 
					sum.setW_end(rs.getString(12)); 
					sum.setW_progress(rs.getString(13)); 
					sum.setW_state(rs.getString(14)); 
					sum.setW_note(rs.getString(15)); 
					sum.setW_ncontent(rs.getString(16)); 
					sum.setW_ntarget(rs.getString(17)); 
					sum.setW_nnote(rs.getString(18));
					sum.setSign(rs.getString(19));
					sum.setSumadDate(rs.getString(20));
					sum.setSumadUpdate(rs.getString(21));
					list.add(sum);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
		
		//bbsRkAction -> summary 테이블에 데이터 삽입
		public int SummaryAdminWrite(String userID, String bbsDeadline, String e_content, String e_end, String e_progress, String e_state, String e_note, String e_ncontent, String e_ntarget, String e_nnote, String w_content, String w_end, String w_progress, String w_state, String w_note, String w_ncontent, String w_ntarget, String w_nnote, String sign, java.sql.Timestamp sumadDate, String sumadUpdate) {
			String sql = "insert into summary_admin values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, userID); 
				pstmt.setString(2, bbsDeadline);
				pstmt.setString(3, e_content); 
				pstmt.setString(4, e_end);
				pstmt.setString(5, e_progress); 
				pstmt.setString(6, e_state); 
				pstmt.setString(7, e_note); 
				pstmt.setString(8, e_ncontent); 
				pstmt.setString(9, e_ntarget);
				pstmt.setString(10, e_nnote); 
				pstmt.setString(11, w_content); 
				pstmt.setString(12, w_end); 
				pstmt.setString(13, w_progress);
				pstmt.setString(14, w_state);
				pstmt.setString(15, w_note);
				pstmt.setString(16, w_ncontent);
				pstmt.setString(17, w_ntarget);
				pstmt.setString(18, w_nnote);
				pstmt.setString(19, sign);
				pstmt.setTimestamp(20, sumadDate);
				pstmt.setString(21, sumadUpdate);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		
		//bbsRkAction -> summary 테이블에 데이터 삽입
		public int SummaryAdminUpdate(String bbsDeadline, String e_content, String e_end, String e_progress, String e_state,
				String e_note, String e_ncontent, String e_ntarget, String e_nnote, String w_content, String w_end, String w_progress,
				String w_state, String w_note, String w_ncontent, String w_ntarget, String w_nnote, String sign, 
				java.sql.Timestamp sumadDate, String sumadUpdate) {
			String sql = "update summary_admin set e_content=?, e_end=?, e_progress=?, e_state=?, e_note=?, e_ncontent=?, e_ntarget=?, e_nnote=?, w_content=?, w_end=?, w_progress=?, w_state=?, w_note=?, w_ncontent=?, w_ntarget=?, w_nnote=?, sign=?, sumadDate=?, sumadUpdate=? where bbsDeadline = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				//pstmt.setInt(1, getNextSumAdmin()); 
				pstmt.setString(1, e_content); 
				pstmt.setString(2, e_end);
				pstmt.setString(3, e_progress); 
				pstmt.setString(4, e_state); 
				pstmt.setString(5, e_note); 
				pstmt.setString(6, e_ncontent); 
				pstmt.setString(7, e_ntarget);
				pstmt.setString(8, e_nnote); 
				pstmt.setString(9, w_content); 
				pstmt.setString(10, w_end); 
				pstmt.setString(11, w_progress);
				pstmt.setString(12, w_state);
				pstmt.setString(13, w_note);
				pstmt.setString(14, w_ncontent);
				pstmt.setString(15, w_ntarget);
				pstmt.setString(16, w_nnote);
				pstmt.setString(17, sign);
				pstmt.setTimestamp(18, sumadDate); //sumadDate
				pstmt.setString(19, sumadUpdate);
				pstmt.setString(20, bbsDeadline);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		
		// summary_admin Sign을 마감으로 변경함! ((제출 날짜가 지남!)) // summary_admin
		public int sumadSign(String bbsDeadline) {
			String sql = " update summary_admin set sign='마감' where bbsDeadline=?";
			 try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsDeadline); 
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			 return -1;
		}
		
		
		// Sign을 마감으로 변경함! ((제출 날짜가 지남!)) // summary_admin
			public int sumadSignOn(String bbsDeadline) {
				String sql = " update summary_admin set sign='승인' where bbsDeadline=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsDeadline); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
}
