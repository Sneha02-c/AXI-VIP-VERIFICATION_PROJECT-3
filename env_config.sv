class axi_env_config extends uvm_object;

        `uvm_object_utils(axi_env_config)

        bit has_sb=1;
        bit has_vseqr=1;
        bit has_magt=1;
        bit has_sagt=1;
        int no_of_slaves=1;
        int no_of_masters=1;
        bit has_int=1;

        axi_m_agt_config m_agt_cfg[];
        axi_s_agt_config s_agt_cfg[];

        int slave0_start_addr= 'h8000_0000;
        int slave0_end_addr= 'h8400_03ff;
        int slave1_start_addr= 'h8800_0000;
        int slave1_end_addr= 'h8c00_03ff;

        extern function new(string name="axi_env_config");
endclass

function axi_env_config::new(string name="axi_env_config");
        super.new(name);
endfunction



