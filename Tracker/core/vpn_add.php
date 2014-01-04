<?php
defined('INCLUDED') or die('Restricted access');

# Фильтр
if (empty($_REQUEST['port']) || !is_numeric($_REQUEST['port']) || ($_REQUEST['port'] < 1024) || empty($_REQUEST['vpnport']) || !is_numeric($_REQUEST['vpnport']) || ($_REQUEST['vpnport'] < 1024)) die('Not enough data to create a room');

$curr_time = date('Y-m-d H:i:s');

$Room = array(
	'creation_time' => $curr_time,
	'last_update' => $curr_time,
	'user_agent' => $Client['user_agent'],
	'client_ip' => $Client['client_ip'],
	'room_ip' => (!empty($_REQUEST['addr'])) ? $_REQUEST['addr'] : $Client['client_ip'],
	'room_port' => (string)$_REQUEST['port'],
	'vpn_ip' => (!empty($_REQUEST['vpnip'])) ? $_REQUEST['vpnip'] : $Client['client_ip'],
	'vpn_port' => (string)$_REQUEST['vpnport'],
	'irc_channel' => (!empty($_REQUEST['chan'])) ? $_REQUEST['chan'] : 'plan_'.rand(0, 9999),
	'teamspeak' => 'none',
	'game_name' => (!empty($_REQUEST['gamename'])) ? $_REQUEST['gamename'] : '(undefined)',
	'room_name' => (!empty($_REQUEST['roomname'])) ? $_REQUEST['roomname'] : '(undefined)',
	'players_count' => (!empty($_REQUEST['playerscount'])) ? $_REQUEST['playerscount'] : '0',
	'players' => (!empty($_REQUEST['playerlist'])) ? $_REQUEST['playerlist'] : ''
);

# В названии комнаты допускаются только цифры, знак "подчёркивание" и латинские буквы
if (!preg_match('/^[a-z0-9_\s]+$/i', $Room['game_name']))
	$Room['game_name'] = '(undefined)';

# Если адрес комнаты вне диапазона локальных адресов, то должен совпадать с адресом клиента
if (($Room['room_ip'] !== $Client['client_ip']) && !IsLAN($Room['room_ip']))
	$Room['room_ip'] = $Client['client_ip'];

# Адрес VPN-сервера должен соответствовать адресу комнаты
if (($Room['vpn_ip'] !== $Room['room_ip']) && !IsLAN($Room['vpn_ip']))
	$Room['vpn_ip'] = $Room['room_ip'];

$db = new SafeMySQL($opts);

/*$ins = array_intersect_key($Room, array_flip(
	array(
		'creation_time',
		'last_update',
		'user_agent',
		'client_ip',
		'room_ip',
		'room_port',
		'vpn_ip',
		'vpn_port',
		'irc_channel',
		'teamspeak',
		'game_name',
		'room_name'
	)
));*/
$ins = $db->filterArray($Room, array('creation_time', 'last_update', 'user_agent',	'client_ip', 'room_ip', 'room_port', 'vpn_ip', 'vpn_port', 'irc_channel', 'teamspeak', 'game_name', 'room_name'));

/*$upd = array_intersect_key($Room, array_flip(
	array(
		'last_update',
		'room_ip',
		'vpn_ip'
	)
));*/
$upd = $db->filterArray($Room, array('last_update',	'room_ip', 'vpn_ip'));

$sql = 'INSERT INTO tracker SET ?u ON DUPLICATE KEY UPDATE ?u';
$query = $db->query($sql, $ins, $upd) or die('Database error');

if ($query) echo 'Room created successfully';
