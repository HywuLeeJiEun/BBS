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
	public int write(String id, String bbsTitle, String name, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget, String bbsDeadline) {
		String sql = "insert into bbs values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, getNext());
			pstmt.setString(2, bbsTitle);
			pstmt.setString(3, id);
			pstmt.setString(4, name);
			pstmt.setString(5, getDate());
			pstmt.setString(6, bbsContent);
			pstmt.setString(7, bbsStart);
			pstmt.setString(8, bbsTarget);
			pstmt.setString(9, bbsEnd);
			pstmt.setString(10, bbsNContent);
			pstmt.setString(11, bbsNStart);
			pstmt.setString(12, bbsNTarget);
			pstmt.setInt(13, 1); //글의 유효번호
			pstmt.setString(14, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//게시글 리스트 메소드
		public ArrayList<Bbs> getList(int pageNumber){
			//String sql = "select * from bbs where bbsID < ? and bbsAvailable = 1 order by bbsID desc limit 10";
			String sql = "select * from bbs order by bbsID desc limit ?,10";
			ArrayList<Bbs> list = new ArrayList<Bbs>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				//pstmt.setInt(1, getNext() - (pageNumber - 1) * 10);
				pstmt.setInt(1, (pageNumber-1) * 10 );
				rs = pstmt.executeQuery();
				while(rs.next()) {
					Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsTitle(rs.getString(2));
					bbs.setUserID(rs.getString(3));
					bbs.setUserName(rs.getString(4));
					bbs.setBbsDate(rs.getString(5));
					bbs.setBbsContent(rs.getString(6));
					bbs.setBbsStart(rs.getString(7));
					bbs.setBbsTarget(rs.getString(8));
					bbs.setBbsEnd(rs.getString(9));
					bbs.setBbsNContent(rs.getString(10));
					bbs.setBbsNStart(rs.getString(11));
					bbs.setBbsNTarget(rs.getString(12));
					bbs.setBbsAvailable(rs.getInt(13));
					bbs.setBbsDeadline(rs.getString(14));
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
					bbs.setBbsTitle(rs.getString(2));
					bbs.setUserID(rs.getString(3));
					bbs.setUserName(rs.getString(4));
					bbs.setBbsDate(rs.getString(5));
					bbs.setBbsContent(rs.getString(6));
					bbs.setBbsStart(rs.getString(7));
					bbs.setBbsTarget(rs.getString(8));
					bbs.setBbsEnd(rs.getString(9));
					bbs.setBbsNContent(rs.getString(10));
					bbs.setBbsNStart(rs.getString(11));
					bbs.setBbsNTarget(rs.getString(12));
					bbs.setBbsAvailable(rs.getInt(13));
					bbs.setBbsDeadline(rs.getString(14));
					return bbs;
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
		
		//게시글 수정 메소드
		public int update(int bbsID, String bbsTitle, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget) {
			String sql = "update bbs set bbsTitle = ?, bbsContent = ?, bbsStart = ?, bbsTarget = ?, bbsEnd = ?, bbsNContent = ?, bbsNStart = ?, bbsNTarget = ? where bbsID =?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, bbsTitle);
				pstmt.setString(2, bbsContent);
				pstmt.setString(3, bbsStart);
				pstmt.setString(4, bbsTarget);
				pstmt.setString(5, bbsEnd);
				pstmt.setString(6, bbsNContent);
				pstmt.setString(7, bbsNStart);
				pstmt.setString(8, bbsNTarget);
				pstmt.setInt(9, bbsID);
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

		
		
		
		// 검색 메소드 
		public ArrayList<Bbs> getSearch(int pageNumber, String searchField, String searchText){//특정한 리스트를 받아서 반환
		      ArrayList<Bbs> list = new ArrayList<Bbs>();
		      String SQL ="select * from bbs WHERE "+searchField.trim();
		      try {
		            if(searchText != null && !searchText.equals("") ){
		                SQL +=" LIKE '%"+searchText.trim()+"%' order by bbsID desc limit ?,10";
		            }
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setInt(1, (pageNumber-1) * 10);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		            Bbs bbs = new Bbs();
					bbs.setBbsID(rs.getInt(1));
					bbs.setBbsTitle(rs.getString(2));
					bbs.setUserID(rs.getString(3));
					bbs.setUserName(rs.getString(4));
					bbs.setBbsDate(rs.getString(5));
					bbs.setBbsContent(rs.getString(6));
					bbs.setBbsStart(rs.getString(7));
					bbs.setBbsTarget(rs.getString(8));
					bbs.setBbsEnd(rs.getString(9));
					bbs.setBbsNContent(rs.getString(10));
					bbs.setBbsNStart(rs.getString(11));
					bbs.setBbsNTarget(rs.getString(12));
					bbs.setBbsAvailable(rs.getInt(13));
					bbs.setBbsDeadline(rs.getString(14));
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
							bbs.setBbsTitle(rs.getString(2));
							bbs.setUserID(rs.getString(3));
							bbs.setUserName(rs.getString(4));
							bbs.setBbsDate(rs.getString(5));
							bbs.setBbsContent(rs.getString(6));
							bbs.setBbsStart(rs.getString(7));
							bbs.setBbsTarget(rs.getString(8));
							bbs.setBbsEnd(rs.getString(9));
							bbs.setBbsNContent(rs.getString(10));
							bbs.setBbsNStart(rs.getString(11));
							bbs.setBbsNTarget(rs.getString(12));
							bbs.setBbsAvailable(rs.getInt(13));
							bbs.setBbsDeadline(rs.getString(14));
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
			String sql = "select bbsID from (select * from bbs where userID=?) bbs order by bbsDate desc";
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
					bbs.setBbsTitle(rs.getString(2));
					bbs.setUserID(rs.getString(3));
					bbs.setUserName(rs.getString(4));
					bbs.setBbsDate(rs.getString(5));
					bbs.setBbsContent(rs.getString(6));
					bbs.setBbsStart(rs.getString(7));
					bbs.setBbsTarget(rs.getString(8));
					bbs.setBbsEnd(rs.getString(9));
					bbs.setBbsNContent(rs.getString(10));
					bbs.setBbsNStart(rs.getString(11));
					bbs.setBbsNTarget(rs.getString(12));
					bbs.setBbsAvailable(rs.getInt(13));
					bbs.setBbsAvailable(rs.getInt(14));
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
}

