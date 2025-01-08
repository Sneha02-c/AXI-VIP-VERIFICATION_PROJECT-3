class axi_s_seq extends uvm_sequence #(axi_xtn);

        `uvm_object_utils(axi_s_seq)

        extern function new(string name="axi_s_seq");
endclass

function axi_s_seq::new(string name="axi_s_seq");
        super.new(name);
endfunction

