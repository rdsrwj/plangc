<?php
defined('INCLUDED') or die('Restricted access');
header('Content-Type: text/plain; charset=windows-1251');

$lang = (string)@$_REQUEST['lang'];

echo "pLan Gaming Client\r\n\r\n";

switch ($lang) {
	case 'ru':
		//echo date('d.m.Y')."  pLan Gaming Client\r\n";
		//echo 'No news at this time';
		echo "26.12.2013  Небольшое обновление программы v0.6.65\r\n\r\n";
		echo "11.12.2013  Обновлён список игр для pLan OpenVPN Edition";
		break;
	default:
		//echo date('d.m.Y')."  pLan Gaming Client\r\n";
		//echo 'No news at this time';
		echo "11.12.2013  Updated list of games for pLan OpenVPN Edition";
}
