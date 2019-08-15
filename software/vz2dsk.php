<?php
include_once('vztool_dsk.php');
include_once('vztool_vzf.php');

function show_bit($ch)
{
	//for($i=128;$i>1;$i=$i/2)
	for($i=1;$i<256;$i=$i*2)
	{
		echo ($ch&$i)?"#":".";
	}
}

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
	printf("php vz2dsk.php trg.dsk src1.vz src2.vz src3.vz ...\n");
	exit;
}


// 读入vz文件
$fn_dsk = $argv[1];

$vzf_a = [];

$n = 2;
while($n<$argc) {
	$fn=$argv[$n];
	$n++;

	$fn_s = strtoupper(trim(basename_ext($fn,[".vz",".VZ"])));
	echo "read $fn\n";
	//echo "basename $fn_s\n";
	$fn_s = trim(substr($fn_s,0,8));
	//echo "dsk filename $fn_s\n";

	$vzf_buf = file_get_contents($fn);
	if($vzf_buf===FALSE) exit;

	$vzf = vzf_parse($vzf_buf);
	if(is_string($vzf)) {
		echo $vzf;
		exit;
	}

	printf("%s : %s %02X %04X %04X %04X\n", $fn_s, $vzf["vzf_filename"], $vzf["vzf_type"], $vzf["vzf_startaddr"], $vzf["vzf_endaddr"], $vzf["vzf_datalen"]);

	$vzf_a[$fn_s] = $vzf;
}

// 目录数量不能超过 15*128/16 = 120

$vzf_n = count($vzf_a);

if($vzf_n>=120) {
	echo "dir over";
	exit;
}

// 建立目录表和扇区数据
$buf = dsk_empty_buf();

$s_cnt = 0;
$next_dir = 0;
$next_t = 1;
$next_s = 0;

foreach( $vzf_a as $fn_s=>$vzf ) {
	echo "build $fn_s\n";
	// 建立目录表
	$dir_buf = str_repeat("\x20", 16);
	// 1个字节 文件类型 T 0x54 B 0x42 D 0x44
	// 1个字节 标识 0x3A
	// 8个字节 文件名
	// 2个字节 0x01 0x00 数据存放位置，磁道扇区
	// 2个字节 开始地址
	// 2个字节 结束地址
	$f_type = "";
	if($vzf["vzf_type"]==0xF0)
		$f_type = "T";
	if($vzf["vzf_type"]==0xF1)
		$f_type = "B";
	// 暂时没有确定
	if($vzf["vzf_type"]==0xF2)
		$f_type = "D";
	if($f_type=="") {
		printf("err filetype %02X", $vzf["vzf_type"]);
		exit;
	}

	$dir_buf{0} = $f_type;
	$dir_buf{1} = "\x3A";
	for($i=0;$i<strlen($fn_s);$i++) {
		$dir_buf{2+$i} = $fn_s{$i};
	}
	$dir_buf{10} = chr($next_t);
	$dir_buf{11} = chr($next_s);
	$dir_buf{12} = chr($vzf["vzf_startaddr"]&0xFF);
	$dir_buf{13} = chr(($vzf["vzf_startaddr"]>>8)&0xFF);
	$dir_buf{14} = chr(($vzf["vzf_endaddr"]+1)&0xFF);
	$dir_buf{15} = chr((($vzf["vzf_endaddr"]+1)>>8)&0xFF);

	// 复制目录数据到零道
	$buf_pos = 0*TRACK_DATA_SIZE+$next_dir*16;
	for($i=0;$i<16;$i++) {
		$buf{$buf_pos+$i} = $dir_buf{$i};
	}
	//for($i=0;$i<16;$i++) {printf("%02X ", ord($dir_buf{$i}));};

	// 复制扇区数据
	//$f_len = $vzf["vzf_endaddr"] - $vzf["vzf_startaddr"] + 1;
	$f_len = $vzf["vzf_datalen"];
	$cnt = 0;
	while($cnt<$f_len) {
		if($next_t>=TRACK_N) {
			printf("dsk full");
			exit;
		}

		$buf_pos = $next_t*TRACK_DATA_SIZE+$next_s*SECTOR_DATA_SIZE;

		// 下一个扇区
		$next_s++;
		if($next_s==SECTOR_N) {
			$next_s=0;
			$next_t++;
		}

		// 最后两个字节是指向下一个扇区
		$l = min($f_len-$cnt,SECTOR_DATA_SIZE-2);
		for($i=0;$i<$l;$i++) {
			$buf{$buf_pos+$i} = $vzf["vzf_data"]{$cnt+$i};
		}

		$cnt+=SECTOR_DATA_SIZE-2;

		// 最后2个字节是下一个存放区域
		if($cnt>=$f_len) {
			// 最后一个扇区放 0 0
			$buf{$buf_pos+SECTOR_DATA_SIZE-2} = "\0";
			$buf{$buf_pos+SECTOR_DATA_SIZE-1} = "\0";
		} else {
			$buf{$buf_pos+SECTOR_DATA_SIZE-2} = chr($next_t);
			$buf{$buf_pos+SECTOR_DATA_SIZE-1} = chr($next_s);
		}

		$s_cnt++;
	}

	$next_dir++;
}

printf("sector count %d/%d (%dKB/%dKB)", $s_cnt, 39*16, $s_cnt/8, 39*2);


// 标记占用的扇区
// 0道 15扇区

$buf_pos = 0*TRACK_DATA_SIZE + 15*SECTOR_DATA_SIZE;

$i = 0;
$bit = 0;
$v = 0;
for($n=0;$n<$s_cnt;$n++) {
	$v = ($v<<1) + 1;
	if($bit==7) {
		$buf{$buf_pos+$i} = chr($v);
		$bit=0;
		$v=0;
		$i++;
	} else {
		$bit++;
	}
}

if($bit!=0)
	$buf{$buf_pos+$i} = chr($v);
	
$dsk_buf = dsk_buf2dsk($buf);

//echo $s;
file_put_contents($fn_dsk, $dsk_buf);

