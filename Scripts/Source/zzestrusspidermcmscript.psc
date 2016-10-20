Scriptname zzEstrusSpiderMCMScript extends SKI_ConfigBase  Conditional

;OIDs

int TentacleSpitEnabledOID
int TentacleSpitChanceOID


bool property TentacleSpitEnabled = true auto
int property TentacleSpitChance = 20 auto


; SCRIPT VERSION ----------------------------------------------------------------------------------
int function GetVersion()
	return 4210
endFunction

string function GetStringVer()
	return StringUtil.Substring((GetVersion() as float / 1000.0) as string, 0, 4)
endFunction

; PRIVATE FUNCTIONS -------------------------------------------------------------------------------
; VERSION 1
string Function decimalDaysToString( Float afDays )
	Return Math.Floor( afDays ) as String + ":" + (( afDays * 24.0 ) as Int % 24 ) as String
EndFunction

; VERSION 3000
string function skseVersionString()
	return SKSE.GetVersion() as string + "." + SKSE.GetVersionMinor() as string  + "." + SKSE.GetVersionBeta() as string
endFunction

int function skseVersionCompare(int major, int minor, int beta)
	int skseMajor = SKSE.GetVersion()
	int skseMinor = SKSE.GetVersionMinor()
	int skseBeta  = SKSE.GetVersionBeta()

	if skseMajor == major
		if skseMinor == minor
			if skseBeta == beta
				return 0
			elseIf skseBeta > beta
				return 1
			else
				return -1
			endIf
		elseIf skseMinor > minor
			return 1
		else
			return -1
		endIf
	elseIf skseMajor > major
		return 1
	else
		return -1
	endIf
endFunction

; VERSION 3001
function registerMenus()
	RegisterForMenu(TRIGGER_MENU)
endFunction

; INITIALIZATION ----------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnConfigInit()
	kPlayer = Game.GetPlayer()

	swellingSliderList = new string[4]
	swellingSliderList[0] = "$ES_NONE"
	swellingSliderList[1] = "$ES_FAST"
	swellingSliderList[2] = "$ES_MEDIUM"
	swellingSliderList[3] = "$ES_SLOW"

	Pages = New String[7]
	Pages[0] = "$ES_PAGE_0"
	Pages[1] = "$ES_PAGE_1"
	Pages[2] = "$ES_PAGE_2"
	Pages[3] = "$ES_PAGE_3"
	Pages[4] = "$ES_PAGE_4"
	Pages[4] = "$ES_PAGE_5"
	Pages[4] = "$ES_PAGE_6"

	sTentacleAnims = New String[6]
	sTentacleAnims[0] = "Tentacle Double"
	sTentacleAnims[1] = "Tentacle Side"
	sTentacleAnims[2] = "Dwemer Machine 2"
	sTentacleAnims[3] = "Dwemer Machine"
	sTentacleAnims[4] = "Slime Creature"
	sTentacleAnims[5] = "Ooze Creature"

	bTentacleAnims = New Bool[6]
	bTentacleAnims[0] = false
	bTentacleAnims[1] = false
	bTentacleAnims[2] = false
	bTentacleAnims[3] = false
	bTentacleAnims[4] = false
	bTentacleAnims[5] = false
	
	sGenderRestriction = New String[3]
	sGenderRestriction[0] = "$ES_BOTH"
	sGenderRestriction[1] = "$ES_MALE"
	sGenderRestriction[2] = "$ES_FEMALE"

	registerMenus()
endEvent

