-------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity subtractor_256b is
    generic (
		C_block_size : integer := 256
	);
    port ( 
        A       : in std_logic_vector(C_block_size downto 0);
        B_2s       : in std_logic_vector(C_block_size downto 0);--Must be in 2s complement
        
        result  : out std_logic_vector(C_block_size-1 downto 0);
        borrow  : out std_logic
    );
end subtractor_256b;

architecture Behavioral of subtractor_256b is
    signal tempRes, tmpA,tmpB : std_logic_vector(C_block_size+1 downto 0); --One extra bit for carry
    signal overflow: std_logic;
    
    
begin
    process(A, B_2s) begin
        tmpA <=  ('0' & A);  
        tmpB <=  ('1' & B_2s); 
        --tmpB <=  '0' & B_2s;  
    end process;
    
    process(tmpA,tmpB) begin
        tempRes <= tmpA + tmpB;
        --tempRes <=  + ('1' & B_2s);
        --tempRes <= tmpA - tmpB;
        --tempRes <= std_logic_vector(('0' & '0' & unsigned(A)) + ('1' & '1' & unsigned(B)));
        
    end process;
    
    process(tempRes) begin
        result <= tempRes(C_block_size-1 downto 0);
        overflow <= tempRes(C_block_size+1) xor tempRes(C_block_size);
        borrow <= tempRes(C_block_size+1);
    end process;

end Behavioral;
