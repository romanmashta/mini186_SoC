----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz<
--
-- Module Name:    dvid_serdes - Behavioral
-- Description: Generating a DVI-D 720p signal using the OSERDES2 serialisers
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.NUMERIC_STD.ALL;

entity dvid_serdes is
    Port ( clk50 : in  STD_LOGIC;
           pixel_clock : inout  STD_LOGIC;
           tmds_out_p : out  STD_LOGIC_VECTOR(3 downto 0);
           tmds_out_n : out  STD_LOGIC_VECTOR(3 downto 0);
           btns : in  STD_LOGIC_VECTOR(3 downto 0);
           r : in  STD_LOGIC_VECTOR(7 downto 0);
           g : in  STD_LOGIC_VECTOR(7 downto 0);
           b : in  STD_LOGIC_VECTOR(7 downto 0);
           h_count : inout unsigned(11 downto 0) := (others => '0');
           v_count : inout unsigned(11 downto 0) := (others => '0');
			  hsync_t : in  STD_LOGIC;
			  vsync_t : in  STD_LOGIC;
			  blank_t : in  STD_LOGIC
           );

end dvid_serdes;

architecture Behavioral of dvid_serdes is

	--signal pixel_clock_t     : std_logic;
	signal data_load_clock_t : std_logic;
	signal ioclock_t         : std_logic;
   signal serdes_strobe_t   : std_logic;

	signal red_mux   : std_logic_vector(7 downto 0);

	signal red_t   : std_logic_vector(7 downto 0);
	signal green_t : std_logic_vector(7 downto 0);
	signal blue_t  : std_logic_vector(7 downto 0);
	--signal blank_t : std_logic;
	--signal hsync_t : std_logic;
	--signal vsync_t : std_logic;

   signal tmds_out_red_t   : std_logic;
   signal tmds_out_green_t : std_logic;
   signal tmds_out_blue_t  : std_logic;
   signal tmds_out_clock_t : std_logic;



--  COMPONENT vga_gen
--	PORT(
--		clk75 : IN std_logic;
--		red   : OUT std_logic_vector(7 downto 0);
--		green : OUT std_logic_vector(7 downto 0);
--		blue  : OUT std_logic_vector(7 downto 0);
--		blank : OUT std_logic;
--		hsync : OUT std_logic;
--		vsync : OUT std_logic;
--		h_count : INOUT unsigned(11 downto 0);
--		v_count : INOUT unsigned(11 downto 0)
--		);
--	END COMPONENT;

	COMPONENT clocking
	PORT(
		clk50m          : IN  std_logic;
		pixel_clock     : OUT std_logic;
		data_load_clock : OUT std_logic;
		ioclock         : OUT std_logic;
		serdes_strobe   : OUT std_logic
		);
	END COMPONENT;

	COMPONENT dvid_out
	PORT(
		pixel_clock     : IN std_logic;
		data_load_clock : IN std_logic;
		ioclock         : IN std_logic;
		serdes_strobe   : IN std_logic;
		red_p : IN std_logic_vector(7 downto 0);
		green_p : IN std_logic_vector(7 downto 0);
		blue_p : IN std_logic_vector(7 downto 0);
		blank : IN std_logic;
		hsync : IN std_logic;
		vsync : IN std_logic;
		red_s : OUT std_logic;
		green_s : OUT std_logic;
		blue_s : OUT std_logic;
		clock_s : OUT std_logic
		);
	END COMPONENT;

begin


Inst_clocking: clocking PORT MAP(
		clk50m          => clk50,
		pixel_clock     => pixel_clock,
		data_load_clock => data_load_clock_t,
		ioclock         => ioclock_t,
		serdes_strobe   => serdes_strobe_t
	);


--i_vga_gen: vga_gen PORT MAP(
--		clk75 => pixel_clock,
--		red   => green_t,
--		green => red_t,
--		blue  => blue_t,
--		blank => blank_t,
--		hsync => hsync_t,
--		vsync => vsync_t,
--		h_count => h_count,
--		v_count => v_count
--	);



i_dvid_out: dvid_out PORT MAP(
		pixel_clock     => pixel_clock,
		data_load_clock => data_load_clock_t,
		ioclock         => ioclock_t,
		serdes_strobe   => serdes_strobe_t,

		--red_p           => red_t,
		--green_p         => green_t,
		--blue_p          => blue_t,
		red_p           => r,
		green_p         => g,
		blue_p          => b,
		blank           => blank_t,
		hsync           => hsync_t,
		vsync           => vsync_t,

		red_s           => tmds_out_red_t,
		green_s         => tmds_out_green_t,
		blue_s          => tmds_out_blue_t,
		clock_s         => tmds_out_clock_t
	);


OBUFDS_blue  : OBUFDS port map ( O  => tmds_out_p(0), OB => tmds_out_n(0), I  => tmds_out_blue_t);
OBUFDS_red   : OBUFDS port map ( O  => tmds_out_p(1), OB => tmds_out_n(1), I  => tmds_out_green_t);
OBUFDS_green : OBUFDS port map ( O  => tmds_out_p(2), OB => tmds_out_n(2), I  => tmds_out_red_t);
OBUFDS_clock : OBUFDS port map ( O  => tmds_out_p(3), OB => tmds_out_n(3), I  => tmds_out_clock_t);

end Behavioral;
