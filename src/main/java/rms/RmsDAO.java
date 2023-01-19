package rms;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class RmsDAO {
	private Connection conn;
	private ResultSet rs;
	
	//기본 생성자
	public RmsDAO() {
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
	
	
	//작성일자(시간 추출) 메소드 - main, update
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
	
	
	//글쓰기 메소드 - main, bbsupdate (rms_this - 금주)
	public int write_rms_this(String id, String bbsDeadline,String bbsTitle, java.sql.Timestamp date,String bbsContent, String bbsStart, String bbsTarget, String bbsEnd) {
		String sql = "insert into rms_this values(?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			pstmt.setString(3, bbsTitle);
			pstmt.setTimestamp(4, date);
			pstmt.setString(5, bbsContent);
			pstmt.setString(6, bbsStart);
			pstmt.setString(7, bbsTarget);
			pstmt.setString(8, bbsEnd);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//글쓰기 메소드 - main, bbsupdate (rms_next - 차주)
	public int write_rms_next(String id, String bbsDeadline, String bbsNContent, String bbsNStart, String bbsNTarget, String pluser) {
		String sql = "insert into rms_next values(?, ?, ?, ?, ?, ?, ?)";
		String sign = "미승인";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			pstmt.setString(3, bbsNContent);
			pstmt.setString(4, bbsNStart);
			pstmt.setString(5, bbsNTarget);
			pstmt.setString(6, sign);
			pstmt.setString(7, pluser);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//글쓰기 메소드 - main, bbsupdate (rms_next - 차주)
	public int write_erp(String id, String bbsDeadline, String e_date, String e_user, String e_text, String e_authority, String e_division) {
		String sql = "insert into erp values(?,?,?,?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			pstmt.setString(3, e_date);
			pstmt.setString(4, e_user);
			pstmt.setString(5, e_text);
			pstmt.setString(6, e_authority);
			pstmt.setString(7, e_division);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
		
	// 같은 날짜에 보고된 주간보고가 있는지 확인 (bbsDeadline을 사용해 rms에 저장되어 있는지 확인)
	public String getOverlap(String bbsDeadline,String id) {
		String sql = "select bbsDeadline from rms_next where bbsDeadLine = ? and userID = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
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
	
	
	//게시글 삭제 메소드 (rms_this)
	public int tdelete(String id, String bbsDeadline) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rms_this where userID = ? and bbsDeadline = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	
	//게시글 삭제 메소드 (rms_next)
	public int ldelete(String id, String bbsDeadline) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rms_next where userID = ? and bbsDeadline = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	//게시글 삭제 메소드 (erp)
	public int edelete(String id, String bbsDeadline) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from erp where userID = ? and bbsDeadline = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	
	// 검색 메소드 this
	public ArrayList<rms_this> gettrms(String bbsDeadline, String id){//특정한 리스트를 받아서 반환
	      ArrayList<rms_this> list = new ArrayList<rms_this>();
	      String SQL ="select * from rms_this where bbsDeadline=? and userID=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, id);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_this rms = new rms_this();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsTitle(rs.getString(3));
	        	 rms.setBbsDate(rs.getString(4));
	        	 rms.setBbsContent(rs.getString(5));
	        	 rms.setBbsStart(rs.getString(6));
	        	 rms.setBbsTarget(rs.getString(7));
	        	 rms.setBbsEnd(rs.getString(8));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	// 검색 메소드 this
	public ArrayList<rms_next> getlrms(String bbsDeadline, String id){//특정한 리스트를 받아서 반환
	      ArrayList<rms_next> list = new ArrayList<rms_next>();
	      String SQL ="select * from rms_next where bbsDeadline=? and userID=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, id);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_next rms = new rms_next();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsNContent(rs.getString(3));
	        	 rms.setBbsNStart(rs.getString(4));
	        	 rms.setBbsNTarget(rs.getString(5));
	        	 rms.setSign(rs.getString(6));
	        	 rms.setPluser(rs.getString(7));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// 검색 메소드 erp
	public ArrayList<erp> geterp(String bbsDeadline, String id){//특정한 리스트를 받아서 반환
	      ArrayList<erp> list = new ArrayList<erp>();
	      String SQL ="select * from erp where bbsDeadline=? and userID=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, id);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 erp rms = new erp();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setE_date(rs.getString(3));
	        	 rms.setE_user(rs.getString(4));
	        	 rms.setE_text(rs.getString(5));
	        	 rms.setE_authority(rs.getString(6));
	        	 rms.setE_division(rs.getString(7));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	//가장 최근에 작성된 rms를 조회 (rms_this)
	public String getMaxbbsDeadline(String id) { 
		 String sql ="select bbsDeadline from rms_this where userID=? order by bbsDeadline desc";
		 try { PreparedStatement pstmt = conn.prepareStatement(sql);
		 	pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입 
		 	rs =pstmt.executeQuery(); 
		 	if(rs.next()) { return rs.getString(1); } 
		 }catch (Exception e) { 
		 e.printStackTrace(); } return ""; //데이터베이스 오류 
	 }
	
	
	// 메소드 this - bbs 조회용(목록보기)
	public ArrayList<rms_this> getthis(String id, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rms_this> list = new ArrayList<rms_this>();
	      String SQL =" select distinct bbsDeadline, bbsTitle, bbsDate from rms_this where userID=? order by BbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_this rms = new rms_this();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setBbsTitle(rs.getString(2));
	        	 rms.setBbsDate(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
		
	// 메소드 this - bbs 조회용(목록보기)
	public ArrayList<rms_next> getlast(String id, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rms_next> list = new ArrayList<rms_next>();
	      String SQL =" select distinct bbsDeadline, sign, pluser from rms_next where userID=? order by BbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_next rms = new rms_next();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setSign(rs.getString(2));
	        	 rms.setPluser(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// 메소드 this - bbs 조회용(목록보기) (sign) ## llist의 bbsDeadline을 결과로 받아와 찾음!
	public ArrayList<rms_this> getthisSign(String id, int pageNumber, String[] bbsDeadline){//특정한 리스트를 받아서 반환
	      ArrayList<rms_this> list = new ArrayList<rms_this>();
	      String SQL =" select distinct bbsDeadline, bbsTitle, bbsDate from rms_this where userID=? and ";
	      for(int i=0; i < bbsDeadline.length; i++) {
	    	  if(i < bbsDeadline.length-1) {
	    	  SQL += " bbsDeadline='"+bbsDeadline[i].trim()+"'"+" or ";
		      } else {
		    	  SQL += " bbsDeadline='"+bbsDeadline[i].trim()+"'";
		      }
      		}
	      		SQL += " order by BbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_this rms = new rms_this();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setBbsTitle(rs.getString(2));
	        	 rms.setBbsDate(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
		
	// 메소드 this - bbs 조회용(목록보기) (sign)
	public ArrayList<rms_next> getlastSign(String id, String sign, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rms_next> list = new ArrayList<rms_next>();
	      String SQL =" select distinct bbsDeadline, sign, pluser from rms_next where userID=? and sign=? order by BbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setString(2, sign);
	            pstmt.setInt(3, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_next rms = new rms_next();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setSign(rs.getString(2));
	        	 rms.setPluser(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// rms_next의 Sign을 변경함! ((제출 날짜가 지남!))
	public int lastSign(String id, String sign, String bbsDeadline) {
		String sql = " update rms_next set sign=? where userID=? and bbsDeadline=?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sign); 
			pstmt.setString(2, id); 
			pstmt.setString(3, bbsDeadline); 
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}
	
	
	// 검색 메소드 this - bbs 조회용(목록보기)
	public ArrayList<rms_this> getthisSearch(int pageNumber, String id, String searchField, String searchText){//특정한 리스트를 받아서 반환
	      ArrayList<rms_this> list = new ArrayList<rms_this>();
	      String SQL =" select distinct bbsDeadline, bbsTitle, bbsDate from (select * from rms_this where userID=?) a"
	    		  +" where "+searchField.trim();
	      try {
	    	  	if(searchText != null && !searchText.equals("")) {
	    	  		SQL += " like '%"+searchText.trim()+"%' order by BbsDeadline desc limit ?,10";
	    	  	} else {
	    	  		SQL += " like '%---%' order by BbsDeadline desc limit ?,10";
	    	  	}
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_this rms = new rms_this();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setBbsTitle(rs.getString(2));
	        	 rms.setBbsDate(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// 검색 메소드 last - bbs 조회용(목록보기)   => this의 bbsDeadline을 통해 조회 
	public ArrayList<rms_next> getlastSearch(int pageNumber, String id, String[] bbsDeadline){//특정한 리스트를 받아서 반환
	      ArrayList<rms_next> list = new ArrayList<rms_next>();
	      String SQL =" select distinct bbsDeadline, sign, pluser from (select * from rms_next where userID=?) a where ";
	      for(int i=0; i < bbsDeadline.length; i++) {
	    	  if(i < bbsDeadline.length-1) {
	    	  SQL += " bbsDeadline='"+bbsDeadline[i].trim()+"'"+" or ";
		      } else {
		    	  SQL += " bbsDeadline='"+bbsDeadline[i].trim()+"'";
		      }
      		}
	      SQL += "order by BbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_next rms = new rms_next();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setSign(rs.getString(2));
	        	 rms.setPluser(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	//게시글 수정 메소드 (rms_this)
	public int update_trms(String userID, String bbsDeadline, String bbsTitle, java.sql.Timestamp date, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, int num) {
		String sql = "update rms_this set bbsTitle=?, bbsDate=?, bbsContent=?, bbsStart=?, bbsTarget=?, bbsEnd=? where userID=? and bbsDeadline=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsTitle);
			pstmt.setTimestamp(2, date);
			pstmt.setString(3, bbsContent);
			pstmt.setString(4, bbsStart);
			pstmt.setString(5, bbsTarget);
			pstmt.setString(6, bbsEnd);
			pstmt.setString(7, userID);
            pstmt.setString(8, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//게시글 수정 메소드 (rms_next)
	public int update_lrms(String userID, String bbsDeadline, String bbsContent, String bbsStart, String bbsTarget) {
		String sql = "update rms_next set bbsNContent=?, bbsNStart=?, bbsNTarget=? where userID=? and bbsDeadline=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsContent);
			pstmt.setString(2, bbsStart);
			pstmt.setString(3, bbsTarget);
			pstmt.setString(4, userID);
			pstmt.setString(5, bbsDeadline);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	// 메소드 this - bbsRk 조회용(목록보기) (sign) ## llist의 bbsDeadline을 결과로 받아와 찾음!
	public ArrayList<rms_this> getthisSignRk(String bbsDeadline, int pageNumber, String[] userID){//특정한 리스트를 받아서 반환
	      ArrayList<rms_this> list = new ArrayList<rms_this>();
	      String SQL =" select distinct r.bbsDeadline, r.bbsTitle, r.bbsDate from (select * from rms_this where bbsDeadline = ?) r where ";
	      for(int i=0; i < userID.length; i++) {
	    	  if(i < userID.length-1) {
	    	  SQL += " r.userID='"+userID[i].trim()+"'"+" or ";
		      } else {
		    	  SQL += " r.userID='"+userID[i].trim()+"'";
		      }
      		}
	      		SQL += " order by r.bbsDate desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms_this rms = new rms_this();
	        	 rms.setBbsDeadline(rs.getString(1));
	        	 rms.setBbsTitle(rs.getString(2));
	        	 rms.setBbsDate(rs.getString(3));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
			
		// 메소드 this - bbsRk 조회용(목록보기) (sign) //pl의 모든 인원 (승인, 마감된 ...)
		public ArrayList<rms_next> getlastSignRk(String bbsDeadline, String pluser, int pageNumber){//특정한 리스트를 받아서 반환
		      ArrayList<rms_next> list = new ArrayList<rms_next>();
		      String SQL ="select distinct r.userID, r.sign, r.pluser "
		      		+ "from (select * from rms_next where bbsDeadline=?) r "
		      		+ "where r.sign='승인' or r.sign='마감' "
		      		+ "and r.pluser=? "
		      		+ "order by r.BbsDeadline desc limit ?,10";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, bbsDeadline);
		            pstmt.setString(2, pluser);
		            pstmt.setInt(3, (pageNumber-1) * 10);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms_next rms = new rms_next();
		        	 rms.setUserID(rs.getString(1));
		        	 rms.setSign(rs.getString(2));
		        	 rms.setPluser(rs.getString(3));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
		// 메소드 this - bbsRk 조회용(목록보기) (sign) //pl의 모든 인원 (승인, 마감된 ...)
		public ArrayList<rms_next> getlastSignRkfull(String bbsDeadline, String pluser){//특정한 리스트를 받아서 반환
		      ArrayList<rms_next> list = new ArrayList<rms_next>();
		      String SQL =" select distinct r.userID, r.sign, r.pluser from (select * from rms_next where bbsDeadline=?) r where r.sign='승인' or r.sign='마감' and r.pluser=? order by r.BbsDeadline desc";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, bbsDeadline);
		            pstmt.setString(2, pluser);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms_next rms = new rms_next();
		        	 rms.setUserID(rs.getString(1));
		        	 rms.setSign(rs.getString(2));
		        	 rms.setPluser(rs.getString(3));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
		
		// 메소드 this - bbsRk 조회용(목록보기) (sign) //pl의 모든 인원 (승인, 마감된 ...)
		public ArrayList<rms_next> getlastSignRkfullSelect(String bbsDeadline, String pluser){//특정한 리스트를 받아서 반환
		      ArrayList<rms_next> list = new ArrayList<rms_next>();
		      String SQL =" select * from (select * from rms_next where bbsDeadline=?) r where r.sign='승인' or r.sign='마감' and r.pluser=? order by r.BbsDeadline desc";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, bbsDeadline);
		            pstmt.setString(2, pluser);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms_next rms = new rms_next();
		        	 rms.setUserID(rs.getString(1));
		        	 rms.setBbsDeadline(rs.getString(2));
		        	 rms.setBbsNContent(rs.getString(3));
		        	 rms.setBbsNStart(rs.getString(4));
		        	 rms.setBbsNTarget(rs.getString(5));
		        	 rms.setSign(rs.getString(6));
		        	 rms.setPluser(rs.getString(7));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
		
		// 메소드 this - bbsRk 조회용(목록보기) (sign) ## llist의 bbsDeadline을 결과로 받아와 찾음!
		public ArrayList<rms_this> getthisSignRkfullSelect(String bbsDeadline, String[] userID){//특정한 리스트를 받아서 반환
		      ArrayList<rms_this> list = new ArrayList<rms_this>();
		      String SQL =" select * from rms_this where bbsDeadline=? and ";
		      for(int i=0; i < userID.length; i++) {
		    	  if(i < userID.length-1) {
		    	  SQL += " userID='"+userID[i].trim()+"'"+" or ";
			      } else {
			    	  SQL += " userID='"+userID[i].trim()+"'";
			      }
	      		}
		      		SQL += " order by bbsDate desc";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, bbsDeadline);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms_this rms = new rms_this();
		        	 rms.setUserID(rs.getString(1));
		        	 rms.setBbsDeadline(rs.getString(2));
		        	 rms.setBbsTitle(rs.getString(3));
		        	 rms.setBbsDate(rs.getString(4));
		        	 rms.setBbsContent(rs.getString(5));
		        	 rms.setBbsStart(rs.getString(6));
		        	 rms.setBbsTarget(rs.getString(7));
		        	 rms.setBbsEnd(rs.getString(8));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
		
		// 메소드 this - bbsRk의 bbsDeadline 선택용 (목록보기) (sign) //distinct, 승인 or 마감
		public ArrayList<rms_next> getNextbbsDeadline(String pluser){//특정한 리스트를 받아서 반환
		      ArrayList<rms_next> list = new ArrayList<rms_next>();
		      String SQL =" select distinct bbsDeadline from rms_next where sign='승인' or sign='마감' and pluser=? order by bbsDeadline";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, pluser);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms_next rms = new rms_next();
		        	 rms.setBbsDeadline(rs.getString(1));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
	
		
	// rms에 저장이 되어 있는지 확인
	public int getRms(String bbsDeadline, String userID) {
		String sql = "select bbsDeadline from rms where bbsDeadline=? and userID=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,  bbsDeadline);
			pstmt.setString(2,  userID);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				if(rs.getString(1) != null || !rs.getString(1).isEmpty()) {
					return 1;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0; //작성된 기록이 없음!
	}
	
	
	//글쓰기 메소드 - RMS (본체)
	public int rmswrite(String userID, String bbsDeadline, String bbsTitle, String bbsDate, String bbsManager, String bbsContent, String bbsStart, String bbsTarget, String bbsEnd, String bbsNContent, String bbsNStart, String bbsNTarget, String pluser) {
		String sql = "insert into rms values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userID);
			pstmt.setString(2, bbsDeadline);
			pstmt.setString(3, bbsTitle);
			pstmt.setString(4, bbsDate);
			pstmt.setString(5, bbsManager);
			pstmt.setString(6, bbsContent);
			pstmt.setString(7, bbsStart);
			pstmt.setString(8, bbsTarget);
			pstmt.setString(9, bbsEnd);
			pstmt.setString(10, bbsNContent);
			pstmt.setString(11, bbsNStart);
			pstmt.setString(12, bbsNTarget);
			pstmt.setString(13, pluser);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	// 메소드 this - bbsRk의 bbsDeadline 선택용 (목록보기) (sign) //distinct, 승인 or 마감
	public ArrayList<rms> getRmsAll(String bbsDeadline, String userID){//특정한 리스트를 받아서 반환
	      ArrayList<rms> list = new ArrayList<rms>();
	      String SQL ="select * from (select * from rms where bbsDeadline=?) r where r.userID=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, userID);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms rms = new rms();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsTitle(rs.getString(3));
	        	 rms.setBbsDate(rs.getString(4));
	        	 rms.setBbsManager(rs.getString(5));
	        	 rms.setBbsContent(rs.getString(6));
	        	 rms.setBbsStart(rs.getString(7));
	        	 rms.setBbsTarget(rs.getString(8));
	        	 rms.setBbsEnd(rs.getString(9));
	        	 rms.setBbsNContent(rs.getString(10));
	        	 rms.setBbsNStart(rs.getString(11));
	        	 rms.setBbsNTarget(rs.getString(12));
	        	 rms.setPluser(rs.getString(13));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// 메소드 this - rms 테이블의 limit
	public ArrayList<rms> getRmsRk(String bbsDeadline, String pluser, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rms> list = new ArrayList<rms>();
	      String SQL ="select * from (select * from rms where bbsDeadline=?) r where r.pluser=? limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, pluser);
	            pstmt.setInt(3, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms rms = new rms();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsTitle(rs.getString(3));
	        	 rms.setBbsDate(rs.getString(4));
	        	 rms.setBbsManager(rs.getString(5));
	        	 rms.setBbsContent(rs.getString(6));
	        	 rms.setBbsStart(rs.getString(7));
	        	 rms.setBbsTarget(rs.getString(8));
	        	 rms.setBbsEnd(rs.getString(9));
	        	 rms.setBbsNContent(rs.getString(10));
	        	 rms.setBbsNStart(rs.getString(11));
	        	 rms.setBbsNTarget(rs.getString(12));
	        	 rms.setPluser(rs.getString(13));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	}
	
	
	// 메소드 this - rms 테이블의 limit
	public ArrayList<rms> getRmsRkfull(String bbsDeadline, String pluser){//특정한 리스트를 받아서 반환
	      ArrayList<rms> list = new ArrayList<rms>();
	      String SQL ="select * from (select * from rms where bbsDeadline=?) r where r.pluser=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, bbsDeadline);
	            pstmt.setString(2, pluser);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms rms = new rms();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsTitle(rs.getString(3));
	        	 rms.setBbsDate(rs.getString(4));
	        	 rms.setBbsManager(rs.getString(5));
	        	 rms.setBbsContent(rs.getString(6));
	        	 rms.setBbsStart(rs.getString(7));
	        	 rms.setBbsTarget(rs.getString(8));
	        	 rms.setBbsEnd(rs.getString(9));
	        	 rms.setBbsNContent(rs.getString(10));
	        	 rms.setBbsNStart(rs.getString(11));
	        	 rms.setBbsNTarget(rs.getString(12));
	        	 rms.setPluser(rs.getString(13));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	}
	
	
	// rms_next -> bbsRkwrite에 sign 확인하기 (수정 확인용)
	public String getSignNext(String bbsDeadline) {
		String sql = " select distinct sign from rms_next where bbsDeadline=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, bbsDeadline); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	// rms -> bbsAdmin.jsp 조회
	public ArrayList<rms> getRmsAdmin(int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rms> list = new ArrayList<rms>();
	      String SQL =" select * from rms order by bbsDeadline desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setInt(1, (pageNumber-1)*10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rms rms = new rms();
	        	 rms.setUserID(rs.getString(1));
	        	 rms.setBbsDeadline(rs.getString(2));
	        	 rms.setBbsTitle(rs.getString(3));
	        	 rms.setBbsDate(rs.getString(4));
	        	 rms.setBbsManager(rs.getString(5));
	        	 rms.setBbsContent(rs.getString(6));
	        	 rms.setBbsStart(rs.getString(7));
	        	 rms.setBbsTarget(rs.getString(8));
	        	 rms.setBbsEnd(rs.getString(9));
	        	 rms.setBbsNContent(rs.getString(10));
	        	 rms.setBbsNStart(rs.getString(11));
	        	 rms.setBbsNTarget(rs.getString(12));
	        	 rms.setPluser(rs.getString(13));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	}

	
	// rms -> bbsAdmin.jsp 조회 (search)
		public ArrayList<rms> getRmsAdminSearch(int pageNumber, String searchField, String searchText){//특정한 리스트를 받아서 반환
		      ArrayList<rms> list = new ArrayList<rms>();
		      String SQL =" select * from rms where "+searchField.trim()+" like '%"+searchText.trim()+"%' order by bbsDeadline desc limit ?,10";
		      try {
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setInt(1, (pageNumber-1)*10);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rms rms = new rms();
		        	 rms.setUserID(rs.getString(1));
		        	 rms.setBbsDeadline(rs.getString(2));
		        	 rms.setBbsTitle(rs.getString(3));
		        	 rms.setBbsDate(rs.getString(4));
		        	 rms.setBbsManager(rs.getString(5));
		        	 rms.setBbsContent(rs.getString(6));
		        	 rms.setBbsStart(rs.getString(7));
		        	 rms.setBbsTarget(rs.getString(8));
		        	 rms.setBbsEnd(rs.getString(9));
		        	 rms.setBbsNContent(rs.getString(10));
		        	 rms.setBbsNStart(rs.getString(11));
		        	 rms.setBbsNTarget(rs.getString(12));
		        	 rms.setPluser(rs.getString(13));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		}
}
