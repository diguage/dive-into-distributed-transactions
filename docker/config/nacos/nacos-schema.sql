/*
 * Copyright 1999-2018 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- create root user and grant rights
-- https://stackoverflow.com/a/16592722
CREATE USER IF NOT EXISTS 'admin_nacos'@'%' IDENTIFIED BY '123456';
GRANT ALL ON `db_nacos`.* TO 'admin_nacos'@'%';

FLUSH PRIVILEGES;

-- create databases
CREATE DATABASE IF NOT EXISTS `db_nacos`
       default character set utf8mb4 collate utf8mb4_0900_bin;

USE `db_nacos`;


/* 以下源文件：https://github.com/alibaba/nacos/blob/3.0.2/distribution/conf/mysql-schema.sql */

/******************************************/
/*   表名称 = config_info                  */
/******************************************/
CREATE TABLE `config_info`
(
    `id`                 bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255)  NOT NULL COMMENT 'data_id',
    `group_id`           varchar(128)           DEFAULT NULL COMMENT 'group_id',
    `content`            longtext      NOT NULL COMMENT 'content',
    `md5`                varchar(32)            DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text COMMENT 'source user',
    `src_ip`             varchar(50)            DEFAULT NULL COMMENT 'source ip',
    `app_name`           varchar(128)           DEFAULT NULL COMMENT 'app_name',
    `tenant_id`          varchar(128)           DEFAULT '' COMMENT '租户字段',
    `c_desc`             varchar(256)           DEFAULT NULL COMMENT 'configuration description',
    `c_use`              varchar(64)            DEFAULT NULL COMMENT 'configuration usage',
    `effect`             varchar(64)            DEFAULT NULL COMMENT '配置生效的描述',
    `type`               varchar(64)            DEFAULT NULL COMMENT '配置的类型',
    `c_schema`           text COMMENT '配置的模式',
    `encrypted_data_key` varchar(1024) NOT NULL DEFAULT '' COMMENT '密钥',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB COMMENT='config_info';

/******************************************/
/*   表名称 = config_info  since 2.5.0                */
/******************************************/
CREATE TABLE `config_info_gray`
(
    `id`                 bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255) NOT NULL COMMENT 'data_id',
    `group_id`           varchar(128) NOT NULL COMMENT 'group_id',
    `content`            longtext     NOT NULL COMMENT 'content',
    `md5`                varchar(32)           DEFAULT NULL COMMENT 'md5',
    `src_user`           text COMMENT 'src_user',
    `src_ip`             varchar(100)          DEFAULT NULL COMMENT 'src_ip',
    `gmt_create`         datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_create',
    `gmt_modified`       datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_modified',
    `app_name`           varchar(128)          DEFAULT NULL COMMENT 'app_name',
    `tenant_id`          varchar(128)          DEFAULT '' COMMENT 'tenant_id',
    `gray_name`          varchar(128) NOT NULL COMMENT 'gray_name',
    `gray_rule`          text         NOT NULL COMMENT 'gray_rule',
    `encrypted_data_key` varchar(256) NOT NULL DEFAULT '' COMMENT 'encrypted_data_key',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfogray_datagrouptenantgray` (`data_id`,`group_id`,`tenant_id`,`gray_name`),
    KEY                  `idx_dataid_gmt_modified` (`data_id`,`gmt_modified`),
    KEY                  `idx_gmt_modified` (`gmt_modified`)
) ENGINE=InnoDB AUTO_INCREMENT=1 COMMENT='config_info_gray';

/******************************************/
/*   表名称 = config_tags_relation         */
/******************************************/
CREATE TABLE `config_tags_relation`
(
    `id`        bigint(20) NOT NULL COMMENT 'id',
    `tag_name`  varchar(128) NOT NULL COMMENT 'tag_name',
    `tag_type`  varchar(64)  DEFAULT NULL COMMENT 'tag_type',
    `data_id`   varchar(255) NOT NULL COMMENT 'data_id',
    `group_id`  varchar(128) NOT NULL COMMENT 'group_id',
    `tenant_id` varchar(128) DEFAULT '' COMMENT 'tenant_id',
    `nid`       bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增长标识',
    PRIMARY KEY (`nid`),
    UNIQUE KEY `uk_configtagrelation_configidtag` (`id`,`tag_name`,`tag_type`),
    KEY         `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB COMMENT='config_tag_relation';

