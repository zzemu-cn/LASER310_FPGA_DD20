<?php
// 把非标准的 dsk 文件转换为标准的 dsk 文件。
// 用于 LASER310 FPGA DD20 虚拟软驱

include_once('vztool_dsk.php');

// LASER310
// 转换dsk磁盘镜像到长度98560字节的磁盘格式
// 98560 = 154 * 16  * 40
// 154 * 16 = 2464
// 2564+16 = 2580

/*
每轨的扇区号依次为：
0x00 0x0B 0x06 0x01
0x0C 0x07 0x02 0x0D
0x08 0x03 0x0E 0x09
0x04 0x0F 0x0A 0x05
*/

define("TRACK_MAX_SIZE", 2580);


if($argc<3) {
	printf("php dsk_std.php src.dsk trg.dsk\n");
	exit;
}

$fn=$argv[1];
$fn_out=$argv[2];

$r_buf = file_get_contents($fn);
if($r_buf===FALSE) exit;

$l = strlen($r_buf);

printf("dsk file %s file len %d\n", $fn, $l);

/*
if($l==TRACK_SIZE*TRACK_N) {
	printf("dsk files do not need to be converted\n");
	exit;
}
*/

// 转换每磁道大于 2564 小于 2580
if($l>=TRACK_SIZE*TRACK_N && $l<=TRACK_MAX_SIZE*TRACK_N) {
	$buf = dsk_conv_more($r_buf);
	if($buf) {
		$dsk_buf = dsk_buf2dsk($buf);
		file_put_contents($fn_out,$dsk_buf);
	}

	exit;
}

printf("Unrecognized file format.\n");

exit;


function dsk_conv_more(&$r_buf)
{
	$buf = dsk_empty_buf();
	$t_buf = str_repeat("\0", TRACK_MAX_SIZE);

	$l = strlen($r_buf);

	$sec_flag_x80_n = 0;

	// 找出当前格式每个轨长度
	for($t_len=TRACK_SIZE;$t_len<=TRACK_MAX_SIZE;$t_len++) {
		if($t_len*TRACK_N>=$l) break;
	}
	printf("track size %d 0x%04X (%d + %d)\n", $t_len, $t_len, TRACK_SIZE, $t_len-TRACK_SIZE);
	
	for($t=0;$t<TRACK_N;$t++) {
		printf("%02d:%05X", $t, $t*TRACK_SIZE);

		$t_pos = $t*$t_len;

		// 找到每扇区数据
		$c=0;
		for($sec=0;$sec<SECTOR_N;$sec++) {
			// 需要查找的扇区号
			$s = sector_n($sec);
			printf(" %s ", sector_a($s) );
		
			$dat = dsk_sector2dat($r_buf, $t_pos, $t_len, $t, $s);

			if(strlen($dat)!=SECTOR_DATA_SIZE) {
				printf("\n$dat");
				return "";
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
