if not CLIENT then return end

surface.CreateFont("cm",{font="Consolas",size=14,weight=400})
surface.CreateFont("cm_b",{font="Consolas",size=14,weight=700})
surface.CreateFont("cm_t",{font="Consolas",size=16,weight=700})
surface.CreateFont("cm_bg",{font="Consolas",size=20,weight=700})

local discordURL="discord.gg/larpwtf"
cheat=cheat or{}
cheat.esp=false cheat.god=false cheat.noclip=false cheat.speed=false
cheat.aimbot=false cheat.fullbright=false cheat.spectate=false
cheat.hitbox=false cheat.hitboxScale=3 cheat.thirdperson=false cheat.tpDist=80
cheat.fovChanger=false cheat.fovValue=100 cheat.crosshair=false cheat.crosshairSize=10
cheat.crosshairStyle=0 cheat.nametags=false cheat.removeshadows=false
cheat.chatspam=false cheat.rainbow=false cheat.spinbot=false cheat.spinSpeed=10
cheat.skeleton=false cheat.headcircle=false cheat.snaplines3d=false
cheat.duck=false cheat.autostrafe=false cheat.espBoxes=true cheat.espHealth=true
cheat.espNames=true cheat.espSnaplines=true cheat.glow=false cheat.bunnyhop=false
cheat.antiaim=false cheat.fakepitch=false cheat.viewangles=false cheat.watermark=true
cheat.spinSavedAngles=nil cheat.nofog=false cheat.nightmode=false cheat.nightmodeVal=0.1
cheat.wireframe=false cheat.chams=false cheat.chamsColor=Color(0,200,255)
cheat.spectatorlist=false cheat.hitsound=false cheat.propESP=false
cheat.nosky=false cheat.flashlight=false cheat.teamaimbot=false cheat.recoil=false
cheat.bhopHold=false cheat.autoreload=false cheat.headshotonly=false
cheat.aimbotSmooth=0 cheat.aimbotFov=10 cheat.showFov=false cheat.antiut=false
cheat.DiscordURL=discordURL
cheat.rapidfire=false cheat.infiniteammo=false cheat.norecoil=false
cheat.infiniteclip=false cheat.autoattack=false cheat.fovzoom=false cheat.fovzoomval=20
cheat.rocketspam=false
cheat.noreload=false
cheat.npcESP=false cheat.entityESP=false cheat.itemESP=false

function cheat.SyncServer(key,val)
	RunConsoleCommand("cheat_set",key,tostring(val))
end

function cheat.GetCrosshairTarget()
	local lp=LocalPlayer()
	if not IsValid(lp) then return nil end
	local eyePos=lp:EyePos()
	local fwd=lp:EyeAngles():Forward()
	local best,nil2=nil,999999
	local fov=cheat.aimbotFov
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local dir=p:WorldSpaceCenter()-eyePos
			local dot=dir:Dot(fwd)
			if dot>0 then
				local hit=eyePos+fwd*dot
				local d2=hit:DistToSqr(p:WorldSpaceCenter())
				local ang=math.deg(math.acos(math.Clamp(dir:GetNormalized():Dot(fwd),-1,1)))
				if ang<=fov and d2<nil2 then nil2=d2 best=p end
			end
		end
	end
	return best
end

function cheat.GetNPCrosshairTarget()
	local lp=LocalPlayer()
	if not IsValid(lp) then return nil end
	local eyePos=lp:EyePos()
	local fwd=lp:EyeAngles():Forward()
	local best,bestDist=nil,999999
	local fov=cheat.npcAimbotFov
	for _,npc in ipairs(ents.FindByClass("npc_*")) do
		if IsValid(npc) and npc:Health()>0 then
			local center=npc:WorldSpaceCenter()
			local dir=center-eyePos
			local dot=dir:Dot(fwd)
			if dot>0 then
				local ang=math.deg(math.acos(math.Clamp(dir:GetNormalized():Dot(fwd),-1,1)))
				if ang<=fov then
					local d=eyePos:DistToSqr(center)
					if d<bestDist then bestDist=d best=npc end
				end
			end
		end
	end
	return best
end

function cheat.W2S(pos) local s=pos:ToScreen() return s.x,s.y end

