function initStarCoord(from, to)
	return love.math.random(from, to)
end

function initStar(z_from, z_to)
	local x = initStarCoord(-1000, 1000)
	local y = initStarCoord(-1000, 1000)
	local z = initStarCoord(z_from, z_to)
	local red_hue = love.math.random(0, 80)
	local yellow_hue = love.math.random(0, 30)
	local blue_hue = love.math.random(0, 100)
	return {x, y, z, red_hue, yellow_hue, blue_hue}
end

function projectStars(camera_z)
	function projectCoord(coord, z, offset)
		return coord/(z+camera_z) * 200 + offset
	end

	function distance(x, y, z)
		return math.sqrt(x^2 + y^2 + z^2)
	end

	stars_on_screen = {}
	local stars_on_screen_iterator = 1
	for k, v in pairs(stars) do
		star_visible = false
		if (v[3] + camera_z) > 0.01 then
			projected_x = projectCoord(v[1], v[3], screen_width/2)
			projected_y = projectCoord(v[2], v[3], screen_height/2)
			if projected_x > 0
					and projected_x <= screen_width
					and projected_y > 0
					and projected_y <= screen_height
					then
				stars_on_screen[stars_on_screen_iterator] = {
					projected_x,
					projected_y,
					distance(v[1], v[2], v[3]+camera_z),
					v[4],
					v[5],
					v[6]
				}
				stars_on_screen_iterator = stars_on_screen_iterator + 1
				star_visible = true
			end
		end
		if not star_visible then
			initDistance = 1000 - camera_z
			stars[k] = initStar(initDistance, initDistance)
		end
	end
	print(string.format("cam z: %i, stars on screen: %i", camera_z, stars_on_screen_iterator - 1))
end

function love.load()
	love.window.setFullscreen(true, "desktop")
	local max_stars = 10000
	stars = {}
	screen_width, screen_height = love.graphics.getDimensions()
	camera_z = 0
	for i=1, max_stars do
		stars[i] = initStar(0, 1000)
	end
	projectStars(camera_z)

	galaxies = {}
	local max_galaxies = 5000
	for i=1, max_galaxies do
		intensity = love.math.random(0, 100)
		galaxies[i] = {
			love.math.random(1, screen_width),
			love.math.random(1, screen_height),
			math.max(intensity - love.math.random(0, 30), 0),
			math.max(intensity - love.math.random(0, 30), 0),
			math.max(intensity - love.math.random(0, 30), 0)
		}
	end
end

function love.update(dt)
	camera_z = camera_z - dt * 80
	projectStars(camera_z)
end

function love.keypressed(k)
   if k == 'escape' then
      love.event.quit()
   end
end

function love.draw()
	function intensity(distance)
		return math.min(450 * 150/distance, 450)
	end

	for k, v in pairs(galaxies) do
		love.graphics.setColor(v[3], v[4], v[5])
		love.graphics.points(v[1], v[2])
	end

	for k, v in pairs(stars_on_screen) do
		curr_intensity = intensity(v[3])
		rgbIntensity = math.min(255, curr_intensity)
		red = rgbIntensity - v[5] - v[6]
		green = rgbIntensity - v[4] - v[6]
		blue = rgbIntensity - v[4]
		radius = math.max(50/v[3], 1)
		love.graphics.setColor(red, green, blue)
		love.graphics.circle("fill", v[1], v[2], radius, math.max(math.floor(radius)*3, 3))
	end
end
