<?php

// LASER310
// 转换dsk磁盘镜像到长度98560字节的磁盘格式
// 98560 = 154 * 16  * 40
// 154 * 16 = 2464
// 2564+16 = 2580

define("TRACK_N", 40);
define("TRACK_SIZE", 2464);

define("SECTOR_N", 16);
define("SECTOR_SIZE", 154);

define("TRACK_DATA_SIZE", 2048);
define("SECTOR_DATA_SIZE", 128);


function sector_a($n)
{
	//return substr("0123456789ABCDEF", $n, 1);
	$a = "0123456789ABCDEF";
	return $a{$n};
}

/*
每轨的扇区号依次为：
0x00 0x0B 0x06 0x01
0x0C 0x07 0x02 0x0D
0x08 0x03 0x0E 0x09
0x04 0x0F 0x0A 0x05
*/

function sector_n($n)
{
	$a	=	[
				0x00, 0x0B, 0x06, 0x01,
				0x0C, 0x07, 0x02, 0x0D,
				0x08, 0x03, 0x0E, 0x09,
				0x04, 0x0F, 0x0A, 0x05
			];
	return $a[$n];
}

function sector_pos($n)
{
	$a	=	[
				0x00, 0x0B, 0x06, 0x01,
				0x0C, 0x07, 0x02, 0x0D,
				0x08, 0x03, 0x0E, 0x09,
				0x04, 0x0F, 0x0A, 0x05
			];
	return array_search($n, $a);
}


function dsk_empty_buf()
{
	$buf = str_repeat("\0", SECTOR_DATA_SIZE*SECTOR_N*TRACK_N);
	return $buf;
}


// 缓冲区数据转扇区格式
function dsk_dat2sec(&$dsk_buf, $dsk_buf_pos, $t, $s, &$buf, $buf_pos)
{
	// 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0xFE, 0xE7, 0x18, 0xC3
	$sec_head = "\x80\x80\x80\x80\x80\x80\x00\xFE\xE7\x18\xC3\x00\x00\x00\x80\x80\x80\x80\x80\x00\xC3\x18\xE7\xFE";
	$sec_head_len = strlen($sec_head);

	for($i=0;$i<$sec_head_len;$i++)
		$dsk_buf{$dsk_buf_pos + $i} = $sec_head{$i};

	$dsk_buf{$dsk_buf_pos+0x0B} = chr($t);
	$dsk_buf{$dsk_buf_pos+0x0C} = chr($s);
	$dsk_buf{$dsk_buf_pos+0x0D} = chr($t+$s);


	$chk=0;
	for($i=0;$i<SECTOR_DATA_SIZE;$i++) {
		$dsk_buf{$dsk_buf_pos+$sec_head_len+$i} = $buf{$buf_pos+$i};
		$chk += ord($buf{$buf_pos+$i});
	}

	$dsk_buf{$dsk_buf_pos+$sec_head_len+SECTOR_DATA_SIZE}	= chr($chk&0xFF);
	$dsk_buf{$dsk_buf_pos+$sec_head_len+SECTOR_DATA_SIZE+1} = chr(($chk>>8)&0xFF);
}

// 缓冲区数据转磁盘格式
function dsk_buf2dsk(&$buf)
{
	$dsk_buf = str_repeat("\0", SECTOR_SIZE*SECTOR_N*TRACK_N);

	for($t=0;$t<TRACK_N;$t++) {
		for($sec=0;$sec<SECTOR_N;$sec++) {
			$buf_pos = $t*TRACK_DATA_SIZE+$sec*SECTOR_DATA_SIZE;
			// 查找的扇区位置
			$s_pos = sector_pos($sec);
			$dsk_buf_pos = $t*TRACK_SIZE+$s_pos*SECTOR_SIZE;

			// 转换扇区
			dsk_dat2sec($dsk_buf, $dsk_buf_pos, $t, $sec, $buf, $buf_pos);
		}
	}

	return $dsk_buf;
}

// 循环缓冲区 ring buffer
function rb_read_ch(&$buf, $n)
{
	$l = strlen($buf);
	if($l==0) return "";

	return $buf{$n%$l};
}

// 循环缓冲区 ring buffer
function rb_cmp_str(&$buf,$n,&$s)
{
	$l = strlen($s);

	for($i=0;$i<$l;$i++) {
		if($s{$i}!=rb_read_ch($buf,$n+$i))
			return false;
	}

	return true;
}


