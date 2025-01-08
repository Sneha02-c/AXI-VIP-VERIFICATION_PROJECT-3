class axi_interconnect extends uvm_component;

        `uvm_component_utils(axi_interconnect)

        virtual axi_if.INTR_CNT_MP vif_mst[];
        virtual axi_if.INTR_CNT_MP vif_slv[];

        semaphore sem=new(1);
        semaphore sem1=new(1);
        semaphore sem2=new(1);
        semaphore sem3=new(1);
        semaphore sem4=new(1);
        semaphore sem5=new(1);
        semaphore sem6=new(1);
        semaphore sem7=new(1);
        semaphore sem8=new(1);
        semaphore sem9=new(1);

        int mst_write_array[int];
        int slv_write_response[int];
        int slv_read_response[int];
        int awlength[int];
        int arlength[int];

        axi_env_config e_cfg;

        extern function new(string name="axi_interconnect", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task mst_waddr_channel(int j);
        extern task mst_wdata_channel(int j);
        extern task mst_wresp_channel(int k);
        extern task mst_raddr_channel(int j);
        extern task mst_rdata_channel(int k);

endclass

function axi_interconnect::new(string name="axi_interconnect",uvm_component parent);
        super.new(name,parent);
endfunction

function void axi_interconnect:: build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",e_cfg))
                `uvm_fatal("CONFIG","Cannot get env_config from uvm_config_db.Have you set it?")

        vif_mst=new[e_cfg.no_of_masters];
        vif_slv=new[e_cfg.no_of_slaves];
endfunction

function void axi_interconnect::connect_phase(uvm_phase phase);

        foreach(vif_mst[i])
        begin
                vif_mst[i]=e_cfg.m_agt_cfg[i].vif;
        end

        foreach(vif_slv[i])
        begin
                vif_slv[i]=e_cfg.s_agt_cfg[i].vif;
        end
endfunction

task axi_interconnect::run_phase(uvm_phase phase);

        $display("**************INSIDE INTERCONNECT**************");

        begin
        fork
                begin:block_1;
                        for(int i=0;i<e_cfg.no_of_masters;i++)
                        begin
                                automatic int j=i;
                                fork
                                        mst_waddr_channel(j);
                                join_none
                        end
                end

                begin:block_2;
                        for(int i=0;i<e_cfg.no_of_masters;i++)
                        begin
                                automatic int j=i;
                                fork
                                        mst_wdata_channel(j);
                                join_none 
                        end
                end

                begin:block_3;
                        for(int n=0;n<e_cfg.no_of_slaves;n++)
                        begin
                                automatic int k=n;
                                fork
                                        mst_wresp_channel(k);
                                join_none
                        end
                end

                begin:block_4;
                        for(int i=0;i<e_cfg.no_of_masters;i++)
                        begin
                                automatic int j=i;
                                fork
                                        mst_raddr_channel(j);
                                join_none
                        end
                end

                begin:block_5;
                        for(int n=0;n<e_cfg.no_of_slaves;n++)
                        begin
                                automatic int k=n;
                                fork
                                        mst_rdata_channel(k);
                                join_none
                        end
                end

        join
        end
endtask

