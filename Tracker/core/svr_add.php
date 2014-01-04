<?php
defined('INCLUDED') or die('Restricted access');

# Фильтр
if (empty($_REQUEST['port']) || !is_numeric($_REQUEST['port']) || empty($_REQUEST['game'])) die('Not enough data to create a server');

//$addr = @$_REQUEST['addr'];
$addr = $Client['client_ip'];
$port = $_REQUEST['port'];
$game = (string)$_REQUEST['game'];
$mod  = (string)@$_REQUEST['mod'];

$db = new Database($Config['db_host'], $Config['db_username'], $Config['db_password'], $Config['db_name']);
$db->query('SET NAMES '.$Config['db_encoding']) or die('Database error');

# Экранируем специальные символы
$game = $db->escape($game);
$mod  = $db->escape($mod);

# ToDo: INSERT INTO ... ON DUBLICATE KEY UPDATE...
$query = $db->query("SELECT * FROM games WHERE (Host='$addr' AND Port='$port');") or die('Database error');
if ($db->num_rows($query) > 0) {
	$row = $db->fetch_assoc($query);
	$id = $row['id'];
	$db->query("UPDATE games SET LastUpdate='".date('Y-m-d H:i:s')."' WHERE (ID='$id');") or die('Database error');
} else {
	$db->query("INSERT INTO games (Game, Host, Port, LastUpdate, GameMod) VALUES ('$game', '$addr', '$port', '".date('Y-m-d H:i:s')."', '$mod');") or die('Database error');
	echo 'Server added successfully';
}

$db->close();
