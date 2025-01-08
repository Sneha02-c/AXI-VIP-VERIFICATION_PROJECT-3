class axi_s_seqr extends uvm_sequencer #(axi_xtn);

        `uvm_component_utils(axi_s_seqr)

        extern function new(string name="axi_s_seqr",uvm_component parent);
endclass

function axi_s_seqr::new(string name="axi_s_seqr",uvm_component parent);
        super.new(name,parent);
endfunction