/******************************************/
/*   表名称 = group_capacity               */
/******************************************/
CREATE TABLE `group_capacity`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `group_id`          varchar(128) NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
    `quota`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int(10) unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
    `max_aggr_size`     int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB COMMENT='集群、各Group容量信息表';

/******************************************/
/*   表名称 = his_config_info              */
/******************************************/
CREATE TABLE `his_config_info`
(
    `id`                 bigint(20) unsigned NOT NULL COMMENT 'id',
    `nid`                bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增标识',
    `data_id`            varchar(255)  NOT NULL COMMENT 'data_id',
    `group_id`           varchar(128)  NOT NULL COMMENT 'group_id',
    `app_name`           varchar(128)           DEFAULT NULL COMMENT 'app_name',
    `content`            longtext      NOT NULL COMMENT 'content',
    `md5`                varchar(32)            DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text COMMENT 'source user',
    `src_ip`             varchar(50)            DEFAULT NULL COMMENT 'source ip',
    `op_type`            char(10)               DEFAULT NULL COMMENT 'operation type',
    `tenant_id`          varchar(128)           DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` varchar(1024) NOT NULL DEFAULT '' COMMENT '密钥',
    `publish_type`       varchar(50)            DEFAULT 'formal' COMMENT 'publish type gray or formal',
    `gray_name`          varchar(50)            DEFAULT NULL COMMENT 'gray name',
    `ext_info`           longtext               DEFAULT NULL COMMENT 'ext info',
    PRIMARY KEY (`nid`),
    KEY                  `idx_gmt_create` (`gmt_create`),
    KEY                  `idx_gmt_modified` (`gmt_modified`),
    KEY                  `idx_did` (`data_id`)
) ENGINE=InnoDB COMMENT='多租户改造';


/******************************************/
/*   表名称 = tenant_capacity              */
/******************************************/
CREATE TABLE `tenant_capacity`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tenant_id`         varchar(128) NOT NULL DEFAULT '' COMMENT 'Tenant ID',
    `quota`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int(10) unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size`     int(10) unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB COMMENT='租户容量信息表';


CREATE TABLE `tenant_info`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
    `kp`            varchar(128) NOT NULL COMMENT 'kp',
    `tenant_id`     varchar(128) default '' COMMENT 'tenant_id',
    `tenant_name`   varchar(128) default '' COMMENT 'tenant_name',
    `tenant_desc`   varchar(256) DEFAULT NULL COMMENT 'tenant_desc',
    `create_source` varchar(32)  DEFAULT NULL COMMENT 'create_source',
    `gmt_create`    bigint(20) NOT NULL COMMENT '创建时间',
    `gmt_modified`  bigint(20) NOT NULL COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`,`tenant_id`),
    KEY             `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB COMMENT='tenant_info';

CREATE TABLE `users`
(
    `username` varchar(50)  NOT NULL PRIMARY KEY COMMENT 'username',
    `password` varchar(500) NOT NULL COMMENT 'password',
    `enabled`  boolean      NOT NULL COMMENT 'enabled'
);

CREATE TABLE `roles`
(
    `username` varchar(50) NOT NULL COMMENT 'username',
    `role`     varchar(50) NOT NULL COMMENT 'role',
    UNIQUE INDEX `idx_user_role` (`username` ASC, `role` ASC) USING BTREE
);

CREATE TABLE `permissions`
(
    `role`     varchar(50)  NOT NULL COMMENT 'role',
    `resource` varchar(128) NOT NULL COMMENT 'resource',
    `action`   varchar(8)   NOT NULL COMMENT 'action',
    UNIQUE INDEX `uk_role_permission` (`role`,`resource`,`action`) USING BTREE
);

/* 源文件：https://github.com/alibaba/nacos/blob/3.0.0/distribution/conf/mysql-schema.sql 到此为止*/

/* 以下导入 Seata 配置信息（含 NACOS管理员信息） */

-- MySQL dump 10.13  Distrib 8.4.5, for macos14.7 (x86_64)
--
-- Host: 127.0.0.1    Database: db_nacos
-- ------------------------------------------------------
-- Server version	8.4.5

--
-- Dumping data for table `config_info`
--

LOCK TABLES `config_info` WRITE;
/*!40000 ALTER TABLE `config_info` DISABLE KEYS */;
INSERT INTO `config_info` VALUES (1,'seataServer.properties','SEATA_GROUP','store.mode=db\n#-----db-----\n# 修改成 hikari 报错\nstore.db.datasource=druid\nstore.db.dbType=mysql\n# 需要根据mysql的版本调整driverClassName\n# mysql8及以上版本对应的driver：com.mysql.cj.jdbc.Driver\n# mysql8以下版本的driver：com.mysql.jdbc.Driver\nstore.db.driverClassName=com.mysql.cj.jdbc.Driver\nstore.db.url=jdbc:mysql://mysql-seata:3306/db_seata?useUnicode=true&characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true\nstore.db.user=admin_seata\nstore.db.password=123456\n# 数据库初始连接数\nstore.db.minConn=1\n# 数据库最大连接数\nstore.db.maxConn=20\n# 获取连接时最大等待时间 默认5000，单位毫秒\nstore.db.maxWait=5000\n# 全局事务表名 默认global_table\nstore.db.globalTable=global_table\n# 分支事务表名 默认branch_table\nstore.db.branchTable=branch_table\n# 全局锁表名 默认lock_table\nstore.db.lockTable=lock_table\n# 查询全局事务一次的最大条数 默认100\nstore.db.queryLimit=100\n\n\n# undo保留天数 默认7天,log_status=1（附录3）和未正常清理的undo\nserver.undo.logSaveDays=7\n# undo清理线程间隔时间 默认86400000，单位毫秒\nserver.undo.logDeletePeriod=86400000\n# 二阶段提交重试超时时长 单位ms,s,m,h,d,对应毫秒,秒,分,小时,天,默认毫秒。默认值-1表示无限重试\n# 公式: timeout>=now-globalTransactionBeginTime,true表示超时则不再重试\n# 注: 达到超时时间后将不会做任何重试,有数据不一致风险,除非业务自行可校准数据,否者慎用\nserver.maxCommitRetryTimeout=-1\n# 二阶段回滚重试超时时长\nserver.maxRollbackRetryTimeout=-1\n# 二阶段提交未完成状态全局事务重试提交线程间隔时间 默认1000，单位毫秒\nserver.recovery.committingRetryPeriod=1000\n# 二阶段异步提交状态重试提交线程间隔时间 默认1000，单位毫秒\nserver.recovery.asynCommittingRetryPeriod=1000\n# 二阶段回滚状态重试回滚线程间隔时间  默认1000，单位毫秒\nserver.recovery.rollbackingRetryPeriod=1000\n# 超时状态检测重试线程间隔时间 默认1000，单位毫秒，检测出超时将全局事务置入回滚会话管理器\nserver.recovery.timeoutRetryPeriod=1000','d3d705aa4ab285e6d72f6646abc21efa','2025-06-09 14:16:56','2025-06-10 00:10:53','nacos','192.168.65.1','','seata-server','',NULL,NULL,'properties',NULL,'');
/*!40000 ALTER TABLE `config_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `group_capacity`
--

