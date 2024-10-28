----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2024 14:13:08
-- Design Name: 
-- Module Name: multiplier_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_tb is
end multiplier_tb;

architecture Behavioral of multiplier_tb is
 -- Component declaration of the unit under test (UUT)
    component modular_multiplier
    Generic (
        C_block_size : integer := 256
    );
    Port (
        a        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        b        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        n        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        result   : out STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        done     : out STD_LOGIC
    );
    end component;

    -- Testbench signals
    signal a_tb, b_tb, n_tb : STD_LOGIC_VECTOR(255 downto 0); -- Test vectors
    signal result_tb        : STD_LOGIC_VECTOR(255 downto 0); -- Result
    signal clk_tb           : STD_LOGIC := '0';               -- Clock signal
    signal reset_tb         : STD_LOGIC := '0';               -- Reset signal
    signal done_tb          : STD_LOGIC;                      -- Done signal

    constant clk_period : time := 10 ns;                      -- Clock period

begin

    -- Instantiate the unit under test (UUT)
    uut: modular_multiplier
        Generic map (
            C_block_size => 256
        )
        Port map (
            a => a_tb,
            b => b_tb,
            n => n_tb,
            result => result_tb,
            clk => clk_tb,
            reset => reset_tb,
            done => done_tb
        );

    -- Clock process definitions
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process clk_process;

    -- Stimulus process
    stimulus: process
    begin
        -- Initialize inputs
        reset_tb <= '1';
        a_tb <= (others => '0'); 
        b_tb <= (others => '0'); 
        n_tb <= (others => '0');
        wait for clk_period * 5;  -- Wait for some clock cycles

        -- Apply stimulus
        reset_tb <= '0';   -- Apply reset
        a_tb <= x"0000000000000000000000000000000000000000000000000000000000000002";  -- Input a = 2
        b_tb <= x"0000000000000000000000000000000000000000000000000000000000000003";  -- Input b = 3
        n_tb <= x"0000000000000000000000000000000000000000000000000000000000000005";  -- Modulus n = 5
        wait for clk_period * 5;  -- Wait for some clock cycles

        reset_tb <= '1';

        -- Wait for the operation to complete
        wait until done_tb = '1';

        -- Check result
        assert result_tb = x"0000000000000000000000000000000000000000000000000000000000000001"
            report "Test Failed for a=2, b=3, n=5" severity error;

        -- Apply next set of inputs
        reset_tb <= '1';   -- Apply reset again
        wait for clk_period * 5;
        reset_tb <= '0';   -- Release reset
        a_tb <= x"000000000000000000000000000000000000000000000000000000000000000A";  -- Input a = 10
        b_tb <= x"0000000000000000000000000000000000000000000000000000000000000007";  -- Input b = 7
        n_tb <= x"000000000000000000000000000000000000000000000000000000000000000D";  -- Modulus n = 13
        wait for clk_period * 5;
        reset_tb <= '1';   -- Apply reset again

        -- Wait for the operation to complete
        wait until done_tb = '1';

        -- Check result
        assert result_tb = x"0000000000000000000000000000000000000000000000000000000000000005"
            report "Test Failed for a=10, b=7, n=13" severity error;

        -- End simulation
        wait;
    end process;

end Behavioral;
