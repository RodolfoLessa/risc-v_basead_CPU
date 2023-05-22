-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Rodolfo de Albuquerque Lessa Villa Verde

library ieee;
use ieee.std_logic_1164.all;

entity porta_and is
  port (
    entrada_a : in std_logic;
    entrada_b : in std_logic;
    saida     : out std_logic
  );
end entity porta_and;

architecture dataflow of porta_and is
begin
    saida <= entrada_a and entrada_b;
end architecture dataflow;
