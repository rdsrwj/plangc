<?php
# Фильтр
if (empty($_SERVER['HTTP_USER_AGENT'])) die();

define('INCLUDED', true);
define('PATH_BASE', dirname(__FILE__));

require_once PATH_BASE.'/includes/functions.php';

# Глобальные переменные
$Client = array();
$Client['client_ip'] = GetClientIP();
$Client['user_agent'] = $_SERVER['HTTP_USER_AGENT'];

# Фильтр
if (!IsIP($Client['client_ip'])) die('Forbidden access');

require_once PATH_BASE.'/includes/config.php';
require_once PATH_BASE.'/includes/class.database.php';

global $Config;

require_once PATH_BASE.'/includes/safemysql.class.php';
require_once PATH_BASE.'/includes/class.cache.php';

# Запрашиваемая команда
$do = (string)@$_REQUEST['do'];

# Разрешённые команды
$allow_do = array(
	'svr_add',
	'svr_get',
	'svr_getshort',
	'vpn_add',
	'vpn_del',
	'vpn_get',
	'vpn_getshort',
	'getnews',
	'checkupdates',
	'status'
);

# Проверяем вхождение
if (in_array($do, $allow_do))
	$sub = $do;
else
	$sub = false;

if ($sub !== false)
	require_once PATH_BASE.'/core/'.$sub.'.php';
else
	require_once PATH_BASE.'/template/index.php';
