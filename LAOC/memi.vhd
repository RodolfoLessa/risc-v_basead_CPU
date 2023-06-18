-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Memória de Programas ou Memória de Instruções de tamanho genérico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memi is
	generic (
		INSTR_WIDTH   : natural; -- tamanho da instrucaoo em numero de bits
		MI_ADDR_WIDTH : natural  -- tamanho do endereco da memoria de instrucoes em numero de bits
	);
	port (
		clk       : in std_logic;
		reset     : in std_logic;
		Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
		Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
	);
end entity;

architecture comportamental of memi is
	type rom_type is array (0 to 2 ** MI_ADDR_WIDTH - 1) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	signal rom : rom_type;
begin
	process (clk, reset) is
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				rom <= (
					0      => X"0004010B", -- exemplo de uma instrução qualquer de 32 bits (8 símbolos em hexadecimal)
					1      => X"0007020B", -- exemplo de uma instrução qualquer de 32 bits (8 símbolos em hexadecimal)
					2      => X"02010300", -- exemplo de uma instrução qualquer de 32 bits (8 símbolos em hexadecimal)
					others => X"00000000"  -- exemplo de uma instrução qualquer de 16 bits (8 símbolos em hexadecimal)
					);
			else
				Instrucao <= rom(to_integer(unsigned(Endereco)));
			end if;
		end if;
	end process;
end comportamental;