event OnInit()
	OnConfigInit()
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
	if (a_version >= 5 && CurrentVersion < 5)
		Debug.Trace(self + ": Updating to script version 5")
		swellingSliderList = new string[4]
		swellingSliderList[0] = "$ES_NONE"
		swellingSliderList[1] = "$ES_LARGE"
		swellingSliderList[2] = "$ES_MEDIUM"
		swellingSliderList[3] = "$ES_SMALL"
	endIf
	if (a_version >= 6 && CurrentVersion < 6)
		Debug.Trace(self + ": Updating to script version 6")
		kPlayer = Game.GetPlayer()

		Pages = New String[2]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_1"
	endIf
	if (a_version >= 8 && CurrentVersion < 8)
		Pages = New String[3]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_1"
		Pages[2] = "$ES_PAGE_2"

		swellingSliderList = new string[4]
		swellingSliderList[0] = "$ES_NONE"
		swellingSliderList[1] = "$ES_FAST"
		swellingSliderList[2] = "$ES_MEDIUM"
		swellingSliderList[3] = "$ES_SLOW"
	endIf
	if (a_version >= 14 && CurrentVersion < 14)
		tentanims.LoadAnimations()
		;me.aeUpdate(12) ;EC Lite Init
	endIf

	if (a_version >= 21 && CurrentVersion < 21)
		tentanims = ( self as Quest ) as zzEstrusChaurusAnim
	endIf

	if (a_version >= 3000 && CurrentVersion < 3000)
		kIncubationOff = New Actor[20]

		Pages = New String[6]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_1"
		Pages[2] = "$ES_PAGE_2"
		Pages[3] = "$ES_PAGE_3"
		Pages[4] = "$ES_PAGE_4"
		Pages[5] = "$ES_PAGE_5"

		sTentacleAnims = New String[2]
		sTentacleAnims[0] = "Tentacle Double"
		sTentacleAnims[1] = "Tentacle Side"

		bTentacleAnims = New Bool[2]
		bTentacleAnims[0] = false
		bTentacleAnims[1] = false

		;sexlabmcm = Game.GetFormFromFile(0x0003e3fa, "SexLab.esm") as sslConfigMenu
		;aemcm = Game.GetFormFromFile(0x00000d65, "actorEvents.esm") as _ae_mcm
	endIf

	if (a_version >= 3001 && CurrentVersion < 3001)
		registerMenus()
	endIf
	
	if (a_version >= 3002 && CurrentVersion < 3002)
		bRegisterCompanions = false
	endIf

	if (a_version >= 3003 && CurrentVersion < 3003)
		Pages = New String[7]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_1"
		Pages[2] = "$ES_PAGE_2"
		Pages[3] = "$ES_PAGE_3"
		Pages[4] = "$ES_PAGE_4"
		Pages[5] = "$ES_PAGE_5"
		Pages[6] = "$ES_PAGE_6"
	endIf

	if (a_version >= 3100 && CurrentVersion < 3100)
		zzEstrusSwellingButt        = Game.GetFormFromFile(0x00037293, "EstrusChaurus.esp") as GlobalVariable
		zzEstrusSpiderMaxButtScale  = Game.GetFormFromFile(0x0004e263, "EstrusSpider.esp") as GlobalVariable
	endIf

	if (a_version >= 3200 && CurrentVersion < 3200)
		sTentacleAnims = New String[3]
		sTentacleAnims[0] = "Tentacle Double"
		sTentacleAnims[1] = "Tentacle Side"
		sTentacleAnims[2] = "Dwemer Machine"

		bTentacleAnims = New Bool[3]
		bTentacleAnims[0] = false
		bTentacleAnims[1] = false
		bTentacleAnims[2] = false
	endIf
	
	if (a_version >= 3201 && CurrentVersion < 3201)
		zzEstrusChaurusResidual      = Game.GetFormFromFile(0x00010a7a, "EstrusChaurus.esp") as GlobalVariable
		zzEstrusChaurusResidualScale = Game.GetFormFromFile(0x0003da79, "EstrusChaurus.esp") as GlobalVariable
	endIf

	if (a_version >= 3330 && CurrentVersion < 3330)
		zzEstrusChaurusGender        = Game.GetFormFromFile(0x0003f002, "EstrusChaurus.esp") as GlobalVariable

		sGenderRestriction = New String[3]
		sGenderRestriction[0] = "$ES_MALE"
		sGenderRestriction[1] = "$ES_FEMALE"
		sGenderRestriction[2] = "$ES_BOTH"
		
		swellingSliderList = new string[4]
		swellingSliderList[0] = "$ES_NONE"
		swellingSliderList[1] = "$ES_FAST"
		swellingSliderList[2] = "$ES_MEDIUM"
		swellingSliderList[3] = "$ES_SLOW"
	endIf

	if (a_version >= 3350 && CurrentVersion < 3350)
		zzEstrusChaurusGender        = Game.GetFormFromFile(0x0003f002, "EstrusChaurus.esp") as GlobalVariable
	endIf

	if (a_version >= 3700 && CurrentVersion < 3700)
		me.RegisterForSLSpider()
	endif

	if (a_version >= 3931 && CurrentVersion < 3931)
		sTentacleAnims = New String[4]
		sTentacleAnims[0] = "Tentacle Double"
		sTentacleAnims[1] = "Tentacle Side"
		sTentacleAnims[2] = "Dwemer Machine 2"
		sTentacleAnims[3] = "Dwemer Machine"

		bTentacleAnims = New Bool[4]
		bTentacleAnims[0] = false
		bTentacleAnims[1] = false
		bTentacleAnims[2] = false
		bTentacleAnims[3] = false
	endIf

	
	if (a_version >= 4000 && CurrentVersion < 4000)
		sTentacleAnims = New String[6]
		sTentacleAnims[0] = "Tentacle Double"
		sTentacleAnims[1] = "Tentacle Side"
		sTentacleAnims[2] = "Dwemer Machine 2"
		sTentacleAnims[3] = "Dwemer Machine"
		sTentacleAnims[4] = "Slime Creature"
		sTentacleAnims[5] = "Ooze Creature"

		bTentacleAnims = New Bool[6]
		bTentacleAnims[0] = false
		bTentacleAnims[1] = false
		bTentacleAnims[2] = false
		bTentacleAnims[3] = false
		bTentacleAnims[4] = false
		bTentacleAnims[5] = false
	endIf

	if (a_version >= 4100 && CurrentVersion < 4100 && CurrentVersion > 0 )
		debug.MessageBox("Warning: Upgrades of earlier versions of ES+ to version 4.1 are NOT supported. A new game or clean save is required.")
	endif

	if (a_version >= 4110 && CurrentVersion < 4110)
		Pages = New String[6]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_1"
		Pages[2] = "$ES_PAGE_3"
		Pages[3] = "$ES_PAGE_4"
		Pages[4] = "$ES_PAGE_5"
		Pages[5] = "$ES_PAGE_6"
	endif

	
endEvent

; MENUS -------------------------------------------------------------------------------------------
Event OnMenuOpen(String MenuName)

EndEvent

Event OnMenuClose(String MenuName)
	if MenuName == TRIGGER_MENU
		if bRegisterAnimations
			tentanims.LoadAnimations()
			bRegisterAnimations = false
		endIf
	endIf	
EndEvent

; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}
	if (a_page == "" || !Self.IsRunning() )
		LoadCustomContent("jbezorg/EstrusSpider.dds", 226, 119)
		return
	else
		UnloadCustomContent()
	endIf

; ACTOR EVENTS ------------------------------------------------------------------------------------
	bAERegistered      =  False  ;me.aeCheck()

; ANIMATIONS --------------------------------------------------------------------------------------
	iIndex             = sTentacleAnims.length
	while iIndex > 0
		iIndex -= 1
		bTentacleAnims[iIndex] = SexLab.GetAnimationByName(sTentacleAnims[iIndex]) != none
	endWhile

	bAnimRegistered       = bTentacleAnims.Find(false) == -1
	bFluidsEnabled        = zzEstrusChaurusFluids.GetValue() as bool
	iGenderIndex          = zzEstrusChaurusGender.GetValueInt()

; NODE TESTS --------------------------------------------------------------------------------------
	bEnableResidualBreast = zzEstrusChaurusResidual.GetValue() as bool
	bLimitBirthDuration   = zzEstrusSpiderBirth.GetValue() as bool
	bool bIsFemale        = (kPlayer.GetLeveledActorBase().GetSex() == 1)

	if CheckXPMSERequirements(kPlayer, bIsFemale)
		bEnableSkirt02     = true
		bEnableBreast      = true
		bEnableBreast01    = true
		bEnableButt        = true
		bEnableBelly       = true
	else
		bEnableSkirt02     = XPMSELib.HasNode(kPlayer, NINODE_SKIRT02)
		bEnableBreast      = XPMSELib.HasNode(kPlayer, NINODE_LEFT_BREAST) && XPMSELib.HasNode(kPlayer, NINODE_RIGHT_BREAST)
		bEnableBreast01    = XPMSELib.HasNode(kPlayer, NINODE_LEFT_BREAST01) && XPMSELib.HasNode(kPlayer, NINODE_RIGHT_BREAST01)
		bEnableButt        = XPMSELib.HasNode(kPlayer, NINODE_LEFT_BUTT) && XPMSELib.HasNode(kPlayer, NINODE_RIGHT_BUTT)
		bEnableBelly       = XPMSELib.HasNode(kPlayer, NINODE_BELLY)
	endif
	
	if ( !bEnableBreast )
		zzEstrusSwellingBreasts.SetValueInt( 0 )
		zzEstrusChaurusTorpedoFix.SetValueInt( 0 )
	endIf
	if ( !bEnableBreast01 )
		zzEstrusChaurusTorpedoFix.SetValueInt( 0 )
	endIf
	if ( !bEnableButt )
		zzEstrusSwellingButt.SetValueInt( 0 )
	endIf	
	if ( !bEnableBelly )
		zzEstrusSwellingBelly.SetValueInt( 0 )
	endIf
	if ( !bEnableSkirt02 )
		zzEstrusDisablePregnancy2.SetValueInt( 1 )
	endIf

