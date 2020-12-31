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

-- Dumping structure for table market.tbl_contact
CREATE TABLE IF NOT EXISTS `tbl_contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mid` int(11) DEFAULT NULL COMMENT '답변시 id 저장',
  `seq` int(11) DEFAULT NULL COMMENT '답변 시퀀스',
  `sType` varchar(2) DEFAULT NULL,
  `sEmail` varchar(400) DEFAULT NULL,
  `sName` varchar(200) DEFAULT NULL,
  `sPhone` varchar(45) DEFAULT NULL,
  `sConv` varchar(1) DEFAULT NULL,
  `sContent` longtext,
  `isRead` varchar(1) DEFAULT 'N',
  `site` varchar(8) DEFAULT NULL,
  `reEmail` varchar(400) DEFAULT NULL COMMENT '답변자 email',
  `reContent` longtext COMMENT '답변자 내용',
  `dealer_id` int(11) DEFAULT NULL COMMENT '답변자',
  `reStatus` varchar(1) DEFAULT 'N' COMMENT '답변 상태 (y,n)',
  `sDate` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8;

-- Dumping data for table market.tbl_contact: ~37 rows (approximately)
DELETE FROM `tbl_contact`;
/*!40000 ALTER TABLE `tbl_contact` DISABLE KEYS */;
INSERT INTO `tbl_contact` (`id`, `mid`, `seq`, `sType`, `sEmail`, `sName`, `sPhone`, `sConv`, `sContent`, `isRead`, `site`, `reEmail`, `reContent`, `dealer_id`, `reStatus`, `sDate`) VALUES
	(5, NULL, NULL, '1', 'showkind@gmail.com', 'Tony Jun', '01062649445', '2', '', 'N', NULL, NULL, NULL, NULL, 'N', '2014-12-16 10:04:41'),
	(9, NULL, NULL, '2', 'test@gmail.com', '', '', '', 'test\r\r\nquestion \r\r\nsend\r\r\nlast \r\r\ntest  ', 'N', NULL, NULL, NULL, NULL, 'N', '2014-12-16 17:37:57'),
	(10, NULL, NULL, '1', 'showkind@gmail.com', 'test', '111111', '1', '', 'N', NULL, NULL, NULL, NULL, 'N', '2015-09-11 06:45:11'),
	(11, NULL, NULL, '2', 'showkind@gmail.com', '', '', '', 'test111', 'N', NULL, NULL, NULL, NULL, 'y', '2015-09-11 06:45:46'),
	(12, NULL, NULL, '2', 'kjs45kr@naver.com', '', '', '', 'Hello John, Keffiyeh blog actually fashion axe vegan, irony biodiesel. Cold-pressed hoodie chillwave put a bird on it aesthetic, bitters brunch meggings vegan iPhone. Dreamcatcher vegan scenester mlkshk. Ethical master cleanse Bushwick, occupy Thundercats banjo cliche ennui farm-to-table mlkshk fanny pack gluten-free. Marfa butcher vegan quinoa, bicycle rights disrupt tofu scenester chillwave 3 wolf moon asymmetrical taxidermy pour-over. Quinoa tote bag fashion axe, Godard disrupt migas church-key tofu blog locavore. Thundercats cronut polaroid Neutra tousled, meh food truck selfies narwhal American Apparel.', 'N', NULL, NULL, NULL, NULL, 'y', '2015-11-19 03:46:34'),
	(13, NULL, NULL, '1', 'kjs45kr@gmail.com', 'kimjisoo', '01054229630', '1', '', 'N', NULL, NULL, NULL, NULL, 'y', '2015-11-19 03:47:16'),
	(14, NULL, NULL, '1', 'kjs45kr@gmail.com', 'jisoo', '01054229630', '1', '', 'N', NULL, NULL, NULL, NULL, 'N', '2015-11-19 03:48:38'),
	(15, NULL, NULL, '2', 'trustswim@gmail.com', '', '', '', 'test mail', 'N', NULL, NULL, NULL, NULL, 'N', '2015-11-24 00:09:32'),
	(16, NULL, NULL, '2', 'trustswim@gmail.com', '', '', '', 'test mail', 'N', NULL, NULL, NULL, NULL, 'N', '2015-11-24 00:09:47'),
	(17, NULL, NULL, '2', 'trustswim@gmail.com', '', '', '', 'test mail', 'N', NULL, NULL, NULL, NULL, 'N', '2015-11-24 00:26:17'),
	(18, NULL, NULL, '2', 'trustswim@gmail.com', '', '', '', 'test mail', 'N', NULL, NULL, NULL, NULL, 'y', '2015-11-24 00:27:18'),
	(22, 12, 1, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45kr2222@naver.com', 'testtttttttttttttt', 0, 'y', '2015-11-24 05:24:25'),
	(23, 18, 1, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, '', 'testttttttt', 0, 'y', '2015-11-24 08:05:16'),
	(24, 12, 2, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45krrrrr@naver.com', 'message test\r\nmessage test\r\nmessage test', 2147483647, 'y', '2015-11-24 08:15:23'),
	(25, 12, 3, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45kreeee@naver.com', 'kjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.com', 2147483647, 'y', '2015-11-24 08:16:22'),
	(26, 12, 4, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs4555555kr@naver.com', 'message', 2147483647, 'y', '2015-11-24 08:17:47'),
	(27, 18, 2, '3', 'trustswim@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, 'test@gmail.com', 'test', 0, 'y', '2015-11-24 08:19:04'),
	(28, 12, 5, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs4eeeeee5kr@naver.com', 'kjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.com', 0, 'y', '2015-11-24 08:22:31'),
	(29, 18, 3, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45kr@naver.com', 'kjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.com', 0, 'y', '2015-11-24 08:23:25'),
	(30, 12, 6, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45kr@naver.com', 'testttttttttttt', 0, 'y', '2015-11-24 08:25:12'),
	(31, 12, 7, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'response@naver.com', 'abcd test email ', 2147483647, 'y', '2015-11-24 08:26:15'),
	(32, 12, 8, '3', 'kjs45kr@naver.com', NULL, NULL, NULL, NULL, NULL, NULL, 'kjs45kr@naver.com', 'kjs45kr@naver.comkjs45kr@naver.comkjs45kr@naver.com', 2147483647, 'y', '2015-11-24 08:31:21'),
	(33, 13, 1, '3', 'kjs45kr@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, 'stomline@naver.com', 'Contact TEST\r\n', 22, 'y', '2015-11-26 02:04:01'),
	(34, NULL, NULL, '2', 'whwlrwjdtls@naver.com', '', '', '', 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 07:24:04'),
	(35, NULL, NULL, '02', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, '123123123', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 07:48:06'),
	(36, NULL, NULL, '02', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, '123123123', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 07:59:27'),
	(37, NULL, NULL, '02', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, '123123123', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:00:10'),
	(38, NULL, NULL, '2', 'whwlrwjdtls@naver.com', '', '', '', 'qwerqwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:03:21'),
	(39, NULL, NULL, '2', 'whwlrwjdtls@naver.com', '', '', '', 'qwerqwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:03:45'),
	(40, NULL, NULL, '02', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:08:13'),
	(41, NULL, NULL, '02', 'trustswim@gmail.com', NULL, NULL, NULL, 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:10:30'),
	(42, NULL, NULL, '2', 'whwlrwjdtls@naver.com', '', '', '', 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:14:14'),
	(43, NULL, NULL, '2', 'whwlrwjdtls@naver.com', '', '', '', 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:15:09'),
	(44, NULL, NULL, '02', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, 'qerwrewqqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:29:43'),
	(45, NULL, NULL, '02', 'trustswim@gmail.com', NULL, NULL, NULL, 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:42:15'),
	(46, NULL, NULL, '02', 'trustswim@gmail.com', NULL, NULL, NULL, 'qwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:43:26'),
	(47, NULL, NULL, '01', 'whwlrwjdtls@naver.com', 'park sin', '123412431', '2', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:45:08'),
	(48, NULL, NULL, '1', 'whwlrwjdtls@naver.com', 'park sin', '1231231', '2', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:47:18'),
	(49, NULL, NULL, '2', 'whwlrwjdtls@naver.com', NULL, NULL, NULL, 'qwerqwerqwer', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 08:47:40'),
	(50, NULL, NULL, '2', 'trustswim@gmail.com', NULL, NULL, NULL, '111111111', 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 09:14:57'),
	(51, NULL, NULL, '1', 'whwlrwjdtls@naver.com', 'sinsin', '11111111341', '2', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-28 09:15:11'),
	(52, NULL, NULL, '1', 'oniashc@gmail.com', 'Chung Peter', '4087128784', '1', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2015-12-31 18:40:13'),
	(53, NULL, NULL, '1', 'tttt@adfadf.com', 'tttt', '1111111111111111', '1', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2016-02-12 03:42:29'),
	(54, NULL, NULL, '2', 'gil@eigolive.com', NULL, NULL, NULL, 'message test\r\r\n', 'N', NULL, NULL, NULL, NULL, 'y', '2016-03-03 21:30:26'),
	(55, NULL, NULL, '1', 'gil@eigolive.com', 'Gil', '4086668122', '1', NULL, 'N', NULL, NULL, NULL, NULL, 'y', '2016-03-03 21:30:59'),
	(56, NULL, NULL, '1', 'kenta-03@softbank.ne.jp', 'kentaimai', '08037611014', '1', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2016-07-10 13:35:21'),
	(57, NULL, NULL, '1', 'kenta-03@softbank.ne.jp', 'kentaimai', '08037611014', '2', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2016-07-10 13:36:05'),
	(58, NULL, NULL, '1', 'kenta-03@softbank.ne.jp', 'kenta', '08037611014', '1', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2016-07-18 13:42:37'),
	(59, 11, 1, '3', 'showkind@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, 'tttttt', 'tttttttt', 2147483647, 'y', '2016-11-18 06:26:40'),
	(60, 11, 2, '3', 'showkind@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '', 't\r\na\r\nd\r\nad\r\nad\r\nf\r\nad\r\nfadfadfadfad', 2147483647, 'y', '2016-11-18 06:28:05'),
	(61, 55, 1, '3', 'gil@eigolive.com', NULL, NULL, NULL, NULL, NULL, NULL, 'Email テスト', 'これはEmailのテストです。', 2147483647, 'y', '2016-12-20 03:32:42'),
	(62, 54, 1, '3', 'gil@eigolive.com', NULL, NULL, NULL, NULL, NULL, NULL, 'Email テスト２', 'これは二回目のテストです', 2147483647, 'y', '2016-12-20 03:35:26'),
	(63, 55, 2, '3', 'gil@eigolive.com', NULL, NULL, NULL, NULL, NULL, NULL, 'Email テスト', 'テスト', 2147483647, 'y', '2016-12-20 03:38:00'),
	(64, NULL, NULL, '1', 'hidez-rt@dhk.janis.or.jp', 'riko miyazaki ', '09040996476', '3', NULL, 'N', NULL, NULL, NULL, NULL, 'N', '2017-01-08 06:59:50');
/*!40000 ALTER TABLE `tbl_contact` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
