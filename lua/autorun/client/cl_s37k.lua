S37K_mapbounds = {}

local function within(num, tbl)
	local contains = false
	for k, v in pairs( tbl ) do
		if (v - 2000) < num and (v+2000) > num then
			contains = true
			break
		end
	end
	if not contains then
		table.insert(tbl,num)
	end
	return contains
end

local function filterfunc(ent)
	if ent:IsWorld() then
		for _, surface in pairs( ent:GetBrushSurfaces() ) do
			if surface:IsSky() then return true end
		end
	end
end

local function findbounds()
	print("s37k_lib: finding map bounds...")
	local skyzpos = {}
	local entz
	local tra = util.TraceLine( {
		start = LocalPlayer():GetPos(),
		endpos = Vector(LocalPlayer():GetPos().x,LocalPlayer():GetPos().y,LocalPlayer():GetPos().z + 100000),
		mask = MASK_SOLID_BRUSHONLY,
		filter = filterfunc
	} )
	if (tra.HitPos.z - LocalPlayer():GetPos().z > 2000) then
		if not within(tra.HitPos.z,skyzpos) then entz =LocalPlayer():GetPos().z end
	else
		local trb = util.TraceLine( {
			start = Vector(LocalPlayer():GetPos().x,LocalPlayer():GetPos().y,LocalPlayer():GetPos().z + 2000),
			endpos = tra.HitPos,
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trc = util.TraceLine( {
			start = trb.HitPos,
			endpos = Vector(LocalPlayer():GetPos().x,LocalPlayer():GetPos().y,LocalPlayer():GetPos().z + 100000),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		if (trc.HitPos.z - LocalPlayer():GetPos().z > 2000) then
			print(trc.HitPos.z - LocalPlayer():GetPos().z)
			if not within(trc.HitPos.z,skyzpos) then entz =LocalPlayer():GetPos().z end
		end
	end
	

	for _, v in pairs( skyzpos ) do
		local pos = v - 100
		local trpx = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(50000,0,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trnx = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(-50000,0,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trpy = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(0,50000,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trny = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(0,-50000,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local tbl = {}
		tbl.area = (trpx.HitPos.x - trnx.HitPos.x) * (trpy.HitPos.y - trny.HitPos.y) * (v - entz)
		tbl.skyZ = v
		if trpx.HitPos.x == 50000 or trnx.HitPos.x == -50000 or trpy.HitPos.y == 50000 or trny.HitPos.y == -50000 then continue end
		tbl.positiveX = trpx.HitPos.x
		tbl.negativeX = trnx.HitPos.x
		tbl.positiveY = trpy.HitPos.y
		tbl.negativeY = trny.HitPos.y
		table.insert(S37K_mapbounds,tbl)
	end
	if #S37K_mapbounds == 0 then print("s37k_lib: Failed to find map bounds! Are you on a weird/complex shaped map?") return end
	print("s37k_lib: map bounds found! (access S37K_mapbounds table to use them in your addons!)")
	PrintTable(S37K_mapbounds)
end
hook.Add("InitPostEntity","swm_findmapbounds_cl",findbounds)