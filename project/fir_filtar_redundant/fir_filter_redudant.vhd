library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;
use IEEE.NUMERIC_STD.ALL;



entity fir_filter_redudant is
generic (   WIDTH_IN:natural:=18;
            fir_ord : natural := 20;
            K : natural := 3;
            N : natural := 5);
    Port ( clk_i : in STD_LOGIC;
           we_i: in std_logic;
           coef_addr_i: in std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           coef_i : in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
           reset: in std_logic;

           
           --AXI_SLAVE_STREAM signals
            axis_s_data: in std_logic_vector(WIDTH_IN-1 downto 0);
            axis_s_valid:in std_logic;
            axis_s_last:in std_logic;
            axis_s_ready:out std_logic;
            
            ----AXI_MASTER_STREAM  signals
            axis_m_valid:out std_logic;
            axis_m_last:out std_logic;
            axis_m_ready:in std_logic;
            axis_m_data: out std_logic_vector(WIDTH_IN-1 downto 0)
            
            );
end fir_filter_redudant;

architecture Behavioral of fir_filter_redudant is
    type std_2d is array (fir_ord downto 0) of std_logic_vector(2*WIDTH_IN-1 downto 0);
    signal mac_inter : std_2d := (others=>(others=>'0'));
    
    type valid_type is array (fir_ord downto 0) of std_logic;
    signal valid_s:valid_type:= (others=>'0');
    
    type coef_t is array (fir_ord downto 0) of std_logic_vector(WIDTH_IN-1 downto 0);
    signal b : coef_t := (others=>(others=>'0'));
     
    type stream_type is (IDLE, PROCESSING);
    signal slave_logic_reg, slave_logic_next:stream_type;
    signal master_logic_reg, master_logic_next:stream_type;
    signal input_is_valid:std_logic;
    signal axis_s_ready_sig:std_logic;
    signal input_data:std_logic_vector(WIDTH_IN-1 downto 0);
    signal output_data:std_logic_vector(WIDTH_IN-1 downto 0);
    
    
    signal en_prop0_reg, en_prop0_next: std_logic;
    signal en_prop1_reg, en_prop1_next: std_logic;
    signal en_prop2_reg, en_prop2_next: std_logic;
    
    signal last_prop0_reg, last_prop0_next: std_logic;
    signal last_prop1_reg, last_prop1_next: std_logic;
    signal last_prop2_reg, last_prop2_next: std_logic;

begin

input_data <=axis_s_data;

process (clk_i) is
begin
    if (rising_edge(clk_i))then
        if(reset = '1') then
            en_prop0_reg<='0';
            en_prop1_reg<='0';
            en_prop2_reg<='0';
            last_prop0_reg<='0';
            last_prop1_reg<='0';
            last_prop2_reg<='0';
        else
            en_prop0_reg<=en_prop0_next;
            en_prop1_reg<=en_prop1_next;
            en_prop2_reg<=en_prop2_next;
            
            last_prop0_reg<=last_prop0_next;
            last_prop1_reg<=last_prop1_next;
            last_prop2_reg<=last_prop2_next;
        end if;
    end if;
end process;

en_prop0_next<=input_is_valid;
en_prop1_next<=en_prop0_reg;
en_prop2_next<=en_prop1_reg;

last_prop0_next<=axis_s_last;
last_prop1_next<=last_prop0_reg;
last_prop2_next<=last_prop1_reg;

process(clk_i) is begin

    if(rising_edge(clk_i)) then
        if(reset = '1') then
            slave_logic_reg<=IDLE;
            master_logic_reg<=IDLE;
        else
            slave_logic_reg<=slave_logic_next;
            master_logic_reg<=master_logic_next;
        end if;
    end if;
end process; 





--AXI STREAM SLAVE INTERFACE
stream_slave_interface: process(slave_logic_reg,axis_s_valid,axis_s_last,axis_m_ready) is begin

    case(slave_logic_reg) is
    
        when IDLE=>
            axis_s_ready_sig<='0';
            if(axis_s_valid = '1') then
                slave_logic_next <= PROCESSING;
            else
                slave_logic_next <= IDLE;
            end if;
        when PROCESSING =>
            slave_logic_next <= PROCESSING;
            
            axis_s_ready_sig<='0'; 
            if(axis_m_ready ='1')then
                axis_s_ready_sig<='1'; 
            end if;
            --end of transaction
            if(axis_s_valid = '1')then
                if(axis_s_last ='1') then
                    slave_logic_next <= IDLE;
                end if;
            
            end if;
   end case;
    
end process;
input_is_valid <= axis_s_valid and axis_s_ready_sig;
axis_s_ready<=axis_s_ready_sig;

--AXI STREAM MASTER INTERFACE
axis_m_data<=output_data;
axis_m_last<=last_prop2_reg;
axis_m_valid<=en_prop2_reg;

process(clk_i)
    begin
        if(clk_i'event and clk_i = '1')then
            if we_i = '1' then
                b(to_integer(unsigned(coef_addr_i))) <= coef_i;
            end if;
        end if;
    end process;


generate_MACs:
    for i in 0 to fir_ord generate
    first_mac:       
        if (i = 0) generate
            MACS:entity work.mac_subsystem(behavioral)
            generic map(WIDTH_IN=>WIDTH_IN, K=>K, N=>N)
            port map(
                clk => clk_i,
                reset => reset,
                en=>input_is_valid,
                a_i => input_data,
                b_i => b(fir_ord),
                mac_i => (others =>'0'),
                mac_o => mac_inter(i)
            );
        end generate first_mac;
    others_macs:       
    if (i /= 0) generate
        other:entity work.mac_subsystem(behavioral)
        generic map(WIDTH_IN=>WIDTH_IN, K=>K, N=>N)
        port map(
            clk => clk_i,
            reset => reset,
            en=>input_is_valid,
            a_i => input_data,
            b_i => b(fir_ord-i),
            mac_i => mac_inter(i-1),
            mac_o => mac_inter(i)
        );
    end generate others_macs;
        
        
    end generate generate_MACs;
    
    process(clk_i)
    begin     
        if(rising_edge(clk_i)) then
            output_data <= mac_inter(fir_ord)(2*WIDTH_IN-2 downto WIDTH_IN - 1);
        end if;
   end process;
   
end Behavioral;
