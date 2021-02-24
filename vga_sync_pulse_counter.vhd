-- module for counting VGA signal pixels and reseting on sync pulses 
--	outputs current coordinate

-- Dependencies (Libraries and packages)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync_pulse_counter is 
	port (
		v_sync	: in std_logic;
		h_sync	: in std_logic;
		VGA_clk	: in std_logic;
		send		: in std_logic;
		v	: out integer range 0 to 599 := 0;		-- VGA resolution
		h	: out integer range 0 to 799 := 0;
		valid : out std_logic := '0'
	);
end entity;

architecture behavioral of vga_sync_pulse_counter is
	signal h_count	: integer range 0 to 799 := 0;		-- VGA resolution
	signal v_count	: integer range 0 to 599 := 0;
	signal h_porch_counter : integer range 0 to 255 := 0;
	signal v_porch_counter : integer range 0 to 24289 := 0; -- should fit 23 full video frames 
	signal h_porch_counter_en : std_logic := '0';
	signal v_porch_counter_en : std_logic := '0';
	signal visible_region_active	: std_logic := '0';
	
	type t_State is (H_start, H_porch, Frame_end);
	signal State : t_State;
	
begin
	process(VGA_clk, v_count, h_count, v_sync, h_sync) is
	begin
			-- output current coordinates and valid signal when
			-- we're inside visible region
		v <= v_count;
		h <= h_count;
		valid <= visible_region_active;
	
		if v_sync = '0' then	
			State <= Frame_end;
			visible_region_active <= '0';
		elsif rising_edge(VGA_clk) then
		
				--counters
		if rising_edge(VGA_clk) and h_porch_counter_en = '1' then
			h_porch_counter <= h_porch_counter + 1;
		end if;
		
		if rising_edge(VGA_clk) and v_porch_counter_en = '1' then
			v_porch_counter <= v_porch_counter + 1;
		end if;
		
			-- FSM
			case State is
				when H_start =>
					h_count <= h_count + 1;
					h_porch_counter_en <= '0';
					h_porch_counter <= 0;
					v_porch_counter_en <= '0';
					v_porch_counter <= 0;
					visible_region_active <= '1';
					if h_sync = '0' then
						v_count <= v_count + 1;
						State <= H_porch;
					end if;
					
				when H_porch =>
					h_porch_counter_en <= '1';
					h_count <= 0;
					visible_region_active <= '0';
					if h_porch_counter = 88+128 then		-- back porch + horizontal sync pulse 
						State <= H_start;
					end if;
					
				when Frame_end =>
					v_porch_counter_en <= '1';
					v_count <= 0;
					h_count <= 0;
					visible_region_active <= '0';
					if v_porch_counter = 23*1056 then 	-- 23 full video frames 
						State <= H_start;
					end if;	
			end case;
		end if;

	end process;
end architecture;