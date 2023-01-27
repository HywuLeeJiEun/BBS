package rmssumr;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RmssumrDAO {
	private Connection conn; //자바와 데이터베이스를 연결
	private PreparedStatement pstmt; //쿼리문 설정 및 실행
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public RmssumrDAO() {
		try {
			String dbURL = "jdbc:mariadb://localhost:3306/rms"; //연결할 DB
			String dbID = "root"; //DB 접속 ID
			String dbPassword = "7471350"; //DB 접속 password
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/*********** 기능 구현(메소드 구현) 영역 ***********/
	//RMSSUMR - 주간보고 요약본 작성하기(insert)
	public int SummaryWrite(String user_id, String rms_dl, String sum_con, String sum_pro, String sum_sta, String sum_end, String sum_div, String sum_sign, java.sql.Timestamp sum_time, String sum_updu ) {
		String sql = "insert into rmssumr values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id); //user_id
			pstmt.setString(2, rms_dl); //rms_dl(bbsDeadline)
			pstmt.setString(3, sum_con); //summary content (요약본 업무 내용)
			pstmt.setString(4, sum_pro); //summary progress (요약본 진행율)
			pstmt.setString(5, sum_sta); //summary state (요약본 상태)
			pstmt.setString(6, sum_end); //summary end (요약본 완료일/목표일)
			pstmt.setString(7, sum_div); //summary division (금주 차주 구분 T, N)
			pstmt.setString(8, sum_sign); //승인 상태
			pstmt.setTimestamp(13, sum_time); //작성 또는 수정 시간
			pstmt.setString(14, sum_updu); //작성 또는 수정한 사용자의 아이디
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
}
