-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Extensor de sinais. Replica o bit de sinal da entrada Rs (largura_saida-largura_dado) vezes.

library ieee;
use ieee.std_logic_1164.all;

entity concatenador is
    port (
      input: in std_logic_vector(11 downto 0);
      output: out std_logic_vector(31 downto 12)
    );
  end entity concatenador;
  
  architecture Behavioral of concatenador is
  begin
    process (input)
    begin
      output <= (others => '0') & input;
    end process;
  end architecture Behavioral;
  