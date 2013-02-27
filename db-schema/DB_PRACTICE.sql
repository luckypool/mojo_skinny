DROP DATABASE if EXISTS practice;
CREATE DATABASE practice;
USE practice;

DROP TABLE if EXISTS entry;
CREATE TABLE entry (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    nickname VARCHAR(32) NOT NULL,
    body VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT 0,
    updated_at DATETIME NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

