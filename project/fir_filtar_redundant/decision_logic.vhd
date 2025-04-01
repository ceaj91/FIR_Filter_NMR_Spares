
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;

entity decision_logic is
generic (
        WIDTH : natural := 4;
        K : natural := 1;
        N : natural := 3
    );
Port ( clk:in std_logic;
       reset: in std_logic;
       input_from_voter: in std_logic_vector(N*WIDTH-1 downto 0);
       voted_data: in std_logic_vector(WIDTH-1 downto 0);
       sel_out: out std_logic_vector(N * log2c(K+1) - 1 downto 0));
end decision_logic;

architecture Behavioral of decision_logic is
type sel_type is array(0 to N-1) of std_logic_vector(log2c(K+1) - 1 downto 0);
type comparators_out_t is array(0 to N-1) of std_logic;

signal mux_sel_reg, mux_sel_next: sel_type;
signal num_of_broken_reg,num_of_broken_next: std_logic_vector(log2c(K+1) - 1 downto 0);
signal comparators_out: std_logic_vector(N-1 downto 0);
signal all_ones :std_logic_vector(N-1 downto 0) := (others=>'1');
begin

process(clk) is begin
    if(rising_edge(clk)) then
        if(reset = '1') then
            num_of_broken_reg<=(others=>'0');
            for i in 0 to N-1 loop
                mux_sel_reg(i)<=std_logic_vector(to_unsigned(0,log2c(K+1)));
            end loop;
            
        else
            num_of_broken_reg<=num_of_broken_next;
            for i in 0 to N-1 loop
                mux_sel_reg(i)<=mux_sel_next(i);
            end loop;
        end if;
    end if;
end process;

mux_sel_generate: for i in 0 to N-1 generate
    sel_out((i+1)*log2c(K+1) - 1 downto i*log2c(K+1)) <= mux_sel_reg(i);
end generate;

--logic for next broken
process(comparators_out,num_of_broken_reg,input_from_voter)is begin
     num_of_broken_next<=num_of_broken_reg;
    if comparators_out /= all_ones then
        if(num_of_broken_reg < std_logic_vector(to_unsigned(K,log2c(K+1)))) then
            num_of_broken_next <= std_logic_vector(unsigned(num_of_broken_reg) + to_unsigned(1,log2c(K+1)));
        end if;
    end if;

end process;

--logic to determine which output is fault
a: for i in 0 to N-1 generate
    process(input_from_voter,voted_data,num_of_broken_next,mux_sel_reg) is
    begin
    mux_sel_next(i) <= mux_sel_reg(i);
    if(input_from_voter((i+1)*WIDTH - 1 downto i*WIDTH) /= voted_data) then
        comparators_out(i) <= '0';
        if(num_of_broken_reg < std_logic_vector(to_unsigned(K,log2c(K+1)))) then
            mux_sel_next(i) <= num_of_broken_next;
        end if;
        
    else
        comparators_out(i) <= '1';
        
    end if;
    end process;
end generate;

end Behavioral;
