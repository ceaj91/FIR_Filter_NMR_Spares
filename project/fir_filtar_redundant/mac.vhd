----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2023 08:01:44 AM
-- Design Name: 
-- Module Name: mac - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mac is
generic (   WIDTH_IN:natural:=16;
            WIDTH_OUT:natural:=32;
            SIGNED_UNSIGNED: string:= "signed");
Port ( clk_i: in std_logic;
       reset: in std_logic;
       en:in std_logic;
        a_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
        b_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
        mac_i: in std_logic_vector(WIDTH_OUT - 1 downto 0);
        mac_o: out std_logic_vector(WIDTH_OUT - 1 downto 0));
end mac;

architecture Behavioral of mac is
    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";
    
    -- Pipeline registers.
    type en_prop_type is array(0 to 2) of std_logic;
    signal en_prop_reg, en_prop_next:en_prop_type;
    
signal en_prop0_reg, en_prop0_next: std_logic;
signal en_prop1_reg, en_prop1_next: std_logic;
signal en_prop2_reg, en_prop2_next: std_logic;
    
    signal a_reg_s: std_logic_vector(WIDTH_IN - 1 downto 0);
    signal b_reg_s: std_logic_vector(WIDTH_IN - 1 downto 0);
    signal m_reg_s: std_logic_vector(WIDTH_OUT - 1 downto 0);
    signal p_reg_s: std_logic_vector(WIDTH_OUT - 1 downto 0);
begin

process (clk_i) is
begin
    if (rising_edge(clk_i))then
        if(reset = '1') then
            a_reg_s <= (others => '0');
            b_reg_s <= (others => '0');
            m_reg_s<=(others => '0');
            p_reg_s<=(others => '0');
        else
            if(en = '1') then
                a_reg_s <= a_i;
                b_reg_s <= b_i;
                if (SIGNED_UNSIGNED = "signed") then
                    m_reg_s <= std_logic_vector(signed(a_reg_s) * signed(b_reg_s));
                    p_reg_s <= std_logic_vector(signed(mac_i) + signed(m_reg_s));

                else
                    m_reg_s <= std_logic_vector(unsigned(a_reg_s) *unsigned(b_reg_s));
                    p_reg_s <= std_logic_vector(unsigned(mac_i) + unsigned(m_reg_s));

                end if;
            end if;
        end if;
    end if;
end process;

mac_o <= p_reg_s;
end Behavioral;


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity mac is
--generic (   WIDTH_IN:natural:=32;
--            WIDTH_OUT:natural:=32);
--    Port ( clk_i: in std_logic;
--        a_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
--        b_i: in std_logic_vector (WIDTH_IN - 1 downto 0);
--        mac_i: in std_logic_vector(WIDTH_OUT - 1 downto 0);
--        mac_o: out std_logic_vector(WIDTH_OUT - 1 downto 0));
--end mac;

--architecture Behavioral of mac is
--    signal reg_s : STD_LOGIC_VECTOR(WIDTH_OUT - 1 downto 0) := (others=>'0');
--begin
--    process(clk_i)
--    begin
--        if (clk_i'event and clk_i = '1') then
--            reg_s <= mac_i;
--        end if;
--    end process;
    
--    mac_o <= std_logic_vector(signed(reg_s) + (signed(a_i) * signed(b_i)));

--end Behavioral;