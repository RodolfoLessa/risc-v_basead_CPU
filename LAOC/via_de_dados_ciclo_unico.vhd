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
		dp_ctrl_bus_width : natural := 16; -- tamanho do barramento de controle da via de dados (DP) em bits
		data_width        : natural := 32; -- tamanho do dado em bits
		pc_width          : natural := 12; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		fr_addr_width     : natural := 5;  -- tamanho da linha de endereços do banco de registradores em bits
		ula_ctrl_width    : natural := 3;  -- tamanho da linha de controle da ULA
		instr_width       : natural := 32  -- tamanho da instrução em bits
	);
	port (
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     : in std_logic;
		reset     : in std_logic;
		controle  : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
		instruct  : out std_logic_vector(instr_width - 1 downto 0);
		pc_out    : out std_logic_vector(pc_width - 1 downto 0);
		saida     : out std_logic_vector(data_width - 1 downto 0)
	);
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

	-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
	component pc is
		generic (
			pc_width : natural := 12
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
			MI_ADDR_WIDTH : natural := 12  -- tamanho do endereço da memoria de instruções em numero de bits
		);
		port (
			clk       : in std_logic;
			reset     : in std_logic;
			Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
			Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
		);
	end component;

	component porta_and is
		port (
			entrada_a : in std_logic;
			entrada_b : in std_logic;
			saida     : out std_logic
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

	component deslocador is
		generic (
			largura_dado : natural := 32;
			largura_qtde : natural := 5
		);
	
		port (
			ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
			ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
			ent_tipo_deslocamento : in std_logic_vector(2 downto 0);
			sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component extensor is
		generic (
			largura_dado  : natural := 16;
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

	component mux21pc is
		generic (
			largura_dado : natural := 12
		);
		port (
			dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent               : in std_logic;
			dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
		);	end component;

		component mux21reg is
			generic (
				largura_dado : natural := 5
			);
			port (
				dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
				sele_ent               : in std_logic;
				dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
			);	end component mux21reg;

	component mux41 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent                                       : in std_logic_vector(1 downto 0);
			dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
		);	end component;

	component somador is
		generic (
			largura_dado : natural := 12
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);	end component;

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
			reset			: in std_logic;
			clk         : in std_logic;
			we          : in std_logic
		);	end component;

	component concatenador is
		port (
		  input: in std_logic_vector(11 downto 0);
		  output: out std_logic_vector(31 downto 0)
		);	  end component concatenador;

	component ula is
	generic (
		largura_dado : natural := 32
	);

	port (
		entrada_a   : in std_logic_vector((largura_dado - 1) downto 0);
		entrada_b   : in std_logic_vector((largura_dado - 1) downto 0);
		seletor     : in std_logic_vector(2 downto 0);
		saida       : out std_logic_vector((largura_dado - 1) downto 0);
		saida_zero  : out std_logic
	);	end component ula;

	-- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
	-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
	-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
	-- componentes onde serão usados.
	-- Veja os exemplos abaixo:
	
	-- sinais relacionados ao PC
	signal aux_pc_next_address  : std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_aux	  	  	: std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_out 	  		: std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_in	  		: std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_beq_address	: std_logic_vector(pc_width - 1 downto 0);
	signal aux_jump_signal  	: std_logic_vector(pc_width - 1 downto 0);
	signal aux_branch_result  	: std_logic;

	-- sinais relacionados ao banco de registradores
	signal instrucao	   	  : std_logic_vector(INSTR_WIDTH - 1 downto 0);
	signal aux_memi_out   	  : std_logic_vector(INSTR_WIDTH - 1 downto 0);
	signal aux_endereco_rs1   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_endereco_rs2   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_endereco_rd    : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_result     	  : std_logic_vector(data_width - 1 downto 0);
	signal aux_read_data1 	  : std_logic_vector(data_width - 1 downto 0);
	signal aux_read_data2 	  : std_logic_vector(data_width - 1 downto 0);

	-- entradas dos registradores destinos no mux destiny 
	signal aux_rd_14to10 	  : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_rd_19to15 	  : std_logic_vector(fr_addr_width - 1 downto 0);
	
	-- sinais relacionados aos blocos de operação
	signal aux_result_select_entry   : std_logic_vector(data_width - 1 downto 0);
	signal aux_shifter_result  		 : std_logic_vector(data_width - 1 downto 0); 	
	signal aux_alu_result            : std_logic_vector(data_width - 1 downto 0);
	signal aux_alu_answer_zero       : std_logic;
	signal aux_jal_result		     : std_logic_vector(data_width - 1 downto 0);

	-- sinais relacionados ao Data Memory
	signal aux_read_data_memory      : std_logic_vector(data_width - 1 downto 0);

	-- sinais relacionados a controladora
	signal aux_we  			: std_logic;
	signal aux_reg_write		: std_logic;
	signal aux_reg_dest	  	: std_logic;
	signal aux_branch   		: std_logic;
	signal aux_jump  			: std_logic;
	signal aux_mem_write    : std_logic;
	signal aux_mem_read	   : std_logic;	
	signal aux_select_in    : std_logic;
	signal aux_resp  			: std_logic_vector(1 downto 0);
	signal aux_srl_cnt  		: std_logic_vector(ula_ctrl_width - 1 downto 0);
	signal aux_alu_ctrl		: std_logic_vector(ula_ctrl_width - 1 downto 0);

	-- sinais relacionados ao imediato
	signal aux_imm32_result		: std_logic_vector(data_width - 1 downto 0);
	signal aux_imm32   	  		: std_logic_vector(15 downto 0);

begin

	-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
	-- os sinais que você acabou de definir.
	-- Veja os exemplos abaixo:
	
	-- sinais relacionados ao MEMI
	instrucao			<= aux_memi_out;
	-- sinais relacionados ao PC
	aux_jump_signal	  	<= instrucao(31 downto 20);
	aux_pc_beq_address 	<= instrucao(31 downto 20);
	pc_out         	 	<= aux_pc_out;

	-- sinais relacionados ao banco de registradores
	aux_endereco_rs1   	<= instrucao(9 downto 5);
	aux_endereco_rs2   	<= instrucao(14 downto 10);
	saida     		   	<= aux_result;

	-- entradas dos registradores destinos no mux destiny 
	aux_rd_14to10 	   	<= instrucao(14 downto 10);
	aux_rd_19to15 	   	<= instrucao(19 downto 15);
	
	-- sinais relacionados a controladora
	aux_we				<= controle(15);
	aux_reg_write		<= controle(14);
	aux_reg_dest		<= controle(13);
	aux_branch			<= controle(12);
	aux_jump			<= controle(11);
	aux_mem_write		<= controle(10);
	aux_mem_read		<= controle(9);
	aux_select_in		<= controle(8);
	aux_resp			<= controle(7 downto 6);
	aux_srl_cnt			<= controle(5 downto 3);
	aux_alu_ctrl			<= controle(2 downto 0);
	-- sinais relacionados ao imediato
	aux_imm32      	<= instrucao(31 downto 16);

	-- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
	-- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	-- instâncias relacionadas ao pc
	instancia_mux_branch: component mux21pc
		port map(
			dado_ent_0 	=> aux_pc_next_address, 
			dado_ent_1 	=> aux_pc_beq_address,
			sele_ent	=> aux_branch_result,            
			dado_sai    => aux_pc_aux
		);

	instancia_mux_jump: component mux21pc
		port map (
			dado_ent_0 	=> aux_pc_aux, 
			dado_ent_1 	=> aux_jump_signal,
			sele_ent	=> aux_jump,            
			dado_sai    => aux_pc_in
		);

	instancia_pc : component pc
		port map(
			entrada 	=> aux_pc_in,
			saida 		=> aux_pc_out,
			clk 		=> clock,
			we 			=> aux_we,
			reset 		=> reset
			);

	instancia_somador : component somador
		port map(
			entrada_a => aux_pc_out,
			entrada_b => "000000000001",
			saida => aux_pc_next_address
		);
	
	instancia_mem_instruction: component memi
		port map (
			clk       	=> clock,
			reset     	=> reset,
			Endereco  	=> aux_pc_out,
			Instrucao 	=> aux_memi_out
		);

	instancia_contatenador: component concatenador
		port map (
			input	=> aux_pc_next_address,
			output	=> aux_jal_result
		);
	
	-- instâncias relacionadas ao banco de registradores
	instancia_banco_registradores : component banco_registradores
		port map(
			ent_rs_ende => aux_endereco_rs1,
			ent_rt_ende => aux_endereco_rs2,
			ent_rd_ende => aux_endereco_rd,
			ent_rd_dado => aux_result,
			sai_rs_dado => aux_read_data1,
			sai_rt_dado => aux_read_data2,
			clk 			=> clock,
			reset 		=> reset,
			we 			=> aux_reg_write
		);

	mux_register_destiny: component mux21reg
		port map (
			dado_ent_0	=> aux_rd_14to10,
			dado_ent_1	=> aux_rd_19to15,
			sele_ent	=> aux_reg_dest,                                      
			dado_sai    => aux_endereco_rd                            
		);
	
	-- instâncias relacionadas aos imediatos
	instancia_extensor_16bits: component extensor
		port map (
			entrada_Rs 	=> aux_imm32,
			saida      	=> aux_imm32_result			
		);
	
	-- instancias relacionadas a ULA
	instancia_mux_ula: component mux21
		generic map(
			largura_dado => 32
		)
		port map(
			dado_ent_0 	=> aux_read_data2, 
			dado_ent_1 	=> aux_imm32_result,
			sele_ent	=> aux_select_in,            
			dado_sai    => aux_result_select_entry
		);
	
	instancia_ula : component ula
  		port map(
			entrada_a => aux_read_data1,
			entrada_b => aux_result_select_entry,
			seletor => aux_alu_ctrl,
			saida => aux_alu_result,
			saida_zero => aux_alu_answer_zero
 		);
	
	instancia_AND: component porta_and
		port map (
			entrada_a => aux_branch,
			entrada_b => aux_alu_answer_zero,
			saida     => aux_branch_result
		);

	instancia_shift: component deslocador
		port map (
			ent_rs_dado				=> aux_read_data1,
			ent_rt_ende				=> aux_result_select_entry(4 downto 0),
			ent_tipo_deslocamento	=> aux_srl_cnt,
			sai_rd_dado				=> aux_shifter_result
		  );
	
	
	-- instâncias relacionadas ao Data Memory
	instancia_data_memory: component memd
		port map (
			clk 			=> clock,               
			mem_write		=> aux_mem_write, 
			mem_read		=> aux_mem_read,
			write_data_mem  => aux_read_data2,   
			adress_mem      => aux_alu_result,
			read_data_mem   => aux_read_data_memory
		);
	
	instancia_mux_result: component mux41
		port map (
			dado_ent_0	=> aux_alu_result,
			dado_ent_1	=> aux_read_data_memory,
			dado_ent_2	=> aux_shifter_result, 
			dado_ent_3	=> aux_jal_result,
			sele_ent	=> aux_resp,                                      
			dado_sai    => aux_result       
		);

	instruct <= instrucao;

end architecture comportamento;