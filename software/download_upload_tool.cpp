#include "UART.h"

// 在 UART.cpp 中 #define BUF_SIZE        512
// 在 UART.cpp 有 bug :
// memcpy(data, readBuf, readCnt);
// memcpy(data+num-remainCnt, readBuf, readCnt);

//9600 19200 38400 57600 115200
#define BAUDRATE 57600

int getCOMx(char*s)
{
	if( strlen(s)!=4 ) return 0;
	if( !(s[0]=='C'||s[0]=='c') ) return 0;
	if( !(s[1]=='O'||s[1]=='o') ) return 0;
	if( !(s[2]=='M'||s[2]=='m') ) return 0;
	if( !(s[3]>='1'||s[3]<='9') ) return 0;
	return s[3]-'0';
}

size_t filelen(FILE *fp)
{
	size_t	curpos, pos;

	if( (curpos = ftello(fp))==-1LL )
		return -1LL;

	if( fseeko( fp, 0LL, SEEK_END ) )
		return -1LL;

	if( (pos = ftello(fp))==-1LL )
		return -1LL;

	if( fseeko( fp, curpos, SEEK_SET ) )
		return -1LL;

	return pos;
}

/* 每次读取 1G */
#define FREAD_LEN 0x40000000LL

size_t readfile(const char* fn, uint8_t* uart_buf)
{
	FILE	*fp;
	size_t	sz;

	//printf("fopen\n");
	if( ( fp = fopen(fn, "rb") ) == NULL ) return 0;

	//printf("filelen\n");
	sz = filelen(fp);
	if( sz<=0 ) { fclose(fp); return 0; }

	/* 实测，win64 mingw环境下，fread 一次读取不能超过 2G (包括2G) */

	/* 每次读取 1G */
	size_t	read_c=0LL;
	size_t	read_sz;

	while(read_c<sz) {
		read_sz = (read_c+FREAD_LEN<=sz) ? FREAD_LEN : sz-read_c;
		//printf("fread %d %d %d\n", sz, read_c, read_sz);
		if( fread( (char*)uart_buf+read_c, read_sz, 1, fp ) != 1LL ) { fclose(fp); return 0; }
		read_c+=read_sz;
	}

	fclose(fp);

	return read_c;
}


/* 每次写入 1G */
#define FWRITE_LEN 0x40000000LL

size_t writefile(const char* fn, uint8_t* uart_buf, size_t sz)
{
	FILE	*fp;

	//printf("fopen\n");
	if( ( fp = fopen(fn, "wb") ) == NULL ) return 0;

	/* 实测，win64 mingw环境下，fread 一次读取不能超过 2G (包括2G) */

	/* 每次写入 1G */
	size_t	write_c=0LL;
	size_t	write_sz;

	while(write_c<sz) {
		write_sz = (write_c+FWRITE_LEN<=sz) ? FREAD_LEN : sz-write_c;
		//printf("fread %d %d %d\n", sz, read_c, read_sz);
		if( fwrite( (char*)uart_buf+write_c, write_sz, 1, fp ) != 1LL ) { fclose(fp); return 0; }
		write_c+=write_sz;
	}

	fclose(fp);

	return write_c;
}


inline void U_SYNC()
{
	uint8_t			data[8];
	const	int		dataLen = 1;

	uint8_t			rcvData[8];

	// sync
	for(int i=0;i<3;i++) {
		data[0] = 0x00;
		UART_SetData(data, dataLen);
	}

	for(int i=0;i<3;i++)
		UART_GetData(rcvData, 1);
}


inline uint8_t CHK_N_ADDR_CNT(uint32_t addr, uint8_t dat_len)
{
	uint8_t			data[8];

	data[0] = addr&0xff;
	data[1] = (addr>>8)&0xff;
	data[2] = (addr>>16)&0xff;
	data[3] = dat_len&0xff;
	// CHK
	return (uint8_t)0xAA^data[0]^data[1]^data[2]^data[3];
}


inline uint8_t U_CMD_ADDR_CNT(uint8_t cmd, uint32_t addr, uint8_t dat_len)
{
	uint8_t			data[8];
	const	int		dataLen = 6;

	uint8_t			rcvData[8];

	data[0] = cmd;
	data[1] = addr&0xff;
	data[2] = (addr>>8)&0xff;
	data[3] = (addr>>16)&0xff;
	data[4] = dat_len&0xff;
	data[5] = CHK_N_ADDR_CNT(addr, dat_len);

	UART_SetData(data, dataLen);

	rcvData[0] = 0;
	while(!UART_GetData(rcvData, 1));
//		printf("%s\n", UART_GetLastErrMsg());

	return rcvData[0];
}


inline uint32_t U_GET_ADDR_CNT()
{
	uint8_t			data[8];
	const	int		dataLen = 1;

	uint8_t			rcvData[8];
	uint8_t			pkg_chk;

	uint32_t r;


	data[0] = 0x05;
	UART_SetData(data, dataLen);

	//	读入 addr cnt chk
	rcvData[0] = 0;
	while(!UART_GetData(rcvData, 4+1))
		printf("%s\n", UART_GetLastErrMsg());

	r = 0;
	r += rcvData[0];
	r += (rcvData[1]<<8);
	r += (rcvData[2]<<16);
	r += (rcvData[3]<<24);

	pkg_chk = (uint8_t)0xAA^rcvData[0]^rcvData[1]^rcvData[2]^rcvData[3];

	if(pkg_chk!=rcvData[4]) {
#ifdef	DBG
		printf("recv addr cnt err %02X %02X %02X %02X %02X\n", rcvData[0], rcvData[1], rcvData[2], rcvData[3], rcvData[4]);
#endif
		r = 0xFFFFFFFF;
	}

	return r;
}