; UNINSTALL ---------------------------------------------------------------------------------------
	bUninstallState    = zzEstrusSpiderUninstall.GetValueInt() as bool
; ADDSTRIP ----------------------------------------------------------------------------------------
	bAddStrip          = zzEstrusSpiderAddStrip.GetValueInt() as bool ;depreciated
; PREGNANCY ---------------------------------------------------------------------------------------
	bPregnancyEnabled  = !zzEstrusDisablePregnancy2.GetValueInt() as bool
; GROWTH ------------------------------------------------------------------------------------------
	bSwellingEnabled   = !zzEstrusDisableNodeResize2.GetValueInt() as bool
	breastSwellingIdx  = zzEstrusSwellingBreasts.GetValueInt()
	bellySwellingIdx   = zzEstrusSwellingBelly.GetValueInt()
	buttSwellingIdx    = zzEstrusSwellingButt.GetValueInt()
	bTorpedoFixEnabled = zzEstrusChaurusTorpedoFix.GetValueInt() as Bool

; GENERAL -----------------------------------------------------------------------------------------
	if bUninstallState && zzEstrusSpiderInfected.GetValueInt() as bool
		iOptionFlag    = OPTION_FLAG_DISABLED
	else
		iOptionFlag    = OPTION_FLAG_NONE
	endIf
	
; MODS & DLC --------------------------------------------------------------------------------------
	iIndex = Game.GetModCount()
	while iIndex > 0
		iIndex -= 1
		if Game.GetModName(iIndex) == "SexLabAroused.esm"
			kfSLAExposure = Game.GetFormFromFile(0x00025837, "SexLabAroused.esm") as Faction
		elseif Game.GetModName(iIndex) == "Devious Devices - Integration.esm"
			kwDeviousDevices = Keyword.GetKeyword("zad_deviousBelt")
		endIf
	endWhile
	
; -------------------------------------------------------------------------------------------------
	if ( a_page == Pages[0] )
		SetCursorFillMode(TOP_TO_BOTTOM)
; INFECTED ----------------------------------------------------------------------------------------
		SetCursorPosition(1)
		AddHeaderOption("$ES_STATUS")
		AddToggleOptionST("STATE_UNINSTALL", "$ES_UNINSTALL", bUninstallState, iOptionFlag)
		AddToggleOptionST("STATE_FORCE_FIX", "$ES_FORCEFIX_NODES", false, iOptionFlag)
		AddTextOption("$ES_INFECTED", zzEstrusSpiderInfected.GetValueInt(), OPTION_FLAG_DISABLED)

; INFECTED ACTIVE ---------------------------------------------------------------------------------
		if !bUninstallState
			bUninstallMessage = false
			iIndex = 0
			while ( iIndex < kIncubationDue.Length )
				if ( kIncubationDue[iIndex] != None )
					thisName = kIncubationDue[iIndex].GetLeveledActorBase().GetName()
					thisTime = decimalDaysToString(fIncubationDue[iIndex] - Utility.GetCurrentGameTime())
					AddTextOption(thisName, thisTime, iOptionFlag)
				endIf
				iIndex += 1
			endWhile
; INFECTED UNINSTALL-------------------------------------------------------------------------------
		elseIf !bUninstallMessage
				AddTextOption("$ES_UNINSTALL_TEXT", "", iOptionFlag)
				bUninstallMessage = true
		else
			iIndex = 0
			while ( iIndex < kIncubationOff.Length )
				if ( kIncubationOff[iIndex] != None )
					thisName = kIncubationOff[iIndex].GetLeveledActorBase().GetName()
					AddTextOption(thisName, "$ES_DISPEL", iOptionFlag)
				endIf
				iIndex += 1
			endWhile
		endIf

		SetCursorPosition(0)
; EVENTS ------------------------------------------------------------------------------------
		AddHeaderOption("Events")
		TentacleSpitEnabledOID = AddToggleOption("Spider spit effect", TentacleSpitEnabled)
		if TentacleSpitEnabled
			TentacleSpitChanceOID = addslideroption("Tentacle attack chance:", TentacleSpitChance, "{0} %")
		else
			TentacleSpitChance = 0
			TentacleSpitChanceOID = addslideroption("Tentacle attack chance:", TentacleSpitChance, "{0} %", OPTION_FLAG_DISABLED)
		endif
; PREGNANCY ---------------------------------------------------------------------------------------
		AddHeaderOption("$ES_PREGNANCY_TITLE")
		AddToggleOptionST("STATE_PREGNANCY", "$ES_PREGNANCY", bPregnancyEnabled, iOptionFlag)
		if bPregnancyEnabled
			AddSliderOptionST("STATE_PERIOD", "$ES_PERIOD", zzEstrusIncubationPeriod2.GetValue(), "{0}", iOptionFlag)
			AddSliderOptionST("STATE_FERTILITY_CHANCE", "$ES_FERTILITY_CHANCE", zzEstrusFertilityChance2.GetValue(), "{0}", iOptionFlag)
			AddToggleOptionST("STATE_LIMIT_BIRTH_DURATION_TOGGLE", "$ES_LIMIT_BIRTH", bLimitBirthDuration, iOptionFlag)
; AFTEREFFECTS ------------------------------------------------------------------------------------
			AddToggleOptionST("STATE_INFESTATION", "$ES_INFESTATION", zzEstrusSpiderInfestation.GetValueInt() as bool, iOptionFlag)
