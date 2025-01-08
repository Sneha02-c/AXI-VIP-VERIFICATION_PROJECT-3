/*class axi_s_mon extends uvm_monitor;

        `uvm_component_utils(axi_s_mon)

        virtual axi_if.S_MON_MP vif;

        axi_s_agt_config sa_cfg;

          axi_xtn q1[$],q2[$],q3[$],q4[$],q5[$];
        semaphore semwa=new();
        semaphore semwr=new();
        semaphore semwd=new(1);
        semaphore semwr1=new(1);
        semaphore semwa1=new(1);
        semaphore semra=new();
        semaphore semra1=new(1);
        semaphore semrd=new(1);


        uvm_analysis_port #(axi_xtn) mon_port;

        extern function new(string name="axi_s_mon",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
/*      extern task run_phase(uvm_phase phase);
        extern task collect_data();
        extern task write_addr();
        extern task write_data();
        extern task write_resp();
        extern task read_addr();
        extern task read_data();
*/
/*endclass

function axi_s_mon::new(string name="axi_s_mon",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_s_mon::build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db #(axi_s_agt_config)::get(this,"","axi_s_agt_config",sa_cfg))
                `uvm_fatal("CONFIG","Cannot get mastet agent config from uvm_config_db.Have you set it?")

endfunction

function void axi_s_mon::connect_phase(uvm_phase phase);
        //super.connect_phase(phase);
        vif=sa_cfg.vif;
endfunction

/*task axi_s_mon::run_phase(uvm_phase phase);
        forever
        begin
                collect_data();
        end
endtask

task axi_s_mon::collect_data();

         fork
        begin
                semwa1.get(1);
                write_addr();
                semwa.put(1);
                semwa1.put(1);
        end

        begin
                semwa.get(1);
                semwd.get(1);
                write_data();
                semwd.put(1);
                semwr.put(1);
        end

        begin
                semwr.get(1);
                semwr1.get(1);
                write_resp();
                semwr1.put(1);
        end

        begin
                semra1.get(1);
                read_addr();
                semra.put(1);
                semra1.put(1);
        end

       begin
                semra.get(1);
                semrd.get(1);
                read_data();
                semrd.put(1);
        end

        join_any
endtask

task axi_s_mon::write_addr();
        axi_xtn xtn1;
        xtn1=axi_xtn::type_id::create("xtn1");
        //@(vif.m_mon_cb);
        wait(vif.s_mon_cb.awvalid && vif.s_mon_cb.awready)
        xtn1.awaddr=vif.s_mon_cb.awaddr;
        xtn1.awlen=vif.s_mon_cb.awlen;
        xtn1.awsize=vif.s_mon_cb.awsize;
        xtn1.awburst=vif.s_mon_cb.awburst;
        xtn1.awid=vif.s_mon_cb.awid;
        q1.push_back(xtn1);
        @(vif.s_mon_cb);
endtask

task axi_s_mon::write_data();
        axi_xtn xtn2;
        xtn2=axi_xtn::type_id::create("xtn2");
        xtn2=q1.pop_front();
        xtn2.wdata =new [xtn2.awlen+1];
        xtn2.wstrb =new [xtn2.awlen+1];
         // @(vif.m_mon_cb);
        //wait(vif.m_mon_cb.wvalid&&vif.m_mon_cb.wready)
        //wait(vif.m_mon_cb.wvalid)

        foreach(xtn2.wdata[i])
        begin
                wait(vif.s_mon_cb.wvalid && vif.s_mon_cb.wready)

                xtn2.wstrb[i]=vif.s_mon_cb.wstrb;
                if(vif.s_mon_cb.wstrb[i]==4'b0001)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[7:0];
                if(vif.s_mon_cb.wstrb[i]==4'b0010)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[15:8];
                if(vif.s_mon_cb.wstrb[i]==4'b0100)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[23:16];
                if(vif.s_mon_cb.wstrb[i]==4'b1000)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[31:24];
                if(vif.s_mon_cb.wstrb[i]==4'b0011)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[15:0];
                if(vif.s_mon_cb.wstrb[i]==4'b1100)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[31:16];
                if(vif.s_mon_cb.wstrb[i]==4'b1111)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[31:0];
               /* if(vif.s_drv_cb.wstrb[i]==4'b0111)
                        xtn2.wdata[i]=vif.m_mon_cb.wdata[23:0];*/
  /*              if(vif.s_mon_cb.wstrb[i]==4'b1110)
                        xtn2.wdata[i]=vif.s_mon_cb.wdata[31:8];


                xtn2.wid=vif.s_mon_cb.wid;
                xtn2.wlast=vif.s_mon_cb.wlast;
                @(vif.s_mon_cb);
        end
endtask
task axi_s_mon::write_resp();
        axi_xtn xtn3;
        xtn3=axi_xtn::type_id::create("xtn3");
        wait(vif.s_mon_cb.bvalid && vif.s_mon_cb.bready)
        xtn3.bid=vif.s_mon_cb.bid;
        xtn3.bresp=vif.s_mon_cb.bresp;
endtask

task axi_s_mon::read_addr();
        axi_xtn xtn4;
        xtn4=axi_xtn::type_id::create("xtn4");
        wait(vif.s_mon_cb.arvalid && vif.s_mon_cb.arready)
        xtn4.araddr=vif.s_mon_cb.araddr;
        xtn4.arlen=vif.s_mon_cb.arlen;
        xtn4.arsize=vif.s_mon_cb.arsize;
        xtn4.arburst=vif.s_mon_cb.arburst;
        xtn4.arid=vif.s_mon_cb.arid;
        q2.push_back(xtn4);
        @(vif.s_mon_cb);
endtask

task axi_s_mon::read_data();
        axi_xtn xtn5;
        xtn5=axi_xtn::type_id::create("xtn5");
        xtn5=q2.pop_front();
        xtn5.rdata=new[xtn5.arlen+1];
        foreach(xtn5.rdata[i])
        begin
                wait(vif.s_mon_cb.rvalid && vif.s_mon_cb.rready)
                xtn5.rresp[i]=vif.s_mon_cb.rresp;
                xtn5.rdata[i]=vif.s_mon_cb.rdata;
                xtn5.rid=vif.s_mon_cb.rid;
                xtn5.rlast=vif.s_mon_cb.rlast;
                @(vif.s_mon_cb);
        end
endtask
*/


