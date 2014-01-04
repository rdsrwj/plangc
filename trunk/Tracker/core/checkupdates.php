<?php
defined('INCLUDED') or die('Restricted access');
header('Content-Type: text/plain; charset=windows-1251');

# Актуальный билд pLan_openvpn.exe
if ($_SERVER['REMOTE_ADDR'] == '213.176.225.168') {
	$actual_build = '66';
} else {
	$actual_build = '66';
}

echo $actual_build."\n";

# Актуальная версия gamelist.txt
echo "15\n\n";

/* ToDo:
$your_build = @$_GET['build'];
if (empty($your_build) || $your_build < $actual_build) {
	echo 'outdated';
} else {
	echo 'updated';
}
*/
