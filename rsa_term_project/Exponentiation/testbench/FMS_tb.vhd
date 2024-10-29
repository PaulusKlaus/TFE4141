library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm_controller is
end tb_fsm_controller;

architecture sim of tb_fsm_controller is
    -- Signal declarations to connect with fsm_controller
    signal start               : STD_LOGIC := '0';
    signal multiplication_done : STD_LOGIC := '0';
    signal ready_out           : STD_LOGIC := '0';
    signal exponent_bit        : STD_LOGIC := '0';

    signal load_a_reg          : STD_LOGIC;
    signal load_b_reg          : STD_LOGIC;
    signal multiply_enable     : STD_LOGIC;
    signal base_squared        : STD_LOGIC;
    signal result_valid        : STD_LOGIC;
    signal ready_in            : STD_LOGIC;

    signal clk                 : STD_LOGIC := '0';
    signal reset_n             : STD_LOGIC := '1';

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the FSM controller
    uut: entity work.fsm_controller
        port map (
            start               => start,
            multiplication_done => multiplication_done,
            ready_out           => ready_out,
            exponent_bit        => exponent_bit,
            load_a_reg          => load_a_reg,
            load_b_reg          => load_b_reg,
            multiply_enable     => multiply_enable,
            base_squared        => base_squared,
            result_valid        => result_valid,
            ready_in            => ready_in,
            clk                 => clk,
            reset_n             => reset_n
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test procedure
    stimulus_process : process
    begin
        -- Reset the FSM
        reset_n <= '0';
        wait for clk_period;
        reset_n <= '1';
        wait for clk_period;

        -- Test 1: Start FSM and go through PROCESSING state
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Set exponent_bit to 1, simulating multiplication
        exponent_bit <= '1';
        wait for clk_period * 2;
        
        -- Signal multiplication completion
        multiplication_done <= '1';
        wait for clk_period;
        multiplication_done <= '0';

        -- Set exponent_bit to 0, simulating squaring
        exponent_bit <= '0';
        wait for clk_period * 2;
        
        -- Signal multiplication completion for squaring
        multiplication_done <= '1';
        wait for clk_period;
        multiplication_done <= '0';

        -- Finalize process by setting ready_out high to check OUTPUT state
        wait for clk_period;
        ready_out <= '1';
        wait for clk_period;
        ready_out <= '0';

        -- Reset and observe FSM returning to INIT state
        wait for clk_period * 2;

        -- End simulation
        wait;
    end process;
end sim;
