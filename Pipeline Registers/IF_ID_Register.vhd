-------------------------------------------------------------------------
-- Daniel Rosenhamer
-- Student of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- IF_ID_Register.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is an implementation of our IF/ID Register
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID_Register is
    generic(N   : integer := 32);
    port(
        i_CLK       : in std_logic,
        i_RST       : in std_logic,
        i_IMem      : in st_logic_vector(N-1 downto 0),
        i_PCNext    : in st_logic_vector(N-1 downto 0),
        o_IMem      : out st_logic_vector(N-1 downto 0),
        o_PCNext    : out st_logic_vector(N-1 downto 0));
end IF_ID_Register;

architecture structural of IF_ID_Register is

    component register_N is
        generic(N : integer := 32);
        port(i_Clock    : in std_logic;
             i_Reset    : in std_logic;
             i_WriteEn  : in std_logic;
             i_Data     : in std_logic_vector(N-1 downto 0);
             o_Data     : out std_logic_vector(N-1 downto 0));
    end component;

    begin
        
        g_PCReg: register_N
        

end structural;