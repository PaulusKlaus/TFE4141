library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multicore_handler is
    Generic (
		C_block_size  : integer := 256;
		NUM_CORES     : integer := 6
	);
	Port (
		-- Input control
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		-- Data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		-- Ouput control
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
    signal selected_core   : integer range 0 to NUM_CORES := 0;
    
    signal intermediate_message : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ) := (others => '0');
    signal intermediate_msgin_last : std_logic := '0';
        
    signal number_of_cores_to_use : integer range 0 to NUM_CORES := NUM_CORES;
    
    signal core_valid_in  : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_ready_in : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_valid_out : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_ready_out : std_logic_vector(NUM_CORES-1 downto 0);
    signal core_data_out  : std_logic_vector((NUM_CORES*C_BLOCK_SIZE)-1 downto 0);
    
    signal core_msgout_last : std_logic_vector(NUM_CORES-1 downto 0);
    
    type state_type is (OUTPUT, INPUT, FILLING_CORES, EMPTYING_CORES);
    signal state : state_type := FILLING_CORES;
    
    signal init_complete : std_logic := '0';

begin
    gen_cores: for i in 0 to NUM_CORES-1 generate
        core_inst: entity work.exponentiation
            generic map (
                C_block_size => C_BLOCK_SIZE
            )
            port map (
                message   => intermediate_message,
                key       => key,
                valid_in  => core_valid_in(i),
                ready_in  => core_ready_in(i),
                valid_out => core_valid_out(i),
                ready_out => core_ready_out(i),
                result    => core_data_out((i+1)*C_BLOCK_SIZE-1 downto i*C_BLOCK_SIZE),
                modulus   => modulus,
                clk       => clk,
                reset_n   => reset_n,
                msgin_last => intermediate_msgin_last,
                msgout_last => core_msgout_last(i)
            );
    end generate;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            selected_core <= 0;
            init_complete <= '0';
            valid_out <= '0';
            ready_in <= '1';
            state <= FILLING_CORES;
            core_valid_in <= (others=>'0');
            core_ready_out <= (others=>'0');
            intermediate_message <= (others=>'0');
            intermediate_msgin_last <= '0';
        elsif rising_edge(clk) then
            case state is
                when FILLING_CORES =>
                    if intermediate_msgin_last = '1' then
                        intermediate_msgin_last <= '0';
                        number_of_cores_to_use <= selected_core;
                    elsif selected_core = number_of_cores_to_use then
                        selected_core <= 0;
                        state <= EMPTYING_CORES;
                    else
                        ready_in <= '1';
                        state <= INPUT;
                    end if;
                    
                when INPUT =>
                    if valid_in = '1' and core_ready_in(selected_core) = '1' and ready_in = '1' then
                        ready_in <= '0';
                        intermediate_message <= message;
                        intermediate_msgin_last <= msgin_last;
                        core_valid_in(selected_core) <= '1';
                    elsif ready_in = '0' and core_ready_in(selected_core) = '0' then
                        core_valid_in(selected_core) <= '0';
                        selected_core <= (selected_core + 1);
                        state <= FILLING_CORES;
                    end if;
                    
                when EMPTYING_CORES =>
                    if selected_core = number_of_cores_to_use then
                        selected_core <= 0;
                        number_of_cores_to_use <= NUM_CORES;
                        state <= FILLING_CORES;
                    else
                        core_ready_out(selected_core) <= '1';
                        state <= OUTPUT;
                    end if;

                    
                when OUTPUT =>
                    if core_valid_out(selected_core) = '1' then
                        result <= core_data_out((selected_core+1)*C_BLOCK_SIZE-1 downto selected_core*C_BLOCK_SIZE);
                        msgout_last <= core_msgout_last(selected_core);
                        valid_out <= '1';
                    elsif ready_out = '1' and valid_out = '1' then
                        valid_out <= '0';
                        core_ready_out(selected_core) <= '0';
                        selected_core <= (selected_core + 1);
                        state <= EMPTYING_CORES;
                    end if;
                    
            end case;
        end if;
    end process;       
    

end Behavioral;