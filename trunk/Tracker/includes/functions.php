<?php
defined('INCLUDED') or die('Restricted access');

require_once PATH_BASE . '/includes/lanlist.php';

function get_client_ip() {
	if (isset($_SERVER)) {
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR']))
			return $_SERVER['HTTP_X_FORWARDED_FOR'];
		if (isset($_SERVER['HTTP_CLIENT_IP']))
			return $_SERVER['HTTP_CLIENT_IP'];
		return $_SERVER['REMOTE_ADDR'];
	}
	if (getenv('HTTP_X_FORWARDED_FOR'))
		return getenv('HTTP_X_FORWARDED_FOR');
	if (getenv('HTTP_CLIENT_IP'))
		return getenv('HTTP_CLIENT_IP');
	return getenv('REMOTE_ADDR');
}

function GetClientIP() {
	if (isset($_SERVER)) {
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR']))
			return $_SERVER['HTTP_X_FORWARDED_FOR'];
		if (isset($_SERVER['HTTP_CLIENT_IP']))
			return $_SERVER['HTTP_CLIENT_IP'];
		return $_SERVER['REMOTE_ADDR'];
	}
	if (getenv('HTTP_X_FORWARDED_FOR'))
		return getenv('HTTP_X_FORWARDED_FOR');
	if (getenv('HTTP_CLIENT_IP'))
		return getenv('HTTP_CLIENT_IP');
	return getenv('REMOTE_ADDR');
}

function is_ip($ip) {
	return (bool)(ip2long($ip) > 0);
}

function IsIP($ip) {
	return (bool)(ip2long($ip) > 0);
}

function filter_xss($array) {
	foreach($array as $name=>$value) {
		//$value = htmlentities($value,ENT_QUOTES, 'UTF-8');
		$value = htmlspecialchars($value, ENT_QUOTES);
		if (get_magic_quotes_gpc())
			$value = stripslashes($value);
		$value = @mysql_real_escape_string($value);
		$value = strip_tags($value);
		$value = str_replace("\n", ' ', $value);
		$value = str_replace("\r", '', $value);
		$value = str_replace('$', ' ', $value);
		$array[$name] = $value;
	}
	return $array;
}

function FilterXSS($array) {
	foreach($array as $name=>$value) {
		//$value = htmlentities($value,ENT_QUOTES, 'UTF-8');
		$value = htmlspecialchars($value, ENT_QUOTES);
		if (get_magic_quotes_gpc())
			$value = stripslashes($value);
		$value = @mysql_real_escape_string($value);
		$value = strip_tags($value);
		$value = str_replace("\n", ' ', $value);
		$value = str_replace("\r", '', $value);
		$value = str_replace('$', ' ', $value);
		$array[$name] = $value;
	}
	return $array;
}

function is_lan($ip) {
	$patterns = array('/(192).(168).(\d+).(\d+)/i', '/(172).(\d+).(\d+).(\d+)/i', '/(10).(\d+).(\d+).(\d+)/i');
	foreach ($patterns as $pattern) {
		if (preg_match($pattern, $ip))
			return true;
	}
	return false;
}

function IsLAN($ip) {
	$patterns = array('/(192).(168).(\d+).(\d+)/i', '/(172).(\d+).(\d+).(\d+)/i', '/(10).(\d+).(\d+).(\d+)/i');
	foreach ($patterns as $pattern) {
		if (preg_match($pattern, $ip))
			return true;
	}
	return false;
}

/*function is_lan($ip) {
	global $lanlist;
	$name = gethostbyname($ip);
	if ($name)
		$addr = ip2long($name);
	else
		$addr = ip2long($ip);
	for ($i = 0; $lanlist[$i] != 0; $i += 2) {
		if (($addr & $lanlist[$i + 1]) == ($lanlist[$i + 0] & $lanlist[$i + 1])) {
			return true;
		}
	}
	return false;
}*/
