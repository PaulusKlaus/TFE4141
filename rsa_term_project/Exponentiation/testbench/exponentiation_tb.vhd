library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- For unsigned types and arithmetic functions

entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;

architecture Behavioral of exponentiation_tb is

	-- Data
	signal message 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal key 			: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    
    -- Input Control
	signal valid_in 	: STD_LOGIC := '0';
	signal ready_in 	: STD_LOGIC;
	
	-- Output Control
	signal ready_out 	: STD_LOGIC := '1';
	signal valid_out 	: STD_LOGIC;
	
	-- Utility
	signal clk 			: STD_LOGIC := '0';
	signal reset_n 		: STD_LOGIC := '1';

	-- Clock period constant
	constant clk_period : time := 10 ns;

begin

	-- Instantiate the unit under test (UUT)
	u_exponentiation : entity work.exponentiation
		port map (
			message   => message,
			key       => key,
			modulus   => modulus,
			result    => result,

			valid_in  => valid_in,
			ready_in  => ready_in,

			ready_out => ready_out,
			valid_out => valid_out,

			clk       => clk,
			reset_n   => reset_n
		);

	-- Clock generation process
	clk_process : process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_process;

	-- Stimulus process
	stimulus_process : process
		-- Test vectors (using unsigned directly)
		constant base1 : unsigned(C_block_size-1 downto 0) := to_unsigned(5, C_block_size);
		constant exponent1 : unsigned(C_block_size-1 downto 0) := to_unsigned(3, C_block_size);
		constant modulus1 : unsigned(C_block_size-1 downto 0) := to_unsigned(13, C_block_size);
		constant expected_result1 : unsigned(C_block_size-1 downto 0) := to_unsigned(8, C_block_size); -- (5^3 mod 13) = 8

		constant base2 : unsigned(C_block_size-1 downto 0) := to_unsigned(6, C_block_size);
		constant exponent2 : unsigned(C_block_size-1 downto 0) := to_unsigned(4, C_block_size);
		constant modulus2 : unsigned(C_block_size-1 downto 0) := to_unsigned(17, C_block_size);
		constant expected_result2 : unsigned(C_block_size-1 downto 0) := to_unsigned(4, C_block_size); -- (6^4 mod 17) = 4

	begin
		-- Initial reset
		reset_n <= '0';
		wait for 20 ns;
		reset_n <= '1';

		-- Test Case 1: (5^3 mod 13)
		message <= std_logic_vector(base1); -- Convert from unsigned to STD_LOGIC_VECTOR for assignment
		key <= std_logic_vector(exponent1); -- Convert from unsigned to STD_LOGIC_VECTOR for assignment
		modulus <= std_logic_vector(modulus1); -- Convert from unsigned to STD_LOGIC_VECTOR for assignment
		valid_in <= '1';
		wait for clk_period; -- Wait for one clock cycle
		valid_in <= '0';

		-- Wait for the result to be valid
		wait until valid_out = '1';
		wait for clk_period; -- Give extra cycle to stabilize output
		-- Check the result
		assert result = std_logic_vector(expected_result1)
			report "Test case failed" severity error;

		-- Test Case 2: (6^4 mod 17)
		message <= std_logic_vector(base2);
		key <= std_logic_vector(exponent2);
		modulus <= std_logic_vector(modulus2);
		valid_in <= '1';
		wait for clk_period;
		valid_in <= '0';

		-- Wait for the result to be valid
		wait until valid_out = '1';
		wait for clk_period;
		-- Check the result
		assert result = std_logic_vector(expected_result2)
			report "Test case 2 failed: (6^4 mod 17) should be 4" severity error;

		-- End simulation
		wait;
	end process stimulus_process;

end Behavioral;
