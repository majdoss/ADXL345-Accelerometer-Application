-------------------------------------------------------------------------------
-- Description: SPI (Serial Peripheral Interface) Master
--              With single chip-select (AKA Slave Select) capability
--
--              Supports arbitrary length byte transfers.
-- 
--              Instantiates a SPI Master and adds single CS.
--              If multiple CS signals are needed, will need to use different
--              module, OR multiplex the CS from this at a higher level.
--
-- Note:        i_Clk must be at least 2x faster than i_SPI_Clk
--
-- Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
--              Can be configured in one of 4 modes:
--              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
--               0   |             0             |        0
--               1   |             0             |        1
--               2   |             1             |        0
--               3   |             1             |        1
--
--              CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
--              derived from i_Clk.  Set to integer number of clocks for each
--              half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
--              would create o_SPI_CLK of 25 MHz.  Must be >= 2
--
--              MAX_BYTES_PER_CS - Set to the maximum number of bytes that
--              will be sent during a single CS-low pulse.
-- 
--              CS_INACTIVE_CLKS - Sets the amount of time in clock cycles to
--              hold the state of Chip-Selct high (inactive) before next 
--              command is allowed on the line.  Useful if chip requires some
--              time when CS is high between trasnfers.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_Master_With_Single_CS is
  port (
   -- Control/Data Signals,
   i_Rst_L : in std_logic;     -- FPGA Reset
   i_Clk   : in std_logic;     -- FPGA Clock
   i_spi_mode : in std_logic_vector (1 downto 0); -- SPI_MODE
   i_clk_scale : in std_logic_vector (15 downto 0); -- clk scale factor
   i_cs_inactive_clks : in std_logic_vector (7 downto 0);
   
   -- TX (MOSI) Signals
   i_TX_Count : in  std_logic_vector (5 downto 0);  -- # bytes per CS low (max. 16)
   i_TX_Byte  : in  std_logic_vector(7 downto 0);  -- Byte to transmit on MOSI
   i_TX_DV    : in  std_logic;     -- Data Valid Pulse with i_TX_Byte
   o_TX_Ready : out std_logic;     -- Transmit Ready for next byte
   
   -- RX (MISO) Signals
   o_RX_Count : out std_logic_vector (5 downto 0);  -- Index RX byte
   o_RX_DV    : out std_logic;  -- Data Valid pulse (1 clock cycle)
   o_RX_Byte  : out std_logic_vector(7 downto 0);   -- Byte received on MISO

   -- SPI Interface
   o_SPI_Clk  : out std_logic;
   i_SPI_MISO : in  std_logic;
   o_SPI_MOSI : out std_logic;
   o_SPI_CS_n : out std_logic
   );
end entity SPI_Master_With_Single_CS;

architecture RTL of SPI_Master_With_Single_CS is

  type t_SM_CS is (IDLE, TRANSFER, CS_INACTIVE);

  signal r_SM_CS : t_SM_CS;
  signal r_CS_n : std_logic;
  signal r_CS_Inactive_Count : integer range 0 to 255;
  signal r_TX_Count : integer range 0 to 15;
  signal w_Master_Ready : std_logic;

  signal CS_INACTIVE_CLKS  : integer range 0 to 255;
  
  signal RX_Count : std_logic_vector (5 downto 0);
  signal RX_DV : std_logic; 
  
  component SPI_Master is
    port (
     -- Control/Data Signals,
     i_Rst_L : in std_logic;        -- FPGA Reset
     i_Clk   : in std_logic;        -- FPGA Clock
     i_spi_mode : in std_logic_vector (1 downto 0); -- SPI mode
     i_clk_scale : in std_logic_vector (15 downto 0); -- clk scale factor
     
     -- TX (MOSI) Signals
     i_TX_Byte   : in std_logic_vector(7 downto 0);   -- Byte to transmit on MOSI
     i_TX_DV     : in std_logic;          -- Data Valid Pulse with i_TX_Byte
     o_TX_Ready  : out std_logic;         -- Transmit Ready for next byte
     
     -- RX (MISO) Signals
     o_RX_DV   : out std_logic;    -- Data Valid pulse (1 clock cycle)
     o_RX_Byte : out std_logic_vector(7 downto 0);   -- Byte received on MISO
  
     -- SPI Interface
     o_SPI_Clk  : out std_logic;
     i_SPI_MISO : in  std_logic;
     o_SPI_MOSI : out std_logic
     );
  end component SPI_Master;

