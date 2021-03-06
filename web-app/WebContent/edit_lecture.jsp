<%@page import="db.DBConnection"%>
<%@page import="sql.*"%>
<%@page import="java.util.*"%>
<%@page import="helper.*"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SenecaBBB | Edit Lecture</title>
    <link rel="shortcut icon" href="http://www.senecacollege.ca/favicon.ico">
    <link rel="stylesheet" type="text/css" media="all" href="css/fonts.css">
    <link rel="stylesheet" type="text/css" media="all" href="css/themes/base/style.css">
    <link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.core.css">
    <link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.theme.css">
    <link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.timepicker.css">
    <link rel="stylesheet" type="text/css" media="all" href="css/themes/base/jquery.ui.selectmenu.css">
    <script type="text/javascript" src="js/jquery-1.9.1.js"></script>
    <script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
    <script type="text/javascript" src="js/ui/jquery.ui.core.js"></script>
    <script type="text/javascript" src="js/ui/jquery.ui.widget.js"></script>
    <script type="text/javascript" src="js/ui/jquery.ui.position.js"></script>
    <script type="text/javascript" src="js/ui/jquery.ui.selectmenu.js"></script>
    <script type="text/javascript" src="js/ui/jquery.timepicker.js"></script>
    <script type="text/javascript" src="js/ui/jquery.ui.stepper.js"></script>
    <script type="text/javascript" src="js/jquery.validate.min.js"></script>
    <script type="text/javascript" src="js/additional-methods.min.js"></script>
    <script type="text/javascript" src="js/checkboxController.js"></script>
    <script type="text/javascript" src="js/moment.js"></script>

    <%
    //Start page validation
    String userId = usersession.getUserId();
    GetExceptionLog elog = new GetExceptionLog();
    if (userId.equals("")) {
        session.setAttribute("redirecturl",request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : ""));
        response.sendRedirect("index.jsp?message=Please log in");
        return;
    }
    String message = request.getParameter("message");
    String successMessage = request.getParameter("successMessage");
    if (message == null || message == "null") {
        message = "";
    }
    if (successMessage == null) {
        successMessage = "";
    }
    String l_id = request.getParameter("l_id");
    String ls_id = request.getParameter("ls_id");
    if (l_id == null || ls_id == null) {
        elog.writeLog("[edit_lecture:] " + "null l_id or ls_id /n");
        response.sendRedirect("calendar.jsp?message=Please do not mess with the URL");
        return;
    }
    l_id = Validation.prepare(l_id);
    ls_id = Validation.prepare(ls_id);
    if (!(Validation.checkLId(l_id) && Validation.checkLsId(ls_id))) {
        elog.writeLog("[edit_lecture:] " + Validation.getErrMsg() + " /n");
        response.sendRedirect("calendar.jsp?message=" + Validation.getErrMsg());
        return;
    }
    User user = new User(dbaccess);
    Lecture lecture = new Lecture(dbaccess);
    MyBoolean myBool = new MyBoolean();
    if (!lecture.isLecture(myBool, ls_id, l_id)) {
        message = lecture.getErrMsg("EL01");
        elog.writeLog("[edit_lecture:] " + message + " /n");
        response.sendRedirect("logout.jsp?message=" + message);
        return;
    }
    if (!myBool.get_value()) {
        elog.writeLog("[edit_lecture:] " + "username: " + userId + "tried to access this page,permission denied" + " /n");
        response.sendRedirect("calendar.jsp?message=You do not permission to access that page");
        return;
    }
    if (!user.isTeaching(myBool, ls_id, userId)) {
        message = user.getErrMsg("EL02");
        elog.writeLog("[edit_lecture:] " + message + " /n");
        response.sendRedirect("logout.jsp?message=" + message);
        return;
    }
    if (!myBool.get_value()) {
        if (!user.isGuestTeaching(myBool, ls_id, l_id, userId)) {
            message = user.getErrMsg("EL03");
            elog.writeLog("[edit_lecture:] " + message + " /n");
            response.sendRedirect("logout.jsp?message=" + message);
            return;
        }
        if (!myBool.get_value()) {
            elog.writeLog("[edit_lecture:] " + "username: " + userId + "tried to access this page,permission denied" + " /n");
            response.sendRedirect("calendar.jsp?message=You do not permission to access that page");
            return;
        }
    }
    // End page validation
    ArrayList<HashMap<String, String>> eventSchedule = new ArrayList<HashMap<String, String>>();
    if (!lecture.getLectureScheduleInfo(eventSchedule, ls_id)) {
        message = lecture.getErrMsg("EL10");
        elog.writeLog("[edit_lecture:] " + message + " /n");
        response.sendRedirect("logout.jsp?message=" + message);
        return;
    }
    boolean edited = false;
    boolean editError = false;
    String startTime = request.getParameter("startUTCDateTime");
    if (startTime != null) {
        if (!lecture.updateLectureTime(1, ls_id, l_id, startTime)) {
            message += user.getErrMsg("EL04");
            elog.writeLog("[edit_lecture:] " + message + " /n");
            response.sendRedirect("logout.jsp?message=" + message);
            return;
        } else {
            edited = true;
        }
    }

    String duration = request.getParameter("eventDuration");
    if (duration != null) {
        if (!Validation.checkDuration(duration)) {
            message += "<br />" + Validation.getErrMsg();
            editError = true;
        } else {
            if (!lecture.updateLectureDuration(1, ls_id, l_id, duration)) {
                message += user.getErrMsg("EL05");
                elog.writeLog("[edit_lecture:] " + message + " /n");
                response.sendRedirect("logout.jsp?message=" + message);
                return;
            } else {
                edited = true;
            }
        }
    }

    String description = request.getParameter("description");
    if (description != null) {
        if (!Validation.checkDescription(description)) {
            message += "<br />" + Validation.getErrMsg();
            editError = false;
        } else {
            if (!lecture.setLectureDescription(ls_id, l_id, description)) {
                message += user.getErrMsg("EL06");
                elog.writeLog("[edit_lecture:] " + message + " /n");
                response.sendRedirect("logout.jsp?message=" + message);
                return;
            } else {
                edited = true;
            }
        }
    }

    if (edited) {
        String cancelEvent = request.getParameter("cancelEventBox");
        if (cancelEvent != null) {
            if (!lecture.setLectureIsCancel(ls_id, l_id, true)) {
                message += user.getErrMsg("EL07");
                elog.writeLog("[edit_lecture:] " + message + " /n");
                response.sendRedirect("logout.jsp?message=" + message);
                return;
            }
        } else {
            if (!lecture.setLectureIsCancel(ls_id, l_id, false)) {
                message += user.getErrMsg("EL08");
                elog.writeLog("[edit_lecture:] " + message + " /n");
                response.sendRedirect("logout.jsp?message=" + message);
                return;
            }
        }
    }

    if (edited) {
        String allowRecording = request.getParameter("allowRecording");
        HashMap<String, Integer> map = new HashMap<String, Integer>();
        if (allowRecording == null) {
            map.put(Settings.meeting_setting[0], 0);
        } else {
            map.put(Settings.meeting_setting[0], 1);
        }
        map.put(Settings.meeting_setting[1], 0);
        map.put(Settings.meeting_setting[2], 0);
        map.put(Settings.meeting_setting[3], 0);
        map.put(Settings.meeting_setting[4], 0);
        if (!lecture.setLectureSetting(map,eventSchedule.get(0).get("c_id"), eventSchedule.get(0).get("sc_id"),eventSchedule.get(0).get("sc_semesterid"))) {
            response.sendRedirect("logout.jsp?message=Fail to change lecture setting");
            return;
        }
    }

    if (edited && !editError) {
        successMessage = "Event Details Updated";
        response.sendRedirect("view_event.jsp?ls_id=" + ls_id + "&l_id=" + l_id + "&successMessage=" + successMessage);
        return;
    }

    ArrayList<HashMap<String, String>> event = new ArrayList<HashMap<String, String>>();
    if (!lecture.getLectureInfo(event, ls_id, l_id)) {
        message = lecture.getErrMsg("EL09");
        elog.writeLog("[edit_lecture:] " + message + " /n");
        response.sendRedirect("logout.jsp?message=" + message);
        return;
    }
    HashMap<String, Integer> isRecordedResult = new HashMap<String, Integer>();
    lecture.getLectureSetting(isRecordedResult, eventSchedule.get(0).get("c_id"), eventSchedule.get(0).get("sc_id"),eventSchedule.get(0).get("sc_semesterid"));
    boolean check1 = event.get(0).get("l_iscancel").equals("1") ? true : false;
    %>

    <script type="text/javascript">
        /* TABLE */
        $(screen).ready(function() {
            $('#startTime').timepicker({ 'scrollDefaultNow': true });   
            <%if (isRecordedResult.get("isRecorded")==0){%>
            $(".checkbox .box:eq(0)").next(".checkmark").toggle();
            $(".checkbox .box:eq(0)").attr("aria-checked", "false");
            $(".checkbox .box:eq(0)").siblings().last().prop("checked", false);
            <%}%>
            
           <%if (!check1){%>
            $(".checkbox .box:eq(1)").next(".checkmark").toggle();
            $(".checkbox .box:eq(1)").attr("aria-checked", "false");
            $(".checkbox .box:eq(1)").siblings().last().prop("checked", false);
            <%}%>
            
            //convert utc time to local time and display it
            var utcStartDateTime = "<%= event.get(0).get("l_inidatetime").substring(0, 19) %>";
            function toLocalTime(utcTime){
                var startMoment = moment.utc(utcTime).local().format("YYYY-MM-DD HH:mm:SS");
                return startMoment;
            }  
            var localCurrentEventStartDateTime = toLocalTime(utcStartDateTime);
            $("#startDate").text(localCurrentEventStartDateTime.substring(0,10));
            $("#startTime").val(localCurrentEventStartDateTime.substring(11,19));
        });
        /* SELECT BOX */
        $(function(){
            $('select').selectmenu();
        });
        
        function toUTC(){
            var startDate = $("#startDate").text();
            var startTime = $("#startTime").val();
            var utcdayTime = moment(startDate + " " + startTime).utc();
            var currentUTCTime = moment.utc();
            if(utcdayTime.isBefore(currentUTCTime)){
                $(".warningMessage").text("Event Start Time must be later than current time!");
                 var notyMsg = noty({text: '<div>'+ $(".warningMessage").text()+' <img  class="notyCloseButton" src="css/themes/base/images/x.png" alt="close" /></div>',
                 layout:'top',
                 type:'error'});
                return false;
            }else{
                var uctdatetimestring = utcdayTime.format("YYYY-MM-DD HH:mm:SS");
                $("#startUTCDateTime").val(uctdatetimestring);
                return true;
            }
        }
    </script>