LOCK TABLES `group_capacity` WRITE;
/*!40000 ALTER TABLE `group_capacity` DISABLE KEYS */;
INSERT INTO `group_capacity` VALUES (1,'',0,1,0,0,0,0,'2025-06-09 10:15:15','2025-06-10 07:49:54');
/*!40000 ALTER TABLE `group_capacity` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES ('ROLE_SEATA','seata-server:*:*','rw');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('nacos','ROLE_ADMIN'),('seata','ROLE_SEATA');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `tenant_capacity`
--

LOCK TABLES `tenant_capacity` WRITE;
/*!40000 ALTER TABLE `tenant_capacity` DISABLE KEYS */;
INSERT INTO `tenant_capacity` VALUES (1,'seata-server',0,1,0,0,0,0,'2025-06-09 10:15:15','2025-06-10 07:49:54');
/*!40000 ALTER TABLE `tenant_capacity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `tenant_info`
--

LOCK TABLES `tenant_info` WRITE;
/*!40000 ALTER TABLE `tenant_info` DISABLE KEYS */;
INSERT INTO `tenant_info` VALUES (1,'2','nacos-default-mcp','nacos-default-mcp','Nacos default AI MCP module.','nacos',1749434747652,1749434747652),(2,'1','seata-server','seata-server','seata-server','nacos',1749435059010,1749435059010);
/*!40000 ALTER TABLE `tenant_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('nacos','$2a$10$OLjDASIyFwZt.CWEZvHpUOhIqns6okVnPoeNnkD3dREa2PkIOX8NW',1),('seata','$2a$10$GaGtP8KW4jNZrRznKqR04.opS2792ECeYR9fqy9EoZV1iXK12ydDy',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

/* Seata 配置信息到此为止 */
