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

-- Dumping structure for table questsoftware.DEBUGBREAKPOINTS
CREATE TABLE IF NOT EXISTS `DEBUGBREAKPOINTS` (
  `connectionid` int(11) NOT NULL,
  `type` varchar(10) NOT NULL,
  `db` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `line` int(11) NOT NULL,
  PRIMARY KEY (`connectionid`,`type`,`db`,`name`,`line`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table questsoftware.DEBUGBREAKPOINTS: ~0 rows (approximately)
DELETE FROM `DEBUGBREAKPOINTS`;
/*!40000 ALTER TABLE `DEBUGBREAKPOINTS` DISABLE KEYS */;
/*!40000 ALTER TABLE `DEBUGBREAKPOINTS` ENABLE KEYS */;


-- Dumping structure for procedure questsoftware.DEBUGDELETE
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGDELETE`(IN n VARCHAR(64))
    READS SQL DATA
BEGIN
  INSERT INTO DEBUGLOG (connectionid, type, name) VALUES (connection_id(), 'Delete', n);
END//
DELIMITER ;


-- Dumping structure for procedure questsoftware.DEBUGENABLE
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGENABLE`()
    READS SQL DATA
BEGIN
  DECLARE cid INT;
	SELECT connection_id() INTO cid;
	DO GET_LOCK(CONCAT('toadbreak_',cid),10);
  DELETE FROM DEBUGLOG WHERE connectionid = cid;
END//
DELIMITER ;


-- Dumping structure for procedure questsoftware.DEBUGENTER
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGENTER`(t VARCHAR(10), d VARCHAR(64), n VARCHAR(64), i VARCHAR(64))
    READS SQL DATA
BEGIN
	DECLARE cid INT;
  DECLARE dlm DATETIME;
  DECLARE olm DATETIME;
  DECLARE u INT;
  SELECT connection_id() INTO cid;
  IF EXISTS (SELECT 'X' FROM information_schema.routines
	            WHERE routine_type = t AND LOWER(routine_schema) = 'questdebug'
							  AND LOWER(routine_name) = CONCAT(i,'impl'))
	THEN
		SELECT last_altered FROM information_schema.routines
	 	 WHERE routine_type = t AND LOWER(routine_schema) = 'questdebug'
	     AND LOWER(routine_name) = CONCAT(i,'impl') INTO dlm;
		SELECT last_altered FROM information_schema.routines
	 	 WHERE routine_type = t AND LOWER(routine_schema) = d
	     AND LOWER(routine_name) = n INTO olm;
		IF dlm < olm THEN
      SELECT 1 INTO u;
    ELSE
      SELECT 0 INTO u;
		END IF;
	ELSE
    SELECT 1 INTO u;
	END IF;
  IF t = 'FUNCTION' THEN
    UPDATE DEBUGSTEPINFO SET step = 'I' WHERE connectionid = cid;
  END IF;
  INSERT INTO DEBUGLOG (connectionid, type, db, name, value) VALUES (cid, t, d, n, u);
  IF IS_USED_LOCK(CONCAT('toadbreak_', cid)) = cid THEN
    DO GET_LOCK(CONCAT('toadbreak2_', cid), 1000000);
  ELSE
    DO GET_LOCK(CONCAT('toadbreak_', cid), 1000000);
  END IF;
  DELETE FROM DEBUGLOG WHERE connectionid = cid;
END//
DELIMITER ;


-- Dumping structure for procedure questsoftware.DEBUGLEAVE
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGLEAVE`()
    READS SQL DATA
BEGIN
	DECLARE cid INT;

  SELECT connection_id() INTO cid;
  INSERT INTO DEBUGLOG (connectionid, type) VALUES (cid, 'Leave');

  IF IS_USED_LOCK(CONCAT('toadbreak_', cid)) = cid THEN
    DO GET_LOCK(CONCAT('toadbreak2_', cid), 1000000);
  ELSE
    DO GET_LOCK(CONCAT('toadbreak_', cid), 1000000);
  END IF;

  DELETE FROM DEBUGLOG WHERE connectionid = cid;
END//
DELIMITER ;


-- Dumping structure for table questsoftware.DEBUGLOG
CREATE TABLE IF NOT EXISTS `DEBUGLOG` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `connectionid` int(11) NOT NULL,
  `type` varchar(10) NOT NULL,
  `db` varchar(64) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `value` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connectionid` (`connectionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table questsoftware.DEBUGLOG: ~0 rows (approximately)
DELETE FROM `DEBUGLOG`;
/*!40000 ALTER TABLE `DEBUGLOG` DISABLE KEYS */;
/*!40000 ALTER TABLE `DEBUGLOG` ENABLE KEYS */;


-- Dumping structure for procedure questsoftware.DEBUGSET
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGSET`(IN n VARCHAR(64), IN t ENUM('P','L'), IN v VARCHAR(20000))
    READS SQL DATA
BEGIN
  INSERT INTO DEBUGLOG (connectionid, type, name, value) VALUES (connection_id(), CONCAT('Value',t), n, v);
END//
DELIMITER ;


-- Dumping structure for table questsoftware.DEBUGSTEPINFO
CREATE TABLE IF NOT EXISTS `DEBUGSTEPINFO` (
  `connectionid` int(11) NOT NULL,
  `step` enum('C','S','O','I') NOT NULL,
  `stackdepth` int(11) DEFAULT NULL,
  `callstackdepth` int(11) DEFAULT NULL,
  PRIMARY KEY (`connectionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table questsoftware.DEBUGSTEPINFO: ~6 rows (approximately)
DELETE FROM `DEBUGSTEPINFO`;
/*!40000 ALTER TABLE `DEBUGSTEPINFO` DISABLE KEYS */;
INSERT INTO `DEBUGSTEPINFO` (`connectionid`, `step`, `stackdepth`, `callstackdepth`) VALUES
	(299685, 'I', NULL, 1),
	(299688, 'I', NULL, 1),
	(299690, 'I', NULL, 1),
	(299692, 'I', NULL, 1),
	(299694, 'I', NULL, 1),
	(299697, 'I', NULL, 1);
/*!40000 ALTER TABLE `DEBUGSTEPINFO` ENABLE KEYS */;


-- Dumping structure for table questsoftware.DEBUGTARGET
CREATE TABLE IF NOT EXISTS `DEBUGTARGET` (
  `type` varchar(10) NOT NULL,
  `db` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `line` int(11) NOT NULL,
  PRIMARY KEY (`type`,`db`,`name`,`line`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table questsoftware.DEBUGTARGET: ~0 rows (approximately)
DELETE FROM `DEBUGTARGET`;
/*!40000 ALTER TABLE `DEBUGTARGET` DISABLE KEYS */;
/*!40000 ALTER TABLE `DEBUGTARGET` ENABLE KEYS */;


-- Dumping structure for procedure questsoftware.DEBUGTRACE
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGTRACE`(t VARCHAR(10), d VARCHAR(64), n VARCHAR(64), IN l INT)
    READS SQL DATA
BEGIN
  DECLARE cid INT;
	DECLARE st ENUM('C','S','O','I');
	DECLARE stsd INT;
  DECLARE sd INT;
	SELECT connectionid, step, stackdepth, callstackdepth FROM DEBUGSTEPINFO
	 WHERE connectionid = connection_id() INTO cid, st, stsd, sd;
	IF (st = 'I') OR (st = 'O' AND sd < stsd) OR (st = 'S' AND sd <= stsd) OR
	   EXISTS (SELECT 'X' FROM DEBUGBREAKPOINTS a
		          WHERE connectionid = cid AND type = t
								AND db = d AND name = n AND line = l) THEN
    INSERT INTO DEBUGLOG (connectionid, type, name) VALUES (cid, 'Trace', l);
    IF IS_USED_LOCK(CONCAT('toadbreak_',cid)) = cid THEN
      DO GET_LOCK(CONCAT('toadbreak2_', cid), 1000000);
    ELSE
      DO GET_LOCK(CONCAT('toadbreak_', cid), 1000000);
    END IF;
    DELETE FROM DEBUGLOG WHERE connectionid = cid;
	END IF;
END//
DELIMITER ;


-- Dumping structure for procedure questsoftware.DEBUGWAIT
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `DEBUGWAIT`(IN cid INT)
    READS SQL DATA
BEGIN
  IF IS_USED_LOCK(CONCAT('toadbreak_',cid)) = connection_id() THEN
    WHILE IS_USED_LOCK(CONCAT('toadbreak2_',cid)) IS NOT NULL DO
      DO SLEEP(0.1);
    END WHILE;
  ELSE
    WHILE IS_USED_LOCK(CONCAT('toadbreak_',cid)) IS NOT NULL DO
      DO SLEEP(0.1);
    END WHILE;
  END IF;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
