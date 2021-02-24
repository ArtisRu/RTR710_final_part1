--input: pixel values, horizontal and vertical coord of pixels (800 x 600)
--output : ~pixel values, horizontal and vertical coord of pixels (25 x 20)

-- Dependencies (Libraries and packages)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity merge is
    port(
			i_clk					: in std_logic;
			i_horizontal		: in integer range 0 to 1023;
			i_vertical			: in integer range 0 to 1023;
			i_ADC_reading		: in std_logic_vector(11 downto 0);
			i_valid_ADC			: in std_logic;
			i_valid_VGA			: in std_logic;
			o_en					: out std_logic;
			o_byteenable		: out std_logic_vector(3 downto 0);
			o_data32				: out std_logic_vector(31 downto 0);
			o_address			: out std_logic_vector(11 downto 0);
			o_test				: out std_logic_vector(31 downto 0)
    );
end entity;

architecture behavioral of merge is
	constant horizontal_ratio  : integer := 32; 		-- 800 / 25, old_res / new_res
	constant vertical_ratio 	: integer := 30; 		-- 600 / 20 
	constant output_horizontal : integer := 25; 
	
	signal i				: integer range 0 to 8 := 0;
	signal global_en	: std_logic := '0';
	signal new_x, new_y	: integer range 0 to 25 := 0;--std_logic_vector(4 downto 0) := (others => '0');
	signal i_horizontal_s : integer range 0 to 1023;
	signal i_vertical_s : integer range 0 to 1023;
	signal o_address_integer : integer range 0 to 4095;
	
	type t_State is (step1, step2); -- for cycling byte enable
	signal State : t_State;
	
	signal o_byteenable_s : std_logic_vector(3 downto 0);
	signal color8	: std_logic_vector(7 downto 0) := (others => '0');
	signal color32	: std_logic_vector(31 downto 0) := (others => '0'); -- padd zeros and shift accordingly
