class axi_s_drv extends uvm_driver #(axi_xtn);

        `uvm_component_utils(axi_s_drv)

        virtual axi_if.S_DRV_MP vif;

        axi_s_agt_config sa_cfg;
        axi_xtn xtn;
        axi_xtn wd_q[$],wr_q[$],rd_q[$];
        bit [31:0] addr[$];
        bit [3:0] len[$];
        bit [2:0] s[$];
        bit [1:0] burst[$];
        bit [3:0] id[$];

        semaphore semwa=new();
        semaphore semwr=new();
        semaphore semwd=new(1);
        semaphore semwr1=new(1);
        semaphore semwa1=new(1);
        semaphore semra=new();
        semaphore semra1=new(1);
        semaphore semrd=new(1);

        extern function new(string name="axi_s_drv",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task drive();
        extern task drive_awaddr();
        extern task drive_wdata(axi_xtn xtn);
        extern task drive_bresp(axi_xtn xtn);
        extern task drive_araddr();
        extern task drive_rdata(axi_xtn xtn);

endclass

function axi_s_drv::new(string name="axi_s_drv",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_s_drv::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_s_agt_config)::get(this,"","axi_s_agt_config",sa_cfg))
                `uvm_fatal("CONFIG","Cannot get slave agent config from uvm_config_db.Have you set it?")
endfunction

function void axi_s_drv::connect_phase(uvm_phase phase);
        vif=sa_cfg.vif;
endfunction

task axi_s_drv::run_phase(uvm_phase phase);
        forever
        begin
                drive();
        end
endtask

task axi_s_drv::drive();
        fork
        begin
                semwa1.get(1);
                drive_awaddr();
                semwa.put(1);
                semwa1.put(1);
        end

       begin
                semwa.get(1);
                semwd.get(1);
                drive_wdata(wd_q.pop_front());
                semwd.put(1);
                semwr.put(1);
        end

        begin
                semwr.get(1);
                semwr1.get(1);
                drive_bresp(wr_q.pop_front());
                semwr1.put(1);
        end

        begin
                semra1.get(1);
                drive_araddr();
                semra.put(1);
                semra1.put(1);
        end

        begin
                semra.get(1);
                semrd.get(1);
                drive_rdata(rd_q.pop_front());
                semrd.put(1);
        end
        join_any
endtask

task axi_s_drv::drive_awaddr();
//         `uvm_info("slave WRITE ADDRESS","START",UVM_LOW)
        xtn=axi_xtn::type_id::create("xtn");
        @(vif.s_drv_cb);
        vif.s_drv_cb.awready <= 1'b1;
        @(vif.s_drv_cb);
        wait(vif.s_drv_cb.awvalid)
//      $display("awvalid is high");

        xtn.awlen = vif.s_drv_cb.awlen;
        xtn.awsize = vif.s_drv_cb.awsize;
        xtn.awburst = vif.s_drv_cb.awburst;
        xtn.awid = vif.s_drv_cb.awid;
        xtn.awaddr = vif.s_drv_cb.awaddr;
        wd_q.push_back(xtn);
        wr_q.push_back(xtn);

//repeat(2)
@(vif.s_drv_cb);

        vif.s_drv_cb.awready <= 1'b0;
  //       `uvm_info("slave WRITE ADDRESS","END",UVM_LOW)

