library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	Generic (
		C_block_size : integer := 256
	);
	Port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC                 
	);
end exponentiation;

architecture expBehave of exponentiation is
    signal base        : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal exponent    : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal modulus_val : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal exponentiation_result  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    
    -- Multiplication signals
    signal load_a_reg  : STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'a'
    signal load_b_reg  : STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'b'
    signal multiplication_result  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    signal multiplication_done : STD_LOGIC := '0';
    
    -- FSM signals
    type state_type is (INIT, PROCESSING, OUTPUT);
    signal state : state_type := INIT;
    signal bit_index   : integer := 0; -- Index for the current bit of the exponent
    
begin
    u_modular_multiplier: entity work.modular_multiplier
--        generic map (
--            C_block_size        => C_block_size
--        )
    port map (
        -- Clock and Reset
        clk                 => clk,
        reset_and_load      => reset_n,
        
        -- Data
        factor_a    => load_a_reg,
        factor_b   => load_b_reg,
        modulus_n    => modulus_val,
        multiplication_result   => multiplication_result,
        done => multiplication_done
    );

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset all registers
            base <= (others => '0');
            exponent <= (others => '0');
            modulus_val <= (others => '0');
            exponentiation_result <= (others => '1'); -- Initialize result to 1
            bit_index <= 0;
            state <= INIT;
            valid_out <= '0';
            ready_in <= '1'; -- Ready for new input
        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    if valid_in = '1' then
                        base <= message;           -- Assign base from message
                        exponent <= key;           -- Assign exponent from key
                        modulus_val <= modulus;    -- Assign modulus
                        bit_index <= 0;            -- Start from the least significant bit
                        exponentiation_result <= (others => '1'); -- Initialize result to 1
                        ready_in <= '0'; -- Processing input
                        valid_out <= '0';
                        state <= PROCESSING;
                    end if;

                when PROCESSING =>
                    if bit_index < 256 then -- Iterate over bits of exponent from right to left
                        if exponent(bit_index) = '1' then
                            --exponentiation_result <= modular_multiply(exponentiation_result = factor_a, base = factor_b, modulus_val = modulus_n);
                        end if;

                        -- Square the base
                        --base <= modular_multiply(base = factor_a, base = factor_b, modulus_val = modulus_n);
                        bit_index <= bit_index + 1; -- Move to the next bit   //better to shift !!!!!
                    else
                        state <= OUTPUT; -- Move to the output state
                    end if;

                when OUTPUT =>
                    if(valid_out = '0') then
                        valid_out <= '1'; -- Indicate valid output and wait 1 clock cycle
                    elsif (ready_out = '1') then
                        result <= exponentiation_result; -- Output the result
                        state <= INIT; -- Reset to initial state after processing is complete
                        ready_in <= '1';
                        valid_out <= '0';
                    end if; -- legge til busy waiting 

                when others =>
                    state <= INIT; -- Default state to reset
                    ready_in <= '1';
                    valid_out <= '0';
            end case;
        end if;
    end process;

end expBehave;

