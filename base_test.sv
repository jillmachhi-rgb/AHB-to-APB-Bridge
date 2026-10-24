import uvm_pkg::*;
`include "uvm_macros.svh"

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    bridge_env env;

    virtual ahb_if ahb_vif;
    virtual apb_if apb_vif;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
            `uvm_fatal("NOVIF", "AHB interface not found in test")

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
            `uvm_fatal("NOVIF", "APB interface not found in test")

        uvm_config_db#(virtual ahb_if)::set(this, "env.ahb_agt.*", "vif", ahb_vif);
        uvm_config_db#(virtual apb_if)::set(this, "env.apb_mon", "vif", apb_vif);

        env = bridge_env::type_id::create("env", this);
    endfunction
endclass
