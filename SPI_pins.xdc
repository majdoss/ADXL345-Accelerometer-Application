# ZedBoard xdc

# PMOD Connections
# JA1
set_property PACKAGE_PIN Y11 [get_ports { o_SPI_CS_n_TOP_0 }];
# JA2
set_property PACKAGE_PIN AA11 [get_ports { o_SPI_MOSI_TOP_0 }];
# JA3
set_property PACKAGE_PIN Y10 [get_ports { i_SPI_MISO_TOP_0 }];
# JA4
set_property PACKAGE_PIN AA9 [get_ports { o_SPI_Clk_TOP_0 }];

set_property IOSTANDARD LVCMOS33 [get_ports { o_SPI_CS_n_TOP_0 }];
set_property IOSTANDARD LVCMOS33 [get_ports { o_SPI_MOSI_TOP_0 }];
set_property IOSTANDARD LVCMOS33 [get_ports { i_SPI_MISO_TOP_0 }];
set_property IOSTANDARD LVCMOS33 [get_ports { o_SPI_Clk_TOP_0 }];
