package user;

import java.lang.reflect.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import bbs.Bbs;

public class UserDAO { //DAO : data access object
	
	private Connection conn; //자바와 데이터베이스를 연결
	private PreparedStatement pstmt; //쿼리문 설정 및 실행
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public UserDAO() {
		try {
			String dbURL = "jdbc:mariadb://localhost:3306/bbs"; //연결할 DB
			String dbID = "root"; //DB 접속 ID
			String dbPassword = "7471350"; //DB 접속 password
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	
	/*********** 기능 구현(메소드 구현) 영역 ***********/
	
	//로그인 영역
		public int login(String id, String password) {
			// DB에서 사용될 sql
			String sql = "select password from user where id = ?";
			try {
				pstmt = conn.prepareStatement(sql); //sql쿼리문을 대기
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery(); //쿼리를 실행한 결과를 rs에 저장
				if(rs.next()) {
					if(rs.getString(1).equals(password)) {
						return 1; //로그인 성공
					}else
						return 0; //비밀번호 틀림
				}
				return -1; //아이디 없음
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -2; //오류
		} // return값에 따른 결과 ( 1 - 성공, 0 - 틀림, -1 - 존재하지 않음. -2 - DB에러 )
		
		
		// 사용자 이름 출력을 위한 메소드
		public String getName(String id) {
			String sql = "select name from user where id = ?";
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
		
		
		// 사용자 담당업무 출력을 위한 메소드
		public String getManager(String code) {
			//String sql = "select manager from user where id = ?";
			String sql = "select work from jobs where code = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, code); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery();
				if(rs.next()) {
					if(rs.getString(1) == null) {
						return "";
					}
					return rs.getString(1);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return ""; //데이터베이스 오류
		}
		
		
		//manager를 나누어 code를 저장한다.
		public ArrayList<String> getCode(String id) {
			String sql = "select substring_index(manager, ',', 5) from user where id = ?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
				rs = pstmt.executeQuery();
				if(rs.next()) {
					if(rs.getString(1) == null) {
						return null;
					}
					String s = rs.getString(1);
					String[] codeArray = s.split(",");
					List<String> split = Arrays.asList(codeArray);
					ArrayList<String> list = new ArrayList<String>();
					
					list.addAll(split);
					return list;
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return null; //데이터베이스 오류
		}
}