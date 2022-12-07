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
    port(i_CLK               : in std_logic;
         i_RST               : in std_logic;
         i_PCNext            : in std_logic_vector(31 downto 0);
         i_Halt              : in std_logic;
         i_Write_Data_Sel    : in std_logic_vector(1 downto 0);
         i_DMemWr            : in std_logic;
         i_ALUsrc            : in std_logic;
         i_RegDest           : in std_logic_vector(1 downto 0);
         i_RegWr             : in std_logic;
         i_ShiftType         : in std_logic_vector(1 downto 0);
         i_ALUop             : in std_logic_vector(3 downto 0);
         i_ALUslt            : in std_logic;
         i_nAdd_Sub          : in std_logic;
         i_UnsignedSelect    : in std_logic;
         i_extendedImm       : in std_logic_vector(31 downto 0);
         i_readData1         : in std_logic_vector(31 downto 0);
         i_readData2         : in std_logic_vector(31 downto 0);
         i_instr             : in std_logic_vector(31 downto 0);
         o_PCNext            : out std_logic_vector(31 downto 0);
         o_Halt              : out std_logic;
         o_Write_Data_Sel    : out std_logic_vector(1 downto 0);
         o_DMemWr            : out std_logic;
         o_ALUsrc            : out std_logic;
         o_RegDest           : out std_logic_vector(1 downto 0);
         o_RegWr             : out std_logic;
         o_ShiftType         : out std_logic_vector(1 downto 0);
         o_ALUop             : out std_logic_vector(3 downto 0);
         o_ALUslt            : out std_logic;
         o_nAdd_Sub          : out std_logic;
         o_UnsignedSelect    : out std_logic;
         o_extendedImm       : out std_logic_vector(31 downto 0);
         o_readData1         : out std_logic_vector(31 downto 0);
         o_readData2         : out std_logic_vector(31 downto 0);
         o_instr             : out std_logic_vector(31 downto 0));
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

        g_Halt: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_Halt,
                o_Data      => o_Halt);

        g_Write_Data_Sel: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_Write_Data_Sel,
                o_Data      => o_Write_Data_Sel);

        g_DMemWr: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_DMemWr,
                o_Data      => o_DMemWr);

        g_ALUsrc: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_ALUsrc,
                o_Data      => o_ALUsrc);

        g_RegDest: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_RegDest,
                o_Data      => o_RegDest);

        g_RegWr: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_RegWr,
                o_Data      => o_RegWr);

        g_ShiftType: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_ShiftType,
                o_Data      => o_ShiftType);

        g_ALUop: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_ALUop,
                o_Data      => o_ALUop);

        g_ALUslt: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_ALUslt,
                o_Data      => o_ALUslt);

        g_nAdd_Sub: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_nAdd_Sub,
                o_Data      => o_nAdd_Sub);

        g_UnsignedSelect: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_UnsignedSelect,
                o_Data      => o_UnsignedSelect);

        g_extendedImm: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_extendedImm,
                o_Data      => o_extendedImm);

        g_readData1: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_readData1,
                o_Data      => o_readData1);

        g_readData2: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_readData2,
                o_Data      => o_readData2);

        g_instr: register_N
            port map(
                i_Clock     => i_CLK,
                i_Reset     => i_RST,
                i_WriteEn   => '1',
                i_Data      => i_instr,
                o_Data      => o_instr);

end structural;