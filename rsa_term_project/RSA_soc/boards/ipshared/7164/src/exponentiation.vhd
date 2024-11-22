library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentiation is
	Generic (
		C_block_size : integer := 256
	);
	Port (
		-- Input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		-- Data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		-- Ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		-- Utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;     
		
		-- Last message
		msgin_last  : in STD_LOGIC;       
		msgout_last : out STD_LOGIC     
	);
end exponentiation;

architecture Behavioral of exponentiation is
    signal base        : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal exponent    : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal modulus_val : STD_LOGIC_VECTOR(C_block_size-1 downto 0);
    signal exponentiation_result  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    signal no_need_for_multiplication : STD_LOGIC := '0';
    
    -- Multiplication signals
    signal load_a_reg  : STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'a'
    signal load_b_reg  : STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'b'
    signal multiplication_result  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    signal multiplication_done : STD_LOGIC := '0';
    
    -- Multiplication for squaring base signals
    signal square_base_result  : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
    signal square_base_done : STD_LOGIC := '0';
    
    -- FSM signals
     type state_type is (INIT, WAIT_MULTIPLY, PROCESSING, OUTPUT);
    signal state : state_type := INIT;
    signal exponent_index   : integer := 0; -- Index for the current bit of the exponent
    signal base_squared : STD_LOGIC := '0';
    signal load_multiplier : STD_LOGIC := '0';
    
    signal msgout_last_holder : STD_LOGIC := '0';

    
begin
    u_modular_multiplier: entity work.modular_multiplier
--        generic map (
--            C_block_size        => C_block_size
--        )
    port map (
        -- Clock and Reset
        clk                 => clk,
        reset_and_load      => load_multiplier,
        
        -- Data
        factor_a                => load_a_reg,
        factor_b                => load_b_reg,
        modulus_n               => modulus_val,
        multiplication_result   => multiplication_result,
        done                    => multiplication_done
    );
    
    u_modular_multiplier_for_squaring_base: entity work.modular_multiplier
--        generic map (
--            C_block_size        => C_block_size
--        )
    port map (
        -- Clock and Reset
        clk                 => clk,
        reset_and_load      => load_multiplier,
        
        -- Data
        factor_a                => base,
        factor_b                => base,
        modulus_n               => modulus_val,
        multiplication_result   => square_base_result,
        done                    => square_base_done
    );

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset all registers
            base <= (others => '0');
            exponent <= (others => '0');
            modulus_val <= (others => '0');
            exponentiation_result <= (0 => '1', others => '0'); -- Initialize result to 1
            exponent_index <= 0;
            state <= INIT;
            valid_out <= '0';
            ready_in <= '1'; -- Ready for new input
            load_multiplier <= '0';
            base_squared <= '0';
            
        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    if valid_in = '1' then
                        base <= message;           -- Assign base from message
                        exponent <= key;           -- Assign exponent from key
                        modulus_val <= modulus;    -- Assign modulus
                        exponent_index <= 0;       -- Start from the least significant bit
                        exponentiation_result <= (0 => '1', others => '0'); -- Initialize result to 1
                        ready_in <= '0'; -- Processing input
                        valid_out <= '0';
                        state <= PROCESSING;
                        msgout_last_holder <= msgin_last;
                    end if;

                when PROCESSING =>
                    if exponent_index < C_block_size then -- Iterate over bits of exponent from right to left
                        -- Multiply result with base if exponent bit is 1
                        if exponent(exponent_index) = '1' then
                            no_need_for_multiplication <= '0';
                            load_a_reg <= exponentiation_result;
                            load_b_reg <= base;
                            load_multiplier <= '1';
                            if multiplication_done = '0' and square_base_done = '0' then   -- Wait for multiplier to load
                                state <= WAIT_MULTIPLY;          
                            end if;
                        else -- Go directly to squaring
                            no_need_for_multiplication <= '1';
                            load_multiplier <= '1';
                            if square_base_done = '0' then   -- Wait for multiplier to load
                                state <= WAIT_MULTIPLY;          
                            end if;
                        end if;
                    else
                        state <= OUTPUT; -- Move to the output state
                    end if;
                    
                when WAIT_MULTIPLY =>
                    load_multiplier <= '0';
                    if multiplication_done = '1' and square_base_done = '1' then
                        base <= square_base_result;
                        exponentiation_result <= multiplication_result; -- Update result
                        exponent_index <= exponent_index + 1;
                        state <= PROCESSING;
                    elsif no_need_for_multiplication = '1' and square_base_done = '1' then
                        base <= square_base_result;
                        exponent_index <= exponent_index + 1;
                        state <= PROCESSING;
                    end if;

                when OUTPUT =>   
                    if (valid_out = '0') then
                        result <= exponentiation_result; -- Output the result
                        msgout_last <= msgout_last_holder;
                        valid_out <= '1'; -- Indicate valid output
                    elsif (ready_out = '1') then
                        ready_in <= '1';
                        valid_out <= '0';
                        state <= INIT; -- Reset to initial state after processing is complete
                    end if;

                when others =>
                    state <= INIT; -- Default state to reset
                    ready_in <= '1';
                    valid_out <= '0';
            end case;
        end if;
    end process;

end Behavioral;