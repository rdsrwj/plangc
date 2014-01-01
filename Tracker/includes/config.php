<?php
defined('INCLUDED') or die('Restricted access');

# ToDo: искоренить старый класс "Database"

# Опции для старого класса "Database" (class.database.php)
$Config['db_host']     = 'localhost'; // Host for database.
$Config['db_username'] = 'username';  // Username for database.
$Config['db_password'] = 'password';  // Password for database.
$Config['db_name']     = 'plangc';    // Name of database.
$Config['db_encoding'] = 'CP1251';    // Database encoding.

# Опции для нового класса "SafeMySQL" (safemysql.class.php)
$opts = array(
	'user'    => 'username',
	'pass'    => 'password',
	'db'      => 'plangc',
	'charset' => 'cp1251'
);
