class axi_xtn extends uvm_sequence_item;

        `uvm_object_utils(axi_xtn)

        bit aresetn;

        randc bit [3:0] wid;
        rand bit [31:0] wdata[];
        bit [3:0] wstrb[];
        bit wlast;
        bit wvalid;
        bit wready;

        randc bit [3:0] awid;
        rand bit [31:0] awaddr;
        rand bit [7:0] awlen;
        randc bit [2:0] awsize;
        randc bit [1:0] awburst;
        bit awvalid;
        bit awready;

        randc bit [3:0] bid;
        rand bit [1:0] bresp;
        bit bvalid;
        bit bready;

        randc bit [3:0] arid;
        rand bit [31:0] araddr;
        rand bit [7:0] arlen;
        randc bit [2:0] arsize;
        randc bit [1:0] arburst;
        bit arvalid;
        bit arready;

        randc bit [3:0] rid;
        rand bit [31:0] rdata[];
        rand bit [1:0] rresp[];
        bit rlast;
        bit rvalid;
        bit rready;

        int number_bytes;
        int start_address;
        int aligned_address;
        int burst_length;
        bit [31:0] addr[];

        //constraints
        //constraint awid_range {awid inside {[1:16]};}
        //constraint arid_range {arid inside {[1:16]};}
        //constraint length {arlen inside {[2:5]};}
        constraint wid_const {awid==wid;bid==wid;}
        constraint rid_const {arid==rid;}
        constraint awb_const {awburst inside {[0:2]};}
        constraint aws_const {awsize inside {[0:2]};}
        constraint boundary_const {((2*awsize)*(awlen+1))<4096;}
        constraint walign_c1 {((awburst==2 || awburst==0) && awsize==1) -> (awaddr%2==0);}
        constraint walign_c2 {((awburst==2 || awburst==0) && awsize==2) -> (awaddr%4==0);}
	constraint ralign_c1 {((arburst==2 || arburst==0) && arsize==1) -> (araddr%2==0);}
        constraint ralign_c2 {((arburst==2 || arburst==0) && arsize==2) -> (araddr%4==0);}
        constraint aws_c1 {wdata.size==awlen+1;}
        //constraint strb_c1 {wstrb.size==wdata.size;}
        constraint aws_c2 {(awburst==2) -> awlen inside {2,4,8,16};}
        constraint ars_const {rdata.size==arlen+1;}
        constraint arr_const {rresp.size==rdata.size;}
        constraint ars_c1 {arsize inside {[0:2]};}
//	constraint awid_range {unique{awid};}
//	constraint arid_range {unique{arid};}


	extern function new(string name="axi_xtn");
        extern function void post_randomize();
        extern function void addr_cal();
        extern function void strb_cal();
	extern function bit do_compare(uvm_object rhs,uvm_comparer comparer);
	extern function void do_print(uvm_printer printer);	

endclass


function axi_xtn::new(string name="axi_xtn");
        super.new(name);
endfunction

function void axi_xtn::post_randomize();
        start_address=awaddr;
        number_bytes=2**awsize;
        aligned_address=(int'(start_address/number_bytes))*number_bytes;
        burst_length=awlen+1;
        addr=new[burst_length];
        wstrb=new[burst_length];
        //`uvm_info("XTN",$sformatf("start address=%0h,number bytes=%0d,aligned address=%0h,burst length=%0d",start_address,number_bytes,aligned_address,burst_length),UVM_LOW)
        addr_cal();
        strb_cal();
endfunction

