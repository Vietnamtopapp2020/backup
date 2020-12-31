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

-- Dumping structure for procedure mis.CHK_SUBSCRIPTION
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `CHK_SUBSCRIPTION`(
	IN in_user_id INT(11),
    IN in_group_id INT(11),
    IN in_class_id INT(11),
    IN in_creditcode VARCHAR(20),
    IN in_site VARCHAR(2),
    IN in_date VARCHAR(8),
    OUT out_result VARCHAR(100),
	OUT out_msg VARCHAR(5000)
)
BEGIN
	DECLARE v_result_param VARCHAR(100);
    DECLARE v_result VARCHAR(100);

    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
	DECLARE v_month_cnt INT(11);
    DECLARE v_new_date VARCHAR(10);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_error VARCHAR(20);
	DECLARE v_idx INT(2);
    DECLARE v_cnt INT(3);
    DECLARE v_cnt_new INT(3);
    DECLARE v_msg VARCHAR(5000);
    
    DECLARE creditcode_cur CURSOR FOR
    SELECT pack_id, pack_dtl_id, month_cnt
    FROM mis.tbl_creditcode a join mis.tbl_creditcode_product b
    ON a.cc_id=b.cc_id 
    WHERE a.credit_code = in_creditcode
    ;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    SET v_finished = 0;
    SET v_result = 0;
    
    SET v_cnt = 0;
    SET v_cnt_new = 0;
    SET v_msg ='';
    
	OPEN creditcode_cur;
	get_creditcode_cur: LOOP
    
    FETCH creditcode_cur
	INTO v_pack_id, v_pack_dtl_id, v_month_cnt;
    
    IF v_finished = 1 THEN
		SET v_month_cnt = v_month_cnt;
		LEAVE get_creditcode_cur;
	END IF;
    
    
		SELECT count(*)
		INTO @count
		FROM mis.tbl_subscription a join mis.tbl_subscription_dtl b on a.sid=b.sid
        WHERE user_id = in_user_id
        AND pack_id = v_pack_id
        AND pack_dtl_id = v_pack_dtl_id
        AND in_date BETWEEN use_stdt AND use_eddt
        AND group_id = in_group_id
        AND class_id = in_class_id
        ;
        
        IF @count > 0 THEN
			SELECT product_name, course_name
			INTO @product_name, @course_name
			FROM mis.tbl_package_dtl
			WHERE pack_id = v_pack_id
			AND pack_dtl_id = v_pack_dtl_id
			;
            	
			SELECT DATE_ADD(use_stdt,INTERVAL 0 month), 
				   DATE_ADD(use_eddt,INTERVAL 0 month), 
                   DATE_ADD(use_eddt,INTERVAL v_month_cnt month)
			INTO @use_stdt, @use_eddt, @for_use_eddt
			FROM mis.tbl_subscription a join mis.tbl_subscription_dtl b on a.sid=b.sid
			WHERE user_id = in_user_id
			AND pack_id = v_pack_id
			AND pack_dtl_id = v_pack_dtl_id
			AND in_date BETWEEN use_stdt AND use_eddt
			;
			
            
			SET v_msg = concat(v_msg, @product_name, ' - ', @course_name , '  [', @use_stdt, '~', @use_eddt, ']-><span style="color:red;">[', @use_stdt, '~', @for_use_eddt, ']</span><br>');
		
        ELSE
        
			SELECT count(*)
			INTO @cnt_new
			FROM mis.tbl_package_dtl
			WHERE pack_id = v_pack_id
			AND pack_dtl_id = v_pack_dtl_id
            AND rid is not null
			;
            
            IF @cnt_new > 0 THEN
				SET v_cnt_new = v_cnt_new + 1;
            END IF;
        
        END IF;
        	
    SET v_cnt = v_cnt + @count;

	END LOOP get_creditcode_cur;
    CLOSE creditcode_cur;
    
		IF v_cnt > 0 THEN
			SET v_result = v_cnt;

            SET v_new_date = (SELECT DATE_ADD(in_date,INTERVAL v_month_cnt month) FROM DUAL);
		END IF;

    SET out_result =  v_result;
    SET out_msg = concat('There are ', v_result, ' courses below in learning <br> and You may add ', v_cnt_new,' new courses until <span style="color:red;">', v_new_date,'</span>.<br><br>', v_msg);
     
END//
DELIMITER ;


-- Dumping structure for function mis.fn_GetBuyno
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetBuyno`(in_sid varchar(20), in_sdtl_no int) RETURNS varchar(20) CHARSET utf8
BEGIN

    DECLARE v_buyno VARCHAR(23);
    
    SELECT CONCAT(in_sid, LPAD(in_sdtl_no, 3, 0)) INTO v_buyno;

	RETURN v_buyno;

END//
DELIMITER ;


-- Dumping structure for function mis.fn_GetDiscountPrice
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetDiscountPrice`(

	in_pack_id int(11)
    ,in_pack_dtl_id int(11)
    ,in_regular_price decimal(15,2)
    ,in_coupon_code varchar(12) 
    ,in_credit_code varchar(12)
    ,in_host varchar(100)
    
) RETURNS decimal(15,2)
BEGIN

    DECLARE v_pack_dtl_cnt int(11);
    DECLARE v_price decimal(15,2) DEFAULT 0;
    DECLARE v_coupon_cnt int(11);
    DECLARE v_coupon_scope_cnt int(11);
    DECLARE v_credit_cnt int(11);
    DECLARE v_discout_method varchar(8);
    DECLARE v_discount int(11);
    DECLARE v_credit_price decimal(15,2);
    DECLARE out_price decimal(15,2) DEFAULT 0;
    
    IF in_credit_code <> '' OR in_credit_code IS NOT NULL THEN
		SELECT CASE WHEN in_pack_dtl_id = '' OR in_pack_dtl_id = NULL THEN 0 ELSE 1 END INTO v_pack_dtl_cnt;
    END IF;
    
    SET v_price = in_regular_price;
    
    /* 1. Apply coupon price */
    SELECT COUNT(coupon_code) INTO v_coupon_cnt
    FROM mis.tbl_coupon_tgt
    WHERE coupon_code = in_coupon_code AND is_use = '0' LIMIT 1
    ;
    
    SELECT COUNT(coupon_code) INTO v_coupon_scope_cnt
    FROM mis.tbl_coupon_scope
    WHERE coupon_code = in_coupon_code
    AND pack_id = in_pack_id 
    AND in_pack_dtl_id = (CASE WHEN in_pack_dtl_id IS NULL OR in_pack_dtl_id ='' THEN in_pack_dtl_id ELSE pack_dtl_id END)
    ;
    
    IF v_coupon_cnt >= 1 AND v_coupon_scope_cnt >= 1 AND v_price > 0 THEN
    
		SELECT discout_method, discount INTO v_discout_method, v_discount
        FROM mis.tbl_coupon
        WHERE coupon_code = in_coupon_code
        ;
        
        IF v_discout_method = 2 THEN
			SELECT v_price - TRUNCATE((v_price * (v_discount / 100)), 2) INTO v_price;
		ELSE
			SET v_price = v_price - v_discount;
		END IF;
    
    END IF;
    
    
    /* 2. Apply credit code price */
    IF v_pack_dtl_cnt = 0 THEN
    
		SELECT COUNT(a.credit_code) INTO v_credit_cnt
		FROM mis.tbl_creditcode a
        JOIN mis.tbl_creditcode_product b ON a.cc_id=b.cc_id
		WHERE a.credit_code = in_credit_code
		AND b.pack_id = in_pack_id
		AND a.is_cert = 'y' AND a.use_status = '00'
		;
    
    ELSE
    
		SELECT COUNT(a.credit_code) INTO v_credit_cnt
		FROM mis.tbl_creditcode a
        JOIN mis.tbl_creditcode_product b ON a.cc_id=b.cc_id
		WHERE a.credit_code = in_credit_code
		AND b.pack_id = in_pack_id AND b.pack_dtl_id = in_pack_dtl_id
		AND a.is_cert = 'y' AND a.use_status = '00'
		;
    
    END IF;
    
    IF v_credit_cnt = 1 AND v_price > 0 THEN
    
		SELECT c_price INTO v_credit_price
        FROM mis.tbl_creditcode
        WHERE credit_code = in_credit_code
        ;
        
        SET v_price = v_price - v_credit_price;
    
    END IF;
    
    
    /* 3. Set price */
    IF v_price < 0 THEN
		SET v_price = 0;
    END IF;
    
    SET out_price = v_price;