; GROWTH ------------------------------------------------------------------------------------------
			AddHeaderOption("$ES_GROWTH_TITLE")
			AddToggleOptionST("STATE_GROWTH", "$ES_GROWTH", bSwellingEnabled, iOptionFlag)
			if bSwellingEnabled
				if bEnableBreast
					AddToggleOptionST("STATE_BREAST_SCALING", "$ES_BREAST_SCALING", bTorpedoFixEnabled, iOptionFlag)
					AddTextOptionST("STATE_BREAST_GROWTH", "$ES_BREAST_GROWTH", swellingSliderList[breastSwellingIdx], iOptionFlag)
				else
					AddToggleOptionST("STATE_BREAST_SCALING", "$ES_BREAST_SCALING", bTorpedoFixEnabled, OPTION_FLAG_DISABLED)
					AddTextOptionST("STATE_BREAST_GROWTH", "$ES_BREAST_GROWTH", swellingSliderList[0], OPTION_FLAG_DISABLED)
				endIf
				if bEnableButt
					AddTextOptionST("STATE_BUTT_GROWTH", "$ES_BUTT_GROWTH", swellingSliderList[buttSwellingIdx], iOptionFlag)
				else
					AddTextOptionST("STATE_BUTT_GROWTH", "$ES_BUTT_GROWTH", swellingSliderList[0], OPTION_FLAG_DISABLED)
				endIf
				if bEnableBelly
					AddTextOptionST("STATE_BELLY_GROWTH", "$ES_BELLY_GROWTH", swellingSliderList[bellySwellingIdx], iOptionFlag)
				else
					AddTextOptionST("STATE_BELLY_GROWTH", "$ES_BELLY_GROWTH", swellingSliderList[0], OPTION_FLAG_DISABLED)
				endIf
			endIf
		endIf
; ANIMATIONS --------------------------------------------------------------------------------------
	elseIf ( a_page == Pages[1] )
		if !bAnimRegistered
			AddToggleOptionST("STATE_ANIMATIONS", "$ES_REGISTER", bAnimRegistered, iOptionFlag)
		else
			AddToggleOptionST("STATE_ANIMATIONS", "$ES_UNREGISTER", bAnimRegistered, iOptionFlag)
		endIf
		AddToggleOptionST("STATE_FLUIDS", "$ES_FLUIDS", bFluidsEnabled, iOptionFlag)
		
		AddHeaderOption("$ES_ANIM")
		AddHeaderOption("")
		iIndex = sTentacleAnims.length
		while iIndex > 0
			iIndex -= 1
			AddToggleOption(sTentacleAnims[iIndex], bTentacleAnims[iIndex], OPTION_FLAG_DISABLED)
		endWhile
	elseIf ( a_page == Pages[2] )
; HATCHERY ----------------------------------------------------------------------------------------
		iIndex = 0
		iCount = 0
		AddHeaderOption("$ES_HATCHERY_TITLE")
		AddHeaderOption("")
		while ( iIndex < kHatchingEgg.Length )
			if ( kHatchingEgg[iIndex] != None )
				thisTime = decimalDaysToString(fHatchingDue[iIndex] - Utility.GetCurrentGameTime())
				if thisTime > 0.0
					thisName = kHatchingEgg[iIndex].GetCurrentLocation().GetName()
					AddTextOption(thisName, thisTime, iOptionFlag)
				else
					( kHatchingEgg[iIndex] as zzSpiderEggsScript ).hatch()
				endIf
				iCount += 1
			elseIf fHatchingDue[iIndex] != 0.0
				fHatchingDue[iIndex] = 0.0
			endIf
			iIndex += 1
		endWhile

		if iCount == 0
			AddTextOption("$ES_NONE", "", OPTION_FLAG_NONE)
		endIf
; MODS & DLC --------------------------------------------------------------------------------------
	elseIf ( a_page == Pages[3] )
		if kwDeviousDevices != none
			AddTextOptionST("STATE_DLCMOD_0", "$EC_DLCMOD_0", "$ES_ENABLED", OPTION_FLAG_NONE)
		else
			AddTextOptionST("STATE_DLCMOD_0", "$EC_DLCMOD_0", "$ES_DISABLED", OPTION_FLAG_NONE)
		endIf
		if kfSLAExposure != none
			AddTextOptionST("STATE_DLCMOD_1", "$EC_DLCMOD_1", "$ES_ENABLED", OPTION_FLAG_NONE)
		else
			AddTextOptionST("STATE_DLCMOD_1", "$EC_DLCMOD_1", "$ES_DISABLED", OPTION_FLAG_NONE)
		endIf
