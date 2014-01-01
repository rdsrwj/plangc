<?php
defined('INCLUDED') or die('Restricted access');

# Load data from cache
$cache = new Cache(PATH_BASE.'/cache');
$cache_key = 'svr_getshort';
$data = $cache->get($cache_key, 20);

if ($data === false) {
	$db = new SafeMySQL($opts);

	# Clean tracker
	$ourdate = date('Y-m-d H:i:s', mktime(date('H'), date('i') - 1, date('s'), date('m'), date('d'), date('Y')));
	$db->query("DELETE FROM games WHERE (LastUpdate < '{$ourdate}')") or die('Database error');

	# Get data from database
	$query = $db->getAll('SELECT Game, GameMod, COUNT(Game) AS cnt FROM games GROUP BY Game') or die('Database error');
	foreach ($query as $row) {
		$data .= $row['Game'];
		if ($row['GameMod']) $data .= '.'.$row['GameMod'];
		$data .= ' '.$row['cnt']."\n";
	}

	# Save data into cache
	$cache->set($cache_key, $data);
}

# Output
echo $data;
