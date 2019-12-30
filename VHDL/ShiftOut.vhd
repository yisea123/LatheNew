--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:29 01/24/2015 
-- Design Name: 
-- Module Name:    ShiftOut - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftOut is
 generic(opVal : unsigned;
         opBits : positive;
         n : positive);
 port (
  clk : in std_logic;
  dshift : in std_logic;
  op : in unsigned (opBits-1 downto 0);
  load : in std_logic;
  data : in unsigned(n-1 downto 0);
  dout : out std_logic := '0'
  );
end ShiftOut;

architecture Behavioral of ShiftOut is

 signal shiftSel : std_logic := '0';
 signal shiftReg : unsigned(n-1 downto 0) := (others => '0');

begin

 -- shiftSel <= '1' when op = opVal else '0';
 dout <= shiftReg(n-1) when shiftSel = '1' else '0';

 shiftout: process (clk)
 begin
  if (rising_edge(clk)) then
   if (op = opVal) then
    shiftSel <= '1';
   else
    shiftSel <= '0';
   end if;
   if ((shiftSel and load) = '1') then
    shiftReg <= data;
   else 
    if ((shiftSel and dShift) = '1') then
     shiftReg <= shiftReg(n-2 downto 0) & shiftReg(n-1);
    end if;
   end if;
  end if;
 end process shiftout;

end Behavioral;

