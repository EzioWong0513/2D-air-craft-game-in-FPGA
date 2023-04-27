----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2023 15:13:30
-- Design Name: 
-- Module Name: clock_divider - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
    generic (N: integer);
    Port (
        clk : IN STD_LOGIC;
        clk_out : OUT STD_LOGIC
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : integer := 0;
    signal sig : STD_LOGIC := '0';
begin
    clk_out <= sig;
    
    process(clk)
    begin
        if (rising_edge(clk)) then
            if(counter = (N - 1)) then
                sig <= NOT sig;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
end Behavioral;