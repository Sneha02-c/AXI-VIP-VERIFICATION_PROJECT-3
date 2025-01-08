class axi_s_agt_config extends uvm_object;

        `uvm_object_utils(axi_s_agt_config)

        virtual axi_if vif;
        int no_of_slaves=2;
        uvm_active_passive_enum is_active=UVM_ACTIVE;

        extern function new(string name="axi_s_agt_config");
endclass

function axi_s_agt_config::new(string name="axi_s_agt_config");
        super.new(name);
endfunction


