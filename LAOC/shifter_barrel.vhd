-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Extensor de sinais. Replica o bit de sinal da entrada Rs (largura_saida-largura_dado) vezes.

library ieee;
use ieee.std_logic_1164.all;

entity shifter_barrel is
  port (
    data_in: in std_logic_vector(31 downto 0);
    shift_amount: in integer range 0 to 31;
    shift_type: in std_logic_vector(2 downto 0); -- "000" para SRL, "001" para SLL, "010" para ROR, "011" para ROL, "100" para SRA
    data_out: out std_logic_vector(31 downto 0)
  );
end entity shifter_barrel;

architecture Behavioral of shifter_barrel is
begin
  process (data_in, shift_amount, shift_type)
    variable shifted_data: std_logic_vector(31 downto 0);
    variable shift_result: std_logic_vector(31 downto 0);
  begin
    shifted_data := data_in;
    
    case shift_type is
      when "000" =>
        -- SRL (Shift Right Logical)
        shift_result := shifted_data(shifted_data'high downto shift_amount);
        shift_result(shift_result'high downto shift_result'high - shift_amount + 1) := (others => '0');
      when "001" =>
        -- SLL (Shift Left Logical)
        shift_result := shifted_data(shift_amount to shifted_data'low) & (others => '0');
      when "010" =>
        -- ROR (Rotate Right)
        shift_result := shifted_data(shifted_data'high - shift_amount to shifted_data'low) & shifted_data(shifted_data'high downto shifted_data'high - shift_amount + 1);
      when "011" =>
        -- ROL (Rotate Left)
        shift_result := shifted_data(shifted_data'high - shift_amount + 1 to shifted_data'low) & shifted_data(shifted_data'high downto shifted_data'high - shift_amount + 1);
      when "100" =>
        -- SRA (Shift Right Arithmetic)
        if shifted_data(shifted_data'high) = '1' then
          shift_result := shifted_data(shifted_data'high downto shift_amount);
          shift_result(shift_result'high downto shift_result'high - shift_amount + 1) := (others => '1');
        else
          shift_result := shifted_data(shifted_data'high downto shift_amount);
          shift_result(shift_result'high downto shift_result'high - shift_amount + 1) := (others => '0');
        end if;
      when others =>
        -- Invalid shift type, do not perform shift
        shift_result := shifted_data;
    end case;
    
    data_out <= shift_result;
  end process;
end architecture Behavioral;
