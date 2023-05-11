library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (clk: in std_logic;
    hsync, vsync: out std_logic;
    red, green, blue: out std_logic_vector(3 downto 0);
    moveU, moveD, moveL, moveR: in std_logic;
    shoot: in std_logic;
    display_enemy: in std_logic;
    reset_game: in std_logic);
end main;

architecture Behavioral of main is
--orginal
constant H_TOTAL: integer := 1344-1;
constant H_SYNC: integer := 48-1;
constant H_BACK: integer := 240-1;
constant H_START: integer := 48+240-1;
constant H_ACTIVE: integer := 1024-1;
constant H_END: integer := 1344-32-1-50;
constant H_FRONT: integer := 32-1;
constant V_TOTAL: integer := 625-1;
constant V_SYNC: integer := 3-1;
constant V_BACK: integer := 12-1;
constant V_START: integer := 3+12;
constant V_ACTIVE: integer := 600-1;
constant V_END: integer := 625-10-1;
constant V_FRONT: integer := 10-1;
signal hcount, vcount: integer;
signal flag: integer;
--bullet
constant BULLET_WIDTH: integer := 50;
constant BULLET_HEIGHT: integer := 50;
signal bullet_x: integer := -BULLET_WIDTH; -- Initialize off-screen
signal bullet_y: integer := -BULLET_HEIGHT; -- Initialize off-screen
signal shoot_bullet: std_logic := '0';
signal new_bullet_x: integer;
signal new_bullet_y: integer;
--kill_aircraft
signal aircraft_alive: std_logic := '1';
--Boss
constant BOSS_HEIGHT: integer := 150;
constant BOSS_WIDTH: integer := 150;
signal boss_x: integer := H_END - BOSS_HEIGHT;
signal boss_y: integer := V_TOTAL/2;
signal boss_dx: integer := 20;
signal boss_flagx: std_logic := '1';
signal boss_flagy: std_logic := '1';
signal boss_hp: integer := 10 - 1; --10HP
constant BOSS_BULLET_WIDTH: integer := 20;
constant BOSS_BULLET_HEIGHT: integer := 20;
-- boss laser
constant LASER_WIDTH: integer := 800;
constant LASER_HEIGHT: integer := 100;
signal boss_laser_x: integer := -LASER_WIDTH; -- Initialize off-screen
signal boss_laser_y: integer := -LASER_HEIGHT; -- Initialize off-screen
signal boss_laser_active: std_logic := '0';
--kill Boss
signal boss_alive: std_logic := '1';

component clock_divider is
 generic (N: integer);
   Port (
       clk : IN STD_LOGIC;
       clk_out : OUT STD_LOGIC
   );
end component;
signal clk1Hz, clk10Hz, clk50MHz: std_logic;
--Aircraft
constant X_STEP : integer := 40;
constant Y_STEP : integer := 40;
constant SIZE : integer := 120;
signal x : integer := H_START;
signal y : integer := V_START;
signal dx : integer := X_STEP;
signal dy : integer := Y_STEP; 
signal flagx: std_logic := '1';
signal flagy: std_logic := '1';
signal aircraft_hp: integer := 10 - 1; --10HP

