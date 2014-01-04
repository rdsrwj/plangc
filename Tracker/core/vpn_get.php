<?php
defined('INCLUDED') or die('Restricted access');

# Запрещаем кэширование страницы в Internet Explorer (для гаджета)
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT');
//header('Cache-Control: no-store, no-cache, must-revalidate');
//header('Pragma: no-cache');

# Формат списка комнат
$format = (string)@$_REQUEST['format'];
switch ($format) {
	case 'json':
		header('Content-type: application/json');
		$cache_key = 'vpn_get_json';
		break;
	default:
		header('Content-Type: text/plain; charset=windows-1251');
		$cache_key = 'vpn_get';
}

# Загружаем данные из кэша
$cache = new Cache(PATH_BASE.'/cache');
$data = $cache->get($cache_key, 20);

# Получить данные из кэша
if ($data === false) {
	$db = new SafeMySQL($opts);

	# Очищаем трекер
	$db->query('DELETE FROM tracker WHERE (last_update < NOW() - INTERVAL 1 MINUTE) AND (static = 0)') or die('Database error');

	switch ($format) {
		case 'json':
			$json = array(
				'time' => strtoupper(dechex(time())),
				'clientip' => $Client['client_ip'],
				'rooms' => array()
			);
			$query = $db->getAll(
				"SELECT HEX(UNIX_TIMESTAMP(creation_time)) as time,
					game_name as gamename,
					room_name as name,
					CONCAT(room_ip, ':', room_port) as addr,
					CONCAT(vpn_ip, ':', vpn_port) as vpnaddr,
					irc_channel as channel,
					players_count as playerscount,
					players
				FROM tracker
				ORDER BY game_name"
			) or die('Database error');
			foreach ($query as $row) {
				//$json['rooms'][] = array_values($row);
				$json['rooms'][] = $row;
			}
			$data = json_safe_encode($json);
			break;
		default:
			$query = $db->getAll(
				'SELECT HEX(UNIX_TIMESTAMP(creation_time)) as time,
					room_ip,
					room_port,
					vpn_ip,
					vpn_port,
					irc_channel,
					teamspeak,
					room_name,
					game_name,
					players_count,
					players
				FROM tracker
				ORDER BY game_name'
			) or die('Database error');
			foreach ($query as $row) {
				$data .= implode('$', $row)."\n";
			}
	}

	# Сохраняем данные в кэш
	$cache->set($cache_key, $data);
}

switch ($format) {
	case 'json':
		break;
	default:
		# Добавляем время на трекере и IP-адрес клиента
		$data = strtoupper(dechex(time())).'$'.$Client['client_ip']."\n".$data;
}

# Выводим данные
echo $data;