function sector_check(&$dat)
{
	$chk = 0;
	for($i=0;$i<SECTOR_DATA_SIZE;$i++) {
		$chk += ord($dat{$i});
	}
	return $chk;
}

// 找到扇区并返回扇区数据数据
function dsk_sector2dat(&$buf, $t_pos, $t_len, $t, $s)
{
	$dat = str_repeat("\0", SECTOR_DATA_SIZE);
	$t_buf = str_repeat("\0", $t_len);

	$l = strlen($buf);
	for($i=0;$i<$t_len;$i++) {
		if($t_pos+$i>=$l) break;
		$t_buf{$i} = $buf{$t_pos+$i};
	}

	// 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0xFE, 0xE7, 0x18, 0xC3
	$sec_IDAM = "\x00\xFE\xE7\x18\xC3\x00\x00\x00";
	$sec_IDAM_len = strlen($sec_IDAM);

	$sec_DATA = "\x00\xC3\x18\xE7\xFE";
	$sec_DATA_len = strlen($sec_DATA);


	$sec_flag_x80_n = 0;

	// 找到扇区数据

	// 需要查找的 IDAM
	$s_IDAM = $sec_IDAM;
	$s_IDAM{5} = chr($t);
	$s_IDAM{6} = chr($s);
	$s_IDAM{7} = chr($t+$s);

	// 查找整个轨道
	$c=0;
	while($c<$t_len) {
		// 跳过 0x80
		$i=0;
		while($i<10) {
			if( rb_read_ch($t_buf,$c+$i)!="\x80")	break;
			$i++;
		}
		$c+=$i;

		// 找扇区 IDAM
		if( rb_cmp_str($t_buf, $c, $s_IDAM) )	{
			$c+=$sec_IDAM_len;
			break;
		}

		$c++;
	}

	if($c>=$t_len) {
		return "IDAM err";
	}

	// 跳过 0x80
	$i=0;
	while($i<10) {
		if( rb_read_ch($t_buf,$c+$i)!="\x80")	break;
		$i++;
	}
	$c+=$i;

	// 找扇区数据区
	if( !rb_cmp_str($t_buf, $c, $sec_DATA) )	{
		return "IDAM data err";
	}

	$c+=$sec_DATA_len;

	// 复制数据
	for($i=0;$i<SECTOR_DATA_SIZE;$i++)
		$dat{$i} = rb_read_ch($t_buf, $c+$i);

	$data_chk = ord(rb_read_ch($t_buf, $c+SECTOR_DATA_SIZE)) + ord(rb_read_ch($t_buf, $c+SECTOR_DATA_SIZE+1))*256;

	$cur_chk = sector_check($dat);

	if($data_chk!=$cur_chk) {
		$err = sprintf("check err(%04X)", $data_chk);
		return $err;
	}

	return $dat;
}


// 把扇区中的数据提取出来, 存放到 128*16*40 字节的缓冲区
// 支持标准的 dsk 文件格式，即长度为98560字节的磁盘格式
function dsk_dsk2buf(&$dsk_buf)
{
	$buf = dsk_empty_buf();
	$t_buf = str_repeat("\0", TRACK_SIZE);

	$l = strlen($dsk_buf);

	$sec_flag_x80_n = 0;

	// 找出当前格式每个轨长度
	$t_len=TRACK_SIZE;

	for($t=0;$t<TRACK_N;$t++) {
		printf("%02d:%05X", $t, $t*TRACK_SIZE);

		$t_pos = $t*$t_len;

		// 找到每扇区数据
		$c=0;
		for($sec=0;$sec<SECTOR_N;$sec++) {
			// 需要查找的扇区号
			$s = sector_n($sec);
			printf(" %s ", sector_a($s) );
		
			$dat = dsk_sector2dat($dsk_buf, $t_pos, $t_len, $t, $s);

			if(strlen($dat)!=SECTOR_DATA_SIZE) {
				return $dat;
			}

			printf("%04X", sector_check($dat));

			// 复制扇区数据
			$buf_pos = $t*TRACK_DATA_SIZE+$s*SECTOR_DATA_SIZE;
			for($i=0;$i<SECTOR_DATA_SIZE;$i++)
				$buf{$buf_pos+$i} = $dat{$i};
		}
		printf("\n");
	}

	return $buf;
}
