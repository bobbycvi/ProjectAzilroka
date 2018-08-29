local PA = _G.ProjectAzilroka
local QS = PA:NewModule('QuestSounds', 'AceEvent-3.0')
PA.QS = QS

QS.Title = '|cFF16C3F2Quest|r|cFFFFFFFFSounds|r'
QS.Description = 'Audio for Quest Progress & Completions.'
QS.Authors = 'Azilroka'

local GetNumQuestLeaderBoards, GetQuestLogLeaderBoard, GetQuestLogTitle, PlaySoundFile = GetNumQuestLeaderBoards, GetQuestLogLeaderBoard, GetQuestLogTitle, PlaySoundFile

function QS:CountCompletedObjectives(index)
	local Completed, Total = 0, GetNumQuestLeaderBoards(index)
	for i = 1, Total do
		local _, _, Finished = GetQuestLogLeaderBoard(i, index)
		if Finished then
			Completed = Completed + 1
		end
	end

	return Completed, Total
end

function QS:SetQuest(index)
	self.QuestIndex = index
	if index > 0 then
		local _, _, _, _, _, _, _, id = GetQuestLogTitle(index)
		self.QuestID = id
		if id and id > 0 then
			self.ObjectivesCompleted, self.ObjectivesTotal = QS:CountCompletedObjectives(index)
		end
	end
end

function QS:PlaySoundFile(file)
	if file == nil or file == '' then
		return
	end

	PlaySoundFile(PA.LSM:Fetch('sound', file))
end

function QS:CheckQuest()
	if self.QuestIndex > 0 then
		local index = self.QuestIndex
		local _, _, _, _, _, _, _, id = GetQuestLogTitle(index)
		if id == self.QuestID then
			self.ObjectivesCompleted, self.ObjectivesTotal = QS:CountCompletedObjectives(index)
			if self.ObjectivesCompleted == self.ObjectivesTotal then
				QS:PlaySoundFile(self.db.QuestComplete)
			elseif self.ObjectivesCompleted > self.ObjectivesTotal then
				QS:PlaySoundFile(self.db.ObjectiveComplete)
			else
				QS:PlaySoundFile(self.db.ObjectiveProgress)
			end
		end
		self.QuestIndex = 0
	end
end

function QS:UNIT_QUEST_LOG_CHANGED(event, unit)
	if unit == "player" then
		QS:CheckQuest()
	end
end

function QS:QUEST_WATCH_UPDATE(event, index)
	QS:SetQuest(index)
end

