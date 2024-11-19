library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multicore_handler is
    Generic (
		C_block_size  : integer := 256;
		NUM_CORES     : integer := 4
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
end multicore_handler;

architecture Behavioral of multicore_handler is
    signal selected_core   : integer range 0 to NUM_CORES-1 := 0;
    
    signal core_valid_in  : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_ready_in : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_valid_out : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_data_out  : std_logic_vector((NUM_CORES*C_BLOCK_SIZE)-1 downto 0);
    
    type state_type is (INIT, WAIT_FOR_CORE, OUTPUT, INPUT);
    signal state : state_type := INIT;

begin
    gen_cores: for i in 0 to NUM_CORES-1 generate
        core_inst: entity work.exponentiation
            generic map (
                C_block_size => C_BLOCK_SIZE
            )
            port map (
                message   => message,
                key       => key,
                valid_in  => core_valid_in(i),
                ready_in  => core_valid_in(i),
                valid_out => core_valid_out(i),
                result    => core_data_out((i+1)*C_BLOCK_SIZE-1 downto i*C_BLOCK_SIZE),
                modulus   => modulus,
                clk       => clk,
                reset_n   => reset_n,
                msgin_last => msgin_last,
                msgout_last => msgout_last
            );
    end generate;
    

    process(clk, reset_n)
        if reset_n = '0' then
            selected_core <= 0;
            state <= INIT;
        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    if valid_in = '1' then
                        ready_in <= '0'; -- Processing input
                        valid_out <= '0';
                        state <= PROCESSING;
                        msgout_last_holder <= msgin_last;
                    end if;
    begin

end Behavioral;
