/*
  V 0.2
  all column name that has a '_is' part is binary and uses BIT(1) for column type
  this script uses table 'bbb_admin' to generate primary keys for tables:
        user_role
        meeting
        meeting_schedule
        lecture
        lecture_schedule
  -Bo Li
*/

DROP TABLE IF EXISTS lecture_attendance CASCADE;
DROP TABLE IF EXISTS guest_lecturer CASCADE;
DROP TABLE IF EXISTS lecture_presentation CASCADE;
DROP TABLE IF EXISTS lecture CASCADE;
DROP TABLE IF EXISTS lecture_schedule CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS section CASCADE;
DROP TABLE IF EXISTS subject CASCADE;
DROP TABLE IF EXISTS meeting_attendance CASCADE;
DROP TABLE IF EXISTS meeting_attendee CASCADE;
DROP TABLE IF EXISTS meeting_guest CASCADE;
DROP TABLE IF EXISTS meeting_presentation CASCADE;
DROP TABLE IF EXISTS meeting CASCADE;
DROP TABLE IF EXISTS non_ldap_user CASCADE;
DROP TABLE IF EXISTS meeting_schedule CASCADE;
DROP TABLE IF EXISTS user_department CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS bbb_user CASCADE;
DROP TABLE IF EXISTS user_role CASCADE;
DROP TABLE IF EXISTS bbb_admin CASCADE;
DROP TABLE IF EXISTS predefined_role CASCADE;

CREATE TABLE predefined_role (
  pr_name         VARCHAR(100) NOT NULL,
  pr_defaultmask  BIT(10) NOT NULL,
  CONSTRAINT pk_predefined_role
    PRIMARY KEY (pr_name)
);

# admin is future keyword, using bbb_admin instead
CREATE TABLE bbb_admin (
  row_num         TINYINT,
  next_m_id       MEDIUMINT UNSIGNED,
  next_ms_id      MEDIUMINT UNSIGNED,
  next_l_id       MEDIUMINT UNSIGNED,
  next_ls_id      MEDIUMINT UNSIGNED,
  next_ur_id      MEDIUMINT UNSIGNED,
  next_d_id       MEDIUMINT UNSIGNED,
  timeout         MEDIUMINT UNSIGNED,
  CONSTRAINT pk_bbb_admin
    PRIMARY KEY (row_num)
);

CREATE TABLE user_role (
  ur_id           MEDIUMINT UNSIGNED,
  pr_name         VARCHAR(100) NOT NULL,
  ur_rolemask     BIT(10) NOT NULL,
  CONSTRAINT pk_user_role 
    PRIMARY KEY (ur_id),
  CONSTRAINT fk_predefined_role_of_user_role
    FOREIGN KEY (pr_name)
	REFERENCES predefined_role (pr_name)
    ON DELETE CASCADE
    ON UPDATE CASCADE

);

# user is keyword, using bbb_user instead
CREATE TABLE bbb_user ( 
  bu_id           VARCHAR(100),
  bu_nick         VARCHAR(100) NOT NULL,
  bu_isbanned     BIT(1) NOT NULL,
  bu_isactive     BIT(1) NOT NULL,
  bu_comment      VARCHAR(2000),
  bu_lastlogin    DATETIME,
  bu_isldap       BIT(1) NOT NULL,
  bu_issuper      BIT(1) NOT NULL,
  ur_id           MEDIUMINT UNSIGNED,
  CONSTRAINT pk_user 
    PRIMARY KEY (bu_id),
  CONSTRAINT fk_user_role_of_user
    FOREIGN KEY (ur_id) 
    REFERENCES user_role (ur_id)
    # user is not deleted even if there is no role for him/her
    ON DELETE SET NULL
	ON UPDATE CASCADE
);

CREATE TABLE department (
  d_id            MEDIUMINT UNSIGNED,
  d_code          CHAR(5),
  d_name          VARCHAR(100) NOT NULL,
  CONSTRAINT pk_department
    PRIMARY KEY (d_id)
);

