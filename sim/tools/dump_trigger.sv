module dump_trigger;
    initial begin
        // Use the macro provided by the compiler
        $dumpfile(`DUMP_FILE);
        $dumpvars(0);
    end
endmodule
