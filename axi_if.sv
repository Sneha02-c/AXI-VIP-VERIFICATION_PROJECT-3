interface axi_if (input bit clock);


        //write data signals
        logic [3:0] wid;
        logic [31:0] wdata;
        logic [3:0] wstrb;
        logic wlast;
        logic wvalid;
        logic wready;
        logic aresetn;

        //write address signals
        logic [3:0] awid;
        logic [31:0] awaddr;
        logic [7:0] awlen;
        logic [2:0] awsize;
        logic [1:0] awburst;
        logic awvalid;
        logic awready;

        //write response signals
        logic [3:0] bid;
        logic [1:0] bresp;
        logic bvalid;
        logic bready;

        //read address signals
        logic [3:0] arid;
        logic [31:0] araddr;
        logic [7:0] arlen;
        logic [2:0] arsize;
        logic [1:0] arburst;
        logic arvalid;
        logic arready;

        //read data channel;
        logic [3:0] rid;
        logic [31:0] rdata;
        logic [1:0] rresp;
        logic rlast;
        logic rvalid;
        logic rready;

        //master driver clocking block
        clocking m_drv_cb @(posedge clock);
                default input #1 output #1;

        output aresetn;
        output wid;
        output wdata;
        output wstrb;
        output wlast;
        output wvalid;
        input wready;
        output awid;
        output awaddr;
        output awlen;
        output awsize;
        output awburst;
        output awvalid;
        input awready;
        input bid;
        input bresp;
        input bvalid;
        output bready;
        output arid;
        output araddr;
        output arlen;
        output arsize;
        output arburst;
        output arvalid;
        input arready;
        input rid;
        input rdata;
        input rresp;
        input rlast;
        input rvalid;
        output rready;

        endclocking

        //master monitor clocking block
        clocking m_mon_cb @(posedge clock);
                default input #1 output #1;

        input aresetn;
        input wid;
        input wdata;
        input wstrb;
        input wlast;
        input wvalid;
        input wready;
        input awid;
        input awaddr;
        input awlen;
        input awsize;
        input awburst;
        input awvalid;
        input awready;
        input bid;
        input bresp;
        input bvalid;
        input bready;
        input arid;
        input araddr;
        input arlen;
        input arsize;
        input arburst;
        input arvalid;
        input arready;
        input rid;
        input rdata;
        input rresp;
        input rlast;
        input rvalid;
        input rready;

        endclocking

        //slave driver clocking block
        clocking s_drv_cb @(posedge clock);
                default input #1 output #1;

        input wid;
        input wdata;
        input wstrb;
        input wlast;
        input wvalid;
        output wready;
        input awid;
        input awaddr;
        input awlen;
        input awsize;
        input awburst;
        input awvalid;
        output awready;
        output bid;
        output bresp;
        output bvalid;
        input bready;
        input arid;
        input araddr;
        input arlen;
        input arsize;
        input arburst;
        input arvalid;
        output arready;
        output rid;
        output rdata;
        output rresp;
        output rlast;
        output rvalid;
        input rready;

        endclocking

        //slave monitor clocking block
        clocking s_mon_cb @(posedge clock);
                default input #1 output #1;

        input wid;
        input wdata;
        input wstrb;
        input wlast;
        input wvalid;
        input wready;
        input awid;
        input awaddr;
        input awlen;
        input awsize;
        input awburst;
        input awvalid;
        input awready;
        input bid;
        input bresp;
        input bvalid;
        input bready;
        input arid;
        input araddr;
        input arlen;
        input arsize;
        input arburst;
        input arvalid;
        input arready;
        input rid;
        input rdata;
        input rresp;
        input rlast;
        input rvalid;
        input rready;

        endclocking

        clocking intr_cnt_cb @(posedge clock);
                default input #1 output #1;

        inout aresetn;
        inout wid;
        inout wdata;
        inout wstrb;
        inout wlast;
        inout wvalid;
        inout wready;
        inout awid;
        inout awaddr;
        inout awlen;
        inout awsize;
        inout awburst;
        inout awvalid;
        inout awready;
        inout bid;
        inout bresp;
        inout bvalid;
        inout bready;
        inout arid;
        inout araddr;
        inout arlen;
        inout arsize;
        inout arburst;
        inout arvalid;
        inout arready;
        inout rid;
        inout rdata;
        inout rresp;
        inout rlast;
        inout rvalid;
        inout rready;

        endclocking


        //modports of clocking blocks
        modport M_DRV_MP(clocking m_drv_cb);
        modport M_MON_MP(clocking m_mon_cb);
        modport S_DRV_MP(clocking s_drv_cb);
        modport S_MON_MP(clocking s_mon_cb);
        modport INTR_CNT_MP(clocking intr_cnt_cb);

endinterface


