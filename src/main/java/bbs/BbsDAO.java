package bbs;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;




public class BbsDAO {

	private Connection conn;
	private ResultSet rs;
	
	//기본 생성자
	public BbsDAO() {
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

	
	
	/*********** 기능 구현(메소드 구현) 영역 ***********/
	
	//작성일자 메소드
	public String getDate() {
		String sql = "select now()";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	//작성일자(시간) 메소드
		public java.sql.Timestamp getDateNow() {
			String sql = "select now()";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getTimestamp(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return null; //데이터베이스 오류
		}
	
	
	//작성자이름 메소드
	public String getName(String id) {
		String sql = "select u.name from user u, bbs b where u.id = "
				+ "b.userID and u.id= ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	//작성자이름 메소드 (현재 로그인 유저 이름)
		public String name(String id) {
			String sql = "select name from user where id=?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getString(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return ""; //데이터베이스 오류
		}
	
	// ********* 금주 업무 실적 관련 **********
	public String getContent(String id, String bbsTitle) {
		String sql = "select b.bbsContent from bbs b Inner join user u on b.userID = u.id and  u.id = ? where b.bbsTitle = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			pstmt.setString(2, bbsTitle);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}

	
	
	//게시글 번호 부여 메소드
	public int getNext() {
		//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
		String sql = "select bbsID from bbs order by bbsID desc";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getInt(1) + 1;
			}
			return 1; //첫 번째 게시물인 경우
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	//게시글 번호 부여 메소드 (Summary)
		public int getNextSum() {
			//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
			String sql = "select sum_id from summary order by sum_id desc";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1) + 1;
				}
				return 1; //첫 번째 게시물인 경우
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		//게시글 번호 부여 메소드 (erp_id)
				public int getNextErp() {
					//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
					String sql = "select erp_id from erp_bbs order by erp_id desc";
					try {
						PreparedStatement pstmt = conn.prepareStatement(sql);
						rs = pstmt.executeQuery();
						if(rs.next()) {
							return rs.getInt(1) + 1;
						}
						return 1; //첫 번째 게시물인 경우
					}catch (Exception e) {
						e.printStackTrace();
					}
					return -1; //데이터베이스 오류
				}
				
			// (erp_id)찾기
			public int getErp(int bbsID) {
				//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
				String sql = "select erp_id from erp_bbs where bbsID=?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, bbsID);
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getInt(1);
					}
					return 1; //첫 번째 게시물인 경우
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
	
	//게시글 번호 부여 메소드 (Summary_admin)
			public int getNextSumAdmin() {
				//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
				String sql = "select sumad_id from summary_admin order by sumad_id desc";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getInt(1) + 1;
					}
					return 1; //첫 번째 게시물인 경우
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
	
	// 이전 bbs개수 카운트 메소드
	public int getCount(int bbsID) {
		//현재 게시글을 내림차순으로 조회하여 가장 마지막 글의 번호를 구한다
		String sql = " select count(bbsID) from bbs where bbsID < ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getInt(1);
			}
			return 1; //첫 번째 게시물인 경우
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	//글쓰기 메소드
	public int write(String id, String bbsManager,String bbsTitle, String name, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget, String bbsDeadline, String pluser) {
		String sql = "insert into bbs values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		String sign = "미승인";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, getNext());
			pstmt.setString(2, bbsManager);
			pstmt.setString(3, bbsTitle);
			pstmt.setString(4, id);
			pstmt.setString(5, name);
			pstmt.setString(6, getDate());
			pstmt.setString(7, bbsContent);
			pstmt.setString(8, bbsStart);
			pstmt.setString(9, bbsTarget);
			pstmt.setString(10, bbsEnd);
			pstmt.setString(11, bbsNContent);
			pstmt.setString(12, bbsNStart);
			pstmt.setString(13, bbsNTarget);
			pstmt.setInt(14, 1); //글의 유효번호
			pstmt.setString(15, bbsDeadline);
			pstmt.setString(16,  name);
			pstmt.setString(17, sign);
			pstmt.setString(18, pluser);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	//게시글 리스트 메소드 -> 요약본 (작성)
	public ArrayList<Bbs> getListBbs(String[] bbsID){
		String sql =  "select * from bbs where (";
				for(int i=0; i<bbsID.length; i++) {
					if(i <bbsID.length-1) {
						sql +="bbsID='"+bbsID[i].trim()+"'" +" or ";
					}else {
						sql += "bbsID='"+bbsID[i].trim()+"'";
					}	
				}
					sql	+= ") order by bbsID desc";
				ArrayList<Bbs> list = new ArrayList<Bbs>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Bbs bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsManager(rs.getString(2));
				bbs.setBbsTitle(rs.getString(3));
				bbs.setUserID(rs.getString(4));
				bbs.setUserName(rs.getString(5));
				bbs.setBbsDate(rs.getString(6));
				bbs.setBbsContent(rs.getString(7));
				bbs.setBbsStart(rs.getString(8));
				bbs.setBbsTarget(rs.getString(9));
				bbs.setBbsEnd(rs.getString(10));
				bbs.setBbsNContent(rs.getString(11));
				bbs.setBbsNStart(rs.getString(12));
				bbs.setBbsNTarget(rs.getString(13));
				bbs.setBbsAvailable(rs.getInt(14));
				bbs.setBbsDeadline(rs.getString(15));
				bbs.setBbsUpdate(rs.getString(16));
				bbs.setSign(rs.getString(17));
				list.add(bbs);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

		
	//게시글 리스트 메소드 (bbsRk)
	public ArrayList<Bbs> getList(int pageNumber, String bbsDeadline, String[] pllist){
		String sql =  "select * from (select * from bbs where sign='마감' or sign='승인') a "
				+ "where a.bbsDeadline like '%"+bbsDeadline.trim()+"%' and (";
				for(int i=0; i<pllist.length; i++) {
					if(i <pllist.length-1) {
						sql +="a.userID='"+pllist[i].trim()+"'" +" or ";
					}else {
						sql += "a.userID='"+pllist[i].trim()+"'";
					}	
				}
					sql	+= ") order by a.bbsID desc limit ?,10";
				ArrayList<Bbs> list = new ArrayList<Bbs>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, (pageNumber-1) * 10 );
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Bbs bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsManager(rs.getString(2));
				bbs.setBbsTitle(rs.getString(3));
				bbs.setUserID(rs.getString(4));
				bbs.setUserName(rs.getString(5));
				bbs.setBbsDate(rs.getString(6));
				bbs.setBbsContent(rs.getString(7));
				bbs.setBbsStart(rs.getString(8));
				bbs.setBbsTarget(rs.getString(9));
				bbs.setBbsEnd(rs.getString(10));
				bbs.setBbsNContent(rs.getString(11));
				bbs.setBbsNStart(rs.getString(12));
				bbs.setBbsNTarget(rs.getString(13));
				bbs.setBbsAvailable(rs.getInt(14));
				bbs.setBbsDeadline(rs.getString(15));
				bbs.setBbsUpdate(rs.getString(16));
				bbs.setSign(rs.getString(17));
				bbs.setPluser(rs.getString(18));
				list.add(bbs);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	//게시글 리스트 메소드 (bbsRk)
		public ArrayList<Bbs> getListfull(String bbsDeadline, String[] pllist){
			String sql =  "select * from (select * from bbs where sign='마감' or sign='승인') a "
					+ "where a.bbsDeadline like '%"+bbsDeadline.trim()+"%' and (";
					for(int i=0; i<pllist.length; i++) {
						if(i <pllist.length-1) {
							sql +="a.userID='"+pllist[i].trim()+"'" +" or ";
						}else {
							sql += "a.userID='"+pllist[i].trim()+"'";
						}	
					}
						sql	+= ") order by a.bbsID desc";
					ArrayList<Bbs> list = new ArrayList<Bbs>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsManager(rs.getString(2));
					bbs.setBbsTitle(rs.getString(3));
					bbs.setUserID(rs.getString(4));
					bbs.setUserName(rs.getString(5));
					bbs.setBbsDate(rs.getString(6));
					bbs.setBbsContent(rs.getString(7));
					bbs.setBbsStart(rs.getString(8));
					bbs.setBbsTarget(rs.getString(9));
					bbs.setBbsEnd(rs.getString(10));
					bbs.setBbsNContent(rs.getString(11));
					bbs.setBbsNStart(rs.getString(12));
					bbs.setBbsNTarget(rs.getString(13));
					bbs.setBbsAvailable(rs.getInt(14));
					bbs.setBbsDeadline(rs.getString(15));
					bbs.setBbsUpdate(rs.getString(16));
					bbs.setSign(rs.getString(17));
					bbs.setPluser(rs.getString(18));
					list.add(bbs);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
	
	// Admin 권한(rank - 실장) => 모든 게시글 확인하기
	public ArrayList<Bbs> getList(int pageNumber){
		String sql =  "select * from (select * from bbs where sign='마감' or sign='승인') a order by a.bbsID desc limit ?,10";
				ArrayList<Bbs> list = new ArrayList<Bbs>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, (pageNumber-1) * 10 );
			rs = pstmt.executeQuery();
			while(rs.next()) {
				Bbs bbs = new Bbs();
				bbs.setBbsID(rs.getInt(1));
				bbs.setBbsManager(rs.getString(2));
				bbs.setBbsTitle(rs.getString(3));
				bbs.setUserID(rs.getString(4));
				bbs.setUserName(rs.getString(5));
				bbs.setBbsDate(rs.getString(6));
				bbs.setBbsContent(rs.getString(7));
				bbs.setBbsStart(rs.getString(8));
				bbs.setBbsTarget(rs.getString(9));
				bbs.setBbsEnd(rs.getString(10));
				bbs.setBbsNContent(rs.getString(11));
				bbs.setBbsNStart(rs.getString(12));
				bbs.setBbsNTarget(rs.getString(13));
				bbs.setBbsAvailable(rs.getInt(14));
				bbs.setBbsDeadline(rs.getString(15));
				bbs.setBbsUpdate(rs.getString(16));
				bbs.setSign(rs.getString(17));
				bbs.setPluser(rs.getString(18));
				list.add(bbs);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
		//페이징 처리 메소드
		public boolean nextPage(int pageNumber) {
			String sql = "select * from bbs where bbsID < ? and bbsAvailable = 1";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, getNext() - (pageNumber - 1) * 10);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return true;
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return false;
	}
		
		
		
		//하나의 게시글을 보는 메소드
		public Bbs getBbs(int bbsID) {
			String sql = "select * from bbs where bbsID = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, bbsID);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsManager(rs.getString(2));
					bbs.setBbsTitle(rs.getString(3));
					bbs.setUserID(rs.getString(4));
					bbs.setUserName(rs.getString(5));
					bbs.setBbsDate(rs.getString(6));
					bbs.setBbsContent(rs.getString(7));
					bbs.setBbsStart(rs.getString(8));
					bbs.setBbsTarget(rs.getString(9));
					bbs.setBbsEnd(rs.getString(10));
					bbs.setBbsNContent(rs.getString(11));
					bbs.setBbsNStart(rs.getString(12));
					bbs.setBbsNTarget(rs.getString(13));
					bbs.setBbsAvailable(rs.getInt(14));
					bbs.setBbsDeadline(rs.getString(15));
					bbs.setBbsUpdate(rs.getString(16));
					bbs.setSign(rs.getString(17));
					bbs.setPluser(rs.getString(18));
					return bbs;
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
		
		//게시글 수정 메소드
		public int update(int bbsID, String bbsManager, String bbsTitle, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget, java.sql.Timestamp date, String bbsUpdate) {
			String sql = "update bbs set bbsManager=?,  bbsTitle = ?, bbsContent = ?, bbsStart = ?, bbsTarget = ?, bbsDate= ? ,bbsEnd = ?, bbsNContent = ?, bbsNStart = ?, bbsNTarget = ?, bbsUpdate = ? where bbsID =?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsManager);
				pstmt.setString(2, bbsTitle);
				pstmt.setString(3, bbsContent);
				pstmt.setString(4, bbsStart);
				pstmt.setString(5, bbsTarget);
				pstmt.setTimestamp(6, date);
				pstmt.setString(7, bbsEnd);
				pstmt.setString(8, bbsNContent);
				pstmt.setString(9, bbsNStart);
				pstmt.setString(10, bbsNTarget);
				pstmt.setString(11, bbsUpdate);
				pstmt.setInt(12, bbsID);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
	

		//게시글 삭제 메소드
		public int delete(int bbsID) {
			//실제 데이터 또한 삭제한다.
			String sql = "delete from bbs where bbsID = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, bbsID);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류 
		}

		//요약본(summary) 삭제 메소드
		public int deleteSum(int sum_id) {
			//실제 데이터 또한 삭제한다.
			String sql = "delete from summary where sum_id = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, sum_id);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류 
		}
		
		
		// 검색 메소드 
		public ArrayList<Bbs> getSearch(int pageNumber, String name, String searchField, String searchText){//특정한 리스트를 받아서 반환
		      ArrayList<Bbs> list = new ArrayList<Bbs>();
		      String SQL ="select * from (select * from bbs where userName like '%"+name.trim()+"%') a"
		      		+ " WHERE "+searchField.trim();
		      try {
		            if(searchText != null && !searchText.equals("") ){
		                SQL +=" LIKE '%"+searchText.trim()+"%' order by BbsDeadline desc limit ?,10";
		            }
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setInt(1, (pageNumber-1) * 10);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsManager(rs.getString(2));
					bbs.setBbsTitle(rs.getString(3));
					bbs.setUserID(rs.getString(4));
					bbs.setUserName(rs.getString(5));
					bbs.setBbsDate(rs.getString(6));
					bbs.setBbsContent(rs.getString(7));
					bbs.setBbsStart(rs.getString(8));
					bbs.setBbsTarget(rs.getString(9));
					bbs.setBbsEnd(rs.getString(10));
					bbs.setBbsNContent(rs.getString(11));
					bbs.setBbsNStart(rs.getString(12));
					bbs.setBbsNTarget(rs.getString(13));
					bbs.setBbsAvailable(rs.getInt(14));
					bbs.setBbsDeadline(rs.getString(15));
					bbs.setBbsUpdate(rs.getString(16));
					bbs.setSign(rs.getString(17));
					bbs.setPluser(rs.getString(18));
		            list.add(bbs);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
		// 검색 메소드 (일반 사용자용)
				public ArrayList<Bbs> getRkSearch(int pageNumber, String searchField, String searchText){//특정한 리스트를 받아서 반환
				      ArrayList<Bbs> list = new ArrayList<Bbs>();
				      String SQL ="select * from bbs a WHERE a."+searchField.trim();
				      try {
				            if(searchText != null && !searchText.equals("") ){
				                SQL +=" LIKE '%"+searchText.trim()+"%' order by a.bbsDeadline desc limit ?,10";
				            } else { 
				            	SQL +=" LIKE '%---%' order by a.bbsDeadline desc limit ?,10";
				            }
				            PreparedStatement pstmt=conn.prepareStatement(SQL);
				            pstmt.setInt(1, (pageNumber-1) * 10);
							rs=pstmt.executeQuery();//select
				         while(rs.next()) {
				            Bbs bbs = new Bbs();
							bbs.setBbsID(rs.getInt(1));
							bbs.setBbsManager(rs.getString(2));
							bbs.setBbsTitle(rs.getString(3));
							bbs.setUserID(rs.getString(4));
							bbs.setUserName(rs.getString(5));
							bbs.setBbsDate(rs.getString(6));
							bbs.setBbsContent(rs.getString(7));
							bbs.setBbsStart(rs.getString(8));
							bbs.setBbsTarget(rs.getString(9));
							bbs.setBbsEnd(rs.getString(10));
							bbs.setBbsNContent(rs.getString(11));
							bbs.setBbsNStart(rs.getString(12));
							bbs.setBbsNTarget(rs.getString(13));
							bbs.setBbsAvailable(rs.getInt(14));
							bbs.setBbsDeadline(rs.getString(15));
							bbs.setBbsUpdate(rs.getString(16));
							bbs.setSign(rs.getString(17));
							bbs.setPluser(rs.getString(18));
				            list.add(bbs);
				         }       
				      } catch(Exception e) {
				         e.printStackTrace();
				      }
				      return list;
				   }
		
				
				//select * from (select * from bbs where userName like '%이지은%') a where a.sign="미승인" order by a.bbsDeadline ASC limit 0,10; 
				// 검색 메소드 (일반 사용자용 -> '미승인' 만을 가져옴!)
				public ArrayList<Bbs> getNoneSignSearch(int pageNumber, String searchText){//특정한 리스트를 받아서 반환
				      ArrayList<Bbs> list = new ArrayList<Bbs>();
				      String SQL ="select * from (select * from bbs where userName like '%"+searchText.trim()+"%') a"
				      		+ " WHERE a.sign='미승인' order by a.bbsDeadline ASC limit ?,10";
				      try {
				            PreparedStatement pstmt=conn.prepareStatement(SQL);
				            pstmt.setInt(1, (pageNumber-1) * 10);
							rs=pstmt.executeQuery();//select
				         while(rs.next()) {
				        	 Bbs bbs = new Bbs();
							bbs.setBbsID(rs.getInt(1));
							bbs.setBbsManager(rs.getString(2));
							bbs.setBbsTitle(rs.getString(3));
							bbs.setUserID(rs.getString(4));
							bbs.setUserName(rs.getString(5));
							bbs.setBbsDate(rs.getString(6));
							bbs.setBbsContent(rs.getString(7));
							bbs.setBbsStart(rs.getString(8));
							bbs.setBbsTarget(rs.getString(9));
							bbs.setBbsEnd(rs.getString(10));
							bbs.setBbsNContent(rs.getString(11));
							bbs.setBbsNStart(rs.getString(12));
							bbs.setBbsNTarget(rs.getString(13));
							bbs.setBbsAvailable(rs.getInt(14));
							bbs.setBbsDeadline(rs.getString(15));
							bbs.setBbsUpdate(rs.getString(16));
							bbs.setSign(rs.getString(17));
							bbs.setPluser(rs.getString(18));
				            list.add(bbs);
				         }         
				      } catch(Exception e) {
				         e.printStackTrace();
				      }
				      return list;
				   }
				
		
		// 취합 메소드 
				public ArrayList<Bbs> getGathering(String searchField, String searchText){//특정한 리스트를 받아서 반환
				      ArrayList<Bbs> list = new ArrayList<Bbs>();
				      String SQL ="select * from bbs WHERE "+searchField.trim();
				      try {
				            if(searchText != null && !searchText.equals("") ){
				                SQL +=" LIKE '%"+searchText.trim()+"%' order by bbsID desc";
				            }
				            PreparedStatement pstmt=conn.prepareStatement(SQL);
							rs=pstmt.executeQuery();//select
				         while(rs.next()) {
				        	 Bbs bbs = new Bbs();
							bbs.setBbsID(rs.getInt(1));
							bbs.setBbsManager(rs.getString(2));
							bbs.setBbsTitle(rs.getString(3));
							bbs.setUserID(rs.getString(4));
							bbs.setUserName(rs.getString(5));
							bbs.setBbsDate(rs.getString(6));
							bbs.setBbsContent(rs.getString(7));
							bbs.setBbsStart(rs.getString(8));
							bbs.setBbsTarget(rs.getString(9));
							bbs.setBbsEnd(rs.getString(10));
							bbs.setBbsNContent(rs.getString(11));
							bbs.setBbsNStart(rs.getString(12));
							bbs.setBbsNTarget(rs.getString(13));
							bbs.setBbsAvailable(rs.getInt(14));
							bbs.setBbsDeadline(rs.getString(15));
							bbs.setBbsUpdate(rs.getString(16));
							bbs.setSign(rs.getString(17));
							bbs.setPluser(rs.getString(18));
				            list.add(bbs);
				         }         
				      } catch(Exception e) {
				         e.printStackTrace();
				      }
				      return list;
				   }
		
		
		/* **************** 이전에 작성한 주간보고의 양식을 불러오는 메서드 영역 *************** */
			
		/* 접속한 id에 bbs 이력이 있는지 확인하는 메서드 */
		public int getBbsRecord(String id) {
			String sql = "select max(b.bbsDate), b.bbsID from bbs b inner join user u on b.userID = u.id and u.id = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery();
				if(rs.next()) {
					if(rs.getString(1) != null) {
						return 1;
					}
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return 0; //작성한 bbs가 없음!
		}
		
		
		/* 가장 최근에 생성된 bbs의 ID 조회 */
	 public int getMaxbbs(String id) { 
	 String sql ="select bbsID from (select * from bbs where userID=?) bbs order by bbsDeadline desc"; 
	 try { PreparedStatement pstmt = conn.prepareStatement(sql);
	 	pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입 
	 	rs =pstmt.executeQuery(); 
	 	if(rs.next()) { return rs.getInt(1); } 
	 }catch (Exception e) { 
	 e.printStackTrace(); } return -1; //데이터베이스 오류 
	 }
			 		 
		 
		
	
	/* 가장 최근에 생성된 sum의 ID 조회  (summary) */ 
 	public int getMaxsum(String bbsDeadline) { 
	 String sql ="select sum_id from (select * from summary where bbsDeadline=?) summary order by bbsDeadline desc" ; 
	 try { PreparedStatement pstmt = conn.prepareStatement(sql);
	 		  pstmt.setString(1, bbsDeadline); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입 
	 	rs =pstmt.executeQuery();
	  if(rs.next()) { return rs.getInt(1); } 
	 }catch
	   (Exception e) { e.printStackTrace(); } return -1; //데이터베이스 오류 
	  }
		 
		
		
		/* n번째로 최근에 생성된 bbs의 ID 조회 */
		public int getNMaxbbs(String id, int i) {
			String sql = "select bbsID from (select * from bbs where userID=?) bbs order by bbsDate desc limit 1 offset ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				pstmt.setInt(2, i);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		/* n번째로 최근에 생성된 sum_id의 ID 조회 */
		public int getNMaxSum(String pl, int week) {
			String sql = " select sum_id from (select * from summary where pl=?) summary order by bbsDeadline desc limit 1 offset ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, pl); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				pstmt.setInt(2, week);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		
		/* n번째로 최근에 생성된 sumad_id의 ID 조회 (summary_admin)*/
		public int getNMaxSumad(int week) {
			String sql = " select sumad_id, bbsDeadline from summary_admin order by bbsDeadline desc limit 1 offset ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, week);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		// 아이디의 bbs 총 개수 세기
		public int getCountbbs(String id) {
			String sql = "select count(bbsID) from (select * from bbs where userID=?) bbs order by bbsDate desc";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		// pl에 해당되는 총 개수 세기
		public int getCountSum(String pl) {
			String sql = "select count(sum_id) from (select * from summary where pl=?) summary order by sum_id desc";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, pl); 
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		// summaey_admin 총 개수 세기
			public int getCountSumAddmin() {
				String sql = "select count(sumad_id) from summary_admin order by sumad_id desc";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getInt(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
		
		//가장 최근 작성된 게시글 하나를 보는 메소드
		public Bbs getBbsLast(String id) {
			String sql = " select * from bbs b Inner join user u on b.userID = u.id and  u.id = ? where b.bbsDate = (select max(bbsDate) from bbs)";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsManager(rs.getString(2));
					bbs.setBbsTitle(rs.getString(3));
					bbs.setUserID(rs.getString(4));
					bbs.setUserName(rs.getString(5));
					bbs.setBbsDate(rs.getString(6));
					bbs.setBbsContent(rs.getString(7));
					bbs.setBbsStart(rs.getString(8));
					bbs.setBbsTarget(rs.getString(9));
					bbs.setBbsEnd(rs.getString(10));
					bbs.setBbsNContent(rs.getString(11));
					bbs.setBbsNStart(rs.getString(12));
					bbs.setBbsNTarget(rs.getString(13));
					bbs.setBbsAvailable(rs.getInt(14));
					bbs.setBbsDeadline(rs.getString(15));
					bbs.setSign(rs.getString(16));
					bbs.setPluser(rs.getString(18));
					return bbs;
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
				
		// 같은 날짜에 보고된 주간보고가 있는지 확인
		public String getDL(String i,String id) {
			String sql = "select bbsID from bbs where bbsDeadLine = ? and userID = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, i); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				pstmt.setString(2, id);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getString(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return ""; //데이터베이스 오류
		}
		
		// 같은 날짜에 보고된 주간보고가 있는지 확인
			public String getDLS(int i) {
				String sql = "select bbsDeadLine from bbs where bbsID = ?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, i); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			public String getuserid(int i) {
				String sql = "select userID from bbs where bbsID = ?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, i); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			
			// 검색 메소드 
			public ArrayList<Bbs> getDeadLineList() {
			      ArrayList<Bbs> list = new ArrayList<Bbs>();
			      String sql = "select bbsDeadLine from bbs group by bbsDeadLine DESC";
			      try {
			            PreparedStatement pstmt=conn.prepareStatement(sql);
						rs=pstmt.executeQuery();//select
			         while(rs.next()) {
			        	 Bbs bbs = new Bbs();
						bbs.setBbsDeadline(rs.getString(1));
			            list.add(bbs);
			         }         
			      } catch(Exception e) {
			         e.printStackTrace();
			      }
			      return list;
			   }
			
			
			// 요약본(Summary) BbsDeadline 중, 가장 큰 제출일 검색 메소드 
			public String getDeadLineListSum() {
			      String sql = " select bbsDeadline from summary order by bbsDeadline desc";
			      try {
			            PreparedStatement pstmt=conn.prepareStatement(sql);
						rs=pstmt.executeQuery();//select
			         while(rs.next()) {
			        	 return rs.getString(1);
			         }         
			      } catch(Exception e) {
			         e.printStackTrace();
			      }
			      return "";
			   }
				
			
			// bbs의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
			public int getSignDeadLine(int bbsId) {
				String sql = " update bbs set sign='마감' where bbsId=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, bbsId); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
			
			
			// bbs의 Sign을 승인으로 변경함! (승인(제출)버튼 클릭시!) => + 승인시, 마지막에 줄바꿈을 추가함(원활한 분리를 위함)
			public int SignAction(String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget, int bbsID) {
				String sql = " update bbs set  bbsContent=?, bbsStart=?, bbsTarget=?, bbsEnd=?, bbsNContent=?, bbsNStart=?, bbsNTarget=?, sign='승인' where bbsId=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsContent);
					pstmt.setString(2, bbsStart);
					pstmt.setString(3, bbsTarget);
					pstmt.setString(4, bbsEnd);
					pstmt.setString(5, bbsNContent);
					pstmt.setString(6, bbsNStart);
					pstmt.setString(7, bbsNTarget);
					pstmt.setInt(8, bbsID); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}

						
			//bbsRkAction -> summary 테이블에 데이터 삽입
			public int SummaryWrite(String pl, String bbsContent, String bbsEnd, String progress, String state, String note, String bbsNContent, String bbsNTarget, String bbsDeadline, String nnote, java.sql.Timestamp summaryDate, String summaryUpdate ) {
				String sql = "insert into summary values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
				String sign = "미승인";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, getNextSum()); //sum_id
					pstmt.setString(2, pl); //pl
					pstmt.setString(3, bbsContent); //bbsContent
					pstmt.setString(4, bbsEnd); //bbsEnd
					pstmt.setString(5, progress); //progress
					pstmt.setString(6, state); //state
					pstmt.setString(7, note); //note
					pstmt.setString(8, bbsNContent); //bbsNContent
					pstmt.setString(9, bbsNTarget); //bbsNTarget
					pstmt.setString(10, bbsDeadline); //bbsDeadline
					pstmt.setString(11, nnote); //nnote
					pstmt.setString(12, sign);
					pstmt.setTimestamp(13, summaryDate);
					pstmt.setString(14, summaryUpdate);
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
			
			
			//summary sum_id를 통해 내용 가져오기 
			public ArrayList<String> getlistSum(String sum_id, String pl){
				String sql =  "select * from summary where sum_id=? and pl=?";
						ArrayList<String> list = new ArrayList<String>();
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, sum_id);
					pstmt.setString(2, pl);
					rs = pstmt.executeQuery();
					while(rs.next()) {
						list.add(rs.getString(1)); //userid
						list.add(rs.getString(2));
						list.add(rs.getString(3));
						list.add(rs.getString(4));
						list.add(rs.getString(5));
						list.add(rs.getString(6));
						list.add(rs.getString(7));
						list.add(rs.getString(8));
						list.add(rs.getString(9));
						list.add(rs.getString(10));
						list.add(rs.getString(11));
						list.add(rs.getString(12));
						list.add(rs.getString(13));
						list.add(rs.getString(14));
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return list;
			}
			
			
			
			
			
			//summary_admin sumad_id를 통해 내용 가져오기 
			public ArrayList<String> getlistSumad(String sumad_id){
				String sql =  "select * from summary_admin where sumad_id=? ";
						ArrayList<String> list = new ArrayList<String>();
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, sumad_id);
					rs = pstmt.executeQuery();
					while(rs.next()) {
						list.add(rs.getString(1)); //
						list.add(rs.getString(2));
						list.add(rs.getString(3));
						list.add(rs.getString(4));
						list.add(rs.getString(5));
						list.add(rs.getString(6));
						list.add(rs.getString(7));
						list.add(rs.getString(8));
						list.add(rs.getString(9));
						list.add(rs.getString(10));
						list.add(rs.getString(11));
						list.add(rs.getString(12));
						list.add(rs.getString(13));
						list.add(rs.getString(14));
						list.add(rs.getString(15));
						list.add(rs.getString(16));
						list.add(rs.getString(17));
						list.add(rs.getString(18));
						list.add(rs.getString(19));
						list.add(rs.getString(20));
						list.add(rs.getString(21));
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return list;
			}
			
			//게시글 수정 메소드
			public int updateSum(int sum_id, String bbsContent, String bbsEnd, String progress, String state, String note, String bbsNContent, String bbsNTarget, String bbsDeadline, String nnote, String sign, java.sql.Timestamp summaryDate, String summaryUpdate) {
				String sql = "update summary set bbsContent = ?,  bbsEnd = ?, progress = ?, state = ?, note = ?, bbsNContent= ? ,bbsNTarget = ?, bbsDeadline = ?, nnote = ?, sign = ?, summaryDate = ?, summaryUpdate = ? where sum_id =?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsContent);
					pstmt.setString(2, bbsEnd);
					pstmt.setString(3, progress);
					pstmt.setString(4, state);
					pstmt.setString(5, note);
					pstmt.setString(6, bbsNContent);
					pstmt.setString(7, bbsNTarget);
					pstmt.setString(8, bbsDeadline);
					pstmt.setString(9, nnote);
					pstmt.setString(10, sign);
					pstmt.setTimestamp(11, summaryDate);
					pstmt.setString(12, summaryUpdate);
					pstmt.setInt(13, sum_id);
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
			
			//ERP, WEB)) bbsDeadline을 통한 sum_id 검색
			public String getSumid(String bbsDeadline, String pl) {
				String sql = "select sum_id from summary where bbsDeadline = ? and pl=?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsDeadline); 
					pstmt.setString(2, pl); 
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			
			//bbsRkAction -> summary 테이블에 데이터 삽입
			public int SummaryAdminWrite(String e_content, String e_end, String e_progress, String e_state, String e_note, String e_ncontent, String e_ntarget, String e_nnote, String w_content, String w_end, String w_progress, String w_state, String w_note, String w_ncontent, String w_ntarget, String w_nnote, String sign, String bbsDeadline, java.sql.Timestamp sumadDate, String sumadUpdate) {
				String sql = "insert into summary_admin values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, getNextSumAdmin()); 
					pstmt.setString(2, e_content); 
					pstmt.setString(3, e_end);
					pstmt.setString(4, e_progress); 
					pstmt.setString(5, e_state); 
					pstmt.setString(6, e_note); 
					pstmt.setString(7, e_ncontent); 
					pstmt.setString(8, e_ntarget);
					pstmt.setString(9, e_nnote); 
					pstmt.setString(10, w_content); 
					pstmt.setString(11, w_end); 
					pstmt.setString(12, w_progress);
					pstmt.setString(13, w_state);
					pstmt.setString(14, w_note);
					pstmt.setString(15, w_ncontent);
					pstmt.setString(16, w_ntarget);
					pstmt.setString(17, w_nnote);
					pstmt.setString(18, sign);
					pstmt.setString(19, bbsDeadline);
					pstmt.setTimestamp(20, sumadDate);
					pstmt.setString(21, sumadUpdate);
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
			
			
			//bbsRkAction -> summary 테이블에 데이터 삽입
			public int SummaryAdminUpdate(int sumad_id,String e_content, String e_end, String e_progress, String e_state, String e_note, String e_ncontent, String e_ntarget, String e_nnote, String w_content, String w_end, String w_progress, String w_state, String w_note, String w_ncontent, String w_ntarget, String w_nnote, String sign, String bbsDeadline, java.sql.Timestamp sumadDate) {
				String sql = "update summary_admin set e_content=?, e_end=?, e_progress=?, e_state=?, e_note=?, e_ncontent=?, e_ntarget=?, e_nnote=?, w_content=?, w_end=?, w_progress=?, w_state=?, w_note=?, w_ncontent=?, w_ntarget=?, w_nnote=?, sign=?, bbsDeadline=?, sumadDate=? where sumad_id = ?";
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
					pstmt.setString(18, bbsDeadline);
					pstmt.setTimestamp(19, sumadDate); //sumadDate
					pstmt.setInt(20, sumad_id);
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				return -1; //데이터베이스 오류
			}
			
			
			//select sumad_id from summary_admin where bbsDeadline ="2022-12-26";
			//ERP, WEB)) bbsDeadline을 통한 sum_id 검색
			public String getSumAdminid(String bbsDeadline) {
				String sql = "select sumad_id from summary_admin where bbsDeadline = ?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsDeadline);  
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			
			//pl에 따라 bbsDeadline을 통한 sum_id 검색
			public String getSumid_Deadline(String bbsDeadline, String pl) {
				String sql = "select sum_id from summary where bbsDeadline = ? and pl=?";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, bbsDeadline);  
					pstmt.setString(2, pl);  
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			//pl에 따른 sum_id 검색 (정렬을 bbsDeadline)
			public String getSumidpl(String pl) {
				String sql = "select sum_id from summary where pl=? order by bbsDeadline desc";
				try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, pl);  
					rs = pstmt.executeQuery();
					if(rs.next()) {
						return rs.getString(1);
					}
				}catch (Exception e) {
					e.printStackTrace();
				}
				return ""; //데이터베이스 오류
			}
			
			
			// bbs의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
			public int sumSign(int sum_id) {
				String sql = " update summary set sign='마감' where sum_id=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, sum_id); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
			
			// bbs의 Sign을 마감으로 변경함! ((제출 날짜가 지남!)) // summary_admin
			public int sumadSign(int sumad_id) {
				String sql = " update summary_admin set sign='마감' where sumad_id=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, sumad_id); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
			
			// Sign을 마감으로 변경함! ((제출 날짜가 지남!)) // summary_admin
			public int sumadSignOn(int sumad_id) {
				String sql = " update summary_admin set sign='승인' where sumad_id=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, sumad_id); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
			
			// bbs의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
			public int sumSignOn(int sum_id) {
				String sql = " update summary set sign='승인' where sum_id=?";
				 try {
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, sum_id); // bbsId 삽입
					return pstmt.executeUpdate();
				}catch (Exception e) {
					e.printStackTrace();
				}
				 return -1;
			}
			
		//erp_bbs 작성 (erpManager만 담당함 -> '계정관리 - 35번')
		public int erpWrite(String erp_date, String erp_user, String erp_stext, String erp_authority, String erp_division, String erpManger, String bbsDeadline, int bbsID) {
			String sql = "insert into erp_bbs values(?,?,?,?,?,?,?,?,?)";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, getNextErp()); //erp_id
				pstmt.setString(2, erp_date); 
				pstmt.setString(3, erp_user);
				pstmt.setString(4, erp_stext); 
				pstmt.setString(5, erp_authority); 
				pstmt.setString(6, erp_division); 
				pstmt.setString(7, erpManger); //userName이 들어감
				pstmt.setString(8, bbsDeadline);
				pstmt.setInt(9, bbsID); 
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
			
		//erp_bbs 작성을 위한 bbsID, bbsManager 구하기
		//summary_admin sumad_id를 통해 내용 가져오기 
		public ArrayList<String> getbbsID(String bbsDeadline, String userName){
			String sql =  "select bbsID, userName, bbsDeadline from bbs where bbsDeadline=? and userName=?";
					ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsDeadline);
				pstmt.setString(2, userName);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //bbsID
					list.add(rs.getString(2)); //bbsManger
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
		// erp_id를 bbsDeadline으로 가져오기
		public ArrayList<String> geterpid(String bbsDeadline){
			String sql =  "select * from erp_bbs where bbsDeadline=?";
					ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsDeadline);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1));
					list.add(rs.getString(2)); 
					list.add(rs.getString(3));
					list.add(rs.getString(4));
					list.add(rs.getString(5));
					list.add(rs.getString(6));
					list.add(rs.getString(7));
					list.add(rs.getString(8));
					list.add(rs.getString(9));
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
		//작성이 안된 상황을 고려해 bbsID를 통한 삭제 진행
		//게시글 삭제 메소드
		public int deleteErp(int bbsID) {
			//실제 데이터 또한 삭제한다.
			String sql = "delete from erp_bbs where bbsID = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, bbsID);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류 
		}
		
		
	
		//Update 및 조회에 활용될 erp_bbs 내용 가져오기
		public ArrayList<String> geterpbbs(int bbsID){
			String sql =  "select * from erp_bbs where bbsID=?";
					ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, bbsID);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //erp_id
					list.add(rs.getString(2)); //erp_date
					list.add(rs.getString(3)); //erp_user
					list.add(rs.getString(4)); //erp_stext
					list.add(rs.getString(5)); //erp_authority
					list.add(rs.getString(6)); //erp_division
					list.add(rs.getString(7)); //erpManager
					list.add(rs.getString(8)); //bbsDeadline
					list.add(rs.getString(9)); //bbsID
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
		
	
		//erp_bbs 게시글 수정 메소드
		public int erp_update(String erp_date, String erp_user, String erp_stext, String erp_authority, String erp_division, int erp_id) {
			String sql = "update erp_bbs set erp_date=?, erp_user=?, erp_stext=?, erp_authority=?, erp_division=? where erp_id=?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, erp_date);
				pstmt.setString(2, erp_user);
				pstmt.setString(3, erp_stext);
				pstmt.setString(4, erp_authority);
				pstmt.setString(5, erp_division);
				pstmt.setInt(6, erp_id);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류
		}
		
		
		//erp_bbs 게시글 삭제 메소드
		public int delete_erp(int bbsID) {
			//실제 데이터 또한 삭제한다.
			String sql = "delete from erp_bbs where bbsID = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, bbsID);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류 
		}
		
		
		//승인 상태인 bbsID를 가져오기 -> 네비바의 작성을 위함 
		public ArrayList<String> signgetBbsID(String pluser){
			String sql =  " select bbsID from bbs where pluser=? and  sign='승인'";
					ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, pluser);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //bbsID
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
}