class axi_s_mon extends uvm_monitor;

        `uvm_component_utils(axi_s_mon)

        virtual axi_if.S_MON_MP vif;

        axi_s_agt_config sa_cfg;



        axi_xtn q1[$],q2[$],q3[$],q4[$],q5[$];
        semaphore semwa=new();
        semaphore semwr=new();
        semaphore semwd=new(1);
        semaphore semwr1=new(1);
        semaphore semwa1=new(1);
        semaphore semra=new();
        semaphore semra1=new(1);
        semaphore semrd=new(1);

        uvm_analysis_port #(axi_xtn) mon_port;

        extern function new(string name="axi_s_mon",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task collect_data();
        extern task write_addr();
        extern task write_data(axi_xtn xtn1);
        extern task write_resp();
        extern task read_addr();
        extern task read_data(axi_xtn xtn2);

endclass

function axi_s_mon::new(string name="axi_s_mon",uvm_component parent);
        super.new(name,parent);
 mon_port=new("mon_port",this);

endfunction

function void axi_s_mon::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_s_agt_config)::get(this,"","axi_s_agt_config",sa_cfg))
                `uvm_fatal("CONFIG","Cannot get slave agent config from uvm_config_db.Have you set it?")
endfunction

function void axi_s_mon::connect_phase(uvm_phase phase);
        vif=sa_cfg.vif;
endfunction

task axi_s_mon::run_phase(uvm_phase phase);
        forever
        begin
                collect_data();
        end
endtask

