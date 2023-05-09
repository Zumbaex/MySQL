DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(100),
    lastname VARCHAR(100) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(100) UNIQUE,
    password_hash varchar(100),
    phone BIGINT,
    is_deleted bit default b'0',
    -- INDEX users_phone_idx(phone), -- помним: как выбирать индексы
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

-- NO ACTION
-- CASCADE 
-- RESTRICT
-- SET NULL
-- SET DEFAULT


ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE;

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL PRIMARY KEY, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    -- `status` TINYINT UNSIGNED,
    `status` ENUM('requested', 'approved', 'declined', 'unfriended'),
    -- `status` TINYINT UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME on update now(),
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED,

	INDEX communities_name_idx(name),
	FOREIGN KEY (admin_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES communities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    -- записей мало, поэтому индекс будет лишним (замедлит работу)!
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED,
    user_id BIGINT UNSIGNED DEFAULT NULL,
  	body text,
    filename VARCHAR(255),
    `size` INT,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме*/
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE

);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	`album_id` BIGINT UNSIGNED NOT NULL,
	`media_id` BIGINT UNSIGNED NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_photo_id
    FOREIGN KEY (photo_id) REFERENCES photos(id)
    ON UPDATE CASCADE ON DELETE SET NULL;



-- СОЗДАННЫЕ НОВЫЕ ТРИ ТАБЛИЦЫ

DROP TABLE IF EXISTS audio;
CREATE TABLE audio (
    id SERIAL PRIMARY KEY,
	audio_name TEXT,
    added_at DATETIME DEFAULT NOW()

);

DROP TABLE IF EXISTS audio_list;
CREATE TABLE audio_list (
    id SERIAL PRIMARY KEY,
	audio_ids TEXT
);

DROP TABLE IF EXISTS user_post;
CREATE TABLE user_post (
    id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED DEFAULT NULL,
    post_body TEXT,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),

    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 1) Заполняем таблицу
USE vk;
INSERT INTO users (firstname, lastname, email, phone)  VALUES
	('Ivan', 'Ivanov', 'ivan@mail.ru', '984789106'),
    ('Gennadiy', 'Gennadyev', 'gena@mail.ru', '984789508'),
    ('Arkadiy', 'Poletov', 'ark@mail.ru', '984589128'),
    ('Lena', 'Kuka', 'lena@mail.ru', '984889128'),
    ('Vasya', 'Vasin', 'vasya@mail.ru', '984089128'),
    ('Alex', 'Pereira', 'alex@mail.ru', '984789108'),
    ('Martin', 'Garrix', 'mart@mail.ru', '984349128'),
    ('Kate', 'Winslet', 'kat@mail.ru', '984789138'),
    ('Maria', 'Callas', 'masha@mail.ru', '984289128'),
    ('Roberto', 'Covalli', 'covalli@mail.ru', '984789168');
    
INSERT INTO media_types (name)  VALUES
	('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg'),
    ('jpeg');
    
INSERT INTO media (body, filename, size)  VALUES
	('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400'),
    ('file', 'photo', '400');
    
INSERT INTO likes (user_id, media_id)  VALUES
	('1', '21'),
    ('2', '22'),
    ('3', '23'),
    ('4', '24'),
    ('5', '25'),
    ('6', '26'),
    ('7', '27'),
    ('8', '28'),
    ('9', '29'),
    ('10', '30');
    
INSERT INTO photo_albums (name)  VALUES
	('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album'),
    ('album');
    
INSERT INTO photos (album_id, media_id)  VALUES
	('1', '21'),
    ('2', '22'),
    ('3', '23'),
    ('4', '24'),
    ('5', '25'),
    ('6', '26'),
    ('7', '27'),
    ('8', '28'),
    ('9', '29'),
    ('10', '30');
    
INSERT INTO profiles (gender, birthday, photo_id, hometown)  VALUES
	('m', '1986-02-21', '21', 'MSK'),
    ('m', '1986-02-21', '22', 'MSK'),
    ('m', '1986-02-21', '23', 'MSK'),
    ('f', '1986-02-21', '24', 'MSK'),
    ('m', '1986-02-21', '25', 'MSK'),
    ('m', '1986-02-21', '26', 'MSK'),
    ('m', '1986-02-21', '27', 'MSK'),
    ('f', '1986-02-21', '28', 'MSK'),
    ('f', '1986-02-21', '29', 'MSK'),
    ('m', '1986-02-21', '30', 'MSK');
    
INSERT INTO messages (from_user_id, to_user_id, body)  VALUES
	('1', '2', 'Hello'),
    ('2', '3', 'Hello'),
    ('3', '4', 'Hello'),
    ('4', '5', 'Hello'),
    ('5', '6', 'Hello'),
    ('6', '7', 'Hello'),
    ('7', '8', 'Hello'),
    ('8', '9', 'Hello'),
    ('9', '10', 'Hello'),
    ('10', '1', 'Hello');
    
INSERT INTO friend_requests (initiator_user_id, target_user_id, status)  VALUES
	('1', '2', 'requested'),
    ('2', '3', 'requested'),
    ('3', '4', 'requested'),
    ('4', '5', 'requested'),
    ('5', '6', 'requested'),
    ('6', '7', 'requested'),
    ('7', '8', 'requested'),
    ('8', '9', 'requested'),
    ('9', '10', 'requested'),
    ('10', '1', 'requested');
    
INSERT INTO communities (admin_user_id, name)  VALUES
	('1', 'community'),
    ('2', 'community'),
    ('3', 'community'),
    ('4', 'community'),
    ('5', 'community'),
    ('6', 'community'),
    ('7', 'community'),
    ('8', 'community'),
    ('9', 'community'),
    ('10', 'community');
    
INSERT INTO users_communities (user_id, community_id)  VALUES
	('1', '1'),
    ('2', '2'),
    ('3', '3'),
    ('4', '4'),
    ('5', '5'),
    ('6', '6'),
    ('7', '7'),
    ('8', '8'),
    ('9', '9'),
    ('10', '10');
    
INSERT INTO audio (audio_name)  VALUES
	('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3'),
    ('audio-mp3');
    
INSERT INTO audio_list (audio_ids)  VALUES
	('1, 2, 3'),
    ('2, 3, 4'),
    ('3, 4, 5'),
    ('4, 5, 6'),
    ('5, 6, 7'),
    ('6, 7, 8'),
    ('7, 8, 9'),
    ('1, 3, 2'),
    ('5, 3, 4'),
    ('6, 9, 8');
    
INSERT INTO user_post (user_id, post_body, media_id)  VALUES
	('1', 'Thats my photo', '21'),
    ('2', 'Thats my photo', '22'),
    ('3', 'Thats my photo', '23'),
    ('4', 'Thats my photo', '24'),
    ('5', 'Thats my photo', '25'),
    ('6', 'Thats my photo', '26'),
    ('7', 'Thats my photo', '27'),
    ('8', 'Thats my photo', '28'),
    ('9', 'Thats my photo', '29'),
    ('10', 'Thats my photo', '30');
    
    
    
-- 2) Выводим 
SELECT DISTINCT firstname FROM users;

-- 3) Пометить как удаленные 5 пользователей
UPDATE users
SET is_deleted = 1 
LIMIT 5;

-- 4) Удаление сообщений из будущего
DELETE FROM messages
WHERE created_at > CURRENT_TIMESTAMP();

-- 5) Пока не придумал

    
	