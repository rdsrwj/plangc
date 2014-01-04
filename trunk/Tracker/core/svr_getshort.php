<?php
defined('INCLUDED') or die('Restricted access');

# Загружаем данные из кэша
$cache = new Cache(PATH_BASE.'/cache');
$cache_key = 'svr_getshort';
$data = $cache->get($cache_key, 20);

if ($data === false) {
	$db = new SafeMySQL($opts);

	# Очищаем трекер
	$ourdate = date('Y-m-d H:i:s', mktime(date('H'), date('i') - 1, date('s'), date('m'), date('d'), date('Y')));
	$db->query("DELETE FROM games WHERE (LastUpdate < '{$ourdate}')") or die('Database error');

	# Получаем данные из базы
	$query = $db->getAll('SELECT Game, GameMod, COUNT(Game) AS cnt FROM games GROUP BY Game') or die('Database error');
	foreach ($query as $row) {
		$data .= $row['Game'];
		if ($row['GameMod']) $data .= '.'.$row['GameMod'];
		$data .= ' '.$row['cnt']."\n";
	}

	# Сохраняем данные в кэш
	$cache->set($cache_key, $data);
}

# Выводим данные
echo $data;