task axi_interconnect::mst_waddr_channel(int j);

        forever
        begin
                logic k;
                $display("********INTERCONNECT WADDR CHANNEL TASK********");

                wait(vif_mst[j].intr_cnt_cb.awvalid)
                $display($time,"********awvalid is detected for j=%0d",j);
                if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.awaddr >= e_cfg.slave0_start_addr && e_cfg.m_agt_cfg[j].vif.m_drv_cb.awaddr <= e_cfg.slave0_end_addr)
                begin
                        sem.get(1);
                        k=0;
                        $display($time,"********SEM GOT THE KEY********j=%0d,k=%0d",j,k);
                end

                else if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.awaddr > e_cfg.slave1_start_addr && e_cfg.m_agt_cfg[j].vif.m_drv_cb.awaddr < e_cfg.slave1_end_addr)
                begin
                        sem1.get(1);
                        k=1;
                        $display($time,"********SEM1 GOT THE KEY********j=%0d,k=%0d",j,k);
                end

                else
                begin
                        $display("*******SLAVE ADDRESS DOESN'T EXIST********");
                        @(vif_mst[j].intr_cnt_cb);
                        vif_mst[j].intr_cnt_cb.awready <= 1'b1;
                        wait(vif_mst[j].intr_cnt_cb.awvalid==0);
                        vif_mst[j].intr_cnt_cb.awready <= 1'b0;
                        @(vif_mst[j].intr_cnt_cb);
                        vif_mst[j].intr_cnt_cb.bresp <= 2'b11;
                        vif_mst[j].intr_cnt_cb.bvalid <= 1'b1;
                        @(vif_mst[j].intr_cnt_cb);
                        $display("********BRESP=%0d,j=%0d",vif_mst[j].intr_cnt_cb.bresp,j);
                        wait(vif_mst[j].intr_cnt_cb.bready);
                        vif_mst[j].intr_cnt_cb.bvalid <= 2'b0;
                        $display("********IN INTERCONNECT WRITE DEOCDE ERROR********");
                        return;
                end
                //vif_mst[j].intr_cnt_cb.awready <= vif_slv[k].intr_cnt_cb.awready;
                wait(vif_slv[k].intr_cnt_cb.awready)
                $display("*********AWREADY IS DETECTED********j=%0d,k=%0d",j,k);
                vif_slv[k].intr_cnt_cb.awid <= vif_mst[j].intr_cnt_cb.awid;
                vif_slv[k].intr_cnt_cb.awaddr <= vif_mst[j].intr_cnt_cb.awaddr;
                vif_slv[k].intr_cnt_cb.awlen <= vif_mst[j].intr_cnt_cb.awlen;
                vif_slv[k].intr_cnt_cb.awburst <= vif_mst[j].intr_cnt_cb.awburst;
                vif_slv[k].intr_cnt_cb.awsize <= vif_mst[j].intr_cnt_cb.awsize;
                vif_slv[k].intr_cnt_cb.awvalid <= vif_mst[j].intr_cnt_cb.awvalid;
                vif_mst[j].intr_cnt_cb.awready <= vif_slv[k].intr_cnt_cb.awready;

                mst_write_array[vif_mst[j].intr_cnt_cb.awid]=vif_mst[j].intr_cnt_cb.awaddr;
                awlength[vif_mst[j].intr_cnt_cb.awid]=vif_mst[j].intr_cnt_cb.awlen;
                slv_write_response[vif_mst[j].intr_cnt_cb.awid]=j;
		//$display("&&&&&&&&&&&& slv_write_response =%p", slv_write_response);
                @(vif_mst[j].intr_cnt_cb);
                fork
                begin
                        wait(vif_slv[k].intr_cnt_cb.awready==0);
                        vif_mst[j].intr_cnt_cb.awready <= vif_slv[k].intr_cnt_cb.awready;
                end
                begin
                        wait(vif_mst[j].intr_cnt_cb.awvalid==0);
                        vif_slv[k].intr_cnt_cb.awvalid <= vif_mst[j].intr_cnt_cb.awvalid;
                end
                join

                repeat(2)
                @(vif_mst[j].intr_cnt_cb);

                if(k==0)
                begin
                        sem.put(1);
                        $display("********SEM PUT THE KEY******** j=%0d,k=%0d",j,k);
                end
                else
                begin
                        sem1.put(1);
                        $display("********SEM1 PUT THE KEY******** j=%0d,k=%0d",j,k);
                end
                $display("********INTERCONNECT WADDR CHANNEL COMPLETED********");
        end
endtask

