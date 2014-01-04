<?php
defined('INCLUDED') or die('Restricted access');
header('Content-Type: text/html; charset=windows-1251');
$db = new SafeMySQL($opts);
$cache = new Cache(PATH_BASE.'/cache');
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="windows-1251">
<title>pLan Gaming Client Tracker</title>
<link rel="stylesheet" href="template/style.css">
</head>
<body>
<p style="font-weight:bold">Your address: <font color="#00F"><?php echo $Client['client_ip']; ?></font></p>
<h2>pLan OpenVPN Edition rooms</h2>
<p>Format: <a href="/?do=vpn_get&format=json">JSON</a></p>
<table class="tracker" style="width:100%">
<tr>
<td class="caption" style="width:25px">№</td>
<td class="caption">Game name</td>
<td class="caption">Room name</td>
<td class="caption" style="width:120px">Host</td>
<td class="caption">Port</td>
<td class="caption">Channel</td>
<td class="caption" colspan="2">Players</td>
</tr>
<?php
$cache_key = 'template_ovpn';
$data = $cache->get($cache_key, 60);
if ($data === false) {
	$query = $db->getAll('SELECT * FROM tracker ORDER BY game_name');
	if ($query) {
		$i = 1;
		foreach ($query as $row) {
			$row['players'] = implode(', ', array_map('trim', explode(',', $row['players'])));
			$data .=
<<< HERE
<tr>
<td>{$i}</td>
<td>{$row['game_name']}</td>
<td>{$row['room_name']}</td>
<td><a href="http://2ip.ru/geoip/?ip={$row['room_ip']}" target="_blank">{$row['room_ip']}</a></td>
<td>{$row['room_port']}</td>
<td>{$row['irc_channel']}</td>
<td>{$row['players']}</td>
<td>{$row['players_count']}</td>
</tr>
HERE;
			$i++;
		}
	}
	$query = $db->getOne('SELECT SUM(players_count) FROM tracker');
	if ($query) {
			$data .=
<<< HERE
<tr>
<td colspan="7">&nbsp;</td>
<td><strong>{$query}</strong></td>
</tr>
HERE;
	}
	$cache->set($cache_key, $data);
}
echo $data;
?>
</table>
<h2>pLan Tracker Client servers</h2>
<table class="tracker" style="width:600px">
<tr>
<td class="caption" style="width:25px">№</td>
<td class="caption">Game</td>
<td class="caption">Mod</td>
<td class="caption">Host</td>
<td class="caption">Port</td>
</tr>
<?php
$cache_key = 'template_tc';
$data = $cache->get($cache_key, 60);
if ($data === false) {
	$query = $db->getAll('SELECT * FROM games');
	if ($query) {
		$i = 1;
		foreach ($query as $row) {
			$data .=
<<< HERE
<tr>
<td>{$i}</td>
<td>{$row['Game']}</td>
<td>&nbsp;{$row['GameMod']}</td>
<td><a href="http://2ip.ru/geoip/?ip={$row['Host']}" target="_blank">{$row['Host']}</a></td>
<td>{$row['Port']}</td>
</tr>
HERE;
			$i++;
		}
	}
	$cache->set($cache_key, $data);
}
echo $data;
?>
</table>
</body>
</html>
