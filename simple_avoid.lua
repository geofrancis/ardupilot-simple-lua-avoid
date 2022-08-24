-- This scirpt uses Rover's turn rate controller to make the vehicle move in circles of fixed radius

-- Edit these variables

local target_speed_xy_mps = 0.5     -- target speed in m/s
local rc_channel_switch = 7         -- switch this channel to "high" to get the script working
local min_range = 100               -- distance that maximum turning is applied.
local max_range = 200               -- distance avoidance starts at.
local circle_min = 1		    -- turning radius for maximum turning rate
local circle_max = 2		    -- turning radius for minimum turning rate

-- Fixed variables
local omega_radps = target_speed_xy_mps/radius_target
local guided_mode = 15
local auto_mode = 10
local left_range = 0
local right_range = 0
local direction = 1
local radius_target = 0
end


-- Script Start --

gcs:send_text(0,"Script started")
gcs:send_text(0,"Trajectory period: " .. tostring(2 * math.rad(180) / omega_radps))


local circle_active = false
local last_mode = 0


function update()

    if not circle_active then
        last_mode = vehicle:get_mode()
    end

    local left_range = rangefinder:distance_cm_orient(6) (true)
  if not left_range then
    return update, 1000
  end
    local right_range = rangefinder:distance_cm_orient(2) (true)
  if not right_range then
    return update, 1000
  end
    
  if  left_range < min_range and left_range < right_range then
    local function radius_target(left_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
end

  if  right_range < min_range and right_range < left_range then
    local function radius_target(right_range, min_range, max_range, circle_min, circle_max)
    return math.floor((radius_target - min_range) * (circle_max - circle_min) / (min_range - min_range) + circle_max)
end

	
	
    if arming:is_armed() and rc:get_pwm(rc_channel_switch) > 1700 and not circle_active and (vehicle:get_mode() == auto_mode) and left_range < min_range and left_range < right_range then
        -- set guided mode and circle to the right 
        vehicle:set_mode(guided_mode)
        direction = 1
        circle_active = true
            
    if arming:is_armed() and rc:get_pwm(rc_channel_switch) > 1700 and not circle_active and (vehicle:get_mode() == auto_mode) and right range < min range and right_range < left range then
        -- set guided mode and circle to the left 
        vehicle:set_mode(guided_mode)
        direction = -1
        circle_active = true
            
    elseif arming:is_armed() and rc:get_pwm(rc_channel_switch) < 1200 and circle_active then
        -- set back to last mode since rc switch is low
        vehicle:set_mode(last_mode)
        circle_active = false
    end

    if circle_active then
        --target turn rate in degrees including direction
        local target_turn_rate = math.deg(omega_radps * direction)

        -- send guided message
        if not vehicle:set_desired_turn_rate_and_speed(target_turn_rate, target_speed_xy_mps) then
            gcs:send_text(0, "Failed to send target ")
        end
    end

    return update, 100
end

return update()
