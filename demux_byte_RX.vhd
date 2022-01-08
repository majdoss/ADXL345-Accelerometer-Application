library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This module is used to store each byte received to its corresponding register in S00_AXI

entity demux_byte_RX is
    Port ( i_rst: in STD_LOGIC;
           i_RX_DV: in STD_LOGIC;
           RX_Byte : in STD_LOGIC_VECTOR (7 downto 0);
           RX_Count : in STD_LOGIC_VECTOR (5 downto 0);
           data0 : out STD_LOGIC_VECTOR (31 downto 0);
           data1 : out STD_LOGIC_VECTOR (31 downto 0);
           data2 : out STD_LOGIC_VECTOR (31 downto 0);
           data3 : out STD_LOGIC_VECTOR (31 downto 0));
end demux_byte_RX;

architecture RTL of demux_byte_RX is

begin
    process(i_rst, i_RX_DV, RX_Byte, RX_Count) is
        begin
            if (i_rst = '0') then
                data0 <= (others => '0');
                data1 <= (others => '0');
                data2 <= (others => '0');
                data3 <= (others => '0');
            elsif (i_RX_DV = '1') then
                case RX_Count is
                    when "000000" => data0(7 downto 0) <= RX_Byte;
                    when "000001" => data0(15 downto 8) <= RX_Byte;
                    when "000010" => data0(23 downto 16) <= RX_Byte;
                    when "000011" => data0(31 downto 24) <= RX_Byte;
                    when "000100" => data1(7 downto 0) <= RX_Byte;
                    when "000101" => data1(15 downto 8) <= RX_Byte;
                    when "000110" => data1(23 downto 16) <= RX_Byte;
                    when "000111" => data1(31 downto 24) <= RX_Byte;
                    when "001000" => data2(7 downto 0) <= RX_Byte;
                    when "001001" => data2(15 downto 8) <= RX_Byte;
                    when "001010" => data2(23 downto 16) <= RX_Byte;
                    when "001011" => data2(31 downto 24) <= RX_Byte;
                    when "001100" => data3(7 downto 0) <= RX_Byte;
                    when "001101" => data3(15 downto 8) <= RX_Byte;
                    when "001110" => data3(23 downto 16) <= RX_Byte;
                    when "001111" => data3(31 downto 24) <= RX_Byte;
                    when others => data0 <= (others => '0');
                                   data1 <= (others => '0');
                                   data2 <= (others => '0');
                                   data3 <= (others => '0');
                end case;
            end if;
        end process;
                      
end RTL;