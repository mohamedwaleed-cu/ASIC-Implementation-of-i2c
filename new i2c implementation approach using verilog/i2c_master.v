module i2c_master(input clk , input rst , input sda_in , output reg sda_out , output scl);

reg [6:0] slave_address=7'b1001100;
reg rw=1'b1;
reg [7:0] data=8'b11110000;
reg [3:0] dataCounter=4'b0000,addressCounter=4'b0000;

reg [4:0]  S0=4'b0000;		//IDLE
reg [4:0]  S1=4'b0001;	//start_condition
reg [4:0]  S2=4'b0010;	//slave_address
reg [4:0]  S3=4'b0011;		//read/write
reg [4:0]  S4=4'b0100;		//waiting for ack
reg [4:0]  S5=4'b0101;		//sending-recieving data
reg [4:0]  S6=4'b0110;	//waiting for ack
reg [4:0]  S7=4'b0111;		//stop condition


reg [4:0]  state=4'b0000 ;
reg start=1'b0;

assign scl = (rst==1 || state==S0 || state==S1) ? 1 : clk;
/*always@(*)
begin
    if(rst==1)  scl<=1;
    else begin
             if((state==S0)||(state==S1))  
                     scl<=1;
            else    scl<=~scl;
         end 
end */

always@(posedge clk or negedge rst)
begin
         if(rst)
        begin
        sda_out <= 1'b0;
        state <= S0;
        addressCounter<=4'b0000;
        dataCounter<=4'b0000;
        end  
        else
        begin
    	case (state)
            S0:
            begin
                    sda_out <= 1'b1;
                    state <= S1;
		    addressCounter<=4'b0000;
		    dataCounter<=4'b0000;		
            end

     	   S1:
     	     begin
                sda_out <= 1'b0;
              	state <= S2;
    	      end

    	    S2: 
    	      begin
    	        sda_out <= slave_address[addressCounter];
    	        addressCounter <= addressCounter + 1;
    	        if (addressCounter == 7) 
    	            begin
     	             state <= S3;
		     sda_out <= rw;	
     	           end
     	     end
     	   S3:
     	     begin
                sda_out <= rw;
              	state <= S4;
    	      end
            S4:
              begin
		if(sda_in)
		state <= S7;
		else
                state <= S5;
              end
            S5:
              begin
            	if(!rw) 
		begin   
                sda_out <= data[dataCounter];
    	        dataCounter <= dataCounter + 1;
                if (dataCounter == 8) 
    	            begin
     	             state <= S6;
		     sda_out <= 1'b0;
     	           end
		end
		else
		begin
                data[dataCounter-1] <= sda_in;
    	        dataCounter <= dataCounter + 1;
                if (dataCounter == 8) 
    	            begin
     	             state <= S6;
		     sda_out <= 1'b0;	
     	           end
		end
              end
            S6:
     	     begin
		sda_out<=1'b0;
                state <= S7;
    	      end
            S7:
              begin
                state <= S0;
		sda_out <= 1'b1;
              end
    	  endcase
    	  end
    end    
endmodule 
