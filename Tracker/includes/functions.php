<?php
defined('INCLUDED') or die('Restricted access');

require_once PATH_BASE . '/includes/lanlist.php';

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

function IsIP($ip) {
	return (bool)(ip2long($ip) > 0);
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

function json_fix_cyr($var) {
	if (is_array($var)) {
		$new = array();
		foreach ($var as $k => $v) {
			$new[json_fix_cyr($k)] = json_fix_cyr($v);
		}
		$var = $new;
	} elseif (is_object($var)) {
		$vars = get_object_vars($var);
		foreach ($vars as $m => $v) {
			$var->$m = json_fix_cyr($v);
		}
	} elseif (is_string($var)) {
		$var = iconv('cp1251', 'utf-8', $var);
	}
	return $var;
}

function json_safe_encode($var) {
	return json_encode(json_fix_cyr($var));
}
