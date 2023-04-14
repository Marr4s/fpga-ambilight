##HDMI RX Signals

set_property -dict { PACKAGE_PIN P19   IOSTANDARD TMDS_33  } [get_ports { TMDS_clk_n }]; #IO_L13N_T2_MRCC_34 Sch=HDMI_RX_CLK_N
set_property -dict { PACKAGE_PIN N18   IOSTANDARD TMDS_33  } [get_ports { TMDS_clk_p }]; #IO_L13P_T2_MRCC_34 Sch=HDMI_RX_CLK_P
create_clock -period 6.734 -waveform {0 3.367} [get_ports { TMDS_clk_p }];
set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_n[0]}]; #IO_L16N_T2_34 Sch=HDMI_RX_D0_N
set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_p[0]}]; #IO_L16P_T2_34 Sch=HDMI_RX_D0_P
set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_n[1]}]; #IO_L15N_T2_DQS_34 Sch=HDMI_RX_D1_N
set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_p[1]}]; #IO_L15P_T2_DQS_34 Sch=HDMI_RX_D1_P
set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_n[2]}]; #IO_L14N_T2_SRCC_34 Sch=HDMI_RX_D2_N
set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33  } [get_ports { TMDS_data_p[2]}]; #IO_L14P_T2_SRCC_34 Sch=HDMI_RX_D2_P
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_hpd_tri_o[0] }]; #IO_25_34 Sch=HDMI_RX_HPD
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]; #IO_25_34 Sch=HDMI_RX_HP
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { DDC_scl_io }]; #IO_L11P_T1_SRCC_34 Sch=HDMI_RX_SCL
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { DDC_sda_io }]; #IO_L11N_T1_SRCC_34 Sch=HDMI_RX_SDA

##HDMI TX Signals

set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_clk_n }]; #IO_L11N_T1_SRCC_35 Sch=HDMI_TX_CLK_N
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_clk_p }]; #IO_L11P_T1_SRCC_35 Sch=HDMI_TX_CLK_P
set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=HDMI_TX_D0_N
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[0]  }]; #IO_L12P_T1_MRCC_35 Sch=HDMI_TX_D0_P
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[1]  }]; #IO_L10N_T1_AD11N_35 Sch=HDMI_TX_D1_N
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[1]  }]; #IO_L10P_T1_AD11P_35 Sch=HDMI_TX_D1_P
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[2]  }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=HDMI_TX_D2_N
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[2]  }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=HDMI_TX_D2_P

## ChipKit Outer Digital Header
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { led_data  }]; #IO_L5P_T0_34            Sch=CK_IO0
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { ck_io1  }]; #IO_L2N_T0_34            Sch=CK_IO1
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { ck_io2  }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=CK_IO2
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { ck_io3  }]; #IO_L3N_T0_DQS_34        Sch=CK_IO3
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { ck_io4  }]; #IO_L10P_T1_34           Sch=CK_IO4
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { ck_io5  }]; #IO_L5N_T0_34            Sch=CK_IO5
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ck_io6  }]; #IO_L19P_T3_34           Sch=CK_IO6
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { ck_io7  }]; #IO_L9N_T1_DQS_34        Sch=CK_IO7
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { ck_io8  }]; #IO_L21P_T3_DQS_34       Sch=CK_IO8
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { ck_io9  }]; #IO_L21N_T3_DQS_34       Sch=CK_IO9
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { ck_io10 }]; #IO_L9P_T1_DQS_34        Sch=CK_IO10
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ck_io11 }]; #IO_L19N_T3_VREF_34      Sch=CK_IO11
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { ck_io12 }]; #IO_L23N_T3_34           Sch=CK_IO12
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { ck_io13 }]; #IO_L23P_T3_34           Sch=CK_IO13