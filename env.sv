class axi_env extends uvm_env;

        `uvm_component_utils(axi_env)

        axi_m_agt_top magt_top;
        axi_s_agt_top sagt_top;

        axi_v_seqr v_seqr;
        axi_interconnect int_h;
        axi_sb sb;
	//axi_scoreboard sb;
        axi_env_config m_cfg;

        extern function new(string name="axi_env",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
endclass

function axi_env::new(string name="axi_env",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_env::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
                `uvm_fatal("CONFIG","Cannot get env config from uvm_config_db.Have you set it?")
        $display("----%0d",m_cfg.no_of_masters);
        if(m_cfg.has_magt)
        begin
                //foreach(magt_top.magt_h[i])
        //      begin
        //              uvm_config_db #(axi_m_agt_config)::set(this,"magt_top*",$sformatf("m_agt_cfg[%0d]",i),m_cfg.m_agt_cfg[i]);
        //      end
                magt_top=axi_m_agt_top::type_id::create("magt_top",this);
        end

        if(m_cfg.has_sagt)
        begin
        //      foreach(sagt_top.sagt_h[i])
        //      begin
        //              uvm_config_db #(axi_s_agt_config)::set(this,"sagt_top*",$sformatf("s_agt_cfg[%0d]",i),m_cfg.s_agt_cfg[i]);
        //      end
                sagt_top=axi_s_agt_top::type_id::create("sagt_top",this);
        end

//      if(m_cfg.has_int)
                int_h=axi_interconnect::type_id::create("int_h",this);

        if(m_cfg.has_vseqr)
                v_seqr=axi_v_seqr::type_id::create("v_seqr",this);

        if(m_cfg.has_sb)
                sb=axi_sb::type_id::create("sb",this);
endfunction

function void axi_env::connect_phase(uvm_phase phase);
        if(m_cfg.has_vseqr)
        begin
                if(m_cfg.has_magt)
                begin
                        foreach(magt_top.magt_h[i])
                                v_seqr.m_seqrh[i]=magt_top.magt_h[i].seqr_m;
                end
                if(m_cfg.has_sagt)
                begin
                        foreach(sagt_top.sagt_h[i])
                                v_seqr.s_seqrh[i]=sagt_top.sagt_h[i].seqr_s;
                end

		if(m_cfg.has_sb)
                begin
                        //magt_top.magt_h.monitor_port_1.connect(sb.monitor_port_1.analysis_export);
                        //sagt_top.sagt_h.monitor_port_1.connect(sb.monitor_port_1.analysis_export);

                        foreach(magt_top.magt_h[i])
                                magt_top.magt_h[i].mon_m.mon_port.connect(sb.master_fifo[i].analysis_export);

                         foreach(sagt_top.sagt_h[i])
                                sagt_top.sagt_h[i].mon_s.mon_port.connect(sb.slave_fifo[i].analysis_export);

                end

        end
endfunction

