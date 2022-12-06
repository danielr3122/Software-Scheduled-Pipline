-------------------------------------------------------------------------
-- Daniel Rosenhamer
-- Student of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ID_EX_Register.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is an implementation of our ID/EX Register
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX_Register is
    generic(N   : integer := 32);
    port(
        i_CLK       : in std_logic,
        i_RST       : in std_logic,
        i_PCNext    : in st_logic_vector(N-1 downto 0),
        o_PCNext    : out st_logic_vector(N-1 downto 0));
end ID_EX_Register;

architecture structural of ID_EX_Register is

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
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_PCNext,
                o_Data      => o_PCNext);

        g_IMemReg: register_N
        port map(
            i_Clock     => i_CLK,
            i_Reset     => i_RST,
            i_WriteEn   => '1',
            i_Data      => i_IMem,
            o_Data      => o_IMem);

end structural;