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

-- Dumping structure for function common.fn_get_board
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_get_board`(value varchar(10),v_boar_type varchar(10)) RETURNS varchar(10) CHARSET utf8
    READS SQL DATA
BEGIN

    DECLARE v_id varchar(10);
    DECLARE v_parent varchar(10);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET @id = NULL;
    
    SET v_parent = @id;
    SET v_id = -1;
 
    IF @id IS NULL THEN
        RETURN NULL;
    END IF;
 
    LOOP
  SELECT 
   MIN(b_id)
  INTO @id FROM
   common.tbl_board
  WHERE
   board_type = v_boar_type
  AND
   b_mid = v_parent
  AND b_id > v_id;
        
  IF @id IS NOT NULL OR v_parent = @start_with THEN
   SET @level = @level + 1;
   RETURN @id;
  END IF;
    
  SET @level := @level - 1;
    
  SELECT 
   b_id, b_mid
  INTO v_id , v_parent 
  FROM
   common.tbl_board
  WHERE
   board_type = v_boar_type
  AND
   b_id = v_parent;
    END LOOP;
END//
DELIMITER ;


-- Dumping structure for procedure common.PROC_DELETE_SUBSCRIPTION
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_DELETE_SUBSCRIPTION`(
	IN in_user_id INT(11),
    OUT out_result INT
)
BEGIN

	DECLARE v_group_cnt INT(11);
    
    DECLARE v_result INT DEFAULT 0;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
    
		/* DELETE paksa.tbl_eval */
		DELETE FROM paksa.tbl_eval_log 
        WHERE evalid IN (SELECT evalid FROM paksa.tbl_eval WHERE userid = in_user_id);
        
        DELETE FROM paksa.tbl_eval_result 
        WHERE userid = in_user_id;
        
        DELETE FROM paksa.tbl_eval 
        WHERE userid = in_user_id;
        
        /* DELETE paksa.tbl_exam */
		DELETE FROM paksa.tbl_exam_log 
        WHERE examid IN (SELECT examid FROM paksa.tbl_exam_result WHERE userid = in_user_id);
        
        DELETE FROM paksa.tbl_exam_result 
        WHERE userid = in_user_id;
        
        /* DELETE paksa.tbl_learn */
		DELETE FROM paksa.tbl_learn_status_log 
        WHERE userid = in_user_id;
        
        DELETE FROM paksa.tbl_learn_status 
        WHERE userid = in_user_id;
        
        DELETE FROM paksa.tbl_learn WHERE 
        userid = in_user_id;
        
        /* DELETE common.tbl_user_learn */
        DELETE FROM common.tbl_user_learn 
        WHERE user_id = in_user_id;
		
        /* DELETE common.tbl_class_learn */
        SELECT COUNT(*) INTO v_group_cnt 
        FROM common.tbl_group 
        WHERE user_id = in_user_id;
        
        IF v_group_cnt > 0 THEN
        
			DELETE FROM common.tbl_class_learn 
            WHERE group_id IN (SELECT group_id FROM common.tbl_group WHERE user_id = in_user_id);
		
			UPDATE common.tbl_class_user 
            SET pay_status = 1 
            WHERE group_id IN (SELECT group_id FROM common.tbl_group WHERE user_id = in_user_id);
        
        END IF;
        
        DELETE FROM mis.tbl_user_credit_card 
        WHERE userid = in_user_id;
        
		DELETE FROM mis.tbl_user_payment_info 
        WHERE sid IN (SELECT sid FROM mis.tbl_subscription WHERE user_id = in_user_id);
        
		/* DELETE mis.tbl_subscription */
        DELETE FROM mis.tbl_subscription_discount_info 
        WHERE sid IN (SELECT sid FROM mis.tbl_subscription WHERE user_id = in_user_id);
        
        DELETE FROM mis.tbl_subscription_dtl 
        WHERE sid IN (SELECT sid FROM mis.tbl_subscription WHERE user_id = in_user_id);
        
        DELETE FROM mis.tbl_subscription 
        WHERE user_id = in_user_id;
        
        /* DELETE mis.tbl_pay_info */
        DELETE FROM mis.tbl_pay_info 
        WHERE pay_id IN (SELECT pay_id FROM mis.tbl_subscription WHERE user_id = in_user_id);
        
        /* DELETE mis.tbl_coupon */
        UPDATE mis.tbl_coupon_tgt 
        SET is_use = 0 
        WHERE user_id = in_user_id;
        
        /* DELETE mis.tbl_creditcode */
        UPDATE mis.tbl_creditcode 
        SET use_status = '00' 
        WHERE user_id = in_user_id;
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;
    
END//
DELIMITER ;


-- Dumping structure for trigger common.tbl_sysuser_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY';
DELIMITER //
CREATE TRIGGER `tbl_sysuser_BEFORE_INSERT` BEFORE INSERT ON `tbl_sysuser` FOR EACH ROW BEGIN


   DECLARE vIdx varchar(11);
   
   SET @dformat = date_format(now(),'%Y%m%d');

   SELECT ifnull(max(sysuseridx), rpad(@dformat,11,'0')) + 1 
   INTO vIdx 
   FROM tbl_sysuser
   WHERE substr(sysuseridx,1,8) = @dformat;
   
   SET NEW.sysuseridx = vIdx;
   
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping structure for trigger common.tbl_user_skey_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY';
DELIMITER //
CREATE TRIGGER `tbl_user_skey_BEFORE_INSERT` BEFORE INSERT ON `tbl_user_skey` FOR EACH ROW BEGIN


 SET @UID = CONCAT('U', UPPER(LEFT(REPLACE(UUID(),'-',''), 8)), FLOOR(RAND() * 401) + 100);
 IF NOT EXISTS(SELECT * FROM common.tbl_user_skey WHERE sskey = @UID) THEN
   SET NEW.sskey = @UID;
 ELSE
	SET NEW.sskey = @UID + 1;
 END IF; 
 
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