function void axi_xtn::addr_cal();
        int wrap_boundary;
        bit k;
        //addr=new[burst_length];

        wrap_boundary=(int'(start_address/(number_bytes*burst_length)))*(number_bytes*burst_length);
        addr[0]=awaddr;

        for(int i=2;i<=(awlen+1);i++)
        begin
                if(awburst==0)
                        addr[i-1]=awaddr;
                else if(awburst==1)
                        addr[i-1]=aligned_address+(i-1)*number_bytes;
                else if(awburst==2)
                        if(k==0)
                        begin
                                addr[i-1]=aligned_address+(i-1)*number_bytes;
                                if(addr[i-1]==wrap_boundary+(number_bytes*burst_length))
                                begin
                                        addr[i-1]=wrap_boundary;
                                        k++;
                                end
                        end
                        else
                                addr[i-1]=start_address+((i-1)*number_bytes)-(number_bytes*burst_length);
        end
        //foreach(addr[i])
                //`uvm_info("XTN",$sformatf("Printing the addresses.\n %h",addr[i]),UVM_LOW)
        //`uvm_info("XTN","address calculation is executed",UVM_LOW)
endfunction

function void axi_xtn::strb_cal();
        int data_bus_bytes=4;
        int lower_byte_lane_0;
        int upper_byte_lane_0;
        int lower_byte_lane;
        int upper_byte_lane;
        //wstrb=new[burst_length];

        //`uvm_info("XTN",$sformatf("start address=%0h,number_bytes=%0d,awsize=%0d,burst_length=%0d,aligned_address=%0h",start_address,number_bytes,awsize,burst_length,aligned_address),UVM_LOW)
        lower_byte_lane_0=start_address-(int'(start_address/data_bus_bytes))*data_bus_bytes;
        upper_byte_lane_0=aligned_address+(number_bytes-1)-(int'(start_address/data_bus_bytes))*data_bus_bytes;
        //`uvm_info("XTN",$sformatf("lower byte lane 0=%0d,upper byte lane 0=%0d",lower_byte_lane_0,upper_byte_lane_0),UVM_LOW)
        for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
                wstrb[0][j]=1'b1;
        //`uvm_info("XTN",$sformatf("First strobe value %b",wstrb[0]),UVM_LOW)
        for(int i=1;i<=burst_length-1;i++)
        begin
                lower_byte_lane=addr[i]-((int'(addr[i]/data_bus_bytes))*data_bus_bytes);
                upper_byte_lane=lower_byte_lane+number_bytes-1;
                for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
                        wstrb[i][j]=1'b1;
                //`uvm_info("XTN",$sformatf("lbl=%0d,ubl=%0d,addr=%0h,wstrb=%b",lower_byte_lane,upper_byte_lane,addr[i],wstrb[i]),UVM_LOW)
        end

//      `uvm_info("XTN",$sformatf("Printing the strobe value.\n%p",wstrb),UVM_LOW)
//      `uvm_info("XTN","Strobe calculation is executed",UVM_LOW)
endfunction


function bit axi_xtn::do_compare(uvm_object rhs,uvm_comparer comparer);

	axi_xtn rhs_;

	if(!$cast(rhs_,rhs))
	begin
		`uvm_fatal("DO COMPARE","Cast of the object failes")
		return 0;
	end

	return super.do_compare(rhs,comparer) &&
	 awid==rhs_.awid&&
        awaddr==rhs_.awaddr&&
        awlen==rhs_.awlen&&
        awsize==rhs_.awsize&&
        awburst==rhs_.awburst&&
	
	wid== rhs_.wid &&
//	foreach(wdata[i])
		 //wdata[i]== rhs_.wdata[i] &&
		
		 wdata== rhs_.wdata &&
  //      foreach(wstrn[i])
		// wstrb[i]== rhs_.wstrb[i] &&

		 wstrb== rhs_.wstrb &&
	 bid==rhs_.bid&&
        bresp==rhs_.bresp&&

	 arid==rhs_.arid&&
        araddr==rhs_.araddr&&
        arlen==rhs_.arlen&&
        arsize==rhs_.arsize&&
        arburst==rhs_.arburst&&
	
        rid==rhs_.rid&&
        //foreach(rdata[i]) rdata[i]==rhs_.rdata[i] &&
        //foreach(rresp[i]) rresp[i]==rhs_.rresp[i];
	rdata==rhs_.rdata &&
	rresp==rhs_.rresp;
endfunction

function void axi_xtn::do_print(uvm_printer printer);

	super.do_print(printer);
	
	printer.print_field("awid",      this.awid,            8,          UVM_DEC);
	printer.print_field("awaddr",    this.awaddr,         32,          UVM_HEX);
	printer.print_field("awlen",     this.awlen,           8,          UVM_DEC);
	printer.print_field("awsize",    this.awsize,          3,          UVM_DEC);
	printer.print_field("awburst",   this.awburst,         2,          UVM_DEC);
	printer.print_field("wid",       this.wid,             8,          UVM_DEC);
        foreach(wdata[i])
                printer.print_field("wdata",     this.wdata[i],           32,          UVM_HEX);
        foreach(wstrb[i])
		printer.print_field("wstrb",     this.wstrb[i],            4,          UVM_DEC);
	printer.print_field("bid",      this.bid,              8,          UVM_DEC);
	printer.print_field("bresp",    this.bresp,            2,          UVM_DEC);
	printer.print_field("arid",      this.arid,            8,          UVM_DEC);
        printer.print_field("araddr",    this.araddr,         32,          UVM_HEX);
        printer.print_field("arlen",     this.arlen,           8,          UVM_DEC);
        printer.print_field("arsize",    this.arsize,          3,          UVM_DEC);
        printer.print_field("arburst",   this.arburst,         2,          UVM_DEC);
        printer.print_field("rid",       this.rid,             8,          UVM_DEC);
        foreach(rdata[i])
                printer.print_field("rdata",     this.rdata[i],           32,          UVM_HEX);
        foreach(rresp[i])
                printer.print_field("rresp",     this.rresp[i],            2,          UVM_DEC);

endfunction



class high_xtn extends axi_xtn;

        // UVM Factory Registration Macro
    `uvm_object_utils(high_xtn)


        //------------------------------------------
        // CONSTRAINTS
        //------------------------------------------

         // Override Constraint for address such that it generates address to
         // access only the first 16 locations of the memory

       // constraint high {foreach(wdata[i]) wdata[i] inside  {[32'd3000000001:32'd4000000000]}; }
        constraint high { awburst==2;}




        //------------------------------------------
        // METHODS
        //------------------------------------------

        // Add constructor
        extern function new(string name = "high_xtn");
        endclass

//-----------------  constructor new method  -------------------//
//Add code for new()

function high_xtn::new(string name = "high_xtn");
        super.new(name);
endfunction:new

