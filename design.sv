`include "iu.sv"
`include "alu.sv"
`include "memory.sv"
`include "round_robin_arbiter.sv"

module core 
(
	input logic clk, rst_n,
  input logic [17:0] inst1, inst2, inst3,
	output logic done,
  output logic [7:0] mem_out,reg_out1,reg_out2,reg_out3,
	input logic start1, start2, start3
);
logic [1:0] mem_fetch_start1, mem_fetch_start2, mem_fetch_start3;

logic hit_status;
logic req1, req2, req3, grnt1, grnt2, grnt3;
  logic [10:0] addr1, addr2, addr3, cache_address, ram_address;
logic mem_fetch_done1,mem_fetch_done2, mem_fetch_done3;
logic mem_done;
logic [7:0] data_in1, data_in2, data_in3, data_out1, data_out2, data_out3;

  initial begin
    $monitor("DESIGN: St=%0b || St=%0b || St=%0b || Instr=%0d || Instr=%0d || Instr=%0d || done1=%0b || time=%0t || grnt1=%0b || grnt2=%0b || grnt3=%0d || mem_fetch_done1=%0d || mem_fetch_done2=%0d || mem_fetch_done3=%0d ",start1, start2, start3,inst1, inst2, inst3,core1.alu_done,$time, grnt1, grnt2, grnt3,mem_fetch_done1,mem_fetch_done2,mem_fetch_done3);

  end
  
  
  
  
iu core1(
.start(start1),
.instruction(inst1),
.clk(clk),
.rst_n(rst_n),
.done(done1),
  .mem_fetch_start(mem_fetch_start1),
.mem_fetch_addr(addr1),
  .reg_out(reg_out1),
.data_in(data_in1),
.data_out(data_out1),
.mem_fetch_done(mem_fetch_done1)
);

iu core2(
.start(start2),
.instruction(inst2),
.clk(clk),
.rst_n(rst_n),
.done(done2),
  .mem_fetch_start(mem_fetch_start2),
.mem_fetch_addr(addr2),
  .reg_out(reg_out2),
.data_in(data_in2),
.data_out(data_out2),
.mem_fetch_done(mem_fetch_done2)
);

iu core3(
.start(start3),
.instruction(inst3),
.clk(clk),
.rst_n(rst_n),
.done(done3),
  .reg_out(reg_out3),
  .mem_fetch_start(mem_fetch_start3),
.mem_fetch_addr(addr3),
.data_in(data_in3),
.data_out(data_out3),
.mem_fetch_done(mem_fetch_done3)
);

round_robin_arbiter r1 (
	.rst_an(rst_n),
	.clk(clk),
	.req({req1, req2, req3}),
	.grant({grnt1, grnt2, grnt3})
);

/*cache_memory c1 (.clk(clk),.address(cache_address), .read(), .dataIn(), .dataOut(cache_data_out), .hit(hit_status));
cache_controller cac_cntrl(.clk(clk),.hit(hit_status),.read(cache_start));
*/

Memory RAM 
(
.clk(clk),
.rst_n(rst_n),
.start(ram_start),     
.done(mem_done),      
  .addr(ram_address), 
  .we(we),         // Write enable input
  .data_in(data_in), // Data input for writing
  .data_out(data_out)
);
  
  assign mem_out=data_out;
//assign done = done1;
assign done = done1 || done2 || done3;
//assign cache_address = (grnt1) ? addr1 : (grnt2) ? addr2 : (grnt3) ? addr3 : 'x;
assign ram_address = (grnt1) ? addr1 : (grnt2) ? addr2 : (grnt3) ? addr3 : 'x;
//assign data_in1 = (grnt1 && hit_status) ? cache_data_out: 'x;
//assign data_in2 = (grnt2 && hit_status) ? cache_data_out: 'x;
//assign data_in3 = (grnt3 && hit_status) ? cache_data_out: 'x;
//assign cache_read_start = cache_start && hit_status;

always_comb begin
  if (grnt1)
// if (grnt1 && hit_status) 
	mem_fetch_done1 = 1;
else
	mem_fetch_done1 = 0; 
  if (grnt2)
// if  (grnt2 && hit_status)	
	mem_fetch_done2 = 1;
 else
	mem_fetch_done2 = 0;
  if (grnt3)
 //if (grnt3 && hit_status)
	mem_fetch_done3 = 1;
 else
	mem_fetch_done3 = 0;
end

  always_ff @(posedge clk) begin
 if (mem_fetch_start1[0]^mem_fetch_start1[1]) 
	req1 <= 1;
else
	req1 <= 0;  
 if  (mem_fetch_start2[0]^mem_fetch_start2[1])	
	req2 <= 1;
 else
	req2 <= 0;
 
 if (mem_fetch_start3[0]^mem_fetch_start3[1])
	req3 <= 1;
 else
	req3 <= 0;
end

endmodule


