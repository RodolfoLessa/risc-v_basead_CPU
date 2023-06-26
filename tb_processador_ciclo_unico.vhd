-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Testbench para o processador_ciclo_unico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Este arquivo irá gerar um sinal de clock e reset de modo a possibilitar a simulação do DUT processador_ciclo_unico

entity tb_processador_ciclo_unico is
end tb_processador_ciclo_unico;

architecture estimulos of tb_processador_ciclo_unico is
	-- Declarar a unidade sob teste
	component processador_ciclo_unico
		generic (
			DATA_WIDTH        : natural := 32; -- tamanho do barramento de dados em bits
			PROC_INSTR_WIDTH  : natural := 32; -- tamanho da instrução do processador em bits
			PROC_ADDR_WIDTH   : natural := 12; -- tamanho do endereço da memória de programa do processador em bits
			DP_CTRL_BUS_WIDTH : natural := 16 -- tamanho do barramento de controle em bits
		);
		port (
			--		Chaves_entrada 			: in std_logic_vector(DATA_WIDTH-1 downto 0);
			--		Chave_enter				: in std_logic;
			Leds_vermelhos_saida : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			Chave_reset          : in std_logic;
			Clock                : in std_logic
		);
	end component;

	signal clk : std_logic;
	signal rst : std_logic;

	-- Definição das configurações de clock				
	constant PERIODO    : time := 20 ns;
	constant DUTY_CYCLE : real := 0.5;
	constant OFFSET     : time := 0 ns;
begin
	-- instancia o componente 
	instancia : processador_ciclo_unico port map(Clock => clk, Chave_reset => rst);
	-- processo para gerar o sinal de clock 		
	gera_clock : process
	begin
		wait for OFFSET;
		CLOCK_LOOP : loop
			clk <= '0';
			wait for (PERIODO - (PERIODO * DUTY_CYCLE));
			clk <= '1';
			wait for (PERIODO * DUTY_CYCLE);
		end loop CLOCK_LOOP;
	end process gera_clock;
	-- processo para gerar o estimulo de reset		
	gera_reset : process
	begin
		rst <= '1';
		for i in 1 to 2 loop
			wait until rising_edge(clk);
		end loop;
		rst <= '0';
		wait;
	end process gera_reset;
end;