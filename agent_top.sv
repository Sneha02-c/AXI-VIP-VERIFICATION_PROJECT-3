class axi_s_agt_top extends uvm_env;

        `uvm_component_utils(axi_s_agt_top)

        axi_s_agt sagt_h[];
        axi_s_agt_config sa_cfg[];
        axi_env_config e_cfg;

        extern function new(string name="axi_s_agt_top",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function axi_s_agt_top::new(string name="axi_s_agt_top",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_s_agt_top::build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",e_cfg))
                `uvm_fatal("CONFIG","Cannot get env_config from uvm_config_db.Have you set it?")
        sagt_h=new[e_cfg.no_of_slaves];
        sa_cfg=new[e_cfg.no_of_slaves];
        foreach(sagt_h[i])
        begin
                sa_cfg[i]=axi_s_agt_config::type_id::create($sformatf("sa_cfg[%0d]",i));
                sa_cfg[i]=e_cfg.s_agt_cfg[i];
                sagt_h[i]=axi_s_agt::type_id::create($sformatf("sagt_h[%0d])",i),this);
                uvm_config_db #(axi_s_agt_config)::set(this,$sformatf("sagt_h[%0d]*",i),"axi_s_agt_config",e_cfg.s_agt_cfg[i]);

        end

endfunction

task axi_s_agt_top::run_phase(uvm_phase phase);
        uvm_top.print_topology();
endtask


