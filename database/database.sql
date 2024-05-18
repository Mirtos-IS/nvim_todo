CREATE TABLE `users` (
    `uid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `username` VARCHAR(64) NULL,
    `password` VARCHAR(64) NULL,
);

CREATE TABLE `todo_items` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `title` VARCHAR(64) NULL,
    `todo_lists_id` INTEGER NULL,
    `ordering` INTEGER NULL,
    `is_marked` NUMBER(1) DEFAULT 0,
    FOREIGN KEY (`todo_lists_id`) REFERENCES todo_lists(id)
);

CREATE TABLE `todo_lists` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `name` VARCHAR(64) NULL
);
