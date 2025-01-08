class axi_v_seqs extends uvm_sequence #(uvm_sequence_item);

        `uvm_object_utils(axi_v_seqs)

        axi_v_seqr vsqrh;

        axi_m_seqr m_seqrh[];
        axi_s_seqr s_seqrh[];

        axi_env_config m_cfg;

        master00_seq m00_seq;
        master11_seq m11_seq;

      master01_seq m01_seq;
      master10_seq m10_seq;

	decerr_seq de_seq;
	burst3_seq b3_seq;

	 master12_seq m101_seq;
        master13_seq m111_seq;


        extern function new(string name="axi_v_seqs");
        extern task body();
endclass

function axi_v_seqs::new(string name="axi_v_seqs");
        super.new(name);
endfunction

task axi_v_seqs::body();
        if(!uvm_config_db #(axi_env_config)::get(null,get_full_name(),"axi_env_config",m_cfg))
                `uvm_fatal("CONFIG","Cannot get env_config from uvm_config_db.Have you set it?")

        m_seqrh=new[m_cfg.no_of_masters];
        s_seqrh=new[m_cfg.no_of_slaves];

        assert($cast(vsqrh,m_sequencer))
        else
        begin
                `uvm_error("BODY","Error in $cast of virtual sequencer")
        end

        foreach(m_seqrh[i])
                m_seqrh[i]=vsqrh.m_seqrh[i];
        foreach(s_seqrh[i])
                s_seqrh[i]=vsqrh.s_seqrh[i];
endtask

class m0s0_m1s1_vseq extends axi_v_seqs;

        `uvm_object_utils(m0s0_m1s1_vseq)

        extern function new(string name="m0s0_m1s1_vseq");
        extern task body();
endclass

function m0s0_m1s1_vseq::new(string name="m0s0_m1s1_vseq");
        super.new(name);
endfunction

task m0s0_m1s1_vseq::body();
        super.body();

        m00_seq=master00_seq::type_id::create("m00_seq");
        m11_seq=master11_seq::type_id::create("m11_seq");


        fork
                m00_seq.start(m_seqrh[0]);
                m11_seq.start(m_seqrh[1]);
        join
endtask

class m0s1_m1s0_vseq extends axi_v_seqs;

        `uvm_object_utils(m0s1_m1s0_vseq)

        extern function new(string name="m0s1_m1s0_vseq");
        extern task body();
endclass

function m0s1_m1s0_vseq::new(string name="m0s1_m1s0_vseq");
        super.new(name);
endfunction

task m0s1_m1s0_vseq::body();
        super.body();

        m01_seq=master01_seq::type_id::create("m01_seq");
        m10_seq=master10_seq::type_id::create("m10_seq");

        fork
                m01_seq.start(m_seqrh[0]);
                m10_seq.start(m_seqrh[1]);
        join
endtask

class m0s0_m1s0_vseq extends axi_v_seqs;

        `uvm_object_utils(m0s0_m1s0_vseq)

        extern function new(string name="m0s0_m1s0_vseq");
        extern task body();
endclass

function m0s0_m1s0_vseq::new(string name="m0s0_m1s0_vseq");
        super.new(name);
endfunction

task m0s0_m1s0_vseq::body();
        super.body();

        m00_seq=master00_seq::type_id::create("m00_seq");
        m10_seq=master10_seq::type_id::create("m10_seq");

        fork
                m00_seq.start(m_seqrh[0]);
                m10_seq.start(m_seqrh[1]);
        join
endtask

class m0s1_m1s1_vseq extends axi_v_seqs;

        `uvm_object_utils(m0s1_m1s1_vseq)

        extern function new(string name="m0s1_m1s1_vseq");
        extern task body();
endclass

function m0s1_m1s1_vseq::new(string name="m0s1_m1s1_vseq");
        super.new(name);
endfunction

task m0s1_m1s1_vseq::body();
        super.body();

        m01_seq=master01_seq::type_id::create("m01_seq");
        m11_seq=master11_seq::type_id::create("m11_seq");

        fork

                m01_seq.start(m_seqrh[0]);
                m11_seq.start(m_seqrh[1]);
        join
endtask

class dec_err_vseq extends axi_v_seqs;

        `uvm_object_utils(dec_err_vseq)

        extern function new(string name="dec_err_vseq");
        extern task body();
endclass

function dec_err_vseq::new(string name="dec_err_vseq");
        super.new(name);
endfunction

task dec_err_vseq::body();
        super.body();

        de_seq=decerr_seq::type_id::create("de_seq");
        m11_seq=master11_seq::type_id::create("m11_seq");


        fork
                de_seq.start(m_seqrh[0]);
                m11_seq.start(m_seqrh[1]);
        join
endtask


class burst_three_vseq extends axi_v_seqs;

        `uvm_object_utils(burst_three_vseq)

        extern function new(string name="burst_three_vseq");
        extern task body();
endclass

function burst_three_vseq::new(string name="burst_three_vseq");
        super.new(name);
endfunction

task burst_three_vseq::body();
        super.body();

        b3_seq=burst3_seq::type_id::create("b3_seq");
        m10_seq=master10_seq::type_id::create("m10_seq");

        fork
                b3_seq.start(m_seqrh[0]);
                m10_seq.start(m_seqrh[1]);
        join
endtask

class masterslave_vseq extends axi_v_seqs;

        `uvm_object_utils(masterslave_vseq)

        extern function new(string name="masterslave_vseq");
        extern task body();
endclass

function masterslave_vseq::new(string name="masterslave_vseq");
        super.new(name);
endfunction

task masterslave_vseq::body();
        super.body();

        m101_seq=master12_seq::type_id::create("m101_seq");
        m111_seq=master13_seq::type_id::create("m111_seq");

        fork

                m101_seq.start(m_seqrh[0]);
                m111_seq.start(m_seqrh[1]);
        join
endtask

