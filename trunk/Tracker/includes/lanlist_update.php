<?php
$list = fopen('./lanlist.txt', 'r');
if (!$list) die('Failed to open lan list');

$localist = fopen('lanlist.php', 'w');
if (!$localist) die('Failed to create local file');

$start = true;
fwrite($localist, '<?php' . "\n" . '$lanlist = array(' . "\n");
while (!feof($list)) {
	$n = fgets($list);
	if (is_numeric($n[0])) {
		if (!strpos($n, '/')) $n .= '/24';
		if (!$start) fwrite($localist, ",\n");
		$start = false;
		$ip_arr = explode('/', $n);
		$network_long = ip2long($ip_arr[0]);
		$x = ip2long($ip_arr[1]);
		$mask = (long2ip($x) == $ip_arr[1]) ? $x : 0xffffffff << (32 - $ip_arr[1]);
		fwrite($localist, "\t$network_long, $mask");
	}
}
fwrite($localist, ",\n\t" . '0, 0' . "\n);\n" . '?>');
fclose($localist);
fclose($list);

echo 'Updated successfully';
