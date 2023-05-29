-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade de controle ciclo único (look-up table) do processador
-- puramente combinacional
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
    generic (
        INSTR_WIDTH       : natural := 32;
        OPCODE_WIDTH      : natural := 4;
        DP_CTRL_BUS_WIDTH : natural := 22;
        ULA_CTRL_WIDTH    : natural := 4
    );
    port (
        instrucao : in std_logic_vector(INSTR_WIDTH - 1 downto 0);       -- instrução
        controle  : out std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0) -- controle da via
    );
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is
    -- As linhas abaixo não produzem erro de compilação no Quartus II, mas no Modelsim (GHDL) produzem.	
    --signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);			-- instrucao
    --signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);			-- opcode
    --signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);		-- controle

    signal inst_aux : std_logic_vector (31 downto 0); -- instrucao
    signal opcode   : std_logic_vector (4 downto 0);  -- opcode
    signal ctrl_aux : std_logic_vector (21 downto 0);  -- controle

begin
    inst_aux <= instrucao;
    -- A linha abaixo não produz erro de compilação no Quartus II, mas no Modelsim (GHDL) produz.	
    --	opcode <= inst_aux (INSTR_WIDTH-1 downto INSTR_WIDTH-OPCODE_WIDTH);
    opcode <= inst_aux (4 downto 0);

    process (opcode)
    begin
        case opcode is
            when "00000" =>
              -- ADD
              ctrl_aux <= "110000000010011000";
            when "00001" =>
              -- ADDI
              ctrl_aux <= "101110000000100110";
            when "00010" =>
              -- SUB
              ctrl_aux <= "110000000010011010";
            when "00011" =>
              -- AUIPC
              ctrl_aux <= "100011000110011000";
            when "00100" =>
              -- XOR
              ctrl_aux <= "110000000010101100";
            when "00101" =>
              -- XORI
              ctrl_aux <= "101110000000110110";
            when "00110" =>
              -- OR
              ctrl_aux <= "110000000010100100";
            when "00111" =>
              -- ORI
              ctrl_aux <= "101110000000101110";
            when "01000" =>
              -- AND
              ctrl_aux <= "110000000010101000";
            when "01001" =>
              -- ANDI
              ctrl_aux <= "101110000000101010";
            when "01010" =>
              -- BEQ
              ctrl_aux <= "000010011010000000";
            when "01011" =>
              -- BLT
              ctrl_aux <= "000010011010001000";
            when "01100" =>
              -- BGE
              ctrl_aux <= "000010011010000000";
            when "01101" =>
              -- SLT
              ctrl_aux <= "110000000000100000";
            when "01110" =>
              -- SLTI
              ctrl_aux <= "101110000000100000";
            when "01111" =>
              -- LB
              ctrl_aux <= "101100000000110111";
            when "10000" =>
              -- LH
              ctrl_aux <= "101101000000110111";
            when "10001" =>
              -- LW
              ctrl_aux <= "101110000000110111";
            when "10010" =>
              -- SB
              ctrl_aux <= "001100000000111011";
            when "10011" =>
              -- SH
              ctrl_aux <= "001101000000111011";
            when "10100" =>
              -- SW
              ctrl_aux <= "001110000000111011";
            when "10101" =>
              -- JAL
              ctrl_aux <= "101110000111100110";
            when "10110" =>
              -- JUMP
              ctrl_aux <= "000000010000000000";
            when "11001" =>
              -- SLL
              ctrl_aux <= "110000000000111010";
            when "11010" =>
              -- SLLI
              ctrl_aux <= "101100000000111010";
            when "11011" =>
              -- SLR
              ctrl_aux <= "110000000000111100";
            when "11100" =>
              -- SLRI
              ctrl_aux <= "101100000000111100";
            when "11101" =>
              -- SRA
              ctrl_aux <= "110000000000111110";
            when "11110" =>
              -- SLRAI
              ctrl_aux <= "101100000000111110";
          end case;
    end process;
    controle <= ctrl_aux;
end beh;