task axi_s_mon::collect_data();

         fork
        begin
                semwa1.get(1);
                write_addr();
                semwa.put(1);
                semwa1.put(1);
        end

        begin
                semwa.get(1);
                semwd.get(1);
                write_data(q1.pop_front());
                semwd.put(1);
                semwr.put(1);
        end

        begin
                semwr.get(1);
                semwr1.get(1);
                write_resp();
                semwr1.put(1);
        end

        begin
                semra1.get(1);
                read_addr();
                semra.put(1);
                semra1.put(1);
        end

       begin
                semra.get(1);
                semrd.get(1);
                read_data(q2.pop_front());
                semrd.put(1);
        end

        join_any
endtask

task axi_s_mon::write_addr();
	axi_xtn xtn;
        
  //	`uvm_info("SLAVE WRITE ADDR","START",UVM_LOW)
	xtn=axi_xtn::type_id::create("xtn");
        @(vif.s_mon_cb);
        wait(vif.s_mon_cb.awvalid && vif.s_mon_cb.awready)
        begin
                xtn.awaddr=vif.s_mon_cb.awaddr;
        xtn.awlen=vif.s_mon_cb.awlen;
        xtn.awsize=vif.s_mon_cb.awsize;
        xtn.awburst=vif.s_mon_cb.awburst;
        xtn.awid=vif.s_mon_cb.awid;

                xtn.awready=vif.s_mon_cb.awready;
                xtn.awvalid=vif.s_mon_cb.awvalid;
                end
                wait(!vif.s_mon_cb.awvalid && !vif.s_mon_cb.awready);

                q1.push_back(xtn);
        // `uvm_info("S_WADDR",$sformatf("Printing from slave monitor \n %s",xtn.sprint()),UVM_LOW)
	mon_port.write(xtn);
                //@(vif.s_mon_cb);
//	`uvm_info("SLAVE WRITE ADDR","END",UVM_LOW)
endtask

task axi_s_mon::write_data(axi_xtn xtn1);
        axi_xtn xtn;
  //      `uvm_info("SLAVE WRITE DATA","START",UVM_LOW)
	xtn=axi_xtn::type_id::create("xtn");
        //xtn=q1.pop_front();
        xtn.wdata =new [xtn1.awlen+1];
        xtn.wstrb =new [xtn1.awlen+1];
         // @(vif.s_mon_cb);
        //wait(vif.s_mon_cb.wvalid&&vif.s_mon_cb.wready)
        //wait(vif.s_mon_cb.wvalid)

        foreach(xtn.wdata[i])
        begin
                @(vif.s_mon_cb);
                                wait(vif.s_mon_cb.wvalid && vif.s_mon_cb.wready);
                begin
        /*                        xtn.wstrb[i]=vif.s_mon_cb.wstrb;
                if(vif.s_mon_cb.wstrb[i]==4'b0001)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[7:0];
                if(vif.s_mon_cb.wstrb[i]==4'b0010)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[15:8];
                if(vif.s_mon_cb.wstrb[i]==4'b0100)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[23:16];
                if(vif.s_mon_cb.wstrb[i]==4'b1000)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[31:24];
                if(vif.s_mon_cb.wstrb[i]==4'b0011)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[15:0];
                if(vif.s_mon_cb.wstrb[i]==4'b1100)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[31:16];
                if(vif.s_mon_cb.wstrb[i]==4'b1111)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[31:0];
               /* if(vif.s_drv_cb.wstrb[i]==4'b0111)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[23:0];*/
               /* if(vif.s_mon_cb.wstrb[i]==4'b1110)
                        xtn.wdata[i]=vif.s_mon_cb.wdata[31:8];*/
		xtn.wdata[i]=vif.s_mon_cb.wdata;
		xtn.wstrb[i]=vif.s_mon_cb.wstrb;
                xtn.wid=vif.s_mon_cb.wid;
                xtn.wlast=vif.s_mon_cb.wlast;
                                xtn.wvalid=vif.s_mon_cb.wvalid;
                                xtn.wready=vif.s_mon_cb.wready;
                                end
                end
	// `uvm_info("S_WDATA",$sformatf("Printing from slave monitor \n %s",xtn.sprint()),UVM_LOW)
        //        wait(!vif.s_mon_cb.wvalid && !vif.s_mon_cb.wready);
              mon_port.write(xtn);
