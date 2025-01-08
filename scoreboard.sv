/*class axi_sb extends uvm_scoreboard;

        `uvm_component_utils(axi_sb)

        axi_env_config m_cfg;

        extern function new(string name="axi_sb",uvm_component parent);
endclass

function axi_sb::new(string name="axi_sb",uvm_component parent);
        super.new(name,parent);

        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
                `uvm_fatal("CONFIG","Cannot get env config from uvm_config_db.Have you set it?")
endfunction
*/


class axi_sb extends uvm_scoreboard;

uvm_tlm_analysis_fifo #(axi_xtn) master_fifo[];
uvm_tlm_analysis_fifo #(axi_xtn) slave_fifo[];


axi_xtn m_xtn1,m_xtn2,s_xtn1,s_xtn2;
axi_xtn m_xtn_1,m_xtn_2, m_xtn_3, m_xtn_4,m_xtn_5;
axi_xtn m_array_1[int], m_array_2[int], m_array_3[int], m_array_4[int],m_array_5[int];
axi_xtn mst_cov;


        `uvm_component_utils(axi_sb)

        axi_env_config m_cfg;

//      extern function new(string name="axi_sb",uvm_component parent);
//endclass

//function axi_sb::new(string name="axi_sb",uvm_component parent);
        //super.new(name,parent);

        //if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
        //      `uvm_fatal("CONFIG","Cannot get env config from uvm_config_db.Have you set it?")

        //       axi_master =new();
        // axi_slave_data =new();
        // axi_master_data = new();

//endfunction


covergroup axi_master_data with function sample(int i);

