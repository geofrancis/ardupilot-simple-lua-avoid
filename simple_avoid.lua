-- This scirpt uses Rover's turn rate controller to make the vehicle move in circles based on the distance to objects

-- Edit these variables


local rc_channel_switch = 7         -- switch this channel to "high" to get the script working
local min_range = 100               -- distance that maximum turning is applied.
local max_range = 200               -- distance avoidance starts at.
local critical_range = 50	    -- minimum distance before stopping the vehicle.
local close_range = 0
local circle_min = 100		    -- turning radius for maximum turning rate
local circle_max = 500		    -- turning radius for minimum turning rate
local speed_min = 0.1
local speed_max = 1
-- Fixed variables
local omega_radps = target_speed_xy_mps/radius_target
local guided_mode = 15
local auto_mode = 10
local hold_mode = 4
local front_range = 0
local front_left_range = 0
local front_right_range = 0
local left_range = 0
local right_range = 0
local direction = 1
local radius_target = 2
local speed_target = 1
end


-- Script Start --

local circle_active = false
local last_mode = 0

gcs:send_text(0,"Script started")




function update()

    if not circle_active then
        last_mode = auto
    end



-- get values from rangefinders
    local left_range = rangefinder:distance_cm_orient(6) (true)
  if not left_range then
gcs:send_text(0, "No left rangefinder data 6")
    return update, 1000
  end
    local front_left_range = rangefinder:distance_cm_orient(7) (true)
  if not front_left_range then
gcs:send_text(0, "No front left rangefinder data 7")
    return update, 1000
  end
local front_range = rangefinder:distance_cm_orient(0) (true)
  if not front_range then
gcs:send_text(0, "No front rangefinder data 0 ")
    return update, 1000
  end
local front_right_range = rangefinder:distance_cm_orient(1) (true)
  if not front_right_range then
gcs:send_text(0, "No front right rangefinder data 1 ")
    return update, 1000
  end
local right_range = rangefinder:distance_cm_orient(2) (true)
  if not right_range then
gcs:send_text(0, "No right rangefinder data 2 ")
    return update, 1000
  end



--finding the closest range
  if front_range < max_range and > 0 then
		close_range = front_range

   else if front_left_range < close_range and > 0 then 
		close_range = front_left_range
	
   else if front_right_range < close_range and > 0 then 
		close_range = front_right_range
		
   else if right_range < close_range and > 0 then 
		close_range = right_range
			
   else if left_range < close_range and > 0 then 
		close_range = left_range
					
      else close_range = max_range				
end

--scaling speed based on closest object 
  if  close_range < max_range then
    local function speed_target(close_range, min_range, max_range, speed_min, speed_max)
    return math.floor((speed_target - min_range) * (speed_max - speed_min) / (min_range - min_range) + speed_max)
end
			
			
			
--calculating the circle radius based on the distance to object 									
--left and right sensors get half the turn rate of the forward sensors
   if  left_range < min_range and left_range < right_range and left_range < left_front_range then
    local function radius_target (left_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
   radius_target = radius_target * 2												
end
  if  right_range < min_range and right_range < left_range and left range < front_left_range then
    local function radius_target(right_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
    radius_target = radius_target * 2
end
  if  front_left_range < min_range and front_left_range < front_right_range then
    local function radius_target(front_left_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
end
  if  front_right_range < min_range and front_right_range < front_left_range then
    local function radius_target(front_right_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
end							
								
-- comparing the left and right rangefinders to figure out what direction to turn								
							
if left_range < max_range and left_range < right_range then					
	direction = 1
        circle_active = true						
else if right_range < max_range and right_range < left_range then
	direction = -1	
	circle_active = true
		--running front sensors last so they get priority								
else if	front_left_range < max_range and front_left_range < front_left_range then
	direction = 1	
	circle_active = true								
else if	front_right_range < max_range and front_right_range < front_right_range then
	direction = -1	
	circle_active = true	
else 	circle_active = false 
	direction = 0
end
					
	 -- set guided mode to avoid 
    if arming:is_armed() and rc:get_pwm(rc_channel_switch) > 1700 and not circle_active and (vehicle:get_mode() == auto_mode) and close_range > critical range then 
        vehicle:set_mode(guided_mode)
	--set Hold mode if distance is critical												
elseif arming:is_armed() and rc:get_pwm(rc_channel_switch) > 1700 and not circle_active and (vehicle:get_mode() == auto_mode) and close_range < critical range then 
        vehicle:set_mode(hold_mode)
	--disable avoidance											
 elseif arming:is_armed() and rc:get_pwm(rc_channel_switch) < 1200 and circle_active then
        circle_active = false


    end

    if circle_active then
        --target turn rate in degrees including direction
        local target_turn_rate = math.deg(omega_radps * direction)
        gcs:send_text(0,"Trajectory period: " .. tostring(2 * math.rad(180) / omega_radps))

        -- send guided message
        if not vehicle:set_desired_turn_rate_and_speed(target_turn_rate, speed_target) then
            gcs:send_text(0, "Failed to send target ")
        end
    end

    return update, 100
end

return update()