RETURN out_price;
END//
DELIMITER ;


-- Dumping structure for function mis.fn_GetId
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetId`() RETURNS varchar(20) CHARSET utf8
BEGIN

	DECLARE v_ncode VARCHAR(3);
    DECLARE v_date VARCHAR(17);
    DECLARE out_id VARCHAR(20);
    
    SELECT LEFT(DATE_FORMAT(NOW(3), '%Y%m%d%H%i%s%f'), 17) INTO v_date;
    
    -- SELECT CONCAT(v_ncode, '', v_date) INTO out_id;

	RETURN v_date;

END//
DELIMITER ;


-- Dumping structure for function mis.fn_GetRegularPrice
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetRegularPrice`(

	in_pack_id int(11)
    ,in_pack_dtl_id int(11)
    ,in_months int(11)
    ,in_members int(11)
    ,in_host varchar(100)
    
) RETURNS decimal(15,2)
BEGIN

    DECLARE v_pack_dtl_id int(11);
    DECLARE v_product_price decimal(15,2) DEFAULT 0;
    DECLARE v_months int(11);
    DECLARE v_members int(11);
    DECLARE v_price decimal(15,2) DEFAULT 0;
    DECLARE out_price decimal(15,2) DEFAULT 0;
    
    /* 1. Get product price */
    SELECT CASE WHEN in_pack_dtl_id = '' OR in_pack_dtl_id = NULL THEN 0 ELSE 1 END INTO v_pack_dtl_id;
    
    IF v_pack_dtl_id = 0 THEN
		
        SELECT 
        case in_host when 'ael.kenglish.kr' then product_price_ko
        when 'ael.eigolive.jp' then product_price_jp else product_price end 
        INTO v_product_price
		FROM mis.tbl_package
		WHERE pack_id = in_pack_id
        ;
        
    ELSE
		
        SELECT 
        case in_host when 'ael.kenglish.kr' then product_price_ko
        when 'ael.eigolive.jp' then product_price_jp else product_price end 
        INTO v_product_price
		FROM mis.tbl_package_dtl
		WHERE pack_id = in_pack_id AND pack_dtl_id = in_pack_dtl_id
        ;
        
    END IF;
    
    
    /* 2. Make discount price */
    SELECT IFNULL(in_months, 1) INTO v_months;
    SELECT IFNULL(in_members, 1) INTO v_members;
    
    SET v_price = v_product_price * v_months * v_members;
    
    
    /* 3. Set price */
    IF v_price < 0 THEN
		SET v_price = 0;
    END IF;
    
    SET out_price = v_price;

RETURN out_price;
END//
DELIMITER ;


-- Dumping structure for function mis.fn_GetValidCreditcode
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_GetValidCreditcode`(in_creditcode VARCHAR(12), in_mem int) RETURNS int(11)
BEGIN

    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_memcnt INT DEFAULT 0;
    DECLARE v_usecnt INT DEFAULT 0;
    DECLARE v_dup_mem INT DEFAULT 0;
    SET v_valid = 0;
    
	SELECT member_cnt INTO v_memcnt FROM mis.tbl_creditcode where credit_code=in_creditcode;
	SELECT Count(*) INTO v_usecnt FROM ( SELECT credit_code FROM mis.tbl_subscription_dtl group by credit_code, sid ) A 
    where credit_code=in_creditcode;
    
    SELECT Count(*) INTO v_dup_mem FROM tbl_creditcode_used 
    where credit_code=in_creditcode and user_id=in_mem;
	
    IF v_memcnt > v_usecnt and v_dup_mem = 0 THEN
		SET v_valid = 1;
    END IF;
    
	RETURN v_valid;

END//
DELIMITER ;


-- Dumping structure for function mis.fn_get_lvl
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `fn_get_lvl`(value INT) RETURNS int(11)
    READS SQL DATA
BEGIN

    DECLARE v_id INT;
    DECLARE v_parent INT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET @id = NULL;
 
    SET v_parent = @id;
    SET v_id = -1;
 
    IF @id IS NULL THEN
        RETURN NULL;
    END IF;
 
    LOOP
  SELECT 
   MIN(dealer_id)
  INTO @id FROM
   mis.tbl_dealer
  WHERE
   dealer_mid = v_parent
   AND dealer_id > v_id;
        
  IF @id IS NOT NULL OR v_parent = @start_with THEN
   SET @level = @level + 1;
   RETURN @id;
  END IF;
    
  SET @level := @level - 1;
    
  SELECT 
   dealer_id, dealer_mid
  INTO v_id , v_parent 
  FROM
   mis.tbl_dealer
  WHERE
   dealer_id = v_parent;
    END LOOP;
END//
DELIMITER ;


-- Dumping structure for procedure mis.INSERT_PROC_PAYMENT
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `INSERT_PROC_PAYMENT`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(17),
    IN in_ssl_approval_code VARCHAR(200),
	IN in_ssl_exp_date VARCHAR(4), 
	IN in_ssl_amount DECIMAL(15,2), 
    IN in_ssl_salestax DECIMAL(15,2), 
	IN in_ssl_txn_id VARCHAR(200), 
	IN in_ssl_txn_time DATETIME, 
	IN in_ssl_card_number VARCHAR(45), 
	IN in_ssl_avs_address VARCHAR(500), 
	IN in_ssl_avs_zip VARCHAR(10),
	IN in_credit_type VARCHAR(45), 
	IN in_fname VARCHAR(45),
	IN in_lname VARCHAR(45), 
	IN in_phone_number VARCHAR(45),
	IN in_strCity VARCHAR(45),
	IN in_strState VARCHAR(45), 
	IN in_ssl_cvv2cvc2 VARCHAR(45),
	IN in_ssl_result VARCHAR(45),
	IN in_ssl_result_message VARCHAR(45),
	IN in_ssl_cvv2_response VARCHAR(45),
	IN in_ssl_avs_response VARCHAR(45),    
	OUT out_result INT
)
BEGIN

    DECLARE v_result INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
	
    SELECT pay_id
    INTO @pay_id
    FROM mis.tbl_pay_info ORDER BY pay_id DESC LIMIT 1;
    
    INSERT INTO mis.tbl_user_payment_info
		(pay_id,
		sid,
		tx_id,
		user_id,
		approval_code,
		card_type,
		ssl_card_number,
		ssl_exp_date,
		ssl_cvv2cvc2,
		ssl_avs_address,
		ssl_avs_zip,
		ssl_amount,
		ssl_salestax,
		fname,
		lname,
		phone,
		city,
		state,
		ssl_result,
		ssl_result_message,
		ssl_cvv2_response,
		ssl_avs_response,
        tx_time
        )
		VALUES
		(
		@pay_id ,
		in_sid ,
		in_ssl_txn_id ,
		in_user_id ,
		in_ssl_approval_code ,
		in_credit_type ,
		in_ssl_card_number ,
		in_ssl_exp_date ,
		in_ssl_cvv2cvc2 ,
		in_ssl_avs_address ,
		in_ssl_avs_zip ,
		in_ssl_amount ,
		in_ssl_salestax ,
		in_fname ,
		in_lname ,
		in_phone_number ,
		in_strCity ,
		in_strState ,
		in_ssl_result ,
		in_ssl_result_message ,
		in_ssl_cvv2_response ,
		in_ssl_avs_response ,
        in_ssl_txn_time
        );

                        
        
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;
    

END//
DELIMITER ;


-- Dumping structure for procedure mis.INSERT_USER_PAYINFO
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `INSERT_USER_PAYINFO`(
	IN in_user_id INT(11),
	IN in_credit_type VARCHAR(45), 
    IN in_cardnumber VARCHAR(45),
    IN in_expmm VARCHAR(2),
    IN in_expyy VARCHAR(2),
	IN in_fname VARCHAR(45),
	IN in_lname VARCHAR(45), 
	IN in_phone_number VARCHAR(45),
    IN in_baddress VARCHAR(500),
	IN in_city VARCHAR(45),
	IN in_state VARCHAR(45), 
	IN in_zip VARCHAR(45),
	IN in_site VARCHAR(500),
	OUT out_result INT
)
BEGIN

    DECLARE v_result INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
		
	SELECT ifnull(MAX(userseq),0) + 1
    INTO @useq
    FROM mis.tbl_user_credit_card
    WHERE userid = in_user_id;
	
    INSERT INTO mis.tbl_user_credit_card
		(userid,
		userseq,
		cardtype,
		cardnumber,
		expmm,
		expyy,
		fname,
		lname,
		phonenumber,
		baddress,
		city,
		state,
		zip,
		site)
		VALUES
		(
        in_user_id ,
		@useq ,
		in_credit_type ,
		in_cardnumber ,
		in_expmm ,
		in_expyy ,
		in_fname ,
		in_lname ,
		in_phone_number ,
		in_baddress ,
		in_city ,
		in_state ,
		in_zip ,
		in_site 
        );


                        
        
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;
    

END//
DELIMITER ;


-- Dumping structure for procedure mis.PAKSA_test
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PAKSA_test`(IN IN_parent INT)
BEGIN

