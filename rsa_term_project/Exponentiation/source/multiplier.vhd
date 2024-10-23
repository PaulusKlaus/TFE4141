library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modular_multiplier is
 Generic (
		C_block_size : integer := 256
    );
    Port (
        a        : in  STD_LOGIC_VECTOR(255 downto 0);  -- Input 'a'
        b        : in  STD_LOGIC_VECTOR(255 downto 0);  -- Input 'b'
        n        : in  STD_LOGIC_VECTOR(255 downto 0);  -- Modulus 'n'
        result   : out STD_LOGIC_VECTOR(255 downto 0);  -- Output result
        clk      : in  STD_LOGIC;                       -- Clock signal
        reset    : in  STD_LOGIC;                       -- reset signal
        done     : out STD_LOGIC                        -- Done signal
    );
end modular_multiplier;

architecture Behavioral of modular_multiplier is
    signal a_reg, b_reg, n_reg, res_reg, a_adder_input : STD_LOGIC_VECTOR(255 downto 0); -- Internal unsigned registers
    signal b_msb : std_logic;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                -- Initialize the registers
                a_reg <= a;
                b_reg <= b;
                n_reg <= n;
                res_reg <= (others => '0'); -- Initialize result to 0
            else
                b_msb <= b_reg(C_block_size -1);
                b_reg <= b_reg(C_block_size-2)&'0';
           end if;
       end if;
    end process;
    
    -- Process for shifting B at each clock cycle, b(i) is changed
    
    -- Process for updating A = A (if b(i)) or A = 0 (if b(i)=0), b(i) in sensitivity list
    
    -- Process for updating result = result*2 + A, mod n.
    
    
    
end Behavioral;
