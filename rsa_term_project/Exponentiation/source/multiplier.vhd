library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modular_multiplier is
 Generic (
		C_block_size : integer := 256
    );
    Port (
        clk                     : in  STD_LOGIC;                       -- Clock signal
        reset_and_load          : in  STD_LOGIC;                       -- reset signal, active high
        factor_a                : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'a'
        factor_b                : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'b'
        modulus_n               : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Modulus 'n'
        multiplication_result   : out STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Output result
        done                    : out STD_LOGIC := '0'                       -- Done signal
    );
end modular_multiplier;

architecture Behavioral of modular_multiplier is
    signal b_reg : STD_LOGIC_VECTOR(C_block_size-1 downto 0); -- Internal unsigned registers
    signal a_reg, n_reg, a_adder_input, result_reg : UNSIGNED(C_block_size - 1 downto 0);
    signal intermediate_result, intermediate_result_finito : UNSIGNED(C_block_size downto 0);
    signal b_msb : std_logic := '0';
    signal counter : unsigned(8 downto 0) := (others => '0');

begin
    -- Process for shifting B at each clock cycle, b(i) is changed (implement counter?)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_and_load = '1' then
                -- Initialize and load the registers
                a_reg <= UNSIGNED(factor_a);
                b_reg <= factor_b;
                n_reg <= UNSIGNED(modulus_n);
                done <= '0';
                b_msb <= '0';
                result_reg <= (others => '0'); -- Initialize result to 0
                multiplication_result <= (others => '0');  -- Initialize result to 0
                counter <= (others => '0');
            else
                if counter < C_block_size then
                    b_msb <= b_reg(C_block_size - 1);
                    b_reg <= b_reg(C_block_size-2 downto 0)&'0';
                    counter <= counter + 1;
                    result_reg <= intermediate_result_finito(C_block_size - 1 downto 0); -- Very important that this update is clocked
                else
                    done <= '1';
                    multiplication_result <= STD_LOGIC_VECTOR(intermediate_result_finito(C_block_size - 1 downto 0)); -- If we use result_reg here, we get unbounded loop
                end if;
           end if;
       end if;
    end process;
   
    -- Process for updating A = A (if b(i)) or A = 0 (if b(i)=0), b(i) in sensitivity list
    process(b_msb)
    begin
        if b_msb='1' then
            a_adder_input <= a_reg;
        else
            a_adder_input <= (others => '0');
        end if;
    end process;
    
    -- Process for updating result = (result*2 + A) mod n.
    process(result_reg, a_adder_input) -- Very important that result_reg is in the sensitivity list
    begin
        intermediate_result <= (result_reg & '0') + ('0' & a_adder_input);
    end process;
    
    -- Process for mod n
    process(intermediate_result)
    begin
        if intermediate_result > (n_reg & '0') then
            intermediate_result_finito <= intermediate_result - (n_reg & '0');
        elsif intermediate_result > ('0' & n_reg) then
            intermediate_result_finito <= intermediate_result - ('0' & n_reg);
        else
            intermediate_result_finito <= intermediate_result;
        end if;
    end process;
    
end Behavioral;