DECLARE abc VARCHAR(255);
DECLARE v_cate_c VARCHAR(255);

DEClARE cate_c_cur CURSOR FOR 
select content_name from v_yourview;

SET @GetName1 = CONCAT('CREATE OR REPLACE VIEW `v_yourview` AS ', 'SELECT content_name FROM paksa.tbl_content  where tid = 3232;');
                                             PREPARE stmt1 FROM @GetName1;

EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
                                                            
  
                     OPEN cate_c_cur;
                        get_cate_c: LOOP
                        
                     FETCH cate_c_cur INTO v_cate_c;
                            
                            
select v_cate_c;
                                                            
                     END LOOP get_cate_c;                               
                            
 
 END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_EXTEND_SUBSCRIPTION
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_EXTEND_SUBSCRIPTION`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(20),
    IN in_sdtl_id VARCHAR(20),
    IN in_month_cnt INT(11),
    IN in_site VARCHAR(2),
    IN in_date VARCHAR(8),
    OUT out_result VARCHAR(100),
	OUT out_msg VARCHAR(5000)
)
BEGIN

    DECLARE v_result INT ;

    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
	DECLARE v_month_cnt INT(11);
    DECLARE v_new_date VARCHAR(10);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_error VARCHAR(20);
	DECLARE v_idx INT(2);
    DECLARE v_cnt INT(3);
    DECLARE v_cnt_new INT(3);
    DECLARE v_msg VARCHAR(5000);
    
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
    
    SELECT LEFT(DATE_FORMAT(CONVERT_TZ(NOW(3), 'UTC', 'Asia/Seoul'), '%Y%m%d%H%i%s%f'), 17) INTO @new_sid;
    
    INSERT INTO mis.tbl_subscription
    (
    sid, sub_dt, user_id, fullname, sdtl_div, sub_status, 
    order_id, pay_id, is_paid, is_admin_paid, create_id, create_time, buyno
    )
    SELECT 
    @new_sid, in_date, user_id, fullname, sdtl_div, sub_status, 
    order_id, NULL, '2', is_admin_paid, create_id, CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul'), buyno
    FROM mis.tbl_subscription  
    WHERE sid = in_sid
    ;
    
	IF in_sdtl_id ='' THEN
		INSERT INTO mis.tbl_subscription_dtl
		(
		sid, sdtl_id, 
		is_pack, pack_id, pack_dtl_id, product_amt, 
		discount_amt, pay_amt, sdtl_div, use_stdt, use_eddt, month_cnt, member_cnt,
		free_month, is_add, add_member_cnt, add_month_cnt, credit_code, order_id,order_dtl_id,
		group_id, class_id, create_time, update_time
		)
		SELECT 
		@new_sid, concat(@new_sid,right(sdtl_id, 3)), 
		is_pack, pack_id, pack_dtl_id, product_amt, 
		discount_amt, pay_amt, sdtl_div, use_stdt, 
        DATE_FORMAT(DATE_ADD(use_eddt,INTERVAL in_month_cnt month),'%Y%m%d'), 
        month_cnt, member_cnt,
		free_month, 
        '1', 
        add_member_cnt, 
        in_month_cnt, 
        credit_code, order_id,order_dtl_id,
		group_id, class_id, CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul'), NULL
		FROM mis.tbl_subscription_dtl  
		WHERE sid = in_sid
	;
	ELSE
		INSERT INTO mis.tbl_subscription_dtl
		(
		sid, sdtl_id, 
		is_pack, pack_id, pack_dtl_id, product_amt, 
		discount_amt, pay_amt, sdtl_div, use_stdt, use_eddt, month_cnt, member_cnt,
		free_month, is_add, add_member_cnt, add_month_cnt, credit_code, order_id,order_dtl_id,
		group_id, class_id, create_time, update_time
		)
		SELECT 
		@new_sid, concat(@new_sid,right(sdtl_id, 3)), 
		is_pack, pack_id, pack_dtl_id, product_amt, 
		discount_amt, pay_amt, sdtl_div, use_stdt, 
        DATE_FORMAT(DATE_ADD(use_eddt,INTERVAL in_month_cnt month),'%Y%m%d'), 
        month_cnt, member_cnt,
		free_month, 
        '1', 
        add_member_cnt, 
        in_month_cnt, 
        credit_code, order_id,order_dtl_id,
		group_id, class_id, CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul'), NULL
		FROM mis.tbl_subscription_dtl  
		WHERE sid = in_sid
        AND sdtl_id = in_sdtl_id
	;
    END IF;
    

    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;

    SET out_result =  v_result;
    SET out_msg = concat('There are ', v_result, ' courses below in learning <br> and You may add ', v_cnt_new,' new courses until <span style="color:red;">', v_new_date,'</span>.<br><br>', v_msg);
     
END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_GROUP_CONFIRM
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_GROUP_CONFIRM`(
	IN in_group_id INT(11),
    IN in_class_id INT(11),
    IN in_confirm_status VARCHAR(8),
    OUT out_result INT
)
BEGIN

	DECLARE v_finished INT DEFAULT 0;
	DECLARE v_result INT DEFAULT 0;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    /* Confirm Status (root_code : CONFIRM)
     * 
     * 1 : Waiting
     * 2 : Confirmed request
     * 3 : Confirmed
     * 4 : Confirmed canceled
     * 5 : Ban
     */
    
    START TRANSACTION;
    
    IF in_confirm_status = '3' THEN
    
		/* INSERT CLASS USER */
		INSERT common.tbl_class_user
		(group_id, class_id, user_id, create_time)
		SELECT  in_group_id
			   ,in_class_id
			   ,user_id
			   ,NOW()
		FROM common.tbl_group_user a
		WHERE group_id = in_group_id AND class_id = in_class_id
		AND confirm_status = in_confirm_status
		AND user_id NOT IN (SELECT user_id FROM common.tbl_class_user
							WHERE group_id = a.group_id AND class_id = a.class_id)
		;
    
    END IF;
    
    IF in_confirm_status = '4' OR in_confirm_status = '5' THEN
    
		/* DELETE CLASS USER */
		DELETE FROM common.tbl_class_user
        WHERE group_id = in_group_id AND class_id = in_class_id
        AND user_id IN (SELECT user_id FROM common.tbl_group_user
						WHERE group_id = in_group_id AND class_id = in_class_id AND confirm_status = in_confirm_status)
        ;
    
    END IF;
    
    CALL paksa.PROC_GROUP_LEARN(in_group_id, in_class_id, v_result);
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;

