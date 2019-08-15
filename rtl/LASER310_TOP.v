`timescale 1 ns / 1 ns

// 为降低开发难度，暂时选用 DE2 DE1 作为开发平台。
//  ROM 放在 FLASH 上，取消磁带输入模拟。内存放在 SRAM 上，使用 64K 空间，无IO和扩展空间。


// 使用FPGA外部 SRAM 芯片，数据口同时完成输入输出。一定要仔细调整时序，防止两个输出撞车。

// 设计中，sys_rom 和 2K RAM 作为基础系统，保证系统最低需求。
// 即使 flash 不能成功写入，也不影响系统运行。
// sys_rom_altera sys_rom(); ram_2k_altera sys_ram_2k();


// DE1 512K SRAM (256K*16bit) IS61LV25616
// DE2 512K SRAM (256K*16bit) IS61LV25616
// DE2-70 2M SSRAM (512K*32bit)
// DE2-115 2M SRAM (1M*16bit) IS61WV102416

// DE1 DE2 FLASH 4M
// DE0 DE2-70 DE2-115 FLASH 8M

// 选择开发板
//`define	DE1
//`define	DE2

// 选择 Z80 软核
`define	TV80

// 扩展绘图模式支持
`define SHRG


// 内存有三种配置方案：1、通过 FPGA 片上内存支持 16K  2、通过 FPGA 片上内存支持 16K 和 16K 扩展内存  3、通过 SRAM 或 SSRAM 支持 256K 扩展内存

`ifdef DE1

`define FPGA_ALTERA
`define FPGA_ALTERA_C2
`define CLOCK_27MHZ
`define AUDIO_WM8731
`define FLASH_CHIP
`define FLASH_CHIP_4M
`define VGA_RESISTOR
`define VGA_BIT12
`define UART_CHIP

`define RAM_ON_SRAM_CHIP
`define SRAM_CHIP_256x16
`define GPIO_PIN
`define VRAM_8K

`endif



`ifdef DE2

`define FPGA_ALTERA
`define FPGA_ALTERA_C2
`define CLOCK_27MHZ
`define AUDIO_WM8731
`define FLASH_CHIP
`define FLASH_CHIP_4M
`define VGA_ADV7123
`define VGA_BIT30
`define UART_CHIP

`define RAM_ON_SRAM_CHIP
`define SRAM_CHIP_256x16
`define VRAM_8K


`endif

module LASER310_TOP(
	CLK50MHZ,

`ifdef CLOCK_27MHZ
	CLK27MHZ,
`endif

`ifdef RAM_ON_SRAM_CHIP
	// Altera DE1 512K SRAM
	RAM_DATA,			// 16 bit data bus to RAM
	RAM_ADDRESS,		// Common address
	RAM_WE_N,			// Common RW
	RAM_OE_N,
	RAM_CS_N,			// Chip Select for RAM
	RAM_BE0_N,			// Byte Enable for RAM
	RAM_BE1_N,			// Byte Enable for RAM
`endif


	// Altera DE1 4MB FLASH
	// Altera DE2 4MB FLASH

	// Altera DE0 8MB FLASH
	// Altera DE2-70 8MB FLASH
	// Altera DE2-115 8MB FLASH
`ifdef FLASH_CHIP
	FL_ADDRESS,
	FL_DATA,
	FL_CE_N,
	FL_OE_N,
	FL_WE_N,
	FL_RESET_N,

`ifdef	DE0
	FL_BYTE_N,
	FL_RY,
	FL_WP_N,
	//FL_DQ15,
`endif

`ifdef	DE1
	//FL_BYTE_N,
	//FL_RY,
	//FL_WP_N,
	//FL_DQ15,
`endif

`ifdef	DE2
	//FL_BYTE_N,
	//FL_RY,
	//FL_WP_N,
	//FL_DQ15,
`endif

`ifdef	DE2_70
	FL_BYTE_N,
	FL_RY,
	FL_WP_N,
	//FL_DQ15,
`endif

`ifdef	DE2_115
	//FL_BYTE_N,
	FL_RY,
	FL_WP_N,
	//FL_DQ15,
`endif

`endif

	// VGA
`ifdef VGA_RESISTOR
	VGA_RED,
	VGA_GREEN,
	VGA_BLUE,
	VGA_HS,
	VGA_VS,
`endif

`ifdef VGA_ADV7123
	VGA_DAC_RED,
	VGA_DAC_GREEN,
	VGA_DAC_BLUE,
	VGA_HS,
	VGA_VS,
	VGA_DAC_BLANK_N,
	VGA_DAC_SYNC_N,
	VGA_DAC_CLOCK,
`endif

	// PS/2
	PS2_KBCLK,
	PS2_KBDAT,
	//Serial Ports
	//TXD1,
	//RXD1,
	// Display
	//DIGIT_N,
	//SEGMENT_N,
	// LEDs
	LED,
`ifdef GPIO_PIN
	LEDG,
`endif
	// Apple Perpherial
	//SPEAKER,
	//PADDLE,
	//P_SWITCH,
	//DTOA_CODE,
	// Extra Buttons and Switches
	SWITCH,

`ifdef AUDIO_WM8731
	////////////////	Audio CODEC		////////////////////////
	AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
	AUD_ADCDAT,						//	Audio CODEC ADC Data
	AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
	AUD_DACDAT,						//	Audio CODEC DAC Data
	AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
	AUD_XCK,						//	Audio CODEC Chip Clock

	////////////////////	I2C		////////////////////////////
	I2C_SDAT,						//	I2C Data
	I2C_SCLK,						//	I2C Clock

`endif

`ifdef GPIO_PIN
	////////////////////	GPIO	////////////////////////////
	//GPIO_0,							//	GPIO Connection 0
	//GPIO_1,							//	GPIO Connection 1
`endif

`ifdef UART_CHIP_EXT
	UART_RTS,
	UART_CTS,
`endif

`ifdef UART_CHIP
	UART_RXD,
	UART_TXD,
`endif

`ifdef	DE1
	////////////////////	7-SEG Dispaly	////////////////////
	HEX0_D,							//	Seven Segment Digit 0
	HEX1_D,							//	Seven Segment Digit 1
	HEX2_D,							//	Seven Segment Digit 2
	HEX3_D,							//	Seven Segment Digit 3
`endif

`ifdef	DE2
	////////////////////	7-SEG Dispaly	////////////////////
	HEX0_D,							//	Seven Segment Digit 0
	HEX1_D,							//	Seven Segment Digit 1
	HEX2_D,							//	Seven Segment Digit 2
	HEX3_D,							//	Seven Segment Digit 3
	HEX4_D,							//	Seven Segment Digit 4
	HEX5_D,							//	Seven Segment Digit 5
	HEX6_D,							//	Seven Segment Digit 6
	HEX7_D,							//	Seven Segment Digit 7
`endif

	// de0
	// de1
	BUTTON_N
);


input				CLK50MHZ;

`ifdef CLOCK_27MHZ
input				CLK27MHZ;
`endif


`ifdef	RAM_ON_SRAM_CHIP

