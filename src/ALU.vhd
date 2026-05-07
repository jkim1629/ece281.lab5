----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

begin
    process(i_A, i_B, i_op)
        variable v_result: std_logic_vector(7 downto 0);
        variable v_math: unsigned(8 downto 0);
        variable v_N : std_logic;
        variable v_Z : std_logic;
        variable v_C : std_logic;
        variable v_V : std_logic;
    begin 
        v_result := (others => '0');
        v_math := (others => '0');
        v_C := '0';
        v_V := '0';
        
        case i_op is 
            when "000" => -- adding
                v_math := unsigned('0' & i_A) + unsigned('0' & i_B);
                v_result := std_logic_vector(v_math(7 downto 0));
                v_C := v_math(8);
                
                if (i_A(7) = i_B(7)) and (v_result(7) /= i_A(7)) then
                    v_V := '1';
                end if;
                
            when "001" =>-- subtracting
                v_math := unsigned('0' & i_A) + unsigned('0' & (not i_B)) +1;
                v_result := std_logic_vector(v_math(7 downto 0));
                v_C := v_math(8);
                
                if (i_A(7) /= i_B(7)) and (v_result(7) /= i_A(7)) then
                    v_V := '1';
                end if;
                
            when "010" =>-- AND
                v_result := i_A and i_B;
                v_C := '0';
                v_V := '0';
                
            when "011" => -- OR
                v_result := i_A or i_B;
                v_C := '0';
                v_V := '0';
                
            when others =>
                v_result := (others => '0');
                v_C := '0';
                v_V := '0';
        end case;
        
        v_N := v_result(7);
        
        if v_result = x"00" then
            v_Z := '1';
        else 
            v_Z := '0';
        end if;
        
        o_result <= v_result;
        o_flags <= v_N & v_Z & v_C & v_V;
        
   end process;
            
            
end Behavioral;
