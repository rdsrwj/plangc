DROP TABLE IF EXISTS `games`;

CREATE TABLE `games` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Game` varchar(255) DEFAULT NULL,
  `Host` varchar(255) DEFAULT NULL,
  `Port` int(11) DEFAULT NULL,
  `LastUpdate` datetime DEFAULT NULL,
  `Location` tinyint(1) NOT NULL DEFAULT '0',
  `Realloc` tinyint(1) NOT NULL DEFAULT '0',
  `Static` tinyint(1) NOT NULL DEFAULT '0',
  `GameMod` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Game` (`Game`)
);

DROP TABLE IF EXISTS `tracker`;

CREATE TABLE `tracker` (
  `creation_time` datetime NOT NULL COMMENT 'Время создания комнаты',
  `last_update` datetime NOT NULL COMMENT 'Дата последнего обновления комнаты',
  `user_agent` varchar(255) NOT NULL DEFAULT 'unknown' COMMENT 'Агент',
  `client_ip` varchar(15) NOT NULL DEFAULT '0.0.0.0' COMMENT 'Адрес клиента',
  `room_ip` varchar(15) NOT NULL DEFAULT '0.0.0.0' COMMENT 'Адрес комнаты',
  `room_port` varchar(5) NOT NULL DEFAULT '1098' COMMENT 'Порт комнаты',
  `vpn_ip` varchar(15) NOT NULL DEFAULT '0.0.0.0' COMMENT 'Адрес VPN сервера',
  `vpn_port` varchar(5) NOT NULL DEFAULT '1097' COMMENT 'Порт VPN сервера',
  `irc_channel` varchar(255) NOT NULL DEFAULT 'none' COMMENT 'IRC-канал комнаты',
  `teamspeak` varchar(21) NOT NULL DEFAULT 'none' COMMENT 'Адрес Teamspeak',
  `game_name` varchar(255) NOT NULL DEFAULT '(undefined)' COMMENT 'Название игры',
  `room_name` varchar(255) NOT NULL DEFAULT '(undefined)' COMMENT 'Название комнаты',
  `players_count` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Количество игроков',
  `players` varchar(255) NOT NULL COMMENT 'Список игроков',
  `static` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Статичная комната',
  PRIMARY KEY (`client_ip`,`room_name`),
  UNIQUE KEY `client_ip` (`client_ip`),
  UNIQUE KEY `room_name` (`room_name`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;