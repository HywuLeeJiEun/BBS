package user;

public class User {

	private String id; //사원아이디
	private String password; //사원비밀번호
	private String name; //사원이름
	private String rank; //사원직급
	private String email; //사원메일
	private String manager; //담당업무
	private String authority; //권한
	private String pl; // part Leader
	private String pluser; // part Leader에 해당되는 user
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getRank() {
		return rank;
	}
	public void setRank(String rank) {
		this.rank = rank;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getManager() {
		return manager;
	}
	public void setManager(String manager) {
		this.manager = manager;
	}
	public String getAuthority() {
		return authority;
	}
	public void setAuthority(String authority) {
		this.authority = authority;
	}
	public String getPl() {
		return pl;
	}
	public void setPl(String pl) {
		this.pl = pl;
	}
	public String getPluser() {
		return pluser;
	}
	public void setPluser(String pluser) {
		this.pluser = pluser;
	}
	
	
	
	
	
	
	
	
}
