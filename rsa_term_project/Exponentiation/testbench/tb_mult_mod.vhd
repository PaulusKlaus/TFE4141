library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_modular_multiply_blakely is
end tb_modular_multiply_blakely;

architecture behavior of tb_modular_multiply_blakely is

    constant C_block_size : integer := 256;

    -- Signals for the DUT
    signal clk             : STD_LOGIC := '0';
    signal rst_n           : STD_LOGIC := '0';
    signal a               : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
    signal b_i             : STD_LOGIC;
    signal modulo          : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
    signal blakely_enable  : STD_LOGIC;
    signal result          : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.modular_multiply_blakely
        generic map (
            C_block_size => C_block_size
        )
        port map (
            clk             => clk,
            rst_n           => rst_n,
            a               => a,
            b_i             => b_i,
            modulo          => modulo,
            blakely_enable  => blakely_enable,
            result          => result
        );

    -- Clock generation
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst_n <= '0';
        blakely_enable <= '0';
        wait for 50 ns; -- Wait for some time for initialization
        rst_n <= '1';
        wait for 20 ns;

        -- Easy Test Case 1: a = 2, b_i = 1, modulo = 5
        -- Expected result: (2 * 1) % 5 = 2
        a <= std_logic_vector(to_unsigned(2, C_block_size));
        b_i <= '1';
        modulo <= std_logic_vector(to_unsigned(5, C_block_size));
        blakely_enable <= '1';
        wait for 50 ns; -- Allow time for the computation
        blakely_enable <= '0';
        wait for 100 ns; -- Wait longer to check result
        report "Test Case 1 Result: " & integer'image(to_integer(unsigned(result)));
        assert result = std_logic_vector(to_unsigned(2, C_block_size))
        report "Test Case 1 Failed: Expected result = 2" severity error;

        -- Easy Test Case 2: a = 7, b_i = 1, modulo = 10
        -- Expected result: (7 * 1) % 10 = 7
        a <= std_logic_vector(to_unsigned(7, C_block_size));
        b_i <= '1';
        modulo <= std_logic_vector(to_unsigned(10, C_block_size));
        blakely_enable <= '1';
        wait for 50 ns;
        blakely_enable <= '0';
        wait for 100 ns;
        report "Test Case 2 Result: " & integer'image(to_integer(unsigned(result)));
        assert result = std_logic_vector(to_unsigned(7, C_block_size))
        report "Test Case 2 Failed: Expected result = 7" severity error;

        -- Complex Test Case 1: a = 25, b_i = 1, modulo = 9
        -- Expected result: (25 * 1) % 9 = 7
        a <= std_logic_vector(to_unsigned(25, C_block_size));
        b_i <= '1';
        modulo <= std_logic_vector(to_unsigned(9, C_block_size));
        blakely_enable <= '1';
        wait for 50 ns;
        blakely_enable <= '0';
        wait for 100 ns;
        report "Complex Test Case 1 Result: " & integer'image(to_integer(unsigned(result)));
        assert result = std_logic_vector(to_unsigned(7, C_block_size))
        report "Complex Test Case 1 Failed: Expected result = 7" severity error;

        -- Complex Test Case 2: a = 12345, b_i = 1, modulo = 678
        -- Expected result: (12345 * 1) % 678 = 201
        a <= std_logic_vector(to_unsigned(12345, C_block_size));
        b_i <= '1';
        modulo <= std_logic_vector(to_unsigned(678, C_block_size));
        blakely_enable <= '1';
        wait for 50 ns;
        blakely_enable <= '0';
        wait for 100 ns;
        report "Complex Test Case 2 Result: " & integer'image(to_integer(unsigned(result)));
        assert result = std_logic_vector(to_unsigned(201, C_block_size))
        report "Complex Test Case 2 Failed: Expected result = 201" severity error;

        -- Complex Test Case 3: a = 99999, b_i = 1, modulo = 54321
        -- Expected result: (99999 * 1) % 54321 = 45678
        a <= std_logic_vector(to_unsigned(99999, C_block_size));
        b_i <= '1';
        modulo <= std_logic_vector(to_unsigned(54321, C_block_size));
        blakely_enable <= '1';
        wait for 50 ns;
        blakely_enable <= '0';
        wait for 100 ns;
        report "Complex Test Case 3 Result: " & integer'image(to_integer(unsigned(result)));
        assert result = std_logic_vector(to_unsigned(45678, C_block_size))
        report "Complex Test Case 3 Failed: Expected result = 45678" severity error;

        -- Simulation end
        wait;
    end process;

end behavior;