task axi_interconnect::mst_wdata_channel(int j);

        forever
        begin

                int addr;
                int len;
                logic k;
                        $display("********INTERCONNECT WDATA CHANNEL TASK********");
                        wait(vif_mst[j].intr_cnt_cb.wvalid);
                        if(mst_write_array.exists(vif_mst[j].intr_cnt_cb.wid) && awlength.exists(vif_mst[j].intr_cnt_cb.wid))
                        begin
                                len=awlength[vif_mst[j].intr_cnt_cb.wid];
                                addr=mst_write_array[vif_mst[j].intr_cnt_cb.wid];
                                $display("********wvalid is detected addr=%h, wid=%0d, awlen=%0d",addr,vif_mst[j].intr_cnt_cb.wid,len);

                                if((addr >= e_cfg.slave0_start_addr && addr <= e_cfg.slave0_end_addr))
                                begin
                                        sem2.get(1);
                                        k=0;
                                        $display("********SEM2 GOT THE KEY********");
                                end

                                else if((addr > e_cfg.slave1_start_addr && addr < e_cfg.slave1_end_addr))
                                begin
                                        sem3.get(1);
                                        k=1;
                                        $display("********SEM3 GOT THE KEY********");
                                end

                                for(int l=0;l<=len;l++)
                                begin
                                        wait(vif_mst[j].intr_cnt_cb.wvalid)
                                        wait(vif_slv[k].intr_cnt_cb.wready)
                                        vif_slv[k].intr_cnt_cb.wid <= vif_mst[j].intr_cnt_cb.wid;
                                        vif_slv[k].intr_cnt_cb.wstrb <= vif_mst[j].intr_cnt_cb.wstrb;
                                        vif_slv[k].intr_cnt_cb.wdata <= vif_mst[j].intr_cnt_cb.wdata;
                                        vif_slv[k].intr_cnt_cb.wlast <= vif_mst[j].intr_cnt_cb.wlast;
                                        vif_slv[k].intr_cnt_cb.wvalid <= vif_mst[j].intr_cnt_cb.wvalid;
                                        vif_mst[j].intr_cnt_cb.wready <= vif_slv[k].intr_cnt_cb.wready;
                                        @(vif_mst[j].intr_cnt_cb);

                                        wait(vif_mst[j].intr_cnt_cb.wvalid==0)
                                        begin
                                                vif_slv[k].intr_cnt_cb.wvalid <= vif_mst[j].intr_cnt_cb.wvalid;
                                                vif_slv[k].intr_cnt_cb.wlast <= vif_mst[j].intr_cnt_cb.wlast;
                                        end
                                        wait(vif_slv[k].intr_cnt_cb.wready==0)
                                        vif_mst[j].intr_cnt_cb.wready <= vif_slv[k].intr_cnt_cb.wready;
                                        repeat(2)
                                        @(vif_mst[j].intr_cnt_cb);
                                end

                                if(k==0)
                                begin
                                        sem2.put(1);
                                        $display("********SEM2 PUT THE KEY********");
                                end
                                else
                                begin
                                        sem3.put(1);
                                        $display("********SEM3 PUT THE KEY********");
                                end
                                $display("********COMPLETED WDATA CHANNEL IN INTERCONNECT********");
                        end

                        else
                        begin
                                $display("IN WDATA CHANNEL********ADDRESS DOESN'T EXIST********");
                                return;
                        end
        $display("********INTERCONNECT WDATA CHANNEL COMPLETED********");
        end
endtask