type colors is (C_Black, C_Green, C_Blue, C_Red, C_White, C_Yellow);
type T_1D is array(0 to 4) of colors;
signal color : colors;
--pixel art
type PixelArt is array(0 to 11, 0 to 12) of colors;
type PixelArt_boss is array(0 to 16, 0 to 15) of colors;
constant AIRCRAFT_PIXEL_ART: PixelArt :=(
(C_Black,C_Black,C_Black,C_Black,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_Black,C_Black,C_White,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_Black,C_Black,C_White,C_Green,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_White,C_Black,C_Black,C_Black,C_White,C_Green,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_White,C_White,C_White,C_White,C_Green,C_Green,C_Green,C_White,C_White,C_White,C_White,C_Black),
(C_Black,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_Black),
(C_Black,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_Black),
(C_Black,C_White,C_White,C_White,C_White,C_Green,C_Green,C_Green,C_White,C_White,C_White,C_White,C_Black),
(C_White,C_Black,C_Black,C_Black,C_White,C_Green,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_Black,C_Black,C_White,C_Green,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_Black,C_Black,C_White,C_Green,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_Black,C_Black,C_Black,C_Black,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black));
constant pixel_x: integer := (hcount - x) / 8;
constant pixel_y: integer := (vcount - y) / 8;
constant BOSS_PIXEL_ART: PixelArt_boss :=(
(C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_White,C_White,C_White,C_Black,C_White,C_White,C_White,C_White,C_White,C_White),
(C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_White,C_White,C_White,C_Black,C_White,C_White,C_White,C_White,C_White,C_White),
(C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_White,C_White,C_White,C_White,C_White,C_White),
(C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_White,C_White,C_White,C_White,C_White,C_White),
(C_White,C_White,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_White,C_White,C_White),
(C_White,C_White,C_White,C_Black,C_White,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_White,C_Black,C_White,C_White,C_White),
(C_White,C_White,C_Black,C_Black,C_White,C_White,C_Black,C_Black,C_White,C_Black,C_Black,C_White,C_White,C_Black,C_Black,C_White,C_White),
(C_White,C_Black,C_Black,C_Black,C_White,C_White,C_White,C_Black,C_White,C_Black,C_White,C_White,C_White,C_Black,C_Black,C_Black,C_White),
(C_White,C_Black,C_Black,C_Black,C_White,C_White,C_White,C_Black,C_White,C_Black,C_White,C_White,C_White,C_Black,C_Black,C_Black,C_White),
(C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black),
(C_White,C_White,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_White,C_White),
(C_White,C_White,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_White,C_White),
(C_White,C_White,C_Black,C_White,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_Black,C_White,C_White,C_Black,C_White,C_White),
(C_White,C_White,C_Black,C_White,C_White,C_Black,C_White,C_White,C_White,C_White,C_White,C_Black,C_White,C_White,C_Black,C_White,C_White),
(C_White,C_White,C_Black,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_White,C_White),
(C_White,C_White,C_White,C_Black,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_White,C_Black,C_White,C_White,C_White));
constant boss_pixel_x: integer := (hcount - x) / 9;
constant boss_pixel_y: integer := (vcount - y) / 9;

begin
u_clk50mhz: clock_divider generic map(N=>1) port map(clk, clk50MHz); 

pixel_count_proc: process(clk50MHz)
begin
    if (rising_edge(clk50MHz)) then
        if(hcount = H_TOTAL) then
            hcount <= 0;
        else
            hcount <= hcount + 1;
        end if;
    end if;
end process pixel_count_proc;

hsync_gen_proc: process(hcount) begin
    if(hcount <= H_SYNC) then
        hsync <= '1';
    else
        hsync <= '0';
    end if;
end process hsync_gen_proc;

line_count_proc: process (clk50MHz)
begin
    if (rising_edge(clk50MHz)) then
        if (hcount = H_TOTAL) then 
            if (vcount = V_TOTAL) then
                vcount <= 0;
            else
                vcount <= vcount + 1;
            end if;
        end if;
    end if;
end process line_count_proc;

vsync_gen_proc : process (hcount)
begin
    if (vcount <= V_SYNC) then
        vsync <= '1';
    else
        vsync <= '0';
    end if;
end process vsync_gen_proc;

u_clk1hz : clock_divider generic map(N =>50000000) port map(clk, clk1Hz);
u_clk10hz : clock_divider generic map(N =>5000000) port map(clk, clk10Hz);