int uart_upload (const char *fn, int uart_com_no)
{
	uint8_t		uart_buf[1024*512];
	uint32_t	uart_len;
	uint32_t	send_len;

	//uint8_t		buf[1024*512];

	uart_len		=	readfile(fn,uart_buf);
	if(!uart_buf) {
#ifdef	DBG
		printf("file read err %d", uart_buf);
#endif
		return 1;
	}

	printf("uart_upload len %d\n", uart_len);

	uint8_t		data[256];
	uint8_t		data_chk;

	uint8_t		rcvData[512];

	send_len	=	uart_len;

	//9600 19200 38400 57600 115200
	if( !UART_Open(uart_com_no, BAUDRATE, NOPARITY, ONESTOPBIT) )
		return 3;


	U_SYNC();

	UART_ClearBuf();

//	for(int i=0;i<3;i++)
//		UART_GetData(rcvData, 1);

//
	int err=0;
	uint32_t	Addr = 0x0000;
	uint16_t	pkg_len;
	uint8_t		pkg_chk;

	//for(int i=0;i<send_len;i++) {

	int	i=0;
	while(i<send_len) {
		if(send_len-i>=256)
			pkg_len = 256;
		else
			pkg_len = send_len-i;

#ifdef	DBG
		printf("send(%08X) len %02X\n", Addr, pkg_len);
#endif

		err = U_CMD_ADDR_CNT(0x02, Addr, pkg_len);

		if(err!=0) {
#ifdef	DBG
			printf("send setup err %d\n", err);
#endif
			break;
		}

		pkg_chk = CHK_N_ADDR_CNT(Addr, pkg_len);

		for(int j=0;j<pkg_len;j++) {
			data[j] = uart_buf[i+j];
			pkg_chk ^= uart_buf[i+j];
		}

		//for(int c=0;c<pkg_len;c++)	printf("send %i: %02X\n", c, data[c]);
		while(!UART_SetData(data, pkg_len))
			printf("%s\n", UART_GetLastErrMsg());

		rcvData[0] = 0;
		while(!UART_GetData(rcvData, 1));
		//printf("recv write echo %02X\n", rcvData[0]);

		if(rcvData[0]!=pkg_chk) {
#ifdef	DBG
			printf("send(%04X) err write echo %02X\n", Addr, rcvData[0]);
#endif
			err=1;
			break;
		}

		Addr += pkg_len;

		i += pkg_len;
	}

	UART_Close();

	if(err)
		return 4;

    return 0;
}


// 参数 40 * 2464 = 98560

int uart_download (const char *fn, int uart_com_no)
{
	uint8_t		uart_buf[1024*512];
	uint32_t	uart_len;
	uint32_t	rcv_len;

	uint8_t		rcvData[512];

	uart_len		=	40 * 2464;
	rcv_len		=	uart_len;

	printf("uart_download len %d\n", uart_len);

	//9600 19200 38400 57600 115200
	if( !UART_Open(uart_com_no, BAUDRATE, NOPARITY, ONESTOPBIT) )
		return 3;

	U_SYNC();

	UART_ClearBuf();

//	for(int i=0;i<3;i++)
//		UART_GetData(rcvData, 1);

//
	int			err		=	0;
	uint32_t	Addr	=	0;
	uint16_t	pkg_len;
	uint8_t		pkg_chk;

	int	i=0;
	while(i<rcv_len) {
		if(rcv_len-i>=256)
			pkg_len = 256;
		else
			pkg_len = rcv_len-i;

#ifdef	DBG
		printf("recv(%08X) len %02X\n", Addr, pkg_len);
#endif

		err = U_CMD_ADDR_CNT(0x01, Addr, pkg_len);
		if(err!=0) {
#ifdef	DBG
			printf("send setup err %d\n", err);
#endif
			break;
		}

		pkg_chk = CHK_N_ADDR_CNT(Addr, pkg_len);

		//	读入数据
		rcvData[0] = 0;
		while(!UART_GetData(rcvData, pkg_len+1))
			printf("recv data err %02X\n", rcvData[pkg_len]);

		for(int j=0;j<pkg_len;j++) {
#ifdef	DBG
			//printf("%02X:%02X ", j, rcvData[j]);
#endif
			uart_buf[i+j] = rcvData[j];
			pkg_chk ^= rcvData[j];
		}

		if(rcvData[pkg_len]!=pkg_chk) {
#ifdef	DBG
			printf("recv(%08X) err read echo %02X\n", Addr, rcvData[pkg_len]);
#endif
			err=1;
			break;
		}

		Addr += pkg_len;

		i += pkg_len;
	}

	UART_Close();

	if(err)
		return 4;

	writefile(fn, uart_buf, uart_len);

    return 0;
}


uint32_t uart_read_addr_cnt(int uart_com_no)
{
	//9600 19200 38400 57600 115200
	if( !UART_Open(uart_com_no, BAUDRATE, NOPARITY, ONESTOPBIT) )
		return 3;

	U_SYNC();

	UART_ClearBuf();

	uint32_t	r		=	0;

	//	读入 addr cnt
	r = U_GET_ADDR_CNT();

/*
	if(r==0XFFFFFFFF) {
#ifdef	DBG
		printf("read addr cnt err %08X\n", r);
#endif
	}
*/

	UART_Close();

    return r;
}