function QS:GetOptions()
	local Options = {
		type = 'group',
		name = QS.Title,
		desc = QS.Description,
		order = 219,
		get = function(info) return QS.db[info[#info]] end,
		set = function(info, value) QS.db[info[#info]] = value end,
		args = {
			Header = {
				order = 0,
				type = 'header',
				name = PA:Color(QS.Title),
			},
			QuestComplete = {
				type = "select", dialogControl = 'LSM30_Sound',
				order = 1,
				name = 'Quest Complete',
				values = PA.LSM:HashTable('sound'),
			},
			ObjectiveComplete = {
				type = "select", dialogControl = 'LSM30_Sound',
				order = 2,
				name = 'Objective Complete',
				values = PA.LSM:HashTable('sound'),
			},
			ObjectiveProgress = {
				type = "select", dialogControl = 'LSM30_Sound',
				order = 3,
				name = 'Objective Progress',
				values = PA.LSM:HashTable('sound'),
			},
			AuthorHeader = {
				order = 11,
				type = 'header',
				name = PA.ACL['Authors:'],
			},
			Authors = {
				order = 12,
				type = 'description',
				name = QS.Authors,
				fontSize = 'large',
			},
		},
	}

	Options.args.profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(QS.data)
	Options.args.profiles.order = -2

	PA.Options.args.QuestSounds = Options
end

function QS:BuildProfile()
	self.data = PA.ADB:New('QuestSoundsDB', {
		profile = {
			['QuestComplete'] = 'Peon Quest Complete',
			['ObjectiveComplete'] = 'Peon Objective Complete',
			['ObjectiveProgress'] = 'Peon Objective Progress',
		},
	}, true)
	self.data.RegisterCallback(self, 'OnProfileChanged', 'SetupProfile')
	self.data.RegisterCallback(self, 'OnProfileCopied', 'SetupProfile')
	self.db = self.data.profile
end

function QS:SetupProfile()
	self.db = self.data.profile
end

function QS:RegisterSounds()
	PA.LSM:Register("sound", "Rubber Ducky", [[Sound\Doodad\Goblin_Lottery_Open01.ogg]])
	PA.LSM:Register("sound", "Cartoon FX", [[Sound\Doodad\Goblin_Lottery_Open03.ogg]])
	PA.LSM:Register("sound", "Explosion", [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.ogg]])
	PA.LSM:Register("sound", "Shing!", [[Sound\Doodad\PortcullisActive_Closed.ogg]])
	PA.LSM:Register("sound", "Wham!", [[Sound\Doodad\PVP_Lordaeron_Door_Open.ogg]])
	PA.LSM:Register("sound", "Simon Chime", [[Sound\Doodad\SimonGame_LargeBlueTree.ogg]])
	PA.LSM:Register("sound", "War Drums", [[Sound\Event Sounds\Event_wardrum_ogre.ogg]])
	PA.LSM:Register("sound", "Cheer", [[Sound\Event Sounds\OgreEventCheerUnique.ogg]])
	PA.LSM:Register("sound", "Humm", [[Sound\Spells\SimonGame_Visual_GameStart.ogg]])
	PA.LSM:Register("sound", "Short Circuit", [[Sound\Spells\SimonGame_Visual_BadPress.ogg]])
	PA.LSM:Register("sound", "Fel Portal", [[Sound\Spells\Sunwell_Fel_PortalStand.ogg]])
	PA.LSM:Register("sound", "Fel Nova", [[Sound\Spells\SeepingGaseous_Fel_Nova.ogg]])
	PA.LSM:Register("sound", "You Will Die!", [[Sound\Creature\CThun\CThunYouWillDIe.ogg]])
	PA.LSM:Register("sound", 'Gong Quest Complete', [[Sound\Doodad\G_GongTroll01.ogg]])
	PA.LSM:Register("sound", 'Gong Objective Complete', [[Sound\Doodad\G_BearTrapReverse_Close01.ogg]])
	PA.LSM:Register("sound", 'Gong Objective Progress', [[Sound\Spells\Bonk1.ogg]])
	PA.LSM:Register("sound", 'Wacky Quest Complete', [[Sound\Doodad\Goblin_Lottery_Open02.ogg]])
	PA.LSM:Register("sound", 'Wacky Objectives Complete', [[Sound\Events\UD_DiscoBallSpawn.ogg]])
	PA.LSM:Register("sound", 'Wacky Objective Progress', [[Sound\Doodad\Goblin_Lottery_Open02.ogg]])
	PA.LSM:Register("sound", 'Creature Quest Complete', [[Sound\Creature\Chicken\ChickenDeathA.ogg]])
	PA.LSM:Register("sound", 'Creature Objective Complete', [[Sound\Creature\Frog\FrogFootstep2.ogg]])
	PA.LSM:Register("sound", 'Creature Objective Progress', [[Sound\Creature\Crab\CrabWoundC.ogg]])
	PA.LSM:Register("sound", 'Peon Quest Complete', [[Sound\Creature\Peon\PeonBuildingComplete1.ogg]])
	PA.LSM:Register("sound", 'Peon Objective Complete', [[Sound\Creature\Peon\PeonReady1.ogg]])
	PA.LSM:Register("sound", 'Peon Objective Progress', [[Sound\Creature\Peasant\PeasantWhat3.ogg]])
	PA.LSM:Register("sound", 'QuestGuru Quest Complete', [[Sound\Interface\levelup2.ogg]])
	PA.LSM:Register("sound", 'QuestGuru Objective Complete', [[Sound\Interface\AuctionWindowClose.ogg]])
	PA.LSM:Register("sound", 'QuestGuru Objective Progress', [[Sound\Interface\AuctionWindowOpen.ogg]])
end

function QS:Initialize()
	QS:RegisterSounds()

	QS:BuildProfile()
	QS:GetOptions()

	QS:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
	QS:RegisterEvent('QUEST_WATCH_UPDATE')

	QS.QuestIndex = 0
	QS.QuestID = 0
	QS.ObjectivesComplete = 0
	QS.ObjectivesTotal = 0
end