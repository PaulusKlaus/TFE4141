

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_tb is

    generic(
    C_block_size : integer := 256
    );
end multiplier_tb;

architecture Behavioral of multiplier_tb is
 -- Component declaration of the unit under test (UUT)
    component modular_multiplier
    Generic (
        C_block_size : integer := 256
    );
    Port (
        factor_a                : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        factor_b                : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        modulus_n               : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        multiplication_result   : out STD_LOGIC_VECTOR(C_block_size -1 downto 0);
        clk                     : in  STD_LOGIC;
        reset_and_load          : in  STD_LOGIC;
        done                    : out STD_LOGIC
    );
    end component;

    -- Testbench signals
    signal a_tb, b_tb, n_tb         : STD_LOGIC_VECTOR(C_block_size -1 downto 0); -- Test vectors
    signal result_tb                : STD_LOGIC_VECTOR(C_block_size -1 downto 0); -- Result
    signal clk_tb                   : STD_LOGIC := '0';               -- Clock signal
    signal reset_and_load_tb        : STD_LOGIC := '1';               -- Reset signal
    signal done_tb                  : STD_LOGIC;                      -- Done signal

    constant clk_period : time := 10 ns;                      -- Clock period

begin

    -- Instantiate the unit under test (UUT)
    uut: modular_multiplier
        Generic map (
            C_block_size => 8
        )
        Port map (
            factor_a => a_tb,
            factor_b => b_tb,
            modulus_n => n_tb,
            multiplication_result => result_tb,
            clk => clk_tb,
            reset_and_load => reset_and_load_tb,
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
        constant a1 : unsigned(C_block_size-1 downto 0) := to_unsigned(5, C_block_size);
        constant b1 : unsigned(C_block_size-1 downto 0) := to_unsigned(5, C_block_size);
        constant n1 : unsigned(C_block_size-1 downto 0) := to_unsigned(13, C_block_size);
        constant expected1 : unsigned(C_block_size-1 downto 0) := to_unsigned(12, C_block_size);

    begin
        -- Initialize inputs
        reset_and_load_tb <= '1';   -- Load values
        a_tb <= std_logic_vector(a1);  -- Input a = 10
        b_tb <= std_logic_vector(b1);  -- Input b = 7
        n_tb <= std_logic_vector(n1);  -- Modulus n = 13
        wait for clk_period * 5;  -- Wait for some clock cycles
        reset_and_load_tb <= '0';

        -- Wait for the operation to complete
        wait until done_tb = '1';

        -- Check result
        assert result_tb = std_logic_vector(expected1);
            report "Test Failed for a=5, b=5, n=13" severity error;
        
        wait;
    end process;

end Behavioral;