process(clk10Hz)
begin
    if(rising_edge(clk10Hz)) then
        -- Reset game state when reset_game is '1'
        if (reset_game = '1') then
            x <= H_START;
            y <= V_START;
            aircraft_alive <= '1';
            boss_alive <= '1';
            shoot_bullet <= '0';
            bullet_x <= -BULLET_WIDTH;
            bullet_y <= -BULLET_HEIGHT;
            -- Reset the boss's health points
            boss_hp <= 10 - 1; --10HP
            -- Reset the aircraft's health points
            aircraft_hp <= 10 - 1; --10HP
        else

            -- The existing code for movements, shooting
            --/*move up, down, left, right && shoot
            if (moveU = '1') then
                if (x < (H_END - SIZE)) then
                    x <= x + dx; 
                end if;
            end if;
           
            if (moveD = '1') then
                if (x > H_START) then
                    x <= x - dx; 
                end if;
            end if;
           
            if (moveL = '1') then
                if (y > V_START) then
                    y <= y - dy;
                end if;
            end if;
           
            if (moveR = '1') then
                if (y < (V_END - SIZE)) then
                    y <= y + dy;
                end if;
            end if;   
                   
            --shoot
            if (shoot = '1' and bullet_y <= V_START) then
                 new_bullet_x <= x + (SIZE / 2) - (BULLET_WIDTH / 2);
                new_bullet_y <= y - BULLET_HEIGHT;
            end if;
                   
            --move up, down, left, right && shoot END*/
            
            --/*bullet_movement_process

                   
                    if (shoot_bullet = '1') then
                        if (bullet_x < H_END) then
                            bullet_x <= bullet_x + dx;
                        else
                            shoot_bullet <= '0'; -- Reset shoot_bullet if the bullet goes beyond the display area
                        end if;
                    elsif (shoot = '1' and shoot_bullet = '0') then
                        shoot_bullet <= '1';
                        bullet_x <= x + SIZE;
                        bullet_y <= y + (SIZE / 2) - (BULLET_WIDTH / 2); -- Set the bullet_y initial position to the top of the aircraft
                    else
                        shoot_bullet <= '0';
                        bullet_x <= -BULLET_WIDTH; -- Reset the bullet off-screen when it is not shooting
                    end if;
                    
                    -- Check for collision with boss
                    if (bullet_x >= boss_x and bullet_x < boss_x + BOSS_WIDTH and bullet_y >= boss_y and bullet_y < boss_y + BOSS_HEIGHT and boss_alive = '1') then
                        boss_hp <= boss_hp - 1; -- Decrement boss's health points
                        shoot_bullet <= '0'; -- Bullet disappears
                        bullet_x <= -BULLET_WIDTH; -- Set the bullet's position off-screen
                    
                        if (boss_hp = 0) then
                            boss_alive <= '0'; -- Boss is killed
                        end if;
                    end if;
            --bullet_movement_process END*/


            
            --boss_movement
            if (boss_y <= V_START) then
                boss_flagy <= '1';
            elsif (boss_y >= (V_END - BOSS_HEIGHT)) then
                boss_flagy <= '0';
            end if;
            
            if (boss_flagy = '1') then
                boss_y <= boss_y + 20;
            elsif (boss_flagy = '0') then
                boss_y <= boss_y - 20;
            end if;
            --boss_movement END
            --boss_laser
            -- boss shoots a laser
            if(boss_laser_active = '0' and boss_y > (V_START + V_END) / 2 - BOSS_WIDTH and boss_y < (V_START + V_END) / 2 + BOSS_WIDTH) then
                boss_laser_active <= '1';
                boss_laser_x <= boss_x - LASER_WIDTH;
                boss_laser_y <= boss_y + BOSS_HEIGHT / 2;          
            else
                boss_laser_active <= '0';
            end if;
            
            -- Check for collision with aircraft
            if (boss_laser_y >= y and boss_laser_y < y + SIZE and boss_laser_active = '1' and aircraft_alive = '1') then
                aircraft_hp <= aircraft_hp - 2; -- Decrement aircraft's health points
                if (aircraft_hp = 0) then
                    aircraft_alive <= '0'; -- Aircraft is killed
                end if;
            end if;
            --boss_laser end
            
        end if;
    end if;
end process;

--display
process (hcount, vcount, x, y, bullet_x, bullet_y)
begin
    if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
        --bullet
        if (hcount >= bullet_x and hcount < bullet_x + BULLET_WIDTH and vcount >= bullet_y and vcount < bullet_y + BULLET_HEIGHT) then
            color <= C_White;
        -- square (aircraft)
        elsif (x <= hcount and hcount < x + SIZE and y < vcount and vcount < y + SIZE and aircraft_alive = '1') then
            color <= AIRCRAFT_PIXEL_ART(pixel_y, pixel_x);
        --boss
        elsif (hcount >= boss_x and hcount < boss_x + BOSS_HEIGHT and vcount < boss_y + BOSS_WIDTH and boss_y < vcount and boss_alive = '1') then
            color <= BOSS_PIXEL_ART(boss_pixel_y, boss_pixel_x);
        -- boss laser
        elsif (hcount >= boss_laser_x and hcount < boss_laser_x + LASER_WIDTH and vcount < boss_laser_y + LASER_HEIGHT and boss_laser_y < vcount and boss_laser_active = '1') then
            color <= C_Yellow;
        else
            color <= C_Black;
        end if;
    else
        color <= C_BLACK;
    end if;
end process;

process (color)
begin
case(color) is
    when C_Black =>
        red <= "0000"; green <= "0000";
        blue <= "0000";
    when C_Green =>
        red <= "0000"; green <= "1000";
        blue <= "0000";
    when C_Blue =>
        red <= "0000"; green <= "0000";
        blue <= "1111";
    when C_Red =>
        red <= "1111"; green <= "0000";
        blue <= "0000";
    when C_White =>
        red <= "1111"; green <= "1111";
        blue <= "1111";
    when C_Yellow =>
        red <= "1111"; green <= "1111";
        blue <= "0000";
    when others =>
        red <= "0000"; green <= "0000";
        blue <= "0000";
    end case;
end process; 

end Behavioral;
