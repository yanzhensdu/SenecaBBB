<%@page import="sql.*"%>
<%@page import="java.util.*"%>
<%@page import="helper.*"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html" charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Seneca | Help: View Event Schedule</title>
<link rel="icon" href="http://www.cssreset.com/favicon.png">
<link rel="stylesheet" type="text/css" media="all" href="css/fonts.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/style.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.core.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.theme.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.datepicker.css">
<link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.selectmenu.css">
<link rel='stylesheet' type="text/css" href='fullcalendar-1.6.3/fullcalendar/fullcalendar.css'>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src='fullcalendar-1.6.3/fullcalendar/fullcalendar.js'></script>
<script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.core.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.widget.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.position.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.selectmenu.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.stepper.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.dataTable.js"></script>
<script type="text/javascript" src="js/componentController.js"></script>
<%
    //Start page validation
    String userId = usersession.getUserId();
    if (userId.equals("")) {
        response.sendRedirect("index.jsp?message=Please log in");
        return;
    }
    String message = request.getParameter("message");
    if (message == null) {
        message="";
    }
    //End page validation
%>
<script type="text/javascript">
/* TABLE */
$(screen).ready(function() {
    /* CURRENT EVENT */
    //$('#currentEvent').dataTable({"sPaginationType": "full_numbers"});
    //$('#currentEvent').dataTable({"aoColumnDefs": [{ "bSortable": false, "aTargets":[5]}], "bRetrieve": true, "bDestroy": true});
    //$('#tbAttendee').dataTable({"sPaginationType": "full_numbers"});
    //$('#tbAttendee').dataTable({"aoColumnDefs": [{ "bSortable": false, "aTargets":[5]}], "bRetrieve": true, "bDestroy": true});
    //$.fn.dataTableExt.sErrMode = 'throw';
    $('.dataTables_filter input').attr("placeholder", "Filter entries");
});
/* SELECT BOX */
$(function(){
    $('select').selectmenu();
});
$(document).ready(function() {
    //Hide some tables on load
});
</script>
</head>
<body>
<div id="page">
    <jsp:include page="header.jsp"/>
    <jsp:include page="menu.jsp"/>
    <section>
        <header> 
            <!-- BREADCRUMB -->
            <h1>Help Page: View Event</h1>
            <br />
            <!-- WARNING MESSAGES -->
            <div class="warningMessage"><%=message %></div>
        </header>
        <form action="persist_user_settings.jsp" method="post">
        <article>
            <div class="content">
                <fieldset>
                <hr />
                    <h2>What is the Event Schedule?</h2>
                    <ol>
                        <li>Every event belongs to an event schedule, even if the event occurs only once.</li>
                        <li>Event schedule is displayed in the first table, click on the DETAILS icon to see all events in the schedule.</li>
                        <li>Event schedule can be modified by its creator (meeting event) or the professor (lecture event).</li>
                        <li>A MODIFY icon will appear if you are eligible to edit the schedule.</li>
                    </ol>
                </fieldset>
            </div>
        </article>
        <article>
            <div class="content">
                <fieldset>
                <hr />
                    <h2>How can I add guest or presentation?</h2>
                    <ol>
                        <li>Only attendee/student belongs to the entire event schedule.</li>
                        <li>Guest and presentation are for individual event.
                        <li>Click the DETAILS icon in the Event List table to show an event in details and add guest or presentation there.</li>
                    </ol>
                </fieldset>
            </div>
        </article>
        </form>
    </section>
    <jsp:include page="footer.jsp"/>
</div>
</body>
</html>