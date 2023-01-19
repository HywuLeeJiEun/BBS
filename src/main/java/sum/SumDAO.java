package sum;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import Sumad.Sumad;


public class SumDAO {
	private Connection conn;
	private ResultSet rs;
	
	//기본 생성자
	public SumDAO() {
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

	
	//summary sum_id를 통해 내용 가져오기 
	public ArrayList<Sum> getlistSum(String bbsDeadline, String pl){
		String sql =  "select * from summary where bbsDeadline=? and pluser=?";
				ArrayList<Sum> list = new ArrayList<Sum>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline);
			pstmt.setString(2, pl);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Sum sum = new Sum();
				sum.setUserID(rs.getString(1)); 
				sum.setBbsDeadline(rs.getString(2)); 
				sum.setPluser(rs.getString(3)); 
				sum.setBbsContent(rs.getString(4)); 
				sum.setBbsEnd(rs.getString(5)); 
				sum.setProgress(rs.getString(6)); 
				sum.setState(rs.getString(7)); 
				sum.setNote(rs.getString(8)); 
				sum.setBbsNContent(rs.getString(9)); 
				sum.setBbsNTarget(rs.getString(10)); 
				sum.setNnote(rs.getString(11)); 
				sum.setSign(rs.getString(12)); 
				sum.setSummaryDate(rs.getString(13)); 
				sum.setSummaryUpdate(rs.getString(14)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//summary sum_id를 통해 내용 가져오기 (전체목록)
	public ArrayList<Sum> getlistSumAll(String pl, int pageNumber){
		String sql =  "select * from summary where pluser=? order by bbsDeadline desc limit ?,10";
				ArrayList<Sum> list = new ArrayList<Sum>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, pl);
			pstmt.setInt(2, (pageNumber-1)  * 10);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Sum sum = new Sum();
				sum.setUserID(rs.getString(1)); 
				sum.setBbsDeadline(rs.getString(2)); 
				sum.setPluser(rs.getString(3)); 
				sum.setBbsContent(rs.getString(4)); 
				sum.setBbsEnd(rs.getString(5)); 
				sum.setProgress(rs.getString(6)); 
				sum.setState(rs.getString(7)); 
				sum.setNote(rs.getString(8)); 
				sum.setBbsNContent(rs.getString(9)); 
				sum.setBbsNTarget(rs.getString(10)); 
				sum.setNnote(rs.getString(11)); 
				sum.setSign(rs.getString(12)); 
				sum.setSummaryDate(rs.getString(13)); 
				sum.setSummaryUpdate(rs.getString(14)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	
	//summary sum_id를 통해 내용 가져오기 (전체목록)
	public ArrayList<Sum> getlistSumSign(String pl){
		String sql =  "select * from summary where sign='미승인' and pluser=? order by bbsDeadline desc";
				ArrayList<Sum> list = new ArrayList<Sum>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, pl);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Sum sum = new Sum();
				sum.setUserID(rs.getString(1)); 
				sum.setBbsDeadline(rs.getString(2)); 
				sum.setPluser(rs.getString(3)); 
				sum.setBbsContent(rs.getString(4)); 
				sum.setBbsEnd(rs.getString(5)); 
				sum.setProgress(rs.getString(6)); 
				sum.setState(rs.getString(7)); 
				sum.setNote(rs.getString(8)); 
				sum.setBbsNContent(rs.getString(9)); 
				sum.setBbsNTarget(rs.getString(10)); 
				sum.setNnote(rs.getString(11)); 
				sum.setSign(rs.getString(12)); 
				sum.setSummaryDate(rs.getString(13)); 
				sum.setSummaryUpdate(rs.getString(14)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//bbsRkAction -> summary 테이블에 데이터 삽입
	public int SummaryWrite(String userID, String bbsDeadline, String pluser, String bbsContent, String bbsEnd, String progress, String state, String note, String bbsNContent, String bbsNTarget, String nnote, java.sql.Timestamp summaryDate, String summaryUpdate ) {
		String sql = "insert into summary values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		String sign = "미승인";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userID); //userID
			pstmt.setString(2, bbsDeadline); //bbsDeadline
			pstmt.setString(3, pluser); //pluser
			pstmt.setString(4, bbsContent); //bbsContent
			pstmt.setString(5, bbsEnd); //bbsEnd
			pstmt.setString(6, progress); //progress
			pstmt.setString(7, state); //state
			pstmt.setString(8, note); //note
			pstmt.setString(9, bbsNContent); //bbsNContent
			pstmt.setString(10, bbsNTarget); //bbsNTarget
			pstmt.setString(11, nnote); //nnote
			pstmt.setString(12, sign); //승인 표시
			pstmt.setTimestamp(13, summaryDate);
			pstmt.setString(14, summaryUpdate);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	// summary의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
	public int sumSign(String bbsDeadline) {
		String sql = " update summary set sign='마감' where bbsDeadline=?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}
	
	
	//요약본(summary) 삭제 메소드
	public int deleteSum(String bbsDeadline, String pluser) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from summary where bbsDeadline = ? and pluser = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline);
			pstmt.setString(2, pluser);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	//게시글 수정 메소드
	public int updateSum(String bbsDeadline, String pluser, String bbsContent, String bbsEnd, String progress, String state, String note, String bbsNContent, String bbsNTarget, String nnote, String sign, java.sql.Timestamp summaryDate, String summaryUpdate) {
		String sql = "update summary set bbsContent = ?,  bbsEnd = ?, progress = ?, state = ?, note = ?, bbsNContent= ? ,bbsNTarget = ?, nnote = ?, sign = ?, summaryDate = ?, summaryUpdate = ? where bbsDeadline =? and pluser= ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsContent);
			pstmt.setString(2, bbsEnd);
			pstmt.setString(3, progress);
			pstmt.setString(4, state);
			pstmt.setString(5, note);
			pstmt.setString(6, bbsNContent);
			pstmt.setString(7, bbsNTarget);
			pstmt.setString(8, nnote);
			pstmt.setString(9, sign);
			pstmt.setTimestamp(10, summaryDate);
			pstmt.setString(11, summaryUpdate);
			pstmt.setString(12, bbsDeadline);
			pstmt.setString(13, pluser);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	// summary의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
	public int sumSignOn(String bbsDeadline, String pluser) {
		String sql = " update summary set sign='승인' where bbsDeadline=? and pluser=?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline); 
			pstmt.setString(2, pluser); 
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}
}