END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_GROUP_PAYCONFIRM
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_GROUP_PAYCONFIRM`(
	IN in_confirrm_id INT(11),
	IN in_user_id INT(11),
    IN in_group_id INT(11),
    IN in_class_id INT(11),
	OUT out_result INT
)
BEGIN

	DECLARE v_today DATETIME;
	DECLARE v_buyno VARCHAR(20);
    DECLARE v_pid INT(11);
    DECLARE v_rid INT(11);
    DECLARE v_month_cnt INT(11);
    DECLARE v_learn_stdt VARCHAR(8);
    DECLARE v_learn_eddt VARCHAR(8);    
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_cnt_his INT DEFAULT 0;
    DECLARE v_his_seq INT(11);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
    
    DECLARE v_learn_method INT ;
    DECLARE temp_pid INT DEFAULT 0;
    
    DECLARE class_learn_cur CURSOR FOR
	SELECT pid, rid
      FROM common.tbl_class_learn a 
     WHERE group_id = in_group_id AND class_id = in_class_id
       AND buyno = (
			  SELECT DISTINCT buyno
                FROM common.tbl_class_learn
			   WHERE group_id = in_group_id
                 AND class_id = in_class_id
		   )
	 ORDER BY a.class_learn_id
	;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
    
    -- buyno 구하기
    SELECT DISTINCT buyno 
      INTO v_buyno
      FROM common.tbl_class_learn
	 WHERE group_id = in_group_id
       AND class_id = in_class_id
	;
    
    -- learn_method 구하기
    SELECT learn_method
      INTO v_learn_method
      FROM paksa.tbl_class_learn_method
	 WHERE group_id = in_group_id
       AND class_id = in_class_id
	;
    -- 학습 기간 구하기
    SELECT MAX(c.month_cnt)
      INTO v_month_cnt
      FROM mis.tbl_subscription b 
		   JOIN mis.tbl_subscription_dtl c ON b.sid = c.sid 
	 WHERE buyno = v_buyno
	;
    
    -- 현재 시간 구하기
    SELECT DATE_FORMAT(CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul'), '%Y%m%d') INTO v_today;
    
    -- 학습 일자 만들기
    SELECT IFNULL(MAX(learn_stdt), v_today), 
		   IFNULL(MAX(learn_eddt), DATE_ADD(v_today, INTERVAL v_month_cnt MONTH))
      INTO v_learn_stdt, v_learn_eddt
      FROM common.tbl_class_learn
	 WHERE group_id = in_group_id AND class_id = in_class_id
	;
    
    SET v_finished = 0;
    
    OPEN class_learn_cur;
	get_class_learn_cur: LOOP
    
    FETCH class_learn_cur
	INTO v_pid, v_rid;
    
		IF v_finished = 1 THEN
			LEAVE get_class_learn_cur;
		END IF;
        
        -- 학습 정보 존재여부 확인
        SELECT IFNULL((SELECT COUNT(*)
						 FROM paksa.tbl_learn
						WHERE userid = in_user_id
						  AND buyno = v_buyno
						  AND pid = v_pid
						  AND rid = v_rid
					  ),0) AS cnt
          INTO v_cnt
		;
        
        IF v_cnt = 0 THEN
			
			-- 학습 정보 백업 내역 존재여부 확인
			SELECT IFNULL((SELECT COUNT(*)
							 FROM paksa.tbl_learn_history
							WHERE userid = in_user_id
							  AND buyno = v_buyno
							  AND pid = v_pid
							  AND rid = v_rid
							GROUP BY userid, buyno, pid, rid
						  ),0) AS cnt
			  INTO v_cnt_his
			;
			
			-- 백업 내역이 없다면 신청 내역으로 생성
			IF v_cnt_his = 0 THEN
				
				INSERT INTO paksa.tbl_learn
				(
					 userid
					,buyno
					,pid
					,rid
					,finish_yn
					,use_stdt
					,use_eddt
				)
				VALUES
				(
					 in_user_id
					,v_buyno
					,v_pid
					,v_rid
					,'n'
					,v_learn_stdt
					,v_learn_eddt
				)
                ;
			
                -- 학습방식 데이터 생성
                /*
                IF v_pid != temp_pid THEN
					SET temp_pid = v_pid;
                    
					INSERT INTO paksa.tbl_user_learn_method
					(
						 user_id
						,buyno
						,pid
						,learn_method
					)
					VALUES
					(
						 in_user_id
						,v_buyno
						,v_pid
						,v_learn_method
					)
					;
                    
                END IF;
                */
			-- 백업 내역이 있다면 백업 내역으로 생성
			ELSE
			
				SELECT MAX(his_seq) INTO v_his_seq
				  FROM paksa.tbl_learn_history
				 WHERE userid = in_user_id
				   AND buyno = v_buyno
				   AND pid = v_pid
				   AND rid = v_rid
				 GROUP BY userid, buyno, pid, rid
				;
				
				INSERT INTO paksa.tbl_learn
				(
					userid, buyno, pid, rid, lid, cid, iid, eid, 
					rstep, lstep, cstep, dgroup, dstep, istep, 
					l_estep, c_estep, resources_type, exam_position, 
					finish_yn, learnst_time, learned_time, use_stdt, use_eddt
				)
				SELECT 
					userid, buyno, pid, rid, lid, cid, iid, eid, 
					rstep, lstep, cstep, dgroup, dstep, istep, 
					l_estep, c_estep, resources_type, exam_position, 
					finish_yn, learnst_time, learned_time, use_stdt, use_eddt
				  FROM paksa.tbl_learn_history
				 WHERE userid = in_user_id
				   AND buyno = v_buyno
				   AND pid = v_pid
				   AND rid = v_rid
				   AND his_seq = v_his_seq
				;
				   
			END IF;
        
        END IF;
         
    END LOOP get_class_learn_cur;
    
    CLOSE class_learn_cur;
    
    -- tbl_class_user 결제 확인 처리
    UPDATE common.tbl_class_user
       SET pay_status = '2', confirm_dt = CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul')
     WHERE group_id = in_group_id AND class_id = in_class_id AND user_id = in_user_id
	;
    
	IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
	SET out_result = v_result;
END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_GROUP_PAYCONFIRM_CANCEL
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_GROUP_PAYCONFIRM_CANCEL`(
	IN in_user_id INT(11),
	IN in_group_id INT(11),
    IN in_class_id INT(11),
	OUT out_result INT
)
BEGIN
	DECLARE v_buyno VARCHAR(20);
    DECLARE v_his_seq INT(11);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
        
    SELECT distinct buyno INTO v_buyno
      FROM common.tbl_class_learn
	 WHERE group_id = in_group_id
       AND class_id = in_class_id
	;
	
    IF v_buyno = NULL OR v_buyno = '' THEN
		SET v_result = -1;
    END IF;
 
    START TRANSACTION;
    
    -- 학습 정보 백업 일련번호 구하기
    SELECT IFNULL(MAX(his_seq)+1, 1) INTO v_his_seq
      FROM paksa.tbl_learn_history
     WHERE userid = in_user_id
       AND buyno  = v_buyno
	 GROUP BY userid, buyno
	;
    
    IF v_his_seq IS NULL THEN
		SET v_his_seq = 1;
    END IF;
    
    -- 삭제할 학습 정보 백업
    INSERT INTO paksa.tbl_learn_history
    (
		userid, buyno, pid, rid, his_seq, lid, cid, iid, eid, 
        rstep, lstep, cstep, dgroup, dstep, istep, 
        l_estep, c_estep, resources_type, exam_position, 
        finish_yn, learnst_time, learned_time, use_stdt, use_eddt, 
        his_date
    )
    SELECT 
		userid, buyno, pid, rid, v_his_seq, lid, cid, iid, eid, 
		rstep, lstep, cstep, dgroup, dstep, istep, 
        l_estep, c_estep, resources_type, exam_position, 
        finish_yn, learnst_time, learned_time, use_stdt, use_eddt,
		CONVERT_TZ(NOW(), 'UTC', 'Asia/Seoul')
	  FROM paksa.tbl_learn
     WHERE userid = in_user_id
       AND buyno  = v_buyno
	;
    
    -- 학습 정보 삭제
    DELETE FROM paksa.tbl_learn
     WHERE userid = in_user_id
       AND buyno  = v_buyno;
       
	-- tbl_class_user 결제 취소 처리
    UPDATE common.tbl_class_user
       SET pay_status = '1', confirm_dt = NULL
     WHERE group_id = in_group_id AND class_id = in_class_id AND user_id = in_user_id
	;
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;
END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_PACKAGE_REVISION
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_PACKAGE_REVISION`(IN IN_pack_id INT, IN IN_pack_dtl_id INT, OUT OUT_result INT)
BEGIN

DECLARE abc VARCHAR(255);
DECLARE v_cate_c VARCHAR(255);

DEClARE cate_c_cur CURSOR FOR 
select content_name from v_yourview;

SET @GetName1 = CONCAT('CREATE OR REPLACE VIEW `v_yourview` AS ', 'SELECT content_name FROM paksa.tbl_content  where tid = 3232;');
															PREPARE stmt1 FROM @GetName1;

EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
                                                            
  
							OPEN cate_c_cur;
								get_cate_c: LOOP
								
							FETCH cate_c_cur INTO v_cate_c;
                            
                            
select v_cate_c;
                                                            
							END LOOP get_cate_c;	                            
                            
 
 END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_SUBSCRIPTION
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_SUBSCRIPTION`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(17),
    IN in_pay_method VARCHAR(8),
    IN in_pay_status VARCHAR(8),
	OUT out_result INT
)
BEGIN

    DECLARE v_sid VARCHAR(17);
    DECLARE v_sdtl_id VARCHAR(20);
    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
    DECLARE v_month_cnt INT(11);
    DECLARE v_member_cnt INT(11);
    DECLARE v_add_member_cnt INT(11);
    DECLARE v_add_month_cnt INT(11);
    DECLARE v_group_id INT(11);
    DECLARE v_class_id INT(11);
    DECLARE v_pay_id VARCHAR(20);
    DECLARE v_use_stdt VARCHAR(8);
    DECLARE v_use_eddt VARCHAR(8);
    
    DECLARE v_pid INT(11);
    DECLARE v_rid INT(11);
    DECLARE v_learn_method INT ;
    DECLARE temp_pid INT DEFAULT 0;
    
    DECLARE v_subtype VARCHAR(1); -- 1 개인 2 클래스
    DECLARE v_buyno VARCHAR(20);
    
    DECLARE v_owner_id INT(11);
    DECLARE v_pay_status VARCHAR(8);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
    
    DECLARE v_error VARCHAR(20);
	DECLARE v_idx INT(2);
    
    DECLARE subscription_dtl_cur CURSOR FOR
	SELECT a.sid, b.sdtl_id, b.pack_id, b.pack_dtl_id, b.month_cnt, b.member_cnt, 
		   IFNULL(b.add_member_cnt,0) AS add_member_cnt, IFNULL(b.add_month_cnt,0) AS add_month_cnt, b.group_id, b.class_id, c.pid, c.rid
     , ifnull(d.use_stdt, DATE_FORMAT(now(),'%Y%m%d')) as use_stdt, ifnull(d.use_eddt, DATE_FORMAT(date_add(date_add(now(), interval 1 month), interval  -1 day),'%Y%m%d')) as use_eddt
    -- , d.use_stdt, d.use_eddt
    FROM mis.tbl_subscription a JOIN mis.tbl_subscription_dtl b ON a.sid = b.sid LEFT OUTER JOIN mis.tbl_package_dtl c ON b.pack_id = c.pack_id AND b.pack_dtl_id = c.pack_dtl_id
	LEFT OUTER JOIN common.tbl_class d ON b.group_id = d.group_id AND b.class_id = d.class_id
    WHERE a.user_id = in_user_id AND a.is_paid = '2' AND a.sid = in_sid
    ;

    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
  
    SET v_finished = 0;
    
    SELECT mis.fn_GetId() INTO v_pay_id;
    
    SET v_error = '1';
    
	INSERT INTO mis.tbl_pay_info
	(pay_id, pay_dt, user_id, fullname, pay_method, cost, tax, discount_cost, real_cost, pay_status, create_time)
	SELECT v_pay_id, DATE_FORMAT(now(),'%Y%m%d'), c.user_id, c.fullname, in_pay_method, d.cost, d.tax, d.discount_cost, d.real_cost, in_pay_status, now()
	FROM
	mis.tbl_subscription c
	JOIN 
	(
	SELECT 
		 a.sid,
		SUM(product_amt) as cost, ((SUM(product_amt) - SUM(discount_amt)) * month_cnt * member_cnt * 0.1) as tax, 
        SUM(discount_amt) as discount_cost, 
        SUM(pay_amt) +((SUM(product_amt) - SUM(discount_amt)) * month_cnt * member_cnt * 0.1) as real_cost
		FROM tbl_subscription a 
		JOIN tbl_subscription_dtl b
		  ON a.sid = b.sid
	   WHERE a.sid = in_sid
		 AND a.is_paid = '2'
		 GROUP BY a.sid, b.month_cnt, b.member_cnt
		 ) d
	ON c.sid = d.sid;
		
        
	SELECT mis.fn_GetBuyno(in_sid, 999) AS buyno INTO v_buyno;
        
    /* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    SET v_error = '2';
    OPEN subscription_dtl_cur;
	get_subscription_dtl_cur: LOOP
    
    FETCH subscription_dtl_cur
	INTO v_sid, v_sdtl_id, v_pack_id, v_pack_dtl_id, v_month_cnt, v_member_cnt, v_add_member_cnt, v_add_month_cnt, v_group_id, v_class_id, v_pid, v_rid, v_use_stdt, v_use_eddt;
    
		SET v_idx = v_idx +1;
		IF v_finished = 1 THEN
			LEAVE get_subscription_dtl_cur;
		END IF;        
        
        /*사용일자 UPDATE*/
        UPDATE mis.tbl_subscription_dtl 
        SET use_stdt = v_use_stdt
		  , use_eddt = v_use_eddt
		WHERE sid = v_sid
		  AND sdtl_id = v_sdtl_id;
        
        /*  그룹 신청일경우 */
        IF v_group_id IS NOT NULL AND v_class_id IS NOT NULL AND v_group_id != '' AND v_class_id != '' THEN
			SET v_subtype = '2';
			
            UPDATE common.tbl_class
			SET
				active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
            IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
				INSERT INTO common.tbl_class_learn
				(class_id, group_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn
				 , learn_stdt, learn_eddt
				)
				VALUES
				(
					 v_class_id
					,v_group_id
					,v_buyno
					,v_pack_id
					,v_pack_dtl_id
					,NOW()
					,v_pid
					,v_rid
					,'y'
					,v_use_stdt
					,v_use_eddt
				);
            
            END IF;
        ELSE
       
            /*
            SELECT user_id INTO v_owner_id FROM common.tbl_group WHERE group_id = v_group_id;
            SELECT pay_status INTO v_pay_status FROM mis.tbl_pay_info WHERE pay_id = v_pay_id;
            
            
            IF in_user_id != v_owner_id THEN
             IF v_pay_status = '2' THEN
            
				 CALL paksa.PROC_GROUP_LEARN(in_group_id, in_class_id, v_result);
                
                IF v_result = 0 THEN
                
					/* UPDATE tbl_class_user
					UPDATE common.tbl_class_user
					SET
						 pay_status = '2'	-- PAYSTATE : Payment Complete(2)
					WHERE
						group_id = v_group_id AND class_id = v_class_id AND user_id = v_user_id
					;
                
					END IF;
            
				END IF;
			
			END IF;
    */       
    SET v_subtype = '1';
          
           IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
           
			INSERT INTO common.tbl_user_learn
			(user_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn, learn_stdt, learn_eddt)
			VALUES 
			(
			in_user_id, v_buyno, v_pack_id, v_pack_dtl_id, now(), v_pid, v_rid, 'y', v_use_stdt, v_use_eddt
			);
		
        
			INSERT INTO paksa.tbl_learn
			(userid, buyno, pid, rid, finish_yn
			 , use_stdt, use_eddt
			)
			VALUES
			(
				 in_user_id
				,v_buyno
				,v_pid
				,v_rid
				,'n'
				,v_use_stdt
				,v_use_eddt
			);
				
                -- 학습방식 데이터 생성
                IF v_pid != temp_pid THEN
					SET temp_pid = v_pid;
                    
                    SELECT learn_method INTO v_learn_method FROM paksa.tbl_product WHERE pid = v_pid;
                    
					INSERT INTO paksa.tbl_user_learn_method
					(
						 user_id
						,buyno
						,pid
						,learn_method
					)
					VALUES
					(
						 in_user_id
						,v_buyno
						,v_pid
						,v_learn_method
					)
					;
                    
                END IF;	
            END IF;
            
		END IF;
    
    END LOOP get_subscription_dtl_cur;
    
    CLOSE subscription_dtl_cur;
    /*
    IF v_subtype = '2' THEN
	
    /* UPDATE tbl_class
            
			UPDATE common.tbl_class
			SET
				 use_stdt      = v_use_stdt
				,use_eddt      = DATE_FORMAT(DATE_ADD(v_use_stdt, INTERVAL v_month_cnt + v_add_month_cnt MONTH), '%Y%m%d')
				,months        = v_month_cnt + v_add_month_cnt
				,members       = v_member_cnt + v_add_member_cnt
				,capa          = CASE WHEN (v_member_cnt + v_add_members) > capa THEN v_member_cnt + v_add_member_cnt ELSE capa END
				,active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
    END IF;
      */
      
	/* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		is_paid = '1'	-- is_paid : Subscription Complete(1)
	  , pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
     SET out_result = v_result;
	 -- SET out_result = v_error;
     -- SET out_result = v_idx;
    

END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_SUBSCRIPTION_DEL
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_SUBSCRIPTION_DEL`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(17),
    IN in_sdtl_id VARCHAR(20),
    IN in_pack_id INT(11),
    IN in_pack_dtl_id INT(11),
    IN in_delmst VARCHAR(1),
    IN in_group_id INT(11),
    IN in_class_id INT(11),
	OUT out_result INT
)
BEGIN

    DECLARE v_sid VARCHAR(17);
    DECLARE v_sdtl_id VARCHAR(20);
    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
    DECLARE v_delmst VARCHAR(1);
    DECLARE v_cnt INT(1);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
 
	DECLARE s_dtl_cur CURSOR FOR
		SELECT 	sdtl_id
		FROM  	mis.tbl_subscription_dtl 
		WHERE 	sid = in_sid 
		AND   	pack_id = in_pack_id
        AND   	(CASE WHEN in_group_id = '' OR in_group_id IS NULL 
					  THEN group_id IS NULL 
                      ELSE group_id = in_group_id 
				 END)-- group_id = in_group_id
        AND   	(CASE WHEN in_class_id = '' OR in_class_id IS NULL 
					  THEN class_id IS NULL 
					  ELSE class_id = in_class_id 
                 END) -- class_id = in_class_id
        AND   	(CASE WHEN (select count(*) 
						   from mis.tbl_subscription_dtl 
                           where sdtl_id = in_sdtl_id
                           and is_pack = '0') = 1 
					  THEN sdtl_id = in_sdtl_id 
                      ELSE 1 = 1 
				 END)
        ORDER BY sdtl_id
		;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;

    SET v_finished = 0;
    SET v_cnt = 0;
    
    OPEN s_dtl_cur;
	del_subscription_dtl_cur: LOOP
    
    FETCH s_dtl_cur INTO v_sdtl_id;
    
		IF v_finished = 1 THEN
			LEAVE del_subscription_dtl_cur;
		END IF;
        
        SELECT COUNT(*) INTO v_cnt
		FROM mis.tbl_subscription_discount_info
		WHERE sdtl_id = v_sdtl_id;
		
		IF v_cnt > 0 THEN
			SELECT dis_type, dis_code 
			INTO @dis_type, @dis_code
			FROM mis.tbl_subscription_discount_info
			WHERE sdtl_id = v_sdtl_id;

			DELETE FROM mis.tbl_subscription_discount_info 
			WHERE sdtl_id = v_sdtl_id;
            
            IF @dis_code IS NOT NULL THEN
				IF @dis_type = '01' THEN
					UPDATE mis.tbl_coupon_tgt SET is_use = '0', used_time = NULL
					WHERE user_id = in_user_id
					AND coupon_code = @dis_code;
				ELSE
					UPDATE mis.tbl_creditcode_product SET credit_code = NULL
					WHERE 1 = 1
					AND credit_code = @dis_code
                    AND pack_id = in_pack_id
                    AND in_pack_dtl_id = (case when '' = in_pack_dtl_id then '' else pack_dtl_id end);
                    
                    SELECT COUNT(*) INTO v_cnt
					FROM mis.tbl_creditcode_product
					WHERE credit_code = @dis_code;
                    
                    IF v_cnt = 0 THEN
						
                        UPDATE mis.tbl_creditcode 
                        SET use_status = '00', 
							is_cert = '0', 
                            paid_time = NULL, 
                            user_id = NULL
						WHERE user_id = in_user_id
						AND credit_code = @dis_code;
                        
                        DELETE FROM mis.tbl_creditcode_used WHERE user_id = in_user_id
						AND credit_code = @dis_code;
						
                    END IF;
              
				END IF;
            END IF;
        
		END IF;
        
        DELETE FROM mis.tbl_subscription_dtl 
        WHERE sdtl_id = v_sdtl_id;
               
        
    END LOOP del_subscription_dtl_cur;
    CLOSE s_dtl_cur;    
    
    
		SELECT COUNT(*) INTO v_cnt
		FROM mis.tbl_subscription_dtl
		WHERE sid = in_sid;
		
		IF v_cnt = 0 THEN
			DELETE FROM mis.tbl_subscription
			WHERE sid = in_sid AND user_id = in_user_id;
		END IF;
                        
        
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
    
    SET out_result = v_result;
    

END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_SUBSCRIPTION_JP
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_SUBSCRIPTION_JP`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(17),
    IN in_pay_method VARCHAR(8),
    IN in_pay_status VARCHAR(8),
	OUT out_result INT
)
BEGIN

    DECLARE v_sid VARCHAR(17);
    DECLARE v_sdtl_id VARCHAR(20);
    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
    DECLARE v_month_cnt INT(11);
    DECLARE v_member_cnt INT(11);
    DECLARE v_add_member_cnt INT(11);
    DECLARE v_add_month_cnt INT(11);
    DECLARE v_group_id INT(11);
    DECLARE v_class_id INT(11);
    DECLARE v_pay_id VARCHAR(20);
    DECLARE v_use_stdt VARCHAR(8);
    DECLARE v_use_eddt VARCHAR(8);
    
    DECLARE v_pid INT(11);
    DECLARE v_rid INT(11);
    DECLARE v_learn_method INT ;
    DECLARE temp_pid INT DEFAULT 0;
    
    DECLARE v_subtype VARCHAR(1); -- 1 개인 2 클래스
    DECLARE v_buyno VARCHAR(20);
    
    DECLARE v_owner_id INT(11);
    DECLARE v_pay_status VARCHAR(8);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
    
    DECLARE v_error VARCHAR(20);
	DECLARE v_idx INT(2);
    
    DECLARE subscription_dtl_cur CURSOR FOR
	SELECT a.sid, b.sdtl_id, b.pack_id, b.pack_dtl_id, b.month_cnt, b.member_cnt, 
		   IFNULL(b.add_member_cnt,0) AS add_member_cnt, IFNULL(b.add_month_cnt,0) AS add_month_cnt, b.group_id, b.class_id, c.pid, c.rid
     , ifnull(d.use_stdt, DATE_FORMAT(now(),'%Y%m%d')) as use_stdt, ifnull(d.use_eddt, DATE_FORMAT(date_add(date_add(now(), interval b.month_cnt month), interval  -1 day),'%Y%m%d')) as use_eddt
    -- , d.use_stdt, d.use_eddt
    FROM mis.tbl_subscription a JOIN mis.tbl_subscription_dtl b ON a.sid = b.sid LEFT OUTER JOIN mis.tbl_package_dtl c ON b.pack_id = c.pack_id AND b.pack_dtl_id = c.pack_dtl_id
	LEFT OUTER JOIN common.tbl_class d ON b.group_id = d.group_id AND b.class_id = d.class_id
    WHERE a.user_id = in_user_id AND a.is_paid = '2' AND a.sid = in_sid
    ;

    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
  
    SET v_finished = 0;
    
    SELECT mis.fn_GetId() INTO v_pay_id;
    
    SET v_error = '1';
    
	INSERT INTO mis.tbl_pay_info
	(pay_id, pay_dt, user_id, fullname, pay_method, cost, tax, discount_cost, real_cost, pay_status, create_time)
	SELECT v_pay_id, DATE_FORMAT(now(),'%Y%m%d'), c.user_id, c.fullname, in_pay_method, d.cost, d.tax, d.discount_cost, d.real_cost, in_pay_status, now()
	FROM
	mis.tbl_subscription c
	JOIN 
	(
	SELECT 
		 a.sid,
		SUM(pay_amt) as cost, ((SUM(pay_amt)) * 0.08) as tax, 
        -- SUM(pay_amt) as cost, ((SUM(pay_amt) - SUM(discount_amt)) * 0.08) as tax, 
        SUM(discount_amt) as discount_cost, 
        SUM(pay_amt) +((SUM(pay_amt)) * 0.08) as real_cost
		FROM tbl_subscription a 
		JOIN tbl_subscription_dtl b
		  ON a.sid = b.sid
	   WHERE a.sid = in_sid
		 AND a.is_paid = '2'
		 GROUP BY a.sid, b.month_cnt, b.member_cnt
		 ) d
	ON c.sid = d.sid;
		
        
	SELECT mis.fn_GetBuyno(in_sid, 999) AS buyno INTO v_buyno;
        
    /* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    SET v_error = '2';
    OPEN subscription_dtl_cur;
	get_subscription_dtl_cur: LOOP
    
    FETCH subscription_dtl_cur
	INTO v_sid, v_sdtl_id, v_pack_id, v_pack_dtl_id, v_month_cnt, v_member_cnt, v_add_member_cnt, v_add_month_cnt, v_group_id, v_class_id, v_pid, v_rid, v_use_stdt, v_use_eddt;
    
		SET v_idx = v_idx +1;
		IF v_finished = 1 THEN
			LEAVE get_subscription_dtl_cur;
		END IF;        
        
        /*사용일자 UPDATE*/
        UPDATE mis.tbl_subscription_dtl 
        SET use_stdt = v_use_stdt
		  , use_eddt = v_use_eddt
		WHERE sid = v_sid
		  AND sdtl_id = v_sdtl_id;
        
        /*  그룹 신청일경우 */
        IF v_group_id IS NOT NULL AND v_class_id IS NOT NULL AND v_group_id != '' AND v_class_id != '' THEN
			SET v_subtype = '2';
			
            UPDATE common.tbl_class
			SET
				active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
            IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
				INSERT INTO common.tbl_class_learn
				(class_id, group_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn
				 , learn_stdt, learn_eddt
				)
				VALUES
				(
					 v_class_id
					,v_group_id
					,v_buyno
					,v_pack_id
					,v_pack_dtl_id
					,NOW()
					,v_pid
					,v_rid
					,'y'
					,v_use_stdt
					,v_use_eddt
				);
            
            END IF;
        ELSE
       
            /*
            SELECT user_id INTO v_owner_id FROM common.tbl_group WHERE group_id = v_group_id;
            SELECT pay_status INTO v_pay_status FROM mis.tbl_pay_info WHERE pay_id = v_pay_id;
            
            
            IF in_user_id != v_owner_id THEN
             IF v_pay_status = '2' THEN
            
				 CALL paksa.PROC_GROUP_LEARN(in_group_id, in_class_id, v_result);
                
                IF v_result = 0 THEN
                
					/* UPDATE tbl_class_user
					UPDATE common.tbl_class_user
					SET
						 pay_status = '2'	-- PAYSTATE : Payment Complete(2)
					WHERE
						group_id = v_group_id AND class_id = v_class_id AND user_id = v_user_id
					;
                
					END IF;
            
				END IF;
			
			END IF;
    */       
    SET v_subtype = '1';
          
           IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
           
			INSERT INTO common.tbl_user_learn
			(user_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn, learn_stdt, learn_eddt)
			VALUES 
			(
			in_user_id, v_buyno, v_pack_id, v_pack_dtl_id, now(), v_pid, v_rid, 'y', v_use_stdt, v_use_eddt
			);
		
        
			INSERT INTO paksa.tbl_learn
			(userid, buyno, pid, rid, finish_yn
			 , use_stdt, use_eddt
			)
			VALUES
			(
				 in_user_id
				,v_buyno
				,v_pid
				,v_rid
				,'n'
				,v_use_stdt
				,v_use_eddt
			);
				
                -- 학습방식 데이터 생성
                IF v_pid != temp_pid THEN
					SET temp_pid = v_pid;
                    
                    SELECT learn_method INTO v_learn_method FROM paksa.tbl_product WHERE pid = v_pid;
                    
					INSERT INTO paksa.tbl_user_learn_method
					(
						 user_id
						,buyno
						,pid
						,learn_method
					)
					VALUES
					(
						 in_user_id
						,v_buyno
						,v_pid
						,v_learn_method
					)
					;
                    
                END IF;	
            END IF;
            
		END IF;
    
    END LOOP get_subscription_dtl_cur;
    
    CLOSE subscription_dtl_cur;
    /*
    IF v_subtype = '2' THEN
	
    /* UPDATE tbl_class
            
			UPDATE common.tbl_class
			SET
				 use_stdt      = v_use_stdt
				,use_eddt      = DATE_FORMAT(DATE_ADD(v_use_stdt, INTERVAL v_month_cnt + v_add_month_cnt MONTH), '%Y%m%d')
				,months        = v_month_cnt + v_add_month_cnt
				,members       = v_member_cnt + v_add_member_cnt
				,capa          = CASE WHEN (v_member_cnt + v_add_members) > capa THEN v_member_cnt + v_add_member_cnt ELSE capa END
				,active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
    END IF;
      */
      
	/* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		is_paid = '1'	-- is_paid : Subscription Complete(1)
	  , pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
     SET out_result = v_result;
	 -- SET out_result = v_error;
     -- SET out_result = v_idx;
    

END//
DELIMITER ;


-- Dumping structure for procedure mis.PROC_SUBSCRIPTION_KO
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` PROCEDURE `PROC_SUBSCRIPTION_KO`(
	IN in_user_id INT(11),
    IN in_sid VARCHAR(17),
    IN in_pay_method VARCHAR(8),
    IN in_pay_status VARCHAR(8),
	OUT out_result INT
)
BEGIN

    DECLARE v_sid VARCHAR(17);
    DECLARE v_sdtl_id VARCHAR(20);
    DECLARE v_pack_id INT(11);
    DECLARE v_pack_dtl_id INT(11);
    DECLARE v_month_cnt INT(11);
    DECLARE v_member_cnt INT(11);
    DECLARE v_add_member_cnt INT(11);
    DECLARE v_add_month_cnt INT(11);
    DECLARE v_group_id INT(11);
    DECLARE v_class_id INT(11);
    DECLARE v_pay_id VARCHAR(20);
    DECLARE v_use_stdt VARCHAR(8);
    DECLARE v_use_eddt VARCHAR(8);
    
    DECLARE v_pid INT(11);
    DECLARE v_rid INT(11);
    DECLARE v_learn_method INT ;
    DECLARE temp_pid INT DEFAULT 0;
    
    DECLARE v_subtype VARCHAR(1); -- 1 개인 2 클래스
    DECLARE v_buyno VARCHAR(20);
    
    DECLARE v_owner_id INT(11);
    DECLARE v_pay_status VARCHAR(8);
    
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_result INT DEFAULT 0;
    
    DECLARE v_error VARCHAR(20);
	DECLARE v_idx INT(2);
    
    DECLARE subscription_dtl_cur CURSOR FOR
	SELECT a.sid, b.sdtl_id, b.pack_id, b.pack_dtl_id, b.month_cnt, b.member_cnt, 
		   IFNULL(b.add_member_cnt,0) AS add_member_cnt, IFNULL(b.add_month_cnt,0) AS add_month_cnt, b.group_id, b.class_id, c.pid, c.rid
     , ifnull(d.use_stdt, DATE_FORMAT(now(),'%Y%m%d')) as use_stdt, ifnull(d.use_eddt, DATE_FORMAT(date_add(date_add(now(), interval 1 month), interval  -1 day),'%Y%m%d')) as use_eddt
    -- , d.use_stdt, d.use_eddt
    FROM mis.tbl_subscription a JOIN mis.tbl_subscription_dtl b ON a.sid = b.sid LEFT OUTER JOIN mis.tbl_package_dtl c ON b.pack_id = c.pack_id AND b.pack_dtl_id = c.pack_dtl_id
	LEFT OUTER JOIN common.tbl_class d ON b.group_id = d.group_id AND b.class_id = d.class_id
    WHERE a.user_id = in_user_id AND a.is_paid = '2' AND a.sid = in_sid
    ;

    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_result = -1;
    
    START TRANSACTION;
  
    SET v_finished = 0;
    
    SELECT mis.fn_GetId() INTO v_pay_id;
    
    SET v_error = '1';
    
	INSERT INTO mis.tbl_pay_info
	(pay_id, pay_dt, user_id, fullname, pay_method, cost, tax, discount_cost, real_cost, pay_status, create_time)
	SELECT v_pay_id, DATE_FORMAT(now(),'%Y%m%d'), c.user_id, c.fullname, in_pay_method, d.cost, d.tax, d.discount_cost, d.real_cost, in_pay_status, now()
	FROM
	mis.tbl_subscription c
	JOIN 
	(
	SELECT 
		 a.sid,
		SUM(pay_amt) as cost, ((SUM(pay_amt) - SUM(discount_amt)) * 0.1) as tax, 
        SUM(discount_amt) as discount_cost, 
        SUM(pay_amt)-SUM(discount_amt) +((SUM(pay_amt) - SUM(discount_amt)) * 0.1) as real_cost
		FROM tbl_subscription a 
		JOIN tbl_subscription_dtl b
		  ON a.sid = b.sid
	   WHERE a.sid = in_sid
		 AND a.is_paid = '2'
		 GROUP BY a.sid, b.month_cnt, b.member_cnt
		 ) d
	ON c.sid = d.sid;
		
        
	SELECT mis.fn_GetBuyno(in_sid, 999) AS buyno INTO v_buyno;
        
    /* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    SET v_error = '2';
    OPEN subscription_dtl_cur;
	get_subscription_dtl_cur: LOOP
    
    FETCH subscription_dtl_cur
	INTO v_sid, v_sdtl_id, v_pack_id, v_pack_dtl_id, v_month_cnt, v_member_cnt, v_add_member_cnt, v_add_month_cnt, v_group_id, v_class_id, v_pid, v_rid, v_use_stdt, v_use_eddt;
    
		SET v_idx = v_idx +1;
		IF v_finished = 1 THEN
			LEAVE get_subscription_dtl_cur;
		END IF;        
        
        /*사용일자 UPDATE*/
        UPDATE mis.tbl_subscription_dtl 
        SET use_stdt = v_use_stdt
		  , use_eddt = v_use_eddt
		WHERE sid = v_sid
		  AND sdtl_id = v_sdtl_id;
        
        /*  그룹 신청일경우 */
        IF v_group_id IS NOT NULL AND v_class_id IS NOT NULL AND v_group_id != '' AND v_class_id != '' THEN
			SET v_subtype = '2';
			
            UPDATE common.tbl_class
			SET
				active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
            IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
				INSERT INTO common.tbl_class_learn
				(class_id, group_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn
				 , learn_stdt, learn_eddt
				)
				VALUES
				(
					 v_class_id
					,v_group_id
					,v_buyno
					,v_pack_id
					,v_pack_dtl_id
					,NOW()
					,v_pid
					,v_rid
					,'y'
					,v_use_stdt
					,v_use_eddt
				);
            
            END IF;
        ELSE
       
            /*
            SELECT user_id INTO v_owner_id FROM common.tbl_group WHERE group_id = v_group_id;
            SELECT pay_status INTO v_pay_status FROM mis.tbl_pay_info WHERE pay_id = v_pay_id;
            
            
            IF in_user_id != v_owner_id THEN
             IF v_pay_status = '2' THEN
            
				 CALL paksa.PROC_GROUP_LEARN(in_group_id, in_class_id, v_result);
                
                IF v_result = 0 THEN
                
					/* UPDATE tbl_class_user
					UPDATE common.tbl_class_user
					SET
						 pay_status = '2'	-- PAYSTATE : Payment Complete(2)
					WHERE
						group_id = v_group_id AND class_id = v_class_id AND user_id = v_user_id
					;
                
					END IF;
            
				END IF;
			
			END IF;
    */       
    SET v_subtype = '1';
          
           IF v_pid IS NOT NULL AND v_rid IS NOT NULL AND v_pid != '' AND v_rid != '' THEN
           
			INSERT INTO common.tbl_user_learn
			(user_id, buyno, pack_id, pack_dtl_id, create_time, pid, rid, assign_yn, learn_stdt, learn_eddt)
			VALUES 
			(
			in_user_id, v_buyno, v_pack_id, v_pack_dtl_id, now(), v_pid, v_rid, 'y', v_use_stdt, v_use_eddt
			);
		
        
			INSERT INTO paksa.tbl_learn
			(userid, buyno, pid, rid, finish_yn
			 , use_stdt, use_eddt
			)
			VALUES
			(
				 in_user_id
				,v_buyno
				,v_pid
				,v_rid
				,'n'
				,v_use_stdt
				,v_use_eddt
			);
			
                -- 학습방식 데이터 생성
                IF v_pid != temp_pid THEN
					SET temp_pid = v_pid;
                    
                    SELECT learn_method INTO v_learn_method FROM paksa.tbl_product WHERE pid = v_pid;
                    
					INSERT INTO paksa.tbl_user_learn_method
					(
						 user_id
						,buyno
						,pid
						,learn_method
					)
					VALUES
					(
						 in_user_id
						,v_buyno
						,v_pid
						,v_learn_method
					)
					;
                    
                END IF;	
            END IF;
            
		END IF;
    
    END LOOP get_subscription_dtl_cur;
    
    CLOSE subscription_dtl_cur;
    /*
    IF v_subtype = '2' THEN
	
    /* UPDATE tbl_class
            
			UPDATE common.tbl_class
			SET
				 use_stdt      = v_use_stdt
				,use_eddt      = DATE_FORMAT(DATE_ADD(v_use_stdt, INTERVAL v_month_cnt + v_add_month_cnt MONTH), '%Y%m%d')
				,months        = v_month_cnt + v_add_month_cnt
				,members       = v_member_cnt + v_add_member_cnt
				,capa          = CASE WHEN (v_member_cnt + v_add_members) > capa THEN v_member_cnt + v_add_member_cnt ELSE capa END
				,active_status = '2'	-- ACTIVE : Activity(2)
                ,update_time   = NOW()
			WHERE
				group_id = v_group_id AND class_id = v_class_id
			; 
            
    END IF;
      */
      
	/* UPDATE tbl_subscription*/
    UPDATE mis.tbl_subscription
	SET
		is_paid = '1'	-- is_paid : Subscription Complete(1)
	  , pay_id = v_pay_id
      , buyno = v_buyno
	WHERE
		sid = in_sid
	;
    
    IF v_result < 0 THEN
		ROLLBACK;
    ELSE
		COMMIT;
    END IF;
     SET out_result = v_result;
	 -- SET out_result = v_error;
     -- SET out_result = v_idx;
    

