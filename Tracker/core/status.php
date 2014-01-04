<?php
/**
 * Скрипт для получения картинки со статусом работы игрового сервера
 * Вызов: index.php?do=status&game=nfsmw&ip=46.188.7.37
 */
defined('INCLUDED') or die();

header('Content-type: image/png');

//$game = (string)@$_REQUEST['game'];
$game = 'nfsmw';

//$ip = (string)@$_REQUEST['ip'];
$ip = '46.188.7.37';

$filename = PATH_BASE.'/cache/'.sha1($game.$ip).'.png';

if (file_exists($filename)) {
	$modified = filemtime($filename);
	if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE'])) {
		$cacheModified = preg_replace('/;.*$/', '', $_SERVER['HTTP_IF_MODIFIED_SINCE']);
		if ($modified <= strtotime($cacheModified)) {
			header('HTTP/1.1 304 Not Modified');
			die();
		}
	}
}

# Устанавливаем HTTP-заголовки для кэширования картинки в браузере на 5 минут
header('Last-Modified: '.gmdate('D, d M Y H:i:s', time()).' GMT');
header('Cache-control: max-age=300, must-revalidate');
header('Expires: '.gmdate('D, d M Y H:i:s', time() + 300).' GMT');

if ((file_exists($filename)) && (time() - filemtime($filename) <= 300)) {
	# Загружаем сохранённую картинку
	$img = @imagecreatefrompng($filename);
	//imagealphablending($img, true);
	imagesavealpha($img, true);
	imagepng($img);
	imagedestroy($img);
} else {
	# Рисуем картинку и сохраняем в файл
	$data = array(
		'vpn' => array(
			'name' => 'XXXXXXXXX',
			'status' => 'offline',
		),
		'tc' => array(
			'name' => 'FOX',
			'status' => 'offline',
		)
	);
	$db = new SafeMySQL($opts);
	$query = $db->getRow("SELECT * FROM tracker WHERE room_ip='178.166.137.149'");
	if ($query) {
		$data['vpn']['name'] = $query['room_name'];
		$data['vpn']['status'] = 'online';
	}
	$query = $db->getRow('SELECT * FROM games WHERE Game=?s AND Host=?s', $game, $ip);
	if ($query) {
		$data['tc']['status'] = 'online';
	}

	$img = @imagecreatefrompng(PATH_BASE.'/media/nfsmw.png');
	if (!$img) {
		$img = imagecreatetruecolor(200, 120);
		$background_color = imagecolorallocate($img, 77, 80, 82);
		imagefilledrectangle($img, 0, 0, 200, 120, $background_color);
	}
	//imagealphablending($img, true);
	imagesavealpha($img, true);
	$name_color = imagecolorallocate($img, 236, 73, 52);
	$server_color = imagecolorallocate($img, 254, 131, 4);
	$online_color = imagecolorallocate($img, 0, 255, 0);
	$offline_color = imagecolorallocate($img, 255, 0, 0);
	$ip_color = imagecolorallocate($img, 155, 178, 198);
	imagestring($img, 3, 10, 23, 'pLan OpenVPN Edition', $name_color);
	imagestring($img, 3, 15, 35, $data['vpn']['name'], $server_color);
	if ($data['vpn']['status'] == 'online') {
		$status_color = $online_color;
	} else {
		$status_color = $offline_color;
	}
	imagestring($img, 3, 145, 35, $data['vpn']['status'], $status_color);
	imagestring($img, 2, 15, 45, 'xxx.xxx.xxx.xxx', $ip_color);
	imagestring($img, 3, 10, 58, 'pLan Tracker Client', $name_color);
	imagestring($img, 3, 15, 70, $data['tc']['name'], $server_color);
	if ($data['tc']['status'] == 'online') {
		$status_color = $online_color;
	} else {
		$status_color = $offline_color;
	}
	imagestring($img, 3, 145, 70, $data['tc']['status'], $status_color);
	imagestring($img, 2, 15, 80, $ip, $ip_color);
	imagepng($img, $filename);
	imagepng($img);
	imagedestroy($img);
}
