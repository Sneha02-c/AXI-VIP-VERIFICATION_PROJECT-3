module top;

        import axi_test_pkg::*;
        import uvm_pkg::*;

        bit clock;

        always
                #10 clock=~clock;

        axi_if in0_m(clock);
        axi_if in1_m(clock);
        axi_if in0_s(clock);
        axi_if in1_s(clock);

        initial
        begin
                uvm_config_db #(virtual axi_if)::set(null,"*","vif_m0",in0_m);
                uvm_config_db #(virtual axi_if)::set(null,"*","vif_m1",in1_m);
                uvm_config_db #(virtual axi_if)::set(null,"*","vif_s0",in0_s);
                uvm_config_db #(virtual axi_if)::set(null,"*","vif_s1",in1_s);

                run_test();
        end
endmodule

