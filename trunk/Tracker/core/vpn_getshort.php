<?php
defined('INCLUDED') or die('Restricted access');

# Устанавливаем русскую кодировку
header('Content-Type: text/plain; charset=windows-1251');

# Загружаем данные из кэша
$cache = new Cache(PATH_BASE.'/cache');
$cache_key = 'vpn_getshort';
$data = $cache->get($cache_key, 20);

if ($data === false) {
	$db = new SafeMySQL($opts);

	# Получаем данные из базы
	$query = $db->getAll('SELECT game_name, COUNT(game_name) as cnt FROM tracker GROUP BY game_name') or die('Database error');
	foreach ($query as $row) {
		$data .= $row['game_name'].'|'.$row['cnt']."\n";
	}

	# Сохраняем данные в кэш
	$cache->set($cache_key, $data);
}

# Выводим данные
echo $data;
