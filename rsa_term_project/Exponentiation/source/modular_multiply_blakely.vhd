library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity modular_multiply_blakely is
    generic (
        C_block_size : integer := 256
    );
    port (
        -- Clock and reset
        clk             :  in STD_LOGIC;
        rst_n           :  in STD_LOGIC;

        -- Inputs
        a               :  in STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
        b_i               :  in STD_LOGIC;
        modulo          :  in STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
        blakely_enable  :  in STD_LOGIC;

        -- Outputs
        result          : out STD_LOGIC_VECTOR(C_block_size - 1 downto 0)
    );
end modular_multiply_blakely;

architecture rtl of modular_multiply_blakely is

-- Signal declaration 
-- Shifted value of modulo 
signal modulo_shifted        : STD_LOGIC_VECTOR(C_block_size downto 0);

signal result_nxt       : STD_LOGIC_VECTOR(C_block_size - 1 downto 0); --next state of result 
signal result_bitshift  : STD_LOGIC_VECTOR(C_block_size downto 0);
signal result_r         : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);  -- current state of result 

signal sum_a            : STD_LOGIC_VECTOR(C_block_size downto 0);
signal mux_b           : STD_LOGIC_VECTOR(C_block_size downto 0); -- resut of multiplexer 
signal sum_modulo            : STD_LOGIC_VECTOR(C_block_size downto 0);
signal sum_2modulo           : STD_LOGIC_VECTOR(C_block_size downto 0);

-- Flags to todect if an underflow condition has occurred 
signal underflow1       : STD_LOGIC;
signal underflow2       : STD_LOGIC;
signal mux_b_underflow : STD_LOGIC;  


begin

-- Sequential process (clocked block)
-- updating result_r based on the next state result_nxt

    process (clk)
    begin
        if (rising_edge(clk)) then
            if  blakely_enable = '1' then
                result_r <= result_nxt;
            else 
                result_r <= result_r;
            end if;
        end if;
     end process;          
    

-- Combinatorial modulat_multiplication algorithm

    process ( a, b_i, modulo, modulo_shifted, result_r, result_nxt, result_bitshift, sum_a, mux_b, sum_modulo, sum_2modulo, underflow1, underflow2, mux_b_underflow)
    begin
            -- Calculate some intermediate values
        result_bitshift <= STD_LOGIC_VECTOR(shift_left(resize(signed(result_r), C_block_size+1), 1));
        sum_a <= STD_LOGIC_VECTOR(unsigned(result_bitshift) + resize(unsigned(a), C_block_size+1));
        
        -- B[i] selection mux
        if(b_i = '1') then
            mux_b <= sum_a;
        else
            mux_b <= result_bitshift;
        end if;
        
        -- Calculate the intermediate values
        sum_modulo   <= STD_LOGIC_VECTOR(unsigned(resize(signed(mux_b), C_block_size+1)) - (resize(unsigned(modulo), C_block_size+1)));
        sum_2modulo  <= STD_LOGIC_VECTOR(unsigned(resize(signed(mux_b), C_block_size+1)) - (unsigned(modulo_shifted)));
        mux_b_underflow <= mux_b(C_block_size);
        underflow1 <= sum_modulo(C_block_size);
        underflow2 <= sum_2modulo(C_block_size) or underflow1;
        
        -- Final selection mux
        if(underflow1 = '1' AND underflow2 = '1' AND mux_b_underflow = '0') then
           result_nxt <= mux_b(C_block_size - 1 downto 0);
        elsif(underflow1 = '0' AND underflow2 = '1') then
            result_nxt <= sum_modulo(C_block_size - 1 downto 0);
        elsif(underflow2 = '0' or mux_b_underflow = '1') then
            result_nxt <= sum_2modulo(C_block_size - 1 downto 0);
        else
            result_nxt <= (others => '0');
        end if;
    end process;
    
    -- Other minor logic
    result <= result_r;
    modulo_shifted <= STD_LOGIC_VECTOR(shift_left(resize(unsigned(modulo), C_block_size+1), 1));
   
end rtl;
