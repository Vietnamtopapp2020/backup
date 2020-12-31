-- --------------------------------------------------------
-- Host:                         paksa-pub.c46t2absfwgx.ap-northeast-1.rds.amazonaws.com
-- Server version:               5.6.34-log - MySQL Community Server (GPL)
-- Server OS:                    Linux
-- HeidiSQL Version:             9.1.0.4867
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for function portal.fn_GetLastSchool
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetLastSchool`(in_idx int) RETURNS varchar(45) CHARSET utf8
BEGIN

	DECLARE v_idx INT(11);
    DECLARE v_seq INT(11);
    DECLARE out_last_school VARCHAR(45);
    
    SELECT idx, MAX(seq) AS seq
      INTO v_idx, v_seq
      FROM portal.tbl_teacher_school
	 WHERE idx = in_idx
     GROUP BY idx
	;
    
    SELECT school
      INTO out_last_school
      FROM portal.tbl_teacher_school
	 WHERE idx = v_idx AND seq = v_seq
	;

	RETURN out_last_school;

END//
DELIMITER ;


-- Dumping structure for table portal.tbl_class
CREATE TABLE IF NOT EXISTS `tbl_class` (
  `class_id` int(11) NOT NULL,
  `class_name` varchar(45) DEFAULT NULL,
  `st_date` varchar(45) DEFAULT NULL,
  `ed_date` varchar(45) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `level` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `cost` decimal(15,2) DEFAULT NULL,
  `summary` varchar(45) DEFAULT NULL,
  `desc` varchar(45) DEFAULT NULL,
  `method_tool` varchar(45) DEFAULT NULL COMMENT 'video chat, voice chat, text chat, graphic chat',
  `is_publish` varchar(1) DEFAULT NULL,
  `tbl_teacher_subject_idx` int(11) NOT NULL,
  `tbl_teacher_subject_seq` int(11) NOT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`class_id`),
  KEY `fk_tbl_classroom_tbl_teacher_subject1_idx` (`tbl_teacher_subject_idx`,`tbl_teacher_subject_seq`),
  CONSTRAINT `fk_tbl_classroom_tbl_teacher_subject1` FOREIGN KEY (`tbl_teacher_subject_idx`, `tbl_teacher_subject_seq`) REFERENCES `tbl_teacher_subject` (`idx`, `seq`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_class: ~0 rows (approximately)
DELETE FROM `tbl_class`;
/*!40000 ALTER TABLE `tbl_class` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_class` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_class_member
CREATE TABLE IF NOT EXISTS `tbl_class_member` (
  `class_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `member_name` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `join_date` datetime DEFAULT NULL,
  `wd_date` datetime DEFAULT NULL,
  PRIMARY KEY (`class_id`,`member_id`),
  CONSTRAINT `fk_tbl_classroom_member_tbl_classroom1` FOREIGN KEY (`class_id`) REFERENCES `tbl_class` (`class_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_class_member: ~0 rows (approximately)
DELETE FROM `tbl_class_member`;
/*!40000 ALTER TABLE `tbl_class_member` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_class_member` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_class_member_access
CREATE TABLE IF NOT EXISTS `tbl_class_member_access` (
  `class_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `ipaddress` varchar(45) DEFAULT NULL,
  `acc_date` datetime DEFAULT NULL,
  PRIMARY KEY (`class_id`,`member_id`,`seq`),
  KEY `fk_tbl_classroom_member_access_tbl_classroom_member1_idx` (`class_id`,`member_id`),
  CONSTRAINT `fk_tbl_classroom_member_access_tbl_classroom_member1` FOREIGN KEY (`class_id`, `member_id`) REFERENCES `tbl_class_member` (`class_id`, `member_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_class_member_access: ~0 rows (approximately)
DELETE FROM `tbl_class_member_access`;
/*!40000 ALTER TABLE `tbl_class_member_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_class_member_access` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_class_rate
CREATE TABLE IF NOT EXISTS `tbl_class_rate` (
  `class_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `rate` varchar(45) DEFAULT NULL,
  `comment` varchar(45) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`class_id`,`member_id`),
  CONSTRAINT `fk_tbl_class_rate_tbl_class_member1` FOREIGN KEY (`class_id`, `member_id`) REFERENCES `tbl_class_member` (`class_id`, `member_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_class_rate: ~0 rows (approximately)
DELETE FROM `tbl_class_rate`;
/*!40000 ALTER TABLE `tbl_class_rate` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_class_rate` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_class_schedule
CREATE TABLE IF NOT EXISTS `tbl_class_schedule` (
  `class_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `date` varchar(45) DEFAULT NULL,
  `time` varchar(45) DEFAULT NULL,
  `lesson_summary` varchar(45) DEFAULT NULL COMMENT 'today''s  content',
  `is_regular` varchar(1) DEFAULT NULL COMMENT 'regular lesson or supplementary lessons\nif supplementary lessons then it should be added',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`class_id`,`seq`),
  CONSTRAINT `fk_tbl_class_schedule_tbl_class1` FOREIGN KEY (`class_id`) REFERENCES `tbl_class` (`class_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_class_schedule: ~0 rows (approximately)
DELETE FROM `tbl_class_schedule`;
/*!40000 ALTER TABLE `tbl_class_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_class_schedule` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_membership
CREATE TABLE IF NOT EXISTS `tbl_membership` (
  `type` varchar(5) NOT NULL COMMENT 'free\nintro\nbasic\nplus\nstandard\npremium\n\n\ntype from code',
  `price` decimal(15,2) DEFAULT NULL,
  `fr_date` varchar(8) DEFAULT NULL,
  `to_date` varchar(8) DEFAULT NULL,
  `is_publish` varchar(1) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_membership: ~0 rows (approximately)
DELETE FROM `tbl_membership`;
/*!40000 ALTER TABLE `tbl_membership` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_membership` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_member_membership
CREATE TABLE IF NOT EXISTS `tbl_member_membership` (
  `tbl_teacher_idx` int(11) NOT NULL,
  `tbl_membership_type` varchar(5) NOT NULL,
  `seq` int(11) NOT NULL,
  `fr_date` varchar(8) DEFAULT NULL,
  `to_date` varchar(8) DEFAULT NULL,
  `is_valid` varchar(1) DEFAULT NULL,
  `create_time` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tbl_teacher_idx`,`tbl_membership_type`,`seq`),
  KEY `fk_tbl_member_membership_tbl_membership1_idx` (`tbl_membership_type`),
  KEY `fk_tbl_member_membership_tbl_teacher1_idx` (`tbl_teacher_idx`),
  CONSTRAINT `fk_tbl_member_membership_tbl_membership1` FOREIGN KEY (`tbl_membership_type`) REFERENCES `tbl_membership` (`type`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_tbl_member_membership_tbl_teacher1` FOREIGN KEY (`tbl_teacher_idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_member_membership: ~0 rows (approximately)
DELETE FROM `tbl_member_membership`;
/*!40000 ALTER TABLE `tbl_member_membership` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_member_membership` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher
CREATE TABLE IF NOT EXISTS `tbl_teacher` (
  `idx` int(11) NOT NULL,
  `teacher_id` varchar(45) NOT NULL,
  `teacher_password` varchar(45) NOT NULL,
  `teacher_username` varchar(45) NOT NULL COMMENT 'email_address',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `teacher_id_UNIQUE` (`teacher_id`),
  UNIQUE KEY `idx_UNIQUE` (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher: ~1 rows (approximately)
DELETE FROM `tbl_teacher`;
/*!40000 ALTER TABLE `tbl_teacher` DISABLE KEYS */;
INSERT INTO `tbl_teacher` (`idx`, `teacher_id`, `teacher_password`, `teacher_username`, `create_time`, `update_time`) VALUES
	(14, 'lstrampp84@gmail.com', '84nicole', 'Leaaaa', '2016-05-19 07:09:51', NULL),
	(15, 'oniashc@gmail.com', '1234', 'peter chung', '2016-08-13 01:22:10', NULL),
	(16, 'gil@fog-ware.com', 'gil123', 'Gil', '2016-11-23 17:04:52', NULL);
/*!40000 ALTER TABLE `tbl_teacher` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_career
CREATE TABLE IF NOT EXISTS `tbl_teacher_career` (
  `idx` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `st_date` varchar(45) DEFAULT NULL,
  `ed_date` varchar(45) DEFAULT NULL,
  `place` varchar(45) DEFAULT NULL,
  `position` varchar(45) DEFAULT NULL,
  `is_related` varchar(1) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`),
  KEY `fk_table1_tbl_teacher1_idx` (`idx`),
  CONSTRAINT `fk_table1_tbl_teacher1` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_career: ~2 rows (approximately)
DELETE FROM `tbl_teacher_career`;
/*!40000 ALTER TABLE `tbl_teacher_career` DISABLE KEYS */;
INSERT INTO `tbl_teacher_career` (`idx`, `seq`, `st_date`, `ed_date`, `place`, `position`, `is_related`, `create_time`, `update_time`) VALUES
	(14, 1, '20130201', '20140201', 'EIE English Academy', 'English Teacher', NULL, '2016-06-02 08:36:46', NULL),
	(14, 2, '20140201', '20160222', 'Daejeon Sahmyook Elementary School', 'Home Room Teacher', NULL, '2016-06-02 08:36:46', NULL);
/*!40000 ALTER TABLE `tbl_teacher_career` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_certification
CREATE TABLE IF NOT EXISTS `tbl_teacher_certification` (
  `idx` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `cert_name` varchar(45) DEFAULT NULL,
  `desc` varchar(45) DEFAULT NULL,
  `file_attached` varchar(45) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`),
  CONSTRAINT `fk_table1_tbl_teacher4` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_certification: ~1 rows (approximately)
DELETE FROM `tbl_teacher_certification`;
/*!40000 ALTER TABLE `tbl_teacher_certification` DISABLE KEYS */;
INSERT INTO `tbl_teacher_certification` (`idx`, `seq`, `cert_name`, `desc`, `file_attached`, `create_time`, `update_time`) VALUES
	(14, 1, 'Teaching Certification', 'TEACH-NOW', '', '2016-05-19 07:13:45', '2016-07-27 18:30:18');
/*!40000 ALTER TABLE `tbl_teacher_certification` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_info
CREATE TABLE IF NOT EXISTS `tbl_teacher_info` (
  `idx` int(11) NOT NULL,
  `last_name` varchar(45) DEFAULT NULL,
  `first_name` varchar(45) DEFAULT NULL,
  `preferred_name` varchar(45) DEFAULT NULL,
  `nick_name` varchar(45) DEFAULT NULL,
  `dob` varchar(45) DEFAULT NULL,
  `gender` varchar(45) DEFAULT NULL,
  `telephone` varchar(45) DEFAULT NULL,
  `mobile` varchar(45) DEFAULT NULL,
  `nation_code` varchar(3) DEFAULT NULL COMMENT 'residence present',
  `address` varchar(45) DEFAULT NULL,
  `desc` blob,
  `filename` varchar(300) DEFAULT NULL,
  `svfilename` varchar(1000) DEFAULT NULL,
  `time_zone` int(3) DEFAULT NULL,
  `create_time` varchar(45) DEFAULT 'CURRENT_TIMESTAMP',
  `update_time` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idx`),
  KEY `fk_tbl_teacher_info_tbl_teacher_idx` (`idx`),
  CONSTRAINT `fk_tbl_teacher_info_tbl_teacher` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_info: ~2 rows (approximately)
DELETE FROM `tbl_teacher_info`;
/*!40000 ALTER TABLE `tbl_teacher_info` DISABLE KEYS */;
INSERT INTO `tbl_teacher_info` (`idx`, `last_name`, `first_name`, `preferred_name`, `nick_name`, `dob`, `gender`, `telephone`, `mobile`, `nation_code`, `address`, `desc`, `filename`, `svfilename`, `time_zone`, `create_time`, `update_time`) VALUES
	(14, 'Strampp', 'Lea', 'Lea.Strampp', 'Lea', '19841108', '2', '828-318-3821', '', '840', '', _binary '', 'LeaHeadShot.jpg', '/image/profile/thumb/14_LeaHeadShot.jpg', NULL, '2016-05-19 07:13:44', '2016-07-27 18:30:18'),
	(15, 'Chung', 'Peter', '', '', '________', '1', '', '', '248', '', _binary '', '', NULL, NULL, '2016-08-13 01:30:54', NULL),
	(16, '', '', '', '', '________', '1', '', '', '248', '', _binary '', '', NULL, NULL, '2016-11-23 17:14:28', NULL);
/*!40000 ALTER TABLE `tbl_teacher_info` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_payinfo
CREATE TABLE IF NOT EXISTS `tbl_teacher_payinfo` (
  `idx` int(11) NOT NULL,
  `seq` varchar(45) NOT NULL,
  `type` varchar(45) DEFAULT NULL COMMENT 'card, bankaccount',
  `card_no` varchar(45) DEFAULT NULL,
  `card_kind` varchar(45) DEFAULT NULL,
  `card_expdate` varchar(45) DEFAULT NULL,
  `card_csv` varchar(45) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`),
  CONSTRAINT `fk_table1_tbl_teacher3` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_payinfo: ~0 rows (approximately)
DELETE FROM `tbl_teacher_payinfo`;
/*!40000 ALTER TABLE `tbl_teacher_payinfo` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_teacher_payinfo` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_rate
CREATE TABLE IF NOT EXISTS `tbl_teacher_rate` (
  `tbl_teacher_idx` int(11) NOT NULL,
  `tbl_class_member_class_id` int(11) NOT NULL,
  `tbl_class_member_member_id` int(11) NOT NULL,
  `rate` varchar(45) DEFAULT NULL,
  `comment` varchar(45) DEFAULT NULL,
  `is_show` varchar(45) DEFAULT NULL,
  `create_time` varchar(45) DEFAULT 'CURRENT_TIMESTAMP',
  PRIMARY KEY (`tbl_teacher_idx`,`tbl_class_member_class_id`,`tbl_class_member_member_id`),
  KEY `fk_tbl_teacher_rate_tbl_teacher1_idx` (`tbl_teacher_idx`),
  KEY `fk_tbl_teacher_rate_tbl_class_member1_idx` (`tbl_class_member_class_id`,`tbl_class_member_member_id`),
  CONSTRAINT `fk_tbl_teacher_rate_tbl_class_member1` FOREIGN KEY (`tbl_class_member_class_id`, `tbl_class_member_member_id`) REFERENCES `tbl_class_member` (`class_id`, `member_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_tbl_teacher_rate_tbl_teacher1` FOREIGN KEY (`tbl_teacher_idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_rate: ~0 rows (approximately)
DELETE FROM `tbl_teacher_rate`;
/*!40000 ALTER TABLE `tbl_teacher_rate` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_teacher_rate` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_schedule
CREATE TABLE IF NOT EXISTS `tbl_teacher_schedule` (
  `idx` int(11) NOT NULL COMMENT 'tbl_teacher  idx',
  `seq` int(11) NOT NULL,
  `sch_title` varchar(200) DEFAULT NULL COMMENT '스케줄을 구분하는 제목 - 교사는 여러개의 일정을 저장하고 노출할 수 있다.',
  `sch_target` varchar(100) DEFAULT NULL COMMENT 'common.tbl_code , USERGRD\n00 전체대상\n01 초등\n02 중등\n03 고등\n04 일반인\ncode에 따라 해당 대을 구분자분리하여 사용함.',
  `sch_code` varchar(2) DEFAULT NULL COMMENT 'common.tbl_code , SCHCD\n01 - 매일\n02 - 매주반복\n03 - 매월반복\n04 - 직접설정',
  `sch_date` blob COMMENT '수업가능\n01 - ''00''으로 구분\n02 - mon, tue, wed, thu, fri, sat, sun\n03- 일자, 일자, 일자...\n04- 년/월/일, 년/월/일 \ncode에 따라 해당 date을 구분자분리하여 사용함.',
  `sch_time` blob COMMENT '수업가능시간: 시:분, 시:분,...\ncode에 따라 해당 time을 구분자분리하여 사용함.\n''00''은 아무때나 (anytime)',
  `sch_mins` varchar(2) DEFAULT NULL COMMENT '수업시간 (분) \ncommon.tbl_code  TCHTIME',
  `is_show` varchar(1) DEFAULT NULL COMMENT '''1'' = 노출(사용)\n''0'' = 미노출(미사용)',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_schedule: ~0 rows (approximately)
DELETE FROM `tbl_teacher_schedule`;
/*!40000 ALTER TABLE `tbl_teacher_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_teacher_schedule` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_school
CREATE TABLE IF NOT EXISTS `tbl_teacher_school` (
  `idx` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `st_date` varchar(10) DEFAULT NULL,
  `ed_date` varchar(10) DEFAULT NULL,
  `school` varchar(200) DEFAULT NULL,
  `degree` varchar(2) DEFAULT NULL COMMENT 'DEGREE',
  `diploma_attach` varchar(500) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`),
  CONSTRAINT `fk_table1_tbl_teacher2` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_school: ~2 rows (approximately)
DELETE FROM `tbl_teacher_school`;
/*!40000 ALTER TABLE `tbl_teacher_school` DISABLE KEYS */;
INSERT INTO `tbl_teacher_school` (`idx`, `seq`, `st_date`, `ed_date`, `school`, `degree`, `diploma_attach`, `create_time`, `update_time`) VALUES
	(14, 1, '', '20070815', 'FSU', '02', NULL, '2016-05-19 07:13:45', NULL),
	(14, 2, '', '20160310', 'TEACH-NOW', '03', NULL, '2016-05-19 07:13:45', NULL);
/*!40000 ALTER TABLE `tbl_teacher_school` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teacher_subject
CREATE TABLE IF NOT EXISTS `tbl_teacher_subject` (
  `idx` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `subject_code` varchar(45) DEFAULT NULL,
  `subject_name` varchar(45) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`idx`,`seq`),
  KEY `fk_tbl_teacher_subject_tbl_teacher1_idx` (`idx`),
  CONSTRAINT `fk_tbl_teacher_subject_tbl_teacher1` FOREIGN KEY (`idx`) REFERENCES `tbl_teacher` (`idx`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teacher_subject: ~0 rows (approximately)
DELETE FROM `tbl_teacher_subject`;
/*!40000 ALTER TABLE `tbl_teacher_subject` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_teacher_subject` ENABLE KEYS */;


-- Dumping structure for table portal.tbl_teach_preparation
CREATE TABLE IF NOT EXISTS `tbl_teach_preparation` (
  `teacher_idx` int(11) NOT NULL,
  `grade` varchar(2) NOT NULL COMMENT 'CURGRADE',
  `level` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `week` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `iid` int(11) DEFAULT NULL,
  `content` blob,
  `create_date` datetime DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  PRIMARY KEY (`teacher_idx`,`grade`,`level`,`month`,`week`,`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table portal.tbl_teach_preparation: ~2 rows (approximately)
DELETE FROM `tbl_teach_preparation`;
/*!40000 ALTER TABLE `tbl_teach_preparation` DISABLE KEYS */;
INSERT INTO `tbl_teach_preparation` (`teacher_idx`, `grade`, `level`, `month`, `week`, `day`, `iid`, `content`, `create_date`, `update_date`) VALUES
	(14, '01', 1, 1, 1, 1, 0, _binary 0x5B566F636162756C6172795D200D0A2A2073696D696C6172203D2073616D6520203C2D3E20646966666572656E740D0A2A20636F6E666964656E740D0A2A20706572736F6E203D20736F6D656F6E650D0A2A206E6F7420706572736F6E203D20736F6D657468696E670D0A0D0A5B416262726576696174696F6E5D0D0A2A20776173206E6F74203D207761736E27740D0A2A206973206E6F74203D2069736E27740D0A0D0A5B4964696F6D5D0D0A0D0A0D0A5B53656E74656E63655D0D0A2A204920616D2073757265203D204920616D20636F6E666964656E7420203C2D3E202049207468696E6B207E203D204D61796265, '2016-05-26 15:31:58', '2016-05-26 15:34:54'),
	(14, '01', 1, 1, 1, 2, 0, _binary 0x5B53656E74656E63655D0D0A0D0A0D0A5B566F636162756C6172795D200D0A0D0A0D0A5B4964696F6D5D0D0A0D0A0D0A5B416262726576696174696F6E5D0D0A0D0A0D0A0D0A0D0A0D0A, '2016-05-26 15:32:54', NULL);
/*!40000 ALTER TABLE `tbl_teach_preparation` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
