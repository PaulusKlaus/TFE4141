library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC
	);
end exponentiation;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modular_exponentiation is
    generic (
        C_block_size : integer := 256
    );
    port (
        valid_in    : in STD_LOGIC;
        ready_in    : out STD_LOGIC;
        message      : in STD_LOGIC_VECTOR (C_block_size-1 downto 0); -- base
        key          : in STD_LOGIC_VECTOR (C_block_size-1 downto 0); -- exponent
        ready_out    : in STD_LOGIC;
        valid_out    : out STD_LOGIC;
        result       : out STD_LOGIC_VECTOR(C_block_size-1 downto 0); -- output result
        modulus      : in STD_LOGIC_VECTOR(C_block_size-1 downto 0); -- modulus
        clk          : in STD_LOGIC;
        reset_n      : in STD_LOGIC
    );
end modular_exponentiation;

architecture expBehave of modular_exponentiation is
    signal base        : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal exponent    : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal modulus_val : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal result_reg  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    signal state       : integer := 0; -- State variable for FSM
    signal bit_index   : integer := 0; -- Index for the current bit of the exponent
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset all registers
            base <= (others => '0');
            exponent <= (others => '0');
            modulus_val <= (others => '0');
            result_reg <= (others => '1'); -- Initialize result to 1
            bit_index <= 0;
            state <= 0;
            valid_out <= '0';
            ready_in <= '1'; -- Ready for new input
        elsif rising_edge(clk) then
            case state is
                when 0 =>
                    if valid_in = '1' then
                        base <= message;           -- Assign base from message
                        exponent <= key;           -- Assign exponent from key
                        modulus_val <= modulus;    -- Assign modulus
                        bit_index <= 0;            -- Start from the least significant bit
                        result_reg <= (others => '1'); -- Initialize result to 1
                        state <= 1;
                        ready_in <= '0'; -- Processing input
                        valid_out <= '0';
                    end if;

                when 1 =>
                    if bit_index < C_block_size then -- Iterate over bits of exponent from right to left
                        if exponent(bit_index) = '1' then
                            result_reg <= modular_multiply(result_reg, base, modulus_val);
                        end if;

                        -- Square the base
                        base <= modular_multiply(base, base, modulus_val);
                        bit_index <= bit_index + 1; -- Move to the next bit
                    else
                        state <= 2; -- Move to the output state
                    end if;

                when 2 =>
                    result <= result_reg; -- Output the result
                    valid_out <= '1'; -- Indicate valid output
                    if ready_out = '1' then
                        state <= 0; -- Reset to initial state after processing is complete
                        ready_in <= '1';
                        valid_out <= '0';
                    end if;

                when others =>
                    state <= 0; -- Default state to reset
                    ready_in <= '1';
                    valid_out <= '0';
            end case;
        end if;
    end process;

   function modular_multiply(a, b, n : STD_LOGIC_VECTOR(C_block_size-1 downto 0)) return STD_LOGIC_VECTOR(C_block_size-1 downto 0) is
        variable a_reg, b_reg, n_reg, res_reg : unsigned(C_block_size-1 downto 0);
    begin
    -- Initialize the variables
    a_reg := unsigned(a);
    b_reg := unsigned(b);
    n_reg := unsigned(n);
    res_reg := (others => '0'); -- Initialize result to 0

    -- Loop through each bit of 'b', starting from the least significant bit (LSB)
    for i in 0 to C_block_size-1 loop
        -- Shift res_reg to the left (equivalent to multiplying by 2)
        res_reg := res_reg sll 1;

        -- If the current bit of 'b' is 1, add a_reg to the result
        if b_reg(i) = '1' then
            res_reg := res_reg + a_reg;
        end if;

        -- Apply modulus if res_reg >= n_reg
        if res_reg >= n_reg then
            res_reg := res_reg - n_reg;
        end if;
    end loop;

    return std_logic_vector(res_reg);
end function modular_multiply;

end expBehave;
