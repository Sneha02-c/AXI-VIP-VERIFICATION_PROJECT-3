class axi_v_seqr extends uvm_sequencer #(uvm_sequence_item);

        `uvm_component_utils(axi_v_seqr)

        axi_m_seqr m_seqrh[];
        axi_s_seqr s_seqrh[];

        axi_env_config m_cfg;

extern function new(string name="axi_v_seqr",uvm_component parent);
extern function void build_phase(uvm_phase phase);


endclass


        
function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_v_seqr::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
                `uvm_fatal("CONFIG","Cannot get env config from uvm_config_db.Have you set it?")
        m_seqrh=new[m_cfg.no_of_masters];
        s_seqrh=new[m_cfg.no_of_slaves];
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

function axi_v_seqr::new(string name="axi_v_seqr",uvm_component parent);
        super.new(name,parent);
endfunction

