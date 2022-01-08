library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_Master_IP_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
		
	   -- Used to interface the ADXL345 (slave) with the top-level SPI_Master_IP block
        o_SPI_Clk_TOP   : out std_logic;
        i_SPI_MISO_TOP  : in std_logic;
        o_SPI_MOSI_TOP  : out std_logic;
        o_SPI_CS_n_TOP  : out std_logic;
        
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end SPI_Master_IP_v1_0;

architecture arch_imp of SPI_Master_IP_v1_0 is

	-- component declaration
	component SPI_Master_IP_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
		-- Control/Data Signals
        S_AXI_O_SPI_MODE : out std_logic_vector (1 downto 0);
        S_AXI_O_CLK_SCALE : out std_logic_vector (15 downto 0);
        S_AXI_O_CS_INACTIVE_CLKS : out std_logic_vector (7 downto 0);
        
        -- TX Interface
        S_AXI_I_TX_READY: in std_logic;
        S_AXI_O_TX_DV: out std_logic;
        S_AXI_O_TX_COUNT : out std_logic_vector (5 downto 0);
        S_AXI_O_TX_BYTE : out std_logic_vector (7 downto 0);
        
        -- Map each byte received to a register
        S_AXI_I_data0 : in std_logic_vector (31 downto 0);
        S_AXI_I_data1 : in std_logic_vector (31 downto 0);
        S_AXI_I_data2 : in std_logic_vector (31 downto 0);
        S_AXI_I_data3 : in std_logic_vector (31 downto 0);
        S_AXI_I_SPI_CS_N : in std_logic;
        
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component SPI_Master_IP_v1_0_S00_AXI;
	
	component SPI_Master_With_Single_CS is
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
	end component SPI_Master_With_Single_CS;
	
	component demux_byte_RX is
        Port ( i_rst: in STD_LOGIC;
               i_RX_DV: in STD_LOGIC;
               RX_Byte : in STD_LOGIC_VECTOR (7 downto 0);
               RX_Count : in STD_LOGIC_VECTOR (5 downto 0);
               data0 : out STD_LOGIC_VECTOR (31 downto 0);
               data1 : out STD_LOGIC_VECTOR (31 downto 0);
               data2 : out STD_LOGIC_VECTOR (31 downto 0);
               data3 : out STD_LOGIC_VECTOR (31 downto 0));
	end component demux_byte_RX;
	
	signal s_RX_DV: std_logic;
	signal s_RX_BYTE: STD_LOGIC_VECTOR (7 downto 0);
	signal s_RX_COUNT: STD_LOGIC_VECTOR (5 downto 0);
	
	signal s_data0: STD_LOGIC_VECTOR (31 downto 0);
	signal s_data1: STD_LOGIC_VECTOR (31 downto 0);
	signal s_data2: STD_LOGIC_VECTOR (31 downto 0);
	signal s_data3: STD_LOGIC_VECTOR (31 downto 0);
	
	signal s_spi_mode: STD_LOGIC_VECTOR (1 downto 0);
	signal s_clk_scale: STD_LOGIC_VECTOR (15 downto 0);
	signal s_cs_inactive_clks: STD_LOGIC_VECTOR (7 downto 0);
	signal s_TX_Count: STD_LOGIC_VECTOR (5 downto 0);
	signal s_TX_Byte: STD_LOGIC_VECTOR (7 downto 0);
	signal s_TX_DV: STD_LOGIC;
	signal s_TX_Ready: STD_LOGIC;
	signal s_spi_cs_n: STD_LOGIC;

begin

-- Instantiation of Axi Bus Interface S00_AXI
SPI_Master_IP_v1_0_S00_AXI_inst : SPI_Master_IP_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    S_AXI_O_SPI_MODE => s_spi_mode,
	    S_AXI_O_CLK_SCALE => s_clk_scale,
	    S_AXI_O_CS_INACTIVE_CLKS => s_cs_inactive_clks,
	    S_AXI_I_TX_READY => s_TX_Ready,
	    S_AXI_O_TX_DV => s_TX_DV,
	    S_AXI_O_TX_COUNT => s_TX_Count,
	    S_AXI_O_TX_BYTE => s_TX_Byte,
	    S_AXI_I_data0 => s_data0,
	    S_AXI_I_data1 => s_data1,
	    S_AXI_I_data2 => s_data2,
	    S_AXI_I_data3 => s_data3,
	    S_AXI_I_SPI_CS_N => s_spi_cs_n,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
    SPI_MASTER_CS : SPI_Master_With_Single_CS
        port map(
            i_Rst_L => s00_axi_aresetn,
            i_Clk => s00_axi_aclk,
            i_spi_mode => s_spi_mode,
            i_clk_scale => s_clk_scale,
            i_cs_inactive_clks => s_cs_inactive_clks,
            i_TX_Count => s_TX_Count,
            i_TX_Byte => s_TX_Byte,
            i_TX_DV => s_TX_DV,
            o_TX_Ready => s_TX_Ready,
            o_RX_Count => s_RX_COUNT,
            o_RX_DV => s_RX_DV,
            o_RX_Byte => s_RX_BYTE,
            o_SPI_Clk => o_SPI_Clk_TOP,
            i_SPI_MISO => i_SPI_MISO_TOP,
            o_SPI_MOSI => o_SPI_MOSI_TOP,
            o_SPI_CS_n => s_spi_cs_n
        );
        
    DEMUX: demux_byte_RX
        Port map ( i_rst => s00_axi_aresetn,
                   i_RX_DV => s_RX_DV,
                   RX_Byte => s_RX_BYTE,
                   RX_Count => s_RX_COUNT,
                   data0 => s_data0,
                   data1 => s_data1,
                   data2 => s_data2,
                   data3 => s_data3 
        );
    
    o_SPI_CS_n_TOP <= s_spi_cs_n;
	-- User logic ends

end arch_imp;