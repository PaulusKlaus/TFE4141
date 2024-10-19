library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modular_multiply_blakely_tb is
    -- No ports for a testbench
end modular_multiply_blakely_tb;

architecture behavior of modular_multiply_blakely_tb is

    -- Constants for the testbench
    constant C_block_size : integer := 256;

    -- Signals to connect to the DUT (Design Under Test)
    signal clk           : STD_LOGIC := '0';
    signal rst_n         : STD_LOGIC := '1';
    signal a             : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
    signal b_i             : STD_LOGIC := '1';
    signal modulo        : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
    signal blakely_enable: STD_LOGIC := '0';
    signal result        : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);

    -- Clock period constant
    constant clk_period  : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.modular_multiply_blakely
        generic map (
            C_block_size => C_block_size
        )
        port map (
            clk            => clk,
            rst_n          => rst_n,
            a              => a,
            b_i              => b_i,
            modulo         => modulo,
            blakely_enable => blakely_enable,
            result         => result
        );

    -- Clock process definition
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst_n <= '0';
        wait for clk_period * 2;
        rst_n <= '1';
        
        -- Test case 1: Simple multiplication
        a <= (others => '0');  -- Initialize to zero
        modulo <= (others => '0'); -- Initialize to zero
        

        
        -- Set some input values
        wait for clk_period * 5;
        a <= x"000000000000000000000000000000000000000000000000000000000000000A"; -- a = 10
        modulo <= x"0000000000000000000000000000000000000000000000000000000000000003"; -- modulo = 3
        b_i <= '1'; -- Set multiplier bit b = 1
        blakely_enable <= '1'; -- Enable the operation

        wait for clk_period * 10;

        -- Test case 2: Multiply with different modulo
        modulo <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"; 
        a <= x"85ee722363960779206a2b37cc8b64b5fc12a934473fa0204bbaaf714bc90c01";
        b_i <= '1'; -- b = 1, multiplication enabled

        wait for clk_period * 10;

        -- Test case 3: Test when b = 0 (no multiplication)
        b_i <= '0';
        wait for clk_period * 10;

        -- Test case 4: Disable the operation
         b_i <= '1';
        blakely_enable <= '0';
        wait for clk_period * 10;

        -- End of simulation
        wait;
    end process;

end behavior;
