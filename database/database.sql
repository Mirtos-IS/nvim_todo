CREATE TABLE `users` (
    `uid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `username` VARCHAR(64) NULL,
    `password` VARCHAR(64) NULL,
);

CREATE TABLE `todo_items` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `title` VARCHAR(64) NULL,
    `ordering` INTEGER NULL,
    `is_marked` NUMBER(1) DEFAULT 0
);

ALTER TABLE todo_items RENAME COLUMN `order` TO `ordering`

CREATE TABLE `todo_lists` (
    `uid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `name` VARCHAR(64) NULL,
    `user_uid` INTEGER NULL,
    FOREIGN KEY (`user_uid`) REFERENCES users(uid)
);

INSERT INTO todo_items(title, is_marked) VALUES('third one', false)

