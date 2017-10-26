library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hdmi_out is
    Port ( lcd_data : out STD_LOGIC_VECTOR (15 downto 0);
           hdmi_intn : inout STD_LOGIC;
           lcd_pclk : out STD_LOGIC;
           lcd_de : out STD_LOGIC;
           lcd_vsync : out STD_LOGIC;
           lcd_hsync : out STD_LOGIC;
           in_clk : in STD_LOGIC);

end hdmi_out;

architecture Behavioral of hdmi_out is

    signal blanking     : std_logic := '0';
    signal hsync        : std_logic := '0';
    signal vsync        : std_logic := '0';
    signal lcd_out      : std_logic_vector (15 downto 0);
    signal color        : std_logic_vector (23 downto 0);
    signal hcounter     : unsigned(10 downto 0) := (others => '0');
    signal vcounter     : unsigned(10 downto 0) := (others => '0');  
    signal hVisible     : unsigned(10 downto 0);
    signal hStartSync   : unsigned(10 downto 0);
    signal hEndSync     : unsigned(10 downto 0);
    signal hMax         : unsigned(10 downto 0);
    signal hSyncActive  : std_logic := '1';
    signal vVisible     : unsigned(10 downto 0);
    signal vStartSync   : unsigned(10 downto 0);
    signal vEndSync     : unsigned(10 downto 0);
    signal vMax         : unsigned(10 downto 0);
    signal vSyncActive  : std_logic := '1';

    constant ZERO       : unsigned(10 downto 0) := (others => '0');
    constant BLACK    : std_logic_vector(23 downto 0) := x"000000";
    constant RED      : std_logic_vector(23 downto 0) := x"FF0000";
    constant GREEN    : std_logic_vector(23 downto 0) := x"00FF00";
    constant BLUE     : std_logic_vector(23 downto 0) := x"0000FF";
    constant WHITE    : std_logic_vector(23 downto 0) := x"FFFFFF";
    constant YELLOW   : std_logic_vector(23 downto 0) := x"FFFF00";
    constant CYAN     : std_logic_vector(23 downto 0) := x"00FFFF";
    constant MAGENTA  : std_logic_vector(23 downto 0) := x"FF00FF";        

begin

    hVisible        <= ZERO + 1280;
    hStartSync      <= ZERO + 1280+72;
    hEndSync        <= ZERO + 1280+72+80;
    hMax            <= ZERO + 1280+72+80+216-1;
    vSyncActive     <= '1';

    vVisible        <= ZERO + 720;
    vStartSync      <= ZERO + 720+3;
    vEndSync        <= ZERO + 720+3+5;
    vMax            <= ZERO + 720+3+5+22-1;
    hSyncActive     <= '1';
    
colour_proc: process(hcounter,vcounter)
     begin
        if vcounter < 600 then
            if hcounter < 160 then
                color <= WHITE;
             elsif hcounter < 320 then
                color <= YELLOW;
             elsif hcounter < 480 then
                color <= CYAN;
            elsif hcounter < 640 then
                color <= GREEN;
            elsif hcounter < 800 then
                color <= MAGENTA;
            elsif hcounter < 960 then
                color <= RED;
            elsif hcounter < 1120 then
                color <= BLUE;
            else
                color <= BLACK; 
            end if;
        else
            color <= x"808080";                  
        end if;
    end process;    
    
    lcd_out(15 downto 11) <= color(23 downto 19);
    lcd_out(10  downto 5) <= color(15 downto 10);
    lcd_out(4  downto 0 ) <= color(7  downto 3);
    lcd_pclk <= in_clk;
    
hdmi: process(in_clk)
    begin
        if (in_clk'event and in_clk ='1') then
              
            if blanking = '1' then
                lcd_data <= (others => '0');
                lcd_de <= '0';
            else
                lcd_data <= lcd_out;
                lcd_de <= '1';
            end if;
            
            lcd_hsync <= hsync;
            lcd_vsync <= vsync;

            if vcounter >= vVisible then 
                blanking <= '1';
            elsif hcounter >= hVisible then 
                blanking <= '1';
            else
                blanking <= '0';
            end if; 

            if vcounter = vStartSync then 
                vSync <= vSyncActive;
            elsif vCounter = vEndSync then
                vSync <= not(vSyncActive);
            end if;

            if hcounter = hStartSync then 
                hSync <= hSyncActive;
            elsif hCounter = hEndSync then
                hSync <= not(hSyncActive);
            end if;

            if hCounter = hMax  then
                hCounter <= (others => '0');
                if vCounter = vMax then
                    vCounter <= (others => '0');
                else
                    vCounter <= vCounter + 1;
                end if;
                else
                hCounter <= hCounter + 1;
            end if;
        end if;
    end process;        

end Behavioral;
