<?php
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


$vzf_name  = strval($argv[1]);
//$file_name  = strval($argv[2]);

echo "read $vzf_name\n";

// 读文件
$vzf_buf = file_get_contents($vzf_name);
if($vzf_buf===FALSE) exit;

$vzf = vzf_parse($vzf_buf);

if(is_string($vzf)) {
	echo $vzf;
	exit;
}

$fn = $vzf_name;
$file_basename = trim(basename_ext($fn,[".vz","VZ"]));

$file_name = sprintf("%s.%02X.%04X.bin",$file_basename,$vzf["vzf_type"],$vzf["vzf_startaddr"]);

echo "$vzf_name to $file_name\n";
echo "cass name ".$vzf["vzf_filename"]."\n";
printf("start address %04X  end address %04X  len %04X(%d)", $vzf["vzf_startaddr"], $vzf["vzf_endaddr"], $vzf["vzf_datalen"], $vzf["vzf_datalen"]);

file_put_contents($file_name, $vzf["vzf_data"]);

