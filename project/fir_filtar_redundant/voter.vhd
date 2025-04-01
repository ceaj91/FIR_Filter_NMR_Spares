----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2023 10:05:13 AM
-- Design Name: 
-- Module Name: voter - Behavioral
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

entity voter is
generic(WIDTH: natural :=48;
        N: natural:= 5);
Port(input_vector:in std_logic_vector(N*WIDTH-1 downto 0);
     output_vector: out std_logic_vector(WIDTH-1 downto 0));
end voter;

architecture Behavioral of voter is

type result_type is array (0 to WIDTH-1) of std_logic_vector(log2c(N)-1 downto 0); --umesto 9 treba formula
signal result: result_type := (others =>(others => '0'));

begin
process(input_vector)is 
variable zbir:integer :=0;
begin
    for i in 0 to WIDTH-1 loop
        zbir :=0;
        for j in 0 to N-1 loop
          if(input_vector(j*WIDTH+i) = '1') then
            zbir := zbir+1; 
          end if;
        end loop;
        if(zbir < N/2) then
                output_vector(i) <= '0';
        elsif(zbir = N/2) then
                output_vector(i) <= '0';
        else
                output_vector(i) <= '1';
        end if;
    end loop;
      
end process;
--outer_loop:    for i in 0 to WIDTH-1 generate
--      inner_loop:for j in 0 to N-1 generate
--          process(input_vector) is
--          begin
--          if(input_vector(j*WIDTH) = '1') then
--            result(i) <= std_logic_vector(unsigned(result(i)) + to_unsigned(1,log2c(N))); 
--          else
--            result(i) <= std_logic_vector(unsigned(result(i)) + to_unsigned(1,log2c(N))); 
--         end if;
--         end process;
--      end generate;
          
--          process(result(i)) is begin
--            if(result(i) < std_logic_vector(TO_UNSIGNED(N/2,log2c(N)))) then
--                output_vector(i) <= '0';
--            elsif(result(i) = std_logic_vector(TO_UNSIGNED(N/2,log2c(N)))) then
--                output_vector(i) <= '0';
--            else
--                output_vector(i) <= '1';
--            end if;
--         end process;
--    end generate;
  


end Behavioral;
