class axi_s_agt extends uvm_agent;

        `uvm_component_utils(axi_s_agt)

        axi_s_agt_config sa_cfg;

        axi_s_drv drv_s;
        axi_s_mon mon_s;
        axi_s_seqr seqr_s;

        extern function new(string name="axi_s_agt",uvm_component parent=null);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
endclass

function axi_s_agt::new(string name="axi_s_agt",uvm_component parent=null);
        super.new(name,parent);
endfunction

function void axi_s_agt::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_s_agt_config)::get(this,"","axi_s_agt_config",sa_cfg))
                `uvm_fatal("CONFIG","Cannot get slave agent config from uvm_config_db. Have you set it?")

        mon_s=axi_s_mon::type_id::create("mon_s",this);

        if(sa_cfg.is_active==UVM_ACTIVE)
        begin
                drv_s=axi_s_drv::type_id::create("drv_s",this);
                seqr_s=axi_s_seqr::type_id::create("seqr_s",this);
        end
endfunction

function void axi_s_agt::connect_phase(uvm_phase phase);
        if(sa_cfg.is_active==UVM_ACTIVE)
                drv_s.seq_item_port.connect(seqr_s.seq_item_export);
endfunction

