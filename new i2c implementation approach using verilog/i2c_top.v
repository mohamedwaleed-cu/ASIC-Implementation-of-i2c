module i2c_top(input clk , input rst );
wire sda_mosi,sda_miso,scl;


i2c_master u1 (clk,rst,sda_miso,sda_mosi,scl);

i2c_slave u2 (sda_mosi,scl,sda_miso);

endmodule