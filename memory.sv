module Memory #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 11)
              (
                input logic rst_n,
              input logic clk,        // Clock input
               input logic rst,        // Reset input
               input logic start,      // Start signal input
               output logic done,      // Done signal output
               input logic [ADDR_WIDTH-1:0] addr, // Address input
               input logic we,         // Write enable input
               input logic [DATA_WIDTH-1:0] data_in, // Data input for writing
               output logic [DATA_WIDTH-1:0] data_out
               ); // Data output for reading

    // Internal memory array
    logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];
    logic write_operation;

    always_ff @(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Reset the memory to 0s
            for (int i = 0; i < 2**ADDR_WIDTH; i = i+1)
                mem[i] <= '0;
            done <= 0;
            write_operation <= 0;
        end
        else begin                           // Start operation
            if (start) begin
                if (!we) begin
                // Read operation
                    $display("Checking Memory Read Operation = %0h", mem[addr]);
                    data_out <= mem[addr];
                end
                else begin                    // Write operation
                $display("[Write Operation]in the loop");
                    mem[addr] <= data_in;
                    write_operation <= 1;
                end
            end
            else if (write_operation) begin   // Indicate completion of write operation
                done <= 1;
                write_operation <= 0;
            end
            else
                done <= 0;
        end
    end
endmodule

