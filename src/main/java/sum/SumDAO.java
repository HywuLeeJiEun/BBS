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
			String dbURL = "jdbc:mariadb://localhost:3306/bbs";
			String dbID = "root";
			String dbPassword = "7471350";
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}

	
	//summary sum_id를 통해 내용 가져오기 (전체목록)
	public ArrayList<Sum> getlistSumAll(String pl){
		String sql =  "select * from summary where pl=? order by bbsDeadline desc";
				ArrayList<Sum> list = new ArrayList<Sum>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, pl);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Sum sum = new Sum();
				sum.setSum_id(rs.getString(1)); 
				sum.setPl(rs.getString(2)); 
				sum.setBbsContent(rs.getString(3)); 
				sum.setBbsEnd(rs.getString(4)); 
				sum.setProgress(rs.getString(5)); 
				sum.setState(rs.getString(6)); 
				sum.setNote(rs.getString(7)); 
				sum.setBbsNContent(rs.getString(8)); 
				sum.setBbsNTarget(rs.getString(9)); 
				sum.setBbsDeadline(rs.getString(10)); 
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
		String sql =  "select * from summary where sign='미승인' and pl=? order by bbsDeadline desc";
				ArrayList<Sum> list = new ArrayList<Sum>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, pl);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Sum sum = new Sum();
				sum.setSum_id(rs.getString(1)); 
				sum.setPl(rs.getString(2));
				sum.setBbsContent(rs.getString(3));
				sum.setBbsEnd(rs.getString(4));
				sum.setProgress(rs.getString(5));
				sum.setState(rs.getString(6));
				sum.setNote(rs.getString(7));
				sum.setBbsNContent(rs.getString(8));
				sum.setBbsNTarget(rs.getString(9));
				sum.setBbsDeadline(rs.getString(10));
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
}
