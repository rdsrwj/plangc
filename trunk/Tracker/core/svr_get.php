<?php
defined('INCLUDED') or die('Restricted access');

if (empty($_REQUEST['game'])) die();

$game = (string)$_REQUEST['game'];

$db = new SafeMySQL($opts);

$query = $db->getAll('SELECT * FROM games WHERE Game=?s', $game) or die('Database error');
foreach ($query as $row) {
	echo $row['Host'].':'.$row['Port']."\n";
}
