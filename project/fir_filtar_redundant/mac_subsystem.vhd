
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mac_subsystem is
    generic (
        WIDTH_IN : natural := 2;
        K : natural := 3;
        N : natural := 5
    );
Port (clk: in std_logic;
       reset: in std_logic;
       en: in std_logic;
        a_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
        b_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
        mac_i: in std_logic_vector(2*WIDTH_IN - 1 downto 0);
        mac_o: out std_logic_vector(2*WIDTH_IN - 1 downto 0) );
end mac_subsystem;

architecture Behavioral of mac_subsystem is
--type mac_out_type is array(0 to N+K-1) of std_logic_vector(2*WIDTH_IN - 1 downto 0);
signal mac_out_s: std_logic_vector((K + N) * 2*WIDTH_IN - 1 downto 0);
signal switch_out_s: std_logic_vector(N*2*WIDTH_IN-1 downto 0);
signal voter_out_s: std_logic_vector(2*WIDTH_IN-1 downto 0);
signal sel_s: std_logic_vector(N * log2c(K+1) - 1 downto 0);
attribute dont_touch : string;
attribute dont_touch of mac_out_s : signal is "true";
attribute dont_touch of switch_out_s : signal is "true";
attribute dont_touch of voter_out_s : signal is "true";
attribute dont_touch of sel_s : signal is "true";
begin

switch_logic: entity work.switch
    generic map(WIDTH =>2*WIDTH_IN , K=>K, N=>N)
    port map(   input_vector =>mac_out_s,
                output_vector =>switch_out_s,
                sel_in =>sel_s);
    
voter_logc: entity work.voter
    generic map(WIDTH => 2*WIDTH_IN, N=>N)
    port map(   input_vector=>switch_out_s,
                output_vector=>voter_out_s);
  
decision_logic_inst: entity work.decision_logic
    generic map(WIDTH =>2*WIDTH_IN , K=>K, N=>N)
    port map(  clk=>clk,
               reset=>reset,
               input_from_voter=>switch_out_s,
               voted_data=>voter_out_s,
               sel_out=>sel_s);

mac_instances_n_plus_k: for i in 0 to (N+K-1) generate
    mac_s: entity work.mac
        generic map(WIDTH_IN=>WIDTH_IN, WIDTH_OUT=>2*WIDTH_IN)
        port map(   clk_i=>clk,
                    reset=>reset,
                    en=>en,
                    a_i=>a_i,
                    b_i=>b_i,
                    mac_i=>mac_i,
                    mac_o=>mac_out_s((i+1)*2*WIDTH_IN-1 downto 2*i*WIDTH_IN));
end generate;

mac_o <= voter_out_s;

end Behavioral;
