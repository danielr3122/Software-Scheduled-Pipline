-------------------------------------------------------------------------
-- Brayton Rude
-- rude87@iastate.edu
-------------------------------------------------------------------------
-- ControlUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the implementation of our MIPS Single
--              Cycle Processor's Control Unit
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ControlUnit is 
    port(i_opCode           : in std_logic_vector(5 downto 0);
         i_funct            : in std_logic_vector(5 downto 0);
         ALUControlOp       : out std_logic_vector(4 downto 0);
         RegDest            : out std_logic_vector(1 downto 0);
         RegWr              : out std_logic;
         extSel             : out std_logic;
         ALUsrc             : out std_logic;
         BranchType         : out std_logic;
         BranchInstr        : out std_logic;
         JumpInstr          : out std_logic;
         JumpReg            : out std_logic;
         DMemWr             : out std_logic;
         Write_Data_Sel     : out std_logic_vector(1 downto 0);
         Halt               : out std_logic);
end ControlUnit;

architecture dataflow of ControlUnit is 

    signal SelectVal             : std_logic_vector(11 downto 0);

begin

    with i_opCode select
        SelectVal <=  i_opCode & i_funct  when "000000", -- Currently only checks opcode for Repl.qb instruction, could use more checks
                      i_opCode & "000000" when others; 
    
    -- Setting ALUControlOp Signal
    with SelectVal select
        ALUControlOp <= b"00000" when b"000000_100000", -- add
                        b"00001" when b"000000_100001", -- addu
                        b"00010" when b"000000_100010", -- sub
                        b"00011" when b"000000_100011", -- subu
                        b"00100" when b"000000_100100", -- and
                        b"00101" when b"000000_100101", -- or 
                        b"00110" when b"000000_100110", -- xor
                        b"00111" when b"000000_100111", -- nor
                        b"01000" when b"000000_000000", -- sll
                        b"01001" when b"000000_000010", -- srl
                        b"01010" when b"000000_000011", -- sra
                        b"01011" when b"000000_011111", -- not (PICKED TEMPORARY FUNCTION CODE, MAY NEED CHANGED LATER)
                        b"01100" when b"000000_101010", -- slt
                        --b"xxxxx" when b"000000_001000", -- jr
                        b"01101" when b"001000_000000", -- addi
                        b"01110" when b"001001_000000", -- addiu
                        b"01111" when b"001100_000000", -- andi
                        b"10000" when b"001101_000000", -- ori
                        b"10001" when b"001110_000000", -- xori
                        b"10010" when b"001111_000000", -- lui
                        b"10011" when b"100011_000000", -- lw
                        b"10100" when b"101011_000000", -- sw
                        b"10101" when b"000100_000000", -- beq
                        b"10110" when b"000101_000000", -- bne
                        b"10111" when b"001010_000000", -- slti
                        --b"xxxxx" when b"000010_000000", -- j
                        --b"xxxxx" when b"000011_000000", -- jal
                        --b"xxxxx" when b"010100_000000", -- halt
                        b"11000" when b"011111_000000", -- Repl.qb
                        b"00000" when others;

    -- Setting RegDest Control Signal
    with SelectVal select                                                                               --<NOT-Line 77>
        RegDest <= b"10" when b"000000_100000" | b"000000_100001" | b"000000_100010" | b"000000_100011" | b"000000_100100" | b"000000_100101" | b"000000_100110" | 
                              b"000000_100111" | b"000000_000000" | b"000000_000010" | b"000000_000011" | b"000000_011111" | b"000000_101010" | b"011111_000000",
                   b"00" when b"001000_000000" | b"001001_000000" | b"001100_000000" | b"001101_000000" | b"001110_000000" | b"001111_000000" | b"100011_000000" | 
                              b"101011_000000" | b"000100_000000" | b"000101_000000" | b"001010_000000", 
                   b"01" when b"000011_000000",
                   b"01" when others;

    -- Setting RegWr Control Signal
    with SelectVal select                                                                            --<NOT-Line 86>
        RegWr <= '1' when b"000000_100000" | b"000000_100001" | b"000000_100010" | b"000000_100011" | b"000000_100100" | b"000000_100101" | b"000000_100110" | 
                          b"000000_100111" | b"000000_000000" | b"000000_000010" | b"000000_000011" | b"000000_011111" | b"000000_101010" | b"001000_000000" | 
                          b"001001_000000" | b"001100_000000" | b"001101_000000" | b"001110_000000" | b"001111_000000" | b"100011_000000" | b"001010_000000" | 
                          b"000011_000000" | b"011111_000000",
                 '0' when others;
    
    -- Setting extSel Control Signal
    with SelectVal select
        extSel <= '1' when b"001000_000000" | b"001001_000000" | b"100011_000000" | b"101011_000000" | b"001010_000000", -- addi, addiu, lw, sw, slti
                  '0' when others;

    -- Setting ALUsrc Control Signal
    with SelectVal select
        ALUsrc <= '1' when b"001000_000000" | b"001001_000000" | b"001100_000000" | b"001101_000000" | b"001110_000000" | b"001111_000000" | b"100011_000000" | 
                           b"101011_000000" | b"001010_000000",
                  '0' when others;

    -- Setting BranchType Control Signal     
    with SelectVal select
        BranchType <= '1' when b"000101_000000",
                      '0' when others;
    
    -- Setting BranchInstr Control Signal
    with SelectVal select
        BranchInstr <= '1' when b"000100_000000" | b"000101_000000",
                       '0' when others;

    -- Setting JumpInstr Control Signal
    with SelectVal select
        JumpInstr <= '1' when b"000000_001000" | b"000010_000000" | b"000011_000000",
                     '0' when others;

    -- Setting JumpReg Control Signal
    with SelectVal select
        JumpReg <= '1' when b"000000_001000",
                   '0' when others;
    
    -- Setting DMemWr Control Signal               
    with SelectVal select
        DMemWr <= '1' when b"101011_000000",
                  '0' when others;

    -- Setting Write_Data_Sel Control Signal              
    with SelectVal select
        Write_Data_Sel <= b"00" when b"100011_000000",
                          b"01" when b"000011_000000", --b"000000_001000",
                          b"10" when others;

    -- Setting Halt Control Signal
    with SelectVal select
        Halt <= '1' when b"010100_000000",
                '0' when others;
end dataflow;