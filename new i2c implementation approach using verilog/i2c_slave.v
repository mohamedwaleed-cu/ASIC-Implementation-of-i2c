/**
I2C Slave to Read/Write 8 bits of data only
*/


module i2c_slave(
	input wire SDA_in,
    input wire SCL,
	output reg SDA_out);
  
  reg [4:0] IDLE 			= 4'b0000;
  reg [4:0] START 			= 4'b0001;
  reg [4:0] READ_ADDRESS 	= 4'b0010;
  reg [4:0] READ_WRITE 		= 4'b0011;
  reg [4:0] ADDRESS_ACK 	= 4'b0100;
  reg [4:0] DATA 			= 4'b0101;
  reg [4:0] DATA_ACK   		= 4'b0110;
  reg [4:0] STOP 			= 4'b0111;
 
  
  reg [4:0] state 			= 4'b0010;
  
  reg [6:0] slaveAddress 	= 7'b100_1000;
  reg [6:0] addr			= 7'b000_0000;
  reg [6:0] addressCounter 	= 7'b000_0000;
  
  reg [7:0] data			= 8'b1100_0000;
  reg [6:0] dataCounter 	= 7'b000_0000;
  
  reg readWrite			= 1'b1;
  reg start 			= 0;
  reg write_ack			= 0;
  
  
  always @(negedge SDA_in) begin
    if ((start == 0) && (SCL == 1)) 
    begin
		start <= 1;
        addressCounter <= 0;
      	dataCounter <= 0;
	end
  end
  
  always @(posedge SDA_in) begin
    if (state == DATA_ACK && SCL == 1)
      begin
        start <= 0;
		state <= READ_ADDRESS;
	  end
	end
  
  always @(posedge SCL)
    begin
    	if (start == 1)
    	begin
    	  case (state)
    	    READ_ADDRESS: 
    	      begin
    	        addr[addressCounter-1] <= SDA_in;
    	        addressCounter <= addressCounter + 1;
    	        if (addressCounter == 7) 
    	            begin
     	             state <= READ_WRITE;
     	           end
     	     end
     	   READ_WRITE:
     	     begin
                readWrite <= SDA_in;
              	state <= ADDRESS_ACK;
		SDA_out <= 1'b1;
    	      end
            ADDRESS_ACK:
              begin
		if(addr==slaveAddress)
		begin
                state <= DATA;
		SDA_out <= 1'b0;
		end
		else
		begin
		SDA_out <= 1'b1;
		state <= STOP;
		end
              end
            DATA:
              begin
            	if(!readWrite) 
		begin   
                data[dataCounter-1] <= SDA_in;
    	        dataCounter <= dataCounter + 1;
                if (dataCounter == 8) 
    	            begin
     	             state <= DATA_ACK;
     	           end
		end
		else
		begin
                SDA_out <= data[dataCounter];
    	        dataCounter <= dataCounter + 1;
                if (dataCounter == 8) 
    	            begin
		     SDA_out<=1'b0;	
     	             state <= DATA_ACK;
     	           end
		end
              end
            DATA_ACK:
     	     begin
		SDA_out<=1'b0;
                state <= STOP;
    	      end
            STOP:
              begin
                start <= 0;
                state <= READ_ADDRESS;
              end
    	  endcase
    	end
    end
    
  
endmodule