task axi_interconnect::mst_wresp_channel(int k);

        forever
        begin

                logic j;
                        $display("********INTERCONNECT RESP CHANNEL TASK********");
                        wait(vif_slv[k].intr_cnt_cb.bvalid);
                        if(slv_write_response.exists(vif_slv[k].intr_cnt_cb.bid))
                        begin
                                j=slv_write_response[vif_slv[k].intr_cnt_cb.bid];
                                $display("********bvalid is detected bid=%0d",vif_slv[k].intr_cnt_cb.bid);

                                if(j==0)
                                begin
                                        sem4.get(1);
                                        $display("********SEM4 GOT THE KEY********");
                                end

                                else if(j==1)
                                begin
                                        sem5.get(1);
                                        $display("********SEM5 GOT THE KEY********");
                                end

                                //wait(vif_slv[k].intr_cnt_cb.bvalid)
                                wait(vif_mst[j].intr_cnt_cb.bready)
                                vif_mst[j].intr_cnt_cb.bid <= vif_slv[k].intr_cnt_cb.bid;
                                vif_mst[j].intr_cnt_cb.bresp <= vif_slv[k].intr_cnt_cb.bresp;
                                vif_mst[j].intr_cnt_cb.bvalid <= vif_slv[k].intr_cnt_cb.bvalid;
                                vif_slv[k].intr_cnt_cb.bready <= vif_mst[j].intr_cnt_cb.bready;
                                @(vif_slv[k].intr_cnt_cb);
                                fork
				begin
                                wait(vif_slv[k].intr_cnt_cb.bvalid==0)
                                //begin
                                    vif_mst[j].intr_cnt_cb.bvalid <= vif_slv[k].intr_cnt_cb.bvalid;
                                end
				begin
                                wait(vif_mst[j].intr_cnt_cb.bready==0)
                                    vif_slv[k].intr_cnt_cb.bready <= vif_mst[j].intr_cnt_cb.bready;
				end
                                join
				//$display("vif_slv[k].intr_cnt_cb.bid = %0d",vif_slv[k].intr_cnt_cb.bid);
                                repeat(2)
                                @(vif_slv[k].intr_cnt_cb);

                                                        if(j==0)
                                                        begin
                                                                sem4.put(1);
                                                                $display("********SEM4 PUT THE KEY********bid=%0d",vif_slv[k].intr_cnt_cb.bid);
                                                        end
                                                        else
                                                        begin
                                                                sem5.put(1);
                                                                $display("********SEM5 PUT THE KEY********bid=%0d",vif_slv[k].intr_cnt_cb.bid);
                                                        end
                                                $display("********COMPLETED RESP CHANNEL IN INTERCONNECT********bid=%0d",vif_slv[k].intr_cnt_cb.bid);
                                        end

                    else
                    begin
                        $display("IN RESP CHANNEL********BID DOESN'T EXIST********");
                        return;
                    end
                        $display("********INTERCONNECT RESP CHANNEL COMPLETED********");
        end
endtask