endtask
task axi_s_drv::drive_wdata(axi_xtn xtn);
//        int mem[int];

    //    `uvm_info("slave WRITE DATA","START",UVM_LOW)
	 if((xtn.awaddr >'h8c00_03ff) || (xtn.awaddr < 'h8000_0000))
                begin
                        repeat(4)
                        @(vif.s_drv_cb);
                        return;
                end
                else
                begin
                        int mem[int];

                        xtn.addr_cal();

       // xtn.addr_cal();
        for(int i=0;i<=xtn.awlen;i++)
        begin
                vif.s_drv_cb.wready <= 1'b1;
                //repeat(2)
                @(vif.s_drv_cb);
                wait(vif.s_drv_cb.wvalid)
                if(vif.s_drv_cb.wstrb[i]==4'b0001)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[7:0];
                if(vif.s_drv_cb.wstrb[i]==4'b0010)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[15:8];
                if(vif.s_drv_cb.wstrb[i]==4'b0100)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[23:16];
                if(vif.s_drv_cb.wstrb[i]==4'b1000)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[31:24];
                if(vif.s_drv_cb.wstrb[i]==4'b0011)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[15:0];
                if(vif.s_drv_cb.wstrb[i]==4'b1100)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[31:16];
                if(vif.s_drv_cb.wstrb[i]==4'b1111)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[31:0];
                if(vif.s_drv_cb.wstrb[i]==4'b0111)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[23:0];
                if(vif.s_drv_cb.wstrb[i]==4'b1110)
                        mem[xtn.addr[i]] = vif.s_drv_cb.wdata[31:7];

                vif.s_drv_cb.wready <= 1'b0;
//                repeat(2)
                @(vif.s_drv_cb);
        end
	end
      //  `uvm_info("slave WRITE DATA","END",UVM_LOW)

endtask

task axi_s_drv::drive_bresp(axi_xtn xtn);
        // `uvm_info("slave WRITE RESP",$sformatf("START awid = %h",xtn.awid),UVM_LOW)

        vif.s_drv_cb.bresp <= $urandom_range(0,3);
        vif.s_drv_cb.bvalid <= 1'b1;
        vif.s_drv_cb.bid <= xtn.awid;
        @(vif.s_drv_cb);


        wait(vif.s_drv_cb.bready)
        vif.s_drv_cb.bvalid <= 1'b0;

//      repeat(2)
        @(vif.s_drv_cb);
        // `uvm_info("slave WRITE RESP","END",UVM_LOW)

endtask

task axi_s_drv::drive_araddr();
       // `uvm_info("slave READ ADDRESS","START",UVM_LOW)
        xtn=axi_xtn::type_id::create("xtn");
        @(vif.s_drv_cb);
        vif.s_drv_cb.arready <= 1'b1;
        //@(vif.s_drv_cb);
        wait(vif.s_drv_cb.arvalid)
        //$display("arvalid is high");
        xtn.arlen = vif.s_drv_cb.arlen;
        xtn.arsize = vif.s_drv_cb.arsize;
        xtn.arburst = vif.s_drv_cb.arburst;
        xtn.arid = vif.s_drv_cb.arid;
        xtn.araddr = vif.s_drv_cb.araddr;
        len.push_back(vif.s_drv_cb.arlen);
        addr.push_back(vif.s_drv_cb.araddr);
        burst.push_back(vif.s_drv_cb.arburst);
        s.push_back(vif.s_drv_cb.arsize);
        id.push_back(vif.s_drv_cb.arid);
//      $display("----------------------------------------------arid=%0d",vif.s_drv_cb.arid);
        rd_q.push_back(xtn);
        //repeat(2)
        @(vif.s_drv_cb);
        vif.s_drv_cb.arready <= 1'b0;

//`uvm_info("slave READ ADDRESS","END",UVM_LOW)
endtask

task axi_s_drv::drive_rdata(axi_xtn xtn);
        int len1;
        //axi_xtn xtn;
        //xtn=axi_xtn::type_id::create("xtn");
//      xtn=rd_q.pop_front();
  //      `uvm_info("slave READ DATA","START",UVM_LOW)
         if((xtn.araddr > 'h8c00_03ff) || (xtn.araddr < 'h8000_0000))
                begin
                        repeat(2)
                        @(vif.s_drv_cb);
                        return;
                end

                else
                begin


	len1=xtn.arlen;
        vif.s_drv_cb.rid <= xtn.arid;
//      $display("---------------------------------------------rid=%0d",vif.s_drv_cb.rid);
        for(int i=0;i<=len1;i++)
        begin
                //$display("value of i %0d",i);
                vif.s_drv_cb.rdata <= $urandom;
                vif.s_drv_cb.rresp <= $urandom_range(0,3);
                vif.s_drv_cb.rvalid <= 1'b1;
                if(i < len1)
                         vif.s_drv_cb.rlast <= 1'b0;
                else
                        vif.s_drv_cb.rlast <= 1'b1;

                @(vif.s_drv_cb);
                wait(vif.s_drv_cb.rready)
                vif.s_drv_cb.rvalid <= 1'b0;
                vif.s_drv_cb.rlast <= 1'b0;
                //vif.s_drv_cb.rresp <= 2'bz;

              repeat(2)
                @(vif.s_drv_cb);

        end
	end
    //    `uvm_info("slave READ DATA","END",UVM_LOW)
endtask

