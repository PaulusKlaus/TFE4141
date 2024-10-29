

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_tb is

    generic(
    C_block_size : integer := 64
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
    signal a_tb, b_tb, n_tb         : STD_LOGIC_VECTOR(255 downto 0); -- Test vectors
    signal result_tb                : STD_LOGIC_VECTOR(255 downto 0); -- Result
    signal clk_tb                   : STD_LOGIC := '0';               -- Clock signal
    signal reset_and_load_tb        : STD_LOGIC := '1';               -- Reset signal
    signal done_tb                  : STD_LOGIC;                      -- Done signal

    constant clk_period : time := 10 ns;                      -- Clock period

begin

    -- Instantiate the unit under test (UUT)
    uut: modular_multiplier
        Generic map (
            C_block_size => 256
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
    begin
        -- Initialize inputs
        reset_and_load_tb <= '1';   -- Load values
        a_tb <= x"0000000000000000000000000000000000000000000000000000000000000002";  -- Input a = 2
        b_tb <= x"0000000000000000000000000000000000000000000000000000000000000003";  -- Input b = 3
        n_tb <= x"0000000000000000000000000000000000000000000000000000000000000005";  -- Modulus n = 5
        wait for clk_period * 5;  -- Wait for some clock cycles
        reset_and_load_tb <= '0';

        -- Wait for the operation to complete
        wait until done_tb = '1';

        -- Check result
        assert result_tb = x"0000000000000000000000000000000000000000000000000000000000000001"
            report "Test Failed for a=2, b=3, n=5" severity error;
            
            
                -- Test with maximum values
        reset_and_load_tb <= '1';
        a_tb <= x"0a23232323232323232323232323232323232323232323232323232323232323";  -- Max input a
        b_tb <= x"0a23232323232323232323232323232323232323232323232323232323232323";  -- Max input b
        n_tb <= x"666dae8c529a9798eac7a157ff32d7edfd77038f56436722b36f298907008973";  -- Modulus n = 4095
        wait for clk_period * 5;
        reset_and_load_tb <= '0';

        wait until done_tb = '1';

        -- Expected value will vary depending on the exact operation but here assumed to be checked with 0xFFF modulus behavior
        assert result_tb = x"43593D3D381F155A604E2D59CBCAE7DD45F9A3052004A8A68E804B7073441069"  -- Replace with the actual result expected
            report "Test Failed for max values of a and b with n=4095" severity error;
    
                     
--                -- Test with maximum values
--        reset_and_load_tb <= '1';
--        a_tb <= std_logic_vector(to_unsigned( 16#13#, C_block_size));
--        b_tb <=std_logic_vector(to_unsigned( 16#56#, C_block_size));  -- Max input b
--        n_tb <= x"FFFFFFFFFFFFFF89";  -- Modulus n = 4095
--        wait for clk_period * 5;
--        reset_and_load_tb <= '0';

--        wait until done_tb = '1';

--        -- Expected value will vary depending on the exact operation but here assumed to be checked with 0xFFF modulus behavior
--        assert result_tb = x"000000000000000000000000000000000000000000000000000000000000000D"  -- Replace with the actual result expected
--            report "Test Failed for max values of a and b with n=4095" severity error;
    
               
            

        -- Apply next set of inputs
        reset_and_load_tb <= '1';   -- Load values
        a_tb <= x"000000000000000000000000000000000000000000000000000000000000000A";  -- Input a = 10
        b_tb <= x"0000000000000000000000000000000000000000000000000000000000000007";  -- Input b = 7
        n_tb <= x"000000000000000000000000000000000000000000000000000000000000000D";  -- Modulus n = 13
        wait for clk_period * 5;
        reset_and_load_tb <= '0';

        -- Wait for the operation to complete
        wait until done_tb = '1';

        -- Check result
        assert result_tb = x"0000000000000000000000000000000000000000000000000000000000000005"
            report "Test Failed for a=10, b=7, n=13" severity error;

        -- End simulation
        wait;
    end process;

end Behavioral;
