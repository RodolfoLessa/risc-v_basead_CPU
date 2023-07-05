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
				
				-- Operacoes Logicas e Aritmeticas
					0      => "00000000000000000000000000000000", -- Instrução ADD de 32 bits 		= 0		
					1      => "00000000000011110000000000000001", -- Instrução ADDI de 32 bits		= 15 					
					2      => "00000000000000000000000000000010", -- Instrução SUB de 32 bits		= 0			
					3      => "00000000000011110000000000000001", -- Instrução ADDI de 32 bits		= 15			
					4      => "00000000000000000000000000000011", -- Instrução XOR de 32 bits		= 0			
					5      => "00000000000000110000000000000100", -- Instrução XORI de 32 bits		= 3			
					6      => "00000000000000000000000000000101", -- Instrução OR de 32 bits		= 3
					7      => "00000000000011110000000000000110", -- Instrução ORI de 32 bits		= 15
					8      => "00000000000000000000000000000111", -- Instrução AND de 32 bits		= 15
					9      => "00000000000000110000000000001000", -- Instrução ANDI de 32 bits		= 3
					
				-- Operacoes de Load e Store
					10     => "00000000000000000000000000001101", -- Instrução SW de 32 bits		= 3
					11     => "00000000000000000000000000001100", -- Instrução LW de 32 bits		= 3
					
				-- Operacoes de Shift
					12     => "00000000000000000000000000010011", -- Instrução SRL de 32 bits		= 24
					13     => "00000000000000000000000000010010", -- Instrução SLL de 32 bits		= 0
					14     => "00000000000000110000000000000001", -- Instrução ADDI de 32 bits		= 3
					15     => "00000000000000000000000000010100", -- Instrução ROR de 32 bits		= 1610612736
					16     => "00000000000000000000000000000010", -- Instrução SUB de 32 bits		= 0			
					17     => "00000000000000110000000000000001", -- Instrução ADDI de 32 bits		= 3
				
				-- Operacoes de Desvio
					18     => "00000001001100000000000000001001", -- Instrução BEQ de 32 bits		= 10
					19	   => "00000000000001110000000000000001", -- Instrução ADDI de 32 bits		= 17
			
				-- Operacoes de Salto
					20     => "00000001010100000000000000001110", -- Instrução JAL de 32 bits		= 22
					21     => "00000001011000000000000000001111", -- Instrução JUMP de 32 bits		
					22     => "00000000000000000000000000000000", -- Instrução ADD de 32 bits		= 4
					others => X"00000000"  
					);
			else
				Instrucao <= rom(to_integer(unsigned(Endereco)));
			end if;
		end if;
	end process;
end comportamental;