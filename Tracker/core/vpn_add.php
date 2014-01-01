<?php
defined('INCLUDED') or die('Restricted access');

# Filters
if (empty($_REQUEST['port']) || !is_numeric($_REQUEST['port']) || ($_REQUEST['port'] < 1024) || empty($_REQUEST['vpnport']) || !is_numeric($_REQUEST['vpnport']) || ($_REQUEST['vpnport'] < 1024)) die('Not enough data to create a room');

$Client['room_ip'] = (!empty($_REQUEST['addr'])) ? $_REQUEST['addr'] : $Client['ip'];
$Client['room_port'] = (string)$_REQUEST['port'];
$Client['vpn_ip'] = (!empty($_REQUEST['vpnip'])) ? $_REQUEST['vpnip'] : $Client['room_ip'];
$Client['vpn_port'] = (string)$_REQUEST['vpnport'];
$Client['irc_channel'] = (!empty($_REQUEST['chan'])) ? $_REQUEST['chan'] : 'plan_'.rand(0, 9999);
$Client['room_name'] = (!empty($_REQUEST['roomname'])) ? $_REQUEST['roomname'] : '(undefined)';
$Client['game_name'] = (!empty($_REQUEST['mod'])) ? $_REQUEST['mod'] : '(undefined)';
//$Client['players_count'] = (!empty($_REQUEST['playerscount'])) ? $_REQUEST['playerscount'] : '0';
//$Client['players'] = (!empty($_REQUEST['playerlist'])) ? $_REQUEST['playerlist']   : '';

# New parameter "gamename" overrides parameter "mod"
if (!empty($_REQUEST['gamename'])) {
	$Client['game_name'] = $_REQUEST['gamename'];
}
if (!preg_match('/^[a-z0-9_\s]+$/i', $Client['game_name']))
	$Client['game_name'] = '(undefined)';

$db = new Database($Config['db_host'], $Config['db_username'], $Config['db_password'], $Config['db_name']);
$db->query('SET NAMES '.$Config['db_encoding']) or die('Database error');

# XSS-filter
$Client = FilterXSS($Client);

if (($Client['room_ip'] !== $Client['ip']) && !IsLAN($Client['room_ip']))
	$Client['room_ip'] = $Client['ip'];

if (($Client['vpn_ip'] !== $Client['room_ip']) && !IsLAN($Client['vpn_ip']))
	$Client['vpn_ip'] = $Client['room_ip'];

$curr_time = date('Y-m-d H:i:s');

/*
$query = $db->query("INSERT INTO tracker (
	creation_time,
	last_update,
	user_agent,
	client_ip,
	room_ip,
	room_port,
	vpn_ip,
	vpn_port,
	irc_channel,
	teamspeak,
	game_name,
	room_name,
	players_count,
	players
) VALUES (
	'{$curr_time}',
	'{$curr_time}',
	'{$Client['user_agent']}',
	'{$Client['ip']}',
	'{$Client['room_ip']}',
	'{$Client['room_port']}',
	'{$Client['vpn_ip']}',
	'{$Client['vpn_port']}',
	'{$Client['irc_channel']}',
	'none',
	'{$Client['game_name']}',
	'{$Client['room_name']}',
	'{$Client['players_count']}',
	'{$Client['players']}'
) ON DUPLICATE KEY UPDATE
	last_update='{$curr_time}',
	room_ip='{$Client['room_ip']}',
	vpn_ip='{$Client['vpn_ip']}',
	players_count='{$Client['players_count']}',
	players='{$Client['players']}';") or die('Database error');
*/

$query = $db->query("INSERT INTO tracker (
	creation_time,
	last_update,
	user_agent,
	client_ip,
	room_ip,
	room_port,
	vpn_ip,
	vpn_port,
	irc_channel,
	teamspeak,
	game_name,
	room_name
) VALUES (
	'{$curr_time}',
	'{$curr_time}',
	'{$Client['user_agent']}',
	'{$Client['ip']}',
	'{$Client['room_ip']}',
	'{$Client['room_port']}',
	'{$Client['vpn_ip']}',
	'{$Client['vpn_port']}',
	'{$Client['irc_channel']}',
	'none',
	'{$Client['game_name']}',
	'{$Client['room_name']}'
) ON DUPLICATE KEY UPDATE
	last_update='{$curr_time}',
	room_ip='{$Client['room_ip']}',
	vpn_ip='{$Client['vpn_ip']}'") or die('Database error');

if ($query) echo 'Room created successfully';

$db->close();