task axi_interconnect::mst_raddr_channel(int j);

        forever
        begin
                logic k;
                $display("********INTERCONNECT RADDR CHANNEL TASK********");

                wait(vif_mst[j].intr_cnt_cb.arvalid)
                $display($time,"********arvalid is detected for j=%0d",j);
                if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr >= e_cfg.slave0_start_addr && e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr <= e_cfg.slave0_end_addr)
                begin
                        sem6.get(1);
                        k=0;
                        $display($time,"********SEM6 GOT THE KEY********j=%0d,k=%0d",j,k);
                end

                else if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr > e_cfg.slave1_start_addr && e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr < e_cfg.slave1_end_addr)
                begin
                        sem7.get(1);
                        k=1;
                        $display($time,"********SEM7 GOT THE KEY********j=%0d,k=%0d",j,k);
                end

                else
                begin
                        $display("*******SLAVE ADDRESS DOESN'T EXIST********");
                        @(vif_mst[j].intr_cnt_cb);
                        vif_mst[j].intr_cnt_cb.arready <= 1'b1;
                        wait(vif_mst[j].intr_cnt_cb.arvalid==0);
                        vif_mst[j].intr_cnt_cb.arready <= 1'b0;
                        @(vif_mst[j].intr_cnt_cb);
                        vif_mst[j].intr_cnt_cb.rresp <= 2'b11;
                        vif_mst[j].intr_cnt_cb.rvalid <= 1'b1;
                        @(vif_mst[j].intr_cnt_cb);
                        $display("********RRESP=%0d,j=%0d",vif_mst[j].intr_cnt_cb.rresp,j);
                        wait(vif_mst[j].intr_cnt_cb.rready);
                        vif_mst[j].intr_cnt_cb.rvalid <= 2'b0;
                        $display("********IN INTERCONNECT DEOCDE ERROR********");
                        return;
                end
                //vif_mst[j].intr_cnt_cb.awready <= vif_slv[k].intr_cnt_cb.awready;
                wait(vif_slv[k].intr_cnt_cb.arready)
                $display("*********ARREADY IS DETECTED********j=%0d,k=%0d",j,k);
                vif_slv[k].intr_cnt_cb.arid <= vif_mst[j].intr_cnt_cb.arid;
                vif_slv[k].intr_cnt_cb.araddr <= vif_mst[j].intr_cnt_cb.araddr;
                vif_slv[k].intr_cnt_cb.arlen <= vif_mst[j].intr_cnt_cb.arlen;
                vif_slv[k].intr_cnt_cb.arburst <= vif_mst[j].intr_cnt_cb.arburst;
                vif_slv[k].intr_cnt_cb.arsize <= vif_mst[j].intr_cnt_cb.arsize;
                                vif_slv[k].intr_cnt_cb.rresp <= vif_mst[j].intr_cnt_cb.rresp;
                vif_slv[k].intr_cnt_cb.arvalid <= vif_mst[j].intr_cnt_cb.arvalid;
                vif_mst[j].intr_cnt_cb.arready <= vif_slv[k].intr_cnt_cb.arready;

                //mst_read_array[vif_mst[j].intr_cnt_cb.arid]=vif_mst[j].intr_cnt_cb.araddr;
                arlength[vif_mst[j].intr_cnt_cb.arid]=vif_mst[j].intr_cnt_cb.arlen;
                slv_read_response[vif_mst[j].intr_cnt_cb.arid]=j;
               // $display("------------------------------%p-----------------------%p",arlength,slv_read_response);
                @(vif_mst[j].intr_cnt_cb);
                fork
                begin
                        wait(vif_slv[k].intr_cnt_cb.arready==0);
                        vif_mst[j].intr_cnt_cb.arready <= vif_slv[k].intr_cnt_cb.arready;
                end
                begin
                        wait(vif_mst[j].intr_cnt_cb.arvalid==0);
                        vif_slv[k].intr_cnt_cb.arvalid <= vif_mst[j].intr_cnt_cb.arvalid;
                end
                join

                repeat(2)
                @(vif_mst[j].intr_cnt_cb);

                if(k==0)
                begin
                        sem6.put(1);
                        $display("********SEM6 PUT THE KEY******** j=%0d,k=%0d",j,k);
                end
                else
                begin
                        sem7.put(1);
                        $display("********SEM7 PUT THE KEY******** j=%0d,k=%0d",j,k);
                end
                $display("********INTERCONNECT RADDR CHANNEL COMPLETED********");
        end
endtask

