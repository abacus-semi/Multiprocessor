module alu
(
input logic clk,
input logic reset_n,
input logic [3:0] op,
input logic start,
output logic [7:0] A,
input logic [7:0] B,
input logic [7:0] C,
input logic [1:0] op_type,
output logic done
);

		logic [7:0] 	  result_aax, result_mult, result_spec;
		logic 		      start_single, start_mult, start_spl, done_aax, done_mult, done_spec;

		assign start_single = start & (((op >= 4'b0001) && (op <= 4'b0011)) || (op === 4'b0111) || (op === 4'b1000))& (op_type === 2'b11);
		assign start_mult   = start & (op === 4'b0100) & (op_type == 2'b11);
		assign start_spl	= start & ((op >= 4'b1001) && (op <= 4'b1100))& (op_type === 2'b11);

		single_cycle arith (.A(B), .B(C), .op, .clk, .reset_n, .start(start_single),
				.done(done_aax), .result(result_aax));

		three_cycle mult (.A(B), .B(C), .op, .clk, .reset_n, .start(start_mult),
				.done(done_mult), .result(result_mult));
	
		special_func func  (.A(B), .B(C), .opcode(op), .clk, .reset_n, .start(start_spl), .done(done_spec), .result(result_spec));


   assign done = ((op >= 4'b1001) && (op <= 4'b1100)) ? done_spec : (op === 4'b0100) ? done_mult : done_aax;

   assign A = ((op >= 4'b1001) && (op <= 4'b1100)) ? result_spec : (op === 4'b0100) ? result_mult :  result_aax;

endmodule 


module single_cycle(input logic [7:0] A,
		   input logic [7:0] B,
		   input logic [3:0] op,
		   input logic clk,
		   input logic reset_n,
		   input logic start,
		   output logic done,
		   output logic [7:0] result);
		   
typedef enum bit[3:0] {   	no_op  = 4'b0000,
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
							
  always @(posedge clk) begin
    if (!reset_n)
      result <= 0;
    else 
      case(op)
		add_op : result <= A + B;
		and_op : result <= A & B;
		sub_op : result <= A - B;
		slr_op : result <= A >> 1;
		sll_op : result <= A << 1;
      endcase 
//$display("A: %0h || B: %0h || start: %0d || opcode: %0d || done:%0d || result: %0h ||" A, B, start, op, done, result); 
end

   always @(posedge clk)
     if (!reset_n)
       done <= 0;
     else
       done =  ((start === 1'b1) && (op !== 3'b000));

endmodule : single_cycle


module three_cycle(input logic [7:0] A,
		   input logic [7:0] B,
		   input logic [3:0] op,
		   input logic clk,
		   input logic reset_n,
		   input logic start,
		   output logic done,
		   output logic [7:0] result);

   logic [7:0] 			       a_int, b_int;
   logic [15:0] 		       mult1, mult2;
   logic 			       done1, done2, done3;

   always @(posedge clk)
     if (!reset_n) begin
	done  <= 0;
	done3 <= 0;
	done2 <= 0;
	done1 <= 0;
	a_int <= 0;
	b_int <= 0;
	mult1 <= 0;
	mult2 <= 0;
	result<= 0;
     end else begin // if (!reset_n)
	a_int  <= A;
	b_int  <= B;
	mult1  <= a_int * b_int;
	mult2  <= mult1;
	result <= mult2;
	done3  <= start & !done;
	done2  <= done3 & !done;
	done1  <= done2 & !done;
	done   <= done1 & !done;
     end // else: !if(!reset_n)
endmodule : three_cycle

module special_func
(
 input logic [7:0] A,
 input logic [7:0] B,
 input logic [3:0] opcode,
 input logic clk,
 input logic reset_n,
 input logic start,
 output logic done,
 output logic [7:0] result
);
  
 logic [7:0] a_int, b_int;
 logic [15:0] mult_ff_1, mult_ff_2;
 logic done_ff_1, done_ff_2, done_ff_3;
  
 always @(posedge clk)
  if (!reset_n) begin
   done <= 0;
   done_ff_3 <= 0;
   done_ff_2 <= 0;
   done_ff_1 <= 0;
   a_int <= 0;
   b_int <= 0;
   mult_ff_1 <= 0;
   mult_ff_2 <= 0;
   result<= 0;
  end   
  else begin 
   if(start) begin
    if (opcode == 4'b1001) begin
     a_int <= A;
     b_int <= B * A;

     mult_ff_1 <= b_int - a_int; // (A*B)-A
     mult_ff_2 <= mult_ff_1;
     result <= mult_ff_2; 

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end 
    else if (opcode == 4'b1010) begin
     a_int <= A*B;
     b_int <= A;
     mult_ff_1 <= a_int * 4; // (A * B * 4) - A
     mult_ff_2 <= mult_ff_1 - b_int;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end
    else if (opcode == 4'b1011) begin
     a_int <= A*B;
     b_int <= A;
     mult_ff_1 <= a_int + b_int; // (A * B) + A
     mult_ff_2 <= mult_ff_1 ;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end 
    else if (opcode == 4'b1100) begin
     a_int <= A;
     b_int <= B;

     mult_ff_1 <= a_int * 3; // A*3
     mult_ff_2 <= mult_ff_1;
     result <= mult_ff_2;

     done_ff_3 <= start & !done;
     done_ff_2 <= done_ff_3 & !done;
     done_ff_1 <= done_ff_2 & !done;
     done <= done_ff_1 & !done;
    end    
   end
   else begin
    a_int <= 0;
    b_int <= 0;
    result <= 0;
    done <= 0;
    done_ff_3 <= 0;
    done_ff_2 <= 0;
    done_ff_1 <= 0;
    mult_ff_1 <= 0;
    mult_ff_2 <= 0;
   end
  end  

endmodule : special_func


