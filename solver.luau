--!strict

--[[
	Returns the lowest point on the given rope
	@param p1 First endpoint of the rope
	@param p2 Second endpoint of the rope
	@param length Length of the rope
]]
local function getLowestRopePoint(p1: Vector3, p2: Vector3, length: number): Vector3
	local h = p2.Y - p1.Y
	local horizVector = Vector3.new(p2.X - p1.X, 0, p2.Z - p1.Z)
	local d = horizVector.Magnitude
	local straightDist = math.sqrt(d * d + h * h)

	-- Edge Case: Taut or physically impossible length
	if length <= straightDist then
		return if p1.Y <= p2.Y then p1 else p2
	end

	-- Edge Case: Vertically aligned anchor points (d = 0)
	if d < 1e-6 then
		local minY = math.min(p1.Y, p2.Y)
		local excessSag = (length - math.abs(h)) / 2
		return Vector3.new(p1.X, minY - excessSag, p1.Z)
	end

	-- Transcendental Catenary Solver
	local K = math.sqrt(length * length - h * h) / d

	-- Newton-Raphson initialization via Taylor expansion: sinh(u)/u ≈ 1 + u^2/6
	local u = math.sqrt(6 * (K - 1))
	for _ = 1, 10 do
		local sinh_u = math.sinh(u)
		local cosh_u = math.cosh(u)
		local f = sinh_u - K * u
		local fPrime = cosh_u - K
		u = u - f / fPrime
	end

	local a = d / (2 * u)

	-- Horizontal distance from p1 to the catenary vertex
	local r0 = (d / 2) - (a / 2) * math.log((length + h) / (length - h))

	-- Edge Case: Vertex lies outside the suspended segment [0, d]
	if r0 < 0 or r0 > d then
		return if p1.Y <= p2.Y then p1 else p2
	end

	-- Lowest Y coordinate on the curve
	local yLow = p1.Y - a * (math.cosh(r0 / a) - 1)

	-- Map 2D vertex position back to 3D space
	local dirHoriz = horizVector.Unit
	local lowestX = p1.X + dirHoriz.X * r0
	local lowestZ = p1.Z + dirHoriz.Z * r0

	return Vector3.new(lowestX, yLow, lowestZ)
end
