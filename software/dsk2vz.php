<?php
// 把标准的 dsk 文件中的文件提取出来，以 vz 格式存放。
// 用于 LASER310 FPGA DD20 虚拟软驱

include_once('vztool_dsk.php');
include_once('vztool_vzf.php');

// LASER310
// 转换长度98560字节dsk磁盘镜像中的文件到 vz 格式
// 98560 = 154 * 16  * 40
// 154 * 16 = 2464


/*
每轨的扇区号依次为：
0x00 0x0B 0x06 0x01
0x0C 0x07 0x02 0x0D
0x08 0x03 0x0E 0x09
0x04 0x0F 0x0A 0x05
*/

function basename_ext($fn,$a_suffix)
{
	$file_basename = basename($fn);

	foreach($a_suffix as $s) {
		$fn_s = basename($fn,$s);
		if($fn_s!=basename($fn)) {
			$file_basename = $fn_s;
			break;
		}
	}

	return $file_basename;
}

if($argc<2) {
	printf("php dsk2vz.php abc.dsk\n");
	exit;
}

$fn=$argv[1];

$r_buf = file_get_contents($fn);
if($r_buf===FALSE) exit;

$fn_dsk = trim(basename_ext($fn,[".dsk",".DSK"]));

$l = strlen($r_buf);

printf("dsk file %s file len %d\n", $fn, $l);

//支持标准的 dsk 文件格式，即长度为98560字节的磁盘格式
if($l!=TRACK_SIZE*TRACK_N) {
	printf("Unrecognized file format.\n");
	exit;
}

$buf = dsk_dsk2buf($r_buf);
if(strlen($buf)!=SECTOR_DATA_SIZE*16*40) {
	echo $buf;
	exit;
}

// 目录数量不能超过 15*128/16 = 120
$next_dir = 0;
$next_t = 1;
$next_s = 0;

$dir_buf = str_repeat("\0", 16);

$vzf_a = [];

while($next_dir<120) {
	// 找到目录数据
	$buf_pos = 0*TRACK_DATA_SIZE+$next_dir*16;
	for($i=0;$i<16;$i++) {
		$dir_buf{$i} = $buf{$buf_pos+$i};
	}

	// 目录表
	// 1个字节 文件类型 T 0x54 B 0x42 D 0x44
	// 1个字节 标识 0x3A
	// 8个字节 文件名
	// 2个字节 0x01 0x00 数据存放位置，磁道扇区
	// 2个字节 开始地址
	// 2个字节 结束地址
	$f_type = $dir_buf{0};
	$f_flag = $dir_buf{1};
	$fn_s = str_repeat("\0", 8);
	for($i=0;$i<strlen($fn_s);$i++) {
		$fn_s{$i} = $dir_buf{2+$i};
	}
	$next_t = ord($dir_buf{10});
	$next_s = ord($dir_buf{11});
	$f_startaddr	= ord($dir_buf{12})+ord($dir_buf{13})*256;
	$f_endaddr		= ord($dir_buf{14})+ord($dir_buf{15})*256;

	$vzf_type = 0x00;
	if($f_type=="T") $vzf_type=0xF0;
	if($f_type=="B") $vzf_type=0xF1;
	// 暂时没有确定
	if($f_type=="D") $vzf_type=0xF2;
	if($f_type=="\1") $vzf_type=0xFF;
	// 遇到0则结束
	if($f_type=="\0") break;
	
	if($vzf_type==0x00) {
		printf("err filetype %02X", ord($f_type));
		exit;
	}

	if($vzf_type!=0xFF) {
		printf("%2d %02X %04X %04X %s\n", $next_dir, $vzf_type, $f_startaddr, $f_endaddr, trim($fn_s),);
	}

	// 只转换 T B 类型的文件
	if($f_type=="T"||$f_type=="B") {
		$f_len = $f_endaddr - $f_startaddr;
		$f_dat = str_repeat("\0", $f_len);
		$cnt=0;
		while($cnt<$f_len) {
			$buf_pos = $next_t*TRACK_DATA_SIZE+$next_s*SECTOR_DATA_SIZE;

			// 复制扇区中的数据
			// 最后两个字节是指向下一个扇区
			$l = min($f_len-$cnt,SECTOR_DATA_SIZE-2);
			for($i=0;$i<$l;$i++) {
				$f_dat{$cnt+$i} = $buf{$buf_pos+$i};
			}
			$cnt+=$l;

			// 下一个扇区
			$next_t = ord($buf{$buf_pos+SECTOR_DATA_SIZE-2});
			$next_s = ord($buf{$buf_pos+SECTOR_DATA_SIZE-1});
		}

		$a = [];
		$a["vzf_filename"] = trim($fn_s);
		$a["vzf_type"] = $vzf_type;
		$a["vzf_startaddr"] = $f_startaddr;
		$a["vzf_endaddr"] = $f_endaddr-1;
		$a["vzf_datalen"] = $f_len;
		$a["vzf_data"] = $f_dat;

		$vz_buf = vzf_vzf2vz($a);

		//$vzf_a[$fn_s] = $a;
		$fn_vz = sprintf("%s.%s.%s.vz", $fn_dsk, trim($fn_s), $f_type);
		echo "build $fn_vz\n";
		file_put_contents($fn_vz, $vz_buf);
	}

	$next_dir++;
}

//printf("%d\n", count($vzf_a));