//	`uvm_info("SLAVE WRITE DATA","END",UVM_LOW)
endtask

task axi_s_mon::write_resp();
        axi_xtn xtn;
        
//	`uvm_info("SLAVE WRITE RESP","START",UVM_LOW)
	xtn=axi_xtn::type_id::create("xtn");
        @(vif.s_mon_cb);
                wait(vif.s_mon_cb.bvalid && vif.s_mon_cb.bready);
        begin
                xtn.bid=vif.s_mon_cb.bid;
        xtn.bresp=vif.s_mon_cb.bresp;

                xtn.bvalid=vif.s_mon_cb.bvalid;
                xtn.bready=vif.s_mon_cb.bready;
                end
	// `uvm_info("S_BRESP",$sformatf("Printing from slave monitor \n %s",xtn.sprint()),UVM_LOW)
        //        wait(!vif.s_mon_cb.bvalid && !vif.s_mon_cb.bready);
              mon_port.write(xtn);
//	`uvm_info("SLAVE WRITE RESP","END",UVM_LOW)
endtask


task axi_s_mon::read_addr();
        axi_xtn xtn;
  //      `uvm_info("SLAVE READ ADDR","START",UVM_LOW)
	xtn=axi_xtn::type_id::create("xtn");
        @(vif.s_mon_cb);
                wait(vif.s_mon_cb.arvalid && vif.s_mon_cb.arready);
        begin
                xtn.araddr=vif.s_mon_cb.araddr;
        xtn.arlen=vif.s_mon_cb.arlen;
        xtn.arsize=vif.s_mon_cb.arsize;
        xtn.arburst=vif.s_mon_cb.arburst;
        xtn.arid=vif.s_mon_cb.arid;

                xtn.arvalid=vif.s_mon_cb.arvalid;
                xtn.arready=vif.s_mon_cb.arready;
                end
                wait(!vif.s_mon_cb.arvalid && !vif.s_mon_cb.arready);
                q2.push_back(xtn);
	// `uvm_info("S_RADDR",$sformatf("Printing from slave monitor \n %s",xtn.sprint()),UVM_LOW)
        mon_port.write(xtn);
//	`uvm_info("SLAVE READ ADDR","START",UVM_LOW)
endtask

task axi_s_mon::read_data(axi_xtn xtn2);
        axi_xtn xtn;
//	`uvm_info("SLAVE READ DATA","START",UVM_LOW)
        xtn=axi_xtn::type_id::create("xtn");
        //xtn=q2.pop_front();
        xtn.rdata=new[xtn2.arlen+1];
        xtn.rresp=new[xtn2.arlen+1];
        foreach(xtn.rdata[i])
        begin
                @(vif.s_mon_cb);
                wait(vif.s_mon_cb.rvalid && vif.s_mon_cb.rready);
                begin
                xtn.rresp[i]=vif.s_mon_cb.rresp;
                xtn.rdata[i]=vif.s_mon_cb.rdata;
                xtn.rid=vif.s_mon_cb.rid;
                xtn.rlast=vif.s_mon_cb.rlast;

                xtn.rvalid=vif.s_mon_cb.rvalid;
                xtn.rready=vif.s_mon_cb.rready;
                end
        //        wait(!vif.s_mon_cb.rvalid && !vif.s_mon_cb.rready);
        end
	// `uvm_info("S_RDATA",$sformatf("Printing from slave monitor \n %s",xtn.sprint()),UVM_LOW)
              mon_port.write(xtn);
//	`uvm_info("SLAVE READ DATA","END",UVM_LOW)
endtask



