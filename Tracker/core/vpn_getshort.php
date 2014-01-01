<?php
defined('INCLUDED') or die('Restricted access');

# Set russian charset
header('Content-Type: text/plain; charset=windows-1251');

# Load data from cache
$cache = new Cache(PATH_BASE.'/cache');
$cache_key = 'vpn_getshort';
$data = $cache->get($cache_key, 20);

if ($data === false) {
	$db = new SafeMySQL($opts);

	# Get data from database
	$query = $db->getAll('SELECT game_name, COUNT(game_name) as cnt FROM tracker GROUP BY game_name') or die('Database error');
	foreach ($query as $row) {
		$data .= $row['game_name'].'|'.$row['cnt']."\n";
	}

	# Save data into cache
	$cache->set($cache_key, $data);
}

# Output
echo $data;
