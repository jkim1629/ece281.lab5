--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
    component ALU is
        port (
            i_A      : in  std_logic_vector(7 downto 0);
            i_B      : in  std_logic_vector(7 downto 0);
            i_op     : in  std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags  : out std_logic_vector(3 downto 0)
        );
    end component;

    component controller_fsm is
        port (
            i_reset : in  std_logic;
            i_adv   : in  std_logic;
            o_cycle : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component button_debounce is
        port (
        clk : in std_logic;
        reset : in std_logic;
        button : in std_logic;
        action : out std_logic 
        );
    end component;
    
    component clock_divider is 
        generic (constant k_DIV : natural := 2);
        port (
        i_clk : in std_logic; 
        i_reset : in std_logic; 
        o_clk : out std_logic
        );
    end component; 
    
    component twos_comp is 
        port(
        i_bin : in std_logic_vector(7 downto 0);
        o_sign : out std_logic;
        o_hund : out std_logic_vector(3 downto 0);
        o_tens : out std_logic_vector(3 downto 0);
        o_ones : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component TDM4 is
        generic (constant k_WIDTH : natural := 4);
        port (
        i_clk : in std_logic;
        i_reset : in std_logic; 
        i_D3 : in std_logic_vector(k_WIDTH -1 downto 0);
        i_D2 : in std_logic_vector(k_WIDTH -1 downto 0);
        i_D1 : in std_logic_vector(k_WIDTH -1 downto 0);
        i_D0 : in std_logic_vector(k_WIDTH -1 downto 0);
        o_data : out std_logic_vector(k_WIDTH -1 downto 0);
        o_sel : out std_logic_vector(3 downto 0)
        );
        
        end component;
        
        component sevenseg_decoder is
        port (
        i_hex : in std_logic_vector(3 downto 0);
        o_seg: out std_logic_vector(6 downto 0)
        );
        end component;
        
        constant k_DISPLAY_DIV : natural := 50000;
        
        signal w_adv : std_logic := '0';
        signal w_disp_clk : std_logic := '0';
        signal w_cycle : std_logic_vector(3 downto 0) := "0001";
        
        signal f_A : std_logic_vector(7 downto 0) := (others => '0');
        signal f_B : std_logic_vector(7 downto 0) := (others => '0');
        
        signal w_alu_result : std_logic_vector(7 downto 0) := (others => '0');
        signal w_alu_flags : std_logic_vector(3 downto 0) := (others => '0');
        
        signal w_display_bin : std_logic_vector(7 downto 0) := (others => '0');
        
        signal w_sign : std_logic := '0';
        signal w_hund : std_logic_vector(3 downto 0) := (others => '0');
        signal w_tens : std_logic_vector(3 downto 0) := (others => '0');
        signal w_ones : std_logic_vector(3 downto 0) := (others => '0');
        
        signal w_tdm_digit : std_logic_vector(3 downto 0) := (others => '0');
        signal w_tdm_sel : std_logic_vector(3 downto 0) := "1111";
        signal w_decoder_seg : std_logic_vector(6 downto 0) := (others => '1');
        
        
        
        
begin
	-- PORT MAPS ----------------------------------------
    u_btnC_debounce : button_debounce
        port map (
        clk => clk,
        reset => btnU,
        button => btnC,
        action => w_adv
        
        );
	
	u_controller : controller_fsm
	   port map (
	   i_reset => btnU,
	   i_adv => w_adv,
	   o_cycle => w_cycle
	   );
	   
	u_alu : ALU
	   port map (
	   i_A => f_A,
	   i_B => f_B,
	   i_op => sw(2 downto 0),
	   o_result => w_alu_result,
	   o_flags => w_alu_flags
	   );
	   
    u_display_clock : clock_divider
    generic map (
        k_DIV => k_DISPLAY_DIV
    )
    port map (
    i_clk => clk,
    i_reset => btnU,
    o_clk => w_disp_clk
    );
    
    
    u_twos_comp : twos_comp
        port map (
        i_bin => w_display_bin,
        o_sign => w_sign,
        o_hund => w_hund,
        o_tens => w_tens,
        o_ones => w_ones
        
        );
        
        u_tdm4: TDM4
        generic map (
        k_WIDTH => 4
        )
        port map (
        i_clk => w_disp_clk,
        i_reset => btnU,
        i_D3 => "0000",
        i_D2 => w_hund,
        i_D1 => w_tens,
        i_D0 => w_ones,
        o_data => w_tdm_digit,
        o_sel => w_tdm_sel 
        );
        
        u_sevenseg_decoder : sevenseg_decoder
            port map (
            i_hex => w_tdm_digit,
            o_seg => w_decoder_seg
            );
            
    process(clk)
    begin
        if rising_edge(clk) then
            if btnU = '1' then
                f_A <= (others => '0');
                f_B <= (others => '0');
                
            elsif w_adv = '1' then  
                if w_cycle = "0010" then
                    f_A <= sw;
                elsif w_cycle = "0100" then 
                    f_B <= sw;
                end if;
            end if;
        end if;
    end process;
    
    
    w_display_bin <= f_A when w_cycle = "0010" else
                     f_B when w_cycle = "0100" else
                     w_alu_result when w_cycle = "1000" else
                     (others => '0');
              
	-- CONCURRENT STATEMENTS ----------------------------
	led(3 downto 0) <= w_cycle;
	led(11 downto 4) <= (others => '0');
	led(15 downto 12) <= w_alu_flags;
	
	an <= "1111" when w_cycle = "0001" else
	   w_tdm_sel;
	
	
	seg <= "1111111" when w_cycle = "0001" else
	       "0111111" when (w_tdm_sel = "0111" and w_sign = '1') else
	       "1111111" when (w_tdm_sel = "0111" and w_sign = '0') else
	       w_decoder_seg;
	
	
end top_basys3_arch;