option.per_instance=1;

                W_data:coverpoint mst_cov.wdata[i] {

                                bins low = {[32'd0:32'd1000000000]};
                                bins min = {[32'd1000000001:32'd2000000000]};
                                bins mid = {[32'd2000000001:32'd3000000000]};
                                bins high = {[32'd3000000001:32'd4000000000]};
                                                                                        }

                W_strb:coverpoint mst_cov.wstrb[i] {

                                bins stb1 = {4'b1111};
                                bins stb2 = {4'b1100};
                                bins stb3 = {4'b0011};
                                bins stb4 = {4'b1000};
                                bins stb5 = {4'b0100};
                                bins stb6 = {4'b0010};
                                bins stb7 = {4'b0001}; 
                                                                }
endgroup

covergroup axi_master;

option.per_instance=1;

                        AW_ID:coverpoint mst_cov.awid[3:0]{
                                bins id_0 ={[0:15]};  }

                        AR_ID:coverpoint mst_cov.arid[3:0]{
                                bins id_1 = {[0:15]};   }

                        AW_addr:coverpoint mst_cov.awaddr[31:0]{
                                bins slave1 = {['h8000_0000:'h8400_03ff]};
                                bins slave2 = {['h8800_0000:'h8c00_03ff]};
                                                                                }

                        AR_addr:coverpoint mst_cov.araddr[31:0]{
                                 bins slave1 = {['h8000_0000:'h8400_03ff]};
                                bins slave2 = {['h8800_0000:'h8c00_03ff]};
                                                                                }
                        AW_size:coverpoint mst_cov.awsize[2:0]{

                                bins Byte_0={0};
                                bins half_word_0={1};
                                bins word_0={2};
                                                                }
                        AR_size:coverpoint mst_cov.arsize[2:0]{

                                bins Byte_0={0};
                                bins half_word_0={1};
                                bins word_0={2};
                                                                }
                        AW_burst:coverpoint mst_cov.awburst[1:0]{

                                bins fixed_0 = {0};
                                bins incr_0 = {1};
                                bins wrap_0 = {2};
                                                                }
                        AR_burst:coverpoint mst_cov.arburst[1:0]{

                                bins fixed_1 = {0};
                                bins incr_1 = {1};
                                bins wrap_1 = {2};
                                                                }
                        AW_len:coverpoint mst_cov.awlen[7:0]{

                                bins length = {[0:255]};
			//	bins min = {[0:63]};
                               // bins mid = {[64:127]};
                               // bins high = {[128:191]};
                               // bins max = {[192:256]};

                                                                }
                        AR_len:coverpoint mst_cov.arlen[7:0]{

                                bins length = {[0:255]};
				//bins min = {[0:63]};
				//bins mid = {[64:127]};
			//	bins high = {[128:191]};
			//	bins max = {[192:256]};
                                                                }
                        B_resp:coverpoint mst_cov.bresp[1:0]{

                                bins okay = {0};
                                bins exokay = {1};
                                bins slave_error = {2};
								bins decode_error ={3};
                                                                }

                        AW_lenxAW_addrxAW_size:cross AW_len,AW_addr,AW_size;
                        AR_lenxAR_addrxAR_size:cross AR_len,AR_addr,AR_size;
endgroup


covergroup axi_slave_data with function sample(int i);

option.per_instance=1;

                R_Data:coverpoint mst_cov.rdata[i] {

                                  bins low = {[32'd0:32'd1000000000]};
                                bins min = {[32'd1000000001:32'd2000000000]};
                                bins mid = {[32'd2000000001:32'd3000000000]};
                                bins high = {[32'd3000000001:32'd4000000000]};
                                                                                        }
                R_resp:coverpoint mst_cov.rresp[i]{

                                bins okay = {0};
                                bins exokay = {1};
                                bins slave_error ={2};
				bins decode_error={3};
                                                                                        }
endgroup

                extern function new(string name = "axi_sb",uvm_component parent);
                extern function void build_phase(uvm_phase phase);
                extern task run_phase(uvm_phase phase);
                extern task storing(axi_xtn master_xtn);
                extern task compare_data(axi_xtn s_xtn);
endclass


function axi_sb::new(string name = "axi_sb",uvm_component parent);
        super.new(name,parent);

          if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
                  `uvm_fatal("CONFIG","Cannot get env config from uvm_config_db.Have you set it?")


        axi_master =new();
        axi_slave_data =new();
        axi_master_data = new();
endfunction



function void axi_sb::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
        `uvm_fatal("CONFIG","Cannot get() config_tb.Have you set() it?")

        master_fifo = new[m_cfg.no_of_masters];
        slave_fifo = new[m_cfg.no_of_slaves];

        foreach(master_fifo[i])
        master_fifo[i] = new($sformatf("master_fifo[%0d]",i),this);

         foreach(slave_fifo[i])
        slave_fifo[i] = new($sformatf("slave_fifo[%0d]",i),this);
endfunction

task axi_sb::run_phase(uvm_phase phase);

        forever

        fork
                begin
                        master_fifo[0].get(m_xtn1);
                        storing(m_xtn1);
                        mst_cov = m_xtn1;
                        axi_master.sample();
                        foreach(mst_cov.wdata[i])
                        axi_master_data.sample(i);
                        foreach(mst_cov.rdata[i])
                        axi_slave_data.sample(i);
                end

                begin
                        master_fifo[1].get(m_xtn2);
                        storing(m_xtn2);
                        mst_cov = m_xtn2;
                        axi_master.sample();
                        foreach(mst_cov.wdata[i])
                        axi_master_data.sample(i);
                        foreach(mst_cov.rdata[i])
                        axi_slave_data.sample(i);
                end

                begin
                        slave_fifo[0].get(s_xtn1);
                        compare_data(s_xtn1);
                        mst_cov = s_xtn1;
                        axi_master.sample();
                        foreach(mst_cov.wdata[i])
                        axi_master_data.sample(i);
                        foreach(mst_cov.rdata[i])
                        axi_slave_data.sample(i);
                end

                 begin
                        slave_fifo[1].get(s_xtn2);
                        compare_data(s_xtn2);
                        mst_cov = s_xtn2;
                        axi_master.sample();
                        foreach(mst_cov.wdata[i])
                        axi_master_data.sample(i);
                        foreach(mst_cov.rdata[i])
                        axi_slave_data.sample(i);
                end

        join_any
endtask

task axi_sb::storing(axi_xtn master_xtn);

        if(master_xtn.awvalid&&master_xtn.awready)
                m_array_1[master_xtn.awid]= master_xtn;
        if(master_xtn.wvalid&&master_xtn.wready)
                m_array_2[master_xtn.wid] = master_xtn;
        if(master_xtn.bvalid&&master_xtn.bready)
                m_array_3[master_xtn.bid] = master_xtn;
        if(master_xtn.arvalid&&master_xtn.arready)
                m_array_4[master_xtn.arid] = master_xtn;
        if(master_xtn.rvalid&& master_xtn.rready)
                m_array_5[master_xtn.rid] = master_xtn;
endtask

task axi_sb::compare_data(axi_xtn s_xtn);

m_xtn_1 = axi_xtn::type_id::create("m_xtn_1");
m_xtn_2 = axi_xtn::type_id::create("m_xtn_2");
m_xtn_3 = axi_xtn::type_id::create("m_xtn_3");
m_xtn_4 = axi_xtn::type_id::create("m_xtn_4");
m_xtn_5 = axi_xtn::type_id::create("m_xtn_5");


        if(m_array_1.exists(s_xtn.awid))
                begin
                m_xtn_1 = m_array_1[s_xtn.awid];
        if(s_xtn.awvalid&&s_xtn.awready)
        begin
                if(m_xtn_1.compare(s_xtn))
        begin
        $display("&&&&&&&&&&&&&&&&&& Comparison is successful &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write addr channel");

        m_xtn_1.print;
        s_xtn.print;
        end

        else

        begin

         $display("&&&&&&&&&&&&&&&&&& Comparison is failure  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write addr channel");


        m_xtn_1.print;
        s_xtn.print;
        end
        end
        end

        if(m_array_2.exists(s_xtn.wid))
                begin
                m_xtn_2 = m_array_2[s_xtn.wid];
          if(s_xtn.wvalid&&s_xtn.wready)
        begin
                if(m_xtn_2.compare(s_xtn))
          begin
        $display("&&&&&&&&&&&&&&&&&& Comparison is successful &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write data channel");

        m_xtn_2.print;
        s_xtn.print;

        end

          else

        begin

         $display("&&&&&&&&&&&&&&&&&& Comparison is failure  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write data channel");


        m_xtn_2.print;
        s_xtn.print;
        end
        end
        end


         if(m_array_3.exists(s_xtn.bid))
                begin
                m_xtn_3 = m_array_3[s_xtn.bid];
          if(s_xtn.bvalid&&s_xtn.bready)
        begin
                if(m_xtn_3.compare(s_xtn))
         begin
        $display("&&&&&&&&&&&&&&&&&& Comparison is successful &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write resp  channel");


        m_xtn_3.print;
        s_xtn.print;

        end

          else

        begin

         $display("&&&&&&&&&&&&&&&&&& Comparison is failure  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard write resp channel");


        m_xtn_3.print;
        s_xtn.print;
        end
        end
        end


         if(m_array_4.exists(s_xtn.arid))
                begin
                m_xtn_4 = m_array_4[s_xtn.arid];
          if(s_xtn.arvalid&&s_xtn.arready)
        begin
                if(m_xtn_4.compare(s_xtn))
         begin
        $display("&&&&&&&&&&&&&&&&&& Comparison is successful &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard read addr   channel");


        m_xtn_4.print;
        s_xtn.print;

        end

           else

        begin

         $display("&&&&&&&&&&&&&&&&&& Comparison is failure  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard read  addr channel");


        m_xtn_4.print;
        s_xtn.print;
        end
        end
        end


        if(m_array_5.exists(s_xtn.rid))
                begin
                m_xtn_5 = m_array_5[s_xtn.rid];
				
          if(s_xtn.rvalid&&s_xtn.rready)
        begin
                if(m_xtn_5.compare(s_xtn))
         begin
        $display("&&&&&&&&&&&&&&&&&& Comparison is successful &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard read data   channel");


        m_xtn_5.print;
        s_xtn.print;

        end

          else

        begin

         $display("&&&&&&&&&&&&&&&&&& Comparison is failure  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
        $display("############################### from scoreboard read data  channel");


        m_xtn_5.print;
        s_xtn.print;
        end
        end
        end

endtask

