--[[
Name: LibBabble-Boss-3.0
Revision: $Rev: 88 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Description: A library to provide localizations for bosses.
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "DPSBabble-Boss-3.1"
local MINOR_VERSION = tonumber(("$Revision: 89 $"):match("%d+"))+90000

-- #AUTODOC_NAMESPACE prototype

local GAME_LOCALE = GetLocale()
do
	-- LibBabble-Core-3.0 is hereby placed in the Public Domain
	-- Credits: ckknight
	local LIBBABBLE_MAJOR, LIBBABBLE_MINOR = "DPSBabble-3.1", 2

	local LibBabble = LibStub:NewLibrary(LIBBABBLE_MAJOR, LIBBABBLE_MINOR)
	if LibBabble then
		local data = LibBabble.data or {}
		for k,v in pairs(LibBabble) do
			LibBabble[k] = nil
		end
		LibBabble.data = data

		local tablesToDB = {}
		for namespace, db in pairs(data) do
			for k,v in pairs(db) do
				tablesToDB[v] = db
			end
		end
		
		local function warn(message)
			--local _, ret = pcall(error, message, 3)
			--geterrorhandler()(ret)
		end

		local lookup_mt = { __index = function(self, key)
			local db = tablesToDB[self]
			local current_key = db.current[key]
			if current_key then
				self[key] = current_key
				return current_key
			end
			local base_key = db.base[key]
			local real_MAJOR_VERSION
			for k,v in pairs(data) do
				if v == db then
					real_MAJOR_VERSION = k
					break
				end
			end
			if not real_MAJOR_VERSION then
				real_MAJOR_VERSION = LIBBABBLE_MAJOR
			end
			if base_key then
				--warn(("%s: Translation %q not found for locale %q"):format(real_MAJOR_VERSION, key, GAME_LOCALE))
				rawset(self, key, base_key)
				return base_key
			end
			--warn(("%s: Translation %q not found."):format(real_MAJOR_VERSION, key))
			rawset(self, key, key)
			return key
		end }

		local function initLookup(module, lookup)
			local db = tablesToDB[module]
			for k in pairs(lookup) do
				lookup[k] = nil
			end
			setmetatable(lookup, lookup_mt)
			tablesToDB[lookup] = db
			db.lookup = lookup
			return lookup
		end

		local function initReverse(module, reverse)
			local db = tablesToDB[module]
			for k in pairs(reverse) do
				reverse[k] = nil
			end
			for k,v in pairs(db.current) do
				reverse[v] = k
			end
			tablesToDB[reverse] = db
			db.reverse = reverse
			db.reverseIterators = nil
			return reverse
		end

		local prototype = {}
		local prototype_mt = {__index = prototype}
		function prototype:GetLookupTable()
			local db = tablesToDB[self]

			local lookup = db.lookup
			if lookup then
				return lookup
			end
			return initLookup(self, {})
		end
		function prototype:GetUnstrictLookupTable()
			local db = tablesToDB[self]

			return db.current
		end
		function prototype:GetBaseLookupTable()
			local db = tablesToDB[self]

			return db.base
		end
		function prototype:GetReverseLookupTable()
			local db = tablesToDB[self]

			local reverse = db.reverse
			if reverse then
				return reverse
			end
			return initReverse(self, {})
		end
		local blank = {}
		local weakVal = {__mode='v'}
		function prototype:GetReverseIterator(key)
			local db = tablesToDB[self]
			local reverseIterators = db.reverseIterators
			if not reverseIterators then
				reverseIterators = setmetatable({}, weakVal)
				db.reverseIterators = reverseIterators
			elseif reverseIterators[key] then
				return pairs(reverseIterators[key])
			end
			local t
			for k,v in pairs(db.current) do
				if v == key then
					if not t then
						t = {}
					end
					t[k] = true
				end
			end
			reverseIterators[key] = t or blank
			return pairs(reverseIterators[key])
		end
		function prototype:Iterate()
			local db = tablesToDB[self]

			return pairs(db.current)
		end

		-- #NODOC
		-- modules need to call this to set the base table
		function prototype:SetBaseTranslations(base)
			local db = tablesToDB[self]
			local oldBase = db.base
			if oldBase then
				for k in pairs(oldBase) do
					oldBase[k] = nil
				end
				for k, v in pairs(base) do
					oldBase[k] = v
				end
				base = oldBase
			else
				db.base = base
			end
			for k,v in pairs(base) do
				if v == true then
					base[k] = k
				end
			end
		end

		local function init(module)
			local db = tablesToDB[module]
			if db.lookup then
				initLookup(module, db.lookup)
			end
			if db.reverse then
				initReverse(module, db.reverse)
			end
			db.reverseIterators = nil
		end

		-- #NODOC
		-- modules need to call this to set the current table. if current is true, use the base table.
		function prototype:SetCurrentTranslations(current)
			local db = tablesToDB[self]
			if current == true then
				db.current = db.base
			else
				local oldCurrent = db.current
				if oldCurrent then
					for k in pairs(oldCurrent) do
						oldCurrent[k] = nil
					end
					for k, v in pairs(current) do
						oldCurrent[k] = v
					end
					current = oldCurrent
				else
					db.current = current
				end
			end
			init(self)
		end

		for namespace, db in pairs(data) do
			setmetatable(db.module, prototype_mt)
			init(db.module)
		end

		-- #NODOC
		-- modules need to call this to create a new namespace.
		function LibBabble:New(namespace, minor)
			local module, oldminor = LibStub:NewLibrary(namespace, minor)
			if not module then
				return
			end

			if not oldminor then
				local db = {
					module = module,
				}
				data[namespace] = db
				tablesToDB[module] = db
			else
				for k,v in pairs(module) do
					module[k] = nil
				end
			end

			setmetatable(module, prototype_mt)

			return module
		end
	end
end

local lib = LibStub("DPSBabble-3.1"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then
	return
end

lib:SetBaseTranslations {
--Ahn'Qiraj
	["Anubisath Defender"] = true,
	["Battleguard Sartura"] = true,
	["C'Thun"] = true,
	["Emperor Vek'lor"] = true,
	["Emperor Vek'nilash"] = true,
	["Eye of C'Thun"] = true,
	["Fankriss the Unyielding"] = true,
	["Lord Kri"] = true,
	["Ouro"] = true,
	["Princess Huhuran"] = true,
	["Princess Yauj"] = true,
	["The Bug Family"] = true,
	["The Prophet Skeram"] = true,
	["The Twin Emperors"] = true,
	["Vem"] = true,
	["Viscidus"] = true,

--Auchindoun
--Auchenai Crypts
	["Exarch Maladaar"] = true,
	["Shirrak the Dead Watcher"] = true,
--Mana-Tombs
	["Nexus-Prince Shaffar"] = true,
	["Pandemonius"] = true,
	["Tavarok"] = true,
--Shadow Labyrinth
	["Ambassador Hellmaw"] = true,
	["Blackheart the Inciter"] = true,
	["Grandmaster Vorpil"] = true,
	["Murmur"] = true,
--Sethekk Halls
	["Anzu"] = true,
	["Darkweaver Syth"] = true,
	["Talon King Ikiss"] = true,

--Blackfathom Deeps
	["Aku'mai"] = true,
	["Baron Aquanis"] = true,
	["Gelihast"] = true,
	["Ghamoo-ra"] = true,
	["Lady Sarevess"] = true,
	["Old Serra'kis"] = true,
	["Twilight Lord Kelris"] = true,

--Blackrock Depths
	["Ambassador Flamelash"] = true,
	["Anger'rel"] = true,
	["Anub'shiah"] = true,
	["Bael'Gar"] = true,
	["Chest of The Seven"] = true,
	["Doom'rel"] = true,
	["Dope'rel"] = true,
	["Emperor Dagran Thaurissan"] = true,
	["Eviscerator"] = true,
	["Fineous Darkvire"] = true,
	["General Angerforge"] = true,
	["Gloom'rel"] = true,
	["Golem Lord Argelmach"] = true,
	["Gorosh the Dervish"] = true,
	["Grizzle"] = true,
	["Hate'rel"] = true,
	["Hedrum the Creeper"] = true,
	["High Interrogator Gerstahn"] = true,
	["High Priestess of Thaurissan"] = true,
	["Houndmaster Grebmar"] = true,
	["Hurley Blackbreath"] = true,
	["Lord Incendius"] = true,
	["Lord Roccor"] = true,
	["Magmus"] = true,
	["Ok'thor the Breaker"] = true,
	["Panzor the Invincible"] = true,
	["Phalanx"] = true,
	["Plugger Spazzring"] = true,
	["Princess Moira Bronzebeard"] = true,
	["Pyromancer Loregrain"] = true,
	["Ribbly Screwspigot"] = true,
	["Seeth'rel"] = true,
	["The Seven Dwarves"] = true,
	["Verek"] = true,
	["Vile'rel"] = true,
	["Warder Stilgiss"] = true,

--Blackrock Spire
--Lower
	["Bannok Grimaxe"] = true,
	["Burning Felguard"] = true,
	["Crystal Fang"] = true,
	["Ghok Bashguud"] = true,
	["Gizrul the Slavener"] = true,
	["Halycon"] = true,
	["Highlord Omokk"] = true,
	["Mor Grayhoof"] = true,
	["Mother Smolderweb"] = true,
	["Overlord Wyrmthalak"] = true,
	["Quartermaster Zigris"] = true,
	["Shadow Hunter Vosh'gajin"] = true,
	["Spirestone Battle Lord"] = true,
	["Spirestone Butcher"] = true,
	["Spirestone Lord Magus"] = true,
	["Urok Doomhowl"] = true,
	["War Master Voone"] = true,
--Upper
	["General Drakkisath"] = true,
	["Goraluk Anvilcrack"] = true,
	["Gyth"] = true,
	["Jed Runewatcher"] = true,
	["Lord Valthalak"] = true,
	["Pyroguard Emberseer"] = true,
	["Solakar Flamewreath"] = true,
	["The Beast"] = true,
	["Warchief Rend Blackhand"] = true,

--Blackwing Lair
	["Broodlord Lashlayer"] = true,
	["Chromaggus"] = true,
	["Ebonroc"] = true,
	["Firemaw"] = true,
	["Flamegor"] = true,
	["Grethok the Controller"] = true,
	["Lord Victor Nefarius"] = true,
	["Nefarian"] = true,
	["Razorgore the Untamed"] = true,
	["Vaelastrasz the Corrupt"] = true,

--Black Temple
	["Essence of Anger"] = true,
	["Essence of Desire"] = true,
	["Essence of Suffering"] = true,
	["Gathios the Shatterer"] = true,
	["Gurtogg Bloodboil"] = true,
	["High Nethermancer Zerevor"] = true,
	["High Warlord Naj'entus"] = true,
	["Illidan Stormrage"] = true,
	["Illidari Council"] = true,
	["Lady Malande"] = true,
	["Mother Shahraz"] = true,
	["Reliquary of Souls"] = true,
	["Shade of Akama"] = true,
	["Supremus"] = true,
	["Teron Gorefiend"] = true,
	["The Illidari Council"] = true,
	["Veras Darkshadow"] = true,

--Borean Tundra
--The Eye of Eternity
	["Malygos"] = true,
--The Nexus
	["Anomalus"] = true,
	["Grand Magus Telestra"] = true,
	["Keristrasza"] = true,
	["Ormorok the Tree-Shaper"] = true,
--The Oculus
	["Drakos the Interrogator"] = true,
	["Ley-Guardian Eregos"] = true,
	["Mage-Lord Urom"] = true,
	["Varos Cloudstrider"] = true,

--Caverns of Time
--Old Hillsbrad Foothills
	["Captain Skarloc"] = true,
	["Epoch Hunter"] = true,
	["Lieutenant Drake"] = true,
--The Culling of Stratholme
	["Meathook"] = true,
	["Chrono-Lord Epoch"] = true,
	["Mal'Ganis"] = true,
	["Salramm the Fleshcrafter"] = true,
--The Black Morass
	["Aeonus"] = true,
	["Chrono Lord Deja"] = true,
	["Medivh"] = true,
	["Temporus"] = true,

--Chamber of Aspects
--The Obsidian Sanctum
	["Sartharion"] = true,
	["Shadron"] = true,
	["Tenebron"] = true,
	["Vesperon"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
	["Coilfang Elite"] = true,
	["Coilfang Strider"] = true,
	["Fathom-Lord Karathress"] = true,
	["Hydross the Unstable"] = true,
	["Lady Vashj"] = true,
	["Leotheras the Blind"] = true,
	["Morogrim Tidewalker"] = true,
	["Pure Spawn of Hydross"] = true,
	["Shadow of Leotheras"] = true,
	["Tainted Spawn of Hydross"] = true,
	["The Lurker Below"] = true,
	["Tidewalker Lurker"] = true,
--The Slave Pens
	["Mennu the Betrayer"] = true,
	["Quagmirran"] = true,
	["Rokmar the Crackler"] = true,
	["Ahune"] = true,
--The Steamvault
	["Hydromancer Thespia"] = true,
	["Mekgineer Steamrigger"] = true,
	["Warlord Kalithresh"] = true,
--The Underbog
	["Claw"] = true,
	["Ghaz'an"] = true,
	["Hungarfen"] = true,
	["Overseer Tidewrath"] = true,
	["Swamplord Musel'ek"] = true,
	["The Black Stalker"] = true,

--Dire Maul
--Arena
	["Mushgog"] = true,
	["Skarr the Unbreakable"] = true,
	["The Razza"] = true,
--East
	["Alzzin the Wildshaper"] = true,
	["Hydrospawn"] = true,
	["Isalien"] = true,
	["Lethtendris"] = true,
	["Pimgib"] = true,
	["Pusillin"] = true,
	["Zevrim Thornhoof"] = true,
--North
	["Captain Kromcrush"] = true,
	["Cho'Rush the Observer"] = true,
	["Guard Fengus"] = true,
	["Guard Mol'dar"] = true,
	["Guard Slip'kik"] = true,
	["King Gordok"] = true,
	["Knot Thimblejack's Cache"] = true,
	["Stomper Kreeg"] = true,
--West
	["Illyanna Ravenoak"] = true,
	["Immol'thar"] = true,
	["Lord Hel'nurath"] = true,
	["Magister Kalendris"] = true,
	["Prince Tortheldrin"] = true,
	["Tendris Warpwood"] = true,
	["Tsu'zee"] = true,

--Dragonblight
-- Ahn'kahet: The Old Kingdom
	["Elder Nadox"] = true,
	["Herald Volazj"]=  true,
	["Jedoga Shadowseeker"] = true,
	["Prince Taldaram"] = true,
--Azjol-Nerub
	["Anub'arak"] = true,
	["Hadronox"] = true,
	["Krik'thir the Gatewatcher"] = true,

--Gnomeregan
	["Crowd Pummeler 9-60"] = true,
	["Dark Iron Ambassador"] = true,
	["Electrocutioner 6000"] = true,
	["Grubbis"] = true,
	["Mekgineer Thermaplugg"] = true,
	["Techbot"] = true,
	["Viscous Fallout"] = true,

--Grizzly Hills
--Drak'Tharon Keep
	["King Dred"] = true,
	["Novos the Summoner"] = true,
	["The Prophet Tharon'ja"] = true,
	["Trollgore"] = true,

--Gruul's Lair
	["Blindeye the Seer"] = true,
	["Gruul the Dragonkiller"] = true,
	["High King Maulgar"] = true,
	["Kiggler the Crazed"] = true,
	["Krosh Firehand"] = true,
	["Olm the Summoner"] = true,

--Hellfire Citadel
--Hellfire Ramparts
	["Nazan"] = true,
	["Omor the Unscarred"] = true,
	["Vazruden the Herald"] = true,
	["Vazruden"] = true,
	["Watchkeeper Gargolmar"] = true,
--Magtheridon's Lair
	["Hellfire Channeler"] = true,
	["Magtheridon"] = true,
--The Blood Furnace
	["Broggok"] = true,
	["Keli'dan the Breaker"] = true,
	["The Maker"] = true,
--The Shattered Halls
	["Blood Guard Porung"] = true,
	["Grand Warlock Nethekurse"] = true,
	["Warbringer O'mrogg"] = true,
	["Warchief Kargath Bladefist"] = true,

--Howling Fjord
--Utgarde Keep
	["Constructor & Controller"] = true, --these are one encounter, so we do this as an encounter name
	["Dalronn the Controller"] = true,
	["Ingvar the Plunderer"] = true,
	["Prince Keleseth"] = true,
	["Skarvald the Constructor"] = true,
--Utgarde Pinnacle
	["Skadi the Ruthless"] = true,
	["King Ymiron"] = true,
	["Svala Sorrowgrave"] = true,
	["Gortok Palehoof"] = true,

--Hyjal Summit
	["Anetheron"] = true,
	["Archimonde"] = true,
	["Azgalor"] = true,
	["Kaz'rogal"] = true,
	["Rage Winterchill"] = true,

--Karazhan
	["Arcane Watchman"] = true,
	["Attumen the Huntsman"] = true,
	["Chess Event"] = true,
	["Dorothee"] = true,
	["Dust Covered Chest"] = true,
	["Grandmother"] = true,
	["Hyakiss the Lurker"] = true,
	["Julianne"] = true,
	["Kil'rek"] = true,
	["King Llane Piece"] = true,
	["Maiden of Virtue"] = true,
	["Midnight"] = true,
	["Moroes"] = true,
	["Netherspite"] = true,
	["Nightbane"] = true,
	["Prince Malchezaar"] = true,
	["Restless Skeleton"] = true,
	["Roar"] = true,
	["Rokad the Ravager"] = true,
	["Romulo & Julianne"] = true,
	["Romulo"] = true,
	["Shade of Aran"] = true,
	["Shadikith the Glider"] = true,
	["Strawman"] = true,
	["Terestian Illhoof"] = true,
	["The Big Bad Wolf"] = true,
	["The Crone"] = true,
	["The Curator"] = true,
	["Tinhead"] = true,
	["Tito"] = true,
	["Warchief Blackhand Piece"] = true,

-- Magisters' Terrace
	--["Kael'thas Sunstrider"] = true,
	["Priestess Delrissa"] = true,
	["Selin Fireheart"] = true,
	["Vexallus"] = true,

--Maraudon
	["Celebras the Cursed"] = true,
	["Gelk"] = true,
	["Kolk"] = true,
	["Landslide"] = true,
	["Lord Vyletongue"] = true,
	["Magra"] = true,
	["Maraudos"] = true,
	["Meshlok the Harvester"] = true,
	["Noxxion"] = true,
	["Princess Theradras"] = true,
	["Razorlash"] = true,
	["Rotgrip"] = true,
	["Tinkerer Gizlock"] = true,
	["Veng"] = true,

--Molten Core
	["Baron Geddon"] = true,
	["Cache of the Firelord"] = true,
	["Garr"] = true,
	["Gehennas"] = true,
	["Golemagg the Incinerator"] = true,
	["Lucifron"] = true,
	["Magmadar"] = true,
	["Majordomo Executus"] = true,
	["Ragnaros"] = true,
	["Shazzrah"] = true,
	["Sulfuron Harbinger"] = true,

--Naxxramas
	["Anub'Rekhan"] = true,
	["Deathknight Understudy"] = true,
	["Feugen"] = true,
	["Four Horsemen Chest"] = true,
	["Gluth"] = true,
	["Gothik the Harvester"] = true,
	["Grand Widow Faerlina"] = true,
	["Grobbulus"] = true,
	["Heigan the Unclean"] = true,
	["Highlord Mograine"] = true,
	["Instructor Razuvious"] = true,
	["Kel'Thuzad"] = true,
	["Lady Blaumeux"] = true,
	["Loatheb"] = true,
	["Maexxna"] = true,
	["Noth the Plaguebringer"] = true,
	["Patchwerk"] = true,
	["Sapphiron"] = true,
	["Sir Zeliek"] = true,
	["Stalagg"] = true,
	["Thaddius"] = true,
	["Thane Korth'azz"] = true,
	["The Four Horsemen"] = true,

--Onyxia's Lair
	["Onyxia"] = true,

--Ragefire Chasm
	["Bazzalan"] = true,
	["Jergosh the Invoker"] = true,
	["Maur Grimtotem"] = true,
	["Taragaman the Hungerer"] = true,

--Razorfen Downs
	["Amnennar the Coldbringer"] = true,
	["Glutton"] = true,
	["Mordresh Fire Eye"] = true,
	["Plaguemaw the Rotting"] = true,
	["Ragglesnout"] = true,
	["Tuten'kash"] = true,

--Razorfen Kraul
	["Agathelos the Raging"] = true,
	["Blind Hunter"] = true,
	["Charlga Razorflank"] = true,
	["Death Speaker Jargba"] = true,
	["Earthcaller Halmgar"] = true,
	["Overlord Ramtusk"] = true,

--Ruins of Ahn'Qiraj
	["Anubisath Guardian"] = true,
	["Ayamiss the Hunter"] = true,
	["Buru the Gorger"] = true,
	["General Rajaxx"] = true,
	["Kurinnaxx"] = true,
	["Lieutenant General Andorov"] = true,
	["Moam"] = true,
	["Ossirian the Unscarred"] = true,

--Scarlet Monastery
--Armory
	["Herod"] = true,
--Cathedral
	["High Inquisitor Fairbanks"] = true,
	["High Inquisitor Whitemane"] = true,
	["Scarlet Commander Mograine"] = true,
--Graveyard
	["Azshir the Sleepless"] = true,
	["Bloodmage Thalnos"] = true,
	["Fallen Champion"] = true,
	["Interrogator Vishas"] = true,
	["Ironspine"] = true,
	["Headless Horseman"] = true,
--Library
	["Arcanist Doan"] = true,
	["Houndmaster Loksey"] = true,

--Scholomance
	["Blood Steward of Kirtonos"] = true,
	["Darkmaster Gandling"] = true,
	["Death Knight Darkreaver"] = true,
	["Doctor Theolen Krastinov"] = true,
	["Instructor Malicia"] = true,
	["Jandice Barov"] = true,
	["Kirtonos the Herald"] = true,
	["Kormok"] = true,
	["Lady Illucia Barov"] = true,
	["Lord Alexei Barov"] = true,
	["Lorekeeper Polkelt"] = true,
	["Marduk Blackpool"] = true,
	["Ras Frostwhisper"] = true,
	["Rattlegore"] = true,
	["The Ravenian"] = true,
	["Vectus"] = true,

--Shadowfang Keep
	["Archmage Arugal"] = true,
	["Arugal's Voidwalker"] = true,
	["Baron Silverlaine"] = true,
	["Commander Springvale"] = true,
	["Deathsworn Captain"] = true,
	["Fenrus the Devourer"] = true,
	["Odo the Blindwatcher"] = true,
	["Razorclaw the Butcher"] = true,
	["Wolf Master Nandos"] = true,

--Stratholme
	["Archivist Galford"] = true,
	["Balnazzar"] = true,
	["Baron Rivendare"] = true,
	["Baroness Anastari"] = true,
	["Black Guard Swordsmith"] = true,
	["Cannon Master Willey"] = true,
	["Crimson Hammersmith"] = true,
	["Fras Siabi"] = true,
	["Hearthsinger Forresten"] = true,
	["Magistrate Barthilas"] = true,
	["Maleki the Pallid"] = true,
	["Nerub'enkan"] = true,
	["Postmaster Malown"] = true,
	["Ramstein the Gorger"] = true,
	["Skul"] = true,
	["Stonespine"] = true,
	["The Unforgiven"] = true,
	["Timmy the Cruel"] = true,

--Sunwell Plateau
	["Kalecgos"] = true,
	["Sathrovarr the Corruptor"] = true,
	["Brutallus"] = true,
	["Felmyst"] = true,
	["Kil'jaeden"] = true,
	["M'uru"] = true,
	["Entropius"] = true,
	["The Eredar Twins"] = true,
	["Lady Sacrolash"] = true,
	["Grand Warlock Alythess"] = true,

--Tempest Keep
--The Arcatraz
	["Dalliah the Doomsayer"] = true,
	["Harbinger Skyriss"] = true,
	["Warden Mellichar"] = true,
	["Wrath-Scryer Soccothrates"] = true,
	["Zereketh the Unbound"] = true,
--The Botanica
	["Commander Sarannis"] = true,
	["High Botanist Freywinn"] = true,
	["Laj"] = true,
	["Thorngrin the Tender"] = true,
	["Warp Splinter"] = true,
--The Eye
	["Al'ar"] = true,
	["Cosmic Infuser"] = true,
	["Devastation"] = true,
	["Grand Astromancer Capernian"] = true,
	["High Astromancer Solarian"] = true,
	["Infinity Blades"] = true,
	["Kael'thas Sunstrider"] = true,
	["Lord Sanguinar"] = true,
	["Master Engineer Telonicus"] = true,
	["Netherstrand Longbow"] = true,
	["Phaseshift Bulwark"] = true,
	["Solarium Agent"] = true,
	["Solarium Priest"] = true,
	["Staff of Disintegration"] = true,
	["Thaladred the Darkener"] = true,
	["Void Reaver"] = true,
	["Warp Slicer"] = true,
--The Mechanar
	["Gatewatcher Gyro-Kill"] = true,
	["Gatewatcher Iron-Hand"] = true,
	["Mechano-Lord Capacitus"] = true,
	["Nethermancer Sepethrea"] = true,
	["Pathaleon the Calculator"] = true,

--The Deadmines
	["Brainwashed Noble"] = true,
	["Captain Greenskin"] = true,
	["Cookie"] = true,
	["Edwin VanCleef"] = true,
	["Foreman Thistlenettle"] = true,
	["Gilnid"] = true,
	["Marisa du'Paige"] = true,
	["Miner Johnson"] = true,
	["Mr. Smite"] = true,
	["Rhahk'Zor"] = true,
	["Sneed"] = true,
	["Sneed's Shredder"] = true,

--The Stockade
	["Bazil Thredd"] = true,
	["Bruegal Ironknuckle"] = true,
	["Dextren Ward"] = true,
	["Hamhock"] = true,
	["Kam Deepfury"] = true,
	["Targorr the Dread"] = true,

--The Temple of Atal'Hakkar
	["Atal'alarion"] = true,
	["Avatar of Hakkar"] = true,
	["Dreamscythe"] = true,
	["Gasher"] = true,
	["Hazzas"] = true,
	["Hukku"] = true,
	["Jade"] = true,
	["Jammal'an the Prophet"] = true,
	["Kazkaz the Unholy"] = true,
	["Loro"] = true,
	["Mijan"] = true,
	["Morphaz"] = true,
	["Ogom the Wretched"] = true,
	["Shade of Eranikus"] = true,
	["Veyzhak the Cannibal"] = true,
	["Weaver"] = true,
	["Zekkis"] = true,
	["Zolo"] = true,
	["Zul'Lor"] = true,

--Uldaman
	["Ancient Stone Keeper"] = true,
	["Archaedas"] = true,
	["Baelog"] = true,
	["Digmaster Shovelphlange"] = true,
	["Galgann Firehammer"] = true,
	["Grimlok"] = true,
	["Ironaya"] = true,
	["Obsidian Sentinel"] = true,
	["Revelosh"] = true,

-- Ulduar
-- Halls of Lightning
	["General Bjarngrim"] = true,
	["Ionar"] = true,
	["Loken"] = true,
	["Volkhan"] = true,
-- Halls of Stone
	["Krystallus"] = true,
	["Maiden of Grief"] = true,
	["Sjonnir the Ironshaper"] = true,
	["The Tribunal of Ages"] = true,

-- The Violet Hold
	["Cyanigosa"] = true,
	["Erekem"] = true,
	["Ichoron"] = true,
	["Lavanthor"] = true,
	["Moragg"] = true,
	["Xevozz"] = true,
	["Zuramat the Obliterator"] = true,

--Wailing Caverns
	["Boahn"] = true,
	["Deviate Faerie Dragon"] = true,
	["Kresh"] = true,
	["Lady Anacondra"] = true,
	["Lord Cobrahn"] = true,
	["Lord Pythas"] = true,
	["Lord Serpentis"] = true,
	["Mad Magglish"] = true,
	["Mutanus the Devourer"] = true,
	["Skum"] = true,
	["Trigore the Lasher"] = true,
	["Verdan the Everliving"] = true,

--World Bosses
	["Avalanchion"] = true,
	["Azuregos"] = true,
	["Baron Charr"] = true,
	["Baron Kazum"] = true,
	["Doom Lord Kazzak"] = true,
	["Doomwalker"] = true,
	["Emeriss"] = true,
	["High Marshal Whirlaxis"] = true,
	["Lethon"] = true,
	["Lord Skwol"] = true,
	["Prince Skaldrenox"] = true,
	["Princess Tempestria"] = true,
	["Taerar"] = true,
	["The Windreaver"] = true,
	["Ysondre"] = true,

--Zul'Aman
	["Akil'zon"] = true,
	["Halazzi"] = true,
	["Jan'alai"] = true,
	["Malacrass"] = true,
	["Nalorakk"] = true,
	["Zul'jin"] = true,
	["Hex Lord Malacrass"] = true,

--Zul'Farrak
	["Antu'sul"] = true,
	["Chief Ukorz Sandscalp"] = true,
	["Dustwraith"] = true,
	["Gahz'rilla"] = true,
	["Hydromancer Velratha"] = true,
	["Murta Grimgut"] = true,
	["Nekrum Gutchewer"] = true,
	["Oro Eyegouge"] = true,
	["Ruuzlu"] = true,
	["Sandarr Dunereaver"] = true,
	["Sandfury Executioner"] = true,
	["Sergeant Bly"] = true,
	["Shadowpriest Sezz'ziz"] = true,
	["Theka the Martyr"] = true,
	["Witch Doctor Zum'rah"] = true,
	["Zerillis"] = true,
	["Zul'Farrak Dead Hero"] = true,

-- Zul'Drak
-- Gundrak
	["Drakkari Colossus"] = true,
	["Gal'darah"] = true,
	["Moorabi"] = true,
	["Slad'ran"] = true,

--Zul'Gurub
	["Bloodlord Mandokir"] = true,
	["Gahz'ranka"] = true,
	["Gri'lek"] = true,
	["Hakkar"] = true,
	["Hazza'rah"] = true,
	["High Priest Thekal"] = true,
	["High Priest Venoxis"] = true,
	["High Priestess Arlokk"] = true,
	["High Priestess Jeklik"] = true,
	["High Priestess Mar'li"] = true,
	["Jin'do the Hexxer"] = true,
	["Renataki"] = true,
	["Wushoolay"] = true,

--Ring of Blood (where? an instance? should be in other file?)
	["Brokentoe"] = true,
	["Mogor"] = true,
	["Murkblood Twin"] = true,
	["Murkblood Twins"] = true,
	["Rokdar the Sundered Lord"] = true,
	["Skra'gath"] = true,
	["The Blue Brothers"] = true,
	["Warmaul Champion"] = true,
}

if GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "Verteidiger des Anubisath",
		["Battleguard Sartura"] = "Schlachtwache Sartura",
		["C'Thun"] = "C'Thun",
		["Emperor Vek'lor"] = "Imperator Vek'lor",
		["Emperor Vek'nilash"] = "Imperator Vek'nilash",
		["Eye of C'Thun"] = "Auge von C'Thun",
		["Fankriss the Unyielding"] = "Fankriss der Unnachgiebige",
		["Lord Kri"] = "Lord Kri",
		["Ouro"] = "Ouro",
		["Princess Huhuran"] = "Prinzessin Huhuran",
		["Princess Yauj"] = "Prinzessin Yauj",
		["The Bug Family"] = "Die Käferfamilie",
		["The Prophet Skeram"] = "Der Prophet Skeram",
		["The Twin Emperors"] = "Die Zwillings-Imperatoren",
		["Vem"] = "Vem",
		["Viscidus"] = "Viscidus",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "Exarch Maladaar",
		["Shirrak the Dead Watcher"] = "Shirrak der Totenwächter",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "Nexusprinz Shaffar",
		["Pandemonius"] = "Pandemonius",
		["Tavarok"] = "Tavarok",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "Botschafter Höllenschlund",
		["Blackheart the Inciter"] = "Schwarzherz der Hetzer",
		["Grandmaster Vorpil"] = "Großmeister Vorpil",
		["Murmur"] = "Murmur",
--Sethekk Halls
		["Anzu"] = "Anzu",
		["Darkweaver Syth"] = "Dunkelwirker Syth",
		["Talon King Ikiss"] = "Klauenkönig Ikiss",

--Blackfathom Deeps
		["Aku'mai"] = "Aku'mai",
		["Baron Aquanis"] = "Baron Aquanis",
		["Gelihast"] = "Gelihast",
		["Ghamoo-ra"] = "Ghamoo-ra",
		["Lady Sarevess"] = "Lady Sarevess",
		["Old Serra'kis"] = "Old Serra'kis",
		["Twilight Lord Kelris"] = "Lord des Schattenhammers Kelris",

--Blackrock Depths
		["Ambassador Flamelash"] = "Botschafter Flammenschlag",
		["Anger'rel"] = "Anger'rel",
		["Anub'shiah"] = "Anub'shiah",
		["Bael'Gar"] = "Bael'Gar",
		["Chest of The Seven"] = "Truhe der Sieben",
		["Doom'rel"] = "Un'rel",
		["Dope'rel"] = "Trott'rel",
		["Emperor Dagran Thaurissan"] = "Imperator Dagran Thaurissan",
		["Eviscerator"] = "Ausweider",
		["Fineous Darkvire"] = "Fineous Dunkelader",
		["General Angerforge"] = "General Zornesschmied",
		["Gloom'rel"] = "Dunk'rel",
		["Golem Lord Argelmach"] = "Golemlord Argelmach",
		["Gorosh the Dervish"] = "Gorosh der Derwisch",
		["Grizzle"] = "Grizzle",
		["Hate'rel"] = "Hass'rel",
		["Hedrum the Creeper"] = "Hedrum der Krabbler",
		["High Interrogator Gerstahn"] = "Verhörmeisterin Gerstahn",
		["High Priestess of Thaurissan"] = "	Hohepriesterin von Thaurissan",
		["Houndmaster Grebmar"] = "Hundemeister Grebmar",
		["Hurley Blackbreath"] = "Hurley Pestatem",
		["Lord Incendius"] = "Lord Incendius",
		["Lord Roccor"] = "Lord Roccor",
		["Magmus"] = "Magmus",
		["Ok'thor the Breaker"] = "Ok'thor der Zerstörer",
		["Panzor the Invincible"] = "Panzor der Unbesiegbare",
		["Phalanx"] = "Phalanx",
		["Plugger Spazzring"] = "Stöpsel Zapfring",
		["Princess Moira Bronzebeard"] = "Prinzessin Moira Bronzebeard",
		["Pyromancer Loregrain"] = "Pyromant Weisenkorn",
		["Ribbly Screwspigot"] = "Ribbly Schraubstutz",
		["Seeth'rel"] = "Wut'rel",
		["The Seven Dwarves"] = "Die Sieben Zwerge",
		["Verek"] = "Verek",
		["Vile'rel"] = "Bös'rel",
		["Warder Stilgiss"] = "	Wärter Stilgiss",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "Bannok Grimmaxt",
		["Burning Felguard"] = "Brennende Teufelswache",
		["Crystal Fang"] = "Kristallfangzahn",
		["Ghok Bashguud"] = "Ghok Haudrauf",
		["Gizrul the Slavener"] = "Gizrul der Geifernde",
		["Halycon"] = "Halycon",
		["Highlord Omokk"] = "Hochlord Omokk",
		["Mor Grayhoof"] = "Mor Grauhuf",
		["Mother Smolderweb"] = "Mutter Glimmernetz",
		["Overlord Wyrmthalak"] = "Oberanführer Wyrmthalak",
		["Quartermaster Zigris"] = "Rüstmeister Zigris",
		["Shadow Hunter Vosh'gajin"] = "Schattenjägerin Vosh'gajin",
		["Spirestone Battle Lord"] = "Kampflord der Felsspitzoger",
		["Spirestone Butcher"] = "Metzger der Felsspitzoger",
		["Spirestone Lord Magus"] = "Maguslord der Felsspitzoger",
		["Urok Doomhowl"] = "Urok Schreckensbote",
		["War Master Voone"] = "Kriegsmeister Voone",
--Upper
		["General Drakkisath"] = "General Drakkisath",
		["Goraluk Anvilcrack"] = "Goraluk Hammerbruch",
		["Gyth"] = "Gyth",
		["Jed Runewatcher"] = "Jed Runenblick",
		["Lord Valthalak"] = "Lord Valthalak",
		["Pyroguard Emberseer"] = "Feuerwache Glutseher",
		["Solakar Flamewreath"] = "Solakar Feuerkrone",
		["The Beast"] = "Die Bestie",
		["Warchief Rend Blackhand"] = "Kriegshäuptling Rend Schwarzfaust",

--Blackwing Lair
		["Broodlord Lashlayer"] = "Brutwächter Dreschbringer",
		["Chromaggus"] = "Chromaggus",
		["Ebonroc"] = "Schattenschwinge",
		["Firemaw"] = "Feuerschwinge",
		["Flamegor"] = "Flammenmaul",
		["Grethok the Controller"] = "Grethok der Aufseher",
		["Lord Victor Nefarius"] = "Lord Victor Nefarius",
		["Nefarian"] = "Nefarian",
		["Razorgore the Untamed"] = "Razorgore der Ungezähmte",
		["Vaelastrasz the Corrupt"] = "Vaelastrasz der Verdorbene",

--Black Temple
		["Essence of Anger"] = "Essenz des Zorns",
		["Essence of Desire"] = "Essenz der Begierde",
		["Essence of Suffering"] = "Essenz des Leidens",
		["Gathios the Shatterer"] = "Gathios der Zerschmetterer",
		["Gurtogg Bloodboil"] = "Gurtogg Siedeblut",
		["High Nethermancer Zerevor"] = "Hochnethermant Zerevor",
		["High Warlord Naj'entus"] = "Oberster Kriegsfürst Naj'entus",
		["Illidan Stormrage"] = "Illidan Sturmgrimm",
		["Illidari Council"] = "Rat der Illidari",
		["Lady Malande"] = "Lady Malande",
		["Mother Shahraz"] = "Mutter Shahraz",
		["Reliquary of Souls"] = "Reliquium der Seelen",
		["Shade of Akama"] = "Akamas Schemen",
		["Supremus"] = "Supremus",
		["Teron Gorefiend"] = "Teron Blutschatten",
		["The Illidari Council"] = "Rat der Illidari",
		["Veras Darkshadow"] = "Veras Schwarzschatten",

--Borean Tundra
--The Eye of Eternity
		--["Malygos"] = true,
--The Nexus
		--["Anomalus"] = true,
		--["Grand Magus Telestra"] = true,
		--["Keristrasza"] = true,
		--["Ormorok the Tree-Shaper"] = true,
--The Oculus
		--["Drakos the Interrogator"] = true,
		--["Ley-Guardian Eregos"] = true,
		--["Mage-Lord Urom"] = true,
		--["Varos Cloudstrider"] = true,	

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "Kapitän Skarloc",
		["Epoch Hunter"] = "Epochenjäger",
		["Lieutenant Drake"] = "Leutnant Drach",
--The Culling of Stratholme
		--["Meathook"] = true,
		--["Chrono-Lord Epoch"] = true,
		--["Mal'Ganis"] = true,
		--["Salramm the Fleshcrafter"] = true,
--The Black Morass
		["Aeonus"] = "Aeonus",
		["Chrono Lord Deja"] = "Chronolord Deja",
		["Medivh"] = "Medivh",
		["Temporus"] = "Temporus",

--Chamber of Aspects
--The Obsidian Sanctum
		--["Sartharion"] = true,
		--["Shadron"] = true,
		--["Tenebron"] = true,
		--["Vesperon"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "Elitesoldat des Echsenkessels",
		["Coilfang Strider"] = "Schreiter des Echsenkessels",
		["Fathom-Lord Karathress"] = "Tiefenlord Karathress",
		["Hydross the Unstable"] = "Hydross der Unstete",
		["Lady Vashj"] = "Lady Vashj",
		["Leotheras the Blind"] = "Leotheras der Blinde",
		["Morogrim Tidewalker"] = "Morogrim Gezeitenwandler",
		["Pure Spawn of Hydross"] = "Gereinigter Nachkomme Hydross'",
		["Shadow of Leotheras"] = "Schatten von Leotheras",
		["Tainted Spawn of Hydross"] = "Besudelter Nachkomme Hydross'",
		["The Lurker Below"] = "Das Grauen aus der Tiefe",
		["Tidewalker Lurker"] = "Lauerer der Gezeitenwandler",
--The Slave Pens
		["Mennu the Betrayer"] = "Mennu der Verräter",
		["Quagmirran"] = "Quagmirran",
		["Rokmar the Crackler"] = "Rokmar der Zerquetscher",
		["Ahune"] = "Ahune",
--The Steamvault
		["Hydromancer Thespia"] = "Wasserbeschwörerin Thespia",
		["Mekgineer Steamrigger"] = "Robogenieur Dampfhammer",
		["Warlord Kalithresh"] = "Kriegsherr Kalithresh",
--The Underbog
		["Claw"] = "Klaue",
		["Ghaz'an"] = "Ghaz'an",
		["Hungarfen"] = "Hungarfenn",
		["Overseer Tidewrath"] = "Overseer Tidewrath",
		["Swamplord Musel'ek"] = "Sumpffürst Musel'ek",
		["The Black Stalker"] = "Die Schattenmutter",

--Dire Maul
--Arena
		["Mushgog"] = "Mushgog",
		["Skarr the Unbreakable"] = "Skarr der Unbezwingbare",
		["The Razza"] = "Der Razza",
--East
		["Alzzin the Wildshaper"] = "Alzzin der Wildformer",
		["Hydrospawn"] = "Hydrobrut",
		["Isalien"] = "Isalien",
		["Lethtendris"] = "Lethtendris",
		["Pimgib"] = "Pimgib",
		["Pusillin"] = "Pusillin",
		["Zevrim Thornhoof"] = "Zevrim Dornhuf",
--North
		["Captain Kromcrush"] = "Hauptmann Krombruch",
		["Cho'Rush the Observer"] = "Cho'Rush der Beobachter",
		["Guard Fengus"] = "Wache Fengus",
		["Guard Mol'dar"] = "Wache Mol'dar",
		["Guard Slip'kik"] = "Wache Slip'kik",
		["King Gordok"] = "König Gordok",
		["Knot Thimblejack's Cache"] = "Knot Thimblejacks Truhe",
		["Stomper Kreeg"] = "Stampfer Kreeg",
--West
		["Illyanna Ravenoak"] = "Illyanna Rabeneiche",
		["Immol'thar"] = "Immol'thar",
		["Lord Hel'nurath"] = "Lord Hel'nurath",
		["Magister Kalendris"] = "Magister Kalendris",
		["Prince Tortheldrin"] = "Prinz Tortheldrin",
		["Tendris Warpwood"] = "Tendris Wucherborke",
		["Tsu'zee"] = "Tsu'zee",

--Dragonblight
-- Ahn'kahet: The Old Kingdom
		--["Elder Nadox"] = true,
		--["Herald Volazj"]=  true,
		--["Jedoga Shadowseeker"] = true,
		--["Prince Taldaram"] = true,
--Azjol-Nerub
		--["Anub'arak"] = true,
		--["Hadronox"] = true,
		--["Krik'thir the Gatewatcher"] = true,

--Gnomeregan
		["Crowd Pummeler 9-60"] = "Meuteverprügler 9-60",
		["Dark Iron Ambassador"] = "Botschafter der Dunkeleisenzwerge",
		["Electrocutioner 6000"] = "Elektrokutor 6000",
		["Grubbis"] = "Grubbis",
		["Mekgineer Thermaplugg"] = "Robogenieur Thermadraht",
		["Techbot"] = "Techbot",
		["Viscous Fallout"] = "Verflüssigte Ablagerung",

--Grizzly Hills
--Draktharon Keep
		--["King Dred"] = true,
		--["Novos the Summoner"] = true,
		--["The Prophet Tharon'ja"] = true,
		--["Trollgore"] = true,

--Gruul's Lair
		["Blindeye the Seer"] = "Blindauge der Seher",
		["Gruul the Dragonkiller"] = "Gruul der Drachenschlächter",
		["High King Maulgar"] = "Hochkönig Maulgar",
		["Kiggler the Crazed"] = "Kiggler the Crazed",
		["Krosh Firehand"] = "Krosh Feuerhand",
		["Olm the Summoner"] = "Olm der Beschwörer",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "Nazan",
		["Omor the Unscarred"] = "Omor der Narbenlose",
		["Vazruden the Herald"] = "Vazruden der Herold",
		["Vazruden"] = "Vazruden",
		["Watchkeeper Gargolmar"] = "Wachhabender Gargolmar",
--Magtheridon's Lair
		["Hellfire Channeler"] = "Kanalisierer des Höllenfeuers",
		["Magtheridon"] = "Magtheridon",
--The Blood Furnace
		["Broggok"] = "Broggok",
		["Keli'dan the Breaker"] = "Keli'dan der Zerstörer",
		["The Maker"] = "Der Schöpfer",
--The Shattered Halls
		["Blood Guard Porung"] = "Blutwache Porung",
		["Grand Warlock Nethekurse"] = "Großhexenmeister Nethekurse",
		["Warbringer O'mrogg"] = "Kriegshetzer O'mrogg",
		["Warchief Kargath Bladefist"] = "Kriegshäuptling Kargath Messerfaust",

--Howling Fjord
--Utgarde Keep
		--["Constructor & Controller"] = true, --these are one encounter, so we do this as an encounter name
		--["Dalronn the Controller"] = true,
		--["Ingvar the Plunderer"] = true,
		--["Prince Keleseth"] = true,
		--["Skarvald the Constructor"] = true,
--Utgarde Pinnacle
		--["Skadi the Ruthless"] = true,
		--["King Ymiron"] = true,
		--["Svala Sorrowgrave"] = true,
		--["Gortok Palehoof"] = true,

--Hyjal Summit
		["Anetheron"] = "Anetheron",
		["Archimonde"] = "Archimonde",
		["Azgalor"] = "Azgalor",
		["Kaz'rogal"] = "Kaz'rogal",
		["Rage Winterchill"] = "Furor Winterfrost",

--Karazhan
		["Arcane Watchman"] = "Arkanwachmann",
		["Attumen the Huntsman"] = "Attumen der Jäger",
		["Chess Event"] = "Chess Event",
		["Dorothee"] = "Dorothee",
		["Dust Covered Chest"] = "Staub Bedeckter Kasten",
		["Grandmother"] = "Großmutter",
		["Hyakiss the Lurker"] = "Hyakiss der Lauerer",
		["Julianne"] = "Julianne",
		["Kil'rek"] = "Kil'rek",
		["King Llane Piece"] = "König Llane",
		["Maiden of Virtue"] = "Tugendhafte Maid",
		["Midnight"] = "Mittnacht",
		["Moroes"] = "Moroes",
		["Netherspite"] = "Nethergroll",
		["Nightbane"] = "Schrecken der Nacht",
		["Prince Malchezaar"] = "Prinz Malchezaar",
		["Restless Skeleton"] = "Ruheloses Skelett",
		["Roar"] = "Brüller",
		["Rokad the Ravager"] = "Rokad der Verheerer",
		["Romulo & Julianne"] = "Romulo & Julianne",
		["Romulo"] = "Romulo",
		["Shade of Aran"] = "Arans Schemen",
		["Shadikith the Glider"] = "Shadikith der Segler",
		["Strawman"] = "Strohmann",
		["Terestian Illhoof"] = "Terestian Siechhuf",
		["The Big Bad Wolf"] = "Der große böse Wolf",
		["The Crone"] = "Die böse Hexe",
		["The Curator"] = "Der Kurator",
		["Tinhead"] = "Blechkopf",
		["Tito"] = "Tito",
		["Warchief Blackhand Piece"] = "Kriegshäuptling Schwarzfaust",

-- Magisters' Terrace
		["Kael'thas Sunstrider"] = "Kael'thas Sonnenwanderer",
		["Priestess Delrissa"] = "Priesterin Delrissa",
		["Selin Fireheart"] = "Selin Feuerherz",
		["Vexallus"] = "Vexallus",

--Maraudon
		["Celebras the Cursed"] = "Celebras der Verfluchte",
		["Gelk"] = "Gelk",
		["Kolk"] = "Kolk",
		["Landslide"] = "Erdrutsch",
		["Lord Vyletongue"] = "Lord Schlangenzunge",
		["Magra"] = "Magra",
		["Maraudos"] = "Maraudos",
		["Meshlok the Harvester"] = "Meshlok der Ernter",
		["Noxxion"] = "Noxxion",
		["Princess Theradras"] = "Prinzessin Theradras",
		["Razorlash"] = "Schlingwurzler",
		["Rotgrip"] = "Faulschnapper",
		["Tinkerer Gizlock"] = "Tüftler Gizlock",
		["Veng"] = "Veng",

--Molten Core
		["Baron Geddon"] = "Baron Geddon",
		["Cache of the Firelord"] = "Truhe des Feuerlords",
		["Garr"] = "Garr",
		["Gehennas"] = "Gehennas",
		["Golemagg the Incinerator"] = "Golemagg der Verbrenner",
		["Lucifron"] = "Lucifron",
		["Magmadar"] = "Magmadar",
		["Majordomo Executus"] = "Majordomus Exekutus",
		["Ragnaros"] = "Ragnaros",
		["Shazzrah"] = "Shazzrah",
		["Sulfuron Harbinger"] = "Sulfuronherold",

--Naxxramas
		["Anub'Rekhan"] = "Anub'Rekhan",
		["Deathknight Understudy"] = "Reservist der Todesritter",
		["Feugen"] = "Feugen",
		["Four Horsemen Chest"] = "Die Vier Reiter Kiste",
		["Gluth"] = "Gluth",
		["Gothik the Harvester"] = "Gothik der Seelenjäger",
		["Grand Widow Faerlina"] = "Großwitwe Faerlina",
		["Grobbulus"] = "Grobbulus",
		["Heigan the Unclean"] = "Heigan der Unreine",
		["Highlord Mograine"] = "Hochlord Mograine",
		["Instructor Razuvious"] = "Instrukteur Razuvious",
		["Kel'Thuzad"] = "Kel'Thuzad",
		["Lady Blaumeux"] = "Lady Blaumeux",
		["Loatheb"] = "Loatheb",
		["Maexxna"] = "Maexxna",
		["Noth the Plaguebringer"] = "Noth der Seuchenfürst",
		["Patchwerk"] = "Flickwerk",
		["Sapphiron"] = "Saphiron",
		["Sir Zeliek"] = "Sire Zeliek",
		["Stalagg"] = "Stalagg",
		["Thaddius"] = "Thaddius",
		["Thane Korth'azz"] = "Thane Korth'azz",
		["The Four Horsemen"] = "Die Vier Reiter",

--Onyxia's Lair
		["Onyxia"] = "Onyxia",

--Ragefire Chasm
		["Bazzalan"] = "Bazzalan",
		["Jergosh the Invoker"] = "Jergosh der Herbeirufer",
		["Maur Grimtotem"] = "Maur Grimmtotem",
		["Taragaman the Hungerer"] = "Taragaman der Hungerleider",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "Amnennar der Kältebringer",
		["Glutton"] = "Nimmersatt",
		["Mordresh Fire Eye"] = "Mordresh Feuerauge",
		["Plaguemaw the Rotting"] = "Seuchenschlund der Faulende",
		["Ragglesnout"] = "Struppmähne",
		["Tuten'kash"] = "Tuten'kash",

--Razorfen Kraul
		["Agathelos the Raging"] = "Agathelos der Tobende",
		["Blind Hunter"] = "Blinder Jäger",
		["Charlga Razorflank"] = "Charlga Klingenflanke",
		["Death Speaker Jargba"] = "Todessprecher Jargba",
		["Earthcaller Halmgar"] = "Erdenrufer Halmgar",
		["Overlord Ramtusk"] = "Oberanführer Rammhauer",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "Beschützer des Anubisath",
		["Ayamiss the Hunter"] = "Ayamiss der Jäger",
		["Buru the Gorger"] = "Buru der Verschlinger",
		["General Rajaxx"] = "General Rajaxx",
		["Kurinnaxx"] = "Kurinnaxx",
		["Lieutenant General Andorov"] = "Generallieutenant Andorov",
		["Moam"] = "Moam",
		["Ossirian the Unscarred"] = "Ossirian der Narbenlose",

--Scarlet Monastery
--Armory
		["Herod"] = "Herod",
--Cathedral
		["High Inquisitor Fairbanks"] = "Hochinquisitor Fairbanks",
		["High Inquisitor Whitemane"] = "Hochinquisitor Weißsträhne",
		["Scarlet Commander Mograine"] = "Scharlachroter Kommandant Mograine",
--Graveyard
		["Azshir the Sleepless"] = "Azshir der Schlaflose",
		["Bloodmage Thalnos"] = "Blutmagier Thalnos",
		["Fallen Champion"] = "Gestürzter Held",
		["Interrogator Vishas"] = "Befrager Vishas",
		["Ironspine"] = "Eisenrücken",
		["Headless Horseman"] = "Der kopflose Reiter",
--Library
		["Arcanist Doan"] = "Arkanist Doan",
		["Houndmaster Loksey"] = "Hundemeister Loksey",

--Scholomance
		["Blood Steward of Kirtonos"] = "Blutdiener von Kirtonos",
		["Darkmaster Gandling"] = "Dunkelmeister Gandling",
		["Death Knight Darkreaver"] = "Todesritter Schattensichel",
		["Doctor Theolen Krastinov"] = "Doktor Theolen Krastinov",
		["Instructor Malicia"] = "Instrukteurin Malicia",
		["Jandice Barov"] = "Jandice Barov",
		["Kirtonos the Herald"] = "Kirtonos der Herold",
		["Kormok"] = "Kormok",
		["Lady Illucia Barov"] = "Lady Illucia Barov",
		["Lord Alexei Barov"] = "Lord Alexei Barov",
		["Lorekeeper Polkelt"] = "Hüter des Wissens Polkelt",
		["Marduk Blackpool"] = "Marduk Blackpool",
		["Ras Frostwhisper"] = "Ras Frostraunen",
		["Rattlegore"] = "Blutrippe",
		["The Ravenian"] = "Der Ravenier",
		["Vectus"] = "Vectus",

--Shadowfang Keep
		["Archmage Arugal"] = "Erzmagier Arugal",
		["Arugal's Voidwalker"] = "Arugals Leerwandler",
		["Baron Silverlaine"] = "Baron Silberlein",
		["Commander Springvale"] = "Kommandant Springvale",
		["Deathsworn Captain"] = "Todeshöriger Captain",
		["Fenrus the Devourer"] = "Fenrus der Verschlinger",
		["Odo the Blindwatcher"] = "Odo der Blindseher",
		["Razorclaw the Butcher"] = "Klingenklaue der Metzger",
		["Wolf Master Nandos"] = "Wolfmeister Nados",

--Stratholme
		["Archivist Galford"] = "Archivar Galford",
		["Balnazzar"] = "Balnazzar",
		["Baron Rivendare"] = "Baron Totenschwur",
		["Baroness Anastari"] = "Baroness Anastari",
		["Black Guard Swordsmith"] = "Schwertschmied der schwarzen Wache",
		["Cannon Master Willey"] = "Kanonenmeister Willey",
		["Crimson Hammersmith"] = "Purpurroter Hammerschmied",
		["Fras Siabi"] = "Fras Siabi",
		["Hearthsinger Forresten"] = "Herdsinger Forresten",
		["Magistrate Barthilas"] = "Magistrat Barthilas",
		["Maleki the Pallid"] = "Maleki der Leichenblasse",
		["Nerub'enkan"] = "Nerub'enkan",
		["Postmaster Malown"] = "Postmeister Malown",
		["Ramstein the Gorger"] = "Ramstein der Verschlinger",
		["Skul"] = "Skul",
		["Stonespine"] = "Steinbuckel",
		["The Unforgiven"] = "Der Unverziehene",
		["Timmy the Cruel"] = "Timmy der Grausame",

--Sunwell Plateau
		["Kalecgos"] = "Kalecgos",
		["Sathrovarr the Corruptor"] = "Sathrovarr der Verderber",
		["Brutallus"] = "Brutallus",
		["Felmyst"] = "Teufelsruch",
		["Kil'jaeden"] = "Kil'jaeden",
		["M'uru"] = "M'uru",
		["Entropius"] = "Entropius",
		["The Eredar Twins"] = "Die Eredar Zwillinge",
		["Lady Sacrolash"] = "Lady Sacrolash",
		["Grand Warlock Alythess"] = "Großhexenmeisterin Alythess",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "Dalliah die Verdammnisverkünderin",
		["Harbinger Skyriss"] = "Herold Horizontiss",
		["Warden Mellichar"] = "Aufseher Mellichar",
		["Wrath-Scryer Soccothrates"] = "Zornseher Soccothrates",
		["Zereketh the Unbound"] = "Zereketh der Unabhängige",
--The Botanica
		["Commander Sarannis"] = "Kommandant Sarannis",
		["High Botanist Freywinn"] = "Hochbotaniker Freywinn",
		["Laj"] = "Laj",
		["Thorngrin the Tender"] = "Dorngrin der Hüter",
		["Warp Splinter"] = "Warpzweig",
--The Eye
		["Al'ar"] = "Al'ar",
		["Cosmic Infuser"] = "Kosmische Macht",
		["Devastation"] = "Verwüstung",
		["Grand Astromancer Capernian"] = "Großastronom Capernian",
		["High Astromancer Solarian"] = "Hochastromantin Solarian",
		["Infinity Blades"] = "Klinge der Unendlichkeit",
		["Kael'thas Sunstrider"] = "Kael'thas Sonnenwanderer",
		["Lord Sanguinar"] = "Fürst Blutdurst",
		["Master Engineer Telonicus"] = "Meisteringenieur Telonicus",
		["Netherstrand Longbow"] = "Netherbespannter Langbogen",
		["Phaseshift Bulwark"] = "Phasenverschobenes Bollwerk",
		["Solarium Agent"] = "Solarian Agent",
		["Solarium Priest"] = "Solarian Priester",
		["Staff of Disintegration"] = "Stab der Auflösung",
		["Thaladred the Darkener"] = "Thaladred der Verfinsterer",
		["Void Reaver"] = "Leerhäscher",
		["Warp Slicer"] = "Warpschnitter",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "Torwächter Gyrotot",
		["Gatewatcher Iron-Hand"] = "Torwächter Eisenhand",
		["Mechano-Lord Capacitus"] = "Mechanolord Kapazitus",
		["Nethermancer Sepethrea"] = "Nethermant Sepethrea",
		["Pathaleon the Calculator"] = "Pathaleon der Kalkulator",

--The Deadmines
		["Brainwashed Noble"] = "Manipulierter Adliger",
		["Captain Greenskin"] = "Kapitän Grünhaut",
		["Cookie"] = "Krümel",
		["Edwin VanCleef"] = "Edwin van Cleef",
		["Foreman Thistlenettle"] = "Großknecht Distelklette",
		["Gilnid"] = "Gilnid",
		["Marisa du'Paige"] = "Marisa du'Paige",
		["Miner Johnson"] = "Minenarbeiter Johnson",
		["Mr. Smite"] = "Handlanger Pein",
		["Rhahk'Zor"] = "Rhahk'Zor",
		["Sneed"] = "Sneed",
		["Sneed's Shredder"] = "Sneeds Schredder",

--The Stockade
		["Bazil Thredd"] = "Bazil Thredd",
		["Bruegal Ironknuckle"] = "Bruegal Eisenfaust",
		["Dextren Ward"] = "Dextren Ward",
		["Hamhock"] = "Hamhock",
		["Kam Deepfury"] = "Kam Tiefenzorn",
		["Targorr the Dread"] = "Targorr der Schreckliche",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "Atal'alarion",
		["Avatar of Hakkar"] = "Avatar von Hakkar",
		["Dreamscythe"] = "Traumsense",
		["Gasher"] = "Schlitzer",
		["Hazzas"] = "Hazzas",
		["Hukku"] = "Hukku",
		["Jade"] = "Jade",
		["Jammal'an the Prophet"] = "Jammal'an der Prophet",
		["Kazkaz the Unholy"] = "Kazkaz der Unheilige",
		["Loro"] = "Loro",
		["Mijan"] = "Mijan",
		["Morphaz"] = "Morphaz",
		["Ogom the Wretched"] = "Ogom der Elende",
		["Shade of Eranikus"] = "Eranikus' Schemen",
		["Veyzhak the Cannibal"] = "Veyzhack der Kannibale",
		["Weaver"] = "Wirker",
		["Zekkis"] = "Zekkis",
		["Zolo"] = "Zolo",
		["Zul'Lor"] = "Zul'Lor",

--Uldaman
		["Ancient Stone Keeper"] = "Uralter Steinbewahrer",
		["Archaedas"] = "Archaedas",
		["Baelog"] = "Baelog",
		["Digmaster Shovelphlange"] = "Grubenmeister Schaufelphlansch",
		["Galgann Firehammer"] = "Galgann Feuerhammer",
		["Grimlok"] = "Grimlok",
		["Ironaya"] = "Ironaya",
		["Obsidian Sentinel"] = "Obsidianschildwache",
		["Revelosh"] = "Revelosh",

-- Ulduar
-- Halls of Lightning
		--["General Bjarngrim"] = true,
		--["Ionar"] = true,
		--["Loken"] = true,
		--["Volkhan"] = true,
-- Halls of Stone
		--["Krystallus"] = true,
		--["Maiden of Grief"] = true,
		--["Sjonnir the Ironshaper"] = true,
		--["The Tribunal of Ages"] = true,

-- The Violet Hold
		--["Cyanigosa"] = true,
		--["Erekem"] = true,
		--["Ichoron"] = true,
		--["Lavanthor"] = true,
		--["Moragg"] = true,
		--["Xevozz"] = true,
		--["Zuramat the Obliterator"] = true,

--Wailing Caverns
		["Boahn"] = "Boahn",
		["Deviate Faerie Dragon"] = "Deviatfeendrache",
		["Kresh"] = "Kresh",
		["Lady Anacondra"] = "Lady Anacondra",
		["Lord Cobrahn"] = "Lord Kobrahn",
		["Lord Pythas"] = "Lord Pythas",
		["Lord Serpentis"] = "Lord Serpentis",
		["Mad Magglish"] = "Zausel der Verrückte",
		["Mutanus the Devourer"] = "Mutanus der Verschlinger",
		["Skum"] = "Skum",
		["Trigore the Lasher"] = "Trigore der Peitscher",
		["Verdan the Everliving"] = "Verdan der Ewiglebende",

--World Bosses
		["Avalanchion"] = "Avalanchion",
		["Azuregos"] = "Azuregos",
		["Baron Charr"] = "Baron Glutarr",
		["Baron Kazum"] = "Baron Kazum",
		["Doom Lord Kazzak"] = "Verdammnislord Kazzak",
		["Doomwalker"] = "Verdammniswandler",
		["Emeriss"] = "Smariss",
		["High Marshal Whirlaxis"] = "Hochmarschall Whirlaxis",
		["Lethon"] = "Lethon",
		["Lord Skwol"] = "Lord Skwol",
		["Prince Skaldrenox"] = "Prince Skaldrenox",
		["Princess Tempestria"] = "Prinzessin Tempestria",
		["Taerar"] = "Taerar",
		["The Windreaver"] = "Der Windhäscher",
		["Ysondre"] = "Ysondre",

--Zul'Aman
		["Akil'zon"] = "Akil'zon",
		["Halazzi"] = "Halazzi",
		["Jan'alai"] = "Jan'alai",
		["Malacrass"] = "Malacrass",
		["Nalorakk"] = "Nalorakk",
		["Zul'jin"] = "Zul'jin",
		["Hex Lord Malacrass"] = "Hexlord Malacrass",

--Zul'Farrak
		["Antu'sul"] = "Antu'sul",
		["Chief Ukorz Sandscalp"] = "Häuptling Ukorz Sandwüter",
		["Dustwraith"] = "Karaburan",
		["Gahz'rilla"] = "Gahz'rilla",
		["Hydromancer Velratha"] = "Wasserbeschwörerin Velratha",
		["Murta Grimgut"] = "Murta Bauchgrimm",
		["Nekrum Gutchewer"] = "Nekrum der Ausweider",
		["Oro Eyegouge"] = "Oro Hohlauge",
		["Ruuzlu"] = "Ruuzlu",
		["Sandarr Dunereaver"] = "Sandarr der Wüstenräuber",
		["Sandfury Executioner"] = "Henker der Sandwüter",
		["Sergeant Bly"] = "Unteroffizier Bly",
		["Shadowpriest Sezz'ziz"] = "Schattenpriester Sezz'ziz",
		["Theka the Martyr"] = "Theka der Märtyrer",
		["Witch Doctor Zum'rah"] = "Hexendoktor Zum'rah" ,
		["Zerillis"] = "Zerillis",
		["Zul'Farrak Dead Hero"] = "Untoter Held aus Zul'Farrak",

-- Zul'Drak
-- Gundrak
		--["Drakkari Colossus"] = true,
		--["Gal'darah"] = true,
		--["Moorabi"] = true,
		--["Slad'ran"] = true,

--Zul'Gurub
		["Bloodlord Mandokir"] = "Blutfürst Mandokir",
		["Gahz'ranka"] = "Gahz'ranka",
		["Gri'lek"] = "Gri'lek",
		["Hakkar"] = "Hakkar",
		["Hazza'rah"] = "Hazza'rah",
		["High Priest Thekal"] = "Hohepriester Thekal",
		["High Priest Venoxis"] = "Hohepriester Venoxis",
		["High Priestess Arlokk"] = "Hohepriesterin Arlokk",
		["High Priestess Jeklik"] = "Hohepriesterin Jeklik",
		["High Priestess Mar'li"] = "Hohepriesterin Mar'li",
		["Jin'do the Hexxer"] = "Jin'do der Verhexer",
		["Renataki"] = "Renataki",
		["Wushoolay"] = "Wushoolay",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "Schmetterzehe",
		["Mogor"] = "Mogor",
		["Murkblood Twin"] = "Zwilling der Finsterblut",
		["Murkblood Twins"] = "Zwillinge der Finsterblut",
		["Rokdar the Sundered Lord"] = "Rokdar der Zerklüftete",
		["Skra'gath"] = "Skra'gath",
		["The Blue Brothers"] = "Die Blaumänner",
		["Warmaul Champion"] = "Champion der Totschläger",
	}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "Défenseur Anubisath",
		["Battleguard Sartura"] = "Garde de guerre Sartura",
		["C'Thun"] = "C'Thun",
		["Emperor Vek'lor"] = "Empereur Vek'lor",
		["Emperor Vek'nilash"] = "Empereur Vek'nilash",
		["Eye of C'Thun"] = "Œil de C'Thun",
		["Fankriss the Unyielding"] = "Fankriss l'Inflexible",
		["Lord Kri"] = "Seigneur Kri",
		["Ouro"] = "Ouro",
		["Princess Huhuran"] = "Princesse Huhuran",
		["Princess Yauj"] = "Princesse Yauj",
		["The Bug Family"] = "La famille insecte",
		["The Prophet Skeram"] = "Le Prophète Skeram",
		["The Twin Emperors"] = "Les Empereurs jumeaux",
		["Vem"] = "Vem",
		["Viscidus"] = "Viscidus",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "Exarque Maladaar",
		["Shirrak the Dead Watcher"] = "Shirrak le Veillemort",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "Prince-nexus Shaffar",
		["Pandemonius"] = "Pandemonius",
		["Tavarok"] = "Tavarok",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "Ambassadeur Gueule-d'enfer",
		["Blackheart the Inciter"] = "Coeur-noir le Séditieux",
		["Grandmaster Vorpil"] = "Grand Maître Vorpil",
		["Murmur"] = "Marmon",
--Sethekk Halls
		["Anzu"] = "Anzu",
		["Darkweaver Syth"] = "Tisseur d'ombre Syth",
		["Talon King Ikiss"] = "Roi-serre Ikiss",

--Blackfathom Deeps
		["Aku'mai"] = "Aku'mai",
		["Baron Aquanis"] = "Baron Aquanis",
		["Gelihast"] = "Gelihast",
		["Ghamoo-ra"] = "Ghamoo-ra",
		["Lady Sarevess"] = "Dame Sarevess",
		["Old Serra'kis"] = "Vieux Serra'kis",
		["Twilight Lord Kelris"] = "Seigneur du crépuscule Kelris",

--Blackrock Depths
		["Ambassador Flamelash"] = "Ambassadeur Cinglefouet",
		["Anger'rel"] = "Colé'rel",
		["Anub'shiah"] = "Anub'shiah",
		["Bael'Gar"] = "Bael'Gar",
		["Chest of The Seven"] = "Coffre des sept",
		["Doom'rel"] = "Tragi'rel",
		["Dope'rel"] = "Demeu'rel",
		["Emperor Dagran Thaurissan"] = "Empereur Dagran Thaurissan",
		["Eviscerator"] = "Eviscérateur",
		["Fineous Darkvire"] = "Fineous Sombrevire",
		["General Angerforge"] = "Général Forgehargne",
		["Gloom'rel"] = "Funéb'rel",
		["Golem Lord Argelmach"] = "Seigneur golem Argelmach",
		["Gorosh the Dervish"] = "Gorosh le Derviche",
		["Grizzle"] = "Grison",
		["Hate'rel"] = "Haine'rel",
		["Hedrum the Creeper"] = "Hedrum le Rampant",
		["High Interrogator Gerstahn"] = "Grand Interrogateur Gerstahn",
		["High Priestess of Thaurissan"] = "Grande prêtresse de Thaurissan",
		["Houndmaster Grebmar"] = "Maître-chien Grebmar",
		["Hurley Blackbreath"] = "Hurley Soufflenoir",
		["Lord Incendius"] = "Seigneur Incendius",
		["Lord Roccor"] = "Seigneur Roccor",
		["Magmus"] = "Magmus",
		["Ok'thor the Breaker"] = "Ok'thor le Briseur",
		["Panzor the Invincible"] = "Panzor l'Invincible",
		["Phalanx"] = "Phalange",
		["Plugger Spazzring"] = "Lanfiche Brouillecircuit",
		["Princess Moira Bronzebeard"] = "Princesse Moira Barbe-de-bronze",
		["Pyromancer Loregrain"] = "Pyromancien Blé-du-savoir",
		["Ribbly Screwspigot"] = "Ribbly Fermevanne",
		["Seeth'rel"] = "Fulmi'rel",
		["The Seven Dwarves"] = "Les sept nains",
		["Verek"] = "Verek",
		["Vile'rel"] = "Ignobl'rel",
		["Warder Stilgiss"] = "Gardien Stilgiss",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "Bannok Hache-sinistre",
		["Burning Felguard"] = "Gangregarde ardent",
		["Crystal Fang"] = "Croc cristallin",
		["Ghok Bashguud"] = "Ghok Bounnebaffe",
		["Gizrul the Slavener"] = "Gizrul l'esclavagiste",
		["Halycon"] = "Halycon",
		["Highlord Omokk"] = "Généralissime Omokk",
		["Mor Grayhoof"] = "Mor Sabot-gris",
		["Mother Smolderweb"] = "Matriarche Couveuse",
		["Overlord Wyrmthalak"] = "Seigneur Wyrmthalak",
		["Quartermaster Zigris"] = "Intendant Zigris",
		["Shadow Hunter Vosh'gajin"] = "Chasseresse des ombres Vosh'gajin",
		["Spirestone Battle Lord"] = "Seigneur de bataille Pierre-du-pic",
		["Spirestone Butcher"] = "Boucher Pierre-du-pic",
		["Spirestone Lord Magus"] = "Seigneur magus Pierre-du-pic",
		["Urok Doomhowl"] = "Urok Hurleruine",
		["War Master Voone"] = "Maître de guerre Voone",
--Upper
		["General Drakkisath"] = "Général Drakkisath",
		["Goraluk Anvilcrack"] = "Goraluk Brisenclume",
		["Gyth"] = "Gyth",
		["Jed Runewatcher"] = "Jed Guette-runes",
		["Lord Valthalak"] = "Seigneur Valthalak",
		["Pyroguard Emberseer"] = "Pyrogarde Prophète ardent",
		["Solakar Flamewreath"] = "Solakar Voluteflamme",
		["The Beast"] = "La Bête",
		["Warchief Rend Blackhand"] = "Chef de guerre Rend Main-noire",

--Blackwing Lair
		["Broodlord Lashlayer"] = "Seigneur des couvées Lanistaire",
		["Chromaggus"] = "Chromaggus",
		["Ebonroc"] = "Rochébène",
		["Firemaw"] = "Gueule-de-feu",
		["Flamegor"] = "Flamegor",
		["Grethok the Controller"] = "Grethok le Contrôleur",
		["Lord Victor Nefarius"] = "Seigneur Victor Nefarius",
		["Nefarian"] = "Nefarian",
		["Razorgore the Untamed"] = "Tranchetripe l'Indompté",
		["Vaelastrasz the Corrupt"] = "Vaelastrasz le Corrompu",

--Black Temple
		["Essence of Anger"] = "Essence de la colère",
		["Essence of Desire"] = "Essence du désir",
		["Essence of Suffering"] = "Essence de la souffrance",
		["Gathios the Shatterer"] = "Gathios le Briseur",
		["Gurtogg Bloodboil"] = "Gurtogg Fièvresang",
		["High Nethermancer Zerevor"] = "Grand néantomancien Zerevor",
		["High Warlord Naj'entus"] = "Grand seigneur de guerre Naj'entus",
		["Illidan Stormrage"] = "Illidan Hurlorage",
		["Illidari Council"] = "Conseil illidari",
		["Lady Malande"] = "Dame Malande",
		["Mother Shahraz"] = "Mère Shahraz",
		["Reliquary of Souls"] = "Le reliquaire des âmes",
		["Shade of Akama"] = "Ombre d'Akama",
		["Supremus"] = "Supremus",
		["Teron Gorefiend"] = "Teron Fielsang",
		["The Illidari Council"] = "Le conseil illidari",
		["Veras Darkshadow"] = "Veras Ombrenoir",

--Borean Tundra
--The Eye of Eternity
		["Malygos"] = "Malygos",
--The Nexus
		["Anomalus"] = "Anomalus",
		["Grand Magus Telestra"] = "Grand magus Telestra",
		["Keristrasza"] = "Keristrasza",
		["Ormorok the Tree-Shaper"] = "Ormorok le Sculpte-arbre",
--The Oculus
		["Drakos the Interrogator"] = "Drakos l'Interrogateur",
		["Ley-Guardian Eregos"] = "Gardien-tellurique Eregos",
		["Mage-Lord Urom"] = "Seigneur-mage Urom",
		["Varos Cloudstrider"] = "Varos Arpentenuée",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "Capitaine Skarloc",
		["Epoch Hunter"] = "Chasseur d'époques",
		["Lieutenant Drake"] = "Lieutenant Drake",
--The Culling of Stratholme
		["Meathook"] = "Grancrochet",
		["Chrono-Lord Epoch"] = "Chronoseigneur Epoch",
		["Mal'Ganis"] = "Mal'Ganis",
		["Salramm the Fleshcrafter"] = "Salramm le Façonneur de chair",
--The Black Morass
		["Aeonus"] = "Aeonus",
		["Chrono Lord Deja"] = "Chronoseigneur Déjà",
		["Medivh"] = "Medivh",
		["Temporus"] = "Temporus",

--Chamber of Aspects
--The Obsidian Sanctum
		--["Sartharion"] = true,
		--["Shadron"] = true,
		--["Tenebron"] = true,
		--["Vesperon"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "Elite de Glissecroc",
		["Coilfang Strider"] = "Trotteur de Glissecroc",
		["Fathom-Lord Karathress"] = "Seigneur des fonds Karathress",
		["Hydross the Unstable"] = "Hydross l'Instable",
		["Lady Vashj"] = "Dame Vashj",
		["Leotheras the Blind"] = "Leotheras l'Aveugle",
		["Morogrim Tidewalker"] = "Morogrim Marcheur-des-flots",
		["Pure Spawn of Hydross"] = "Pur rejeton d'Hydross",
		["Shadow of Leotheras"] = "Ombre de Leotheras",
		["Tainted Spawn of Hydross"] = "Rejeton d'Hydross souillé",
		["The Lurker Below"] = "Le Rôdeur d'En bas",
		["Tidewalker Lurker"] = "Rôdeur marcheur-des-flots",
--The Slave Pens
		["Ahune"] = "Ahune",
		["Mennu the Betrayer"] = "Mennu le Traître",
		["Quagmirran"] = "Bourbierreux",
		["Rokmar the Crackler"] = "Rokmar le Crépitant",
--The Steamvault
		["Hydromancer Thespia"] = "Hydromancienne Thespia",
		["Mekgineer Steamrigger"] = "Mékgénieur Montevapeur",
		["Warlord Kalithresh"] = "Seigneur de guerre Kalithresh",
--The Underbog
		["Claw"] = "Griffe",
		["Ghaz'an"] = "Ghaz'an",
		["Hungarfen"] = "Hungarfen",
		["Overseer Tidewrath"] = "Surveillant Tidewrath",
		["Swamplord Musel'ek"] = "Seigneur des marais Musel'ek",
		["The Black Stalker"] = "La Traqueuse noire",

--Dire Maul
--Arena
		["Mushgog"] = "Mushgog",
		["Skarr the Unbreakable"] = "Bâlhafr l'Invaincu",
		["The Razza"] = "La Razza",
--East
		["Alzzin the Wildshaper"] = "Alzzin le Modeleur",
		["Hydrospawn"] = "Hydrogénos",
		["Isalien"] = "Isalien",
		["Lethtendris"] = "Lethtendris",
		["Pimgib"] = "Pimgib",
		["Pusillin"] = "Pusillin",
		["Zevrim Thornhoof"] = "Zevrim Sabot-de-ronce",
--North
		["Captain Kromcrush"] = "Capitaine Kromcrush",
		["Cho'Rush the Observer"] = "Cho'Rush l'Observateur",
		["Guard Fengus"] = "Garde Fengus",
		["Guard Mol'dar"] = "Garde Mol'dar",
		["Guard Slip'kik"] = "Garde Slip'kik",
		["King Gordok"] = "Roi Gordok",
		["Knot Thimblejack's Cache"] = "Réserve de Noué Dédodevie",
		["Stomper Kreeg"] = "Kreeg le Marteleur",
--West
		["Illyanna Ravenoak"] = "Illyanna Corvichêne",
		["Immol'thar"] = "Immol'thar",
		["Lord Hel'nurath"] = "Seigneur Hel'nurath",
		["Magister Kalendris"] = "Magistère Kalendris",
		["Prince Tortheldrin"] = "Prince Tortheldrin",
		["Tendris Warpwood"] = "Tendris Crochebois",
		["Tsu'zee"] = "Tsu'zee",

--Dragonblight
-- Ahn'kahet: The Old Kingdom
		["Elder Nadox"] = "Ancien Nadox",
		["Herald Volazj"]=  "Héraut Volazj",
		["Jedoga Shadowseeker"] = "Jedoga Cherchelombre",
		["Prince Taldaram"] = "Prince Taldaram",
--Azjol-Nerub
		["Anub'arak"] = "Anub'arak",
		["Hadronox"] = "Hadronox",
		["Krik'thir the Gatewatcher"] = "Krik'thir le Gardien de porte",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "Faucheur de foule 9-60",
		["Dark Iron Ambassador"] = "Ambassadeur Sombrefer",
		["Electrocutioner 6000"] = "Electrocuteur 6000",
		["Grubbis"] = "Grubbis",
		["Mekgineer Thermaplugg"] = "Mekgénieur Thermojoncteur",
		["Techbot"] = "Techbot",
		["Viscous Fallout"] = "Retombée visqueuse",

--Grizzly Hills
--Drak'Tharon Keep
		["King Dred"] = "Roi Dred",
		["Novos the Summoner"] = "Novos l'Invocateur",
		["The Prophet Tharon'ja"] = "Le prophète Tharon'ja",
		["Trollgore"] = "Trollétripe",

--Gruul's Lair
		["Blindeye the Seer"] = "Oeillaveugle le Voyant",
		["Gruul the Dragonkiller"] = "Gruul le Tue-dragon",
		["High King Maulgar"] = "Haut Roi Maulgar",
		["Kiggler the Crazed"] = "Kiggler le Cinglé",
		["Krosh Firehand"] = "Krosh Brasemain",
		["Olm the Summoner"] = "Olm l'Invocateur",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "Nazan",
		["Omor the Unscarred"] = "Omor l'Intouché",
		["Vazruden the Herald"] = "Vazruden le Héraut",
		["Vazruden"] = "Vazruden",
		["Watchkeeper Gargolmar"] = "Gardien des guetteurs Gargolmar",
--Magtheridon's Lair
		["Hellfire Channeler"] = "Canaliste des Flammes infernales",
		["Magtheridon"] = "Magtheridon",
--The Blood Furnace
		["Broggok"] = "Broggok",
		["Keli'dan the Breaker"] = "Keli'dan le Briseur",
		["The Maker"] = "Le Faiseur",
--The Shattered Halls
		["Blood Guard Porung"] = "Garde de sang Porung",
		["Grand Warlock Nethekurse"] = "Grand démoniste Néanathème",
		["Warbringer O'mrogg"] = "Porteguerre O'mrogg",
		["Warchief Kargath Bladefist"] = "Chef de guerre Kargath Lamepoing",

--Howling Fjord
--Utgarde Keep
		["Constructor & Controller"] = "Constructeur & Contrôleur", --these are one encounter, so we do this as an encounter name
		["Dalronn the Controller"] = "Dalronn le Contrôleur",
		["Ingvar the Plunderer"] = "Ingvar le Pilleur",
		["Prince Keleseth"] = "Prince Keleseth",
		["Skarvald the Constructor"] = "Skarvald le Constructeur",
--Utgarde Pinnacle
		["Skadi the Ruthless"] = "Skadi le Brutal",
		["King Ymiron"] = "Roi Ymiron",
		["Svala Sorrowgrave"] = "Svala Tristetombe",
		["Gortok Palehoof"] = "Gortok Pâle-sabot",

--Hyjal Summit
		["Anetheron"] = "Anetheron",
		["Archimonde"] = "Archimonde",
		["Azgalor"] = "Azgalor",
		["Kaz'rogal"] = "Kaz'rogal",
		["Rage Winterchill"] = "Rage Froidhiver",

--Karazhan
		["Arcane Watchman"] = "Veilleur arcanique",
		["Attumen the Huntsman"] = "Attumen le Veneur",
		["Chess Event"] = "Partie d'échec",
		["Dorothee"] = "Dorothée",
		["Dust Covered Chest"] = "Coffre couvert de poussière",
		["Grandmother"] = "Mère-grand",
		["Hyakiss the Lurker"] = "Hyakiss le rôdeur",
		["Julianne"] = "Julianne",
		["Kil'rek"] = "Kil'rek",
		["King Llane Piece"] = "Pion du Roi Llane",
		["Maiden of Virtue"] = "Damoiselle de vertu",
		["Midnight"] = "Minuit",
		["Moroes"] = "Moroes",
		["Netherspite"] = "Dédain-du-Néant",
		["Nightbane"] = "Plaie-de-nuit",
		["Prince Malchezaar"] = "Prince Malchezaar",
		["Restless Skeleton"] = "Squelette sans repos",
		["Roar"] = "Graou",
		["Rokad the Ravager"] = "Rodak le ravageur",
		["Romulo & Julianne"] = "Romulo & Julianne",
		["Romulo"] = "Romulo",
		["Shade of Aran"] = "Ombre d'Aran",
		["Shadikith the Glider"] = "Shadikith le glisseur",
		["Strawman"] = "Homme de paille",
		["Terestian Illhoof"] = "Terestian Malsabot",
		["The Big Bad Wolf"] = "Le Grand Méchant Loup",
		["The Crone"] = "La Mégère",
		["The Curator"] = "Le conservateur",
		["Tinhead"] = "Tête de fer-blanc",
		["Tito"] = "Tito",
		["Warchief Blackhand Piece"] = "Pion du Chef de guerre Main-noire",

-- Magisters' Terrace
		--["Kael'thas Sunstrider"] = "Kael'thas Haut-soleil",
		["Priestess Delrissa"] = "Prêtresse Delrissa",
		["Selin Fireheart"] = "Selin Coeur-de-feu",
		["Vexallus"] = "Vexallus",

--Maraudon
		["Celebras the Cursed"] = "Celebras le Maudit",
		["Gelk"] = "Gelk",
		["Kolk"] = "Kolk",
		["Landslide"] = "Glissement de terrain",
		["Lord Vyletongue"] = "Seigneur Vylelangue",
		["Magra"] = "Magra",
		["Maraudos"] = "Maraudos",
		["Meshlok the Harvester"] = "Meshlok le Moissonneur",
		["Noxxion"] = "Noxcion",
		["Princess Theradras"] = "Princesse Theradras",
		["Razorlash"] = "Tranchefouet",
		["Rotgrip"] = "Grippe-charogne",
		["Tinkerer Gizlock"] = "Bricoleur Kadenaz",
		["Veng"] = "Veng",

--Molten Core
		["Baron Geddon"] = "Baron Geddon",
		["Cache of the Firelord"] = "Cachette du Seigneur du feu",
		["Garr"] = "Garr",
		["Gehennas"] = "Gehennas",
		["Golemagg the Incinerator"] = "Golemagg l'Incinérateur",
		["Lucifron"] = "Lucifron",
		["Magmadar"] = "Magmadar",
		["Majordomo Executus"] = "Chambellan Executus",
		["Ragnaros"] = "Ragnaros",
		["Shazzrah"] = "Shazzrah",
		["Sulfuron Harbinger"] = "Messager de Sulfuron",

--Naxxramas
		["Anub'Rekhan"] = "Anub'Rekhan",
		["Deathknight Understudy"] = "Doublure de chevalier de la mort",
		["Feugen"] = "Feugen",
		["Four Horsemen Chest"] = "Coffre des quatre cavaliers",
		["Gluth"] = "Gluth",
		["Gothik the Harvester"] = "Gothik le Moissonneur",
		["Grand Widow Faerlina"] = "Grande veuve Faerlina",
		["Grobbulus"] = "Grobbulus",
		["Heigan the Unclean"] = "Heigan l'Impur",
		["Highlord Mograine"] = "Généralissime Mograine",
		["Instructor Razuvious"] = "Instructeur Razuvious",
		["Kel'Thuzad"] = "Kel'Thuzad",
		["Lady Blaumeux"] = "Dame Blaumeux",
		["Loatheb"] = "Horreb",
		["Maexxna"] = "Maexxna",
		["Noth the Plaguebringer"] = "Noth le Porte-peste",
		["Patchwerk"] = "Le Recousu",
		["Sapphiron"] = "Saphiron",
		["Sir Zeliek"] = "Sire Zeliek",
		["Stalagg"] = "Stalagg",
		["Thaddius"] = "Thaddius",
		["Thane Korth'azz"] = "Thane Korth'azz",
		["The Four Horsemen"] = "Les quatre cavaliers",

--Onyxia's Lair
		["Onyxia"] = "Onyxia",

--Ragefire Chasm
		["Bazzalan"] = "Bazzalan",
		["Jergosh the Invoker"] = "Jergosh l'Invocateur",
		["Maur Grimtotem"] = "Maur Totem-sinistre",
		["Taragaman the Hungerer"] = "Taragaman l'Affameur",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "Amnennar le Porte-froid",
		["Glutton"] = "Glouton",
		["Mordresh Fire Eye"] = "Mordresh Oeil-de-feu",
		["Plaguemaw the Rotting"] = "Pestegueule le Pourrissant",
		["Ragglesnout"] = "Groinfendu",
		["Tuten'kash"] = "Tuten'kash",

--Razorfen Kraul
		["Agathelos the Raging"] = "Agathelos le Déchaîné",
		["Blind Hunter"] = "Chasseur aveugle",
		["Charlga Razorflank"] = "Charlga Trancheflanc",
		["Death Speaker Jargba"] = "Nécrorateur Jargba",
		["Earthcaller Halmgar"] = "Implorateur de la terre Halmgar",
		["Overlord Ramtusk"] = "Seigneur Brusquebroche",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "Gardien Anubisath",
		["Ayamiss the Hunter"] = "Ayamiss le Chasseur",
		["Buru the Gorger"] = "Buru Grandgosier",
		["General Rajaxx"] = "Général Rajaxx",
		["Kurinnaxx"] = "Kurinnaxx",
		["Lieutenant General Andorov"] = "Général de division Andorov",
		["Moam"] = "Moam",
		["Ossirian the Unscarred"] = "Ossirian l'Intouché",

--Scarlet Monastery
--Armory
		["Herod"] = "Hérode",
--Cathedral
		["High Inquisitor Fairbanks"] = "Grand Inquisiteur Fairbanks",
		["High Inquisitor Whitemane"] = "Grand Inquisiteur Blanchetête",
		["Scarlet Commander Mograine"] = "Commandant écarlate Mograine",
--Graveyard
		["Azshir the Sleepless"] = "Azshir le Sans-sommeil",
		["Bloodmage Thalnos"] = "Mage de sang Thalnos",
		["Fallen Champion"] = "Champion mort",
		["Headless Horseman"] = "Cavalier sans tête",
		["Interrogator Vishas"] = "Interrogateur Vishas",
		["Ironspine"] = "Echine-de-fer",
--Library
		["Arcanist Doan"] = "Arcaniste Doan",
		["Houndmaster Loksey"] = "Maître-chien Loksey",

--Scholomance
		["Blood Steward of Kirtonos"] = "Régisseuse sanglante de Kirtonos",
		["Darkmaster Gandling"] = "Sombre Maître Gandling",
		["Death Knight Darkreaver"] = "Chevalier de la mort Ravassombre",
		["Doctor Theolen Krastinov"] = "Docteur Theolen Krastinov",
		["Instructor Malicia"] = "Instructeur Malicia",
		["Jandice Barov"] = "Jandice Barov",
		["Kirtonos the Herald"] = "Kirtonos le Héraut",
		["Kormok"] = "Kormok",
		["Lady Illucia Barov"] = "Dame Illucia Barov",
		["Lord Alexei Barov"] = "Seigneur Alexei Barov",
		["Lorekeeper Polkelt"] = "Gardien du savoir Polkelt",
		["Marduk Blackpool"] = "Marduk Noirétang",
		["Ras Frostwhisper"] = "Ras Murmegivre",
		["Rattlegore"] = "Cliquettripes",
		["The Ravenian"] = "Le Voracien",
		["Vectus"] = "Vectus",

--Shadowfang Keep
		["Archmage Arugal"] = "Archimage Arugal",
		["Arugal's Voidwalker"] = "Marcheur du Vide d'Arugal",
		["Baron Silverlaine"] = "Baron d'Argelaine",
		["Commander Springvale"] = "Commandant Springvale",
		["Deathsworn Captain"] = "Capitaine Ligemort",
		["Fenrus the Devourer"] = "Fenrus le Dévoreur",
		["Odo the Blindwatcher"] = "Odo l'Aveugle",
		["Razorclaw the Butcher"] = "Tranchegriffe le Boucher",
		["Wolf Master Nandos"] = "Maître-loup Nandos",

--Stratholme
		["Archivist Galford"] = "Archiviste Galford",
		["Balnazzar"] = "Balnazzar",
		["Baron Rivendare"] = "Baron Vaillefendre",
		["Baroness Anastari"] = "Baronne Anastari",
		["Black Guard Swordsmith"] = "Fabricant d'épées de la Garde noire",
		["Cannon Master Willey"] = "Maître canonnier Willey",
		["Crimson Hammersmith"] = "Forgeur de marteaux cramoisi",
		["Fras Siabi"] = "Fras Siabi",
		["Hearthsinger Forresten"] = "Chanteloge Forrestin",
		["Magistrate Barthilas"] = "Magistrat Barthilas",
		["Maleki the Pallid"] = "Maleki le Blafard",
		["Nerub'enkan"] = "Nerub'enkan",
		["Postmaster Malown"] = "Postier Malown",
		["Ramstein the Gorger"] = "Ramstein Grandgosier",
		["Skul"] = "Krân",
		["Stonespine"] = "Echine-de-pierre",
		["The Unforgiven"] = "Le Condamné",
		["Timmy the Cruel"] = "Timmy le Cruel",

--Sunwell Plateau
		["Kalecgos"] = "Kalecgos",
		["Sathrovarr the Corruptor"] = "Sathrovarr le Corrupteur",
		["Brutallus"] = "Brutallus",
		["Felmyst"] = "Gangrebrume",
		["Kil'jaeden"] = "Kil'jaeden",
		["M'uru"] = "M'uru",
		["Entropius"] = "Entropius",
		["The Eredar Twins"] = "Les jumelles érédars",
		["Lady Sacrolash"] = "Dame Sacrocingle",
		["Grand Warlock Alythess"] = "Grande démoniste Alythess",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "Dalliah l'Auspice-funeste",
		["Harbinger Skyriss"] = "Messager Cieuriss",
		["Warden Mellichar"] = "Gardien Mellichar",
		["Wrath-Scryer Soccothrates"] = "Scrute-courroux Soccothrates",
		["Zereketh the Unbound"] = "Zereketh le Délié",
--The Botanica
		["Commander Sarannis"] = "Commandant Sarannis",
		["High Botanist Freywinn"] = "Grand botaniste Freywinn",
		["Laj"] = "Laj",
		["Thorngrin the Tender"] = "Rirépine le Tendre",
		["Warp Splinter"] = "Brise-dimension",
--The Eye
		["Al'ar"] = "Al'ar",
		["Cosmic Infuser"] = "Masse d'infusion cosmique",
		["Devastation"] = "Dévastation",
		["Grand Astromancer Capernian"] = "Grande astromancienne Capernian",
		["High Astromancer Solarian"] = "Grande astromancienne Solarian",
		["Infinity Blades"] = "Lames d'infinité",
		["Kael'thas Sunstrider"] = "Kael'thas Haut-soleil",
		["Lord Sanguinar"] = "Seigneur Sanguinar",
		["Master Engineer Telonicus"] = "Maître ingénieur Telonicus",
		["Netherstrand Longbow"] = "Arc long brins-de-Néant",
		["Phaseshift Bulwark"] = "Rempart de déphasage",
		["Solarium Agent"] = "Agent du Solarium",
		["Solarium Priest"] = "Prêtre du Solarium",
		["Staff of Disintegration"] = "Bâton de désintégration",
		["Thaladred the Darkener"] = "Thaladred l'Assombrisseur",
		["Void Reaver"] = "Saccageur du Vide",
		["Warp Slicer"] = "Tranchoir dimensionnel",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "Gardien de porte Gyro-Meurtre",
		["Gatewatcher Iron-Hand"] = "Gardien de porte Main-en-fer",
		["Mechano-Lord Capacitus"] = "Mécano-seigneur Capacitus",
		["Nethermancer Sepethrea"] = "Néantomancien Sepethrea",
		["Pathaleon the Calculator"] = "Pathaleon le Calculateur",

--The Deadmines
		["Brainwashed Noble"] = "Noble manipulé",
		["Captain Greenskin"] = "Capitaine Vertepeau",
		["Cookie"] = "Macaron",
		["Edwin VanCleef"] = "Edwin VanCleef",
		["Foreman Thistlenettle"] = "Contremaître Crispechardon",
		["Gilnid"] = "Gilnid",
		["Marisa du'Paige"] = "Marisa du'Paige",
		["Miner Johnson"] = "Mineur Johnson",
		["Mr. Smite"] = "M. Châtiment",
		["Rhahk'Zor"] = "Rhahk'Zor",
		["Sneed"] = "Sneed",
		["Sneed's Shredder"] = "Déchiqueteur de Sneed",

--The Stockade
		["Bazil Thredd"] = "Bazil Thredd",
		["Bruegal Ironknuckle"] = "Bruegal Poing-de-fer",
		["Dextren Ward"] = "Dextren Ward",
		["Hamhock"] = "Hamhock",
		["Kam Deepfury"] = "Kam Furie-du-fond",
		["Targorr the Dread"] = "Targorr le Terrifiant",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "Atal'alarion",
		["Avatar of Hakkar"] = "Avatar d'Hakkar",
		["Dreamscythe"] = "Fauche-rêve",
		["Gasher"] = "Gasher",
		["Hazzas"] = "Hazzas",
		["Hukku"] = "Hukku",
		["Jade"] = "Jade",
		["Jammal'an the Prophet"] = "Jammal'an le prophète",
		["Kazkaz the Unholy"] = "Kazkaz l'Impie",
		["Loro"] = "Loro",
		["Mijan"] = "Mijan",
		["Morphaz"] = "Morphaz",
		["Ogom the Wretched"] = "Ogom le Misérable",
		["Shade of Eranikus"] = "Ombre d'Eranikus",
		["Veyzhak the Cannibal"] = "Veyzhak le Cannibale",
		["Weaver"] = "Tisserand",
		["Zekkis"] = "Zekkis",
		["Zolo"] = "Zolo",
		["Zul'Lor"] = "Zul'Lor",

--Uldaman
		["Ancient Stone Keeper"] = "Ancien Gardien des pierres",
		["Archaedas"] = "Archaedas",
		["Baelog"] = "Baelog",
		["Digmaster Shovelphlange"] = "Maître des fouilles Pellaphlange",
		["Galgann Firehammer"] = "Galgann Martel-de-feu",
		["Grimlok"] = "Grimlok",
		["Ironaya"] = "Ironaya",
		["Obsidian Sentinel"] = "Sentinelle d'obsidienne",
		["Revelosh"] = "Revelosh",

-- Ulduar
-- Halls of Lightning
		["General Bjarngrim"] = "Général Bjarngrim",
		["Ionar"] = "Ionar",
		["Loken"] = "Loken",
		["Volkhan"] = "Volkhan",
-- Halls of Stone
		["Krystallus"] = "Krystallus",
		["Maiden of Grief"] = "Damoiselle de peine",
		["Sjonnir the Ironshaper"] = "Sjonnir le Sculptefer",
		--["The Tribunal of Ages"] = true,

-- The Violet Hold
		--["Cyanigosa"] = true,
		--["Erekem"] = true,
		--["Ichoron"] = true,
		--["Lavanthor"] = true,
		--["Moragg"] = true,
		--["Xevozz"] = true,
		--["Zuramat the Obliterator"] = true,

--Wailing Caverns
		["Boahn"] = "Boahn",
		["Deviate Faerie Dragon"] = "Dragon féérique déviant",
		["Kresh"] = "Kresh",
		["Lady Anacondra"] = "Dame Anacondra",
		["Lord Cobrahn"] = "Seigneur Cobrahn",
		["Lord Pythas"] = "Seigneur Pythas",
		["Lord Serpentis"] = "Seigneur Serpentis",
		["Mad Magglish"] = "Magglish le Dingue",
		["Mutanus the Devourer"] = "Mutanus le Dévoreur",
		["Skum"] = "Skum",
		["Trigore the Lasher"] = "Trigore le Flagelleur",
		["Verdan the Everliving"] = "Verdan l'Immortel",

--World Bosses
		["Avalanchion"] = "Avalanchion",
		["Azuregos"] = "Azuregos",
		["Baron Charr"] = "Baron Charr",
		["Baron Kazum"] = "Baron Kazum",
		["Doom Lord Kazzak"] = "Seigneur funeste Kazzak",
		["Doomwalker"] = "Marche-funeste",
		["Emeriss"] = "Emeriss",
		["High Marshal Whirlaxis"] = "Haut maréchal Trombe",
		["Lethon"] = "Léthon",
		["Lord Skwol"] = "Seigneur Skwol",
		["Prince Skaldrenox"] = "Prince Skaldrenox ",
		["Princess Tempestria"] = "Princesse Tempestria",
		["Taerar"] = "Taerar",
		["The Windreaver"] = "Ouraganien",
		["Ysondre"] = "Ysondre",

--Zul'Aman
		["Akil'zon"] = "Akil'zon",
		["Halazzi"] = "Halazzi",
		["Jan'alai"] = "Jan'alai",
		["Malacrass"] = "Malacrass",
		["Nalorakk"] = "Nalorakk",
		["Zul'jin"] = "Zul'jin",
		["Hex Lord Malacrass"] = "Seigneur des maléfices Malacrass",

--Zul'Farrak
		["Antu'sul"] = "Antu'sul",
		["Chief Ukorz Sandscalp"] = "Chef Ukorz Scalpessable",
		["Dustwraith"] = "Ame en peine poudreuse",
		["Gahz'rilla"] = "Gahz'rilla",
		["Hydromancer Velratha"] = "Hydromancienne Velratha",
		["Murta Grimgut"] = "Murta Mornentraille",
		["Nekrum Gutchewer"] = "Nekrum Mâchetripes",
		["Oro Eyegouge"] = "Oro Crève-oeil ",
		["Ruuzlu"] = "Ruuzlu",
		["Sandarr Dunereaver"] = "Sandarr Ravadune",
		["Sandfury Executioner"] = "Bourreau Furie-des-sables",
		["Sergeant Bly"] = "Sergent Bly",
		["Shadowpriest Sezz'ziz"] = "Prêtre des ombres Sezz'ziz",
		["Theka the Martyr"] = "Theka le Martyr",
		["Witch Doctor Zum'rah"] = "Sorcier-docteur Zum'rah",
		["Zerillis"] = "Zerillis",
		["Zul'Farrak Dead Hero"] = "Héros mort de Zul'Farrak",

-- Zul'Drak
-- Gundrak
		["Drakkari Colossus"] = "Colosse drakkari",
		["Gal'darah"] = "Gal'darah",
		["Moorabi"] = "Moorabi",
		["Slad'ran"] = "Slad'ran",

--Zul'Gurub
		["Bloodlord Mandokir"] = "Seigneur sanglant Mandokir",
		["Gahz'ranka"] = "Gahz'ranka",
		["Gri'lek"] = "Gri'lek",
		["Hakkar"] = "Hakkar",
		["Hazza'rah"] = "Hazza'rah",
		["High Priest Thekal"] = "Grand prêtre Thekal",
		["High Priest Venoxis"] = "Grand prêtre Venoxis",
		["High Priestess Arlokk"] = "Grande prêtresse Arlokk",
		["High Priestess Jeklik"] = "Grande prêtresse Jeklik",
		["High Priestess Mar'li"] = "Grande prêtresse Mar'li",
		["Jin'do the Hexxer"] = "Jin'do le Maléficieur",
		["Renataki"] = "Renataki",
		["Wushoolay"] = "Wushoolay",

--Ring of Blood (where? an instance? should be in other file?)
		["Brokentoe"] = "Brisorteil",
		["Mogor"] = "Mogor",
		["Murkblood Twin"] = "Jumeau bourbesang",
		["Murkblood Twins"] = "Jumeaux bourbesang",
		["Rokdar the Sundered Lord"] = "Rokdar le Seigneur scindé",
		["Skra'gath"] = "Skra'gath",
		["The Blue Brothers"] = "Les Grands Bleus",
		["Warmaul Champion"] = "Champion Cogneguerre",
	}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "阿努比萨斯防御者",
		["Battleguard Sartura"] = "沙尔图拉",
		["C'Thun"] = "克苏恩",
		["Emperor Vek'lor"] = "维克洛尔大帝",
		["Emperor Vek'nilash"] = "维克尼拉斯大帝",
		["Eye of C'Thun"] = "克苏恩之眼",
		["Fankriss the Unyielding"] = "顽强的范克瑞斯",
		["Lord Kri"] = "克里勋爵",
		["Ouro"] = "奥罗",
		["Princess Huhuran"] = "哈霍兰公主",
		["Princess Yauj"] = "亚尔基公主",
		["The Bug Family"] = "虫子一家",
		["The Prophet Skeram"] = "预言者斯克拉姆",
		["The Twin Emperors"] = "双子皇帝",
		["Vem"] = "维姆",
		["Viscidus"] = "维希度斯",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "大主教玛拉达尔",
		["Shirrak the Dead Watcher"] = "死亡观察者希尔拉克",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "节点亲王沙法尔",
		["Pandemonius"] = "潘德莫努斯",
		["Tavarok"] = "塔瓦洛克",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "赫尔默大使",
		["Blackheart the Inciter"] = "煽动者布莱卡特",
		["Grandmaster Vorpil"] = "沃匹尔大师",
		["Murmur"] = "摩摩尔",
--Sethekk Halls
		["Anzu"] = "安苏",
		["Darkweaver Syth"] = "黑暗编织者塞斯",
		["Talon King Ikiss"] = "利爪之王艾吉斯",

--Blackfathom Deeps
		["Aku'mai"] = "阿库麦尔",
		["Baron Aquanis"] = "阿奎尼斯男爵",
		["Gelihast"] = "格里哈斯特",
		["Ghamoo-ra"] = "加摩拉",
		["Lady Sarevess"] = "萨利维丝",
		["Old Serra'kis"] = "瑟拉吉斯",
		["Twilight Lord Kelris"] = "梦游者克尔里斯",

--Blackrock Depths
		["Ambassador Flamelash"] = "弗莱拉斯大使",
		["Anger'rel"] = "安格雷尔",
		["Anub'shiah"] = "阿努希尔",
		["Bael'Gar"] = "贝尔加",
		["Chest of The Seven"] = "七贤之箱",--七贤的宝箱
		["Doom'rel"] = "杜姆雷尔",
		["Dope'rel"] = "多普雷尔",
		["Emperor Dagran Thaurissan"] = "达格兰·索瑞森大帝",
		["Eviscerator"] = "剜眼者",
		["Fineous Darkvire"] = "弗诺斯·达克维尔",
		["General Angerforge"] = "安格弗将军",
		["Gloom'rel"] = "格鲁雷尔",
		["Golem Lord Argelmach"] = "傀儡统帅阿格曼奇",
		["Gorosh the Dervish"] = "修行者高罗什",
		["Grizzle"] = "格里兹尔",
		["Hate'rel"] = "黑特雷尔",
		["Hedrum the Creeper"] = "爬行者赫杜姆",
		["High Interrogator Gerstahn"] = "审讯官格斯塔恩",
		["High Priestess of Thaurissan"] = "索瑞森高阶女祭司",
		["Houndmaster Grebmar"] = "驯犬者格雷布玛尔",
		["Hurley Blackbreath"] = "霍尔雷·黑须",
		["Lord Incendius"] = "伊森迪奥斯",
		["Lord Roccor"] = "洛考尔",
		["Magmus"] = "玛格姆斯",
		["Ok'thor the Breaker"] = "破坏者奥科索尔",
		["Panzor the Invincible"] = "无敌的潘佐尔",
		["Phalanx"] = "方阵",
		["Plugger Spazzring"] = "普拉格",
		["Princess Moira Bronzebeard"] = "铁炉堡公主茉艾拉·铜须",
		["Pyromancer Loregrain"] = "控火师罗格雷恩",
		["Ribbly Screwspigot"] = "雷布里·斯库比格特",
		["Seeth'rel"] = "西斯雷尔",
		["The Seven Dwarves"] = "七贤矮人",
		["Verek"] = "维雷克",
		["Vile'rel"] = "瓦勒雷尔",
		["Warder Stilgiss"] = "典狱官斯迪尔基斯",

--Blackrock Spire
--Lower 黑下
		["Bannok Grimaxe"] = "班诺克·巨斧",
		["Burning Felguard"] = "燃烧地狱卫士",--check 翻译成2种 燃烧地狱守卫
		["Crystal Fang"] = "水晶之牙",
		["Ghok Bashguud"] = "霍克·巴什古德",
		["Gizrul the Slavener"] = "奴役者基兹鲁尔",
		["Halycon"] = "哈雷肯",
		["Highlord Omokk"] = "欧莫克大王",
		["Mor Grayhoof"] = "莫尔·灰蹄",
		["Mother Smolderweb"] = "烟网蛛后",
		["Overlord Wyrmthalak"] = "维姆萨拉克",
		["Quartermaster Zigris"] = "军需官兹格雷斯",
		["Shadow Hunter Vosh'gajin"] = "暗影猎手沃什加斯",
		["Spirestone Battle Lord"] = "尖石统帅",
		["Spirestone Butcher"] = "尖石屠夫",
		["Spirestone Lord Magus"] = "尖石首席法师",
		["Urok Doomhowl"] = "乌洛克",
		["War Master Voone"] = "指挥官沃恩",
--Upper 黑上
		["General Drakkisath"] = "达基萨斯将军",
		["Goraluk Anvilcrack"] = "古拉鲁克",
		["Gyth"] = "盖斯",
		["Jed Runewatcher"] = "杰德",
		["Lord Valthalak"] = "瓦塔拉克公爵",
		["Pyroguard Emberseer"] = "烈焰卫士艾博希尔",
		["Solakar Flamewreath"] = "索拉卡·火冠",
		["The Beast"] = "比斯巨兽",
		["Warchief Rend Blackhand"] = "大酋长雷德·黑手",

--Blackwing Lair
		["Broodlord Lashlayer"] = "勒什雷尔",
		["Chromaggus"] = "克洛玛古斯",
		["Ebonroc"] = "埃博诺克",
		["Firemaw"] = "费尔默",
		["Flamegor"] = "弗莱格尔",
		["Grethok the Controller"] = "黑翼控制者",
		["Lord Victor Nefarius"] = "维克多·奈法里奥斯",
		["Nefarian"] = "奈法利安",
		["Razorgore the Untamed"] = "狂野的拉佐格尔",
		["Vaelastrasz the Corrupt"] = "堕落的瓦拉斯塔兹",

--Black Temple
		["Essence of Anger"] = "愤怒精华",
		["Essence of Desire"] = "欲望精华",
		["Essence of Suffering"] = "苦痛精华",
		["Gathios the Shatterer"] = "击碎者加西奥斯",
		["Gurtogg Bloodboil"] = "古尔图格·血沸",
		["High Nethermancer Zerevor"] = "高阶灵术师塞勒沃尔",
		["High Warlord Naj'entus"] = "高阶督军纳因图斯",
		["Illidan Stormrage"] = "伊利丹·怒风",
		["Illidari Council"] = "伊利达雷议会",
		["Lady Malande"] = "女公爵玛兰德",
		["Mother Shahraz"] = "莎赫拉丝主母",
		["Reliquary of Souls"] = "灵魂之匣",
		["Shade of Akama"] = "阿卡玛之影",
		["Supremus"] = "苏普雷姆斯",
		["Teron Gorefiend"] = "塔隆·血魔",
		["The Illidari Council"] = "伊利达雷议会",
		["Veras Darkshadow"] = "维尔莱斯·深影",

--Borean Tundra
--The Eye of Eternity
		--["Malygos"] = true,
--The Nexus
		--["Anomalus"] = true,
		--["Grand Magus Telestra"] = true,
		--["Keristrasza"] = true,
		--["Ormorok the Tree-Shaper"] = true,
--The Oculus
		--["Drakos the Interrogator"] = true,
		--["Ley-Guardian Eregos"] = true,
		--["Mage-Lord Urom"] = true,
		--["Varos Cloudstrider"] = true,

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "斯卡洛克上尉",
		["Epoch Hunter"] = "时空猎手",
		["Lieutenant Drake"] = "德拉克中尉",
--The Culling of Stratholme
		--["Meathook"] = true,
		--["Chrono-Lord Epoch"] = true,
		--["Mal'Ganis"] = true,
		--["Salramm the Fleshcrafter"] = true,
--The Black Morass
		["Aeonus"] = "埃欧努斯",
		["Chrono Lord Deja"] = "时空领主德亚",
		["Medivh"] = "麦迪文",
		["Temporus"] = "坦普卢斯",

--Chamber of Aspects
--The Obsidian Sanctum
		--["Sartharion"] = true,
		--["Shadron"] = true,
		--["Tenebron"] = true,
		--["Vesperon"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "盘牙精英",
		["Coilfang Strider"] = "盘牙巡逻者",
		["Fathom-Lord Karathress"] = "深水领主卡拉瑟雷斯",
		["Hydross the Unstable"] = "不稳定的海度斯",
		["Lady Vashj"] = "瓦丝琪",
		["Leotheras the Blind"] = "盲眼者莱欧瑟拉斯",
		["Morogrim Tidewalker"] = "莫洛格里·踏潮者",
		["Pure Spawn of Hydross"] = "纯净的海度斯爪牙",
		["Shadow of Leotheras"] = "莱欧瑟拉斯之影",
		["Tainted Spawn of Hydross"] = "污染的海度斯爪牙",
		["The Lurker Below"] = "鱼斯拉",
		["Tidewalker Lurker"] = "踏潮潜伏者",
--The Slave Pens
		["Mennu the Betrayer"] = "背叛者门努",
		["Quagmirran"] = "夸格米拉",
		["Rokmar the Crackler"] = "巨钳鲁克玛尔",
	 	["Ahune"] = "埃霍恩",
--The Steamvault
		["Hydromancer Thespia"] = "水术师瑟丝比娅",
		["Mekgineer Steamrigger"] = "机械师斯蒂里格",
		["Warlord Kalithresh"] = "督军卡利瑟里斯",
--The Underbog
		["Claw"] = "克劳恩",
		["Ghaz'an"] = "加兹安",
		["Hungarfen"] = "霍加尔芬",
		["Overseer Tidewrath"] = "工头泰德瓦斯",
		["Swamplord Musel'ek"] = "沼地领主穆塞雷克",
		["The Black Stalker"] = "黑色阔步者",

--Dire Maul 厄运
--Arena 竞技场
		["Mushgog"] = "姆斯高格",
		["Skarr the Unbreakable"] = "无敌的斯卡尔",
		["The Razza"] = "拉扎尔",
--East
		["Alzzin the Wildshaper"] = "奥兹恩",
		["Hydrospawn"] = "海多斯博恩",
		["Isalien"] = "伊萨利恩",
		["Lethtendris"] = "蕾瑟塔蒂丝",
		["Pimgib"] = "匹姆吉布",
		["Pusillin"] = "普希林",
		["Zevrim Thornhoof"] = "瑟雷姆·刺蹄",
--North
		["Captain Kromcrush"] = "克罗卡斯",
		["Cho'Rush the Observer"] = "观察者克鲁什",
		["Guard Fengus"] = "卫兵芬古斯",
		["Guard Mol'dar"] = "卫兵摩尔达",
		["Guard Slip'kik"] = "卫兵斯里基克",
		["King Gordok"] = "戈多克大王",
		["Knot Thimblejack's Cache"] = "诺特·希姆加克的储物箱",
		["Stomper Kreeg"] = "践踏者克雷格",
--West
		["Illyanna Ravenoak"] = "伊琳娜·暗木",
		["Immol'thar"] = "伊莫塔尔",
		["Lord Hel'nurath"] = "赫尔努拉斯",
		["Magister Kalendris"] = "卡雷迪斯镇长",
		["Prince Tortheldrin"] = "托塞德林王子",
		["Tendris Warpwood"] = "特迪斯·扭木",
		["Tsu'zee"] = "苏斯",

--Dragonblight
-- Ahn'kahet: The Old Kingdom
		--["Elder Nadox"] = true,
		--["Herald Volazj"]=  true,
		--["Jedoga Shadowseeker"] = true,
		--["Prince Taldaram"] = true,
--Azjol-Nerub
		--["Anub'arak"] = true,
		--["Hadronox"] = true,
		--["Krik'thir the Gatewatcher"] = true,

--Gnomeregan
		["Crowd Pummeler 9-60"] = "群体打击者9-60",
		["Dark Iron Ambassador"] = "黑铁大师",
		["Electrocutioner 6000"] = "电刑器6000型",
		["Grubbis"] = "格鲁比斯",
		["Mekgineer Thermaplugg"] = "麦克尼尔·瑟玛普拉格",
		["Techbot"] = "尖端机器人",
		["Viscous Fallout"] = "粘性辐射尘",

--Grizzly Hills
--Draktharon Keep
		--["King Dred"] = true,
		--["Novos the Summoner"] = true,
		--["The Prophet Tharon'ja"] = true,
		--["Trollgore"] = true,

--Gruul's Lair
		["Blindeye the Seer"] = "盲眼先知",
		["Gruul the Dragonkiller"] = "屠龙者格鲁尔",
		["High King Maulgar"] = "莫加尔大王",
		["Kiggler the Crazed"] = "疯狂的基戈尔",
		["Krosh Firehand"] = "克洛什·火拳",
		["Olm the Summoner"] = "召唤者沃尔姆",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "纳杉",
		["Omor the Unscarred"] = "无疤者奥摩尔",
		["Vazruden the Herald"] = "传令官瓦兹德",
		["Vazruden"] = "瓦兹德",
		["Watchkeeper Gargolmar"] = "巡视者加戈玛",
--Magtheridon's Lair
		["Hellfire Channeler"] = "地狱火导魔者",
		["Magtheridon"] = "玛瑟里顿",
--The Blood Furnace
		["Broggok"] = "布洛戈克",
		["Keli'dan the Breaker"] = "击碎者克里丹",
		["The Maker"] = "制造者",
--The Shattered Halls
		["Blood Guard Porung"] = "血卫士伯鲁恩",
		["Grand Warlock Nethekurse"] = "高阶术士奈瑟库斯",
		["Warbringer O'mrogg"] = "战争使者沃姆罗格",
		["Warchief Kargath Bladefist"] = "酋长卡加斯·刃拳",

--Howling Fjord
--Utgarde Keep
		--["Constructor & Controller"] = true, --these are one encounter, so we do this as an encounter name
		--["Dalronn the Controller"] = true,
		--["Ingvar the Plunderer"] = true,
		--["Prince Keleseth"] = true,
		--["Skarvald the Constructor"] = true,
--Utgarde Pinnacle
		--["Skadi the Ruthless"] = true,
		--["King Ymiron"] = true,
		--["Svala Sorrowgrave"] = true,
		--["Gortok Palehoof"] = true,

--Hyjal Summit
		["Anetheron"] = "安纳塞隆",
		["Archimonde"] = "阿克蒙德",
		["Azgalor"] = "阿兹加洛",
		["Kaz'rogal"] = "卡兹洛加",
		["Rage Winterchill"] = "雷基·冬寒",

--Karazhan
		["Arcane Watchman"] = "奥术看守",
		["Attumen the Huntsman"] = "猎手阿图门",
		["Chess Event"] = "国际象棋",
		["Dorothee"] = "多萝茜",
		["Dust Covered Chest"] = "灰尘覆盖的箱子",--nga数据库
		["Grandmother"] = "老奶奶",
		["Hyakiss the Lurker"] = "潜伏者希亚其斯",
		["Julianne"] = "朱丽叶",
		["Kil'rek"] = "基尔里克",
		["King Llane Piece"] = "莱恩国王",
		["Maiden of Virtue"] = "贞节圣女",
		["Midnight"] = "午夜",
		["Moroes"] = "莫罗斯",
		["Netherspite"] = "虚空幽龙",
		["Nightbane"] = "夜之魇",
		["Prince Malchezaar"] = "玛克扎尔王子",
		["Restless Skeleton"] = "无法安息的骷髅",
		["Roar"] = "胆小的狮子",
		["Rokad the Ravager"] = "蹂躏者洛卡德",
		["Romulo & Julianne"] = "罗密欧与朱丽叶",
		["Romulo"] = "罗密欧",
		["Shade of Aran"] = "埃兰之影",
		["Shadikith the Glider"] = "滑翔者沙德基斯",
		["Strawman"] = "稻草人",
		["Terestian Illhoof"] = "特雷斯坦·邪蹄",
		["The Big Bad Wolf"] = "大灰狼",
		["The Crone"] = "巫婆",
		["The Curator"] = "馆长",
		["Tinhead"] = "铁皮人",
		["Tito"] = "托托",
		["Warchief Blackhand Piece"] = "黑手酋长",

-- Magisters' Terrace (魔导师平台)
		["Kael'thas Sunstrider"] = "凯尔萨斯·逐日者",
		["Priestess Delrissa"] = "女祭司德莉希亚",
		["Selin Fireheart"] = "塞林·火心",
		["Vexallus"] = "维萨鲁斯",

--Maraudon
		["Celebras the Cursed"] = "被诅咒的塞雷布拉斯",
		["Gelk"] = "吉尔克",
		["Kolk"] = "考尔克",
		["Landslide"] = "兰斯利德",
		["Lord Vyletongue"] = "维利塔恩",
		["Magra"] = "玛格拉",
		["Maraudos"] = "玛拉多斯",
		["Meshlok the Harvester"] = "收割者麦什洛克",
		["Noxxion"] = "诺克赛恩",
		["Princess Theradras"] = "瑟莱德丝公主",
		["Razorlash"] = "锐刺鞭笞者",
		["Rotgrip"] = "洛特格里普",
		["Tinkerer Gizlock"] = "工匠吉兹洛克",
		["Veng"] = "温格",

--Molten Core
		["Baron Geddon"] = "迦顿男爵",
		["Cache of the Firelord"] = "火焰之王的宝箱",
		["Garr"] = "加尔",
		["Gehennas"] = "基赫纳斯",
		["Golemagg the Incinerator"] = "焚化者古雷曼格",
		["Lucifron"] = "鲁西弗隆",
		["Magmadar"] = "玛格曼达",
		["Majordomo Executus"] = "管理者埃克索图斯",
		["Ragnaros"] = "拉格纳罗斯",
		["Shazzrah"] = "沙斯拉尔",
		["Sulfuron Harbinger"] = "萨弗隆先驱者",

--Naxxramas
		["Anub'Rekhan"] = "阿努布雷坎",
		["Deathknight Understudy"] = "见习死亡骑士",
		["Feugen"] = "费尔根",
		["Four Horsemen Chest"] = "四骑士之箱",
		["Gluth"] = "格拉斯",
		["Gothik the Harvester"] = "收割者戈提克",
		["Grand Widow Faerlina"] = "黑女巫法琳娜",
		["Grobbulus"] = "格罗布鲁斯",
		["Heigan the Unclean"] = "肮脏的希尔盖",
		["Highlord Mograine"] = "大领主莫格莱尼",
		["Instructor Razuvious"] = "教官拉苏维奥斯",
		["Kel'Thuzad"] = "克尔苏加德",
		["Lady Blaumeux"] = "女公爵布劳缪克丝",
		["Loatheb"] = "洛欧塞布",
		["Maexxna"] = "迈克斯纳",
		["Noth the Plaguebringer"] = "瘟疫使者诺斯",
		["Patchwerk"] = "帕奇维克",
		["Sapphiron"] = "萨菲隆",
		["Sir Zeliek"] = "瑟里耶克爵士",
		["Stalagg"] = "斯塔拉格",
		["Thaddius"] = "塔迪乌斯",
		["Thane Korth'azz"] = "库尔塔兹领主",
		["The Four Horsemen"] = "四骑士",

--Onyxia's Lair
		["Onyxia"] = "奥妮克希亚",

--Ragefire Chasm
		["Bazzalan"] = "巴扎兰",
		["Jergosh the Invoker"] = "祈求者耶戈什",
		["Maur Grimtotem"] = "玛尔·恐怖图腾",
		["Taragaman the Hungerer"] = "饥饿者塔拉加曼",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "寒冰之王亚门纳尔",
		["Glutton"] = "暴食者",
		["Mordresh Fire Eye"] = "火眼莫德雷斯",
		["Plaguemaw the Rotting"] = "腐烂的普雷莫尔",
		["Ragglesnout"] = "拉戈斯诺特",
		["Tuten'kash"] = "图特卡什",

--Razorfen Kraul
		["Agathelos the Raging"] = "暴怒的阿迦赛罗斯",
		["Blind Hunter"] = "盲眼猎手",
		["Charlga Razorflank"] = "卡尔加·刺肋",
		["Death Speaker Jargba"] = "亡语者贾格巴",
		["Earthcaller Halmgar"] = "唤地者哈穆加",
		["Overlord Ramtusk"] = "主宰拉姆塔斯",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "阿努比萨斯守卫者",
		["Ayamiss the Hunter"] = "狩猎者阿亚米斯",
		["Buru the Gorger"] = "吞咽者布鲁",
		["General Rajaxx"] = "拉贾克斯将军",
		["Kurinnaxx"] = "库林纳克斯",
		["Lieutenant General Andorov"] = "安多洛夫中将",
		["Moam"] = "莫阿姆",
		["Ossirian the Unscarred"] = "无疤者奥斯里安",

--Scarlet Monastery
--Armory
		["Herod"] = "赫洛德",
--Cathedral
		["High Inquisitor Fairbanks"] = "大检察官法尔班克斯",
		["High Inquisitor Whitemane"] = "大检察官怀特迈恩",
		["Scarlet Commander Mograine"] = "血色十字军指挥官莫格莱尼",
--Graveyard
		["Azshir the Sleepless"] = "永醒的艾希尔",
		["Bloodmage Thalnos"] = "血法师萨尔诺斯",
		["Fallen Champion"] = "死灵勇士",
		["Interrogator Vishas"] = "审讯员韦沙斯",
		["Ironspine"] = "铁脊死灵",
		["Headless Horseman"] = "无头骑士",
--Library
		["Arcanist Doan"] = "奥法师杜安",
		["Houndmaster Loksey"] = "驯犬者洛克希",

--Scholomance
		["Blood Steward of Kirtonos"] = "基尔图诺斯的卫士",
		["Darkmaster Gandling"] = "黑暗院长加丁",
		["Death Knight Darkreaver"] = "死亡骑士达克雷尔",
		["Doctor Theolen Krastinov"] = "瑟尔林·卡斯迪诺夫教授",
		["Instructor Malicia"] = "讲师玛丽希亚",
		["Jandice Barov"] = "詹迪斯·巴罗夫",
		["Kirtonos the Herald"] = "传令官基尔图诺斯",
		["Kormok"] = "库尔莫克",
		["Lady Illucia Barov"] = "伊露希亚·巴罗夫",
		["Lord Alexei Barov"] = "阿雷克斯·巴罗夫",
		["Lorekeeper Polkelt"] = "博学者普克尔特",
		["Marduk Blackpool"] = "马杜克·布莱克波尔",
		["Ras Frostwhisper"] = "莱斯·霜语",
		["Rattlegore"] = "血骨傀儡",
		["The Ravenian"] = "拉文尼亚",
		["Vectus"] = "维克图斯",

--Shadowfang Keep
		["Archmage Arugal"] = "大法师阿鲁高",
		["Arugal's Voidwalker"] = "阿鲁高的虚空行者",
		["Baron Silverlaine"] = "席瓦莱恩男爵",
		["Commander Springvale"] = "指挥官斯普林瓦尔",
		["Deathsworn Captain"] = "死亡之誓",
		["Fenrus the Devourer"] = "吞噬者芬鲁斯",
		["Odo the Blindwatcher"] = "盲眼守卫奥杜",
		["Razorclaw the Butcher"] = "屠夫拉佐克劳",
		["Wolf Master Nandos"] = "狼王南杜斯",

--Stratholme
		["Archivist Galford"] = "档案管理员加尔福特",
		["Balnazzar"] = "巴纳扎尔",
		["Baron Rivendare"] = "瑞文戴尔男爵",
		["Baroness Anastari"] = "安娜丝塔丽男爵夫人",
		["Black Guard Swordsmith"] = "黑衣守卫铸剑师",
		["Cannon Master Willey"] = "炮手威利",
		["Crimson Hammersmith"] = "红衣铸锤师",
		["Fras Siabi"] = "弗拉斯·希亚比",
		["Hearthsinger Forresten"] = "弗雷斯特恩",
		["Magistrate Barthilas"] = "巴瑟拉斯镇长",
		["Maleki the Pallid"] = "苍白的玛勒基",
		["Nerub'enkan"] = "奈鲁布恩坎",
		["Postmaster Malown"] = "邮差马龙",
		["Ramstein the Gorger"] = "吞咽者拉姆斯登",
		["Skul"] = "斯库尔",
		["Stonespine"] = "石脊",
		["The Unforgiven"] = "不可宽恕者",
		["Timmy the Cruel"] = "悲惨的提米",

--Sunwell Plateau (太阳之井高地)
		["Kalecgos"] = "卡雷苟斯",
		["Sathrovarr the Corruptor"] = "腐蚀者萨索瓦尔",
		["Brutallus"] = "布鲁塔卢斯",
		["Felmyst"] = "菲米丝",
		["Kil'jaeden"] = "基尔加丹",
		["M'uru"] = "穆鲁",
		["Entropius"] = "熵魔",
		["The Eredar Twins"] = "艾瑞达双子",
		["Lady Sacrolash"] = "萨洛拉丝女王",
		["Grand Warlock Alythess"] = "高阶术士奥蕾塞丝",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "末日预言者达尔莉安",
		["Harbinger Skyriss"] = "预言者斯克瑞斯",
		["Warden Mellichar"] = "监护者梅里卡尔",
		["Wrath-Scryer Soccothrates"] = "天怒预言者苏克拉底",
		["Zereketh the Unbound"] = "自由的瑟雷凯斯",
--The Botanica
		["Commander Sarannis"] = "指挥官萨拉妮丝",
		["High Botanist Freywinn"] = "高级植物学家弗雷温",
		["Laj"] = "拉伊",
		["Thorngrin the Tender"] = "看管者索恩格林",
		["Warp Splinter"] = "迁跃扭木",
--The Eye
		["Al'ar"] = "奥",
		["Cosmic Infuser"] = "宇宙灌注者",
		["Devastation"] = "毁坏",
		["Grand Astromancer Capernian"] = "星术师卡波妮娅",
		["High Astromancer Solarian"] = "大星术师索兰莉安",
		["Infinity Blades"] = "无尽之刃",
		["Kael'thas Sunstrider"] = "凯尔萨斯·逐日者",
		["Lord Sanguinar"] = "萨古纳尔男爵",
		["Master Engineer Telonicus"] = "首席技师塔隆尼库斯",
		["Netherstrand Longbow"] = "灵弦长弓",
		["Phaseshift Bulwark"] = "相位壁垒",
		["Solarium Agent"] = "日晷密探",
		["Solarium Priest"] = "日晷祭司",
		["Staff of Disintegration"] = "瓦解法杖",
		["Thaladred the Darkener"] = "亵渎者萨拉德雷",
		["Void Reaver"] = "空灵机甲",
		["Warp Slicer"] = "迁跃切割者",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "看守者盖罗基尔",
		["Gatewatcher Iron-Hand"] = "看守者埃隆汉",
		["Mechano-Lord Capacitus"] = "机械领主卡帕西图斯",
		["Nethermancer Sepethrea"] = "灵术师塞比瑟蕾",
		["Pathaleon the Calculator"] = "计算者帕萨雷恩",

--The Deadmines
		["Brainwashed Noble"] = "被洗脑的贵族",
		["Captain Greenskin"] = "绿皮队长",
		["Cookie"] = "曲奇",
		["Edwin VanCleef"] = "艾德温·范克里夫",
		["Foreman Thistlenettle"] = "工头希斯耐特",
		["Gilnid"] = "基尔尼格",
		["Marisa du'Paige"] = "玛里莎·杜派格",
		["Miner Johnson"] = "矿工约翰森",
		["Mr. Smite"] = "重拳先生",
		["Rhahk'Zor"] = "拉克佐",
		["Sneed"] = "斯尼德",
		["Sneed's Shredder"] = "斯尼德的伐木机",

--The Stockade
		["Bazil Thredd"] = "巴基尔·斯瑞德",
		["Bruegal Ironknuckle"] = "布鲁高·铁拳",
		["Dextren Ward"] = "迪克斯特·瓦德",
		["Hamhock"] = "哈姆霍克",
		["Kam Deepfury"] = "卡姆·深怒",
		["Targorr the Dread"] = "可怕的塔格尔",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "阿塔拉利恩",
		["Avatar of Hakkar"] = "哈卡的化身",
		["Dreamscythe"] = "德姆塞卡尔",
		["Gasher"] = "加什尔",
		["Hazzas"] = "哈扎斯",
		["Hukku"] = "胡库",
		["Jade"] = "玉龙",
		["Jammal'an the Prophet"] = "预言者迦玛兰",
		["Kazkaz the Unholy"] = "邪恶的卡萨卡兹",
		["Loro"] = "洛若尔",
		["Mijan"] = "米杉",
		["Morphaz"] = "摩弗拉斯",
		["Ogom the Wretched"] = "可悲的奥戈姆",
		["Shade of Eranikus"] = "伊兰尼库斯的阴影",
		["Veyzhak the Cannibal"] = "食尸者维萨克",
		["Weaver"] = "德拉维沃尔",
		["Zekkis"] = "泽基斯",
		["Zolo"] = "祖罗",
		["Zul'Lor"] = "祖罗尔",

--Uldaman
		["Ancient Stone Keeper"] = "古代的石头看守者",
		["Archaedas"] = "阿扎达斯",
		["Baelog"] = "巴尔洛戈",
		["Digmaster Shovelphlange"] = "挖掘专家舒尔弗拉格",
		["Galgann Firehammer"] = "加加恩·火锤",
		["Grimlok"] = "格瑞姆洛克",
		["Ironaya"] = "艾隆纳亚",
		["Obsidian Sentinel"] = "黑曜石哨兵",
		["Revelosh"] = "鲁维罗什",

-- Ulduar
-- Halls of Lightning
		--["General Bjarngrim"] = true,
		--["Ionar"] = true,
		--["Loken"] = true,
		--["Volkhan"] = true,
-- Halls of Stone
		--["Krystallus"] = true,
		--["Maiden of Grief"] = true,
		--["Sjonnir the Ironshaper"] = true,
		--["The Tribunal of Ages"] = true,

-- The Violet Hold
		--["Cyanigosa"] = true,
		--["Erekem"] = true,
		--["Ichoron"] = true,
		--["Lavanthor"] = true,
		--["Moragg"] = true,
		--["Xevozz"] = true,
		--["Zuramat the Obliterator"] = true,

--Wailing Caverns
		["Boahn"] = "博艾恩",
		["Deviate Faerie Dragon"] = "变异精灵龙",
		["Kresh"] = "克雷什",
		["Lady Anacondra"] = "安娜科德拉",
		["Lord Cobrahn"] = "考布莱恩",
		["Lord Pythas"] = "皮萨斯",
		["Lord Serpentis"] = "瑟芬迪斯",
		["Mad Magglish"] = "疯狂的马格利什",
		["Mutanus the Devourer"] = "吞噬者穆坦努斯",
		["Skum"] = "斯卡姆",
		["Trigore the Lasher"] = "鞭笞者特里高雷",
		["Verdan the Everliving"] = "永生者沃尔丹",

--World Bosses
		["Avalanchion"] = "阿瓦兰奇奥",
		["Azuregos"] = "艾索雷葛斯",
		["Baron Charr"] = "火焰男爵查尔",
		["Baron Kazum"] = "卡苏姆男爵",
		["Doom Lord Kazzak"] = "末日领主卡扎克",
		["Doomwalker"] = "末日行者",
		["Emeriss"] = "艾莫莉丝",
		["High Marshal Whirlaxis"] = "大元帅维拉希斯",
		["Lethon"] = "莱索恩",
		["Lord Skwol"] = "斯古恩男爵",
		["Prince Skaldrenox"] = "斯卡德诺克斯王子",
		["Princess Tempestria"] = "泰比斯蒂亚公主",
		["Taerar"] = "泰拉尔",
		["The Windreaver"] = "烈风掠夺者",
		["Ysondre"] = "伊森德雷",

--Zul'Aman Add new bosses for 2.3
		["Akil'zon"] = "埃基尔松",
		["Halazzi"] = "哈尔拉兹",
		["Jan'alai"] = "加亚莱",
		["Malacrass"] = "玛拉卡斯",
		["Nalorakk"] = "纳洛拉克",
		["Zul'jin"] = "祖尔金",
		["Hex Lord Malacrass"] = "妖术领主玛拉卡斯",

--Zul'Farrak
		["Antu'sul"] = "安图苏尔",
		["Chief Ukorz Sandscalp"] = "乌克兹·沙顶",
		["Dustwraith"] = "灰尘怨灵",
		["Gahz'rilla"] = "加兹瑞拉",
		["Hydromancer Velratha"] = "水占师维蕾萨",
		["Murta Grimgut"] = "穆尔塔",
		["Nekrum Gutchewer"] = "耐克鲁姆",
		["Oro Eyegouge"] = "欧罗·血眼",
		["Ruuzlu"] = "卢兹鲁",
		["Sandarr Dunereaver"] = "杉达尔·沙掠者",
		["Sandfury Executioner"] = "沙怒刽子手",
		["Sergeant Bly"] = "布莱中士",
		["Shadowpriest Sezz'ziz"] = "暗影祭司塞瑟斯",
		["Theka the Martyr"] = "殉教者塞卡",
		["Witch Doctor Zum'rah"] = "巫医祖穆拉恩",
		["Zerillis"] = "泽雷利斯",
		["Zul'Farrak Dead Hero"] = "祖尔法拉克阵亡英雄",

-- Zul'Drak
-- Gundrak
		--["Drakkari Colossus"] = true,
		--["Gal'darah"] = true,
		--["Moorabi"] = true,
		--["Slad'ran"] = true,

--Zul'Gurub
		["Bloodlord Mandokir"] = "血领主曼多基尔",
		["Gahz'ranka"] = "加兹兰卡",
		["Gri'lek"] = "格里雷克",
		["Hakkar"] = "哈卡",
		["Hazza'rah"] = "哈扎拉尔",
		["High Priest Thekal"] = "高阶祭司塞卡尔",
		["High Priest Venoxis"] = "高阶祭司温诺希斯",
		["High Priestess Arlokk"] = "高阶祭司娅尔罗",
		["High Priestess Jeklik"] = "高阶祭司耶克里克",
		["High Priestess Mar'li"] = "高阶祭司玛尔里",
		["Jin'do the Hexxer"] = "妖术师金度",
		["Renataki"] = "雷纳塔基",
		["Wushoolay"] = "乌苏雷",

--Ring of Blood 位于 纳格兰
		["Brokentoe"] = "断蹄",
		["Mogor"] = "穆戈尔",
		["Murkblood Twin"] = "暗血双子",
		["Murkblood Twins"] = "暗血双子",
		["Rokdar the Sundered Lord"] = "裂石之王洛卡达尔",
		["Skra'gath"] = "瑟克拉加斯",
		["The Blue Brothers"] = "蓝色兄弟",--鲜血竞技场
		["Warmaul Champion"] = "战槌勇士",
	}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
--Ahn'Qiraj
		["Anubisath Defender"] = "阿努比薩斯防衛者",
		["Battleguard Sartura"] = "沙爾圖拉",
		["C'Thun"] = "克蘇恩",
		["Emperor Vek'lor"] = "維克洛爾大帝",
		["Emperor Vek'nilash"] = "維克尼拉斯大帝",
		["Eye of C'Thun"] = "克蘇恩之眼",
		["Fankriss the Unyielding"] = "不屈的范克里斯",
		["Lord Kri"] = "克里領主",
		["Ouro"] = "奧羅",
		["Princess Huhuran"] = "哈霍蘭公主",
		["Princess Yauj"] = "亞爾基公主",
		["The Bug Family"] = "蟲子家族",
		["The Prophet Skeram"] = "預言者斯克拉姆",
		["The Twin Emperors"] = "雙子皇帝",
		["Vem"] = "維姆",
		["Viscidus"] = "維希度斯",

--Auchindoun
--Auchenai Crypts
		["Exarch Maladaar"] = "主教瑪拉達爾",
		["Shirrak the Dead Watcher"] = "死亡看守者辛瑞克",
--Mana-Tombs
		["Nexus-Prince Shaffar"] = "奈薩斯王子薩法爾",
		["Pandemonius"] = "班提蒙尼厄斯",
		["Tavarok"] = "塔瓦洛克",
--Shadow Labyrinth
		["Ambassador Hellmaw"] = "海爾瑪大使",
		["Blackheart the Inciter"] = "煽動者黑心",
		["Grandmaster Vorpil"] = "領導者瓦皮歐",
		["Murmur"] = "莫爾墨",
--Sethekk Halls
		["Anzu"] = "安祖",
		["Darkweaver Syth"] = "暗法師希斯",
		["Talon King Ikiss"] = "鷹王伊奇斯",

--Blackfathom Deeps
		["Aku'mai"] = "阿庫麥爾",
		["Baron Aquanis"] = "阿奎尼斯男爵",
		["Gelihast"] = "格里哈斯特",
		["Ghamoo-ra"] = "加摩拉",
		["Lady Sarevess"] = "薩利維絲女士",
		["Old Serra'kis"] = "瑟拉吉斯",
		["Twilight Lord Kelris"] = "暮光領主克爾里斯",

--Blackrock Depths
		["Ambassador Flamelash"] = "弗萊拉斯大使",
		["Anger'rel"] = "安格雷爾",
		["Anub'shiah"] = "阿努希爾",
		["Bael'Gar"] = "貝爾加",
		["Chest of The Seven"] = "七賢之箱",
		["Doom'rel"] = "杜姆雷爾",
		["Dope'rel"] = "多普雷爾",
		["Emperor Dagran Thaurissan"] = "達格蘭·索瑞森大帝",
		["Eviscerator"] = "剜眼者",
		["Fineous Darkvire"] = "弗諾斯·達克維爾",
		["General Angerforge"] = "安格弗將軍",
		["Gloom'rel"] = "格魯雷爾",
		["Golem Lord Argelmach"] = "魔像領主阿格曼奇",
		["Gorosh the Dervish"] = "『修行者』高羅什",
		["Grizzle"] = "格里茲爾",
		["Hate'rel"] = "黑特雷爾",
		["Hedrum the Creeper"] = "『爬行者』赫杜姆",
		["High Interrogator Gerstahn"] = "審訊官格斯塔恩",
		["High Priestess of Thaurissan"] = "索瑞森高階女祭司",
		["Houndmaster Grebmar"] = "馴犬者格雷布瑪爾",
		["Hurley Blackbreath"] = "霍爾雷·黑鬚",
		["Lord Incendius"] = "伊森迪奧斯領主",
		["Lord Roccor"] = "洛考爾領主",
		["Magmus"] = "瑪格姆斯",
		["Ok'thor the Breaker"] = "『破壞者』奧科索爾",
		["Panzor the Invincible"] = "無敵的潘佐爾",
		["Phalanx"] = "法拉克斯",
		["Plugger Spazzring"] = "普拉格",
		["Princess Moira Bronzebeard"] = "茉艾拉·銅鬚公主",
		["Pyromancer Loregrain"] = "控火師羅格雷恩",
		["Ribbly Screwspigot"] = "雷布里·斯庫比格特",
		["Seeth'rel"] = "西斯雷爾",
		["The Seven Dwarves"] = "七賢人",
		["Verek"] = "維雷克",
		["Vile'rel"] = "瓦勒雷爾",
		["Warder Stilgiss"] = "守衛斯迪爾基斯",

--Blackrock Spire
--Lower
		["Bannok Grimaxe"] = "班諾克·巨斧",
		["Burning Felguard"] = "燃燒惡魔守衛",
		["Crystal Fang"] = "水晶之牙",
		["Ghok Bashguud"] = "霍克·巴什古德",
		["Gizrul the Slavener"] = "『奴役者』基茲盧爾",
		["Halycon"] = "哈雷肯",
		["Highlord Omokk"] = "歐莫克大王",
		["Mor Grayhoof"] = "莫爾·灰蹄",
		["Mother Smolderweb"] = "煙網蛛后",
		["Overlord Wyrmthalak"] = "維姆薩拉克主宰",
		["Quartermaster Zigris"] = "軍需官茲格雷斯",
		["Shadow Hunter Vosh'gajin"] = "暗影獵手沃許加斯",
		["Spirestone Battle Lord"] = "尖石戰鬥統帥",
		["Spirestone Butcher"] = "尖石屠夫",
		["Spirestone Lord Magus"] = "尖石首席魔導師",
		["Urok Doomhowl"] = "烏洛克",
		["War Master Voone"] = "指揮官沃恩",
--Upper
		["General Drakkisath"] = "達基薩斯將軍",
		["Goraluk Anvilcrack"] = "古拉魯克",
		["Gyth"] = "蓋斯",
		["Jed Runewatcher"] = "傑德",
		["Lord Valthalak"] = "瓦薩拉克領主",
		["Pyroguard Emberseer"] = "烈焰衛士艾博希爾",
		["Solakar Flamewreath"] = "索拉卡·火冠",
		["The Beast"] = "比斯巨獸",
		["Warchief Rend Blackhand"] = "大酋長雷德·黑手",

--Blackwing Lair
		["Broodlord Lashlayer"] = "龍領主勒西雷爾",
		["Chromaggus"] = "克洛瑪古斯",
		["Ebonroc"] = "埃博諾克",
		["Firemaw"] = "費爾默",
		["Flamegor"] = "弗萊格爾",
		["Grethok the Controller"] = "『控制者』葛瑞托克",
		["Lord Victor Nefarius"] = "維克多·奈法利斯領主",
		["Nefarian"] = "奈法利安",
		["Razorgore the Untamed"] = "狂野的拉佐格爾",
		["Vaelastrasz the Corrupt"] = "墮落的瓦拉斯塔茲",

--Black Temple
		["Essence of Anger"] = "憤怒精華",
		["Essence of Desire"] = "慾望精華",
		["Essence of Suffering"] = "受難精華",
		["Gathios the Shatterer"] = "粉碎者高希歐",
		["Gurtogg Bloodboil"] = "葛塔格·血沸",
		["High Nethermancer Zerevor"] = "高等虛空術師札瑞佛",
		["High Warlord Naj'entus"] = "高階督軍納珍塔斯",
		["Illidan Stormrage"] = "伊利丹·怒風",
		["Illidari Council"] = "伊利達瑞議事",
		["Lady Malande"] = "瑪蘭黛女士",
		["Mother Shahraz"] = "薩拉茲女士",
		["Reliquary of Souls"] = "靈魂之匣",
		["Shade of Akama"] = "阿卡瑪的黑暗面",
		["Supremus"] = "瑟普莫斯",
		["Teron Gorefiend"] = "泰朗·血魔",
		["The Illidari Council"] = "伊利達瑞議事",
		["Veras Darkshadow"] = "維拉斯·深影",

--Borean Tundra
--The Eye of Eternity
		["Malygos"] = "瑪里苟斯",
--The Nexus
		["Anomalus"] = "艾諾瑪路斯",
		["Grand Magus Telestra"] = "大魔導師特雷斯翠",
		["Keristrasza"] = "凱瑞史卓莎",
		["Ormorok the Tree-Shaper"] = "『樹木造形者』歐爾莫洛克",
--The Oculus
		["Drakos the Interrogator"] = "『審問者』德拉高斯",
		["Ley-Guardian Eregos"] = "地脈守護者伊瑞茍斯",
		["Mage-Lord Urom"] = "法師領主厄隆",
		["Varos Cloudstrider"] = "瓦羅斯·雲行者",

--Caverns of Time
--Old Hillsbrad Foothills
		["Captain Skarloc"] = "史卡拉克上尉",
		["Epoch Hunter"] = "紀元狩獵者",
		["Lieutenant Drake"] = "中尉崔克",
--The Culling of Stratholme
		["Meathook"] = "肉鉤",
		["Chrono-Lord Epoch"] = "紀元時間領主",
		["Mal'Ganis"] = "瑪爾加尼斯",
		["Salramm the Fleshcrafter"] = "『血肉工匠』塞歐朗姆",
--The Black Morass
		["Aeonus"] = "艾奧那斯",
		["Chrono Lord Deja"] = "時間領主迪賈",
		["Medivh"] = "麥迪文",
		["Temporus"] = "坦普拉斯",

--Chamber of Aspects
--The Obsidian Sanctum
		--["Sartharion"] = true,
		--["Shadron"] = true,
		--["Tenebron"] = true,
		--["Vesperon"] = true,

--Coilfang Reservoir
--Serpentshrine Cavern
		["Coilfang Elite"] = "盤牙精英",
		["Coilfang Strider"] = "盤牙旅行者",
		["Fathom-Lord Karathress"] = "深淵之王卡拉薩瑞斯",
		["Hydross the Unstable"] = "不穩定者海卓司",
		["Lady Vashj"] = "瓦許女士",
		["Leotheras the Blind"] = "『盲目者』李奧薩拉斯",
		["Morogrim Tidewalker"] = "莫洛葛利姆·潮行者",
		["Pure Spawn of Hydross"] = "純正的海卓司子嗣",
		["Shadow of Leotheras"] = "李奧薩拉斯的陰影",
		["Tainted Spawn of Hydross"] = "腐化的海卓司之子",
		["The Lurker Below"] = "海底潛伏者",
		["Tidewalker Lurker"] = "潮行者潛伏者",
--The Slave Pens
		["Mennu the Betrayer"] = "背叛者曼紐",
		["Quagmirran"] = "奎克米瑞",
		["Rokmar the Crackler"] = "爆裂者洛克瑪",
		["Ahune"] = "艾胡恩",

--The Steamvault
		["Hydromancer Thespia"] = "海法師希斯比亞",
		["Mekgineer Steamrigger"] = "米克吉勒·蒸氣操控者",
		["Warlord Kalithresh"] = "督軍卡利斯瑞",
--The Underbog
		["Claw"] = "裂爪",
		["Ghaz'an"] = "高薩安",
		["Hungarfen"] = "飢餓之牙",
		["Overseer Tidewrath"] = "監督者泰洛斯",
		["Swamplord Musel'ek"] = "沼澤之王莫斯萊克",
		["The Black Stalker"] = "黑色捕獵者",

--Dire Maul
--Arena
		["Mushgog"] = "姆斯高格",
		["Skarr the Unbreakable"] = "無敵的斯卡爾",
		["The Razza"] = "拉札",
--East
		["Alzzin the Wildshaper"] = "『狂野變形者』奧茲恩",
		["Hydrospawn"] = "海多斯博恩",
		["Isalien"] = "依薩利恩",
		["Lethtendris"] = "蕾瑟塔蒂絲",
		["Pimgib"] = "匹姆吉布",
		["Pusillin"] = "普希林",
		["Zevrim Thornhoof"] = "瑟雷姆·刺蹄",
--North
		["Captain Kromcrush"] = "克羅卡斯",
		["Cho'Rush the Observer"] = "『觀察者』克魯什",
		["Guard Fengus"] = "衛兵芬古斯",
		["Guard Mol'dar"] = "衛兵摩爾達",
		["Guard Slip'kik"] = "衛兵斯里基克",
		["King Gordok"] = "戈多克大王",
		["Knot Thimblejack's Cache"] = "諾特·希姆加克的儲物箱",
		["Stomper Kreeg"] = "踐踏者克雷格",
--West
		["Illyanna Ravenoak"] = "伊琳娜·鴉橡",
		["Immol'thar"] = "伊莫塔爾",
		["Lord Hel'nurath"] = "赫爾努拉斯領主",
		["Magister Kalendris"] = "卡雷迪斯鎮長",
		["Prince Tortheldrin"] = "托塞德林王子",
		["Tendris Warpwood"] = "特迪斯·扭木",
		["Tsu'zee"] = "蘇斯",

--Dragonblight
-- Ahn'kahet: The Old Kingdom
		--["Elder Nadox"] = true,
		["Herald Volazj"]=  "信使沃菈齊",
		["Jedoga Shadowseeker"] = "潔杜佳·尋影者",
		["Prince Taldaram"] = "泰爾達朗王子",
--Azjol-Nerub
		["Anub'arak"] = "阿努巴拉克",
		["Hadronox"] = "哈卓諾克斯",
		["Krik'thir the Gatewatcher"] = "『守門者』齊力克西爾",

--Gnomeregan
		["Crowd Pummeler 9-60"] = "群體打擊者9-60",
		["Dark Iron Ambassador"] = "黑鐵大使",
		["Electrocutioner 6000"] = "電刑器6000型",
		["Grubbis"] = "格魯比斯",
		["Mekgineer Thermaplugg"] = "麥克尼爾·瑟瑪普拉格",
		["Techbot"] = "尖端機器人",
		["Viscous Fallout"] = "粘性輻射塵",

--Grizzly Hills
--Draktharon Keep
		["King Dred"] = "崔德國王",
		["Novos the Summoner"] = "『召喚者』諾沃司",
		["The Prophet Tharon'ja"] = "預言者薩隆杰",
		["Trollgore"] = "血角食人妖",

--Gruul's Lair
		["Blindeye the Seer"] = "先知盲眼",
		["Gruul the Dragonkiller"] = "弒龍者戈魯爾",
		["High King Maulgar"] = "大君王莫卡爾",
		["Kiggler the Crazed"] = "瘋癲者奇克勒",
		["Krosh Firehand"] = "克羅斯·火手",
		["Olm the Summoner"] = "召喚者歐莫",

--Hellfire Citadel
--Hellfire Ramparts
		["Nazan"] = "納桑",
		["Omor the Unscarred"] = "無疤者歐瑪爾",
		["Vazruden the Herald"] = "『信使』維斯路登",
		["Vazruden"] = "維斯路登",
		["Watchkeeper Gargolmar"] = "看護者卡爾古瑪",
--Magtheridon's Lair
		["Hellfire Channeler"] = "地獄火導魔師",
		["Magtheridon"] = "瑪瑟里頓",
--The Blood Furnace
		["Broggok"] = "布洛克",
		["Keli'dan the Breaker"] = "『破壞者』凱利丹",
		["The Maker"] = "創造者",
--The Shattered Halls
		["Blood Guard Porung"] = "血衛士波洛克",
		["Grand Warlock Nethekurse"] = "大術士奈德克斯",
		["Warbringer O'mrogg"] = "戰爭製造者·歐姆拉格",
		["Warchief Kargath Bladefist"] = "大酋長卡加斯·刃拳",

--Howling Fjord
--Utgarde Keep
		--["Constructor & Controller"] = true, --these are one encounter, so we do this as an encounter name
		["Dalronn the Controller"] = "『控制者』達隆恩",
		["Ingvar the Plunderer"] = "『盜掠者』因格瓦",
		["Prince Keleseth"] = "凱雷希斯王子",
		["Skarvald the Constructor"] = "『建造者』史卡沃",
--Utgarde Pinnacle
		["Skadi the Ruthless"] = "『無情』斯卡迪",
		["King Ymiron"] = "依米倫國王",
		["Svala Sorrowgrave"] = "司瓦拉禍害使者",
		["Gortok Palehoof"] = "戈托克·白蹄",

--Hyjal Summit
		["Anetheron"] = "安納塞隆",
		["Archimonde"] = "阿克蒙德",
		["Azgalor"] = "亞茲加洛",
		["Kaz'rogal"] = "卡茲洛加",
		["Rage Winterchill"] = "瑞齊·凜冬",

--Karazhan
		["Arcane Watchman"] = "秘法警備者",
		["Attumen the Huntsman"] = "獵人阿圖曼",
		["Chess Event"] = "西洋棋事件",
		["Dorothee"] = "桃樂絲",
		["Dust Covered Chest"] = "滿佈灰塵箱子",
		["Grandmother"] = "外婆",
		["Hyakiss the Lurker"] = "潛伏者亞奇斯",
		["Julianne"] = "茱麗葉",
		["Kil'rek"] = "基瑞克",
		["King Llane Piece"] = "萊恩王棋子",
		["Maiden of Virtue"] = "貞潔聖女",
		["Midnight"] = "午夜",
		["Moroes"] = "摩洛",
		["Netherspite"] = "尼德斯",
		["Nightbane"] = "夜禍",
		["Prince Malchezaar"] = "莫克札王子",
		["Restless Skeleton"] = "永不安息的骷髏",
		["Roar"] = "獅子",
		["Rokad the Ravager"] = "劫毀者拉卡",
		["Romulo & Julianne"] = "羅慕歐與茱麗葉",
		["Romulo"] = "羅慕歐",
		["Shade of Aran"] = "埃蘭之影",
		["Shadikith the Glider"] = "滑翔者薛迪依斯",
		["Strawman"] = "稻草人",
		["Terestian Illhoof"] = "泰瑞斯提安·疫蹄",
		["The Big Bad Wolf"] = "大野狼",
		["The Crone"] = "老巫婆",
		["The Curator"] = "館長",
		["Tinhead"] = "機器人",
		["Tito"] = "多多",
		["Warchief Blackhand Piece"] = "黑手大酋長棋子",

-- Magisters' Terrace
		["Kael'thas Sunstrider"] = "凱爾薩斯·逐日者",
		["Priestess Delrissa"] = "女牧師戴利莎",
		["Selin Fireheart"] = "賽林·炎心",
		["Vexallus"] = "維克索魯斯",

--Maraudon
		["Celebras the Cursed"] = "被詛咒的塞雷布拉斯",
		["Gelk"] = "吉爾克",
		["Kolk"] = "考爾克",
		["Landslide"] = "蘭斯利德",
		["Lord Vyletongue"] = "維利塔恩領主",
		["Magra"] = "瑪格拉",
		["Maraudos"] = "瑪拉多斯",
		["Meshlok the Harvester"] = "『收割者』麥什洛克",
		["Noxxion"] = "諾克賽恩",
		["Princess Theradras"] = "瑟萊德絲公主",
		["Razorlash"] = "銳刺鞭笞者",
		["Rotgrip"] = "洛特格里普",
		["Tinkerer Gizlock"] = "技工吉茲洛克",
		["Veng"] = "溫格",

--Molten Core
		["Baron Geddon"] = "迦頓男爵",
		["Cache of the Firelord"] = "火焰之王的寶箱",
		["Garr"] = "加爾",
		["Gehennas"] = "基赫納斯",
		["Golemagg the Incinerator"] = "『焚化者』古雷曼格",
		["Lucifron"] = "魯西弗隆",
		["Magmadar"] = "瑪格曼達",
		["Majordomo Executus"] = "管理者埃克索圖斯",
		["Ragnaros"] = "拉格納羅斯",
		["Shazzrah"] = "沙斯拉爾",
		["Sulfuron Harbinger"] = "薩弗隆先驅者",

--Naxxramas
		["Anub'Rekhan"] = "阿努比瑞克漢",
		["Deathknight Understudy"] = "死亡騎士實習者",
		["Feugen"] = "伏晨",
		["Four Horsemen Chest"] = "四騎士箱子",
		["Gluth"] = "古魯斯",
		["Gothik the Harvester"] = "『收割者』高希",
		["Grand Widow Faerlina"] = "大寡婦費琳娜",
		["Grobbulus"] = "葛羅巴斯",
		["Heigan the Unclean"] = "『骯髒者』海根",
		["Highlord Mograine"] = "大領主莫格萊尼",
		["Instructor Razuvious"] = "講師拉祖維斯",
		["Kel'Thuzad"] = "科爾蘇加德",
		["Lady Blaumeux"] = "布洛莫斯女士",
		["Loatheb"] = "憎恨者",
		["Maexxna"] = "梅克絲娜",
		["Noth the Plaguebringer"] = "『瘟疫使者』諾斯",
		["Patchwerk"] = "縫補者",
		["Sapphiron"] = "薩菲隆",
		["Sir Zeliek"] = "札里克爵士",
		["Stalagg"] = "斯塔拉格",
		["Thaddius"] = "泰迪斯",
		["Thane Korth'azz"] = "寇斯艾茲族長",
		["The Four Horsemen"] = "四騎士",

--Onyxia's Lair
		["Onyxia"] = "奧妮克希亞",

--Ragefire Chasm
		["Bazzalan"] = "巴札蘭",
		["Jergosh the Invoker"] = "『塑能師』耶戈什",
		["Maur Grimtotem"] = "瑪爾·恐怖圖騰",
		["Taragaman the Hungerer"] = "『飢餓者』塔拉加曼",

--Razorfen Downs
		["Amnennar the Coldbringer"] = "『寒冰使者』亞門納爾",
		["Glutton"] = "暴食者",
		["Mordresh Fire Eye"] = "火眼莫德雷斯",
		["Plaguemaw the Rotting"] = "腐爛的普雷莫爾",
		["Ragglesnout"] = "拉戈斯諾特",
		["Tuten'kash"] = "圖特卡什",

--Razorfen Kraul
		["Agathelos the Raging"] = "暴怒的阿迦賽羅斯",
		["Blind Hunter"] = "盲眼獵手",
		["Charlga Razorflank"] = "卡爾加·刺肋",
		["Death Speaker Jargba"] = "亡語者賈格巴",
		["Earthcaller Halmgar"] = "喚地者哈穆加",
		["Overlord Ramtusk"] = "拉姆塔斯主宰",

--Ruins of Ahn'Qiraj
		["Anubisath Guardian"] = "阿努比薩斯守衛者",
		["Ayamiss the Hunter"] = "『狩獵者』阿亞米斯",
		["Buru the Gorger"] = "『暴食者』布魯",
		["General Rajaxx"] = "拉賈克斯將軍",
		["Kurinnaxx"] = "庫林納克斯",
		["Lieutenant General Andorov"] = "安多洛夫中將",
		["Moam"] = "莫阿姆",
		["Ossirian the Unscarred"] = "『無疤者』奧斯里安",

--Scarlet Monastery
--Armory
		["Herod"] = "赫洛德",
--Cathedral
		["High Inquisitor Fairbanks"] = "高等審判官法爾班克斯",
		["High Inquisitor Whitemane"] = "高等審判官懷特邁恩",
		["Scarlet Commander Mograine"] = "血色十字軍指揮官莫格萊尼",
--Graveyard
		["Azshir the Sleepless"] = "不眠的艾希爾",
		["Bloodmage Thalnos"] = "血法師薩爾諾斯",
		["Fallen Champion"] = "亡靈勇士",
		["Interrogator Vishas"] = "審訊員韋沙斯",
		["Ironspine"] = "鐵脊死靈",
		["Headless Horseman"] = "無頭騎士",
--Library
		["Arcanist Doan"] = "秘法師杜安",
		["Houndmaster Loksey"] = "馴犬者洛克希",

--Scholomance
		["Blood Steward of Kirtonos"] = "基爾圖諾斯的衛士",
		["Darkmaster Gandling"] = "黑暗院長加丁",
		["Death Knight Darkreaver"] = "死亡騎士達克雷爾",
		["Doctor Theolen Krastinov"] = "瑟爾林·卡斯迪諾夫教授",
		["Instructor Malicia"] = "講師瑪麗希亞",
		["Jandice Barov"] = "詹迪斯·巴羅夫",
		["Kirtonos the Herald"] = "傳令官基爾圖諾斯",
		["Kormok"] = "科爾莫克",
		["Lady Illucia Barov"] = "伊露希亞·巴羅夫女士",
		["Lord Alexei Barov"] = "阿萊克斯·巴羅夫領主",
		["Lorekeeper Polkelt"] = "博學者普克爾特",
		["Marduk Blackpool"] = "馬杜克·布萊克波爾",
		["Ras Frostwhisper"] = "萊斯·霜語",
		["Rattlegore"] = "血骨傀儡",
		["The Ravenian"] = "拉文尼亞",
		["Vectus"] = "維克圖斯",

--Shadowfang Keep
		["Archmage Arugal"] = "大法師阿魯高",
		["Arugal's Voidwalker"] = "阿魯高的虛無行者",
		["Baron Silverlaine"] = "席瓦萊恩男爵",
		["Commander Springvale"] = "指揮官斯普林瓦爾",
		["Deathsworn Captain"] = "死亡誓言者隊長",
		["Fenrus the Devourer"] = "『吞噬者』芬魯斯",
		["Odo the Blindwatcher"] = "『盲眼守衛』奧杜",
		["Razorclaw the Butcher"] = "屠夫拉佐克勞",
		["Wolf Master Nandos"] = "狼王南杜斯",

--Stratholme
		["Archivist Galford"] = "檔案管理員加爾福特",
		["Balnazzar"] = "巴納札爾",
		["Baron Rivendare"] = "瑞文戴爾男爵",
		["Baroness Anastari"] = "安娜絲塔麗男爵夫人",
		["Black Guard Swordsmith"] = "黑衣守衛鑄劍師",
		["Cannon Master Willey"] = "砲手威利",
		["Crimson Hammersmith"] = "紅衣鑄錘師",
		["Fras Siabi"] = "弗拉斯·希亞比",
		["Hearthsinger Forresten"] = "弗雷斯特恩",
		["Magistrate Barthilas"] = "巴瑟拉斯鎮長",
		["Maleki the Pallid"] = "蒼白的瑪勒基",
		["Nerub'enkan"] = "奈幽布恩坎",
		["Postmaster Malown"] = "郵差瑪羅恩",
		["Ramstein the Gorger"] = "『暴食者』拉姆斯登",
		["Skul"] = "斯庫爾",
		["Stonespine"] = "石脊",
		["The Unforgiven"] = "不可寬恕者",
		["Timmy the Cruel"] = "悲慘的提米",

--Sunwell Plateau
		["Kalecgos"] = "卡雷苟斯",
		["Sathrovarr the Corruptor"] = "『墮落者』塞斯諾瓦",
		["Brutallus"] = "布魯托魯斯",
		["Felmyst"] = "魔龍謎霧",
		["The Eredar Twins"] = "埃雷達爾雙子",
		["Kil'jaeden"] = "基爾加丹",
		["M'uru"] = "莫魯",
		["Entropius"] = "安卓普斯",
		["Lady Sacrolash"] = "莎珂蕾希女士",
		["Grand Warlock Alythess"] = "大術士艾黎瑟絲",

--Tempest Keep
--The Arcatraz
		["Dalliah the Doomsayer"] = "末日預言者達利亞",
		["Harbinger Skyriss"] = "先驅者史蓋力司",
		["Warden Mellichar"] = "看守者米利恰爾",
		["Wrath-Scryer Soccothrates"] = "怒鐮者索寇斯瑞特",
		["Zereketh the Unbound"] = "無約束的希瑞奇斯",
--The Botanica
		["Commander Sarannis"] = "指揮官薩瑞尼斯",
		["High Botanist Freywinn"] = "大植物學家費瑞衛恩",
		["Laj"] = "拉杰",
		["Thorngrin the Tender"] = "『看管者』索古林",
		["Warp Splinter"] = "扭曲分裂者",
--The Eye
		["Al'ar"] = "歐爾",
		["Cosmic Infuser"] = "宇宙灌溉者",
		["Devastation"] = "毀滅",
		["Grand Astromancer Capernian"] = "大星術師卡普尼恩",
		["High Astromancer Solarian"] = "高階星術師索拉瑞恩",
		["Infinity Blades"] = "無盡之刃",
		["Kael'thas Sunstrider"] = "凱爾薩斯·逐日者",
		["Lord Sanguinar"] = "桑古納爾領主",
		["Master Engineer Telonicus"] = "工程大師泰隆尼卡斯",
		["Netherstrand Longbow"] = "虛空之絃長弓",
		["Phaseshift Bulwark"] = "相位壁壘",
		["Solarium Agent"] = "日光之室密探",
		["Solarium Priest"] = "日光之室牧師",
		["Staff of Disintegration"] = "瓦解之杖",
		["Thaladred the Darkener"] = "扭曲預言家薩拉瑞德",
		["Void Reaver"] = "虛無搶奪者",
		["Warp Slicer"] = "扭曲分割者",
--The Mechanar
		["Gatewatcher Gyro-Kill"] = "看守者蓋洛奇歐",
		["Gatewatcher Iron-Hand"] = "看守者鐵手",
		["Mechano-Lord Capacitus"] = "機械王卡帕希特斯",
		["Nethermancer Sepethrea"] = "虛空術師賽菲瑞雅",
		["Pathaleon the Calculator"] = "操縱者帕薩里歐",

--The Deadmines
		["Brainwashed Noble"] = "被洗腦的貴族",
		["Captain Greenskin"] = "綠皮隊長",
		["Cookie"] = "廚師",
		["Edwin VanCleef"] = "艾德溫·范克里夫",
		["Foreman Thistlenettle"] = "工頭希斯耐特",
		["Gilnid"] = "基爾尼格",
		["Marisa du'Paige"] = "瑪里莎·杜派格",
		["Miner Johnson"] = "礦工約翰森",
		["Mr. Smite"] = "重拳先生",
		["Rhahk'Zor"] = "拉克佐",
		["Sneed"] = "斯尼德",
		["Sneed's Shredder"] = "斯尼德的伐木機",

--The Stockade
		["Bazil Thredd"] = "巴基爾·斯瑞德",
		["Bruegal Ironknuckle"] = "布魯戈·艾爾克納寇",
		["Dextren Ward"] = "迪克斯特·瓦德",
		["Hamhock"] = "哈姆霍克",
		["Kam Deepfury"] = "卡姆·深怒",
		["Targorr the Dread"] = "可怕的塔高爾",

--The Temple of Atal'Hakkar
		["Atal'alarion"] = "阿塔拉利恩",
		["Avatar of Hakkar"] = "哈卡的化身",
		["Dreamscythe"] = "德姆塞卡爾",
		["Gasher"] = "加什爾",
		["Hazzas"] = "哈札斯",
		["Hukku"] = "胡庫",
		["Jade"] = "玉龍",
		["Jammal'an the Prophet"] = "『預言者』迦瑪蘭",
		["Kazkaz the Unholy"] = "邪惡的卡薩卡茲",
		["Loro"] = "洛若爾",
		["Mijan"] = "米杉",
		["Morphaz"] = "摩弗拉斯",
		["Ogom the Wretched"] = "可悲的奧戈姆",
		["Shade of Eranikus"] = "伊蘭尼庫斯的陰影",
		["Veyzhak the Cannibal"] = "『食人者』維薩克",
		["Weaver"] = "德拉維沃爾",
		["Zekkis"] = "澤基斯",
		["Zolo"] = "祖羅",
		["Zul'Lor"] = "祖羅爾",

--Uldaman
		["Ancient Stone Keeper"] = "古代的石頭看守者",
		["Archaedas"] = "阿札達斯",
		["Baelog"] = "巴爾洛戈",
		["Digmaster Shovelphlange"] = "挖掘專家舒爾弗拉格",
		["Galgann Firehammer"] = "加加恩·火錘",
		["Grimlok"] = "格瑞姆洛克",
		["Ironaya"] = "艾隆納亞",
		["Obsidian Sentinel"] = "黑曜石哨兵",
		["Revelosh"] = "魯維羅什",

-- Ulduar
-- Halls of Lightning
		["General Bjarngrim"] = "賈恩格林將軍",
		["Ionar"] = "埃歐納",
		["Loken"] = "克羅努斯",
		["Volkhan"] = "渥克瀚",
-- Halls of Stone
		["Krystallus"] = "克利斯托魯斯",
		["Maiden of Grief"] = "悲痛侍女",
		["Sjonnir the Ironshaper"] = "『塑鐵者』斯雍尼爾",
		--["The Tribunal of Ages"] = true,

-- The Violet Hold
		--["Cyanigosa"] = true,
		--["Erekem"] = true,
		--["Ichoron"] = true,
		--["Lavanthor"] = true,
		--["Moragg"] = true,
		--["Xevozz"] = true,
		--["Zuramat the Obliterator"] = true,

--Wailing Caverns
		["Boahn"] = "博艾恩",
		["Deviate Faerie Dragon"] = "變異精靈龍",
		["Kresh"] = "克雷什",
		["Lady Anacondra"] = "安娜科德拉",
		["Lord Cobrahn"] = "考布萊恩領主",
		["Lord Pythas"] = "皮薩斯領主",
		["Lord Serpentis"] = "瑟芬迪斯領主",
		["Mad Magglish"] = "瘋狂的馬格利什",
		["Mutanus the Devourer"] = "『吞噬者』穆坦努斯",
		["Skum"] = "斯卡姆",
		["Trigore the Lasher"] = "『鞭笞者』特里高雷",
		["Verdan the Everliving"] = "永生的沃爾丹",

--World Bosses
		["Avalanchion"] = "阿瓦蘭奇奧",
		["Azuregos"] = "艾索雷葛斯",
		["Baron Charr"] = "火焰男爵查爾",
		["Baron Kazum"] = "卡蘇姆男爵",
		["Doom Lord Kazzak"] = "毀滅領主卡札克",
		["Doomwalker"] = "厄運行者",
		["Emeriss"] = "艾莫莉絲",
		["High Marshal Whirlaxis"] = "大元帥維拉希斯",
		["Lethon"] = "雷索",
		["Lord Skwol"] = "斯古恩領主",
		["Prince Skaldrenox"] = "斯卡德諾克斯王子",
		["Princess Tempestria"] = "泰比斯蒂亞公主",
		["Taerar"] = "泰拉爾",
		["The Windreaver"] = "烈風搶奪者",
		["Ysondre"] = "伊索德雷",

--Zul'Aman
		["Akil'zon"] = "阿奇爾森",
		["Halazzi"] = "哈拉齊",
		["Jan'alai"] = "賈納雷",
		["Malacrass"] = "瑪拉克雷斯",
		["Nalorakk"] = "納羅拉克",
		["Zul'jin"] = "祖爾金",
		["Hex Lord Malacrass"] = "妖術領主瑪拉克雷斯", -- confirm ?

--Zul'Farrak
		["Antu'sul"] = "安圖蘇爾",
		["Chief Ukorz Sandscalp"] = "烏克茲·沙頂",
		["Dustwraith"] = "灰塵怨靈",
		["Gahz'rilla"] = "加茲瑞拉",
		["Hydromancer Velratha"] = "水占師維蕾薩",
		["Murta Grimgut"] = "莫爾塔",
		["Nekrum Gutchewer"] = "耐克魯姆",
		["Oro Eyegouge"] = "歐魯·鑿眼",
		["Ruuzlu"] = "盧茲魯",
		["Sandarr Dunereaver"] = "杉達爾·沙掠者",
		["Sandfury Executioner"] = "沙怒劊子手",
		["Sergeant Bly"] = "布萊中士",
		["Shadowpriest Sezz'ziz"] = "暗影祭司塞瑟斯",
		["Theka the Martyr"] = "『殉教者』塞卡",
		["Witch Doctor Zum'rah"] = "巫醫·祖穆拉恩",
		["Zerillis"] = "澤雷利斯",
		["Zul'Farrak Dead Hero"] = "祖爾法拉克陣亡英雄",

-- Zul'Drak
-- Gundrak
		--["Drakkari Colossus"] = true,
		["Gal'darah"] = "蓋爾達拉",
		["Moorabi"] = "慕拉比",
		["Slad'ran"] = "史拉德銳",

--Zul'Gurub
		["Bloodlord Mandokir"] = "血領主曼多基爾",
		["Gahz'ranka"] = "加茲蘭卡",
		["Gri'lek"] = "格里雷克",
		["Hakkar"] = "哈卡",
		["Hazza'rah"] = "哈札拉爾",
		["High Priest Thekal"] = "高階祭司塞卡爾",
		["High Priest Venoxis"] = "高階祭司溫諾希斯",
		["High Priestess Arlokk"] = "哈卡萊先知",
		["High Priestess Jeklik"] = "高階祭司耶克里克",
		["High Priestess Mar'li"] = "哈卡萊安魂者",
		["Jin'do the Hexxer"] = "『妖術師』金度",
		["Renataki"] = "雷納塔基",
		["Wushoolay"] = "烏蘇雷",

--Ring of Blood (where? an instnace? should be in other file?)
		["Brokentoe"] = "斷趾",
		["Mogor"] = "莫古",
		["Murkblood Twin"] = "黑暗之血雙子",
		["Murkblood Twins"] = "黑暗之血雙子",
		["Rokdar the Sundered Lord"] = "『碎裂領主』洛克達",
		["Skra'gath"] = "史卡拉克斯",
		["The Blue Brothers"] = "憂鬱兄弟黨",
		["Warmaul Champion"] = "戰槌勇士",
	}
else
	lib:SetCurrentTranslations(true)
end
