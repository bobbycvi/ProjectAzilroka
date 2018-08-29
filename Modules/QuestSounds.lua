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

	PlaySoundFile(file)
end

function QS:CheckQuest()
	if self.QuestIndex > 0 then
		local index = self.QuestIndex
		local _, _, _, _, _, _, _, id = GetQuestLogTitle(index)
		if id == self.QuestID then
			self.ObjectivesCompleted, self.ObjectivesTotal = QS:CountCompletedObjectives(index)
			print(self.ObjectivesCompleted, self.ObjectivesTotal)
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

	for Key, Option in pairs({ 'QuestComplete', 'ObjectiveComplete', 'ObjectiveProgress' }) do
		Options.args[Option] = {
			name = Option,
			order = Key,
			type = 'select',
			values = {
				["Sound/Doodad/G_GongTroll01.ogg"] = 'Gong Quest Complete',
				["Sound/Doodad/G_BearTrapReverse_Close01.ogg"] = 'Gong Objective Complete',
				["Sound/Spells/Bonk1.ogg"] = 'Gong Objective Progress',
				["Sound/Doodad/Goblin_Lottery_Open02.ogg"] = 'Wacky Quest Complete',
				["Sound/Events/UD_DiscoBallSpawn.ogg"] = 'Wacky Objectives Complete',
--				["Sound/Doodad/Goblin_Lottery_Open02.ogg"] = 'Wacky Objective Progress',
				["Sound/Creature/Chicken/ChickenDeathA.ogg"] = 'Creature Quest Complete',
				["Sound/Creature/Frog/FrogFootstep2.ogg"] = 'Creature Objective Complete',
				["Sound/Creature/Crab/CrabWoundC.ogg"] = 'Creature Objective Progress',
				["Sound/Creature/Peon/PeonBuildingComplete1.ogg"] = 'Peon Quest Complete',
				["Sound/Creature/Peon/PeonReady1.ogg"] = 'Peon Objective Complete',
				["Sound/Creature/Peasant/PeasantWhat3.ogg"] = 'Peon Objective Progress',
			},
		}
	end

	Options.args.profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(QS.data)
	Options.args.profiles.order = -2

	PA.Options.args.QuestSounds = Options
end

function QS:BuildProfile()
	self.data = PA.ADB:New('QuestSoundsDB', {
		profile = {
			['QuestComplete'] = "Sound/Creature/Peon/PeonBuildingComplete1.ogg",
			['ObjectiveComplete'] = "Sound/Creature/Peon/PeonReady1.ogg",
			['ObjectiveProgress'] = "Sound/Creature/Peasant/PeasantWhat3.ogg",
		},
	}, true)
	self.data.RegisterCallback(self, 'OnProfileChanged', 'SetupProfile')
	self.data.RegisterCallback(self, 'OnProfileCopied', 'SetupProfile')
	self.db = self.data.profile
end

function QS:SetupProfile()
	self.db = self.data.profile
end

function QS:Initialize()
	QS:BuildProfile()
	QS:GetOptions()

	QS:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
	QS:RegisterEvent('QUEST_WATCH_UPDATE')

	QS.QuestIndex = 0
	QS.QuestID = 0
	QS.ObjectivesComplete = 0
	QS.ObjectivesTotal = 0
end
