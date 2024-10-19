library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity modular_multiply_blakely is
    generic (
        C_block_size : integer := 256
    );
    port (
        clk             : in STD_LOGIC;
        rst_n           : in STD_LOGIC;
        a               : in STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
        b_i             : in STD_LOGIC;
        modulo          : in STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
        blakely_enable  : in STD_LOGIC;
        result          : out STD_LOGIC_VECTOR(C_block_size - 1 downto 0)
    );
end modular_multiply_blakely;

architecture rtl of modular_multiply_blakely is

-- Signal declaration
signal modulo_shifted    : STD_LOGIC_VECTOR(C_block_size downto 0);
signal result_nxt        : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
signal result_bitshift   : STD_LOGIC_VECTOR(C_block_size downto 0);
signal result_r          : STD_LOGIC_VECTOR(C_block_size - 1 downto 0);
signal sum_a             : STD_LOGIC_VECTOR(C_block_size downto 0);
signal mux_b             : STD_LOGIC_VECTOR(C_block_size downto 0);
signal sum_modulo        : STD_LOGIC_VECTOR(C_block_size downto 0);
signal sum_2modulo       : STD_LOGIC_VECTOR(C_block_size downto 0);
signal underflow1        : STD_LOGIC;
signal underflow2        : STD_LOGIC;
signal mux_b_underflow   : STD_LOGIC;

begin

-- Sequential process for clocked operations
process (clk, rst_n)
begin
    if rst_n = '0' then
        result_r <= (others => '0');
    elsif rising_edge(clk) then
        if blakely_enable = '1' then
            result_r <= result_nxt;
        end if;
    end if;
end process;

-- Combinational process for modular multiplication
process (a, b_i, modulo, modulo_shifted, result_r, result_bitshift, sum_a, mux_b, sum_modulo, sum_2modulo, underflow1, underflow2, mux_b_underflow)
begin
    result_bitshift <= STD_LOGIC_VECTOR(shift_left(resize(signed(result_r), C_block_size+1), 1));
    sum_a <= STD_LOGIC_VECTOR(unsigned(result_bitshift) + resize(unsigned(a), C_block_size+1));

    -- B[i] selection mux
    if (b_i = '1') then
        mux_b <= sum_a;
    else
        mux_b <= result_bitshift;
    end if;

    -- Calculate the intermediate values
    sum_modulo   <= STD_LOGIC_VECTOR(unsigned(mux_b) - resize(unsigned(modulo), C_block_size+1));
    sum_2modulo  <= STD_LOGIC_VECTOR(unsigned(mux_b) - unsigned(modulo_shifted));

    -- Underflow detection
    mux_b_underflow <= mux_b(C_block_size);
    underflow1 <= sum_modulo(C_block_size);
    underflow2 <= sum_2modulo(C_block_size) or underflow1;

    -- Final result selection
    if (underflow1 = '1' and underflow2 = '1' and mux_b_underflow = '0') then
        result_nxt <= mux_b(C_block_size-1 downto 0);
    elsif (underflow1 = '0' and underflow2 = '1') then
        result_nxt <= sum_modulo(C_block_size-1 downto 0);
    elsif (underflow2 = '0' or mux_b_underflow = '1') then
        result_nxt <= sum_2modulo(C_block_size-1 downto 0);
    else
        result_nxt <= (others => '0');
    end if;
    
    
    
end process;

-- Shift modulo left by 1
modulo_shifted <= STD_LOGIC_VECTOR(shift_left(resize(unsigned(modulo), C_block_size+1), 1));

-- Output assignment
result <= result_r;

end rtl;