END//
DELIMITER ;


-- Dumping structure for function mis.start_with_connect_by
DELIMITER //
CREATE DEFINER=`paksamysql`@`%` FUNCTION `start_with_connect_by`(value INT) RETURNS int(11)
    READS SQL DATA
BEGIN
        DECLARE _seq INT;
        DECLARE _pseq INT;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET @seq = NULL;

        SET _pseq = @seq;
        SET _seq = -1;

        IF @seq IS NULL THEN
                RETURN NULL;
        END IF;

        LOOP
                SELECT  MIN(seq)
                INTO    @seq
                FROM    doc_folder
                WHERE   pseq = _pseq
                        AND seq > _seq;
                
                IF @seq IS NOT NULL OR _pseq = @start_with THEN
                        SET @level = @level + 1;
                        RETURN @seq;
                END IF;

                SET @level := @level - 1;

                SELECT  seq, pseq
                INTO    _seq, _pseq
                FROM    doc_folder
                WHERE   seq = _pseq;
        END LOOP;
END//
DELIMITER ;


-- Dumping structure for view mis.v_yourview
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_yourview` (
	`content_name` VARCHAR(300) NOT NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;


-- Dumping structure for trigger mis.tbl_coupon_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY';
DELIMITER //
CREATE TRIGGER `tbl_coupon_BEFORE_INSERT` BEFORE INSERT ON `tbl_coupon` FOR EACH ROW BEGIN

 SET @UID = CONCAT('C', UPPER(LEFT(REPLACE(UUID(),'-',''), 8)), FLOOR(RAND() * 401) + 100);
 IF NOT EXISTS(SELECT * FROM tbl_coupon WHERE coupon_code = @UID) THEN
   SET NEW.coupon_code = @UID;
 ELSE
	SET NEW.coupon_code = @UID + 1;
 END IF; 
	

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping structure for trigger mis.tbl_creditcode_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY';
DELIMITER //
CREATE TRIGGER `tbl_creditcode_BEFORE_INSERT` BEFORE INSERT ON `tbl_creditcode` FOR EACH ROW BEGIN

 SET @UID = CONCAT(UPPER(LEFT(REPLACE(UUID(),'-',''), 12)));
 IF NOT EXISTS(SELECT * FROM tbl_creditcode WHERE credit_code = @UID) THEN
   SET NEW.credit_code = @UID;
 ELSE
   SET NEW.credit_code = @UID + 1;
 END IF;  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping structure for view mis.v_yourview
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_yourview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`paksamysql`@`%` SQL SECURITY DEFINER VIEW `v_yourview` AS select `paksa`.`tbl_content`.`content_name` AS `content_name` from `paksa`.`tbl_content` where (`paksa`.`tbl_content`.`tid` = 3232);
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
