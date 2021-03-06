/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-08 16:56
 * Last modified : 2018-04-08 16:56
 * Filename      : top.v
 * Description   : 
 * *********************************************************************/
module  top(
        input                   CLOCK_50                ,
        //ADC
        output  wire            VGA_CLK                 ,
        output  wire            VGA_SYNC_N              ,
        output  wire            VGA_BLANK_N             ,
        //VGA               
        output  wire            VGA_HS                  ,
        output  wire            VGA_VS                  ,
        output  wire  [ 7: 0]   VGA_R                   ,
        output  wire  [ 7: 0]   VGA_G                   ,
        output  wire  [ 7: 0]   VGA_B                   
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
wire                            rst_n                           ; 
wire                            clk_25m                         ;
wire                            clk_65m                         ; 
wire                            clk_130m                        ; 
wire                            clk                             ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================




pll_clk	pll_clk_inst (
        .inclk0                 (CLOCK_50               ),
        .c0                     (clk                    ),
        .c1                     (clk_25m                ),
        .c2                     (clk_65m                ),
		  .c3                     (clk_130m               ),
        .locked                 (rst_n                  )
	);


vga vga_inst(
        .clk                    (clk_25m                ),
        .rst_n                  (rst_n                  ),
        //vga
        .vga_r                  (VGA_R                  ),
        .vga_g                  (VGA_G                  ),
        .vga_b                  (VGA_B                  ),
        .vga_hs                 (VGA_HS                 ),
        .vga_vs                 (VGA_VS                 ),
        .vga_blank              (VGA_BLANK_N            ),
        .vga_sync               (VGA_SYNC_N             ),
        .vga_clk                (VGA_CLK                )
);


endmodule
