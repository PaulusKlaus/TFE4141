library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity modular_multiplier is
 Generic (
		C_block_size : integer := 256
    );
    Port (
        a        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'a'
        b        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Input 'b'
        n        : in  STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Modulus 'n'
        result   : out STD_LOGIC_VECTOR(C_block_size -1 downto 0);  -- Output result
        clk      : in  STD_LOGIC;                       -- Clock signal
        reset    : in  STD_LOGIC;                       -- reset signal
        done     : out STD_LOGIC                        -- Done signal
    );
end modular_multiplier;

architecture Behavioral of modular_multiplier is
    signal b_reg : STD_LOGIC_VECTOR(C_block_size-1 downto 0); -- Internal unsigned registers
    signal a_reg, n_reg, a_adder_input, result_reg : UNSIGNED(C_block_size - 1 downto 0);
    signal intermediate_result, intermediate_result2, intermediate_result3 : UNSIGNED(C_block_size downto 0);
    signal b_msb : std_logic;
    signal counter : unsigned(8 downto 0);

begin
    -- Process for shifting B at each clock cycle, b(i) is changed (implement counter?)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                -- Initialize the registers
                a_reg <= UNSIGNED(a);
                b_reg <= b;
                n_reg <= UNSIGNED(n);
                done <= '0';
                b_msb <= '0';
                result_reg <= (others => '0'); -- Initialize result to 0
                result <= (others => '0');  -- Initialize result to 0
                counter <= (others => '0');
            else
                if counter < 256 then
                    b_msb <= b_reg(C_block_size - 1);
                    b_reg <= b_reg(C_block_size-2 downto 0)&'0';
                    counter <= counter + 1;
                    result_reg <= intermediate_result3(C_block_size - 1 downto 0); -- Very important that this update is clocked here
                else
                    done <= '1';
                    result <= STD_LOGIC_VECTOR(intermediate_result3(C_block_size - 1 downto 0)); -- If we use result_reg here, we get unbounded loop
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
        if intermediate_result > ('0' & n_reg) then
            intermediate_result2 <= intermediate_result - ('0' & n_reg);
        else
            intermediate_result2 <= intermediate_result;
        end if;
    end process;
    
    process(intermediate_result2)
    begin
        if intermediate_result2 > ('0' & n_reg) then
            intermediate_result3 <= intermediate_result2 - ('0' & n_reg);
        else
            intermediate_result3 <= intermediate_result2;
        end if;
    end process;
    
end Behavioral;
