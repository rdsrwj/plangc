<?php
defined('INCLUDED') or die('Restricted access');
header('Content-Type: text/plain; charset=windows-1251');

# Actual build of pLan_openvpn.exe
$actual_build = '65';

echo $actual_build."\n";

# Actual version of gamelist.txt
echo "15\n\n";

/* ToDo:
$your_build = @$_GET['build'];
if (empty($your_build) || $your_build < $actual_build) {
	echo 'outdated';
} else {
	echo 'updated';
}
*/
