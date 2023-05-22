-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	generic (
		-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
		dp_ctrl_bus_width : natural := 14; -- tamanho do barramento de controle da via de dados (DP) em bits
		data_width        : natural := 32; -- tamanho do dado em bits
		pc_width          : natural := 32; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		fr_addr_width     : natural := 5;  -- tamanho da linha de endereços do banco de registradores em bits
		ula_ctrl_width    : natural := 3;  -- tamanho da linha de controle da ULA
		instr_width       : natural := 32  -- tamanho da instrução em bits
	);
	port (
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     : in std_logic;
		reset     : in std_logic;
		controle  : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
		instrucao : in std_logic_vector(instr_width - 1 downto 0);
		pc_out    : out std_logic_vector(pc_width - 1 downto 0);
		saida     : out std_logic_vector(data_width - 1 downto 0)
	);
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

	-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
	component pc is
		generic (
			pc_width : natural := 32
		);
		port (
			entrada : in std_logic_vector(pc_width - 1 downto 0);
			saida   : out std_logic_vector(pc_width - 1 downto 0);
			clk     : in std_logic;
			we      : in std_logic;
			reset   : in std_logic
		);
	end component;

	component memi is
		generic (
			INSTR_WIDTH   : natural := 32; -- tamanho da instrução em numero de bits
			MI_ADDR_WIDTH : natural := 32  -- tamanho do endereço da memoria de instruções em numero de bits
		);
		port (
			clk       : in std_logic;
			reset     : in std_logic;
			Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
			Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
		);
	end component;

	component memd is
		generic (
			number_of_words : natural := 512; -- número de words que a sua memória é capaz de armazenar
			MD_DATA_WIDTH   : natural := 32; -- tamanho da palavra em bits
			MD_ADDR_WIDTH   : natural := 32 -- tamanho do endereco da memoria de dados em bits
		);
		port (
			clk                 : in std_logic;
			mem_write, mem_read : in std_logic; --sinais do controlador
			write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
			adress_mem          : in std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);
			read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0)
		);
	end component;

	component deslocador2bits is
		generic (
			largura_dado : natural := 32;
			largura_qtde : natural := 2
		);
	
		port (
			ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
			ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
			ent_tipo_deslocamento : in std_logic_vector(1 downto 0);
			sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component deslocador10bits is
		generic (
			largura_dado : natural := 32;
			largura_qtde : natural := 10
		);
	
		port (
			ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
			ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
			ent_tipo_deslocamento : in std_logic_vector(1 downto 0);
			sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;	

	component extensor is
		generic (
			largura_dado  : natural := 32;
			largura_saida : natural := 32
		);
	
		port (
			entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0);
			saida      : out std_logic_vector((largura_saida - 1) downto 0)
		);
	end component;

	component mux21 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent               : in std_logic;
			dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
		);	end component;

	component mux41x32 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent                                       : in std_logic_vector(1 downto 0);
			dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component mux41x5 is
		generic (
			largura_dado : natural := 5
		);
		port (
			dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent                                       : in std_logic_vector(1 downto 0);
			dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component somador is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component banco_registradores is
		generic (
			largura_dado : natural := 32;
			largura_ende : natural := 5
		);
		port (
			ent_rs_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rt_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_dado : in std_logic_vector((largura_dado - 1) downto 0);
			sai_rs_dado : out std_logic_vector((largura_dado - 1) downto 0);
			sai_rt_dado : out std_logic_vector((largura_dado - 1) downto 0);
			clk         : in std_logic;
			we          : in std_logic
		);
	end component;

	component ula is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			seletor   : in std_logic_vector(2 downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	-- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
	-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
	-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
	-- componentes onde serão usados.
	-- Veja os exemplos abaixo:
	
	-- sinais relacionados ao PC
	signal pc_branch  	  : std_logic_vector(pc_width - 1 downto 0);
	signal pc_aux	  	  : std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_out 	  : std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_in	  : std_logic_vector(pc_width - 1 downto 0);
	signal beq_signal	  : std_logic_vector(pc_width - 1 downto 0);
	signal jump_signal	  : std_logic_vector(pc_width - 1 downto 0);
	signal jump_desl	  : std_logic_vector(24 downto 0);	

	-- sinais relacionados ao banco de registradores
	signal aux_read_rs1   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_read_rs2   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_write_rd   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal result     	  : std_logic_vector(data_width - 1 downto 0);
	signal read_data1 	  : std_logic_vector(data_width - 1 downto 0);
	signal read_data2 	  : std_logic_vector(data_width - 1 downto 0);

	-- entradas dos registradores destinos no mux destiny 
	signal rd_9to5     	  : std_logic_vector(data_width - 1 downto 0);
	signal rd_14to10 	  : std_logic_vector(data_width - 1 downto 0);
	signal rd_19to15 	  : std_logic_vector(data_width - 1 downto 0);
	
	-- sinais relacionados a ALU
	signal mux_to_alu 	  : std_logic_vector(data_width - 1 downto 0);
	signal alu_answer 	  : std_logic_vector(data_width - 1 downto 0);

	-- sinais relacionados ao Data Memory
	signal read_data 	  : std_logic_vector(data_width - 1 downto 0);

	-- sinais relacionados a controladora
	signal aux_reg_write  : std_logic;
	signal aux_reg_dest	  : std_logic_vector(1 downto 0);
	signal aux_aluscr     : std_logic;
	signal aux_mem_read   : std_logic;
	signal aux_imm	  	  : std_logic_vector(1 downto 0);
	signal aux_desl    	  : std_logic;
	signal aux_branch	  : std_logic;
	signal aux_mem_write  : std_logic;
	signal aux_jump   	  : std_logic;
	signal aux_ula_ctrl	  : std_logic_vector(ula_ctrl_width - 1 downto 0);

	-- sinais relacionados ao imediato
	signal aux_imm16   	  : std_logic_vector(15 downto 0);
	signal aux_imm12   	  : std_logic_vector(11 downto 0);
	signal aux_imm8   	  : std_logic_vector(7 downto 0);
	signal aux_imm22   	  : std_logic_vector(21 downto 0);
	signal imm_result  	  : std_logic_vector(data_width downto 0);
	signal imm_extend	  : std_logic_vector(data_width downto 0);

	-- sinais relacionados ao shifter
	signal shifter10   	  : std_logic_vector(data_width downto 0);
	signal shifter2  	  : std_logic_vector(data_width downto 0);
	signal result_shitfer : std_logic_vector(data_width downto 0);

begin

	-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
	-- os sinais que você acabou de definir.
	-- Veja os exemplos abaixo:

	-- sinais relacionados ao PC
	jump_desl	    <= instrucao(25 downto 0);
	pc_out          <= aux_pc_out;

	-- sinais relacionados ao banco de registradores
	aux_read_rs1   	<= instrucao(9 downto 5);
	aux_read_rs2   	<= instrucao(14 downto 10);
	saida     	   	<= result;

	-- entradas dos registradores destinos no mux destiny 
	rd_9to5        	<= instrucao(9 downto 5);
	rd_14to10 	   	<= instrucao(14 downto 10);
	rd_19to15 	   	<= instrucao(19 downto 15);
	
	-- sinais relacionados a controladora
	aux_reg_write  	<= controle(13);
	aux_reg_dest   	<= controle(12 downto 11);
	aux_aluscr     	<= controle(10);
	aux_mem_read   	<= controle(9);
	aux_imm	  	   	<= controle(8 downto 7);
	aux_desl       	<= controle(6);
	aux_branch	   	<= controle(5);
	aux_mem_write  	<= controle(4);
	aux_jump   	   	<= controle(3);
	aux_ula_ctrl   	<= controle(2 to 0);

	-- sinais relacionados ao imediato
	aux_imm16      	<= instrucao(31 downto 15);
	aux_imm12      	<= instrucao(31 downto 20);
	aux_imm8   	   	<= instrucao(31 downto 24);
	aux_imm22      	<= instrucao(31 downto 10);

	-- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
	-- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	instancia_ula1 : component ula
  		port map(
			entrada_a => read_data1,
			entrada_b => read_data2,
			seletor => aux_ula_ctrl,
			saida => result
 		);

	instancia_banco_registradores : component banco_registradores
		port map(
			ent_rs_ende => aux_read_rs1,
			ent_rt_ende => aux_read_rs2,
			ent_rd_ende => aux_write_rd,
			ent_rd_dado => result,
			sai_rs_dado => read_data1,
			sai_rt_dado => read_data2,
			clk => clock,
			we => aux_reg_write
		);

    instancia_pc : component pc
    	port map(
			entrada => aux_pc_in,
			saida => aux_pc_out,
			clk => clock,
			we => aux_we,
			reset => reset
      	);

    instancia_somador : component somador
        port map(
			entrada_a => aux_pc_out,
			entrada_b => "0001",
			saida => aux_pc_in
        );
end architecture comportamento;