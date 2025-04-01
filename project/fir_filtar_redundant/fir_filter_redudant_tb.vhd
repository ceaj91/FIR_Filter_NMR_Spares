----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2023 10:43:12 AM
-- Design Name: 
-- Module Name: fir_filter_redudant_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.txt_util.all;
use work.util_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_filter_redudant_tb is
generic (   WIDTH_IN:natural:=24;
            fir_ord : natural := 20;
            K : natural := 3;
            N : natural := 5);
end fir_filter_redudant_tb;

architecture Behavioral of fir_filter_redudant_tb is
    file input_test_vector : text open read_mode is "../../../../../projekat/input.txt";
    file output_check_vector : text open read_mode is "../../../../../projekat/expected.txt";
    file input_coef : text open read_mode is "../../../../../projekat/coef.txt";
    
    signal clk_s : std_logic;
    signal reset_s: std_logic;
    constant per_c : time := 20ns;
    signal we_i_s : std_logic;
    signal coef_addr_i_s : std_logic_vector(log2c(fir_ord)-1 downto 0);
    signal coef_i_s : std_logic_vector(WIDTH_IN-1 downto 0);
    signal start_check : std_logic := '0';
    
    --AXI_SLAVE_STREAM signals
    signal axis_s_data_s:  std_logic_vector(WIDTH_IN-1 downto 0);
    signal axis_s_valid_s: std_logic;
    signal axis_s_last_s: std_logic;
    signal axis_s_ready_s: std_logic;
    
    ----AXI_MASTER_STREAM  signals
    signal axis_m_valid_s: std_logic;
    signal axis_m_last_s: std_logic;
    signal axis_m_ready_s: std_logic;
    signal axis_m_data_s:  std_logic_vector(WIDTH_IN-1 downto 0);
    
begin
fir_under_test:
    entity work.fir_filter_redudant(behavioral) 
    generic map(WIDTH_IN=>WIDTH_IN, fir_ord=>fir_ord,K=>K,N=>N)
    port map(clk_i=>clk_s,
             reset => reset_s,
             we_i => we_i_s,
             coef_addr_i => coef_addr_i_s,
             coef_i => coef_i_s,
             --AXI_SLAVE_STREAM signals
            axis_s_data=>axis_s_data_s,
            axis_s_valid=>axis_s_valid_s,
            axis_s_last=>axis_s_last_s,
            axis_s_ready=>axis_s_ready_s,
            
            ----AXI_MASTER_STREAM  signals
            axis_m_valid=>axis_m_valid_s,
            axis_m_last=>axis_m_last_s,
            axis_m_ready=>axis_m_ready_s,
            axis_m_data=>axis_m_data_s);
             
clk_process:
    process
    begin
        clk_s <= '0';
        wait for per_c/2;
        clk_s <= '1';
        wait for per_c/2;
    end process;
    
    stim_process:
    process
        variable tv : line;
        variable counter: integer :=0;

    begin
        axis_s_data_s<=(others=>'0');
        axis_s_valid_s<='0';
        axis_s_last_s<='0';
        axis_m_ready_s<='0';
        --reset
       reset_s <= '1';
         wait until falling_edge(clk_s);
         reset_s <= '0';
        wait until falling_edge(clk_s);
        
        --upis koeficijenata
        for i in 0 to fir_ord loop
            we_i_s <= '1';
            coef_addr_i_s <= std_logic_vector(to_unsigned(i,log2c(fir_ord)));
            readline(input_coef,tv);
            coef_i_s <= to_std_logic_vector(string(tv));
            wait until falling_edge (clk_s);
        end loop;
        axis_m_ready_s<='1';
        while not endfile(input_test_vector) loop
            
            readline(input_test_vector,tv);
            axis_s_data_s<=to_std_logic_vector(string(tv));
            axis_s_valid_s<='1';

            if(axis_s_ready_s = '0') then
                while(axis_s_ready_s = '0') loop
                    wait until falling_edge(clk_s);
                end loop;
            else
                wait until falling_edge(clk_s);
            end if;

            if(counter = 3) then
                start_check <= '1';
            end if;
            counter := counter + 1;
        end loop;
        
        start_check <= '0';
        axis_s_last_s<='1';
        wait until falling_edge(clk_s);
        
        axis_s_last_s<='0';
        axis_s_valid_s<='0';
        
        report "verification done!" severity failure;
        wait;
end process;
check_process:
    process
        variable check_v : line;
        variable tmp : std_logic_vector(WIDTH_IN-1 downto 0);
    begin
        wait until start_check = '1';
        while(true)loop
            wait until rising_edge(clk_s);
            readline(output_check_vector,check_v);
            tmp := to_std_logic_vector(string(check_v));
            if(abs(signed(tmp) - signed(axis_m_data_s)) > "000000000000000000000111")then
               report "result mismatch!" severity failure;
            end if;
        end loop;
    end process;
end Behavioral;
