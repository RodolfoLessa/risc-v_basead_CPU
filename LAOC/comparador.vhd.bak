-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Rodolfo de Albuquerque Lessa Villa Verde

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
  port (
    entrada_a : in std_logic_vector(31 downto 0);
    entrada_b : in std_logic_vector(31 downto 0);
    controle : in std_logic_vector(1 downto 0);
    saida : out std_logic_vector(0 downto 0)
  );
end entity comparador;

architecture dataflow of comparador is
begin
  process(entrada_a, entrada_b, controle)
  begin
    case controle is
      when "00" =>  -- Maior que
        saida(0) <= '1' when (entrada_a > entrada_b) else '0';
      when "01" =>  -- Menor que
        saida(0) <= '1' when (entrada_a < entrada_b) else '0';
      when "10" =>  -- Igual a
        saida(0) <= '1' when (entrada_a = entrada_b) else '0';
      when others => -- Outros casos
        saida(0) <= '1';
    end case;
  end process;
end architecture dataflow;
