<?php

// LASER310
/*
vz 文件格式
VZF_MAGIC : 4个字节 0x20 0x20 0x00 0x00 或者是 0x56 0x5A 0x46 0x30
vzf_filename : 17个字节 最后一个字节必须为零，末尾不足的字符用空格0x20代替
vzf_type : 1个字节 同磁带
vzf_startaddr : 2个字节 程序开始地址
之后是数据
*/

function vzf_parse(&$vz_buf)
{
	$vz_len = strlen($vz_buf);

	$dat_sum=0;
	//$dat_sum=0xFF00;

	$a = [];

	// VZF_MAGIC 0x20 0x20 0x00 0x00
	// VZF_MAGIC 0x56 0x5a 0x46 0x30 VZF
	if( !( (ord($vz_buf{0})==0x20 && ord($vz_buf{1})==0x20 && ord($vz_buf{2})==0x00 && ord($vz_buf{3})==0x00 ) ||
		   (ord($vz_buf{0})==0x56 && ord($vz_buf{1})==0x5a && ord($vz_buf{2})==0x46 && ord($vz_buf{3})==0x30 )) ) {
		return "err format";
	}

	// len
	$i = 4;
	for($n=0;$n<17;$n=$n+1) {
		if($vz_buf{$i+$n}=="\0") break;
	}
	//printf("filename len : %d\n",$n);

	$fn_len = ($n>=17)?17:$n+1;
	$prg_len = $vz_len -4-17-1-2;
	$mif_len = 2+1+128+5+1+$fn_len+2+2+$prg_len+2+20;
	$cass_len =    128+5+1+$fn_len+2+2+$prg_len+2+20;

	// VZF_TYPE
	$i = 4+17;
	$vzf_type = ord($vz_buf{$i});

	// VZF_FILENAME
	$i = 4;
	$vzf_filename = "";
	for($n=0;$n<$fn_len;$n=$n+1)
		$vzf_filename{$n} = $vz_buf{$i+$n};

	// VZF_STARTADDR
	$vzf_startaddr = 0;
	$i = 4+17+1;
	$vzf_startaddr = ord($vz_buf{$i+0});
	$vzf_startaddr += ord($vz_buf{$i+1})*256;

	// END ADDR
	$vzf_endaddr = $vzf_startaddr + $prg_len -1;


	// DATA
	$i = 4+17+1+2;
	$vzf_data = "";
	for($n=0;$n<$prg_len;$n=$n+1)
	{
		$vzf_data{$n} = $vz_buf{$i+$n};
	}

	$a["vzf_filename"] = $vzf_filename;
	$a["vzf_type"] = $vzf_type;
	$a["vzf_startaddr"] = $vzf_startaddr;
	$a["vzf_endaddr"] = $vzf_endaddr;
	$a["vzf_datalen"] = $prg_len;
	$a["vzf_data"] = $vzf_data;

	return $a;
}


function vzf_vzf2vz(&$a)
{
	$vz_buf = str_repeat("\0", $a["vzf_datalen"]+4+17+1+2);

	// VZF_MAGIC 0x56 0x5a 0x46 0x30 VZF
	$vz_buf{0} = chr(0x56);
	$vz_buf{1} = chr(0x5a);
	$vz_buf{2} = chr(0x46);
	$vz_buf{3} = chr(0x30);

	// len
	$i = 4;

/*
	for($n=0;$n<16;$n++) {
		$vz_buf{$i+$n} = "\x20";
	}
	$vz_buf{$i+16} = "\0";
*/

	for($n=0;$n<strlen($a["vzf_filename"]);$n++) {
		$vz_buf{$i+$n} = $a["vzf_filename"]{$n};
	}
	$i += 17;

	$vz_buf{$i} = chr($a["vzf_type"]);
	$i++;

	$vz_buf{$i} = chr($a["vzf_startaddr"]&0xFF);
	$vz_buf{$i+1} = chr(($a["vzf_startaddr"]>>8)&0xFF);
	$i += 2;

	for($n=0;$n<strlen($a["vzf_data"] );$n++) {
		$vz_buf{$i+$n} = $a["vzf_data"]{$n};
	}

	return $vz_buf;
}
