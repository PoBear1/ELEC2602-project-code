module pmem_block #(
    parameter ptr_width = 16,
    parameter opcode_size = 32,
    parameter mem_len = 1 << ptr_width
) (
    input [ptr_width - 1:0] addr,
    output [opcode_size - 1:0] w
);
    reg[opcode_size - 1:0] mem[0:mem_len - 1];
    initial begin
        $readmemb("assembly/program.hex", mem);
    end
    assign w = mem[addr];
endmodule
