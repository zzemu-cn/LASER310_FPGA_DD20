<?php
//include_once('view.php');

// 生成 intel hex 文件格式
function bin2ihex($buf)
{
	$l = strlen($buf);

	$s = "";

	$c = 0;
	while($c<$l) {
		if(($c&0xFFFF)==0) {
			$checksum = 2+4;
			$checksum += (($c>>16)&0xFF);
			$checksum += (($c>>24)&0xFF);
			$s .= sprintf(":02000004%04X%02X\n", (($c>>16)&0xFFFF), (~($checksum&0xFF) + 1)&0xFF);
		}

		$n = $l-$c;
		if($n>16) $n=16;
		$checksum = $n;
		$checksum += ($c&0xFF);
		$checksum += (($c>>8)&0xFF);
		$s .= sprintf(":%02X%04X00", $n, ($c&0xFFFF));
		for($i=0;$i<$n;$i++) {
			$ch = ord($buf{$c+$i});
			$s .= sprintf("%02X",$ch);
			$checksum += $ch;
		}

		$s .= sprintf("%02X\n", (~($checksum&0xFF) + 1)&0xFF);

		$c += $n;
	}

	$s .= ":00000001FF\n";

	return $s;
}


function bin2asciihex($buf)
{
	$l = strlen($buf);

	$s = "";

	$c = 0;
	while($c<$l) {
		$n = $l-$c;
		if($n>16) $n=16;

		for($i=0;$i<$n;$i++) {
			$ch = ord($buf{$c+$i});
			$s .= sprintf("%02X",$ch);
		}

		$c += $n;
	}

	return $s;
}


//$bin_name  = strval($argv[1]);
//$file_name  = strval($argv[2]);

$file_name  = "flash_rom.bin";
$hex_file_name  = "flash_rom.hex";

$rom_lst	=	[
	//	bank 0
	//	0000H 16K 0 1 2 3
	[	"vtech/vtechv20.u12",			0*4,	],	// 16K
	[	"vtech/vtechv12.u12",			1*4,	],	// 16K
	[	"vtech/vtechv21.u12",			2*4,	],	// 16K

	//	4000H 8K 4 5
	[	"vtech/vzdosv12.rom",			8*4,	],	// 8K
	[	"vtech/char.rom", 				8*4+2,	],	// 8K

//	[	"zx/zx80/zx80.rom", 			12*4,	],	// 8K
//	[	"zx/zx80/aszmic.rom", 			12*4+1,	],	// 8K

//	[	"zx/pc8300/8300_org.rom", 		13*4,	],	// 8K
//	[	"zx/zx81/zx81.rom", 			13*4+2,	],	// 8K
//	[	"zx/lambda/lambda.rom", 		14*4,	],	// 8K
//	[	"zx/LAM10061.BIN", 				14*4+2,	],	// 8K
//	[	"zx/8300_fnt.bin", 				15*4+2,	],	// 8K

	//	bank 16 ... 31
	//	16K 4 D E F
	[	"autostart/Wordpro.bin",		16*4,	],	// 16K
	[	"autostart/Wordpro.bin",		16*4+1,	],	// 16K
	[	"autostart/invaders.bin", 		17*4,	],	// 16K
	[	"autostart/invaders.bin", 		17*4+1,	],	// 16K

	//	bank 32 ... 63
	//	16K C D E F
	[	"vz/BUST OUT.vz",				32*4,	],	// 16K
	[	"vz/COS-RES.VZ", 				33*4,	],	// 16K
	[	"vz/CRASH.VZ",					34*4,	],	// 16K
	[	"vz/DAWN.VZ", 					35*4,	],	// 16K
	[	"vz/HOPPY.VZ",					36*4,	],	// 16K
	[	"vz/KAMIKAZE.VZ", 				37*4,	],	// 16K
	[	"vz/P-CURSE3.VZ",				38*4,	],	// 16K
	[	"vz/MONITORR.vz", 				39*4,	],	// 16K
	[	"vz/PUCK MAN.vz",				40*4,	],	// 16K
	[	"vz/Space_Ram.vz", 				41*4,	],	// 16K

	//	bank 64 80 100000H
	//  CEC-I 1.1
//	[	"CEC-I/MX231024-0059.bin",				64*4,	],	// 128K CEC-I 国标GB2312字库 16 x 16 点阵
//	[	"CEC-I/MX231024-0060.bin", 				72*4,	],	// 128K 
//	[	"CEC-I/U7.TMM24256AP.bin",				80*4,	],	// 32K
//	[	"CEC-I/U35.TMM24256AP.bin", 			82*4,	],	// 32K
//	[	"CEC-I/U13.9433C-0202.RCL-ZH-32.bin", 	84*4,	],	// 4K 字符点阵字模 8 x 8 点阵

	//	bank 96 112 180000H
	//  CEC-I 1.21
//	[	"CEC-I/MX231024-0059.bin",				96*4,	],	// 128K CEC-I 国标GB2312字库 16 x 16 点阵
//	[	"CEC-I/MX231024-0060.bin", 				104*4,	],	// 128K 
//	[	"CEC-I/u7.alt",							112*4,	],	// 32K
//	[	"CEC-I/u35.alt", 						114*4,	],	// 32K
//	[	"CEC-I/U13.9433C-0202.RCL-ZH-32.bin", 	116*4,	],	// 4K 字符点阵字模 8 x 8 点阵

	//	bank 128 144 200000H
	//  CEC-E
//	[	"CEC-E/u4.c3001.531000.bin",			128*4,	],	// 128K CEC-E 国标GB2312字库 16 x 16 点阵
//	[	"CEC-E/u7.c3002.531000.bin", 			136*4,	],	// 128K 
//	[	"CEC-E/u20.rom10.27256.bin", 			144*4,	],	// 32K
//	[	"CEC-E/u14.rom20.27256.bin",			146*4,	],	// 32K
//	[	"CEC-E/u13.9433c-0202.rcl-zh-32.bin", 	148*4,	],	// 4K 字符点阵字模 8 x 8 点阵

	//	bank 128 144 200000H
	//  CEC-M
//	[	"CEC-M/MX231024-0059.bin",				128*4,	],	// 128K CEC-I 国标GB2312字库 16 x 16 点阵
//	[	"CEC-M/MX231024-0060.bin", 				136*4,	],	// 128K 
//	[	"CEC-M/u8_st_27256fi_042f.bin",			144*4,	],	// 32K
//	[	"CEC-M/u35_st_27256fi_a53a.bin", 		146*4,	],	// 32K
//	[	"CEC-M/U13.9433C-0202.RCL-ZH-32.bin", 	148*4,	],	// 4K 字符点阵字模 8 x 8 点阵

	//	bank 160 176 280000H
	//	CEC-2000
//	[	"CEC-2000/u18.wl.lo.c3001.bin",			160*4,	],	// 128K CEC-2000 国标GB2312字库 16 x 16 点阵 内容同 CEC-E
//	[	"CEC-2000/u27.wl.hi.c3002.bin", 		168*4,	],	// 128K 
//	[	"CEC-2000/u34.rom1.27256.bin",			176*4,	],	// 32K
//	[	"CEC-2000/u41.rom2.27256.bin", 			178*4,	],	// 32K
//	[	"CEC-2000/u13.9433c-0202.rcl-zh-32.bin",180*4,	],	// 4K 字符点阵字模 8 x 8 点阵

	// bank 192 208 300000H

	// bank 224 240 380000H
	// test
//	[	"DOS.nib",								224*4,	],	// APPLE II  380000H
//	[	"LodeRunner.nib",						240*4,	],	// APPLE II  3C0000H
];


