<%@page import="db.DBConnection"%>
<%@page import="sql.User"%>
<%@page import="java.util.*"%>
<%@page import="helper.MyBoolean"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html" charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Departments</title>
<link rel="icon" href="http://www.cssreset.com/favicon.png">
<link rel="stylesheet" type="text/css" media="all" href="css/fonts.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/style.css">
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
<script type="text/javascript" src="js/componentController.js"></script>

<%
	//Start page validation
	String userId = usersession.getUserId();
	if (userId.equals("")) {
		response.sendRedirect("index.jsp?error=Please log in");
		return;
	}
	if (dbaccess.getFlagStatus() == false) {
		response.sendRedirect("index.jsp?error=Database connection error");
		return;
	} //End page validation
	
	String message = request.getParameter("message");
	if (message == null || message == "null") {
		message="";
	}
	
	User user = new User(dbaccess);
	MyBoolean prof = new MyBoolean();
	HashMap<String, Integer> userSettings = new HashMap<String, Integer>();
	HashMap<String, Integer> meetingSettings = new HashMap<String, Integer>();
	HashMap<String, Integer> roleMask = new HashMap<String, Integer>();
	userSettings = usersession.getUserSettingsMask();
	meetingSettings = usersession.getUserMeetingSettingsMask();
	roleMask = usersession.getRoleMask();
	int nickName = roleMask.get("nickname");
%>
</head>
<body>
<div id="page">
	<jsp:include page="header.jsp"/>
	<jsp:include page="menu.jsp"/>
	<section>
		<header> 
			<!-- BREADCRUMB -->
			<p><a href="calendar.jsp" tabindex="13">home</a> � <a href="departments.jsp" tabindex="14">departments</a> �<a href="create_departments.jsp" tabindex="15">create department</a></p>
			<!-- PAGE NAME -->
			<h1>Create Departments</h1>
			<!-- WARNING MESSAGES -->
			<div class="warningMessage"></div>
		</header>
		<form>
			<article>
				<header>
					<h2>Department Form</h2>
					<img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/>
				</header>
				<div class="content">
					<fieldset>
				        <div class="component">
				            <label for="DeptCode" class="label">Department Code:</label>
				            <input type="text" name="DeptCode" id="DeptCode" class="input" tabindex="2" title="Please Enter Department code">
				        </div>
				        <div class="component">
				            <label for="DeptName" class="label">Department Name:</label>
				            <input type="text" name="DeptName" id="DeptName" class="input" tabindex="3" title="Please Enter Department Name" >
				        </div>
				        <div class="component">
					        <div class="buttons">
	                           <button type="submit" name="saveDept" id="saveDept" class="button" title="Click here to save">Save</button>
	                        </div>
                        </div>
					</fieldset>
				</div>
			</article>
		</form>
	</section>
	<jsp:include page="footer.jsp"/>
</div>
</body>
</html>