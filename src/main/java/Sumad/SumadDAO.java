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
		public ArrayList<Sumad> getlistSumAll(){
			String sql =  "select * from summary_admin where sign='승인' or sign='마감' order by bbsDeadline desc";
					ArrayList<Sumad> list = new ArrayList<Sumad>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Sumad sum = new Sumad();
					sum.setSumad_id(rs.getString(1)); 
					sum.setE_content(rs.getString(2)); 
					sum.setE_end(rs.getString(3)); 
					sum.setE_progress(rs.getString(4)); 
					sum.setE_state(rs.getString(5)); 
					sum.setE_note(rs.getString(6)); 
					sum.setE_ncontent(rs.getString(7)); 
					sum.setE_ntarget(rs.getString(8)); 
					sum.setE_nnote(rs.getString(9));
					sum.setW_content(rs.getString(10)); 
					sum.setW_end(rs.getString(11)); 
					sum.setW_progress(rs.getString(12)); 
					sum.setW_state(rs.getString(13)); 
					sum.setW_note(rs.getString(14)); 
					sum.setW_ncontent(rs.getString(15)); 
					sum.setW_ntarget(rs.getString(16)); 
					sum.setW_nnote(rs.getString(17));
					sum.setSign(rs.getString(18));
					sum.setBbsDeadline(rs.getString(19));
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
				public ArrayList<Sumad> getlistSumAlllist(){
					String sql =  "select * from summary_admin order by bbsDeadline desc";
							ArrayList<Sumad> list = new ArrayList<Sumad>();
					try {
						PreparedStatement pstmt = conn.prepareStatement(sql);
						rs = pstmt.executeQuery();
						while(rs.next()) {
							Sumad sum = new Sumad();
							sum.setSumad_id(rs.getString(1)); 
							sum.setE_content(rs.getString(2)); 
							sum.setE_end(rs.getString(3)); 
							sum.setE_progress(rs.getString(4)); 
							sum.setE_state(rs.getString(5)); 
							sum.setE_note(rs.getString(6)); 
							sum.setE_ncontent(rs.getString(7)); 
							sum.setE_ntarget(rs.getString(8)); 
							sum.setE_nnote(rs.getString(9));
							sum.setW_content(rs.getString(10)); 
							sum.setW_end(rs.getString(11)); 
							sum.setW_progress(rs.getString(12)); 
							sum.setW_state(rs.getString(13)); 
							sum.setW_note(rs.getString(14)); 
							sum.setW_ncontent(rs.getString(15)); 
							sum.setW_ntarget(rs.getString(16)); 
							sum.setW_nnote(rs.getString(17));
							sum.setSign(rs.getString(18));
							sum.setBbsDeadline(rs.getString(19));
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
				public ArrayList<Sumad> getlistSumSign(){
					String sql =  "select * from summary_admin where sign='미승인' order by bbsDeadline desc";
							ArrayList<Sumad> list = new ArrayList<Sumad>();
					try {
						PreparedStatement pstmt = conn.prepareStatement(sql);
						rs = pstmt.executeQuery();
						while(rs.next()) {
							Sumad sum = new Sumad();
							sum.setSumad_id(rs.getString(1)); 
							sum.setE_content(rs.getString(2)); 
							sum.setE_end(rs.getString(3)); 
							sum.setE_progress(rs.getString(4)); 
							sum.setE_state(rs.getString(5)); 
							sum.setE_note(rs.getString(6)); 
							sum.setE_ncontent(rs.getString(7)); 
							sum.setE_ntarget(rs.getString(8)); 
							sum.setE_nnote(rs.getString(9));
							sum.setW_content(rs.getString(10)); 
							sum.setW_end(rs.getString(11)); 
							sum.setW_progress(rs.getString(12)); 
							sum.setW_state(rs.getString(13)); 
							sum.setW_note(rs.getString(14)); 
							sum.setW_ncontent(rs.getString(15)); 
							sum.setW_ntarget(rs.getString(16)); 
							sum.setW_nnote(rs.getString(17));
							sum.setSign(rs.getString(18));
							sum.setBbsDeadline(rs.getString(19));
							sum.setSumadDate(rs.getString(20));
							sum.setSumadUpdate(rs.getString(21));
							list.add(sum);
						}
					}catch (Exception e) {
						e.printStackTrace();
					}
					return list;
				}
}