begin
	process(i_clk) is
	begin

		if i_valid_ADC	= '1' and i_valid_VGA = '1' then
			global_en <= '1';
			o_en <= '1';
		else
			global_en <= '0';
			o_en <= '0';
		end if;
		
		if rising_edge(i_clk) then
		
			case State is								-- counts i_valid_VGA pulses. used for byte enable
				when step1 =>							-- i_valid_VGA is high, when in visible area
					if i_valid_VGA	= '1' then
						i <= i + 1;
						if i = 8 then
							i <= 0;
						end if;
					end if;
					State <= step2;
				when step2 =>
					if i_valid_VGA <= '0' then
						State <= step1;
					end if;
			end case;
						
			case i is
				when 0|1|2 => o_byteenable_s <= "0100"; -- RED				-- each 3 horizontal lines for one color
				when 3|4|5 => o_byteenable_s <= "0010"; -- GREEN
				when 6|7|8 => o_byteenable_s <= "0001"; -- GREEN
				when others		=> o_byteenable <= "0100";
			end case;
		o_byteenable <= o_byteenable_s;
		
		if global_en = '1' then
			i_horizontal_s <= i_horizontal;
			i_vertical_s	<= i_vertical;
			
			-- 800x600 => 25x20
		if i_horizontal_s >= 0*horizontal_ratio and i_horizontal_s < 1*horizontal_ratio then
			new_x <= 0;
		elsif i_horizontal_s >= 1*horizontal_ratio and i_horizontal_s < 2*horizontal_ratio then
			new_x <= 1;
		elsif i_horizontal_s >= 2*horizontal_ratio and i_horizontal_s < 3*horizontal_ratio then
			new_x <= 2;
		elsif i_horizontal_s >= 3*horizontal_ratio and i_horizontal_s < 4*horizontal_ratio then
			new_x <= 3;
		elsif i_horizontal_s >= 4*horizontal_ratio and i_horizontal_s < 5*horizontal_ratio then
			new_x <= 4;
		elsif i_horizontal_s >= 5*horizontal_ratio and i_horizontal_s < 6*horizontal_ratio then
			new_x <= 5;
		elsif i_horizontal_s >= 6*horizontal_ratio and i_horizontal_s < 7*horizontal_ratio then
			new_x <= 6;
		elsif i_horizontal_s >= 7*horizontal_ratio and i_horizontal_s < 8*horizontal_ratio then
			new_x <= 7;
		elsif i_horizontal_s >= 8*horizontal_ratio and i_horizontal_s < 9*horizontal_ratio then
			new_x <= 8;
		elsif i_horizontal_s >= 9*horizontal_ratio and i_horizontal_s < 10*horizontal_ratio then
			new_x <= 9;
		elsif i_horizontal_s >= 10*horizontal_ratio and i_horizontal_s < 11*horizontal_ratio then
			new_x <= 10;
		elsif i_horizontal_s >= 11*horizontal_ratio and i_horizontal_s < 12*horizontal_ratio then
			new_x <= 11;
		elsif i_horizontal_s >= 12*horizontal_ratio and i_horizontal_s < 13*horizontal_ratio then
			new_x <= 12;
		elsif i_horizontal_s >= 13*horizontal_ratio and i_horizontal_s < 14*horizontal_ratio then
			new_x <= 13;
		elsif i_horizontal_s >= 14*horizontal_ratio and i_horizontal_s < 15*horizontal_ratio then
			new_x <= 14;
		elsif i_horizontal_s >= 15*horizontal_ratio and i_horizontal_s < 16*horizontal_ratio then
			new_x <= 15;
		elsif i_horizontal_s >= 16*horizontal_ratio and i_horizontal_s < 17*horizontal_ratio then
			new_x <= 16;
		elsif i_horizontal_s >= 17*horizontal_ratio and i_horizontal_s < 18*horizontal_ratio then
			new_x <= 17;
		elsif i_horizontal_s >= 18*horizontal_ratio and i_horizontal_s < 19*horizontal_ratio then
			new_x <= 18;
		elsif i_horizontal_s >= 19*horizontal_ratio and i_horizontal_s < 20*horizontal_ratio then
			new_x <= 19;
		elsif i_horizontal_s >= 20*horizontal_ratio and i_horizontal_s < 21*horizontal_ratio then
			new_x <= 20;
		elsif i_horizontal_s >= 21*horizontal_ratio and i_horizontal_s < 22*horizontal_ratio then
			new_x <= 21;
		elsif i_horizontal_s >= 22*horizontal_ratio and i_horizontal_s < 23*horizontal_ratio then
			new_x <= 22;
		elsif i_horizontal_s >= 23*horizontal_ratio and i_horizontal_s < 24*horizontal_ratio then
			new_x <= 23;
		elsif i_horizontal_s >= 24*horizontal_ratio and i_horizontal_s < 25*horizontal_ratio then
			new_x <= 24;
		else
			new_x <= 0;
		end if;
		
		if i_vertical_s >= 0*vertical_ratio and i_vertical_s < 1*vertical_ratio then
			new_y <= 0;
		elsif i_vertical_s >= 1*vertical_ratio and i_vertical_s < 2*vertical_ratio then
			new_y <= 1;
		elsif i_vertical_s >= 2*vertical_ratio and i_vertical_s < 3*vertical_ratio then
			new_y <= 2;
		elsif i_vertical_s >= 3*vertical_ratio and i_vertical_s < 4*vertical_ratio then
			new_y <= 3;
		elsif i_vertical_s >= 4*vertical_ratio and i_vertical_s < 5*vertical_ratio then
			new_y <= 4;
		elsif i_vertical_s >= 5*vertical_ratio and i_vertical_s < 6*vertical_ratio then
			new_y <= 5;
		elsif i_vertical_s >= 6*vertical_ratio and i_vertical_s < 7*vertical_ratio then
			new_y <= 6;
		elsif i_vertical_s >= 7*vertical_ratio and i_vertical_s < 8*vertical_ratio then
			new_y <= 7;
		elsif i_vertical_s >= 8*vertical_ratio and i_vertical_s < 9*vertical_ratio then
			new_y <= 8;
		elsif i_vertical_s >= 9*vertical_ratio and i_vertical_s < 10*vertical_ratio then
			new_y <= 9;
		elsif i_vertical_s >= 10*vertical_ratio and i_vertical_s < 11*vertical_ratio then
			new_y <= 10;
		elsif i_vertical_s >= 11*vertical_ratio and i_vertical_s < 12*vertical_ratio then
			new_y <= 11;
		elsif i_vertical_s >= 12*vertical_ratio and i_vertical_s < 13*vertical_ratio then
			new_y <= 12;
		elsif i_vertical_s >= 13*vertical_ratio and i_vertical_s < 14*vertical_ratio then
			new_y <= 13;
		elsif i_vertical_s >= 14*vertical_ratio and i_vertical_s < 15*vertical_ratio then
			new_y <= 14;
		elsif i_vertical_s >= 15*vertical_ratio and i_vertical_s < 16*vertical_ratio then
			new_y <= 15;
		elsif i_vertical_s >= 16*vertical_ratio and i_vertical_s < 17*vertical_ratio then
			new_y <= 16;
		elsif i_vertical_s >= 17*vertical_ratio and i_vertical_s < 18*vertical_ratio then
			new_y <= 17;
		elsif i_vertical_s >= 18*vertical_ratio and i_vertical_s < 19*vertical_ratio then
			new_y <= 18;
		elsif i_vertical_s >= 19*vertical_ratio and i_vertical_s < 20*vertical_ratio then
			new_y <= 19;
		else
			new_y <= 0;
		end if;
		
		o_address_integer <= output_horizontal * new_y + new_x;
		o_address <= std_logic_vector(to_unsigned(o_address_integer, 12)); -- address for memory
		
		color8 <= i_ADC_reading(9 downto 2); -- 11 and 10 dont care because VGA is 0.7V max, 0 and 1 dont care because wouldnt make difference on leds
		--o_test <= color8;
		
		color32 <= std_logic_vector(resize(unsigned(color8), 32)); -- padded with zeros
		--o_test <= color32;
		
		case o_byteenable_s is 
			when "0100" => -- RED
				-- shift 16 left
				o_data32 <= std_logic_vector(shift_left(unsigned(color32),16));
			when "0010" => -- GREEN
				-- shift 8 left
				o_data32 <= std_logic_vector(shift_left(unsigned(color32),8));
			when "0001" =>	-- BLUE
				-- dont shift
				o_data32 <= color32;
			when others =>
				o_data32 <= color32;
		end case;
		
		end if;
		end if;
	end process;
end architecture;


