-- https://stackoverflow.com/a/52899915


-- create root user and grant rights
-- https://stackoverflow.com/a/16592722
CREATE USER IF NOT EXISTS 'account'@'%' IDENTIFIED BY '123456';
GRANT ALL ON `account`.* TO 'account'@'%';

FLUSH PRIVILEGES;


-- create databases
CREATE DATABASE IF NOT EXISTS `account`
       default character set utf8mb4 collate utf8mb4_0900_ai_ci;

USE `account`;

DROP TABLE IF EXISTS `account_tbl`;
CREATE TABLE `account_tbl`
(
    `id`      int(11) NOT NULL AUTO_INCREMENT,
    `user_id` varchar(255) DEFAULT NULL,
    `money`   int(11) DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;


DROP TABLE IF EXISTS `undo_log`;
CREATE TABLE `undo_log`
(
    `branch_id`     BIGINT       NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(128) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COMMENT ='AT transaction mode undo table';

ALTER TABLE `undo_log`
    ADD INDEX `ix_log_created` (`log_created`);
