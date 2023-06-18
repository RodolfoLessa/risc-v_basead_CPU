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
    process (entrada_a, entrada_b, seletor) is
       variable maior_que: std_logic;
		 variable menor_que: std_logic;
		 variable igual_que: std_logic;
    begin

	    if signed(entrada_a) > signed(entrada_b) then
            maior_que := '1';
            menor_que := '0';
            igual_que := '0';
       elsif signed(entrada_a) < signed(entrada_b) then
            maior_que := '0';
            menor_que := '1';
            igual_que := '0';
       else
            maior_que := '0';
            menor_que := '0';
            igual_que := '1';
       end if;
       
		 case(seletor) is
            when "000" => -- soma com sinal
            resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
            when "001" => -- soma estendida
            resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
            when "010" => -- and lógico
            resultado_ula <= entrada_a and entrada_b;
            when "011" => -- or lógico
            resultado_ula <= entrada_a or entrada_b;
            when "100" => -- xor lógico
            resultado_ula <= entrada_a xor entrada_b;
            when "101" => -- ==
            resultado_ula_zero  <= igual_que;
            when "110" => -- <=
            resultado_ula_zero  <= menor_que;
            when "111" => -- >= 
            resultado_ula_zero  <= maior_que; 
            when others => -- xnor lógico
            resultado_ula <= entrada_a xnor entrada_b;
        end case;
    end process;
    saida <= resultado_ula;
    saida_zero <= resultado_ula_zero;
end comportamental;