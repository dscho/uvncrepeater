-- Copyright (C) 2006 Lokkju, Inc. lokkju@lokkju.com

DROP TABLE IF EXISTS viewers;
DROP TABLE IF EXISTS repeaters;
DROP TABLE IF EXISTS servers;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS organizations;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS users_groups;
DROP TABLE IF EXISTS server_configs;

-- for the repeater

CREATE TABLE viewers (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	uid CHAR(36),
	repeater_uid CHAR(36),
	lasttime INTEGER,
	status INTEGER,
	table_index INTEGER,
	code INTEGER,
	mode INTEGER,
	ip VARCHAR(20)	
);
CREATE TABLE servers (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	uid CHAR(36),
	repeater_uid CHAR(36),
	lasttime INTEGER,
	status INTEGER,
	table_index INTEGER,
	code INTEGER,
	mode INTEGER,
	ip VARCHAR(20)	
);

CREATE TABLE repeaters (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	uid CHAR(36),
	process_id INTEGER,
	lasttime INTEGER,
	status INTEGER,
	maxsessions INTEGER,
	ip VARCHAR(20),
	server_port INTEGER,
	viewer_port INTEGER
);
 	
CREATE TABLE sessions (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	repeater_uid CHAR(36),
	status INTEGER,
	lasttime INTEGER,
	server_index INTEGER,
	server_ip VARCHAR(20),
	server_uid CHAR(36),
	viewer_index INTEGER,
	viewer_ip VARCHAR(20),
	viewer_uid CHAR(36),
	code INTEGER,
	mode INTEGER
);

-- for the web interface

CREATE TABLE organizations (
	id INTEGER NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(500),
	address_line_one VARCHAR(500),
	address_line_two VARCHAR(500),
	city VARCHAR(500) NOT NULL,
	state VARCHAR(50) NOT NULL,
	zip VARCHAR(10) NOT NULL,
	country VARCHAR(50) NOT NULL,
	code_prefix VARCHAR(4) NOT NULL,
	PRIMARY KEY(id),
	UNIQUE INDEX CODE_PREFIX_UNIQUE_INDEX(code_prefix)
);

INSERT INTO organizations VALUES(1,'Lokkju, Inc','','','','','','','','4012');

CREATE TABLE groups (
	id INTEGER NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(500),
	rules VARCHAR(500),
	PRIMARY KEY(id)
);

INSERT INTO groups VALUES (1, 'Global Admin','','*:*');
INSERT INTO groups VALUES (2, 'Organization Admin','','*:*,!*:admin_*');
INSERT INTO groups VALUES (3, 'Support Technician','','');

CREATE TABLE users (
	id INTEGER NOT NULL AUTO_INCREMENT,
	organization_id INTEGER NOT NULL,
	display_name VARCHAR(50) NOT NULL,
	email VARCHAR(250) NOT NULL,
	username VARCHAR(50) NOT NULL,
	password VARCHAR(50) NOT NULL,
	PRIMARY KEY(id)
);

INSERT INTO users VALUES (1,1,'Lokkju','lokkju@lokkju.com','lokkju','pass');

CREATE TABLE users_groups (
	user_id INTEGER NOT NULL DEFAULT 0,
	group_id INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY(user_id,group_id)
);

INSERT INTO users_groups VALUES(1,1);

CREATE TABLE server_configs (
	id INTEGER NOT NULL PRIMARY KEY,
	company_id INTEGER NOT NULL,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(500),
	helpdesk VARCHAR(1000)
);