`ifdef SRAM_CHIP_256x16

// Altera DE1 512K SRAM
// Altera DE2 512K SRAM
inout	wire	[15:0]	RAM_DATA;			// 16 bit data bus to RAM
output	wire	[17:0]	RAM_ADDRESS;		// Common address
output	reg				RAM_WE_N;			// Common RW
output	reg				RAM_OE_N;

output	reg				RAM_CS_N;			// Chip Select for RAM
output	reg				RAM_BE0_N;			// Byte Enable for RAM
output	reg				RAM_BE1_N;			// Byte Enable for RAM

reg		[15:0]			RAM_DATA_W;

`endif


`endif


`ifdef FLASH_CHIP

// Altera DE1 4MB FLASH
`ifdef FLASH_CHIP_4M
output	[21:0]	FL_ADDRESS;
`endif

// Altera DE2-70 8MB FLASH
`ifdef FLASH_CHIP_8M
output	[22:0]	FL_ADDRESS;
`endif

//input	[15:0]	FL_DATA;
input	[7:0]	FL_DATA;
output	FL_CE_N;
output	FL_OE_N;
output	FL_WE_N;
output	FL_RESET_N;

`ifdef DE0
output		FL_BYTE_N;
input		FL_RY;
output		FL_WP_N;
//output	FL_DQ15;
`endif

`ifdef DE1
//output	FL_BYTE_N;
//input		FL_RY;
//output	FL_WP_N;
//output	FL_DQ15;
`endif

`ifdef DE2
//output	FL_BYTE_N;
//input		FL_RY;
//output	FL_WP_N;
//output	FL_DQ15;
`endif

`ifdef DE2_70
output		FL_BYTE_N;
input		FL_RY;
output		FL_WP_N;
//output	FL_DQ15;
`endif

`ifdef DE2_115
//output	FL_BYTE_N;
input		FL_RY;
output		FL_WP_N;
//output	FL_DQ15;
`endif

`endif



`ifdef VGA_RESISTOR
// de0 de1
`ifdef VGA_BIT12
output	wire	[3:0]	VGA_RED;
output	wire	[3:0]	VGA_GREEN;
output	wire	[3:0]	VGA_BLUE;
`endif

output	wire			VGA_HS;
output	wire			VGA_VS;
`endif


`ifdef VGA_ADV7123
// de2
`ifdef VGA_BIT30
output	wire	[9:0]	VGA_DAC_RED;
output	wire	[9:0]	VGA_DAC_GREEN;
output	wire	[9:0]	VGA_DAC_BLUE;
`endif

`ifdef VGA_BIT24
output	wire	[7:0]	VGA_DAC_RED;
output	wire	[7:0]	VGA_DAC_GREEN;
output	wire	[7:0]	VGA_DAC_BLUE;
`endif

output	reg				VGA_HS;
output	reg				VGA_VS;
output	wire			VGA_DAC_BLANK_N;
output	wire			VGA_DAC_SYNC_N;
output	wire			VGA_DAC_CLOCK;
`endif


// PS/2
input 			PS2_KBCLK;
input			PS2_KBDAT;

// LEDs
output	wire	[9:0]	LED;

`ifdef GPIO_PIN
output	wire	[7:0]	LEDG;
`endif

// Extra Buttons and Switches

//input	[3:0]		SWITCH;
input	[9:0]		SWITCH;


`ifdef	DE1
//input	[9:0]		SWITCH;
`endif

`ifdef	DE2
//input	[17:0]		SWITCH;
`endif


`ifdef AUDIO_WM8731

////////////////////	Audio CODEC		////////////////////////////
// ADC
inout			AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
input			AUD_ADCDAT;				//	Audio CODEC ADC Data

// DAC
inout			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
output	wire	AUD_DACDAT;				//	Audio CODEC DAC Data

inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
output	wire	AUD_XCK;				//	Audio CODEC Chip Clock

////////////////////////	I2C		////////////////////////////////
inout			I2C_SDAT;				//	I2C Data
output			I2C_SCLK;				//	I2C Clock

`endif


`ifdef UART_CHIP
input		UART_RXD;
output		UART_TXD;
`endif

`ifdef UART_CHIP_EXT
output		UART_CTS = 1'bz;
input		UART_RTS;
`endif

// DE1

`ifdef	DE1
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 2
output	[6:0]	HEX3_D;					//	Seven Segment Digit 3
`endif

// DE2

// DE系列开发板
//  0
// 5 1
//  6
// 4 2
//  3

`ifdef	DE2
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 2
output	[6:0]	HEX3_D;					//	Seven Segment Digit 3
output	[6:0]	HEX4_D;					//	Seven Segment Digit 4
output	[6:0]	HEX5_D;					//	Seven Segment Digit 5
output	[6:0]	HEX6_D;					//	Seven Segment Digit 6
output	[6:0]	HEX7_D;					//	Seven Segment Digit 7
`endif


// DE1 DE2
input	[3:0]		BUTTON_N;
wire	[3:0]		BUTTON;

`ifdef SKIP_BTN
assign	BUTTON		=	4'b0000;
`else
assign BUTTON		=	~BUTTON_N;
`endif


`ifdef GPIO_PIN
////////////////////////	GPIO	////////////////////////////////
//output	[35:0]	GPIO_0;		//	GPIO Connection 0
//output	[35:0]	GPIO_1;		//	GPIO Connection 1
`endif


/*
reg					CLK25MHZ;
always @(posedge CLK50MHZ)
	CLK25MHZ	<=	~CLK25MHZ;
*/

// 10MHz 的频率用于模块计数， 包括产生 50HZ 的中断信号的时钟，uart 模块的时钟，模拟磁带模块的时钟
// 选择 10MHz 是因为 Cyclone II 的DLL 分频最多能到 5。最初打算用 1MHz。
wire				CLK10MHZ;
CLK10MHZ_PLL CLK10MHZ_PLL_INST(
	CLK50MHZ,
	CLK10MHZ);


// DLY_CLK 主要用于延时使用
reg		[5:0]		DLY_CLK_CNT;
reg					DLY_CLK;

`ifdef SIMULATE
initial
	begin
		DLY_CLK_CNT	=	6'b0;
	end
`endif


always @ (posedge CLK10MHZ)
begin
	DLY_CLK			<=	DLY_CLK_CNT[5];
	DLY_CLK_CNT		<=	DLY_CLK_CNT + 1;		//	10/64 = 0.15625 MHz
end



// CLOCK & BUS
(*keep*)wire				BASE_CLK = CLK50MHZ;

reg		[3:0]		CLK_CNT;




// Processor
(*keep*)reg				CPU_CLK;
(*keep*)wire	[15:0]	CPU_A;
(*keep*)wire	[7:0]	CPU_DI;
(*keep*)wire	[7:0]	CPU_DO;
(*keep*)wire	[7:0]	CPU_D_INPORT;

(*keep*)wire			CPU_RESET;
(*keep*)wire			CPU_HALT;
(*keep*)wire			CPU_WAIT;

(*keep*)wire			CPU_MREQ;
(*keep*)wire			CPU_RD;
(*keep*)wire			CPU_WR;
(*keep*)wire			CPU_IORQ;

(*keep*)reg				CPU_INT;
(*keep*)wire			CPU_NMI;
(*keep*)wire			CPU_M1;


wire					CPU_BUSRQ;
wire					CPU_BUSAK;

wire					CPU_RFSH;