</head>

<body>
    <div id="page">
        <jsp:include page="header.jsp"/>
        <jsp:include page="menu.jsp"/>
        <section>
            <header> 
                <!-- BREADCRUMB -->
                <p>
                    <a href="calendar.jsp" tabindex="13">home</a> � 
                    <a href="view_event.jsp?ls_id=<%= ls_id %>&l_id=<%= l_id %>" tabindex="14">view_event</a> � 
                    <a href="edit_lecture.jsp?ls_id=<%= ls_id %>&l_id=<%= l_id %>" tabindex="15">edit_event</a>
                </p>
                <!-- PAGE NAME -->
                <h1>Lecture Event</h1>
                <br />
                <!-- MESSAGES -->
                <div class="warningMessage"><%=message %></div>
                <div class="successMessage"><%=successMessage %></div> 
            </header>
            <form name="EditLecture" id="EditLecture" method="get" action="edit_lecture.jsp" onsubmit="return toUTC()">
                <article>
                    <header>
                        <h2>Current Event</h2>
                    </header>
                    <div class="content">
                        <fieldset>
                            <div id="currentEventDiv" class="tableComponent">
                                <table id="tbEvent" border="0" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th class="firstColumn" tabindex="16" title="Course">Course<span></span></th>
                                            <th title="Section">Section<span></span></th>
                                            <th title="Semester">Semester<span></span></th>
                                            <th title="Date">Date<span></span></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td class="row"><%= eventSchedule.get(0).get("c_id") %></td>
                                            <td><%= eventSchedule.get(0).get("sc_id") %></td>
                                            <td><%= eventSchedule.get(0).get("sc_semesterid") %></td>
                                            <td id="startDate"><%= event.get(0).get("l_inidatetime").substring(0, 10) %></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </fieldset>
                    </div>
                </article>
                <article>
                    <header>
                        <h2>Edit Form</h2>
                        <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/>
                    </header>
                    <div class="content">
                        <fieldset>
                            <input type="hidden" name="ls_id" id="ls_id" value="<%= ls_id %>">
                            <input type="hidden" name="l_id" id="l_id" value="<%= l_id %>">  
                            <div class="component" >
                                <label for="startTime" class="label">Start Time:</label> 
                                <input name="startUTCDateTime" id="startUTCDateTime" hidden="hidden" value=""/>
                                <input id="startTime" name="startTime"  type="text"  class="input"  value="<%= event.get(0).get("l_inidatetime").substring(11, 19) %>" tabindex="24" title="Start Time" placeholder="pick start time"/> 
                            </div>
                            <div class="component" >
                                <label for="eventDuration" class="label">Duration:</label>
                                <input id="eventDuration" name="eventDuration"  type="number"  class="input"  tabindex="25" title="Event Duration"  value="<%= event.get(0).get("l_duration") %>" placeholder="minutes" required/>
                            </div>
                            <div class="component" >
                                <label for="description" class="label">Description:</label>
                                <input name="description" id="description" class="input" cols="35" rows="5" title="Description" value="<%= event.get(0).get("l_description") %>"/>
                            </div>
                            <div class="component">
                                <div class="checkbox" title="Allow event recording"> <span class="box" role="checkbox" aria-checked="true" tabindex="21" aria-labelledby="eventSetting4"></span>
                                    <label class="checkmark"></label>
                                    <label class="text" id="allowRecording">Allow Lecture recording</label>
                                    <input type="checkbox" name="allowRecording" checked="checked">
                                </div>
                            </div>
                            <div class="component">
                                <div class="checkbox" title="Cancel Lecture"> <span class="box" role="checkbox" aria-checked="true" tabindex="22" aria-labelledby="eventSetting5"></span>
                                    <label class="checkmark"></label>
                                    <label class="text" id="cancelEventBox">Cancel Lecture</label>
                                    <input type="checkbox" name="cancelEventBox" checked="checked">
                                </div>
                            </div>
                            <div class="component">
                                <div class="buttons">
                                   <button type="submit" class="button" title="Click here to save">Save</button>
                                   <button type="reset" class="button" title="Click here to reset">Reset</button>
                                   <button type="button" class="button" title="Click here to cancel" 
                                    onclick="window.location.href='view_event.jsp?ls_id=<%= ls_id %>&l_id=<%= l_id %>'">Cancel</button>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </article>
            </form>
        </section>
        
        <script>
        // form validation, edit the regular expression pattern and error messages to meet your needs
            jQuery.validator.addMethod("timeFormat", function(value, element) {
                return this.optional(element) || /^\s*(?:(?!24:00:00).)*\s*$/.test(value);
            });
            $(document).ready(function(){
                 $('#EditLecture').validate({
                     validateOnBlur : true,
                     rules: {
                         description:{
                            required: false,
                            maxlength: 100,
                            pattern: /^[^<>]+$/
                        },
                        startTime:{
                            required: true,
                            pattern: /^\s*[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\s*$/,
                            timeFormat:true
                        },
                        eventDuration:{
                            required: true,
                            range:[1,999]                  
                        },
                        
                     },
                     messages: {
                         startTime:{
                             pattern:"Please enter a valid Time Format",
                             required:"Start time is required",
                             timeFormat:"Accept 00:00:00 ~ 23:59:59 only"
                         },
                         eventDuration:"Please enter a valid Number",
                         description:"Invalid characters"
                     }
                 });
               
             });
        </script>
        <jsp:include page="footer.jsp"/>
    </div>
</body>
</html>