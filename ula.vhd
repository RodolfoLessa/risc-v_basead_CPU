-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade Lógica e Aritmética com capacidade para 8 operações distintas, além de entradas e saída de dados genérica.
-- Os três bits que selecionam o tipo de operação da ULA são os 3 bits menos significativos do OPCODE (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    generic (
        largura_dado : natural
    );

    port (
        entrada_a   : in std_logic_vector((largura_dado - 1) downto 0);
        entrada_b   : in std_logic_vector((largura_dado - 1) downto 0);
        seletor     : in std_logic_vector(2 downto 0);
        saida       : out std_logic_vector((largura_dado - 1) downto 0);
        saida_zero  : out std_logic
    );
end ula;

architecture comportamental of ula is
    signal resultado_ula        : std_logic_vector((largura_dado - 1) downto 0);
    signal resultado_ula_zero   : std_logic;
begin
	process(entrada_a, entrada_b, seletor) is
	variable diferenca : signed((largura_dado - 1) downto 0);
	begin
		 diferenca := signed(entrada_a) - signed(entrada_b);
		 case(seletor) is
            when "000" => -- soma com sinal
            resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
				resultado_ula_zero <= '0';
            when "001" => -- soma estendida
            resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
				resultado_ula_zero <= '0';
            when "010" => -- and lógico
            resultado_ula <= entrada_a and entrada_b;
				resultado_ula_zero <= '0';
            when "011" => -- or lógico
            resultado_ula <= entrada_a or entrada_b;
				resultado_ula_zero <= '0';
            when "100" => -- xor lógico
            resultado_ula <= entrada_a xor entrada_b;
				resultado_ula_zero <= '0';
            when "101" => -- ==
				resultado_ula <= (others => '0');
            resultado_ula_zero  <= not diferenca(largura_dado - 1);
            when "110" => -- <=
				resultado_ula <= (others => '0');
            resultado_ula_zero  <= diferenca(largura_dado - 1);
            when "111" => -- >= 
				resultado_ula <= (others => '0');
            resultado_ula_zero  <= not diferenca(largura_dado - 1); 
            when others => -- xnor lógico
            resultado_ula <= entrada_a xnor entrada_b;
				resultado_ula_zero <= '0';
         end case;
    end process;
    saida <= resultado_ula;
    saida_zero <= resultado_ula_zero;
end comportamental;