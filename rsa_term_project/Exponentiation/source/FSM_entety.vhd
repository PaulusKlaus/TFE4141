library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_controller is
    Port (
        -- Control signals to `exponentiation`
        start        : in STD_LOGIC;
        multiplication_done : in STD_LOGIC;
        ready_out    : in STD_LOGIC;
        exponent_bit : in std_logic;

        -- Signals to control the `exponentiation` entity
        load_a_reg   : out STD_LOGIC;
        load_b_reg   : out STD_LOGIC;
        multiply_enable : out STD_LOGIC;
        base_squared : out STD_LOGIC;
        result_valid : out STD_LOGIC;
        ready_in     : out STD_LOGIC;

        -- Clock and reset
        clk          : in STD_LOGIC;
        reset_n      : in STD_LOGIC
    );
end fsm_controller;

architecture Behavioral of fsm_controller is
    -- FSM State definition
    type state_type is (INIT, PROCESSING, WAIT_MULTIPLY, SQUARE_BASE, OUTPUT);
    signal state : state_type := INIT;

    -- Internal signals
    signal exponent_index : integer := 0;
    signal base_squared_flag, result_valid_flag  : std_logic := '0';  -- internal flag to indicate squaring 

begin

    base_squared <= base_squared_flag;
    result_valid <= result_valid_flag;
    
    
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset all signals
            state <= INIT;
            load_a_reg <= '0';
            load_b_reg <= '0';
            multiply_enable <= '0';
            base_squared_flag <= '0';
            result_valid_flag <= '0';
            ready_in <= '1';

        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    if start = '1' then
                        -- Start exponentiation process
                        ready_in <= '0';
                        result_valid_flag <= '0';
                        state <= PROCESSING;
                    end if;

                when PROCESSING =>
                    if exponent_index < 256 then -- Adjust based on bit size
                        -- Check if exponent bit is 1 to determine multiplication
                        if exponent_bit = '1' then
                            load_a_reg <= '1';
                            load_b_reg <= '1';
                            multiply_enable <= '1';
                            base_squared_flag <= '0';
                            state <= WAIT_MULTIPLY;
                        else
                            -- Proceed to squaring the base
                            state <= SQUARE_BASE;
                        end if;
                    else
                        -- Move to output after processing all bits
                        state <= OUTPUT;
                    end if;

                when WAIT_MULTIPLY =>
                    multiply_enable <= '0';
                    if multiplication_done = '1' then
                        -- Update states based on operation type (multiply/square)
                        if base_squared_flag = '1' then
                            base_squared_flag <= '0';
                            state <= PROCESSING;
                        else
                            state <= SQUARE_BASE;
                        end if;
                    end if;

                when SQUARE_BASE =>
                    load_a_reg <= '1';
                    load_b_reg <= '1';
                    multiply_enable <= '1';
                    base_squared_flag <= '1';
                    state <= WAIT_MULTIPLY;

                when OUTPUT =>
                    if result_valid_flag = '0' then
                        result_valid_flag <= '1';
                    end if;
                    if ready_out = '1' then
                        ready_in <= '1';
                        state <= INIT;
                    end if;

                when others =>
                    state <= INIT;
                    ready_in <= '1';
            end case;
        end if;
    end process;
end Behavioral;
