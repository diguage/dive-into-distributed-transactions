-- https://stackoverflow.com/a/52899915


-- create root user and grant rights
-- https://stackoverflow.com/a/16592722
CREATE USER IF NOT EXISTS 'admin_storage'@'%' IDENTIFIED BY '123456';
GRANT ALL ON `db_storage`.* TO 'admin_storage'@'%';

FLUSH PRIVILEGES;


-- create databases
CREATE DATABASE IF NOT EXISTS `db_storage`
       default character set utf8mb4 collate utf8mb4_0900_ai_ci;

USE `db_storage`;


DROP TABLE IF EXISTS `storage_tbl`;
CREATE TABLE `storage_tbl`
(
    `id`             int(11) NOT NULL AUTO_INCREMENT,
    `commodity_code` varchar(255) DEFAULT NULL,
    `count`          int(11) DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY (`commodity_code`)
) ENGINE=InnoDB;

INSERT INTO storage_tbl(id, commodity_code, `count`)
VALUES (1, 'j10', 666);


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
