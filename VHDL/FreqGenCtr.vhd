--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:00:00 12/12/2019
-- Design Name: 
-- Module Name:    FreqGenCtr - Behavioral 
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

use work.regdef.all;

entity FreqGenCtr is
 generic(opBase : unsigned;
         opBits : positive := 8;
         freqBits : positive;
         countBits: positive);
 port (
  clk : in std_logic;
  din : in std_logic;
  dshift : in boolean;
  op : in unsigned (opBits-1 downto 0);
  load : in boolean;
  ena : in std_logic;
  pulseOut : out std_logic := '0'
  );
end FreqGenCtr;

architecture Behavioral of FreqGenCtr is

 component ShiftOp is
  generic(opVal : unsigned;
         opBits : positive;
         n : positive);
  port (
   clk : in std_logic;
   shift : in boolean;
   op : in unsigned (opBits-1 downto 0);
   din : in std_logic;
   data : inout unsigned (n-1 downto 0));
 end component;

 type fsm is (idle, run, updCount, chkCount, done);
 signal state : fsm := idle;
 
 signal freqVal : unsigned(freqBits-1 downto 0);
 signal freqCounter : unsigned(freqBits-1 downto 0) :=
  (freqBits-1 downto 0 => '0');

 signal countVal : unsigned(countBits-1 downto 0);
 signal outputCounter : unsigned(countBits-1 downto 0) :=
  (countBits-1 downto 0 => '0');

begin

 freqReg: ShiftOp
  generic map(opVal => opBase + F_Ld_Dbg_Freq,
              opBits => opBits,
              n => freqBits)
  port map (
   clk => clk,
   shift => dshift,
   op => op,
   din => din,
   data => freqVal);

 countReg: ShiftOp
  generic map(opVal => opBase + F_Ld_Dbg_Count,
              opBits => opBits,
              n => countBits)
  port map (
   clk => clk,
   shift => dshift,
   op => op,
   din => din,
   data => countVal);

 freqCtr: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (op = opBase + F_Ld_Dbg_Freq) then --if changing frequency
    state <= idle;                      --return to idle state
   else
    case state is
     when idle =>                        --idle
      if (ena = '1') then
       outputCounter <= countVal;
       freqCounter <= freqVal;
       state <= run;
      end if;

     when run =>                         --run
      if (ena = '0') then                --if enable cleared
       state <= idle;                    --return to idle state
      else
       if (freqCounter = (freqBits-1 downto 0 => '0')) then --if zero
        freqCounter <= freqVal;         --reload counter
        pulseOut <= '1';                --activate frequency pulse
        state <= updCount;
       else                             --if counter non zero
        pulseOut <= '0';                --clear output pulse
        freqCounter <= freqCounter - 1; --count down
       end if;
      end if;

     when updCount =>                    --update count
      freqCounter <= freqCounter - 1;    --count down
      pulseOut <= '0';                   --clear output pulse
      if (outputCounter = (countBits-1 downto 0 => '0')) then --count zero
       state <= run;                     --return to run state
      else                               --if count non zero
       outputCounter <= outputCounter - 1; --count down
       state <= chkCount;                --adancee to check count state
      end if;

     when chkCount =>                    --check count
      freqCounter <= freqCounter - 1;    --count down
      if (outputCounter /= (countBits-1 downto 0 => '0')) then --non zero
       state <= run;                     --continue in run state
      else                               --if count zero
       state <= done;                    --wait for ena to clear
      end if;

     when done =>                       --done
      if (ena = '0') then               --if enable cleared
       state <= idle;                   --return to idle state
      end if;
      if ((op = opBase + F_Ld_Dbg_Count) and load) then
       outputCounter <= countVal;
       freqCounter <= freqVal;          --reload counter
       state <= run;
      end if;
    end case;
   end if;
  end if;
 end process freqCtr;

end Behavioral;

