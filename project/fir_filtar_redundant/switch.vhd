library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;
use IEEE.NUMERIC_STD.ALL;
entity switch is
    generic (
        WIDTH : natural := 48;
        K : natural := 8;
        N : natural := 3
    );
    port (
        input_vector : in std_logic_vector((K + N) * WIDTH - 1 downto 0);
        output_vector : out std_logic_vector(N * WIDTH - 1 downto 0);
        sel_in : in std_logic_vector(N * log2c(K + 1) - 1 downto 0)
    );
end switch;

architecture Behavioral of switch is
    type mux_inputs_type is array (0 to N-1) of std_logic_vector((K+1)*WIDTH - 1 downto 0);
    signal mux_inputs : mux_inputs_type;
begin


muxes: for i in 0 to N-1 generate

    mux_inputs(i) <= input_vector((i+1)*WIDTH-1 downto i*WIDTH) & input_vector((K + N) * WIDTH - 1 downto N*WIDTH);
    dut: entity work.mux_param_inputs
    generic map(WIDTH => WIDTH , N=>K+1)
    port map(input_vector=> mux_inputs(i), output_vector=>output_vector((i+1)*WIDTH-1 downto i*WIDTH), sel_in=>sel_in((i+1)*log2c(K + 1)-1 downto i*log2c(K + 1)));

end generate;

end Behavioral;
