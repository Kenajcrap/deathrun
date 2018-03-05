print("Loaded pointshop support...")

local hasPointshop = false
local hasPointshop2 = false
local hadRedactedHub = false

if PS then
	hasPointshop = true 
end
if RS then
	hasRedactedHub = true 
end
if Pointshop2 then
	hasPointshop2 = true
end

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE

local PointshopFinishReward = CreateConVar("deathrun_pointshop_finish_reward", 10, defaultFlags, "How many points to award the player when he finishes the map." )
local PointshopKillReward = CreateConVar("deathrun_pointshop_kill_reward", 5, defaultFlags, "How many points to award the player when they kill another player." )
local PointshopWinReward = CreateConVar("deathrun_pointshop_win_reward", 3, defaultFlags, "How many points to award the player when their team wins." )
local PointshopSuicideReward = CreateConVar("deathrun_pointshop_Suicide_reward", 1, defaultFlags, "How many points to award the player the other teams player suicides" )
local PointshopRewardMessage = CreateConVar("deathrun_pointshop_notify", 1, defaultFlags, "Enable chat messages or notifications when rewards are received - does not work for PS2")

if SERVER then

	function DR:GetMultiplier( ply )
		local pmulti = sql.Query( "SELECT pmultiplier FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'") or {[1]={["pmultiplier"] = "1"}}
		return tonumber(pmulti[1]["pmultiplier"])
	end

	function DR:RewardPlayer( ply, amt, reason, premium )
		amt = amt or 0
		if hasPointshop then
			ply:PS_GivePoints( amt )
			if PointshopRewardMessage:GetBool() then
				ply:PS_Notify("Foram dados "..tostring( amt ).." pontos a você por "..(reason or "jogar").."!")
			end
		end
		if hasRedactedHub then
			local storemoney = RS:GetStoreMoney() or 0
			if amt <= storemoney then
				ply:AddMoney( amt )
				RS:SubStoreMoney( amt )
				if PointshopRewardMessage:GetBool() then
					ply:DeathrunChatPrint("You were given "..tostring( amt ).." points for "..(reason or "playing").."!")
				end
			else
				if PointshopRewardMessage:GetBool() then
					ply:DeathrunChatPrint("Unfortunately the store does not have enough points to reward you.")
				end
			end			
		end
		if hasPointshop2 then
			--if PointshopRewardMessage:GetBool() then
			if premium == true then
			ply:PS2_AddPremiumPoints( amt, "Foram dadas "..tostring( amt ).." reliquias a você por "..(reason or "jogar").."!", true)
			else
			ply:PS2_AddStandardPoints( amt, "Foram dados "..tostring( amt ).." pontos a você por "..(reason or "jogar").."!", true)
			end
		end
	end


	hook.Add("DeathrunPlayerFinishMap", "PointshopRewards", function( ply, zname, z, place )
		DR:RewardPlayer( ply, math.Round(PointshopFinishReward:GetInt()*#player.GetAllPlaying()*DR:GetMultiplier(ply),0), " terminar o mapa")
	end)

	hook.Add("DeathrunPlayerGetMedal", "PointshopReward", function (ply, type, reward, bonus)
		DR:RewardPlayer( ply, math.Round(tonumber(bonus)*#player.GetAllPlaying()*DR:GetMultiplier(ply),0), "obter a medalha de "..type.."!")
		DR:RewardPlayer( ply, tonumber(reward), "obter a medalha de "..type.."!", true)
	end)

	hook.Add("PlayerDeath", "PointshopRewards", function( ply, inflictor, attacker )
		if attacker:IsPlayer() then
			if ply:Team() ~= attacker:Team() then
				DR:RewardPlayer( attacker, math.Round(	PointshopKillReward:GetInt()*#player.GetAllPlaying()*DR:GetMultiplier(attacker),0), " matar "..ply:Nick())
			end
		else
			if ply:Team() == TEAM_RUNNER then
				for k,v in ipairs( team.GetPlayers(TEAM_DEATH)) do 
					DR:RewardPlayer( v, math.Round(PointshopSuicideReward:GetInt()*#team.GetPlayers(TEAM_RUNNER)*DR:GetMultiplier(v),0), ply:Nick().." se suicidar")
				end
			end
			if ply:Team() == TEAM_DEATH then
				for k,v in ipairs( team.GetPlayers(TEAM_RUNNER)) do
					DR:RewardPlayer( v, math.Round(PointshopSuicideReward:GetInt()*#team.GetPlayers(TEAM_DEATH)*DR:GetMultiplier(v),0), ply:Nick().." se suicidar")
				end
			end
		end
	end)

	hook.Add("DeathrunRoundWin", "PointshopRewards", function( winner )
		for k,v in ipairs( player.GetAllPlaying() ) do
			if v:Team() == winner then
				DR:RewardPlayer( v, PointshopWinReward:GetInt()*#player.GetAllPlaying()*DR:GetMultiplier(v), "vencer o round")
			end
		end
	end)
end