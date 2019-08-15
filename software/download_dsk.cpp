// g++ -std=c++17 -o download_dsk download_dsk.cpp UART.cpp -mconsole -DMINGW_HAS_SECURE_API -D_FILE_OFFSET_BITS=64 -IC:/MinGW/include
#include <cstdint>

#include <cstdio>
#include <cstdlib>
#include <cstring>

#define DBG
#include "download_upload_tool.cpp"

int main (int argc, char *argv []) {

    //char *port = malloc (sizeof (char) * 12); // Just for "straight to test purposes", in production, use the port detection functions instead
    //strcpy(port, "\\\\.\\COM3");

//------------------------------------ Stand-alone function to do their straight work the most synchronous way ------------------------------------

//    AVAILABLE_PORTS *ports;                         // Initializing the struct values
//    ports = malloc(sizeof(AVAILABLE_PORTS));
//    updateAvailablePortsInfo(ports);                // Setup/load time, the function will update the living struct

	int	uart_com_no = 0;

    if(argc<3) {
		fprintf(stderr, "usage: download_dsk COMx filename.dsk\n");
		return 1;
	}

	uart_com_no = getCOMx(argv[1]);
	if(uart_com_no==0) { printf("COMx err %d", uart_com_no); return 1; }

	int err = uart_download (argv[2], uart_com_no);

	if(!err)
		printf("downloaded completed");

    return err?1:0;
}