`ifdef	TV80

(*keep*)wire			CPU_RESET_N;
(*keep*)wire			CPU_HALT_N;
(*keep*)wire			CPU_WAIT_N;

(*keep*)wire			CPU_MREQ_N;
(*keep*)wire			CPU_RD_N;
(*keep*)wire			CPU_WR_N;
(*keep*)wire			CPU_IORQ_N;

(*keep*)wire			CPU_INT_N;
(*keep*)wire			CPU_NMI_N;
(*keep*)wire			CPU_M1_N;

wire					CPU_BUSRQ_N;
wire					CPU_BUSAK_N;

wire					CPU_RFSH_N;

`endif

// VRAM
(*keep*)wire	[12:0]	VRAM_ADDRESS;
(*keep*)wire			VRAM_WR;
(*keep*)wire	[7:0]	VRAM_DATA_OUT;

(*keep*)wire			VDG_RD;
(*keep*)wire	[12:0]	VDG_ADDRESS;
(*keep*)wire	[7:0]	VDG_DATA;

reg						VRAM_WR_N;

// RAM
reg					RAM_RDY_UART;

reg			[17:0]	RAM_ADDR;

//wire RAM_BE0_N_VID;
wire RAM_BE0_N_UART;
wire RAM_BE0_N_FD;
wire RAM_BE0_N_CPU;

//wire RAM_BE1_N_VID;
wire RAM_BE1_N_UART;
wire RAM_BE1_N_FD;
wire RAM_BE1_N_CPU;

//wire RAM_CS_N_VID;
wire RAM_CS_N_UART;
wire RAM_CS_N_FD;
wire RAM_CS_N_CPU;

//wire	[17:0]	RAM_ADDRESS_VID;
wire	[17:0]	RAM_ADDRESS_UART;
wire	[17:0]	RAM_ADDRESS_FD_R;
wire	[17:0]	RAM_ADDRESS_FD_W;
wire	[17:0]	RAM_ADDRESS_CPU;

// bus
wire	[7:0]		SYS_ROM_DATA;
wire	[7:0]		DOS_ROM_DATA;


wire	[7:0]		RAM_DATA_OUT_64K;
wire	[7:0]		RAM_DATA_OUT_FDC;


wire				ADDRESS_ROM;
wire				ADDRESS_DOSROM;
wire				ADDRESS_IO;
wire				ADDRESS_VRAM;

wire				ADDRESS_89AB;
wire				ADDRESS_CDEF;

wire				ADDRESS_RAM_78;

wire				ADDRESS_IO_SHRG;
wire				ADDRESS_IO_BANK;

wire				ADDRESS_RAM_CHIP;

wire				ADDRESS_IO_FDC;
wire				ADDRESS_IO_FDC_CT;
wire				ADDRESS_IO_FDC_DATA;
wire				ADDRESS_IO_FDC_POLL;
wire				ADDRESS_IO_FDC_WP;

/*
74LS174输出的各个控制信号是：
Q5 蜂鸣器B端电平
Q4 IC15（6847）第39脚的CSS信号（控制显示基色）
Q3 IC15（6847）第35脚的~A/G信号（控制显示模式）
Q2 磁带记录信号电平
Q1 未用
Q0 蜂鸣器A端电平
*/

reg		[7:0]		LATCHED_IO_DATA_WR;
//reg	[7:0]		LATCHED_IO_DATA_RD;

reg		[7:0]		LATCHED_BANK_0000;
reg		[7:0]		LATCHED_BANK_4000;
reg		[7:0]		LATCHED_BANK_C000;

// 用于大于 4M 的 FLASH 区间切换
reg					LATCHED_FLASH_BANK_SW;

reg					LATCHED_DOSROM_EN;

`ifdef SHRG
reg					LATCHED_SHRG_EN;
reg		[7:0]		LATCHED_IO_SHRG;
`endif

// FLOPPY
reg		[7:0]		LATCHED_IO_FDC;
reg		[7:0]		LATCHED_IO_FDC_CT;

reg		[7:0]		LATCHED_RAM_DATA_FDC;


// VGA
wire	[7:0]		VGA_OUT_RED;
wire	[7:0]		VGA_OUT_GREEN;
wire	[7:0]		VGA_OUT_BLUE;

wire				VGA_OUT_HS;
wire				VGA_OUT_VS;

wire				VGA_OUT_BLANK;

`ifdef CLOCK_50MHZ
reg					VGA_CLK;
`else
// 通过 PLL 生成
wire				VGA_CLK;
`endif


// keyboard
reg		[4:0]		KB_CLK_CNT;
reg					KB_CLK;

wire	[7:0]		KEY_DATA;
wire				KEY_PRESSED;

reg		[7:0]		LATCHED_KEY_DATA;


// speaker
(*keep*)wire		SPEAKER_A = LATCHED_IO_DATA_WR[0];
(*keep*)wire		SPEAKER_B = LATCHED_IO_DATA_WR[5];


// cassette
(*keep*)wire	[1:0]	CASS_OUT;
(*keep*)wire			CASS_IN;
(*keep*)wire			CASS_IN_L;
(*keep*)wire			CASS_IN_R;

// floppy
(*keep*)wire					FDC_RAM_R;
(*keep*)wire					FDC_RAM_W;
(*keep*)wire		[17:0]		FDC_RAM_ADDR_R;
(*keep*)wire		[17:0]		FDC_RAM_ADDR_W;
reg			[7:0]		LAST_WRITE_DATA;
(*keep*)wire		[7:0]		FDC_RAM_DATA_W;

(*keep*)wire	[7:0]		FLOPPY_RD_DATA;
(*keep*)wire	[7:0]		FLOPPY_DATA;

// uart
wire		[23:0]	UART_BUF_A;
wire				UART_BUF_WR;
wire		[7:0]	UART_BUF_DAT;

// other
wire				SYS_RESET_N;
(*keep*)wire		RESET_N;
wire				RESET_AHEAD_N;

wire				RESET_KEY_N;

wire				TURBO_SPEED		=	SWITCH[0];

`ifdef GPIO_PIN
wire				GPIO_SW			=	1'b1;
wire	[7:0]		GPIO_IN;
`else
wire				GPIO_SW			=	1'b0;
`endif


//	All inout port turn to tri-state
//assign	DRAM_DQ		=	16'hzzzz;
//assign	FL_DQ		=	8'hzz;
//assign	SRAM_DQ		=	16'hzzzz;
//assign	SD_DAT		=	1'bz;
assign	I2C_SDAT	=	1'bz;
assign	AUD_ADCLRCK	=	1'bz;
assign	AUD_DACLRCK	=	1'bz;
assign	AUD_BCLK	=	1'bz;


// reset

assign SYS_RESET_N = !BUTTON[0];

RESET_DE RESET_DE(
	.CLK(CLK50MHZ),			// 50MHz
	.SYS_RESET_N(SYS_RESET_N && RESET_KEY_N),
	.RESET_N(RESET_N),		// 50MHz/32/65536
	.RESET_AHEAD_N(RESET_AHEAD_N)	// 提前恢复，可以接 FL_RESET_N
);



`ifdef SIMULATE
initial
	begin
		VGA_CLK = 1'b0;
	end
`endif

`ifdef CLOCK_50MHZ

always @(negedge CLK50MHZ)
	VGA_CLK <= !VGA_CLK;

`endif


