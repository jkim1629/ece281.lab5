----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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




-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    type sm_cycle is (s_clear, s_load_A, s_load_B, s_result);
    signal f_state : sm_cycle := s_clear;
begin

    process(i_adv, i_reset)
    begin   
    if i_reset = '1' then
        f_state <= s_clear;
    elsif rising_edge(i_adv) then
        case f_state is 
            when s_clear =>
                f_state <= s_load_A;
            when s_load_A =>
                f_state <= s_load_B;
            when s_load_B =>
                f_state <= s_result;
            when s_result =>
                f_state <= s_clear;
         end case;
    end if;
end process; 

o_cycle <= "0001" when f_state = s_clear else 
            "0010" when f_state = s_load_A else
            "0100" when f_state = s_load_B else
            "1000";
    


end FSM;
