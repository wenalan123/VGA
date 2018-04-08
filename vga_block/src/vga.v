/************************************************************************
 * Author        : Wen Chunyang
 * Email         : 1494640955@qq.com
 * Create time   : 2018-04-08 16:57
 * Last modified : 2018-04-08 16:57
 * Filename      : vga.v
 * Description   : 
 * *********************************************************************/
module  vga(
        input                   clk                     ,
        input                   rst_n                   ,
        //vga
        output  reg   [ 7: 0]   vga_r                   ,
        output  reg   [ 7: 0]   vga_g                   ,
        output  reg   [ 7: 0]   vga_b                   ,
        output  wire            vga_hs                  ,
        output  wire            vga_vs                  ,
        output  wire            vga_blank               ,
        output  wire            vga_sync                ,
        output  wire            vga_clk 
);
//=====================================================================\
// ********** Define Parameter and Internal Signals *************
//=====================================================================/
//ADV7123 t输出延迟=t6+t8=7.5+15=22.5ns
//640*480@60Hz fclk=25MHz,Tclk=40ns<22.5ns,所以数据不需要提前一个时钟输出,按正常时序即可
parameter   LinePeriod      =       800                         ;
parameter   H_SyncPulse     =       96                          ;
parameter   H_BackPorch     =       48                          ;
parameter   H_ActivePix     =       640                         ;
parameter   H_FrontPorch    =       16                          ;
parameter   Hde_start       =       H_SyncPulse + H_BackPorch   ; 
parameter   Hde_end         =       Hde_start + H_ActivePix     ; 

parameter   FramePeriod     =       525                         ;
parameter   V_SyncPulse     =       2                           ;
parameter   V_BackPorch     =       33                          ;
parameter   V_ActivePix     =       480                         ;
parameter   V_FrontPorch    =       10                          ;
parameter   Vde_start       =       V_SyncPulse + V_BackPorch   ; 
parameter   Vde_end         =       Vde_start + V_ActivePix     ; 

/*
// 1024*768@60Hz fclk=65MHz,Tclk=15.38ns<22.5ns,所以数据要提前一个时钟输出,从而使数据对齐
parameter   LinePeriod      =       1344                        ;
parameter   H_SyncPulse     =       136                         ;
parameter   H_BackPorch     =       160                         ;
parameter   H_ActivePix     =       1024                        ;
parameter   H_FrontPorch    =       24                          ;
parameter   Hde_start       =       H_SyncPulse + H_BackPorch -1;//提前一个周期发送数据，从而使数据对齐 
parameter   Hde_end         =       Hde_start + H_ActivePix     ;//注意Hde_start已经提前了一个周期，所以这里就不能再减一了，否则就相当于减二了 

parameter   FramePeriod     =       806                         ;
parameter   V_SyncPulse     =       6                           ;
parameter   V_BackPorch     =       29                          ;
parameter   V_ActivePix     =       768                         ;
parameter   V_FrontPorch    =       3                           ;
parameter   Vde_start       =       V_SyncPulse + V_BackPorch   ; 
parameter   Vde_end         =       Vde_start + V_ActivePix     ; 
*/

parameter   Red_Wide        =       20                          ;
parameter   Green_block     =       100                         ;


reg                             hsync                           ;
reg                             vsync                           ;

reg     [10: 0]                 h_cnt                           ;
wire                            add_h_cnt                       ;
wire                            end_h_cnt                       ;

reg     [ 9: 0]                 v_cnt                           ;
wire                            add_v_cnt                       ; 
wire                            end_v_cnt                       ;

wire                            red_area                        ;
wire                            green_area                      ; 
wire                            blue_area                       ; 
wire                            valid_area                      ; 
//======================================================================
// ***************      Main    Code    ****************
//======================================================================
assign  vga_sync    =       1'b0;
assign  vga_blank   =       vga_hs & vga_vs;
assign  vga_hs      =       hsync;
assign  vga_vs      =       vsync;
assign  vga_clk     =       ~clk;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        h_cnt <= 0;
    end
    else if(add_h_cnt)begin
        if(end_h_cnt)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;
    end
end

assign add_h_cnt     =       1'b1;
assign end_h_cnt     =       add_h_cnt && h_cnt== LinePeriod-1;

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        v_cnt <= 0;
    end
    else if(add_v_cnt)begin
        if(end_v_cnt)
            v_cnt <= 0;
        else
            v_cnt <= v_cnt + 1;
    end
end

assign add_v_cnt     =       end_h_cnt;
assign end_v_cnt     =       add_v_cnt && v_cnt== FramePeriod-1;

//hsync
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hsync   <=      1'b0;
    end
    else if(add_h_cnt && h_cnt == H_SyncPulse-1)begin
        hsync   <=      1'b1;
    end
    else if(end_h_cnt)begin
        hsync   <=      1'b0;
    end
end

//vsync
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vsync   <=      1'b0;
    end
    else if(add_v_cnt && v_cnt == V_SyncPulse-1)begin
        vsync   <=      1'b1;
    end
    else if(end_v_cnt)begin
        vsync   <=      1'b0;
    end
end

assign  valid_area  =   (h_cnt >= Hde_start - 1 && h_cnt < Hde_end - 1 && v_cnt >= Vde_start && v_cnt < Vde_end);//v_cnt是多周期的，所以不用提前  


assign  red_area    =   (h_cnt >= Hde_start -1 && h_cnt < Hde_start - 1 + Red_Wide) || (h_cnt >= Hde_end - 1 - 20 && h_cnt < Hde_end - 1) || (v_cnt >= Vde_start && v_cnt < Vde_start + Red_Wide) || (v_cnt >= Vde_end - 20 && v_cnt < Vde_end);


assign  green_area  =   (h_cnt >= Hde_start - 1 + 270 && h_cnt < Hde_start -1 + 370) && (v_cnt >= Vde_start + 190 && v_cnt < Vde_start + 290);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vga_r   <=      8'h0;
        vga_g   <=      8'h0;
        vga_b   <=      8'h0;
    end
    else if(valid_area)
        if(red_area)begin
            vga_r   <=      8'hff;
            vga_g   <=      8'h0;
            vga_b   <=      8'h0;
        end
        else if(green_area)begin
            vga_r   <=      8'h0;
            vga_g   <=      8'hff;
            vga_b   <=      8'h0;
        end
        else begin
            vga_r   <=      8'hff;
            vga_g   <=      8'hff;
            vga_b   <=      8'hff;
        end
    else begin
            vga_r   <=      8'h0;
            vga_g   <=      8'h0;
            vga_b   <=      8'h0;
    end
end



endmodule