`ifdef CLOCK_27MHZ

VGA_Audio_PLL  VGA_AUDIO_PLL(.inclk0(CLK27MHZ),.c0(VGA_CLK),.c1(AUD_CTRL_CLK));

`endif


// 频率 50HZ
// 回扫周期暂定为：2线 x 800点 x 10MHZ / 25MHZ

// ~FS 垂直同步信号，送往IC1、IC2称IC4。6847对CPU的唯一直接影响，便是它的~FS输出被作为Z80A的~INT控制信号；
// 每一场扫描结束，6847的~FS信号变低，便向Z80A发出中断请求。在PAL制中，场频为50Hz，每秒就有50次中断请求，以便系统程序利用场消隐期运行监控程序，访问显示RAM。

// 在加速模式中，要考虑对该计数器的影响

// 系统中断：简化处理是直接接到 VGA 的垂直回扫信号，频率60HZ。带来的问题是软件计时器会产生偏差。

reg 		[17:0]	INT_CNT;

always @ (negedge CLK10MHZ)
	case(INT_CNT[17:0])
		18'd0:
		begin
			CPU_INT <= 1'b1;
			INT_CNT <= 18'd1;
		end
		18'd640:
		begin
			CPU_INT <= 1'b0;
			INT_CNT <= 18'd641;
		end
		18'd199999:
		begin
			INT_CNT <= 18'd0;
		end
		default:
		begin
			INT_CNT <= INT_CNT + 1;
		end
	endcase

// CPU clock

// 17.7MHz/5 = 3.54MHz
// LASER310 CPU：Z-80A/3.54MHz
// VZ300 CPU：Z-80A/3.54MHz

// 高速模式 50MHZ / 4  = 12.5MHz  ( TURBO_SPEED )
// 正常速度 50MHZ / 14 = 3.57MHz

// 同步内存操作
// 写 0 CPU 写信号和地址 1 锁存写和地址 2 完成写操作
// 读 0 CPU 读信号和地址 1 锁存读和地址 2 完读写操作，开始输出数据

// 读取需要中间间隔一个时钟


`ifdef SIMULATE
initial
	begin
		CLK_CNT = 4'b0;
	end
`endif

