-- Задание 1 - Установить MySQL и создать .my.cnf
-- Файл создал, а командная строка все равно не пускает - ERROR 1045 (28000)

/* Задание 2 - Создайте базу данных example, разместите в ней таблицу users, состоящую 
    из двух столбцов, числового id и строкового name. */

CREATE DATABASE example;
CREATE TABLE users(
id SERIAL PRIMARY KEY,
name VARCHAR(255) COMMENT 'Name');

-- 3. Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.
mysql -u root -p
CREATE DATABASE sample;

mysqldump -u root -p example > sample.sql

mysql -u root -p sample < sample.sql