task axi_interconnect::mst_rdata_channel(int k);

        forever
        begin

                //int addr;
                int len;
                logic j;
                        $display("********INTERCONNECT RDATA CHANNEL TASK********");
                        wait(vif_slv[k].intr_cnt_cb.rvalid);
                        //$display("------------------%p-------------------------------%p------------------------------------------",arlength,slv_read_response);
                        if(arlength.exists(vif_slv[k].intr_cnt_cb.rid) && slv_read_response.exists(vif_slv[k].intr_cnt_cb.rid))
                        begin
                                len=arlength[vif_slv[k].intr_cnt_cb.rid];
                                //addr=mst_write_array[vif_mst[j].intr_cnt_cb.wid];
                                j=slv_read_response[vif_slv[k].intr_cnt_cb.rid];
                                $display("********rvalid is detected rid=%0d, arlen=%0d",vif_slv[k].intr_cnt_cb.rid,len);

                                if(j==0)
                                begin
                                        sem8.get(1);
                                        $display("********SEM8 GOT THE KEY********");
                                end

                                else if(j==1)
                                begin
                                        sem9.get(1);
                                        $display("********SEM9 GOT THE KEY********");
                                end

                                for(int l=0;l<=len;l++)
                                begin
                                        wait(vif_slv[k].intr_cnt_cb.rvalid)
                                        wait(vif_mst[j].intr_cnt_cb.rready)
                                        vif_mst[j].intr_cnt_cb.rid <= vif_slv[k].intr_cnt_cb.rid;
                                        vif_mst[j].intr_cnt_cb.rdata <= vif_slv[k].intr_cnt_cb.rdata ;
                                        vif_mst[j].intr_cnt_cb.rlast <= vif_slv[k].intr_cnt_cb.rlast;
                                        vif_mst[j].intr_cnt_cb.rvalid <= vif_slv[k].intr_cnt_cb.rvalid;
					vif_mst[j].intr_cnt_cb.rresp <= vif_slv[k].intr_cnt_cb.rresp;
                                        vif_slv[k].intr_cnt_cb.rready <= vif_mst[j].intr_cnt_cb.rready;
                                        @(vif_slv[k].intr_cnt_cb);
                                        //fork
                                        wait(vif_slv[k].intr_cnt_cb.rvalid==0)
                                        begin
                                                vif_mst[j].intr_cnt_cb.rvalid <= vif_slv[k].intr_cnt_cb.rvalid;
                                                vif_mst[j].intr_cnt_cb.rlast <= vif_slv[k].intr_cnt_cb.rlast;
                                        end
                                        wait(vif_mst[j].intr_cnt_cb.rready==0)
                                                vif_slv[k].intr_cnt_cb.rready <= vif_mst[j].intr_cnt_cb.rready;
                                        //join
                        //      end
                                        repeat(2)
                                        @(vif_slv[k].intr_cnt_cb);
                                end

                                if(j==0)
                                begin
                                        sem8.put(1);
                                        $display("********SEM8 PUT THE KEY********");
                                end
                                else
                                begin
                                        sem9.put(1);
                                        $display("********SEM9 PUT THE KEY********");
                                end
                                $display("********COMPLETED RDATA CHANNEL IN INTERCONNECT********");
                        end

                        else
                        begin
                                $display("IN RDATA CHANNEL********RID DOESN'T EXIST********");
                                return;
                        end
        $display("********INTERCONNECT RDATA CHANNEL COMPLETED********");
        end
endtask

