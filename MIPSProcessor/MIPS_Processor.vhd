-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  -------------------------
  --- General Components --
  -------------------------

  component mux2t1_32b is 
    generic(N : integer := 32);
    port(i_s        : in std_logic;
        i_d0       : in std_logic_vector(N-1 downto 0);
        i_d1       : in std_logic_vector(N-1 downto 0);
        o_o        : out std_logic_vector(N-1 downto 0));
  end component;

  component mux4t1_5 is
      generic(N   : integer := 5; M  : integer := 2);
      port(i_d0       : in std_logic_vector(N-1 downto 0);
           i_d1       : in std_logic_vector(N-1 downto 0);
           i_d2       : in std_logic_vector(N-1 downto 0);
           i_d3       : in std_logic_vector(N-1 downto 0);
           i_s        : in std_logic_vector(M-1 downto 0);
           o_o        : out std_logic_vector(N-1 downto 0));
  end component;

  component mux4t1_32 is
      generic(N   : integer := 32; M  : integer := 2);
      port(i_d0       : in std_logic_vector(N-1 downto 0);
           i_d1       : in std_logic_vector(N-1 downto 0);
           i_d2       : in std_logic_vector(N-1 downto 0);
           i_d3       : in std_logic_vector(N-1 downto 0);
           i_s        : in std_logic_vector(M-1 downto 0);
           o_o        : out std_logic_vector(N-1 downto 0));
  end component;
  
  -------------------------
  ----- PC Addressing -----
  -------------------------

  component register_N is
    generic(N : integer := 32);
    port(i_Clock    : in std_logic;
         i_Reset    : in std_logic;
         i_WriteEn  : in std_logic;
         i_Data     : in std_logic_vector(N-1 downto 0);
         o_Data     : out std_logic_vector(N-1 downto 0));
  end component;

  component shiftLeftTwo_28 is
    generic(N   : integer := 26; M   : integer := 28);
    port(i_d0       : in std_logic_vector(N-1 downto 0);
         o_o        : out std_logic_vector(M-1 downto 0));
  end component;

  component shiftLeftTwo_32 is
      generic(N   : integer := 32);
      port(i_d0       : in std_logic_vector(N-1 downto 0);
           o_o        : out std_logic_vector(N-1 downto 0));
  end component;

  component BranchAdder is
      generic(N   : integer := 32);
      port(i_d0       : in std_logic_vector(N-1 downto 0);
           i_d1       : in std_logic_vector(N-1 downto 0);
           o_o        : out std_logic_vector(N-1 downto 0));
  end component;

  component PCPlusFour is
      generic(N   : integer := 32);
      port(i_d0       : in std_logic_vector(N-1 downto 0);
           o_o        : out std_logic_vector(N-1 downto 0));
  end component;

  -------------------------
  ------ Control Unit -----
  -------------------------

  component ControlUnit is 
    port(i_opCode           : in std_logic_vector(5 downto 0);
         i_funct            : in std_logic_vector(5 downto 0);
         shiftType          : out std_logic_vector(1 downto 0);
         ALUop              : out std_logic_vector(3 downto 0);
         ALUslt             : out std_logic;
         nAdd_Sub           : out std_logic;
         unsignedSel        : out std_logic;
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
    end component;

  -------------------------
  ------ Register File ----
  -------------------------

  component regFile_MIPS is
    generic(N : integer := 32;
            M : integer := 5); 
    port(i_Clock        : in std_logic;
        i_Reset        : in std_logic;
        i_RegWrite     : in std_logic;
        i_WriteReg     : in std_logic_vector(M-1 downto 0);
        i_ReadReg1     : in std_logic_vector(M-1 downto 0);
        i_ReadReg2     : in std_logic_vector(M-1 downto 0);
        i_WriteData    : in std_logic_vector(N-1 downto 0);
        o_ReadData1    : out std_logic_vector(N-1 downto 0);
        o_ReadData2    : out std_logic_vector(N-1 downto 0));
  end component;

  -------------------------
  ------ Sign Extender ----
  -------------------------

  component extender16t32 is
    port(i_extSelect    : in std_logic;
        i_data16       : in std_logic_vector(15 downto 0);
        o_data32       : out std_logic_vector(31 downto 0));
  end component;

  -------------------------------------
  ----------------- ALU  --------------
  -------------------------------------

  component ALU is 
    port(i_opA               : in std_logic_vector(31 downto 0);
        i_opB                : in std_logic_vector(31 downto 0);
        i_RQBimm             : in std_logic_vector(7 downto 0);
        i_shamt              : in std_logic_vector(4 downto 0);
        i_shiftType          : in std_logic_vector(1 downto 0);
        i_ALUop              : in std_logic_vector(3 downto 0);
        i_ALUslt             : in std_logic;
        i_nAdd_Sub           : in std_logic;
        i_unsignedSelect     : in std_logic;
        o_ALUzero            : out std_logic;
        o_Overflow           : out std_logic;
        o_ALUresult          : out std_logic_vector(31 downto 0));
  end component;

  -------------------------------------
  -------- Pipeline Registers  --------
  -------------------------------------

  component IF_ID_Register is
    generic(N   : integer := 32);
    port(i_CLK              : in std_logic;
         i_RST              : in std_logic;
         i_IF_Inst          : in std_logic_vector(N-1 downto 0);
         i_IF_PCNext        : in std_logic_vector(N-1 downto 0);
         o_ID_Inst          : out std_logic_vector(N-1 downto 0);
         o_ID_PCNext        : out std_logic_vector(N-1 downto 0));
  end component;

  component ID_EX_Register is
    port(i_CLK                  : in std_logic;
         i_RST                  : in std_logic;
         i_ID_PCNext            : in std_logic_vector(31 downto 0);
         i_ID_Halt              : in std_logic;
         i_ID_DMemWr            : in std_logic;
         i_ID_Write_Data_Sel    : in std_logic_vector(1 downto 0);
         i_ID_ALUsrc            : in std_logic;
         i_ID_ShiftType         : in std_logic_vector(1 downto 0);
         i_ID_ALUop             : in std_logic_vector(3 downto 0);
         i_ID_ALUslt            : in std_logic;
         i_ID_nAdd_Sub          : in std_logic;
         i_ID_UnsignedSelect    : in std_logic;
         i_ID_RegWr             : in std_logic;
         i_ID_RegDest           : in std_logic_vector(1 downto 0);
         i_ID_Inst              : in std_logic_vector(31 downto 0);
         i_ID_extendedImm       : in std_logic_vector(31 downto 0);
         i_ID_readData1         : in std_logic_vector(31 downto 0);
         i_ID_readData2         : in std_logic_vector(31 downto 0);
         o_EX_PCNext            : out std_logic_vector(31 downto 0);
         o_EX_Halt              : out std_logic;
         o_EX_DMemWr            : out std_logic;
         o_EX_Write_Data_Sel    : out std_logic_vector(1 downto 0);
         o_EX_RegWr             : out std_logic;
         o_EX_readData1         : out std_logic_vector(31 downto 0);
         o_EX_readData2         : out std_logic_vector(31 downto 0);
         o_EX_extendedImm       : out std_logic_vector(31 downto 0);
         o_EX_ALUsrc            : out std_logic;
         o_EX_ShiftType         : out std_logic_vector(1 downto 0);
         o_EX_ALUop             : out std_logic_vector(3 downto 0);
         o_EX_ALUslt            : out std_logic;
         o_EX_nAdd_Sub          : out std_logic;
         o_EX_UnsignedSelect    : out std_logic;
         o_EX_RegDest           : out std_logic_vector(1 downto 0);
         o_EX_Inst              : out std_logic_vector(31 downto 0));
  end component;

  component EX_MEM_Register is
    port(i_CLK                  : in std_logic;
         i_RST                  : in std_logic;
         i_EX_PCNext            : in std_logic_vector(31 downto 0);
         i_EX_Halt              : in std_logic;
         i_EX_DMemWr            : in std_logic;
         i_EX_Write_Data_Sel    : in std_logic_vector(1 downto 0);
         i_EX_RegWr             : in std_logic;
         i_EX_Ovfl              : in std_logic;
         i_EX_ALUout            : in std_logic_vector(31 downto 0);
         i_EX_RegWrAddr         : in std_logic_vector(4 downto 0);
         o_MEM_PCNext           : in std_logic_vector(31 downto 0);
         o_MEM_Halt             : in std_logic;
         o_MEM_DMemWr           : in std_logic;
         o_MEM_Write_Data_Sel   : in std_logic_vector(1 downto 0);
         o_MEM_RegWr            : in std_logic;
         o_MEM_Ovfl             : in std_logic;
         o_MEM_ALUout           : in std_logic_vector(31 downto 0);
         o_MEM_RegWrAddr        : in std_logic_vector(4 downto 0));
  end component;

  component MEM_WB_Register is
    generic(N   : integer := 32);
    port(i_CLK                  : in std_logic;
         i_RST                  : in std_logic;
         i_MEM_PCNext           : in std_logic_vector(31 downto 0);
         i_MEM_Halt             : in std_logic;
         i_MEM_Write_Data_Sel   : in std_logic_vector(1 downto 0);
         i_MEM_RegWr            : in std_logic;
         i_MEM_Ovfl             : in std_logic;
         i_MEM_ALUout           : in std_logic_vector(31 downto 0);
         i_MEM_DMemOut          : in std_logic_vector(31 downto 0);
         i_MEM_RegWrAddr        : in std_logic_vector(4 downto 0);
         o_WB_Halt              : out std_logic;
         o_WB_Ovfl              : out std_logic;
         o_WB_ALUout            : out std_logic_vector(31 downto 0);
         o_WB_Write_Data_Sel    : out std_logic_vector(1 downto 0);
         o_WB_DMemOut           : out std_logic_vector(31 downto 0);
         o_WB_PCNext            : out std_logic_vector(31 downto 0);
         o_WB_RegWrAddr         : out std_logic_vector(4 downto 0);
         o_WB_RegWr             : out std_logic);
  end component;

  -------------------------------------
  ----------- Fetch Signals -----------
  -------------------------------------

  signal s_jumpToPC,
         s_IF_PCNext,
         s_IF_Inst     : std_logic_vector(31 downto 0);

  -------------------------------------
  ---------- Decode Signals -----------
  -------------------------------------

  signal s_ID_PCNext, 
         s_ID_Inst,
         s_ID_jumpAddr32,
         s_ID_extendedImm,
         s_ID_branchTarget,
         s_ID_readData1,
         s_ID_readData2,
         s_ID_branchResult,
         s_ID_branchMuxOut,
         s_ID_jumpMuxOut,
         s_ID_muxToPC : std_logic_vector(31 downto 0);

  signal s_ID_BranchType,
         s_ID_BranchInstr,
         s_ID_JumpInstr,
         s_ID_JumpReg,
         s_ID_Halt,
         s_ID_DMemWr,
         s_ID_ALUsrc,
         s_ID_ALUslt,
         s_ID_nAdd_Sub,
         s_ID_UnsignedSel,
         s_ID_RegWr,
         s_ID_extSel,
         s_ID_xor,
         s_ID_and,
         s_ID_sameData : std_logic;

  signal s_ID_Write_Data_Sel,
         s_ID_ShiftType,
         s_ID_RegDest : std_logic_vector(1 downto 0);

  signal s_ID_ALUop : std_logic_vector(3 downto 0);

  signal s_ID_jumpAddr28  : std_logic_vector(27 downto 0);

  -------------------------------------
  ---------- Execute Signals ----------
  -------------------------------------

  signal s_EX_PCNext,
         s_EX_readData1,
         s_EX_readData2,
         s_EX_extendedImm,
         s_EX_Inst,
         s_EX_ALUSrcMuxOut,
         s_EX_ALUout : std_logic_vector(31 downto 0);

  signal s_EX_Halt,
         s_EX_DMemWr,
         s_EX_RegWr,
         s_EX_ALUsrc,
         s_EX_ALUslt,
         s_EX_nAdd_Sub,
         s_EX_UnsignedSel,
         s_EX_Ovfl : std_logic;

  signal s_EX_Write_Data_Sel,
         s_EX_ShiftType,
         s_EX_RegDest

  signal s_ID_ALUop : std_logic_vector(3 downto 0);

  signal s_EX_RegWrAddr : std_logic_vector(4 downto 0);

  -------------------------------------
  ---------- Memory Signals -----------
  -------------------------------------

  signal s_MEM_PCnext,
         s_MEM_ALUout,
         s_MEM_DMemData,  -- TODO: aka read data 2
         s_MEM_DMemOut : std_logic_vector(31 downto 0);

  signal s_MEM_Halt,
         s_MEM_RegWr,
         s_MEM_Ovfl,
         s_MEM_DMemWr : std_logic;

  signal s_MEM_Write_Data_Sel : std_logic_vector(1 downto 0);

  signal s_MEM_DMemAddr,
         s_MEM_RegWrAddr : std_logic_vector(4 downto 0);

  -------------------------------------
  -------- Write Back Signals ---------
  -------------------------------------

  signal s_WB_Write_Data_Sel : std_logic_vector(1 downto 0);

  signal s_WB_RegWr : std_logic;

  signal s_WB_DMemOut,
         s_WB_PCNext : std_logic_vector(31 downto 0);

  signal s_WB_RegWrAddr : std_logic_vector(4 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  -- TODO: move to mem stage
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

--------------------------
------- Fetch Stage ------
--------------------------

  s_pcSelect <= '1' when (s_BranchType xor s_sameData) and s_branchInstr else
                '1' when s_JumpInstr else
                '1' when s_JumpReg else
                '0';

  g_PCPlusFour: PCPlusFour
    port map(i_d0 => s_NextInstAddr,
            o_o  => s_pcNext);

  g_PCMux: mux2t1_32b
    port map(i_s   => s_pcSelect,
             i_d0  => s_pcNext,
             i_d1  => s_muxToPC,
             o_o   => s_pcInput);

  g_PC: register_N
    port map(i_Clock    => iCLK,
             i_Reset    => iRST,
             i_WriteEn  => '1',
             i_Data     => s_pcInput,
             o_Data     => s_NextInstAddr);

  g_IF_ID: IF_ID_Register
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_IMem   => s_Inst,
             i_PCNext => s_pcNext,
             o_Imem   => 
             o_PCNext =>);

---------------------------
------- Decode Stage ------
---------------------------

  g_ShiftLeftTwo_28: shiftLeftTwo_28
  port map(i_d0 => s_Inst(25 downto 0),
           o_o  => s_jumpAddr28);

  s_jumpAddr32 <= s_pcNext(31 downto 28) & s_jumpAddr28;

  g_ShiftLeftTwo_32: shiftLeftTwo_32
    port map(i_d0 => s_extendedImmediate,
             o_o  => s_branchImmediate);

  g_BranchAdder: BranchAdder
    port map(i_d0 => s_pcNext,
             i_d1 => s_branchImmediate,
             o_o  => s_branchResult);

  s_sameData <= '1' when (s_readData1 = s_readData2) else '0';
  s_xor <= s_sameData xor s_BranchType;
  s_and <= s_xor and s_BranchInstr;

  g_BranchMux: mux2t1_32b
    port map(i_s  => s_and,
             i_d0 => s_pcNext,
             i_d1 => s_branchResult,
             o_o  => s_branchMuxOut);

  g_JumpMux: mux2t1_32b
    port map(i_s  => s_JumpInstr,
            i_d0 => s_branchMuxOut,
            i_d1 => s_jumpAddr32,
            o_o  => s_jumpMuxOut);

  g_MUXToPC: mux2t1_32b
    port map(i_s  => s_JumpReg,
            i_d0 => s_jumpMuxOut,
            i_d1 => s_readData1,
            o_o  => s_muxToPC);

  g_ControlUnit: ControlUnit
    port map(i_opCode => s_Inst(31 downto 26),      
            i_funct => s_Inst(5 downto 0),
            shiftType => s_shiftType,
            ALUop => s_ALUop,
            ALUslt => s_ALUslt,
            nAdd_Sub => s_nAdd_Sub,
            unsignedSel => s_UnsignedSel,
            RegDest => s_RegDest,
            RegWr => s_RegWr,         
            extSel => s_extSel,      
            ALUsrc => s_ALUsrc,        
            BranchType => s_BranchType,   
            BranchInstr => s_BranchInstr,  
            JumpInstr => s_JumpInstr,    
            JumpReg => s_JumpReg,      
            DMemWr => s_DMemWr,       
            Write_Data_Sel => s_Write_Data_Sel,
            Halt => s_Halt);

  -- TODO: put it in writeback stage
  g_WriteRegMux: mux4t1_5
    port map(i_d0 => s_Inst(20 downto 16),
            i_d1 => b"11111",
            i_d2 => s_Inst(15 downto 11),
            i_d3 => b"00000",
            i_s  => s_RegDest,
            o_o  => s_RegWrAddr);

  g_RegisterFile: regFile_MIPS
    port map(i_Clock => iCLK,    
             i_Reset => iRST,   
             i_RegWrite => s_RegWr,
             i_WriteReg => s_RegWrAddr,
             i_ReadReg1 => s_Inst(25 downto 21),
             i_ReadReg2 => s_Inst(20 downto 16),
             i_WriteData => s_RegWrData,
             o_ReadData1 => s_readData1,
             o_ReadData2 => s_readData2);

  g_SignExtender: extender16t32
    port map(i_extSelect => s_extSel,
             i_data16 => s_Inst(15 downto 0),  
             o_data32 => s_extendedImmediate);

  s_DMemData <= s_readData2;

  -- TODO: add id/ex reg
  g_ID_EX: ID_EX_Register
    port map(i_CLK              => i_CLK,
             i_RST              => i_RST,
             i_PCNext           => s_pcNext,
             i_Halt             => s_Halt,
             i_Write_Data_Sel   => 
             i_DMemWr           =>
             i_ALUsrc           =>
             i_RegDest          =>
             i_RegWr            =>
             i_ShiftType        =>
             i_ALUop            =>
             i_ALUslt           =>
             i_nAdd_Sub         =>
             i_UnsignedSelect   =>
             i_extendedImm      =>
             i_readData1        =>
             i_readData2        =>  
             i_instr            =>
             o_PCNext           =>
             o_Halt             =>
             o_Write_Data_Sel   =>
             o_DMemWr           =>
             o_ALUsrc           =>
             o_RegDest          =>
             o_RegWr            =>
             o_ShiftType        =>
             o_ALUop            =>
             o_ALUslt           =>
             o_nAdd_Sub         =>
             o_UnsignedSelect   =>
             o_extendedImm      =>
             o_readData1        =>
             o_readData2        =>
             o_instr            =>);

----------------------------
------- Execute Stage ------
----------------------------

  g_ALUSrcMux: mux2t1_32b
    port map(i_s => s_ALUsrc, 
             i_d0 => s_readData2,
             i_d1 => s_extendedImmediate,
             o_o => s_ALUSrcMuxOut);

  g_ALU: ALU
    port map(i_opA => s_readData1,          
             i_opB => s_ALUSrcMuxOut,
             i_RQBimm => s_Inst(23 downto 16),       
             i_shamt => s_Inst(10 downto 6),       
             i_shiftType => s_shiftType,
             i_ALUop => s_ALUop,        
             i_ALUslt => s_ALUslt,      
             i_nAdd_Sub => s_nAdd_Sub,     
             i_unsignedSelect => s_UnsignedSel,
             o_ALUzero => s_ALUzero,       
             o_Overflow => s_Ovfl,     
             o_ALUresult => s_ALUresult);

  s_DMemAddr <= s_ALUresult;

  g_RegWriteMux: mux4t1_32
    port map(i_d0 => s_DMemOut,
             i_d1 => s_pcNext,
             i_d2 => s_ALUresult,
             i_d3 => x"0000_0000",
             i_s  => s_Write_Data_Sel,
             o_o => s_RegWrData);

  oALUOut <= s_ALUresult;

end structure;

