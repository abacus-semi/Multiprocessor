`include "package.sv"
module iu (
input logic start,
input logic [17:0] instruction,
input logic clk,
input logic rst_n,
output logic done,
output logic [2:0] mem_fetch_start,
output logic [10:0] mem_fetch_addr,
input logic [7:0] data_in,
output logic [7:0] data_out,
  output logic [7:0] reg_out,
input logic mem_fetch_done
);

typedef enum logic[3:0] {   				no_op  = 4'b0000,
							add_op = 4'b0001, 
							and_op = 4'b0010,
							sub_op = 4'b0011,
							mul_op = 4'b0100,
							load_op = 4'b0101,
							store_op = 4'b0110,
							slr_op = 4'b0111,
							sll_op = 4'b1000,
							sp_func1_op = 4'b1001,
							sp_func2_op = 4'b1010,
							sp_func3_op = 4'b1011,
							sp_func4_op = 4'b1100 } operation_t;
							
typedef enum logic[1:0] {   	alu_type   = 2'b11,
							load_type  = 2'b01, 
							store_type = 2'b10,
							no_type    = 2'b00} operationType_t;
							
operationType_t op_type;

logic [7:0] a, b, c, wr_data_reg_file;
operation_t op;
logic alu_start, alu_done, fetch_done, wr_en;

RegisterFile r1 (
	.clk,
  	.rst_n,
	.wr_addr(instruction[13:11]),
	.rd_addr1(instruction[7:5]),
	.rd_addr2(instruction[2:0]),
	.op_type(op_type),
	.op(op),
	.wr_en(wr_en),
	.wr_data(wr_data_reg_file),
	.rd_data1(b),
	.rd_data2(c),
	.reg_wr(reg_wr_done)
);


alu a1 
(
	.clk,
	.reset_n(rst_n),
	.start(alu_start),
	.A(a),
	.B(b),
	.C(c),
	.op(op),
	.op_type,
	.done(alu_done)
	
);

  
assign wr_data_reg_file = ((op_type === alu_type) && alu_done && start) ? a : 
					((op_type === load_type) && mem_fetch_done && start) ? data_in : 'x;
assign reg_out = wr_data_reg_file;
  
assign wr_en =  (op_type === alu_type) ? alu_done && start : 
					(op_type === load_type) ? (!reg_wr_done && mem_fetch_done && start) : 0;
//assign x = instruction[17:14]; 

assign data_out = ((op_type === store_type) && start) ? b : 'x;

assign done = ((op_type === store_type) && start) ? mem_fetch_done : (rst_n == 0) ? 1 : reg_wr_done;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		op_type <= no_type;
		mem_fetch_start <= no_type;
	end
	else if(start)begin
		case(instruction[17:14])
				no_op : $display("No-Operation/Instruction Delay");		
				add_op  	:  begin
								  op_type <= alu_type;
								  op <=  add_op;
								  alu_start <= 1; 	
						  end
				and_op 		: begin
								  op_type <= alu_type;
								  op <=  and_op;
								  alu_start <= 1; 
						
						  end
				sub_op         :  begin
								  op_type <= alu_type;
								  op <=  sub_op;
								  alu_start <= 1; 
						
						  end
				mul_op 		:  begin
								  op_type <= alu_type;
								  op <=  mul_op;
								  alu_start <= 1; 
						
						  end	
				slr_op 		:  begin
								  op_type <= alu_type;
								  op <=  slr_op;
								  alu_start <= 1; 
						
						  end	
				sll_op          :  begin
								  op_type <= alu_type;
								  op <=  sll_op;
								  alu_start <= 1; 
						
						  end
				sp_func1_op     :  begin
								  op_type <= alu_type;
								  op <=  sp_func1_op;
								  alu_start <= 1; 
						
						  end 	
				sp_func2_op 	: begin
								  op_type <= alu_type;
								  op <=  sp_func2_op;
								  alu_start <= 1; 
						
						  end
				sp_func3_op 	: begin
								  op_type <= alu_type;
								  op <=  sp_func3_op;
								  alu_start <= 1; 
						
						  end	
				sp_func4_op 	: begin
								  op_type <= alu_type;
								  op <=  sp_func4_op;
								  alu_start <= 1; 
						
						  end
								  
				load_op 		: begin
						    	//if(start)begin
									op_type <= load_type;
									op <= load_op;
								  mem_fetch_start <= load_type;	
								  alu_start <= 0;
								mem_fetch_addr <=  instruction[10:0];

						//if(mem_fetch_done) begin
						//wr_data_reg_file <= data_in;
						//end
						end
								  
				store_op 		: begin
									op_type <= store_type;
								  mem_fetch_start <= store_type;
									op <= store_op;
								  alu_start <= 0;
								  end
								
		endcase
	end
end


endmodule


module RegisterFile #(parameter N = 3, M = 8)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N-1:0] rd_addr1, // Read address 1
    input  logic [N-1:0] rd_addr2, // Read address 2
    input  logic [N-1:0] wr_addr,  // Write address
    input  logic [M-1:0]  wr_data,  // Write data
    input  logic         wr_en,    // Write enable
    output logic [M-1:0]  rd_data1, // Read data 1
    output logic [M-1:0]  rd_data2,  // Read data 2
	input logic [3:0] op,
	input logic [1:0] op_type,
	output logic reg_wr
);

    logic [M-1:0] registers [N-1:0];

  initial begin

  end


    // Read operation
    assign rd_data1 = (rd_addr1 < N) ? registers[rd_addr1] : 'x;
    assign rd_data2 = (rd_addr2 < N) ? registers[rd_addr2] : 'x;

    // Write operation
    always_ff @(posedge clk) begin
      if(rst_n==0) begin
      for(int i=0;i<N-1;i++)
      registers[i]=8'b0;
      end
        
        
        if ((op_type != 2'b10) && (op_type != 2'b00) && wr_en) begin
            registers[wr_addr] <= wr_data;
	    reg_wr <= 1'b1;
	end
	else reg_wr <= 1'b0;
    end

endmodule

