class axi_base_test extends uvm_test;

        `uvm_component_utils(axi_base_test)

        axi_env env_h;
        axi_env_config m_cfg;

        axi_m_agt_config m_agt_cfg[];
        axi_s_agt_config s_agt_cfg[];

        int has_magt=1;
        int has_sagt=1;
        int no_of_masters=2;
        int no_of_slaves=2;
        int no_of_agent=1;

        extern function new(string name="axi_base_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
//      extern function void axi_config();
endclass

function axi_base_test::new(string name="axi_base_test",uvm_component parent);
        super.new(name,parent);
endfunction

/*function void axi_base_test::axi_config();
        if(has_magt)
        begin
                m_agt_cfg=new[no_of_masters];
                m_cfg.m_agt_cfg=new[no_of_masters];
                foreach(m_agt_cfg[i])
                begin

                        m_agt_cfg[i]=axi_m_agt_config::type_id::create($sformatf("m_agt_cfg[%0d]",i));

                        m_agt_cfg[i].is_active=UVM_ACTIVE;
                        if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_m%0d",i),m_agt_cfg[i].vif))
                                `uvm_fatal("VIF CONFIG","Cannot get interface from uvm_config_db.Have you set it?")
                        m_cfg.m_agt_cfg[i]=m_agt_cfg[i];
                        m_agt_cfg[i].no_of_masters=no_of_masters;
                end
        end

        if(has_sagt)
        begin
                s_agt_cfg=new[no_of_slaves];
                foreach(s_agt_cfg[i])
                begin
                        s_agt_cfg[i]=axi_s_agt_config::type_id::create($sformatf("s_agt_cfg[%0d]",i));
                        if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_s%0d",i),s_agt_cfg[i].vif))
                                `uvm_fatal("VIF CONFIG","Cannot get interface from uvm_config_db.Have you set it?")
                        s_agt_cfg[i].is_active=UVM_ACTIVE;
                        m_cfg.s_agt_cfg[i]=s_agt_cfg[i];
                        s_agt_cfg[i].no_of_slaves=no_of_slaves;
                end
        end

        m_cfg.has_magt=has_magt;
        m_cfg.has_sagt=has_sagt;
        m_cfg.has_sb=1;
        m_cfg.no_of_slaves=no_of_slaves;
        m_cfg.no_of_masters=no_of_masters;
endfunction*/

function void axi_base_test::build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_cfg=axi_env_config::type_id::create("m_cfg");

        if(has_magt)
        begin
                //m_cfg.m_agt_cfg=new[no_of_masters];
                 m_agt_cfg=new[no_of_masters];
                m_cfg.m_agt_cfg=new[no_of_masters];
                foreach(m_agt_cfg[i])
                begin
                        //$display("%d",i);
                        m_agt_cfg[i]=axi_m_agt_config::type_id::create($sformatf("m_agt_cfg[%0d]",i));

                        m_agt_cfg[i].is_active=UVM_ACTIVE;
                        if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_m%0d",i),m_agt_cfg[i].vif))
                                `uvm_fatal("VIF CONFIG","Cannot get interface from uvm_config_db.Have you set it?")
                        m_cfg.m_agt_cfg[i]=m_agt_cfg[i];
                       // m_agt_cfg[i].no_of_masters=no_of_masters;
                end
        end
        if(has_sagt)
        begin
                m_cfg.s_agt_cfg=new[no_of_slaves];
                s_agt_cfg=new[no_of_slaves];
                foreach(s_agt_cfg[i])
                begin
                        s_agt_cfg[i]=axi_s_agt_config::type_id::create($sformatf("s_agt_cfg[%0d]",i));
                        if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_s%0d",i),s_agt_cfg[i].vif))
                                `uvm_fatal("VIF CONFIG","Cannot get interface from uvm_config_db.Have you set it?")
                        s_agt_cfg[i].is_active=UVM_ACTIVE;
                        m_cfg.s_agt_cfg[i]=s_agt_cfg[i];
                        s_agt_cfg[i].no_of_slaves=no_of_slaves;
                end

        end
        //axi_config();

                m_cfg.has_magt=has_magt;
        m_cfg.has_sagt=has_sagt;
        m_cfg.has_sb=1;
        m_cfg.no_of_slaves=no_of_slaves;
        m_cfg.no_of_masters=no_of_masters;
        uvm_config_db #(axi_env_config)::set(this,"*","axi_env_config",m_cfg);
        env_h=axi_env::type_id::create("env_h",this);


endfunction

class m0s0_m1s1_test extends axi_base_test;

        `uvm_component_utils(m0s0_m1s1_test)

        m0s0_m1s1_vseq seqh;

        extern function new(string name="m0s0_m1s1_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function m0s0_m1s1_test::new(string name="m0s0_m1s1_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void m0s0_m1s1_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task m0s0_m1s1_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=m0s0_m1s1_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask


class m0s1_m1s0_test extends axi_base_test;

        `uvm_component_utils(m0s1_m1s0_test)

        m0s1_m1s0_vseq seqh;

        extern function new(string name="m0s1_m1s0_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function m0s1_m1s0_test::new(string name="m0s1_m1s0_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void m0s1_m1s0_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task m0s1_m1s0_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=m0s1_m1s0_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask


class m0s0_m1s0_test extends axi_base_test;

        `uvm_component_utils(m0s0_m1s0_test)

        m0s0_m1s0_vseq seqh;

        extern function new(string name="m0s0_m1s0_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function m0s0_m1s0_test::new(string name="m0s0_m1s0_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void m0s0_m1s0_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task m0s0_m1s0_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=m0s0_m1s0_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask


class m0s1_m1s1_test extends axi_base_test;

        `uvm_component_utils(m0s1_m1s1_test)

        m0s1_m1s1_vseq seqh;

        extern function new(string name="m0s1_m1s1_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function m0s1_m1s1_test::new(string name="m0s1_m1s1_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void m0s1_m1s1_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task m0s1_m1s1_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=m0s1_m1s1_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask
//////////////////////////////////////////////////////////////////////////////////////////////////
class dec_err_test extends axi_base_test;

        `uvm_component_utils(dec_err_test)

        dec_err_vseq seqh;

        extern function new(string name="dec_err_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function dec_err_test::new(string name="dec_err_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void dec_err_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task dec_err_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=dec_err_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask

class burst_three_test extends axi_base_test;

        `uvm_component_utils(burst_three_test)

        burst_three_vseq seqh;

        extern function new(string name="burst_three_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function burst_three_test::new(string name="burst_three_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void burst_three_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task burst_three_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=burst_three_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask

class m0s1_m1s11_test extends axi_base_test;

        `uvm_component_utils(m0s1_m1s11_test)

         masterslave_vseq seqh;

        extern function new(string name="m0s1_m1s11_test",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function m0s1_m1s11_test::new(string name="m0s1_m1s11_test",uvm_component parent);
        super.new(name,parent);
endfunction

function void m0s1_m1s11_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task m0s1_m1s11_test::run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seqh=masterslave_vseq::type_id::create("seqh");
        seqh.start(env_h.v_seqr);
        #5000;
        phase.drop_objection(this);
endtask

