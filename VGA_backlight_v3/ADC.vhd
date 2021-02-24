
-- module for controlling DE1-SOC ADC LTC2308

-- Dependencies (Libraries and packages)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_spi_master is
    port(
			ADC_clk		: in std_logic;			-- 40 MHz clock is needed
			ADC_DOUT		: in std_logic;			-- sampled data
			ADC_DIN		: out std_logic;			-- 6 configuration bits for ADC operation mode
			ADC_SCLK		: out std_logic;			-- ADC clk
			ADC_CONVST	: out std_logic := '0';	-- convertion start (chip select)
			--config_in	: in std_logic_vector(17 downto 0);
			valid			: out std_logic := '0';
			data_out		: out std_logic_vector(11 downto 0) := (others => '0')
    );
end entity;


--define inside of the module
architecture behavioral of ADC_spi_master is
	 signal config_bits		: std_logic_vector(17 downto 0) := "100010000000000000";			--channel 0
	 --signal config_bits		: std_logic_vector(17 downto 0) := "110010000000000000";			--channel 1
	 --signal config_bits		: std_logic_vector(17 downto 0) := "100110000000000000";			--channel 2
	 signal i 					: integer range 0 to 81;	-- count to 80 clock cycles (2us) for ADC_CONVST
	 signal sampled_data		: std_logic_vector(11 downto 0) := (others => '0');
	 signal sampled_data_integer	: integer range 0 to 4100;
	 signal output_ready		: std_logic := '0';
	 signal config_counter	: integer range 0 to 2 := 0; -- for changing configuration bits (ADC input channel)
	 type t_State is (init_state, tx_state);
	 signal State : t_State;
	 
begin
	ADC_SCLK <= ADC_clk;
	--sampled_data_integer <= to_integer(unsigned(sampled_data));
	data_out <= sampled_data;
	process(ADC_clk) is
	begin
		if rising_edge(ADC_clk) then
		i <= i + 1;
		if i = 79 then
		i <= 0;
		end if;
		case State is
			when init_state =>
				--change config bits here
				case config_counter is
					when 0 => config_bits <= "100010000000000000";		--ch1
					when 1 => config_bits <= "110010000000000000";		--ch2
					when 2 => config_bits <= "100110000000000000";		--ch3
					when others => config_bits <= "100010000000000000";	-- ch1
				end case;
				ADC_CONVST <= '1';
				ADC_DIN <= '0';
				valid <= '0';
				if i = 60 then 
					config_counter <= config_counter + 1;
					if config_counter = 2 then
						config_counter <= 0;
					end if;
					State <= tx_state;
				end if;
				
			when tx_state =>
				ADC_CONVST <= '0';
				case i is
					when 62 => ADC_DIN <= config_bits(17); 
					when 63 => ADC_DIN <= config_bits(16);
					when 64 => ADC_DIN <= config_bits(15);
					when 65 => ADC_DIN <= config_bits(14);
					when 66 => ADC_DIN <= config_bits(13);
					when 67 => ADC_DIN <= config_bits(12);
					when 68 => ADC_DIN <= config_bits(11);
					when 69 => ADC_DIN <= config_bits(10);
					when 70 => ADC_DIN <= config_bits(9);
					when 71 => ADC_DIN <= config_bits(8);
					when 72 => ADC_DIN <= config_bits(7);
					when 73 => ADC_DIN <= config_bits(6);
					when 74 => ADC_DIN <= config_bits(5);
					when 75 => ADC_DIN <= config_bits(4); valid <= '1';
					when 76 => ADC_DIN <= config_bits(3); valid <= '1';
					when 77 => ADC_DIN <= config_bits(2); valid <= '1';
					when 78 => ADC_DIN <= config_bits(1); valid <= '1';
					when 79 => ADC_DIN <= config_bits(0); valid <= '1';
					when others => ADC_DIN <= '0';
				end case;
				if i = 79 then
					State <= init_state;
				end if;
		end case;
		end if;
	end process;
	
	process(ADC_clk) is
	begin
		if falling_edge(ADC_clk) then
			case i is
			when 63 => sampled_data(11) <= ADC_DOUT;
			when 64 => sampled_data(10) <= ADC_DOUT;
			when 65 => sampled_data(9) <= ADC_DOUT;  
			when 66 => sampled_data(8) <= ADC_DOUT;  	
			when 67 => sampled_data(7) <= ADC_DOUT; 
			when 68 => sampled_data(6) <= ADC_DOUT; 
			when 69 => sampled_data(5) <= ADC_DOUT;  
			when 70 => sampled_data(4) <= ADC_DOUT;  
			when 71 => sampled_data(3) <= ADC_DOUT;  
			when 72 => sampled_data(2) <= ADC_DOUT;  
			when 73 => sampled_data(1) <= ADC_DOUT;  
			when 74 => sampled_data(0) <= ADC_DOUT;  
			when others => output_ready <= '0';
			end case;
		end if;
	end process;
end architecture;