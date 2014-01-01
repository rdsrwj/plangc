<?php
class Database {
	var $link_id;
	var $query_result;
	var $num_queries = 0;

	function __construct($db_host, $db_username, $db_password, $db_name) {
		$this->link_id = @mysql_connect($db_host, $db_username, $db_password, true);
		if ($this->link_id) {
			if (@mysql_select_db($db_name, $this->link_id))
				return $this->link_id;
			else
				$this->error('Unable to select database.');
		}
		else
			$this->error('Unable to connect to MySQL server.');
	}

	function query($sql) {
		$this->query_result = @mysql_query($sql, $this->link_id);
		if ($this->query_result) {
			++$this->num_queries;
			return $this->query_result;
		}
		else
			return false;
	}

	function result($query_id = 0, $row = 0) {
		return ($query_id) ? @mysql_result($query_id, $row) : false;
	}

	function fetch_assoc($query_id = 0) {
		return ($query_id) ? @mysql_fetch_assoc($query_id) : false;
	}

	function fetch_row($query_id = 0) {
		return ($query_id) ? @mysql_fetch_row($query_id) : false;
	}

	function num_rows($query_id = 0) {
		return ($query_id) ? @mysql_num_rows($query_id) : false;
	}

	function affected_rows() {
		return ($this->link_id) ? @mysql_affected_rows($this->link_id) : false;
	}

	function insert_id() {
		return ($this->link_id) ? @mysql_insert_id($this->link_id) : false;
	}

	function get_num_queries() {
		return $this->num_queries;
	}

	function free_result($query_id = false) {
		return ($query_id) ? @mysql_free_result($query_id) : false;
	}

	function escape($str) {
		if (function_exists('mysql_real_escape_string'))
			return mysql_real_escape_string($str, $this->link_id);
		else
			return mysql_escape_string($str);
	}

	function error($msg) {
		//echo $msg;
	}

	function close() {
		if ($this->link_id) {
			if ($this->query_result)
				@mysql_free_result($this->query_result);
			return @mysql_close($this->link_id);
		}
		else
			return false;
	}
}