begin

  CS_INACTIVE_CLKS <= to_integer(unsigned(i_cs_inactive_clks));
  
  o_RX_Count <= RX_Count;
  o_RX_DV <= RX_DV;
  

  -- Instantiate Master
  SPI_Master_1 : SPI_Master
    port map (
      -- Control/Data Signals,
      i_Rst_L    => i_Rst_L,            -- FPGA Reset
      i_Clk      => i_Clk,              -- FPGA Clock
      i_spi_mode => i_spi_mode,         -- SPI mode
      i_clk_scale => i_clk_scale,       -- clk scale factor

      -- TX (MOSI) Signals
      i_TX_Byte  => i_TX_Byte,          -- Byte to transmit
      i_TX_DV    => i_TX_DV,            -- Data Valid pulse
      o_TX_Ready => w_Master_Ready,     -- Transmit Ready for Byte
      -- RX (MISO) Signals
      o_RX_DV    => RX_DV,            -- Data Valid pulse
      o_RX_Byte  => o_RX_Byte,          -- Byte received on MISO
      -- SPI Interface
      o_SPI_Clk  => o_SPI_Clk, 
      i_SPI_MISO => i_SPI_MISO,
      o_SPI_MOSI => o_SPI_MOSI
      );
  

  -- Purpose: Control CS line using State Machine
  SM_CS : process (i_Clk, i_Rst_L, CS_INACTIVE_CLKS) is
  begin
    if i_Rst_L = '0' then
      r_SM_CS             <= IDLE;
      r_CS_n              <= '1';   -- Resets to high
      r_TX_Count          <= 0;
      r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
    elsif rising_edge(i_Clk) then

      case r_SM_CS is
        when IDLE =>
          if r_CS_n = '1' and i_TX_DV = '1' then -- Start of transmission
            r_TX_Count <= to_integer(unsigned(i_TX_Count) - 1); -- Register TX Count
            r_CS_n     <= '0';       -- Drive CS low
            r_SM_CS    <= TRANSFER;   -- Transfer bytes
          end if;

        when TRANSFER =>
          -- Wait until SPI is done transferring do next thing
          if w_Master_Ready = '1' then
            if r_TX_Count > 0 then
              if i_TX_DV = '1' then
                r_TX_Count <= r_TX_Count - 1;
              end if;
            else
              r_CS_n              <= '1'; -- we done, so set CS high
              r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
              r_SM_CS             <= CS_INACTIVE;
            end if;
          end if;
          
        when CS_INACTIVE =>
          if r_CS_Inactive_Count > 0 then
            r_CS_Inactive_Count <= r_CS_Inactive_Count - 1;
          else
            r_SM_CS <= IDLE;
          end if;

        when others => 
          r_CS_n  <= '1'; -- we done, so set CS high
          r_SM_CS <= IDLE;
      end case;
    end if;
  end process SM_CS; 


  -- Purpose: Keep track of RX_Count
  P_RX_COUNT : process (i_Clk, r_CS_n, RX_DV, RX_Count)
  begin
    if rising_edge(i_Clk) then
      if r_CS_n = '1' then
        RX_Count <= "000000";
      elsif RX_DV = '1' then
        RX_Count <= std_logic_vector(unsigned(RX_Count) + 1);
      end if;
    end if;
  end process P_RX_COUNT;

  o_SPI_CS_n <= r_CS_n;

  o_TX_Ready <= '1' when i_TX_DV /= '1' and ((r_SM_CS = IDLE) or (r_SM_CS = TRANSFER and w_Master_Ready = '1' and r_TX_Count > 0)) else '0'; 

end architecture RTL;