-- ESP
hook.Add("HUDPaint","cheat_esp",function()
	if not cheat.esp then return end
	local lp=LocalPlayer()
	if not IsValid(lp) then return end
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local top=p:GetPos()+Vector(0,0,72)
			local bot=p:GetPos()
			local tx,ty=cheat.W2S(top)
			local bx,by=cheat.W2S(bot)
			if(tx==0 and ty==0)or(bx==0 and by==0) then continue end
			local h=math.abs(ty-by)
			if h<5 then continue end
			local w=h*0.6 local cx=(tx+bx)/2 local lx=cx-w/2 local topy=math.min(ty,by)
			local tr=lp:GetEyeTrace() local aimed=tr and IsValid(tr.Entity) and tr.Entity==p
			local team=p:Team()==lp:Team()
			local col
			if aimed then col=Color(255,220,0) elseif team then col=Color(100,200,100) else col=Color(0,200,255) end
			if cheat.glow then for i=3,1,-1 do surface.SetDrawColor(col.r,col.g,col.b,30) surface.DrawOutlinedRect(lx-i,topy-i,w+i*2,h+i*2,1) end end
			if cheat.espBoxes then surface.SetDrawColor(col) surface.DrawOutlinedRect(lx,topy,w,h,1) end
			if cheat.espBooks then
				local hp=p:Health() local mhp=math.max(p:GetMaxHealth(),1) local r=math.Clamp(hp/mhp,0,1) local hh=h*r
				local hc=r>0.5 and Color(0,220,80) or(r>0.25 and Color(255,200,0) or Color(255,40,40))
				surface.SetDrawColor(Color(0,0,0,160)) surface.DrawRect(lx-5,topy,3,h)
				surface.SetDrawColor(hc) surface.DrawRect(lx-5,topy+(h-hh),3,hh)
			end
			if cheat.espHealth then
				local hp=p:Health() local mhp=math.max(p:GetMaxHealth(),1) local r=math.Clamp(hp/mhp,0,1) local hh=h*r
				local hc=r>0.5 and Color(0,220,80) or(r>0.25 and Color(255,200,0) or Color(255,40,40))
				surface.SetDrawColor(Color(0,0,0,160)) surface.DrawRect(lx-5,topy,3,h)
				surface.SetDrawColor(hc) surface.DrawRect(lx-5,topy+(h-hh),3,hh)
			end
			if cheat.espNames then
				draw.SimpleText(p:Nick(),"cm",cx,topy-6,Color(255,255,255,230),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
				local hp=p:Health() local mhp=math.max(p:GetMaxHealth(),1) local r=math.Clamp(hp/mhp,0,1)
				local hc=r>0.5 and Color(0,220,80) or(r>0.25 and Color(255,200,0) or Color(255,40,40))
				draw.SimpleText(hp.." hp","cm",cx,topy+h+4,hc,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				local wep=p:GetActiveWeapon()
				if IsValid(wep) then draw.SimpleText(wep:GetPrintName(),"cm",cx,topy+h+16,Color(180,180,180,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) end
			end
			if cheat.espSnaplines then
				local ex,ey=cheat.W2S(lp:EyePos())
				if ex~=0 or ey~=0 then surface.SetDrawColor(col.r,col.g,col.b,80) surface.DrawLine(ex,ey,cx,topy+h/2) end
			end
		end
	end
end)

local function GetBone(p,bname) local id=p:LookupBone(bname) if not id then return nil end return p:GetBonePosition(id) end

-- Skeleton
hook.Add("HUDPaint","cheat_skeleton",function()
	if not cheat.skeleton then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local bones={
		{"ValveBiped.Bip01_Head","ValveBiped.Bip01_Neck"},
		{"ValveBiped.Bip01_Neck","ValveBiped.Bip01_Spine4"},
		{"ValveBiped.Bip01_Spine4","ValveBiped.Bip01_Spine2"},
		{"ValveBiped.Bip01_Spine2","ValveBiped.Bip01_Spine"},
		{"ValveBiped.Bip01_Spine","ValveBiped.Bip01_Pelvis"},
		{"ValveBiped.Bip01_Neck","ValveBiped.Bip01_L_UpperArm"},
		{"ValveBiped.Bip01_L_UpperArm","ValveBiped.Bip01_L_Forearm"},
		{"ValveBiped.Bip01_L_Forearm","ValveBiped.Bip01_L_Hand"},
		{"ValveBiped.Bip01_Neck","ValveBiped.Bip01_R_UpperArm"},
		{"ValveBiped.Bip01_R_UpperArm","ValveBiped.Bip01_R_Forearm"},
		{"ValveBiped.Bip01_R_Forearm","ValveBiped.Bip01_R_Hand"},
		{"ValveBiped.Bip01_Pelvis","ValveBiped.Bip01_L_Thigh"},
		{"ValveBiped.Bip01_L_Thigh","ValveBiped.Bip01_L_Calf"},
		{"ValveBiped.Bip01_L_Calf","ValveBiped.Bip01_L_Foot"},
		{"ValveBiped.Bip01_Pelvis","ValveBiped.Bip01_R_Thigh"},
		{"ValveBiped.Bip01_R_Thigh","ValveBiped.Bip01_R_Calf"},
		{"ValveBiped.Bip01_R_Calf","ValveBiped.Bip01_R_Foot"},
	}
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			surface.SetDrawColor(255,255,255,180)
			for _,b in ipairs(bones) do
				local a=GetBone(p,b[1]) local bb=GetBone(p,b[2])
				if a and bb then
					local ax,ay=cheat.W2S(a) local bx2,by2=cheat.W2S(bb)
					if(ax~=0 or ay~=0)and(bx2~=0 or by2~=0) then surface.DrawLine(ax,ay,bx2,by2) end
				end
			end
		end
	end
end)

-- Head circles
hook.Add("HUDPaint","cheat_headcircle",function()
	if not cheat.headcircle then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local hx,hy=cheat.W2S(p:GetPos()+Vector(0,0,72))
			if hx~=0 or hy~=0 then
				surface.SetDrawColor(255,0,0,200)
				local r,n=12,20
				for i=0,n-1 do local a1=(i/n)*math.pi*2 local a2=((i+1)/n)*math.pi*2 surface.DrawLine(hx+math.cos(a1)*r,hy+math.sin(a1)*r,hx+math.cos(a2)*r,hy+math.sin(a2)*r) end
			end
		end
	end
end)

-- 3D Snaplines
hook.Add("HUDPaint","cheat_snaplines3d",function()
	if not cheat.snaplines3d then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local ex,ey=cheat.W2S(lp:EyePos()) if ex==0 and ey==0 then return end
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local px,py=cheat.W2S(p:GetPos())
			if px~=0 or py~=0 then surface.SetDrawColor(0,255,0,80) surface.DrawLine(ex,ey,px,py) end
		end
	end
end)

-- Watermark
hook.Add("HUDPaint","cheat_watermark",function()
	if not cheat.watermark then return end
	local txt=discordURL.." | "..os.date("%H:%M:%S")
	surface.SetFont("cm")
	local tw=surface.GetTextSize(txt)
	draw.RoundedBox(2,10,10,tw+14,20,Color(0,0,0,180))
	draw.SimpleText(txt,"cm",17,20,Color(0,200,80),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
end)

-- Crosshair
hook.Add("HUDPaint","cheat_crosshair",function()
	if not cheat.crosshair then return end
	local cx,cy=ScrW()/2,ScrH()/2 local s,pg=cheat.crosshairSize,4
	surface.SetDrawColor(0,255,0,220)
	if cheat.crosshairStyle==0 then
		surface.DrawLine(cx-s,cy,cx-pg,cy) surface.DrawLine(cx+pg,cy,cx+s,cy)
		surface.DrawLine(cx,cy-s,cx,cy-pg) surface.DrawLine(cx,cy+pg,cx,cy+s)
	elseif cheat.crosshairStyle==1 then
		for i=0,23 do local a1=(i/24)*math.pi*2 local a2=((i+1)/24)*math.pi*2 surface.DrawLine(cx+math.cos(a1)*s,cy+math.sin(a1)*s,cx+math.cos(a2)*s,cy+math.sin(a2)*s) end
	else
		surface.DrawLine(cx-s,cy,cx+s,cy) surface.DrawLine(cx,cy-s,cx,cy+s)
		surface.DrawLine(cx-s*0.7,cy-s*0.7,cx-pg,cy-pg) surface.DrawLine(cx+pg,cy+pg,cx+s*0.7,cy+s*0.7)
	end
end)

-- FOV circle
hook.Add("HUDPaint","cheat_fovcircle",function()
	if not cheat.showFov or not cheat.aimbot then return end
	local cx,cy=ScrW()/2,ScrH()/2 local fov=cheat.aimbotFov
	local pfov=LocalPlayer():GetFOV()
	local r=math.tan(math.rad(fov))/math.tan(math.rad(pfov/2))*(ScrW()/2)
	surface.SetDrawColor(255,255,255,60)
	for i=0,39 do local a1=(i/40)*math.pi*2 local a2=((i+1)/40)*math.pi*2 surface.DrawLine(cx+math.cos(a1)*r,cy+math.sin(a1)*r,cx+math.cos(a2)*r,cy+math.sin(a2)*r) end
end)

-- Name tags
hook.Add("HUDPaint","cheat_nametags",function()
	if not cheat.nametags then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local nx,ny=cheat.W2S(p:GetPos()+Vector(0,0,80))
			if nx~=0 or ny~=0 then
				draw.SimpleText(p:Nick(),"cm",nx,ny-14,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
				draw.SimpleText(math.Round(lp:GetPos():Distance(p:GetPos())).."m","cm",nx,ny,Color(180,180,180,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
		end
	end
end)

-- Spectator list
hook.Add("HUDPaint","cheat_spectatorlist",function()
	if not cheat.spectatorlist then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local list={}
	for _,p in ipairs(player.GetAll()) do if p~=lp and IsValid(p) and p:GetObserverTarget()==lp then table.insert(list,p:Nick()) end end
	if #list==0 then return end
	local lx,ly=ScrW()-200,40
	draw.RoundedBox(2,lx,ly,190,20+#list*16,Color(0,0,0,150))
	draw.SimpleText("spectators ("..#list..")","cm",lx+4,ly+3,Color(255,255,100),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	for i,n in ipairs(list) do draw.SimpleText(n,"cm",lx+4,ly+18+(i-1)*16,Color(255,255,255,200),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP) end
end)

-- Prop ESP
hook.Add("HUDPaint","cheat_propesp",function()
	if not cheat.propESP then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,p in ipairs(ents.FindByClass("prop_*")) do
		if IsValid(p) and p:GetClass()=="prop_physics" then
			local pos=p:GetPos()+p:OBBCenter() local px,py=cheat.W2S(pos)
			if px~=0 or py~=0 then
				local d=math.Round(lp:GetPos():Distance(p:GetPos()))
				if d<500 then draw.SimpleText(d.."m","cm",px,py,Color(255,180,0,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
			end
		end
	end
end)

-- NPC ESP (box + name + health for all NPCs)
hook.Add("HUDPaint","cheat_npcesp",function()
	if not cheat.npcESP then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,npc in ipairs(ents.FindByClass("npc_*")) do
		if IsValid(npc) and npc:GetClass()~="npc_think" and npc:Health()>0 then
			local top=npc:GetPos()+Vector(0,0,npc:OBBMaxs().z)
			local bot=npc:GetPos()
			local tx,ty=cheat.W2S(top)
			local bx,by=cheat.W2S(bot)
			if(tx==0 and ty==0)or(bx==0 and by==0) then goto skipnpc end
			local h=math.abs(ty-by)
			if h<5 then goto skipnpc end
			local w=h*0.6 local cx=(tx+bx)/2 local lx=cx-w/2 local topy=math.min(ty,by)
			local hp=npc:Health() local mhp=math.max(npc:GetMaxHealth(),1) local r=math.Clamp(hp/mhp,0,1)
			local hc=r>0.5 and Color(0,220,80)or(r>0.25 and Color(255,200,0)or Color(255,40,40))
			surface.SetDrawColor(255,100,0) surface.DrawOutlinedRect(lx,topy,w,h,1)
			surface.SetDrawColor(Color(0,0,0,160)) surface.DrawRect(lx-5,topy,3,h)
			surface.SetDrawColor(hc) surface.DrawRect(lx-5,topy+(h-h*r),3,h*r)
			draw.SimpleText(npc:GetClass(),"cm",cx,topy-6,Color(255,100,0,230),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText(hp.." hp","cm",cx,topy+h+4,hc,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			local d=math.Round(lp:GetPos():Distance(npc:GetPos()))
			draw.SimpleText(d.."m","cm",cx,topy+h+16,Color(180,180,180,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			::skipnpc::
		end
	end
end)

-- Entity ESP (SENTs, vehicles, brushes, etc)
hook.Add("HUDPaint","cheat_entityesp",function()
	if not cheat.entityESP then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,e in ipairs(ents.GetAll()) do
		if not IsValid(e) then goto skipent end
		local cls=e:GetClass()
		if cls:find("^npc_") or cls:find("^prop_") or cls==e:GetClass() and not cls:find("^func_") and not cls:find("^env_") and not cls:find("^info_") and not cls:find("^trigger_") and not cls:find("^player") then
			if not e:IsWorld() and e:EntIndex()>0 and e:GetPos():Distance(lp:GetPos())<800 then
				local isVeh=cls:find("^prop_vehicle") or cls:find("^vehicle_")
				local isSent=cls:find("^sent_")
				if isVeh or isSent then
					local pos=e:GetPos()+Vector(0,0,30)
					local px,py=cheat.W2S(pos)
					if px~=0 or py~=0 then
						local d=math.Round(lp:GetPos():Distance(e:GetPos()))
						local col=isVeh and Color(0,200,255) or Color(200,100,255)
						draw.SimpleText(cls,"cm",px,py-8,Color(col.r,col.g,col.b,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
						draw.SimpleText(d.."m","cm",px,py+8,Color(180,180,180,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
					end
				end
			end
		end
		::skipent::
	end
end)

-- Item ESP (dropped weapons, ammo, shipments, money, etc.)
hook.Add("HUDPaint","cheat_itemesp",function()
	if not cheat.itemESP then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local itemClasses={"weapon_*","item_*","ammo_*","shipment_*","money_*","dm_*","spawned_*","cs_*","zyb_*","DarkRP_*","magnet_*","gmod_*"}
	for _,pattern in ipairs(itemClasses) do
		for _,e in ipairs(ents.FindByClass(pattern)) do
			if not IsValid(e) then goto skipitem end
			if e:IsWorld() then goto skipitem end
			if e:EntIndex()<=0 then goto skipitem end
			local d=lp:GetPos():Distance(e:GetPos())
			if d>600 then goto skipitem end
			local pos=e:GetPos()+Vector(0,0,10)
			local px,py=cheat.W2S(pos)
			if px~=0 or py~=0 then
				local cls=e:GetClass()
				local printName=e.PrintName or cls
				draw.SimpleText(printName,"cm",px,py-6,Color(0,255,180,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
				draw.SimpleText(d.."m","cm",px,py+6,Color(180,180,180,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
			::skipitem::
		end
	end
end)

-- View angles display
hook.Add("HUDPaint","cheat_viewangles",function()
	if not cheat.viewangles then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local a=lp:EyeAngles()
	draw.SimpleText(string.format("yaw: %.1f  pitch: %.1f",a.yaw,a.pitch),"cm",ScrW()/2,ScrH()/2+30,Color(255,255,255,150),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
end)

-- Flashlight overlay
hook.Add("HUDPaint","cheat_flashlight",function()
	if not cheat.flashlight then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local cx,cy=ScrW()/2,ScrH()/2
	for i=5,1,-1 do surface.SetDrawColor(255,255,200,5) surface.DrawCircle(cx,cy,200*(i/5),Color(255,255,200,5)) end
end)

-- Toggle functions
function cheat.ToggleGod()
	cheat.god=not cheat.god
	RunConsoleCommand("god")
end

function cheat.ToggleNoClip()
	cheat.noclip=not cheat.noclip
	if cheat.noclip then
		hook.Add("Think","cheat_noclip",function()
			local lp=LocalPlayer()
			if IsValid(lp) and lp:Alive() then lp:SetMoveType(MOVETYPE_NOCLIP) end
		end)
	else
		hook.Remove("Think","cheat_noclip")
		local lp=LocalPlayer()
		if IsValid(lp) then lp:SetMoveType(MOVETYPE_WALK) end
	end
end

function cheat.ToggleFullbright()
	cheat.fullbright=not cheat.fullbright
	RunConsoleCommand("mat_fullbright",cheat.fullbright and "1" or "0")
end

function cheat.ToggleSpeed()
	cheat.speed=not cheat.speed
	if cheat.speed then
		hook.Add("Think","cheat_speed",function()
			if IsValid(LocalPlayer()) then LocalPlayer():SetRunSpeed(600) LocalPlayer():SetWalkSpeed(400) end
		end)
	else
		hook.Remove("Think","cheat_speed")
		if IsValid(LocalPlayer()) then LocalPlayer():SetRunSpeed(250) LocalPlayer():SetWalkSpeed(150) end
	end
end

function cheat.ToggleAimbot()
	cheat.aimbot=not cheat.aimbot
	if cheat.aimbot then
		hook.Add("CreateMove","cheat_aimbot",function(cmd)
			local lp=LocalPlayer() if not IsValid(lp) then return end
			local tgt=cheat.GetCrosshairTarget()
			if tgt and IsValid(tgt) then
				local aim=tgt:WorldSpaceCenter()
				if cheat.headshotonly then
					local bid=tgt:LookupBone("ValveBiped.Bip01_Head")
					if bid then aim=tgt:GetBonePosition(bid) end
				end
				local ang=(aim-lp:EyePos()):Angle()
				if cheat.aimbotSmooth>0 then
					local ca=cmd:GetViewAngles() local diff=ang-ca diff:Normalize() ang=ca+diff/cheat.aimbotSmooth
				end
				cmd:SetViewAngles(ang)
			end
		end)
	else
		hook.Remove("CreateMove","cheat_aimbot")
	end
end

function cheat.ToggleSpectate()
	cheat.spectate=not cheat.spectate
	if cheat.spectate then
		local tgt=cheat.GetCrosshairTarget()
		if tgt and IsValid(tgt) then LocalPlayer():Spectate(OBS_MODE_IN_EYE) LocalPlayer():SpectateEntity(tgt) end
	else
		LocalPlayer():Spectate(OBS_MODE_NONE) LocalPlayer():SpectateEntity(nil)
	end
end

function cheat.ToggleHitbox()
	cheat.hitbox=not cheat.hitbox
	if not cheat.hitbox then
		for _,p in ipairs(player.GetAll()) do
			if IsValid(p) and p~=LocalPlayer() then for i=0,p:GetBoneCount()-1 do p:ManipulateBoneScale(i,Vector(1,1,1)) end end
		end
	end
end

-- Hitbox Think
hook.Add("Think","cheat_hitbox",function()
	if not cheat.hitbox then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local s=cheat.hitboxScale
	for _,p in ipairs(player.GetAll()) do
		if IsValid(p) and p~=lp and p:Alive() then for i=0,p:GetBoneCount()-1 do p:ManipulateBoneScale(i,Vector(s,s,s)) end end
	end
end)

-- NPC Aimbot toggle
function cheat.ToggleNpcAimbot()
	cheat.npcAimbot=not cheat.npcAimbot
	if cheat.npcAimbot then
		hook.Add("CreateMove","cheat_npcaimbot",function(cmd)
			local lp=LocalPlayer() if not IsValid(lp) then return end
			local tgt=cheat.GetNPCrosshairTarget()
			if tgt and IsValid(tgt) then
				local aim=tgt:WorldSpaceCenter()
				if cheat.headshotonly then
					local bid=tgt:LookupBone("ValveBiped.Bip01_Head")
					if bid then aim=tgt:GetBonePosition(bid) end
				end
				local ang=(aim-lp:EyePos()):Angle()
				if cheat.npcAimbotSmooth>0 then
					local ca=cmd:GetViewAngles() local diff=ang-ca diff:Normalize() ang=ca+diff/cheat.npcAimbotSmooth
				end
				cmd:SetViewAngles(ang)
			end
		end)
	else
		hook.Remove("CreateMove","cheat_npcaimbot")
	end
end

-- NPC Hitbox expander toggle
function cheat.ToggleNpcHitbox()
	cheat.npcHitbox=not cheat.npcHitbox
	if not cheat.npcHitbox then
		for _,npc in ipairs(ents.FindByClass("npc_*")) do
			if IsValid(npc) then for i=0,npc:GetBoneCount()-1 do npc:ManipulateBoneScale(i,Vector(1,1,1)) end end
		end
	end
end

-- NPC Hitbox Think
hook.Add("Think","cheat_npchitbox",function()
	if not cheat.npcHitbox then return end
	local s=cheat.npcHitboxScale
	for _,npc in ipairs(ents.FindByClass("npc_*")) do
		if IsValid(npc) and npc:Health()>0 then for i=0,npc:GetBoneCount()-1 do npc:ManipulateBoneScale(i,Vector(s,s,s)) end end
	end
end)

-- Thirdperson
hook.Add("CalcView","cheat_thirdperson",function(ply,pos,ang,fov)
	if not cheat.thirdperson then return end
	return{origin=pos-ang:Forward()*cheat.tpDist,angles=ang,fov=fov,drawviewer=true}
end)

-- FOV Changer
hook.Add("CalcView","cheat_fov",function(ply,pos,ang,fov)
	if not cheat.fovChanger then return end
	return{origin=pos,angles=ang,fov=cheat.fovValue}
end)

-- Zoom Hack
hook.Add("CalcView","cheat_fovzoom",function(ply,pos,ang,fov)
	if not cheat.fovzoom then return end
	return{origin=pos,angles=ang,fov=cheat.fovzoomval}
end)

-- Remove shadows
hook.Add("Think","cheat_removeshadows",function()
	if cheat.removeshadows then render.SuppressEngineLighting(true) end
end)

-- Chat spam
timer.Create("cheat_chatspam",3,0,function()
	if cheat.chatspam then RunConsoleCommand("say",discordURL) end
end)

-- Rainbow
hook.Add("Think","cheat_rainbow",function()
	if not cheat.rainbow then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local t=RealTime()*100
	lp:SetColor(Color(math.sin(t)*127+128,math.sin(t+2)*127+128,math.sin(t+4)*127+128))
end)

-- No fog
hook.Add("Think","cheat_nofog",function()
	if cheat.nofog then render.FogMode(MATERIAL_FOG_NONE) end
end)

-- Wireframe
hook.Add("PostDrawOpaqueRenderables","cheat_wireframe",function()
	if cheat.wireframe then render.SetWireframeMaterial(1) end
end)

-- Night mode
hook.Add("Think","cheat_nightmode",function()
	if not cheat.nightmode then return end
	render.SetAmbientLight(cheat.nightmodeVal,cheat.nightmodeVal,cheat.nightmodeVal)
end)

-- Chams
hook.Add("PostDrawOpaqueRenderables","cheat_chams",function()
	if not cheat.chams then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	for _,p in ipairs(player.GetAll()) do
		if p~=lp and IsValid(p) and p:Alive() then
			local c=cheat.chamsColor
			render.SetColorModulation(c.r/255,c.g/255,c.b/255)
			p:DrawModel()
			render.SetColorModulation(1,1,1)
		end
	end
end)

-- No sky
hook.Add("Think","cheat_nosky",function()
	if cheat.nosky then render.Clear(0,0,0,255) end
end)

-- Hit sound
hook.Add("EntityTakeDamage","cheat_hitsound",function(victim,dmg)
	if not cheat.hitsound then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	if dmg:GetAttacker()==lp then surface.PlaySound("buttons/button15.wav") end
end)

-- ============ CreateMove HOOKS ============

-- Spinbot (server sees spin, client doesn't)
hook.Add("CreateMove","cheat_spinbot",function(cmd)
	if not cheat.spinbot then cheat.spinSavedAngles=nil return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	cheat.spinSavedAngles=cmd:GetViewAngles()
	local ang=cmd:GetViewAngles()
	ang.yaw=ang.yaw+cheat.spinSpeed
	cmd:SetViewAngles(ang)
end)

-- Spinbot view counter (client doesn't see spin)
hook.Add("CalcView","cheat_spinview",function(ply,pos,ang,fov)
	if not cheat.spinbot then return end
	local a=Angle(ang)
	a.yaw=a.yaw-cheat.spinSpeed
	return{origin=pos,angles=a,fov=fov}
end)

-- Recoil control (lock view angles to counteract punch)
hook.Add("CreateMove","cheat_recoil",function(cmd)
	if not cheat.recoil then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	if wep.GetNextPrimaryFire and wep:GetNextPrimaryFire()>CurTime() then return end
	cmd:SetViewAngles(cmd:GetViewAngles())
end)

-- No recoil (re-lock view angles each tick)
hook.Add("CreateMove","cheat_norecoil",function(cmd)
	if not cheat.norecoil then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	cmd:SetViewAngles(cmd:GetViewAngles())
end)

-- Rapid fire
hook.Add("CreateMove","cheat_rapidfire",function(cmd)
	if not cheat.rapidfire then return end
	if not cmd:KeyDown(IN_ATTACK) then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	wep:SetNextPrimaryFire(CurTime())
end)

-- Auto attack
hook.Add("CreateMove","cheat_autoattack",function(cmd)
	if not cheat.autoattack then return end
	cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
end)

-- Auto strafe
hook.Add("CreateMove","cheat_autostrafe",function(cmd)
	if not cheat.autostrafe then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	if not lp:OnGround() and cmd:KeyDown(IN_SPEED) then
		if cmd:GetMouseX()>0 then cmd:SetSideMove(400) elseif cmd:GetMouseX()<0 then cmd:SetSideMove(-400) end
	end
end)

-- Bunny hop
hook.Add("CreateMove","cheat_bunnyhop",function(cmd)
	if not cheat.bunnyhop and not cheat.bhopHold then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	if cmd:KeyDown(IN_JUMP) and not lp:OnGround() then cmd:RemoveKey(IN_JUMP) end
end)

-- Auto duck
hook.Add("CreateMove","cheat_duck",function(cmd)
	if not cheat.duck then return end
	cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_DUCK))
end)

-- Anti-aim
hook.Add("CreateMove","cheat_antiaim",function(cmd)
	if not cheat.antiaim then return end
	local ang=cmd:GetViewAngles()
	ang.yaw=ang.yaw+180
	ang.pitch=cheat.fakepitch and -89 or 89
	cmd:SetViewAngles(ang)
end)

-- ============ Think HOOKS ============

-- Infinite ammo (keep clip full every tick)
hook.Add("Think","cheat_infiniteammo",function()
	if not cheat.infiniteammo then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	wep:SetClip1(wep:GetMaxClip1())
end)

-- Infinite clip (clip never decreases)
hook.Add("Think","cheat_infiniteclip",function()
	if not cheat.infiniteclip then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	wep:SetClip1(wep:GetMaxClip1())
end)

-- No reload (cancel reload state every tick)
hook.Add("Think","cheat_noreload",function()
	if not cheat.noreload then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) then return end
	wep:SetClip1(wep:GetMaxClip1())
	wep:SetNextPrimaryFire(CurTime())
	wep:SetNextSecondaryFire(CurTime())
end)

-- Rocket launcher spam (rapid fire + infinite ammo + no reload for RPG)
hook.Add("Think","cheat_rocketspam",function()
	if not cheat.rocketspam then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass()~="weapon_rpg" then return end
	wep:SetClip1(wep:GetMaxClip1())
	wep:SetNextPrimaryFire(CurTime())
	wep:SetNextSecondaryFire(CurTime())
end)

hook.Add("CreateMove","cheat_rocketspam",function(cmd)
	if not cheat.rocketspam then return end
	local lp=LocalPlayer() if not IsValid(lp) then return end
	local wep=lp:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass()~="weapon_rpg" then return end
	wep:SetNextPrimaryFire(CurTime())
	wep:SetNextSecondaryFire(CurTime())
	wep:SetClip1(wep:GetMaxClip1())
	cmd:SetViewAngles(cmd:GetViewAngles())
end)

-- ============ KEY HANDLER ============
local keys={}
hook.Add("Think","cheat_keys",function()
	if not input then return end
	local binds={
		[KEY_F1]=function() cheat.esp=not cheat.esp end,
		[KEY_F2]=function() cheat.ToggleGod() end,
		[KEY_F3]=function() cheat.ToggleNoClip() end,
		[KEY_F4]=function() cheat.ToggleSpeed() end,
		[KEY_F5]=function() cheat.ToggleAimbot() end,
		[KEY_F6]=function() cheat.ToggleFullbright() end,
		[KEY_F7]=function() cheat.ToggleSpectate() end,
		[KEY_INSERT]=function() if IsValid(cheat._frame) then cheat.CloseMenu() else cheat.OpenMenu() end end,
	}
	for k,fn in pairs(binds) do
		local down=input.IsKeyDown(k)
		if down and not keys[k] then fn() end
		keys[k]=down
	end
end)

-- ============ MENU ============
local C={bg=Color(12,12,15),panel=Color(20,20,24),card=Color(26,26,32),accent=Color(0,195,255),accent2=Color(0,255,120),dim=Color(100,100,110),txt=Color(200,200,205),bright=Color(240,240,240),off=Color(50,50,56),red=Color(255,60,60),green=Color(0,220,100),purple=Color(88,101,242)}

function cheat.CloseMenu()
	if IsValid(cheat._frame) then cheat._frame:SetMouseInputEnabled(false) cheat._frame:Remove() cheat._frame=nil end
end

function cheat.OpenMenu()
	if IsValid(cheat._frame) then cheat.CloseMenu() return end
	local W,H=380,540 local sw,sh=ScrW(),ScrH()
	local titleH=30 local tabH=28
	local tabs={"combat","visuals","movement","misc"}
	local tabW=#tabs>0 and W/#tabs or W
	local activeTab=1
	local dragging,sx,sy=false,0,0

	local frame=vgui.Create("DPanel")
	frame:SetSize(W,H) frame:SetPos(sw-W-40,sh/2-H/2)
	frame:MakePopup() frame:SetKeyboardInputEnabled(false)
	cheat._frame=frame

	frame.Paint=function(self,w,h)
		draw.RoundedBox(8,0,0,w,h,C.bg)
		surface.SetDrawColor(C.accent) surface.DrawRect(0,0,1,h)
		draw.RoundedBoxEx(8,0,0,w,titleH,C.panel,true,true,false,false)
		surface.SetDrawColor(C.accent) surface.DrawRect(0,titleH-1,w,1)
		draw.SimpleText("larpwtf","cm_t",10,titleH/2,C.accent,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.RoundedBox(0,0,titleH,W,tabH,C.panel)
		surface.SetDrawColor(C.card) surface.DrawRect(0,titleH+tabH-1,W,1)
		for i,t in ipairs(tabs) do
			local tx=(i-1)*tabW
			if i==activeTab then
				draw.RoundedBox(0,tx,titleH+tabH-2,tabW,2,C.accent)
				draw.SimpleText(t,"cm",tx+tabW/2,titleH+tabH/2,C.bright,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(t,"cm",tx+tabW/2,titleH+tabH/2,C.dim,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
		end
	end

	frame.OnMousePressed=function(self,mc)
		if mc==MOUSE_LEFT then dragging=true local mx,my=gui.MousePos() local fx,fy=self:GetPos() sx,sy=mx-fx,my-fy end
	end
	frame.OnMouseReleased=function() dragging=false end
	frame.Think=function(self) if dragging then local mx,my=gui.MousePos() self:SetPos(mx-sx,my-sy) end end

	-- Tab buttons
	for i=1,#tabs do
		local btn=vgui.Create("DButton",frame)
		btn:SetPos((i-1)*tabW,titleH) btn:SetSize(tabW,tabH) btn:SetText("") btn.Paint=function() end
		btn.DoClick=function() activeTab=i Rebuild() end
	end

	local scrollStart=titleH+tabH
	local scroll=vgui.Create("DScrollPanel",frame)
	scroll:SetPos(0,scrollStart) scroll:SetSize(W,H-scrollStart)
	scroll.Paint=function(self,w,h) draw.RoundedBox(0,0,0,w,h,C.bg) end
	local sb=scroll:GetVBar() sb:SetWide(3)
	sb.Paint=function(self,w,h) draw.RoundedBox(1,0,0,w,h,C.panel) end
	sb.btnGrip.Paint=function(self,w,h) draw.RoundedBox(1,0,0,w,h,C.accent) end
	sb.btnUp.Paint=function() end sb.btnDown.Paint=function() end

	local contentW=W-16

	-- Helper: section header
	local function Section(y,label)
		local p2=vgui.Create("DPanel",scroll) p2:SetPos(8,y) p2:SetSize(contentW,22)
		p2.Paint=function(self,w,h) surface.SetDrawColor(C.accent) surface.DrawRect(0,5,2,h-10) draw.SimpleText("// "..label,"cm",8,h/2,C.accent,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER) end
		return y+26
	end

	-- Helper: toggle
	local function Toggle(y,label,key,func)
		local p2=vgui.Create("DPanel",scroll) p2:SetPos(8,y) p2:SetSize(contentW,26)
		p2.Paint=function(self,w,h)
			draw.SimpleText(label,"cm",4,h/2,C.txt,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			local val=cheat[key] local bw,bh=34,16 local bx=w-bw-4 local by=(h-bh)/2
			draw.RoundedBox(bh/2,bx,by,bw,bh,val and C.accent or C.off)
			local kx=val and(bx+bw-bh+2)or(bx+2)
			draw.RoundedBox(bh/2-1,kx,by+1,bh-2,bh-2,Color(255,255,255,val and 230 or 80))
		end
		local btn=vgui.Create("DButton",p2) btn:SetPos(0,0) btn:SetSize(contentW,26) btn:SetText("") btn.Paint=function() end
		btn.DoClick=function() if func then func() else cheat[key]=not cheat[key] end cheat.SyncServer(key,cheat[key]) end
		return y+28
	end

	-- Helper: slider
	local function Slider(y,label,key,min,max)
		local p2=vgui.Create("DPanel",scroll) p2:SetPos(8,y) p2:SetSize(contentW,38)
		p2.Paint=function(self,w,h)
			draw.SimpleText(label..": "..tostring(cheat[key]),"cm",4,6,C.dim,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		local sh2=22 local trackH=6 local knobR=7
		local slider=vgui.Create("DPanel",p2) slider:SetPos(0,sh2) slider:SetSize(contentW,trackH+knobR*2)
		slider:SetCursor("hand")
		slider.Paint=function(self,w,h)
			local ty=(h-trackH)/2
			draw.RoundedBox(3,0,ty,w,trackH,C.off)
			local pct=math.Clamp((cheat[key]-min)/(max-min),0,1)
			draw.RoundedBox(3,0,ty,w*pct,trackH,C.accent)
			local kx=pct*w draw.RoundedBox(knobR,kx-knobR,(h-knobR*2)/2,knobR*2,knobR*2,C.bright)
		end
		local held=false
		slider.OnMousePressed=function(self,mc) if mc==MOUSE_LEFT then held=true end end
		slider.OnMouseReleased=function() held=false end
		slider.Think=function(self)
			if held then
				local mx=self:ScreenToLocal(gui.MousePos())
				local pct=math.Clamp(mx/self:GetWide(),0,1)
				cheat[key]=math.Round(min+pct*(max-min))
			end
		end
		return y+40
	end

	-- Helper: action button
	local function ActionBtn(y,label,fn)
		local btn=vgui.Create("DButton",scroll) btn:SetPos(8,y) btn:SetSize(contentW,26)
		btn:SetText(label) btn:SetFont("cm") btn:SetTextColor(C.bg)
		btn.Paint=function(self,w,h) draw.RoundedBox(6,0,0,w,h,self:IsHovered() and C.accent2 or C.accent) end
		btn.DoClick=fn return y+30
	end

	-- Helper: info label
	local function Info(y,text,col)
		local lbl=vgui.Create("DLabel",scroll) lbl:SetPos(12,y) lbl:SetText(text) lbl:SetFont("cm") lbl:SetTextColor(col or C.dim) lbl:SizeToContents() return y+16
	end

	-- Helper: blank spacer
	local function Spacer(y,h) return y+(h or 4) end

	-- Discord button
	local function DiscordBtn(y)
		local btn=vgui.Create("DButton",scroll) btn:SetPos(8,y) btn:SetSize(contentW,30)
		btn:SetText("") btn.Paint=function(self,w,h)
			local col=self:IsHovered() and C.purple or Color(70,80,200)
			draw.RoundedBox(6,0,0,w,h,col)
			draw.SimpleText(">> discord.gg/larpwtf <<","cm",w/2,h/2,C.bright,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		btn.DoClick=function() gui.OpenURL("https://"..cheat.DiscordURL) end return y+34
	end

	local TABS={}
	TABS[1]=function()
		local y=6
		y=Section(y,"aimbot")
		y=Toggle(y,"aimbot [F5]","aimbot",function() cheat.ToggleAimbot() end)
		y=Slider(y,"aimbot fov","aimbotFov",1,180)
		y=Slider(y,"aimbot smooth","aimbotSmooth",0,20)
		y=Toggle(y,"headshot only","headshotonly")
		y=Toggle(y,"show fov circle","showFov")
		y=Toggle(y,"recoil control","recoil")
		y=Section(y,"rage")
		y=Toggle(y,"spinbot","spinbot")
		y=Slider(y,"spin speed","spinSpeed",1,50)
		y=Toggle(y,"anti-aim","antiaim")
		y=Toggle(y,"fake pitch","fakepitch")
		y=Section(y,"weapon mods")
		y=Toggle(y,"rapid fire","rapidfire")
		y=Toggle(y,"infinite ammo","infiniteammo")
		y=Toggle(y,"no recoil","norecoil")
		y=Toggle(y,"infinite clip","infiniteclip")
		y=Toggle(y,"auto attack","autoattack")
		y=Toggle(y,"rocket launcher spam","rocketspam")
		y=Toggle(y,"no reload","noreload")
		y=Section(y,"automation")
		y=Toggle(y,"auto duck","duck")
		y=Toggle(y,"auto strafe","autostrafe")
		y=Toggle(y,"bunny hop","bunnyhop")
		y=Toggle(y,"team aimbot","teamaimbot")
		y=Section(y,"npc")
		y=Toggle(y,"npc aimbot","npcAimbot",function() cheat.ToggleNpcAimbot() end)
		y=Slider(y,"npc aimbot fov","npcAimbotFov",1,180)
		y=Slider(y,"npc aimbot smooth","npcAimbotSmooth",0,20)
	end

	TABS[2]=function()
		local y=6
		y=Section(y,"player esp")
		y=Toggle(y,"esp [F1]","esp")
		y=Toggle(y,"boxes","espBoxes")
		y=Toggle(y,"health bars","espHealth")
		y=Toggle(y,"names + hp + weapon","espNames")
		y=Toggle(y,"snaplines","espSnaplines")
		y=Toggle(y,"glow","glow")
		y=Section(y,"other esp")
		y=Toggle(y,"skeleton","skeleton")
		y=Toggle(y,"head circles","headcircle")
		y=Toggle(y,"3d snaplines","snaplines3d")
		y=Toggle(y,"name tags + dist","nametags")
		y=Toggle(y,"prop esp","propESP")
		y=Toggle(y,"npc esp","npcESP")
		y=Toggle(y,"entity esp (vehicles, sents)","entityESP")
		y=Toggle(y,"item esp (weapons, ammo, etc)","itemESP")
		y=Toggle(y,"spectator list","spectatorlist")
		y=Section(y,"render")
		y=Toggle(y,"crosshair","crosshair")
		y=Slider(y,"crosshair size","crosshairSize",4,30)
		y=Toggle(y,"remove shadows","removeshadows")
		y=Toggle(y,"no fog","nofog")
		y=Toggle(y,"no sky","nosky")
		y=Toggle(y,"fullbright [F6]","fullbright",function() cheat.ToggleFullbright() end)
		y=Toggle(y,"wireframe","wireframe")
		y=Toggle(y,"night mode","nightmode")
		y=Slider(y,"night brightness","nightmodeVal",0,1)
		y=Toggle(y,"chams","chams")
		y=Toggle(y,"rainbow player","rainbow")
		y=Toggle(y,"hit sound","hitsound")
		y=Toggle(y,"view angles","viewangles")
		y=Toggle(y,"flashlight overlay","flashlight")
		y=Section(y,"model")
		y=Toggle(y,"hitbox expander","hitbox",function() cheat.ToggleHitbox() end)
		y=Slider(y,"hitbox scale","hitboxScale",1,10)
		y=Toggle(y,"npc hitbox expander","npcHitbox",function() cheat.ToggleNpcHitbox() end)
		y=Slider(y,"npc hitbox scale","npcHitboxScale",1,10)
	end

	TABS[3]=function()
		local y=6
		y=Section(y,"movement [singleplayer]")
		y=Toggle(y,"god mode [F2]","god",function() cheat.ToggleGod() end)
		y=Toggle(y,"noclip [F3]","noclip",function() cheat.ToggleNoClip() end)
		y=Toggle(y,"speed boost [F4]","speed",function() cheat.ToggleSpeed() end)
		y=Toggle(y,"spectate [F7]","spectate",function() cheat.ToggleSpectate() end)
		y=Section(y,"movement")
		y=Toggle(y,"thirdperson","thirdperson")
		y=Slider(y,"tp distance","tpDist",30,200)
		y=Toggle(y,"fov changer","fovChanger")
		y=Slider(y,"fov value","fovValue",60,160)
		y=Toggle(y,"zoom hack","fovzoom")
		y=Slider(y,"zoom fov","fovzoomval",10,80)
	end

	TABS[4]=function()
		local y=6
		y=DiscordBtn(y)
		y=Section(y,"fun")
		y=Toggle(y,"chat spam","chatspam")
		y=Section(y,"info")
		y=Info(y,"F1-F7  =  quick toggles")
		y=Info(y,"INSERT  =  open/close menu")
		y=Info(y,"server-side features need cheat_server.lua in autorun/",C.green)
		y=Spacer(y,4)
		y=Section(y,"quick")
		y=ActionBtn(y,"ENABLE ALL",function()
			cheat.esp=true cheat.skeleton=true cheat.headcircle=true
			cheat.nametags=true cheat.crosshair=true cheat.watermark=true
			cheat.spectatorlist=true cheat.propESP=true
			cheat.rapidfire=true cheat.infiniteammo=true cheat.norecoil=true
			cheat.infiniteclip=true cheat.rocketspam=true cheat.noreload=true
			cheat.SyncServer("rapidfire",true) cheat.SyncServer("infiniteammo",true)
			cheat.SyncServer("norecoil",true) cheat.SyncServer("infiniteclip",true)
			cheat.SyncServer("rocketspam",true) cheat.SyncServer("noreload",true)
			if not cheat.god then cheat.ToggleGod() end
			if not cheat.noclip then cheat.ToggleNoClip() end
			if not cheat.aimbot then cheat.ToggleAimbot() end
		end)
		y=ActionBtn(y,"DISABLE ALL",function()
			cheat.esp=false cheat.skeleton=false cheat.headcircle=false
			cheat.nametags=false cheat.crosshair=false cheat.glow=false
			cheat.spinbot=false cheat.antiaim=false cheat.bunnyhop=false
			cheat.rainbow=false cheat.chatspam=false cheat.duck=false
			cheat.autostrafe=false cheat.thirdperson=false cheat.fovChanger=false
			cheat.nofog=false cheat.wireframe=false cheat.nightmode=false
			cheat.chams=false cheat.spectatorlist=false cheat.propESP=false
			cheat.hitsound=false cheat.nosky=false cheat.recoil=false
			cheat.showFov=false cheat.rapidfire=false cheat.infiniteammo=false
			cheat.norecoil=false cheat.infiniteclip=false cheat.autoattack=false
			cheat.fovzoom=false cheat.rocketspam=false cheat.noreload=false
cheat.npcESP=false cheat.entityESP=false cheat.itemESP=false
cheat.npcAimbot=false cheat.npcAimbotFov=30 cheat.npcAimbotSmooth=0
cheat.npcHitbox=false cheat.npcHitboxScale=3
			cheat.npcAimbot=false cheat.npcHitbox=false
			cheat.SyncServer("rapidfire",false) cheat.SyncServer("infiniteammo",false)
			cheat.SyncServer("norecoil",false) cheat.SyncServer("infiniteclip",false)
			cheat.SyncServer("rocketspam",false) cheat.SyncServer("noreload",false)
			if cheat.god then cheat.ToggleGod() end
			if cheat.noclip then cheat.ToggleNoClip() end
			if cheat.speed then cheat.ToggleSpeed() end
			if cheat.aimbot then cheat.ToggleAimbot() end
			if cheat.spectate then cheat.ToggleSpectate() end
			if cheat.npcAimbot then cheat.ToggleNpcAimbot() end
			if cheat.npcHitbox then cheat.ToggleNpcHitbox() end
		end)
	end

	function Rebuild() scroll:Clear() if TABS[activeTab] then TABS[activeTab]() end end
	Rebuild()
end

concommand.Add("cheat",function()
	if IsValid(cheat._frame) then cheat.CloseMenu() else cheat.OpenMenu() end
end)

print("[larpwtf] loaded. 'cheat' to open, INSERT to toggle")