// 4MB = 4096KB = 256 * 4 * 4KB

// 512KB = 32 * 4 * 4KB


$bin_buf = str_repeat("\x00", 128*1024*16);
//echo strlen($bin_buf);
// 读文件

foreach($rom_lst as $item)
{
	$fn = $item[0];
	$pos = $item[1]*4*1024;

	//echo "in : $fn\n";

	$rom_buf = file_get_contents($fn);
	if($rom_buf===FALSE) exit;
	$rom_len = strlen($rom_buf);

	// 如果后缀是 .vz 需要再开头写入文件长度
	$file_basename = basename($fn);

	$fn_b = basename($fn,".vz");
	if($fn_b != basename($fn))
		$file_basename = $fn_b;

	$fn_b = basename($fn,".VZ");
	if($fn_b != basename($fn))
		$file_basename = $fn_b;


	echo "in : $fn  pos $pos  len $rom_len\n";

	$off=0;

	if( $file_basename != basename($fn) ) {
		echo "VZF fomat $fn\n";
		$bin_buf{$pos+0} = chr($rom_len&0xFF);
		$bin_buf{$pos+1} = chr(($rom_len>>8)&0xFF);
		$off=2;
	}

	for($i=0;$i<$rom_len;$i++) {
		$bin_buf{$i+$off+$pos} = $rom_buf{$i};
	}

	//$n = $pos+2;
	//printf( "%08X %02X", $n, ord($bin_buf{$n}) );
}

echo "out : $file_name\n";

//$n = 0x40002;
//printf( "%08X %02X", $n, ord($bin_buf{$n}) );

file_put_contents($file_name,$bin_buf);

// 生成 intel hex 文件格式

echo "out : $hex_file_name\n";

//file_put_contents($hex_file_name,bin2ihex($bin_buf));
file_put_contents($hex_file_name,bin2asciihex($bin_buf));