/*task axi_interconnect::mst_wresp_channel(int j);

        forever
        begin
                logic k;
                int addr;
                int len;
                $display("********INTERCONNECT WRESP CHANNEL TASK********");
                wait(vif_mst[j].intr_cnt_cb.bready)
                if(mst_write_array.exists(vif_mst[j].intr_cnt_cb.bid) && awlength.exists(vif_mst[j].intr_cnt_cb.bid))
                begin
                        len=awlength[vif_mst[j].intr_cnt_cb.bid];
                        addr=mst_write_array[vif_mst[j].intr_cnt_cb.bid];
                        $display("********bready is detected, addr=%h,bid=%d,awlen=%d********",addr,vif_mst[j].intr_cnt_cb.bid,len);

                        if(addr >= e_cfg.slave0_start_addr && addr <= e_cfg.slave0_end_addr)
                        begin
                                sem4.get(1);
                                k=0;
                                $display($time,"********SEM4 GOT THE KEY********");
                        end
                        else if(addr > e_cfg.slave1_start_addr && addr < e_cfg.slave1_end_addr)
                        begin
                                sem5.get(1);
                                k=1;
                                $display($time,"********SEM5 GOT THE KEY********");
                        end

                        wait(vif_slv[k].intr_cnt_cb.bvalid)
                        wait(vif_mst[j].intr_cnt_cb.bready)
                        begin
                                vif_mst[j].intr_cnt_cb.bid <= vif_slv[k].intr_cnt_cb.bid;
                                vif_mst[j].intr_cnt_cb.bvalid <= vif_slv[k].intr_cnt_cb.bvalid;
                                vif_slv[k].intr_cnt_cb.bready <= vif_mst[j].intr_cnt_cb.bready;
                                vif_mst[j].intr_cnt_cb.bresp <= vif_slv[k].intr_cnt_cb.bresp;
                        end
                        @(vif_mst[j].intr_cnt_cb);
                        wait(vif_slv[k].intr_cnt_cb.bvalid==0)
                                vif_mst[j].intr_cnt_cb.bvalid <= vif_slv[k].intr_cnt_cb.bvalid;

                        wait(vif_mst[j].intr_cnt_cb.bready==0);
                        begin
                                        vif_slv[k].intr_cnt_cb.bready <= vif_mst[j].intr_cnt_cb.bready;
                        end

                        repeat(2)
                        @(vif_mst[j].intr_cnt_cb);

                        if(k==0)
                        begin
                                sem4.put(1);
                                $display("********SEM4 PUT THE KEY********");
                        end
                        else
                        begin
                                sem5.put(1);
                                $display("********SEM5 PUT THE KEY********");
                        end
                        $display("********INTERCONNECT WRESP CHANNEL COMPLETED********");
                end
                else
                begin
                        $display("IN WRESP********ADDRESS DOESN'T EXIST********");
                        return;
                end
        end
endtask



task axi_interconnect::mst_raddr_connect(int j);  // j=0 for master[0] and j=1 for master[1]
 forever
         begin
                logic k;
                $display("In interconnect raddr task");

                wait(vif_mst[j].intr_cnt_cb.arvalid)  // to perform read operation master will put arvalid
                        $display($time,"awvalid is detected j=%d",j);

                if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr >= e_cfg.start_addrs_slave0 && e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr <= e_cfg.end_addrs_slave0)

                  begin
                        sem4.get(1);
                        k=0;
                        $display($time,"Sem4 got the key ---------------- %d %d",j,k);
                end

                  else if(e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr > e_cfg.start_addrs_slave1 && e_cfg.m_agt_cfg[j].vif.m_drv_cb.araddr < e_cfg.end_addrs_slave1)
                begin
                        sem5.get(1);
                        k=1;
                        $display($time,"Sem5 got the key ---------------- %d %d",j,k);
                end


                else
                begin
                        $display("Slave address does not exist");
                        @(vif_mst[j].intr_cnt_cb);


                        vif_mst[j].intr_cnt_cb.arready <= 1;  // if slave addr will not match then interconnect will send arready<=1
                        wait(vif_mst[j].intr_cnt_cb.arvalid==0) // from master
                        vif_mst[j].intr_cnt_cb.arready <= 0;   // interconnect will drive arready since no slave
                        @(vif_mst[j].intr_cnt_cb);
                 vif_mst[j].intr_cnt_cb.rresp <= 2'b11; // since there is no slave selected interconnect will send rresp and rvalid to get decode error//
                                vif_mst[j].intr_cnt_cb.rvalid <= 1'b1;
                        @(vif_mst[j].intr_cnt_cb);

                        $display("BRESP=%d,j=%d",vif_mst[j].intr_cnt_cb.rresp,j);


                        wait(vif_mst[j].intr_cnt_cb.rready)
                        vif_mst[j].intr_cnt_cb.rvalid <= 1'b0;
                        $display("In interconnect read  decode error");
                        return;
                end


                 wait(vif_slv[k].intr_cnt_cb.arready) // suppose if there is a slave than we to wait for arready which is sent by slave
                $display("arready is detected j=%d,k=%d",j,k); // after waiting for arvalid from master and arready from slave now interconnect will drive addr and control from master to slave

                vif_slv[k].intr_cnt_cb.arid <= vif_mst[j].intr_cnt_cb.arid;
                vif_slv[k].intr_cnt_cb.araddr <= vif_mst[j].intr_cnt_cb.araddr;
                vif_slv[k].intr_cnt_cb.arlen <= vif_mst[j].intr_cnt_cb.arlen;
                vif_slv[k].intr_cnt_cb.arburst <= vif_mst[j].intr_cnt_cb.arburst;
                vif_slv[k].intr_cnt_cb.arsize <= vif_mst[j].intr_cnt_cb.arsize;
                vif_slv[k].intr_cnt_cb.arvalid <= vif_mst[j].intr_cnt_cb.arvalid;
                vif_mst[j].intr_cnt_cb.arready <= vif_slv[k].intr_cnt_cb.arready;  // from arready from slave to master

                mst_write_array[vif_mst[j].intr_cnt_cb.arid]=vif_mst[j].intr_cnt_cb.araddr;  // storing araddr in associative array
                arlength[vif_mst[j].intr_cnt_cb.arid]=vif_mst[j].intr_cnt_cb.arlen; // storing arlen in associative array which is required for read_data_channel in slve
                slv_read_response_array[vif_mst[j].intr_cnt_cb.arid]=j;  // master[0] or master[1]


                 @(vif_mst[j].intr_cnt_cb);
                fork
                begin
                        wait(vif_slv[k].intr_cnt_cb.arready==0);
                        vif_mst[j].intr_cnt_cb.arready <= vif_slv[k].intr_cnt_cb.arready;
                end
                begin
                        wait(vif_slv[k].intr_cnt_cb.arready==0)
                        vif_slv[k].intr_cnt_cb.arvalid <= vif_mst[j].intr_cnt_cb.arvalid;
                end

                repeat(2)
                @(vif_mst[j].intr_cnt_cb);
                if(k==0)
                        sem4.put(1);
                else
                        sem5.put(1);

                $display("Completed raddr task in interconnect j=%d, arvalid=%d",j,vif_mst[j].intr_cnt_cb.arvalid);
                join
        end
endtask

task axi_interconnect::mst_rdata_connect(int j);

        forever
        begin
                int addr;
                int len;
                logic k; // slave[0] and slave[1]

                  //wait(vif_slv[k].intr_cnt_cb.rvalid)

                if(mst_write_array.exists(vif_mst[j].intr_cnt_cb.arid) && arlength.exists(vif_mst[j].intr_cnt_cb.arid))
                begin
                        len=arlength[vif_mst[j].intr_cnt_cb.arid];
                        addr=mst_write_array[vif_mst[j].intr_cnt_cb.arid];
                   $display("rvalid is detected, addr=%h,arid=%d,arlen=%d",addr,vif_mst[j].intr_cnt_cb.arid,len);

                         if(addr >= e_cfg.start_addrs_slave0 && addr <= e_cfg.end_addrs_slave0)
                        begin
                                sem8.get(1);
                                k=0;
                        end

                        else if(addr > e_cfg.start_addrs_slave1 && addr < e_cfg.end_addrs_slave1)
                        begin
                                sem9.get(1);
                                k=1;
                        end

                         for(int l=0;l<=len;l++)
                        begin
                                wait(vif_slv[k].intr_cnt_cb.rvalid)
                                wait(vif_mst[j].intr_cnt_cb.rready)
                                vif_mst[j].intr_cnt_cb.rid <= vif_slv[k].intr_cnt_cb.rid;
                                //vif_slv[k].intr_cnt_cb.wburst <= vif_mst[j].intr_cnt_cb.wburst;
                                vif_mst[j].intr_cnt_cb.rdata <= vif_slv[k].intr_cnt_cb.rdata;
                                vif_mst[j].intr_cnt_cb.rlast <= vif_slv[k].intr_cnt_cb.rlast;
                                vif_mst[j].intr_cnt_cb.rvalid <= vif_slv[k].intr_cnt_cb.rvalid;
                                vif_slv[k].intr_cnt_cb.rready <= vif_mst[j].intr_cnt_cb.rready;
                                @(vif_slv[k].intr_cnt_cb);


                                  wait(vif_slv[k].intr_cnt_cb.rvalid==0);
                                begin
                                        vif_mst[j].intr_cnt_cb.rready <= vif_slv[k].intr_cnt_cb.rvalid;
                 vif_mst[j].intr_cnt_cb.rlast <= vif_mst[k].intr_cnt_cb.rlast;
                                end

                                wait(vif_mst[j].intr_cnt_cb.rready==0)
                                        vif_slv[k].intr_cnt_cb.rready <= vif_mst[j].intr_cnt_cb.rready;

                                repeat(2)
                                @(vif_slv[k].intr_cnt_cb);
                        end

                          //        @(vif_mst[j].intr_cnt_cb);
                        //end

                        if(k==0)
                        begin
                                sem8.put(1);
                        end
                        else
                        begin
                                sem9.put(1);
                        end
                           $display("Completed rdata task in interconnect k=%d, rvalid=%d",j,vif_slv[k].intr_cnt_cb.rvalid);

                end
                else
                begin
                        $display("Address does not exist");
                        return;
                end
end
endtask
*/