; NODE TESTS --------------------------------------------------------------------------------------
	elseIf ( a_page == Pages[4] )
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddToggleOptionST("STATE_RESIDUAL_BREAST_TOGGLE", "$ES_RESIDUAL_BREAST", bEnableResidualBreast, iOptionFlag)
		
		AddToggleOption("$ES_NINODE_LEFT_BREAST", bEnableBreast, OPTION_FLAG_DISABLED)
		AddToggleOption("$ES_NINODE_LEFT_BREAST01", bEnableBreast01, OPTION_FLAG_DISABLED)
		AddToggleOption("$ES_NINODE_RIGHT_BREAST", bEnableBreast, OPTION_FLAG_DISABLED)
		AddToggleOption("$EC_NINODE_RIGHT_BREAST01", bEnableBreast01, OPTION_FLAG_DISABLED)
		AddSliderOptionST("STATE_NINODE_BREAST_SCALE", "$ES_NINODE_MAX_BREAST_SCALE", zzEstrusSpiderMaxBreastScale.GetValue(), "{1}", iOptionFlag)
		AddToggleOption("$ES_NINODE_SKIRT02", bEnableBelly, OPTION_FLAG_DISABLED)
		AddToggleOption("$ES_NINODE_BELLY", bEnableSkirt02, OPTION_FLAG_DISABLED)
		AddSliderOptionST("STATE_NINODE_BELLY_SCALE", "$ES_NINODE_MAX_BELLY_SCALE", zzEstrusSpiderMaxBellyScale.GetValue(), "{1}", iOptionFlag)
		AddToggleOption("$ES_NINODE_LEFT_BUTT", bEnableButt, OPTION_FLAG_DISABLED)
		AddToggleOption("$ES_NINODE_RIGHT_BUTT", bEnableButt, OPTION_FLAG_DISABLED)
		AddSliderOptionST("STATE_NINODE_BUTT_SCALE", "$ES_NINODE_MAX_BUTT_SCALE", zzEstrusSpiderMaxButtScale.GetValue(), "{1}", iOptionFlag)

		SetCursorPosition(1)
		AddSliderOptionST("STATE_RESIDUAL_BREAST_SCALE", "$ES_RESIDUAL_BREAST_MULT", zzEstrusChaurusResidualScale.GetValue(), "{1}", iOptionFlag)
		SetCursorPosition(3)
		AddTextOptionST("STATE_NINODE_0", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		AddTextOptionST("STATE_NINODE_1", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		AddTextOptionST("STATE_NINODE_2", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		AddTextOptionST("STATE_NINODE_3", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		SetCursorPosition(13)
		AddTextOptionST("STATE_NINODE_4", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		AddTextOptionST("STATE_NINODE_5", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		SetCursorPosition(19)
		AddTextOptionST("STATE_NINODE_6", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
		AddTextOptionST("STATE_NINODE_7", "$ES_NINODE_INFO", "", OPTION_FLAG_NONE)
; VERSION CHECK -----------------------------------------------------------------------------------
	elseIf ( a_page == Pages[5] )
		AddHeaderOption("Estrus Spider v" + GetStringVer())
		AddToggleOption("$ES_VERSION_OK", (GetVersion() >= 3700), OPTION_FLAG_DISABLED)
		AddHeaderOption("SKSE v" + skseVersionString() )
		AddToggleOption("$ES_VERSION_OK", (skseVersionCompare(1,7,1) >= 0), OPTION_FLAG_DISABLED)
		AddHeaderOption("FNIS v" + FNIS.VersionToString())
		AddToggleOption("$ES_VERSION_OK", (FNIS.VersionCompare(5,1,1) >= 0), OPTION_FLAG_DISABLED)
		AddHeaderOption("FNIS Creature v" + FNIS.VersionToString(true))
		AddToggleOption("$ES_VERSION_OK", (FNIS.VersionCompare(5,1,0,true) >= 0), OPTION_FLAG_DISABLED)
		AddHeaderOption("SexLab v" + sexlab.GetStringVer())
		AddToggleOption("$ES_VERSION_OK", (sexlab.GetVersion() >= 1500), OPTION_FLAG_DISABLED)
		AddHeaderOption("XP32MSE v" + StringUtil.Substring(XPMSELib.GetXPMSEVersion(kPlayer, bisFemale) as string, 0, 4))
		AddToggleOption("$EC_VERSION_OK", (XPMSELib.GetXPMSEVersion(kPlayer, bisFemale) >= 2.8) , OPTION_FLAG_DISABLED)
		AddHeaderOption("NiOverride Plugin v" + SKSE.GetPluginVersion("NiOverride"))
		AddToggleOption("$EC_VERSION_OK", (SKSE.GetPluginVersion("NiOverride") >= NIOVERRIDE_VERSION) , OPTION_FLAG_DISABLED)
		AddHeaderOption("NiOverride Scripts v" + SKSE.GetPluginVersion("NiOverride"))
		AddToggleOption("$EC_VERSION_OK", (NiOverride.GetScriptVersion() >= NIOVERRIDE_SCRIPT_VERSION) , OPTION_FLAG_DISABLED) 
	endIf
endEvent



event OnOptionSelect(int option)

	if (option == TentacleSpitEnabledOID)
        TentacleSpitEnabled = !TentacleSpitEnabled
        SetToggleOptionValue(TentacleSpitEnabledOID, TentacleSpitEnabled)
	endif

endevent

event OnOptionHighlight(int option)
    if (option == TentacleSpitEnabledOID)
        SetInfoText("Enables Tentacle attacks when hit by Spider spit.\nDefault: true")
    elseif (option == TentacleSpitChanceOID)
		SetInfoText("Chance that being hit by Spider spit will start a Tentacle attack.\nDefault: 20")
    endif
endevent


Event OnOptionSliderOpen(int opt)
	if opt == TentacleSpitChanceOID
		SetSliderDialogStartValue(TentacleSpitChance)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endIf
endevent

Event OnOptionSliderAccept(int opt, float val)
	if opt == TentacleSpitChanceOID
		TentacleSpitChance = val as int
		SetSliderOptionValue(opt, TentacleSpitChance, "{0} %")
	endif
endevent


; INFECTED ----------------------------------------------------------------------------------------
state STATE_UNINSTALL
	event OnSelectST()
		zzEstrusSpiderUninstall.SetValueInt( Math.LogicalXor( 1, zzEstrusSpiderUninstall.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusSpiderUninstall.GetValueInt() as Bool )
		if !zzEstrusSpiderUninstall.GetValueInt() as Bool
			;me.aeUnRegisterMod()
		endIf
		ForcePageReset()
	endEvent

	event OnDefaultST()
		zzEstrusSpiderUninstall.SetValueInt( 0 )
		SetToggleOptionValueST( false )
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_UNINSTALL_INFO")
	endEvent
endState
state STATE_FORCE_FIX
	event OnSelectST()
		SetToggleOptionValueST( true )
		If ShowMessage("$EC_UPDATE_EXIT")
		
			;while ( Utility.IsInMenuMode() )
				Utility.Wait( 0.1 )
			;endWhile

			int idx1
			int idx2

			string[] nodes = new string[8]
			nodes[0] = "NPC L Breast"
			nodes[1] = "NPC L Breast01"
			nodes[2] = "NPC L Butt"
			nodes[3] = "NPC R Breast"
			nodes[4] = "NPC R Breast01"
			nodes[5] = "NPC R Butt"
			nodes[6] = "SkirtBBone02"
			nodes[7] = "NPC Belly"
			
			Actor kActor = Game.GetCurrentCrosshairRef() as Actor
		
			If kActor == None
				kActor = Player
			Endif
			bool bIsFemale = (kActor.GetLeveledActorBase().GetSex() == 1)

			idx2 = nodes.length

			While idx2 >0
				idx2 -= 1
				
				XPMSELib.SetNodeScale(kActor, bIsFemale , nodes[idx2], 1.0, ES_KEY)
			endWhile

			kActor.QueueNiNodeUpdate()
			;SetToggleOptionValueST( false )
		else
			SetToggleOptionValueST( false )
		endIf
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST( false )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_FORCEFIX_NODES_INFO")
	endEvent
endState
state STATE_INFECTED
	event OnHighlightST()
		if !bUninstallState
			SetInfoText("$ES_INFECTED_TIME")
		else
			SetInfoText("$ES_UNINSTALL_INFO")
		endIf
	endEvent
endState

; PREGNANCY ---------------------------------------------------------------------------------------
state STATE_PREGNANCY ; TOGGLE
	event OnSelectST()
		zzEstrusDisablePregnancy2.SetValueInt( Math.LogicalXor( 1, zzEstrusDisablePregnancy2.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusDisablePregnancy2.GetValueInt() as Bool )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		zzEstrusDisablePregnancy2.SetValueInt( 0 )
		SetToggleOptionValueST( false )
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_PREGNANCY_INFO")
	endEvent
endState
state STATE_PERIOD ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusIncubationPeriod2.GetValueInt() )
		SetSliderDialogDefaultValue( 3 )
		SetSliderDialogRange( 1, 30 )
		SetSliderDialogInterval( 1 )
	endEvent

	event OnSliderAcceptST(float value)
		int thisValue = value as int
		zzEstrusIncubationPeriod2.SetValueInt( thisValue )
		SetSliderOptionValueST( thisValue )
	endEvent

	event OnDefaultST()
		zzEstrusIncubationPeriod2.SetValueInt( 3 )
		SetSliderOptionValueST( 3 )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_PERIOD_INFO")
	endEvent
endState
state STATE_FERTILITY_CHANCE ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusFertilityChance2.GetValue() )
		SetSliderDialogDefaultValue( 5 )
		SetSliderDialogRange( 0, 25 )
		SetSliderDialogInterval( 1 )
	endEvent

	event OnSliderAcceptST(float value)
		int thisValue = value as int
		zzEstrusFertilityChance2.SetValue( thisValue )
		SetSliderOptionValueST( thisValue )
	endEvent

	event OnDefaultST()
		zzEstrusFertilityChance2.SetValue( 5 )
		SetSliderOptionValueST( 5 )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_FERTILITY_CHANCE_INFO")
	endEvent
endState
state STATE_LIMIT_BIRTH_DURATION_TOGGLE; TOGGLE
	event OnSelectST()
		zzEstrusSpiderBirth.SetValueInt( Math.LogicalXor( 1, zzEstrusSpiderBirth.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusSpiderBirth.GetValueInt() as Bool )
	endEvent

	event OnDefaultST()
		zzEstrusSpiderBirth.SetValueInt( 0 )
		SetToggleOptionValueST( false )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_LIMIT_BIRTH_INFO")
	endEvent
endState

; GROWTH ------------------------------------------------------------------------------------------
state STATE_GROWTH ; TOGGLE
	event OnSelectST()
		zzEstrusDisableNodeResize2.SetValueInt( Math.LogicalXor( 1, zzEstrusDisableNodeResize2.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusDisableNodeResize2.GetValueInt() as Bool )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		zzEstrusDisableNodeResize2.SetValueInt( 1 )
		SetToggleOptionValueST( true)
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_GROWTH_INFO")
	endEvent
endState
state STATE_BREAST_GROWTH ; TEXT
	event OnSelectST()
		breastSwellingIdx += 1
		breastSwellingIdx = breastSwellingIdx % swellingSliderList.length
		zzEstrusSwellingBreasts.SetValueInt( breastSwellingIdx )
		SetTextOptionValueST( swellingSliderList[breastSwellingIdx] )
	endEvent

	event OnDefaultST()
		breastSwellingIdx = 1
		zzEstrusSwellingBreasts.SetValueInt( 1 )
		SetTextOptionValueST( swellingSliderList[1] )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_BREAST_GROWTH_INFO")
	endEvent
endState
state STATE_BELLY_GROWTH ; TEXT
	event OnSelectST()
		bellySwellingIdx += 1
		bellySwellingIdx = bellySwellingIdx % swellingSliderList.length
		zzEstrusSwellingBelly.SetValueInt( bellySwellingIdx )
		SetTextOptionValueST( swellingSliderList[bellySwellingIdx] )
	endEvent

	event OnDefaultST()
		bellySwellingIdx = 1
		zzEstrusSwellingBelly.SetValueInt( 1 )
		SetTextOptionValueST( swellingSliderList[1] )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_BELLY_GROWTH_INFO")
	endEvent
endState
state STATE_BREAST_SCALING ; TOGGLE
	event OnSelectST()
		zzEstrusChaurusTorpedoFix.SetValueInt( Math.LogicalXor( 1, zzEstrusChaurusTorpedoFix.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusChaurusTorpedoFix.GetValueInt() as Bool )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		zzEstrusChaurusTorpedoFix.SetValueInt( 1 )
		SetToggleOptionValueST( true )
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_BREAST_SCALING_INFO")
	endEvent
endState
state STATE_BUTT_GROWTH ; TEXT
	event OnSelectST()
		buttSwellingIdx += 1
		buttSwellingIdx = buttSwellingIdx % swellingSliderList.length
		zzEstrusSwellingButt.SetValueInt( buttSwellingIdx )
		SetTextOptionValueST( swellingSliderList[buttSwellingIdx] )
	endEvent

	event OnDefaultST()
		buttSwellingIdx = 1
		zzEstrusSwellingButt.SetValueInt( 1 )
		SetTextOptionValueST( swellingSliderList[1] )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_BUTT_GROWTH_INFO")
	endEvent
endState

; AFTEREFFECTS ------------------------------------------------------------------------------------
state STATE_INFESTATION ; TOGGLE
	event OnSelectST()
		zzEstrusSpiderInfestation.SetValueInt( Math.LogicalXor( 1, zzEstrusSpiderInfestation.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusSpiderInfestation.GetValueInt() as Bool )
	endEvent

	event OnDefaultST()
		zzEstrusSpiderInfestation.SetValueInt( 0 )
		SetToggleOptionValueST( false )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_INFESTATION_INFO")
	endEvent
endState

; NODE TESTS --------------------------------------------------------------------------------------
state STATE_RESIDUAL_BREAST_TOGGLE ; TOGGLE
	event OnSelectST()
		zzEstrusChaurusResidual.SetValueInt( Math.LogicalXor( 1, zzEstrusChaurusResidual.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusChaurusResidual.GetValueInt() as Bool )
	endEvent

	event OnDefaultST()
		zzEstrusChaurusResidual.SetValueInt( 0 )
		SetToggleOptionValueST( false )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_RESIDUAL_BREAST_INFO")
	endEvent
endState
state STATE_RESIDUAL_BREAST_SCALE ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusChaurusResidualScale.GetValue() )
		SetSliderDialogDefaultValue( RESIDUAL_MULT_DEFAULT )
		SetSliderDialogRange( NINODE_MIN_SCALE, NINODE_MAX_SCALE )
		SetSliderDialogInterval( 0.1 )
	endEvent

	event OnSliderAcceptST(float value)
		zzEstrusChaurusResidualScale.SetValue( value )
		SetSliderOptionValueST( value, "{1}")
	endEvent

	event OnDefaultST()
		zzEstrusChaurusResidualScale.SetValue( RESIDUAL_MULT_DEFAULT )
		SetSliderOptionValueST( RESIDUAL_MULT_DEFAULT )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_RESIDUAL_BREAST_MULT_INFO")
	endEvent
endState
state STATE_NINODE_0 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_LEFT_BREAST_INFO")
	endEvent
endState
state STATE_NINODE_1 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_RIGHT_BREAST_INFO")
	endEvent
endState
state STATE_NINODE_2 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_LEFT_BREAST01_INFO")
	endEvent
endState
state STATE_NINODE_3 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_RIGHT_BREAST01_INFO")
	endEvent
endState
state STATE_NINODE_4 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_SKIRT02_INFO")
	endEvent
endState
state STATE_NINODE_5 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_BELLY_INFO")
	endEvent
endState
state STATE_NINODE_6 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_LEFT_BUTT_INFO")
	endEvent
endState
state STATE_NINODE_7 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_NINODE_RIGHT_BUTT_INFO")
	endEvent
endState

; NODE SCALE --------------------------------------------------------------------------------------
state STATE_NINODE_BREAST_SCALE ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusSpiderMaxBreastScale.GetValue() )
		SetSliderDialogDefaultValue( NINODE_MAX_SCALE )
		SetSliderDialogRange( NINODE_MIN_SCALE, NINODE_MAX_SCALE )
		SetSliderDialogInterval( 0.1 )
	endEvent

	event OnSliderAcceptST(float value)
		zzEstrusSpiderMaxBreastScale.SetValue( value )
		SetSliderOptionValueST( value, "{1}" )
	endEvent

	event OnDefaultST()
		zzEstrusSpiderMaxBreastScale.SetValue( NINODE_MAX_SCALE )
		SetSliderOptionValueST( NINODE_MAX_SCALE, "{1}" )
	endEvent
endState
state STATE_NINODE_BELLY_SCALE ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusSpiderMaxBellyScale.GetValue() )
		SetSliderDialogDefaultValue( NINODE_MAX_SCALE )
		SetSliderDialogRange( NINODE_MIN_SCALE, NINODE_MAX_SCALE * 2.0 ) 
		SetSliderDialogInterval( 0.1 )
	endEvent

	event OnSliderAcceptST(float value)
		zzEstrusSpiderMaxBellyScale.SetValue( value )
		SetSliderOptionValueST( value, "{1}")
	endEvent

	event OnDefaultST()
		zzEstrusSpiderMaxBellyScale.SetValue( NINODE_MAX_SCALE )
		SetSliderOptionValueST( NINODE_MAX_SCALE, "{1}" )
	endEvent
endState
state STATE_NINODE_BUTT_SCALE; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusSpiderMaxButtScale.GetValue() )
		SetSliderDialogDefaultValue( 2.0 )
		SetSliderDialogRange( NINODE_MIN_SCALE, NINODE_MAX_SCALE )
		SetSliderDialogInterval( 0.1 )
	endEvent

	event OnSliderAcceptST(float value)
		zzEstrusSpiderMaxButtScale.SetValue( value )
		SetSliderOptionValueST( value, "{1}")
	endEvent

	event OnDefaultST()
		zzEstrusSpiderMaxButtScale.SetValue( 2.0 )
		SetSliderOptionValueST( 2.0, "{1}" )
	endEvent
endState

;EVENTS ------------------------------------------------------------------------------------

state STATE_GENDER ; TEXT
	event OnSelectST()
		iGenderIndex = ( zzEstrusChaurusGender.GetValueInt() + 1 ) % sGenderRestriction.Length
		zzEstrusChaurusGender.SetValue( iGenderIndex )
		SetTextOptionValueST( sGenderRestriction[iGenderIndex] )
	endEvent

	event OnDefaultST()
		zzEstrusChaurusGender.SetValue( 1 )
		SetTextOptionValueST( sGenderRestriction[1] )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_GENDER_RESTRICT_INFO")
	endEvent
endState

; ANIMATIONS --------------------------------------------------------------------------------------
state STATE_ANIMATIONS ; TEXT
	event OnSelectST()
		bAnimRegistered = !bAnimRegistered

		if bAnimRegistered
			bRegisterAnimations = ShowMessage("$ES_UPDATE_EXIT")
		else
			ShowMessage("$ES_UNREGISTER_ANIM")
			bAnimRegistered = true
		endIf

		SetToggleOptionValueST( bAnimRegistered )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		bAnimRegistered = true
		SetToggleOptionValueST( bAnimRegistered )

		tentanims.LoadAnimations()
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_ANIM_INFO")
	endEvent
endState
state STATE_FLUIDS ; TOGGLE
	event OnSelectST()
		zzEstrusChaurusFluids.SetValueInt( Math.LogicalXor( 1, zzEstrusChaurusFluids.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusChaurusFluids.GetValueInt() as Bool )
	endEvent

	event OnDefaultST()
		zzEstrusChaurusFluids.SetValueInt( 1 )
		SetToggleOptionValueST( true )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_FLUIDS_INFO")
	endEvent
endState

; MODS & DLC --------------------------------------------------------------------------------------
state STATE_DLCMOD_0 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_DLCMOD_0_INFO")
	endEvent
endState
state STATE_DLCMOD_1 ; TEXT
	event OnHighlightST()
		SetInfoText("$ES_DLCMOD_1_INFO")
	endEvent
endState

bool Function CheckXPMSERequirements(Actor akActor, bool isFemale)
	return Game.GetModByName("CharacterMakingExtender.esp") == 255 && XPMSELib.CheckXPMSEVersion(akActor, isFemale, XPMSE_VERSION, true) && XPMSELib.CheckXPMSELibVersion(XPMSELIB_VERSION) && SKSE.GetPluginVersion("NiOverride") >= NIOVERRIDE_VERSION && NiOverride.GetScriptVersion() >= NIOVERRIDE_SCRIPT_VERSION
EndFunction

; PUBLIC VARIABLES --------------------------------------------------------------------------------
; VERSION 0
GlobalVariable      Property zzEstrusSpiderAddStrip         Auto
GlobalVariable      Property zzEstrusSpiderForceDrop        Auto
GlobalVariable      Property zzEstrusDisableNodeResize2     Auto
GlobalVariable      Property zzEstrusDisablePregnancy2      Auto
GlobalVariable      Property zzEstrusIncubationPeriod2      Auto
GlobalVariable      Property zzEstrusSwellingBreasts        Auto
GlobalVariable      Property zzEstrusSwellingBelly          Auto
GlobalVariable      Property zzEstrusSpiderInfestation      Auto
GlobalVariable      Property zzEstrusSpiderUninstall        Auto
GlobalVariable      Property zzEstrusSpiderInfected         Auto
GlobalVariable      Property zzEstrusSpiderMaxBreastScale   Auto
GlobalVariable      Property zzEstrusSpiderMaxBellyScale    Auto
GlobalVariable      Property zzEstrusChaurusTorpedoFix      Auto
GlobalVariable      Property zzEstrusFertilityChance2       Auto
MagicEffect         Property zzEstrusBreederEffect2         Auto
Actor               Property Player                         Auto
Float[]             Property fIncubationDue                 Auto
Actor[]             Property kIncubationDue                 Auto
Float[]             Property fHatchingDue                   Auto
ObjectReference[]   Property kHatchingEgg                   Auto
Actor[]             Property kIncubationOff                 Auto

String              Property NINODE_LEFT_BREAST    = "NPC L Breast" AutoReadOnly
String              Property NINODE_LEFT_BREAST01  = "NPC L Breast01" AutoReadOnly
String              Property NINODE_LEFT_BUTT      = "NPC L Butt" AutoReadOnly
String              Property NINODE_RIGHT_BREAST   = "NPC R Breast" AutoReadOnly
String              Property NINODE_RIGHT_BREAST01 = "NPC R Breast01" AutoReadOnly
String              Property NINODE_RIGHT_BUTT     = "NPC R Butt" AutoReadOnly
String              Property NINODE_SKIRT02        = "SkirtBBone02" AutoReadOnly
String              Property NINODE_BELLY          = "NPC Belly" AutoReadOnly
Float               Property NINODE_MAX_SCALE      = 3.0 AutoReadOnly
Float               Property NINODE_MIN_SCALE      = 0.1 AutoReadOnly
Float               Property RESIDUAL_MULT_DEFAULT = 1.2 AutoReadOnly
string              Property ES_KEY                = "Estrus_Spider" AutoReadOnly

; NiOverride version data
int                      Property NIOVERRIDE_VERSION    = 4 AutoReadOnly
int                      Property NIOVERRIDE_SCRIPT_VERSION = 4 AutoReadOnly

; XPMSE version data
float                    Property XPMSE_VERSION         = 3.0 AutoReadOnly
float                    Property XPMSELIB_VERSION      = 3.0 AutoReadOnly

; VERSION 10
;_ae_framework       Property ae                   Auto
SexLabFramework     Property SexLab                Auto

; VERSION 11
zzEstrusSpiderAE   Property me                     Auto

; VERSION 14
GlobalVariable      Property zzEstrusChaurusFluids Auto

; VERSION 21
zzEstrusChaurusAnim Property tentanims             Auto
Bool                Property bAnimRegistered       Auto  Hidden

; VERSION 3000
;sslConfigMenu       Property sexlabmcm            Auto
;_ae_mcm             Property aemcm                Auto

; VERSION 3001
String              Property TRIGGER_MENU        = "Journal Menu" AutoReadOnly
Bool                Property bRegisterCompanions   Auto  Hidden

; VERSION 3003
Keyword             Property kwDeviousDevices      Auto  Hidden
Faction             Property kfSLAExposure         Auto  Hidden

; VERSION 3100
GlobalVariable      Property zzEstrusSwellingButt         Auto
GlobalVariable      Property zzEstrusSpiderMaxButtScale  Auto

; VERSION 3202
GlobalVariable      Property zzEstrusChaurusResidual      Auto
GlobalVariable      Property zzEstrusChaurusResidualScale Auto

; VERSION 3330
GlobalVariable      Property zzEstrusChaurusGender        Auto

; VERSION 3940
GlobalVariable      Property zzEstrusSpiderBirth      	  Auto

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; VERSION 1
; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
; lists
string[]	swellingSliderList

; Internal
int swellingIdx
float timeLeft
int iIndex
int iCount

; VERSION 2
String thisName            = ""
String thisTime            = ""

; VERSION 3
Bool bAddStrip             = False
Int  iOptionFlag           = 0

; VERSION 4
int breastSwellingIdx      = 0
int bellySwellingIdx       = 0
bool bSwellingEnabled      = False
bool bPregnancyEnabled     = False

; VERSION 5
bool bUninstallState       = False
bool bUninstallMessage     = False

; VERSION 6
Actor kPlayer              = None
Bool  bDisableNodeChange   = False
Bool  bEnableBreast        = False
Bool  bEnableBelly         = False
Bool  bEnableSkirt02       = False

; VERSION 7
Float fMaxBreastScale      = 0.0 ;depreciated
Float fMaxBellyScale       = 0.0 ;depreciated

; VERSION 11
Bool bAERegistered         = False

; VERSION 12
Bool bTorpedoFixEnabled    = True

; VERSION 14
Bool bFluidsEnabled        = True

; VERSION 3000
String[] sTentacleAnims
Bool[] bTentacleAnims


; VERSION 3001
Bool bRegisterAnimations   = False

; VERSION 3100
Int  buttSwellingIdx       = 0
Bool bEnableButt           = False
Bool bEnableBreast01       = False

; VERSION 3201
Bool bEnableResidualBreast = False

; VERSION 3330
String[] sGenderRestriction
Int iGenderIndex           = 1   

; VERSION 3940
Bool bLimitBirthDuration   = False