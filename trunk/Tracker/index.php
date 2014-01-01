<?php
# Filter
if (empty($_SERVER['HTTP_USER_AGENT'])) die();

define('INCLUDED', true);
define('PATH_BASE', dirname(__FILE__));

require_once PATH_BASE.'/includes/functions.php';

# Global variables
$Client = array();
$Client['ip'] = GetClientIP();
$Client['user_agent'] = $_SERVER['HTTP_USER_AGENT'];

# Filter
if (!IsIP($Client['ip'])) die('Forbidden access');

# Includes
require_once PATH_BASE.'/includes/config.php';
require_once PATH_BASE.'/includes/class.database.php';

global $Config;

require_once PATH_BASE.'/includes/safemysql.class.php';
require_once PATH_BASE.'/includes/class.cache.php';

# Requesting command
$do = (string)@$_REQUEST['do'];

# Permitted commands
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

# Check entry
if (in_array($do, $allow_do))
	$sub = $do;
else
	$sub = false;

if ($sub !== false)
	require_once PATH_BASE.'/core/'.$sub.'.php';
else
	require_once PATH_BASE.'/template/index.php';
