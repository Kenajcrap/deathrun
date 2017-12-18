DR.AnnouncerName = DR.AnnouncerName or "HELP" -- incase the file refreshes
DR.AnnouncerColor = DR.AnnouncerColor or DR.Colors.Text.Alizarin

function DR:SetAnnouncerName( name )
	DR.AnnouncerName = name
end

function DR:SetAnnouncerColor( col )
	DR.AnnouncerColor = col
end

function DR:SetAnnouncerTable( tbl )
	msgs = tbl
end

function DR:GetAnnouncerTable( )
	return msgs
end



local msgs = {}

msgs = {
	"Não hesite em pedir ajuda à staff, eles estão aqui para isso.",
	"Escreva !rtv para votar para a mudar o mapa.",
	"Escreva !crosshair para personalizar sua mira",
	"Mude a posição e o estilo do HUD apertando F2 ou escrevendo !settings.",
	"Mude por quanto tempo o nome dos players ficam na tela apertnado F2 ou escrevendo !settings.",
	"Botões são reservados automaticamente, só ande até eles!",
	"Sabia que as armas possuem padrões de tiro? Puxe a arma um pouco pra baixo ao atirar!",
	"Muta gente falando? Mute players apertando TAB.",
	"Desative estas mensagens apertando F2 ou escrevendo !settings",
	"Ative a terceira pessoa escrevendo !3p (e desative escrevendo !1p).",
	"Veja os recordes do mapa escrevendo !recordes",
	"Desconectar enquanto estiver nos Death não é permitido, e resultará em jogar mais um round como death!",
	"Cada arma melee conta com alguma propriedade expecial. Explore-as, algumas são muito boas!",
	"Criei uma interface nova para quem gosta de pegar recordes, se você nao liga para isso, pode voltar para a antiga no menu F2.",
	"O Preço das facas é proporcional ao preço real delas e é atualizado semanalmente.",
	"As áreas pintadas são colocadas para evitar que players usem bugs nos mapas. Cuidado!",
}

function DR:AddAnnouncement( ann )
	table.insert( msgs, ann or "Blank Announcement" )
end

local AnnouncementInterval = CreateClientConVar("deathrun_announcement_interval", 60, true, false)
local AnnouncementEnabled = CreateClientConVar("deathrun_enable_announcements", 1, true, false)

local idx = 1

local function DoAnnouncements()
	if AnnouncementEnabled:GetBool() == false then return end

	chat.AddText(DR.Colors.Text.Clouds, "[", DR.AnnouncerColor, DR.AnnouncerName, DR.Colors.Text.Clouds, "] "..(msgs[idx]))
	idx = idx + 1
	if idx > #msgs then idx = 1 end
end

cvars.AddChangeCallback( "deathrun_announcement_interval", function( name, old, new )
	timer.Destroy("DeathrunAnnouncementTimer")
	timer.Create("DeathrunAnnouncementTimer", new, 0, function()
		DoAnnouncements()
	end)
end, "DeathrunAnnouncementInterval")

timer.Create("DeathrunAnnouncementTimer", AnnouncementInterval:GetFloat(), 0, function()
	DoAnnouncements()
end)