CREATE TABLE user_department (
  bu_id           VARCHAR(100),
  d_id            MEDIUMINT UNSIGNED,
  ud_isadmin      BIT(1) NOT NULL,
  CONSTRAINT pk_user_department 
    PRIMARY KEY (bu_id, d_id),
  CONSTRAINT fk_bbb_user_of_user_department
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_department_of_user_department
    FOREIGN KEY (d_id) 
    REFERENCES department (d_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE meeting_schedule (
  ms_id           MEDIUMINT UNSIGNED,
  ms_title        VARCHAR(100) NOT NULL,
  ms_intdatetime  DATETIME NOT NULL,
  ms_intervals    MEDIUMINT UNSIGNED NOT NULL,
  ms_repeats      MEDIUMINT UNSIGNED NOT NULL,
  ms_duration     MEDIUMINT UNSIGNED NOT NULL,
  bu_id           VARCHAR(100) NOT NULL,
  CONSTRAINT pk_meeting_schedule 
    PRIMARY KEY (ms_id),
  CONSTRAINT fk_bbb_user_of_meeting_schedule
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE non_ldap_user (
  bu_id           VARCHAR(100),
  nu_name         VARCHAR(100) NOT NULL,
  nu_lastname     VARCHAR(100) NOT NULL,
  nu_salt         VARCHAR(100) NOT NULL,
  nu_hash         VARCHAR(100) NOT NULL,
  nu_email        VARCHAR(100) NOT NULL,
  CONSTRAINT pk_non_ldap_user 
    PRIMARY KEY (bu_id),
  CONSTRAINT fk_bbb_user_of_non_ldap_user
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE meeting (
  m_id            MEDIUMINT UNSIGNED,
  ms_id           MEDIUMINT UNSIGNED,
  m_intdatetime   DATETIME NOT NULL,
  m_duration      MEDIUMINT UNSIGNED NOT NULL,
  m_iscancel      BIT(1) NOT NULL,
  m_description   VARCHAR(2000),
  CONSTRAINT pk_meeting 
    PRIMARY KEY (m_id, ms_id),
  CONSTRAINT fk_meeting_schedule_of_meeting
    FOREIGN KEY (ms_id) 
    REFERENCES meeting_schedule (ms_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE meeting_presentation (
  m_id            MEDIUMINT UNSIGNED,
  mp_title        VARCHAR(100),
  CONSTRAINT pk_meeting_presentation 
    PRIMARY KEY (m_id, mp_title),
  CONSTRAINT fk_meeting_of_meeting_presentation
    FOREIGN KEY (m_id) 
    REFERENCES meeting (m_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE meeting_guest (
  bu_id           VARCHAR(100),
  m_id            MEDIUMINT UNSIGNED,
  mg_ismod        BIT(1) NOT NULL,
  CONSTRAINT pk_meeting_guest 
    PRIMARY KEY (bu_id, m_id),
  CONSTRAINT fk_bbb_user_of_meeting_guest
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT fk_meeting_of_meeting_guest
    FOREIGN KEY (m_id) 
    REFERENCES meeting (m_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE meeting_attendee (
  bu_id           VARCHAR(100),
  ms_id           MEDIUMINT UNSIGNED,
  ma_ismod        BIT(1) NOT NULL,
  CONSTRAINT pk_meeting_attendee 
    PRIMARY KEY (bu_id, ms_id),
  CONSTRAINT fk_bbb_user_of_meeting_attendee
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT fk_meeting_schedule_of_meeting_attendee
    FOREIGN KEY (ms_id) 
    REFERENCES meeting_schedule (ms_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

# may not be used in Integration v1.0
CREATE TABLE meeting_attendance (
  bu_id           VARCHAR(100),
  ms_id           MEDIUMINT UNSIGNED,
  m_id            MEDIUMINT UNSIGNED,
  mac_isattend    BIT(1) NOT NULL,
  CONSTRAINT pk_meeting_attendance 
    PRIMARY KEY (bu_id, ms_id, m_id),
  CONSTRAINT fk_bbb_user_of_meeting_attendance
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT fk_meeting_of_meeting_attendance
    FOREIGN KEY (m_id, ms_id) 
    REFERENCES meeting (m_id, ms_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE subject (
  sub_id          CHAR(8),
  sub_name        VARCHAR(100) NOT NULL,
  CONSTRAINT pk_subject 
    PRIMARY KEY (sub_id)
);

CREATE TABLE section (
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  # semester_id is currently not part of pk for now, that may change
  semester_id     MEDIUMINT UNSIGNED NOT NULL,
  s_modpass       VARCHAR(100) NOT NULL,
  s_viewpass      VARCHAR(100) NOT NULL,
  s_ismuldraw     BIT(1) NOT NULL,
  s_isrecorded    BIT(1) NOT NULL,
  CONSTRAINT pk_section 
    PRIMARY KEY (sub_id, sc_id),
  CONSTRAINT fk_subject_of_section
    FOREIGN KEY (sub_id) 
    REFERENCES subject (sub_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE professor (
  bu_id           VARCHAR(100),
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  CONSTRAINT pk_professor 
    PRIMARY KEY (sub_id, sc_id, bu_id),
  CONSTRAINT fk_section_of_professor
    FOREIGN KEY (sub_id, sc_id) 
    REFERENCES section (sub_id, sc_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_bbb_user_of_professor
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE  
);

CREATE TABLE student (
  bu_id           VARCHAR(100), 
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  s_isbanned      BIT(1) NOT NULL,
  CONSTRAINT pk_student 
    PRIMARY KEY (sub_id, sc_id, bu_id),
  CONSTRAINT fk_section_of_student
    FOREIGN KEY (sub_id, sc_id) 
    REFERENCES section (sub_id, sc_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_bbb_user_of_student
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE  
);

CREATE TABLE lecture_schedule (
  ls_id           MEDIUMINT UNSIGNED,
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  ls_intdatetime  DATETIME NOT NULL,
  ls_intervals    MEDIUMINT UNSIGNED NOT NULL,
  ls_repeats      MEDIUMINT UNSIGNED NOT NULL,
  ls_duration     MEDIUMINT UNSIGNED NOT NULL,
  CONSTRAINT pk_lecture_schedule 
    PRIMARY KEY (ls_id, sub_id, sc_id),
  CONSTRAINT fk_section_of_lecture_schedule
    FOREIGN KEY (sub_id, sc_id) 
    REFERENCES section (sub_id, sc_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
  
CREATE TABLE lecture (
  l_id            MEDIUMINT UNSIGNED,
  ls_id           MEDIUMINT UNSIGNED,
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  l_intdatetime   DATETIME NOT NULL,
  l_duration      MEDIUMINT UNSIGNED NOT NULL,
  l_iscancel      BIT(1) NOT NULL,
  l_description   VARCHAR(2000),
  #l_url          VARCHAR(100),
  CONSTRAINT pk_lecture 
    PRIMARY KEY (l_id, ls_id, sub_id, sc_id),
  CONSTRAINT fk_lecture_schedule_of_lecture
    FOREIGN KEY (sub_id, sc_id, ls_id) 
    REFERENCES lecture_schedule (sub_id, sc_id, ls_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE lecture_presentation (
  lp_title        VARCHAR(100),
  l_id            MEDIUMINT UNSIGNED,
  ls_id           MEDIUMINT UNSIGNED,
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  CONSTRAINT pk_lecture_presentation 
    PRIMARY KEY (lp_title, l_id, ls_id, sub_id, sc_id),
  CONSTRAINT fk_lecture_of_lecture_presentation
    FOREIGN KEY (sub_id, sc_id, ls_id, l_id) 
    REFERENCES lecture (sub_id, sc_id, ls_id, l_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE guest_lecturer (
  bu_id           VARCHAR(100),
  l_id            MEDIUMINT UNSIGNED,
  ls_id           MEDIUMINT UNSIGNED,
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  gl_ismod        BIT(1) NOT NULL,
  CONSTRAINT pk_guest_lecturer 
    PRIMARY KEY (bu_id, l_id, ls_id, sub_id, sc_id),
  CONSTRAINT fk_lecture_of_guest_lecturer
    FOREIGN KEY (sub_id, sc_id, ls_id, l_id) 
    REFERENCES lecture (sub_id, sc_id, ls_id, l_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_bbb_user_of_guest_lecturer
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

# may not be used in Integration v1.0
CREATE TABLE lecture_attendance (
  bu_id           VARCHAR(100),
  ls_id           MEDIUMINT UNSIGNED,
  l_id            MEDIUMINT UNSIGNED,
  sub_id          CHAR(8),
  sc_id           CHAR(2),
  la_isattend     BIT(1) NOT NULL,
  CONSTRAINT pk_lecture_attendance 
    PRIMARY KEY (bu_id, ls_id, l_id, sub_id, sc_id),
  CONSTRAINT fk_bbb_user_of_lecture_attendance
    FOREIGN KEY (bu_id) 
    REFERENCES bbb_user (bu_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT fk_lecture_of_lecture_attendance
    FOREIGN KEY (l_id, ls_id, sub_id, sc_id) 
    REFERENCES lecture (l_id, ls_id, sub_id, sc_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);