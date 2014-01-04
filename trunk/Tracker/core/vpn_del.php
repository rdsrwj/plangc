<?php
defined('INCLUDED') or die('Restricted access');

$db = new SafeMySQL($opts);
$db->query("DELETE FROM tracker WHERE (client_ip='{$Client['client_ip']}') AND (static=0)") or die('Database error');
