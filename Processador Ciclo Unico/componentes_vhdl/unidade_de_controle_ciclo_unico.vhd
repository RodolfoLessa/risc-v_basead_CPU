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
        OPCODE_WIDTH      : natural := 5;
        DP_CTRL_BUS_WIDTH : natural := 16;
        ULA_CTRL_WIDTH    : natural := 3
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
    signal ctrl_aux : std_logic_vector (15 downto 0);  -- controle

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
              ctrl_aux <= "1110000000000000";
            when "00001" =>
              -- ADDI
              ctrl_aux <= "1100000100000000";
            when "00010" =>
              -- SUB
              ctrl_aux <= "1110000000000001";
            when "00011" =>
              -- XOR
              ctrl_aux <= "1110000000000100";
            when "00100" =>
              -- XORI
              ctrl_aux <= "1100000100000100";
            when "00101" =>
              -- OR
              ctrl_aux <= "1110000000000011";
            when "00110" =>
              -- ORI
              ctrl_aux <= "1100000100000011";
            when "00111" =>
              -- AND
              ctrl_aux <= "1110000000000010";
            when "01000" =>
              -- ANDI
              ctrl_aux <= "1100000100000010";
            when "01001" =>
              -- BEQ
              ctrl_aux <= "1001000000000101";
            when "01010" =>
              -- BLT
              ctrl_aux <= "1001000000000111";
            when "01011" =>
              -- BGE
              ctrl_aux <= "1001000000000110";
            when "01100" =>
              -- LW
              ctrl_aux <= "1100001101000000";
            when "01101" =>
              -- SW
              ctrl_aux <= "1000010100000000";
            when "01110" =>
              -- JAL
              ctrl_aux <= "1110100011000000";
            when "01111" =>
              -- JUMP
              ctrl_aux <= "1000100000000000";
            when "10010" =>
              -- SLR
              ctrl_aux <= "1110000010000000";
            when "10011" =>
              -- SLL
              ctrl_aux <= "1110000010001000";
            when "10100" =>
              -- ROR
              ctrl_aux <= "1110000010010000";
				  when others =>
				     ctrl_aux <= (others => '0');
			 end case;
    end process;
    controle <= ctrl_aux;
end beh;