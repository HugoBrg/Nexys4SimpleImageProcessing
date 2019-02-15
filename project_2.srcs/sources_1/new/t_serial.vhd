-- EB Mar 2013
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

entity t_serial is
port(
  sys_clk: in std_logic; -- 100 MHz system clock
  
  led: out std_logic_vector(7 downto 0);
  uart_rx: in std_logic;
  uart_tx: out std_logic;
  
  reset_btn: in std_logic
);
end t_serial;

architecture Behavioral of t_serial is

component basic_uart is
generic (
  DIVISOR: natural
);
port (
  clk: in std_logic;   -- system clock
  reset: in std_logic;
  
  -- Client interface
  rx_data: out std_logic_vector(7 downto 0);  -- received byte
  rx_enable: out std_logic;  -- validates received byte (1 system clock spike)
  tx_data: in std_logic_vector(7 downto 0);  -- byte to send
  tx_enable: in std_logic;  -- validates byte to send if tx_ready is '1'
  tx_ready: out std_logic;  -- if '1', we can send a new byte, otherwise we won't take it
  
  -- Physical interface
  rx: in std_logic;
  tx: out std_logic
);
end component;

type fsm_state_t is (idle, received, emitting);
type state_t is
record
  fsm_state: fsm_state_t; -- FSM state
  tx_data: std_logic_vector(7 downto 0);
  tx_enable: std_logic;
end record;

signal reset: std_logic;
signal uart_rx_data: std_logic_vector(7 downto 0);
signal uart_rx_enable: std_logic;
signal uart_tx_data: std_logic_vector(7 downto 0);
signal uart_tx_enable: std_logic;
signal uart_tx_ready: std_logic;

signal rx_integer: integer;
signal rx_real: real;

signal R: std_logic_vector(2 downto 0);
signal G: std_logic_vector(2 downto 0);
signal B: std_logic_vector(1 downto 0);
signal RGB : std_logic_vector(7 downto 0);

signal R_int: integer;
signal G_int: integer;
signal B_int: integer;

signal R_sin : unsigned (2 downto 0);
signal G_sin : unsigned (2 downto 0);
signal B_sin : unsigned (1 downto 0);
signal RGB_sin : unsigned (7 downto 0);

signal state,state_next: state_t;

begin

  basic_uart_inst: basic_uart
  generic map (DIVISOR => 2604) -- 2400
  port map (
    clk => sys_clk, reset => reset,
    rx_data => uart_rx_data, rx_enable => uart_rx_enable,
    tx_data => uart_tx_data, tx_enable => uart_tx_enable, tx_ready => uart_tx_ready,
    rx => uart_rx,
    tx => uart_tx
  );

  reset_control: process (reset_btn) is
  begin
    if reset_btn = '1' then
      reset <= '0';
    else
      reset <= '1';
    end if;
  end process;
  
  
  fsm_clk: process (sys_clk,reset) is
  begin
    if reset = '1' then
      state.fsm_state <= idle;
      state.tx_data <= (others => '0');
      state.tx_enable <= '0';
    else
      if rising_edge(sys_clk) then
        state <= state_next;
      end if;
    end if;
  end process;

  fsm_next: process (state,uart_rx_enable,uart_rx_data,uart_tx_ready) is
  begin
    state_next <= state;
    case state.fsm_state is
    
    when idle =>
      if uart_rx_enable = '1' then
        
        R <= uart_rx_data(2 downto 0);
        G <= uart_rx_data(5 downto 3);
        B <= uart_rx_data(7 downto 6);
        
--        R_int <= to_integer(unsigned(R));
--        G_int <= to_integer(unsigned(G));
--        B_int <= to_integer(unsigned(B));
        
--        R_sin <= to_unsigned(R_int,R_sin'length);
--        G_sin <= to_unsigned(G_int,G_sin'length);
--        B_sin <= to_unsigned(B_int,B_sin'length);
        
--        R_sin(2 downto 2) <= "0"; 
--        R_sin(1 downto 1) <= "0"; 
--        R_sin(0 downto 0) <= "0"; 
        
--        RGB_sin(2 downto 0) <= R_sin (2 downto 0);
--        RGB_sin(5 downto 3) <= G_sin (2 downto 0);
--        RGB_sin(7 downto 6) <= B_sin (1 downto 0);
        
--        R(2 downto 2) <= "0"; 
--        R(1 downto 1) <= "0"; 
--        R(0 downto 0) <= "0"; 
--        B(1 downto 1) <= "0";
        
        
        
        RGB(2 downto 0) <= R(2 downto 0);
        RGB(5 downto 3) <= G(2 downto 0);
        RGB(7 downto 6) <= "00";
        
        
--        RGB_sin (7 downto 7) <= "0";
--        RGB_sin (6 downto 6) <= "0";
--        RGB_sin (5 downto 5) <= "0";
--        RGB_sin (4 downto 4) <= "0";
--        RGB_sin (3 downto 3) <= "0";
--        RGB_sin (2 downto 2) <= "0";
--        RGB_sin (1 downto 1) <= "0";
--        RGB_sin (0 downto 0) <= "0";

        state_next.tx_data(7 downto 0) <= RGB (7 downto 0);
        --state_next.tx_data <= std_logic_vector(to_unsigned(rx_integer,state_next.tx_data'length));
        state_next.tx_enable <= '0';
        state_next.fsm_state <= received;
      end if;
      
    when received =>
      if uart_tx_ready = '1' then
        state_next.tx_enable <= '1';
        state_next.fsm_state <= emitting;
      end if;
      
    when emitting =>
      if uart_tx_ready = '0' then
        state_next.tx_enable <= '0';
        state_next.fsm_state <= idle;
      end if;
      
    end case;
  end process;
  
  fsm_output: process (state) is
  begin
  
    uart_tx_enable <= state.tx_enable;
    uart_tx_data <= state.tx_data;
    led <= state.tx_data;
    
  end process;
  
end Behavioral;

