----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2023 09:42:41 AM
-- Design Name: 
-- Module Name: mux_param_inputs - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_param_inputs is
generic (
        WIDTH : natural := 4;
        N : natural := 4
    );
port (
        input_vector : in std_logic_vector(N*WIDTH - 1 downto 0);
        output_vector : out std_logic_vector(WIDTH - 1 downto 0);
        sel_in : in std_logic_vector(log2c(N) - 1 downto 0)
    );
end mux_param_inputs;

architecture Behavioral of mux_param_inputs is

begin

    process(sel_in, input_vector) is
    begin
        output_vector<=(others => '0');
        for i in 0 to N-1 loop
            if(sel_in = std_logic_vector(to_unsigned(i,log2c(N)))) then
                output_vector <= input_vector((N-i)*WIDTH-1 downto (N-i-1)*WIDTH);
            end if;
        end loop;
            

        
    end process;

end Behavioral;