always @(posedge BASE_CLK or negedge RESET_N)
	if(~RESET_N)
	begin
		CPU_CLK					<=	1'b0;

		// 复位期间设置，避免拨动开关引起错误
		//LATCHED_DOSROM_EN		<=	SWITCH[1];
		LATCHED_DOSROM_EN		<=	1'b1;

		LATCHED_BANK_0000		<=	{8'b0};
		LATCHED_BANK_4000		<=	{8'b0};

		//LATCHED_BANK_0000		<=	{5'b0,SWITCH[6:4]};
		//LATCHED_BANK_4000		<=	{5'b0,SWITCH[9:7]};
		LATCHED_BANK_C000		<=	8'b0;

		LATCHED_FLASH_BANK_SW	<=	1'b0;

`ifdef SHRG
		LATCHED_IO_SHRG			<=	8'b00001000;
		// 复位期间设置，避免拨动开关引起错误
		LATCHED_SHRG_EN			<=	SWITCH[1];
`endif


		LATCHED_KEY_DATA		<=	8'b0;
		LATCHED_IO_DATA_WR		<=	8'b0;

		LATCHED_IO_FDC		<=	8'hFF;
		LATCHED_RAM_DATA_FDC	<=	8'hFF;

		LATCHED_IO_FDC_CT		<=	8'b0110_0000;

`ifdef RAM_ON_SRAM_CHIP
		RAM_CS_N				<=	1'b0;
		RAM_OE_N				<=	1'b0;
		RAM_BE0_N				<=	1'b1;
		RAM_BE1_N				<=	1'b1;

		RAM_WE_N				<=	1'b1;

		RAM_ADDR				<=	18'b0;
		RAM_DATA_W				<=	16'b0;
`endif

		RAM_RDY_UART			<=	1'b0;

		VRAM_WR_N				<=	1'b1;

		CLK_CNT					<=	4'd0;
	end
	else
	begin
		case (CLK_CNT[3:0])
		4'd0:
			begin
				// 当前状态：RAM：UART 读写
				CPU_CLK				<=	1'b0;

				RAM_RDY_UART		<=	1'b0;

`ifdef RAM_ON_SRAM_CHIP
				// 异步SRAM内存，锁存读写信号和地址，使能写信号
				RAM_CS_N			<=	1'b0;
				RAM_OE_N			<=	1'b0;
				RAM_BE0_N			<=	1'b0;
				RAM_BE1_N			<=	1'b1;

				if({CPU_MREQ,CPU_RD,CPU_WR,ADDRESS_RAM_CHIP}==4'b1011)
				begin
					RAM_WE_N		<=	1'b0;
				end
				else
				begin
					RAM_WE_N		<=	1'b1;
				end

				RAM_ADDR			<=	{2'b0, CPU_A};
				RAM_DATA_W			<=	{8'b0, CPU_DO};
`endif

				CLK_CNT					<=	4'd1;
			end
	
		4'd1:
			begin
				// 当前状态：RAM：准备 CPU 需要的数据
				// 同步内存，等待读写信号建立
				CPU_CLK				<=	1'b1;

`ifdef RAM_ON_SRAM_CHIP
				// 异步SRAM内存，等待读写信号建立
				RAM_CS_N			<=	1'b0;
				RAM_OE_N			<=	1'b0;
				RAM_BE0_N			<=	1'b1;
				RAM_BE1_N			<=	1'b0;

				RAM_WE_N			<=	~FDC_RAM_W;

				RAM_ADDR			<=	RAM_ADDRESS_FD_W;
				RAM_DATA_W			<=	{FDC_RAM_DATA_W[7:0], 8'b0};
`endif

				VRAM_WR_N			<=	1'b1;

				CLK_CNT				<=	4'd2;
			end

		4'd2:
			begin
				// CPU_CLK : 拉高

				// 当前状态：*** CPU 操作 （CPU 锁存信号线数据）***
				// 当前状态：*** CPU 信号线开始输出 ***

				// 软盘控制器数据写入RAM
				CPU_CLK				<=	1'b0;

//				RAM_RDY_FDC			<=	1'b0;	// 可以下个周期操作

				LATCHED_KEY_DATA	<=	KEY_DATA;

				if({CPU_MREQ,CPU_RD,CPU_WR,ADDRESS_IO}==4'b1011)
					LATCHED_IO_DATA_WR	<=	CPU_DO;

`ifdef SHRG
				if(LATCHED_SHRG_EN)
					if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_SHRG}==4'b1011)
						LATCHED_IO_SHRG		<=	CPU_DO;
`endif


`ifdef IO_BANK
				if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_BANK}==4'b1011)
					LATCHED_BANK_C000	<=	CPU_DO;
`endif

`ifdef GPIO_PIN
`endif


// FDC
				if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_FDC_CT}==4'b1011)
					LATCHED_IO_FDC_CT	<=	CPU_DO;

				if({CPU_IORQ,CPU_RD,CPU_WR}==3'b110)
					LATCHED_IO_FDC	<=	ADDRESS_IO_FDC_POLL	?	{FDC_POLL, 7'h7F}	:
										ADDRESS_IO_FDC_DATA	?	FDC_DATA			:
										ADDRESS_IO_FDC_WP	?	{FDC_WP, 7'h7F}		:
										8'hFF;

`ifdef RAM_ON_SRAM_CHIP
				// 异步SRAM内存，锁存读写信号和地址，使能写信号
				RAM_CS_N			<=	1'b0;
				RAM_OE_N			<=	1'b0;
				RAM_BE0_N			<=	1'b1;
				RAM_BE1_N			<=	1'b0;

				RAM_WE_N			<=	1'b1;

				RAM_ADDR			<=	RAM_ADDRESS_FD_R;
				RAM_DATA_W			<=	16'b0;
`endif

				if({CPU_MREQ,CPU_RD,CPU_WR,ADDRESS_VRAM}==4'b1011)
				begin
					VRAM_WR_N			<=	1'b0;
				end
				else
				begin
					VRAM_WR_N			<=	1'b1;
				end

				CLK_CNT				<=	4'd3;
			end

		4'd3:
			begin
				// CPU_CLK : 拉低

				// 完成读写操作，开始输出

				// 软盘控制器数据读取RAM
				CPU_CLK				<=	1'b0;

				RAM_RDY_UART		<=	1'b1;	// 可以下个周期操作

				// 锁存读取的 FDC 磁盘数据
				if(FDC_RAM_R)
					LATCHED_RAM_DATA_FDC	<=	RAM_DATA_OUT_FDC;

`ifdef RAM_ON_SRAM_CHIP
				// 进行异步内存读写操作
				// 读取操作，下个周期可以读取
				// 写入操作，下个周期完成

				//RAM_CS_N		<=	~UART_BUF_WAIT;
				RAM_CS_N		<=	~UART_BUF_CS;
				RAM_OE_N		<=	1'b0;
				RAM_BE0_N		<=	RAM_BE0_N_UART;
				RAM_BE1_N		<=	RAM_BE1_N_UART;

				//RAM_WE_N		<=	~UART_BUF_WAIT;		// UART数据写入RAM
				RAM_WE_N		<=	~UART_BUF_WR;		// UART数据写入RAM

				RAM_ADDR		<=	RAM_ADDRESS_UART;
				RAM_DATA_W		<=	{UART_BUF_DAT,8'b0};
`endif

				VRAM_WR_N			<=	1'b1;

				if(TURBO_SPEED)
					CLK_CNT				<=	4'd0;
				else
					CLK_CNT				<=	4'd4;
			end

		4'd4:
			begin
				// 当前状态：RAM：UART 读写
				CPU_CLK				<=	1'b0;

				RAM_RDY_UART		<=	1'b0;

`ifdef RAM_ON_SRAM_CHIP
				// 异步SRAM内存，锁存读写信号和地址，使能写信号
				RAM_CS_N			<=	1'b1;
				RAM_OE_N			<=	1'b0;
				RAM_BE0_N			<=	1'b1;
				RAM_BE1_N			<=	1'b1;

				RAM_WE_N			<=	1'b1;

				RAM_ADDR			<=	18'b0;
				RAM_DATA_W			<=	16'b0;
`endif

				CLK_CNT				<=	4'd5;
			end

		// 正常速度
		4'd13:
			begin
				CPU_CLK				<=	1'b0;

				CLK_CNT				<=	4'd0;
			end

		default:
			begin
				CPU_CLK				<=	1'b0;

`ifdef RAM_ON_SRAM_CHIP
				// 异步SRAM内存，完成了写操作
				RAM_WE_N			<=	1'b1;
`endif

				CLK_CNT				<=	CLK_CNT + 1'b1;
			end
		endcase
	end


	//vga_pll vgapll(CLK50MHZ, VGA_CLOCK);
	/* This module generates a clock with half the frequency of the input clock.
	 * For the VGA adapter to operate correctly the clock signal 'clock' must be
	 * a 50MHz clock. The derived clock, which will then operate at 25MHz, is
	 * required to set the monitor into the 640x480@60Hz display mode (also known as
	 * the VGA mode).
	 */


//wire [7:0] InPort = ADDR[0] ? {3'b000, INP[2:0], vcount[9:8]} : vcount[7:0];

`ifdef GPIO_PIN
wire [7:0] InPort = GPIO_IN;
`else
wire [7:0] InPort = 8'b0;
`endif


// CPU

`ifdef TV80

assign CPU_M1 = ~CPU_M1_N;
assign CPU_MREQ = ~CPU_MREQ_N;
assign CPU_IORQ = ~CPU_IORQ_N;
assign CPU_RD = ~CPU_RD_N;
assign CPU_WR = ~CPU_WR_N;
assign CPU_RFSH = ~CPU_RFSH_N;
assign CPU_HALT= ~CPU_HALT_N;
assign CPU_BUSAK = ~CPU_BUSAK_N;

assign CPU_RESET_N = ~CPU_RESET;
assign CPU_WAIT_N = ~CPU_WAIT;
assign CPU_INT_N = ~CPU_INT;	// 50HZ
//assign CPU_INT_N = ~VGA_VS;	// 接 VGA 垂直回扫信号 60HZ
assign CPU_NMI_N = ~CPU_NMI;
assign CPU_BUSRQ_N = ~CPU_BUSRQ;

/*
  // Outputs
  m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n, A, dout,
  // Inputs
  reset_n, clk, wait_n, int_n, nmi_n, busrq_n, di
*/

tv80s Z80CPU (
	.m1_n(CPU_M1_N),
	.mreq_n(CPU_MREQ_N),
	.iorq_n(CPU_IORQ_N),
	.rd_n(CPU_RD_N),
	.wr_n(CPU_WR_N),
	.rfsh_n(CPU_RFSH_N),
	.halt_n(CPU_HALT_N),
	.busak_n(CPU_BUSAK_N),
	.A(CPU_A),
	.dout(CPU_DO),
	.reset_n(CPU_RESET_N),
	.clk(CPU_CLK),
	.wait_n(CPU_WAIT_N),
	.int_n(CPU_INT_N),
	.nmi_n(CPU_NMI_N),
	.busrq_n(CPU_BUSRQ_N),
	.di(CPU_IORQ_N ? CPU_DI : CPU_D_INPORT)
);

`endif

assign CPU_RESET = ~RESET_N;

assign CPU_NMI = 1'b0;

// LASER310 的 WAIT_N 始终是高电平。
assign CPU_WAIT = 1'b0;

//assign CPU_WAIT = CPU_MREQ && (~CLKStage[2]);


// 0000 -- 3FFF ROM 16KB
// 4000 -- 5FFF DOS
// 6000 -- 67FF BOOT ROM
// 6800 -- 6FFF I/O
// 7000 -- 77FF VRAM 2KB (SRAM 6116)
// 7800 -- 7FFF RAM 2KB
// 8000 -- B7FF RAM 14KB
// B800 -- BFFF RAM ext 2KB
// C000 -- F7FF RAM ext 14KB

assign ADDRESS_ROM				=	(CPU_A[15:14] == 2'b00)?1'b1:1'b0;
assign ADDRESS_DOSROM			=	(CPU_A[15:13] == 3'b010)?LATCHED_DOSROM_EN:1'b0;
assign ADDRESS_IO				=	(CPU_A[15:11] == 5'b01101)?1'b1:1'b0;
assign ADDRESS_VRAM				=	(CPU_A[15:11] == 5'b01110)?1'b1:1'b0;

assign ADDRESS_89AB				=	(CPU_A[15:14] == 2'b10)?1'b1:1'b0;
assign ADDRESS_CDEF				=	(CPU_A[15:14] == 2'b11)?1'b1:1'b0;

// 7800 -- 7FFF RAM 2KB
assign ADDRESS_RAM_78			=	(CPU_A[15:11] == 5'b01111)?1'b1:1'b0;

// 7800 -- 7FFF RAM 2KB
// 8000 -- B7FF RAM 14KB
assign ADDRESS_RAM_16K		=	(CPU_A[15:12] == 4'h8)?1'b1:
								(CPU_A[15:12] == 4'h9)?1'b1:
								(CPU_A[15:12] == 4'hA)?1'b1:
								(CPU_A[15:11] == 5'b01111)?1'b1:
								(CPU_A[15:11] == 5'b10110)?1'b1:
								1'b0;

// 7800 -- 7FFF RAM 2KB
// 8000 -- FFFF RAM 32KB
assign ADDRESS_RAM_64K		=	(CPU_A[15:11] == 5'b01111)?1'b1:(CPU_A[15]);


assign ADDRESS_IO_SHRG		=	(CPU_A[7:0] == 8'd32)?1'b1:1'b0;

// 64K RAM expansion cartridge vz300_review.pdf 中的端口号是 IO 7FH 127
// 128K SIDEWAYS RAM SHRG2 HVVZUG23 (Mar-Apr 1989).PDF 中的端口号是 IO 112

assign ADDRESS_IO_BANK	=	(CPU_A[7:0] == 8'd127 || CPU_A[7:0] == 8'd112)?1'b1:1'b0;


assign ADDRESS_IO_FDC	=	(CPU_A[7:2] == 6'b000100)?1'b1:1'b0;

assign ADDRESS_IO_FDC_CT	=	(CPU_A[7:0] == 8'h10)?1'b1:1'b0;
assign ADDRESS_IO_FDC_DATA	=	(CPU_A[7:0] == 8'h11)?1'b1:1'b0;
assign ADDRESS_IO_FDC_POLL	=	(CPU_A[7:0] == 8'h12)?1'b1:1'b0;
assign ADDRESS_IO_FDC_WP	=	(CPU_A[7:0] == 8'h13)?1'b1:1'b0;


assign	ADDRESS_RAM_CHIP	=	ADDRESS_RAM_64K;


assign VRAM_WR			=	~VRAM_WR_N;


`ifdef	RAM_ON_SRAM_CHIP
assign CPU_DI = 	ADDRESS_ROM				? SYS_ROM_DATA			:
					ADDRESS_DOSROM			? DOS_ROM_DATA			:
					ADDRESS_VRAM			? VRAM_DATA_OUT			:
					ADDRESS_RAM_64K			? RAM_DATA_OUT_64K		:
					ADDRESS_IO				? LATCHED_KEY_DATA		:
					8'hzz;
`endif


assign CPU_D_INPORT	=	ADDRESS_IO_FDC			? LATCHED_IO_FDC	:
						8'hzz;


//assign RAM_CS_N_VID		=	~VID_BUF_VRAM_FETCH_WAIT;
assign RAM_CS_N_UART	=	~UART_BUF_WAIT;
//assign RAM_CS_N_FD		=	~FDC_RAM_W;
assign RAM_CS_N_FD		=	1'b0;
//assign RAM_CS_N_CPU		=	1'b1;

//assign RAM_BE0_N_VID	=	1'b0;
assign RAM_BE0_N_UART	=	1'b1;
assign RAM_BE0_N_FD		=	1'b1;
//assign RAM_BE0_N_CPU	=	1'b1;


//assign RAM_BE1_N_VID	=	1'b1;
assign RAM_BE1_N_UART	=	1'b0;
//assign RAM_BE1_N_FD		=	~FDC_RAM_W;
assign RAM_BE1_N_FD		=	1'b0;
//assign RAM_BE1_N_CPU	=	1'b1;


assign RAM_ADDRESS_UART	=		UART_BUF_A[17:0];
assign RAM_ADDRESS_FD_R	=		FDC_RAM_ADDR_R;
assign RAM_ADDRESS_FD_W	=		FDC_RAM_ADDR_W;


`ifdef FLASH_CHIP

// bank 1 bank255

// Altera DE1 4MB FLASH
`ifdef FLASH_CHIP_4M
//output	[21:0]	FL_ADDRESS;
assign	FL_ADDRESS[21:0]	=	(ADDRESS_CDEF)				?	{LATCHED_BANK_C000, CPU_A[13:0]}				:
								(ADDRESS_DOSROM)			?	{5'b00001, LATCHED_BANK_4000[2:0], CPU_A[13:0]}	:
																{5'b00000, LATCHED_BANK_0000[2:0], CPU_A[13:0]}	;
`endif

// Altera DE2-70 8MB FLASH
`ifdef FLASH_CHIP_8M
//output	[22:0]	FL_ADDRESS;
assign	FL_ADDRESS[21:0]	=	(ADDRESS_CDEF)				?	{LATCHED_BANK_C000, CPU_A[13:0]}				:
								(ADDRESS_DOSROM)			?	{5'b00001, LATCHED_BANK_4000[2:0], CPU_A[13:0]}	:
																{5'b00000, LATCHED_BANK_0000[2:0], CPU_A[13:0]}	;
assign	FL_ADDRESS[22]		=	LATCHED_FLASH_BANK_SW;
`endif

assign	FL_RESET_N	=	RESET_AHEAD_N;
assign	FL_CE_N		=	1'b0;
assign	FL_OE_N		=	1'b0;
assign	FL_WE_N		=	1'b1;


assign	SYS_ROM_DATA	=	FL_DATA;
assign	DOS_ROM_DATA	=	FL_DATA;


`ifdef DE1
assign	FL_BYTE_N	=	1'b0;
//output	FL_DQ15;
//input		FL_RY;
assign	FL_WP_N		=	1'bz;
`endif

`ifdef DE2
assign	FL_BYTE_N	=	1'b0;
//output	FL_DQ15;
//input		FL_RY;
assign	FL_WP_N		=	1'bz;
`endif

`ifdef DE2_70
assign	FL_BYTE_N	=	1'b0;
//output	FL_DQ15;
//input		FL_RY;
assign	FL_WP_N		=	1'bz;
`endif

`ifdef DE2_115
//assign	FL_BYTE_N	=	1'b0;
//output	FL_DQ15;
//input		FL_RY;
assign	FL_WP_N		=	1'bz;
`endif

`endif



`ifdef	RAM_ON_SRAM_CHIP

`ifdef SRAM_CHIP_256x16

// Altera DE1 512K SRAM
// Altera DE2 512K SRAM

assign	RAM_ADDRESS				=	RAM_ADDR;

`endif

assign	RAM_DATA	=	RAM_WE_N	?	16'bZ	:	RAM_DATA_W;

assign	RAM_DATA_OUT_64K	=	RAM_DATA[7:0];
assign	RAM_DATA_OUT_FDC	=	RAM_DATA[15:8];

`endif


/*****************************************************************************
* Video
******************************************************************************/
// Request for every other line to be black
// Looks more like the original video


`ifdef VRAM_2K

`ifdef FPGA_ALTERA

vram_altera vram_2k(
	.address_a(CPU_A[10:0]),
	.address_b(VDG_ADDRESS[10:0]),
	.clock_a(BASE_CLK),
	.clock_b(VDG_RD),
	.data_a(CPU_DO),
	.data_b(),
	//.wren_a(CPU_MREQ & VRAM_WR),
	.wren_a(VRAM_WR),
	.wren_b(1'b0),
	.q_a(VRAM_DATA_OUT),
	.q_b(VDG_DATA)
);

`endif

`endif


`ifdef VRAM_8K

`ifdef FPGA_ALTERA

vram_8k_altera vram_8k(
	.address_a({LATCHED_IO_SHRG[1:0],CPU_A[10:0]}),
	.address_b(VDG_ADDRESS[12:0]),
	.clock_a(BASE_CLK),
	.clock_b(VDG_RD),
	.data_a(CPU_DO),
	.data_b(),
	//.wren_a(CPU_MREQ & VRAM_WR),
	.wren_a(VRAM_WR),
	.wren_b(1'b0),
	.q_a(VRAM_DATA_OUT),
	.q_b(VDG_DATA)
);

`endif

`endif


// Video timing and modes
MC6847_VGA MC6847_VGA(
	.PIX_CLK(VGA_CLK),		//25 MHz = 40 nS
	.RESET_N(RESET_N),

	.RD(VDG_RD),
	.DD(VDG_DATA),
	.DA(VDG_ADDRESS),

	.AG(LATCHED_IO_DATA_WR[3]),
	.AS(1'b0),
	.EXT(1'b0),
	.INV(1'b0),
`ifdef SHRG
	.GM(LATCHED_IO_SHRG[4:2]),
`else
	.GM(3'b010),
`endif
	.CSS(LATCHED_IO_DATA_WR[4]),

	// vga
	.VGA_OUT_HSYNC(VGA_OUT_HS),
	.VGA_OUT_VSYNC(VGA_OUT_VS),
	.VGA_OUT_RED(VGA_OUT_RED),
	.VGA_OUT_GREEN(VGA_OUT_GREEN),
	.VGA_OUT_BLUE(VGA_OUT_BLUE)
);


`ifdef VGA_RESISTOR

`ifdef VGA_BIT12
assign VGA_RED = VGA_OUT_RED[7:4];
assign VGA_GREEN = VGA_OUT_GREEN[7:4];
assign VGA_BLUE = VGA_OUT_BLUE[7:4];
`endif

assign VGA_HS = VGA_OUT_HS;
assign VGA_VS = VGA_OUT_VS;

`endif

`ifdef VGA_ADV7123

`ifdef VGA_BIT24
assign VGA_DAC_RED = VGA_OUT_RED;
assign VGA_DAC_GREEN = VGA_OUT_GREEN;
assign VGA_DAC_BLUE = VGA_OUT_BLUE;
`endif

`ifdef VGA_BIT30
assign VGA_DAC_RED = {VGA_OUT_RED,2'b0};
assign VGA_DAC_GREEN = {VGA_OUT_GREEN,2'b0};
assign VGA_DAC_BLUE = {VGA_OUT_BLUE,2'b0};
`endif

assign VGA_DAC_BLANK_N = 1'b1;
assign VGA_DAC_SYNC_N = ~(VGA_OUT_HS | VGA_OUT_VS);
assign VGA_DAC_CLOCK = VGA_CLK;

always @(posedge VGA_CLK)
	begin
		VGA_HS <= VGA_OUT_HS;
		VGA_VS <= VGA_OUT_VS;
	end

`endif


// keyboard

`ifdef SIMULATE
initial
	begin
		KB_CLK_CNT = 5'b0;
	end
`endif


always @ (posedge CLK50MHZ)
begin
	KB_CLK			<=	KB_CLK_CNT[4];
	KB_CLK_CNT		<=	KB_CLK_CNT + 1;		//	50/32 = 1.5625 MHz
end


assign KEY_DATA[7] = 1'b1;	// 没有空置，具体用途没有理解
//assign KEY_DATA[6] = CASS_IN;
assign KEY_DATA[6] = ~CASS_IN;


LASER_KEYBOARD	KEYBOARD_U
(
	KB_CLK,			// 1.5625 MHz
	DLY_CLK,		// 0.15625 MHz
	RESET_N,

	PS2_KBCLK,
	PS2_KBDAT,

	CPU_A[7:0],
	KEY_PRESSED,
	KEY_DATA[5:0],

	RESET_KEY_N
);


`ifdef AUDIO_WM8731

AUDIO_IF AUD_IF(
	//	Audio Side
	.oAUD_BCLK(AUD_BCLK),
	.oAUD_DACLRCK(AUD_DACLRCK),
	.oAUD_DACDAT(AUD_DACDAT),
	.oAUD_ADCLRCK(AUD_ADCLRCK),
	.iAUD_ADCDAT(AUD_ADCDAT),
	//	Control Signals
	.iSPK_A(SPEAKER_A),
	.iSPK_B(SPEAKER_B),
	.iCASS_OUT(CASS_OUT),
	.oCASS_IN_L(CASS_IN_L),
	.oCASS_IN_R(CASS_IN_R),
	// System
	.iCLK_18_4(AUD_CTRL_CLK),
	.iRST_N(RESET_N)
);


`ifdef DE1

// AUDIO_WM8731

I2C_AUD_Config AUD_I2C_U(
	//	Host Side
	.iCLK(CLK50MHZ),
	//.iRST_N(RESET_N),
	.iRST_N(1'b1),
	//	I2C Side
	.I2C_SCLK(I2C_SCLK),
	.I2C_SDAT(I2C_SDAT)
);

`endif

`ifdef DE2

// AUDIO_WM8731
// ADV7180
// 有个老的DE2开发板需要设置 ADV7180，否则显示画面不稳定(产生CLK27MHZ信号)

I2C_AV_Config AV_I2C_U(
	//	Host Side
	.iCLK(CLK50MHZ),
	//.iRST_N(RESET_N),
	.iRST_N(1'b1),
	//	I2C Side
	.I2C_SCLK(I2C_SCLK),
	.I2C_SDAT(I2C_SDAT)
);

`endif

assign	AUD_XCK = AUD_CTRL_CLK;

`endif



assign	CASS_OUT		=	{LATCHED_IO_DATA_WR[2], 1'b0};

`ifdef AUDIO_WM8731
assign	CASS_IN			=	CASS_IN_L;
`endif



`ifdef GPIO_PIN
//assign	GPIO_0[35:0]	=	36'bz;		//	GPIO Connection 0
//assign	GPIO_1[35:0]	=	36'bz;		//	GPIO Connection 1
`endif


// floppy

assign FLOPPY_WP_READ	= 1'b0;



wire	[7:0]		FDC_DATA;
wire				FDC_POLL;
wire				FDC_WP;

wire	[7:0]		SECTOR_BYTE;
wire	[7:0]		TRACK1_NO;
wire	[7:0]		TRACK2_NO;
wire				DRIVE1;
wire				DRIVE2;
wire				MOTOR;

wire		FDC_IO;
wire		FDC_IO_POLL;
wire		FDC_IO_R;
wire		FDC_IO_W;

wire		FDC_SIG;
wire		FDC_SIG_CLK;

assign	FDC_IO		=	(CPU_IORQ&ADDRESS_IO_FDC);
assign	FDC_IO_POLL	=	(CPU_IORQ&ADDRESS_IO_FDC_POLL);
assign	FDC_IO_DATA	=	(CPU_IORQ&ADDRESS_IO_FDC_DATA);
assign	FDC_IO_CT	=	(CPU_IORQ&ADDRESS_IO_FDC_CT);

FDC_IF FDC_U (
	CPU_CLK,
	RESET_N,
	SWITCH[3:2],
	SWITCH[9:6],

	FDC_RAM_R,
	FDC_RAM_W,
	FDC_RAM_ADDR_R,
	FDC_RAM_ADDR_W,
	LATCHED_RAM_DATA_FDC,
	FDC_RAM_DATA_W,

	FDC_IO,
	FDC_IO_POLL,
	FDC_IO_DATA,
	FDC_IO_CT,

	FDC_SIG,
	FDC_SIG_CLK,

	LATCHED_IO_FDC_CT,
	FDC_DATA,
	FDC_POLL,
	FDC_WP,

	SECTOR_BYTE,
	TRACK1_NO,
	TRACK2_NO,
	DRIVE1,
	DRIVE2,
	MOTOR
);


`ifdef	DE1
wire	[15:0]	SEG7_DIG	=	{TRACK2_NO, TRACK1_NO};
SEG7_LUT_4 SEG7_U(HEX0_D,HEX1_D,HEX2_D,HEX3_D, SEG7_DIG);
`endif


`ifdef	DE2
wire	[31:0]	SEG7_DIG	=	{16'b0, TRACK2_NO, TRACK1_NO};
SEG7_LUT_8 SEG7_U(HEX0_D,HEX1_D,HEX2_D,HEX3_D,HEX4_D,HEX5_D,HEX6_D,HEX7_D, SEG7_DIG);
`endif

// uart

wire	UART_DBG;

UART_IF FD_BUF_UART_IF(
	//
	.MEM_A(UART_BUF_A),
	.MEM_WR(UART_BUF_WR),
	.MEM_DAT(UART_BUF_DAT),
	.MEM_Q(RAM_DATA_OUT_FDC),
	.MEM_RDY(RAM_RDY_UART),
	.MEM_WAIT(UART_BUF_WAIT),
	.MEM_CS(UART_BUF_CS),
	//
	.MEM_RD(),

	//	Control Signals

    /*
     * UART: 115200 bps, 8N1
     */
    .UART_RXD(UART_RXD),
    .UART_TXD(UART_TXD),

	// 串口调试
	.DBG(UART_DBG),

	// Clock: 10MHz 25MHz 50MHz
	.CLK(BASE_CLK),		// 需要与主状态机在同一时钟域
	.RST_N(RESET_N)
);

// other

//(*keep*)wire trap = (CPU_RD|CPU_WR) && (CPU_A[15:12] == 4'h0);
//assign LED = {KEY_PRESSED, CASS_IN, CASS_IN_L, CASS_IN_R, CASS_OUT, trap, 1'b0, LATCHED_SHRG_EN, LATCHED_DOSROM_EN, TURBO_SPEED};

reg trap_clk;
//reg trap;

//always @(posedge BASE_CLK)
always @(posedge CPU_CLK)
	begin
		// 数据读取点

/*
		// 读取之前
		trap_clk <=	(
			// 读取 0x80 0x80  0xFE 0xE7 0x18 0xC3  扇区
			LATCHED_CPU_A==16'h5441 || LATCHED_CPU_A==16'h54C6
		 || LATCHED_CPU_A==16'h554B || LATCHED_CPU_A==16'h55D0 || LATCHED_CPU_A==16'h5655 || LATCHED_CPU_A==16'h56DA
		 || LATCHED_CPU_A==16'h57EF

			// 读取 0x80 0x80  0xC3 0x18 0xE7 0xFE
		 || LATCHED_CPU_A==16'h5B60 || LATCHED_CPU_A==16'h5BE5
		 || LATCHED_CPU_A==16'h5C6A || LATCHED_CPU_A==16'h5CEF || LATCHED_CPU_A==16'h5D74 || LATCHED_CPU_A==16'h5DF9

			// 读取数据 读取失败 读取成功
		 || LATCHED_CPU_A==16'h5E7D || LATCHED_CPU_A==16'h5E9F || LATCHED_CPU_A==16'h5EA2
			);


		// 读取成功
		trap_clk <=	(
			// 找到 0x80 0x80  0xFE 0xE7 0x18 0xC3  扇区
			LATCHED_CPU_A==16'h5446 || LATCHED_CPU_A==16'h54C8 || LATCHED_CPU_A==16'h54CB
		 || LATCHED_CPU_A==16'h5550 || LATCHED_CPU_A==16'h55D5 || LATCHED_CPU_A==16'h565A || LATCHED_CPU_A==16'h56DF
		 || LATCHED_CPU_A==16'h57FB

			// 找到 0x80 0x80  0xC3 0x18 0xE7 0xFE
		 || LATCHED_CPU_A==16'h5B65 || LATCHED_CPU_A==16'h5BEA
		 || LATCHED_CPU_A==16'h5C6F || LATCHED_CPU_A==16'h5CF4 || LATCHED_CPU_A==16'h5D79 || LATCHED_CPU_A==16'h5DFE

			// 读取数据 读取失败 读取成功
		 || LATCHED_CPU_A==16'h5E7D || LATCHED_CPU_A==16'h5E9F || LATCHED_CPU_A==16'h5EA2
			);


		// 使用后，系统不稳定。用 FDC_SIG_CLK 替代
		trap_clk <=	FDC_RAM_W;	//磁盘写
*/
/*
		trap_clk <=	(
			// 读取数据 读取失败 读取成功
			LATCHED_CPU_A==16'h5E7D
			);
*/

		trap_clk <=	(
			LATCHED_CPU_A==16'h54CB
			|| LATCHED_CPU_A==16'h56DF || LATCHED_CPU_A==16'h57FB

			// 读取数据 读取失败 读取成功
			|| LATCHED_CPU_A==16'h5E7D || LATCHED_CPU_A==16'h5E9F || LATCHED_CPU_A==16'h5EA2
			);

/*
		trap_clk <=	(
		    LATCHED_CPU_A==16'h57FB
			// 读取数据 读取失败 读取成功
		 || LATCHED_CPU_A==16'h5E7D
			);
*/
	end


reg	[15:0]	LATCHED_CPU_A;

always @(posedge CPU_CLK)
	begin
		if(CPU_MREQ)
			LATCHED_CPU_A	<=	CPU_A;
	end

// 读取完128个数据准备校验
(*keep*)wire trap =	(LATCHED_CPU_A==16'h5E88);

//(*keep*)wire trap =	(LATCHED_CPU_A==16'h4241);	// ERROR 寄存器a存放错误代码


assign LED = {KEY_PRESSED, MOTOR, DRIVE1, trap, trap_clk, FDC_SIG, FDC_SIG_CLK, UART_DBG, LATCHED_SHRG_EN, TURBO_SPEED};


endmodule
