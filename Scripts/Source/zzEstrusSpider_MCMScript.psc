Scriptname zzEstrusSpider_MCMScript extends SKI_ConfigBase  Conditional

; PUBLIC VARIABLES --------------------------------------------------------------------------------
; VERSION 0
GlobalVariable      Property zzEstrusSpiderDisablePregnancy Auto
GlobalVariable      Property zzEstrusSpiderIncubationPeriod Auto
GlobalVariable      Property zzEstrusSpiderInfestation      Auto
GlobalVariable      Property zzEstrusSpiderUninstall        Auto
GlobalVariable      Property zzEstrusSpiderInfected         Auto
GlobalVariable      Property zzEstrusSpiderFertilityChance  Auto
MagicEffect         Property zzEstrusSpiderBreederEffect    Auto
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
String              Property NINODE_SKIRT03        = "SkirtBBone03" AutoReadOnly
String              Property NINODE_BELLY          = "NPC Belly" AutoReadOnly
String              Property NINODE_GENSCROT       = "NPC GenitalsScrotum [GenScrot]" AutoReadOnly
Float               Property NINODE_MAX_SCALE      = 3.0 AutoReadOnly
Float               Property NINODE_MIN_SCALE      = 0.1 AutoReadOnly
Float               Property RESIDUAL_MULT_DEFAULT = 1.2 AutoReadOnly

Armor               Property zzEstrusChaurusFluid           Auto
Armor               Property zzEstrusChaurusRMilk           Auto
Armor               Property zzEstrusChaurusLMilk           Auto
Faction             Property zzEstrusSpiderBreederFaction   Auto
Faction             Property SexLabAnimatingFaction         Auto
GlobalVariable      Property zzEstrusDisableNodeResize      Auto
GlobalVariable      Property zzEstrusSwellingBreasts        Auto
GlobalVariable      Property zzEstrusSwellingBelly          Auto
GlobalVariable      Property zzEstrusChaurusFluids          Auto
GlobalVariable      Property zzEstrusChaurusMaxBreastScale  Auto  
GlobalVariable      Property zzEstrusChaurusMaxBellyScale   Auto
GlobalVariable      Property zzEstrusChaurusMaxButtScale    Auto
GlobalVariable      Property zzEstrusChaurusTorpedoFix      Auto  
Ingredient          Property zzEstrusSpiderEggs             Auto
Spell               Property zzEstrusSpiderBreederAbility   Auto
Sound               Property zzEstrusBreastPainMarker       Auto
Static              Property xMarker                        Auto

SexLabFramework     Property SexLab               			Auto
String              Property TRIGGER_MENU = "Journal Menu" 	AutoReadOnly
Faction             Property kfSLAExposure         			Auto  Hidden

; VERSION 3100
GlobalVariable      Property zzEstrusSwellingButt         	Auto

; VERSION 3202
GlobalVariable      Property zzEstrusChaurusResidual      	Auto
GlobalVariable      Property zzEstrusChaurusResidualScale 	Auto

; VERSION 3330
GlobalVariable      Property zzEstrusChaurusGender        	Auto

; VERSION 3940
GlobalVariable      Property zzEstrusSpiderBirth      	  	Auto

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; VERSION 1
; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
; lists

; Internal
float timeLeft
int iIndex
int iCount

; VERSION 2
String thisName            = ""
String thisTime            = ""
Int  iOptionFlag           = 0
bool bPregnancyEnabled     = False
bool bUninstallState       = False
bool bUninstallMessage     = False
Bool bTorpedoFixEnabled    = True

;OIDs

int TentacleSpitEnabledOID
int TentacleSpitChanceOID
int ParalyzeSpitEnabledOID
int ParalyzeSpitChanceOID

bool property TentacleSpitEnabled = false auto
bool property ParalyzeSpitEnabled = true auto
int property TentacleSpitChance = 20 auto
int property ParalyzeSpitChance = 20 auto


; SCRIPT VERSION ----------------------------------------------------------------------------------
int function GetVersion()
	return 4334
endFunction

string function GetStringVer()
	return StringUtil.Substring((GetVersion() as float / 1000.0) as string, 0, 4)
endFunction

; PRIVATE FUNCTIONS -------------------------------------------------------------------------------
; VERSION 1
string Function decimalDaysToString( Float afDays )
	Return Math.Floor( afDays ) as String + ":" + (( afDays * 24.0 ) as Int % 24 ) as String
EndFunction

; VERSION 3001
function registerMenus()
	RegisterForMenu(TRIGGER_MENU)
endFunction

; INITIALIZATION ----------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnConfigInit()

	Pages = New String[2]
	Pages[0] = "$ES_PAGE_0"
	Pages[1] = "$ES_PAGE_3"

	registerMenus()
endEvent

event OnInit()
	OnConfigInit()
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
	if (a_version >= 4100 && CurrentVersion < 4100 && CurrentVersion > 0 )
		debug.MessageBox("Warning: Upgrades of earlier versions of ES+ to version 4.1 are NOT supported. A new game or clean save is required.")
	endif
	
	if (a_version >= 4110 && CurrentVersion < 4110)
		Pages = New String[2]
		Pages[0] = "$ES_PAGE_0"
		Pages[1] = "$ES_PAGE_3"
	endif
endEvent

; MENUS -------------------------------------------------------------------------------------------
Event OnMenuOpen(String MenuName)

EndEvent

Event OnMenuClose(String MenuName)

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
; ANIMATIONS --------------------------------------------------------------------------------------
;Handled by EC
; NODE TESTS --------------------------------------------------------------------------------------
;Handled by EC
; UNINSTALL ---------------------------------------------------------------------------------------
	bUninstallState    = zzEstrusSpiderUninstall.GetValueInt() as bool
; ADDSTRIP ----------------------------------------------------------------------------------------
; PREGNANCY ---------------------------------------------------------------------------------------
	bPregnancyEnabled  = !zzEstrusSpiderDisablePregnancy.GetValueInt() as bool
; GROWTH ------------------------------------------------------------------------------------------
;Handled by EC
; GENERAL -----------------------------------------------------------------------------------------
	if bUninstallState && zzEstrusSpiderInfected.GetValueInt() as bool
		iOptionFlag    = OPTION_FLAG_DISABLED
	else
		iOptionFlag    = OPTION_FLAG_NONE
	endIf
	
; MODS & DLC --------------------------------------------------------------------------------------
;Handled by EC
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
		AddHeaderOption("Spider spit effect")
		TentacleSpitEnabledOID = AddToggleOption("Tentacle", TentacleSpitEnabled)
		ParalyzeSpitEnabledOID = AddToggleOption("Paralyze", ParalyzeSpitEnabled)
		TentacleSpitChanceOID = addslideroption("Tentacle attack chance:", TentacleSpitChance, "{0} %")
		ParalyzeSpitChanceOID = addslideroption("Paralyze chance:", ParalyzeSpitChance, "{0} %")
; PREGNANCY ---------------------------------------------------------------------------------------
		AddHeaderOption("$ES_PREGNANCY_TITLE")
		AddToggleOptionST("STATE_PREGNANCY", "$ES_PREGNANCY", bPregnancyEnabled, iOptionFlag)
		if bPregnancyEnabled
			AddSliderOptionST("STATE_PERIOD", "$ES_PERIOD", zzEstrusSpiderIncubationPeriod.GetValue(), "{0}", iOptionFlag)
			AddSliderOptionST("STATE_FERTILITY_CHANCE", "$ES_FERTILITY_CHANCE", zzEstrusSpiderFertilityChance.GetValue(), "{0}", iOptionFlag)
			AddToggleOptionST("STATE_LIMIT_BIRTH_DURATION_TOGGLE", "$ES_LIMIT_BIRTH", zzEstrusSpiderBirth.GetValue(), iOptionFlag)
; AFTEREFFECTS ------------------------------------------------------------------------------------
			AddToggleOptionST("STATE_INFESTATION", "$ES_INFESTATION", zzEstrusSpiderInfestation.GetValueInt() as bool, iOptionFlag)
; GROWTH ------------------------------------------------------------------------------------------
;Handled by EC
		endIf
; ANIMATIONS --------------------------------------------------------------------------------------
;Handled by EC
; HATCHERY ----------------------------------------------------------------------------------------
	elseIf ( a_page == Pages[1] )
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
					( kHatchingEgg[iIndex] as zzEstrusSpider_EggsScript ).hatch()
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
;Handled by EC
; NODE TESTS --------------------------------------------------------------------------------------
;Handled by EC
; VERSION CHECK -----------------------------------------------------------------------------------
;Handled by EC
	endIf
endEvent

event OnOptionSelect(int option)
	if (option == TentacleSpitEnabledOID)
        TentacleSpitEnabled = !TentacleSpitEnabled
        SetToggleOptionValue(TentacleSpitEnabledOID, TentacleSpitEnabled)
	endif
	if (option == ParalyzeSpitEnabledOID)
        ParalyzeSpitEnabled = !ParalyzeSpitEnabled
        SetToggleOptionValue(ParalyzeSpitEnabledOID, ParalyzeSpitEnabled)
	endif
endevent

event OnOptionHighlight(int option)
    if (option == TentacleSpitEnabledOID)
        SetInfoText("Enables Tentacle attacks when hit by Spider spit.\nDefault: false")
    elseif (option == TentacleSpitChanceOID)
		SetInfoText("Chance that being hit by Spider spit will start a Tentacle attack.\nDefault: 20")
    elseif (option == ParalyzeSpitEnabledOID)
       SetInfoText("Enables Paralyze when hit by Spider spit.\nDefault: true")
    elseif (option == ParalyzeSpitChanceOID)
		SetInfoText("Chance that being hit by Spider spit will Paralyze actor.\nDefault: 20")
    endif
endevent

Event OnOptionSliderOpen(int opt)
	if opt == TentacleSpitChanceOID
		SetSliderDialogStartValue(TentacleSpitChance)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	elseif opt == ParalyzeSpitChanceOID
		SetSliderDialogStartValue(ParalyzeSpitChance)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endIf
endevent

Event OnOptionSliderAccept(int opt, float val)
	if opt == TentacleSpitChanceOID
		TentacleSpitChance = val as int
		SetSliderOptionValue(opt, TentacleSpitChance, "{0} %")
	elseif opt == ParalyzeSpitChanceOID
		ParalyzeSpitChance = val as int
		SetSliderOptionValue(opt, ParalyzeSpitChance, "{0} %")
	endif
endevent

; INFECTED ----------------------------------------------------------------------------------------
state STATE_UNINSTALL
	event OnSelectST()
		zzEstrusSpiderUninstall.SetValueInt( Math.LogicalXor( 1, zzEstrusSpiderUninstall.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusSpiderUninstall.GetValueInt() as Bool )
		if !zzEstrusSpiderUninstall.GetValueInt() as Bool
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
		If ShowMessage("$ES_UPDATE_EXIT")
			zzestrusspider_BodyMod BodyMod = Quest.GetQuest("zzestrusspider_BodyMod") as zzestrusspider_BodyMod
		
			Utility.Wait( 0.1 )

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
			
			Actor akActor = Game.GetCurrentCrosshairRef() as Actor
		
			If akActor == None
				akActor = Player
			Endif
			bool IsFemale = (akActor.GetLeveledActorBase().GetSex() == 1)

			idx2 = nodes.length

			While idx2 >0
				idx2 -= 1
				BodyMod.SetNodeScale(akActor, nodes[idx2], 1, isFemale)
			endWhile

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
		zzEstrusSpiderDisablePregnancy.SetValueInt( Math.LogicalXor( 1, zzEstrusSpiderDisablePregnancy.GetValueInt() ) )
		SetToggleOptionValueST( zzEstrusSpiderDisablePregnancy.GetValueInt() as Bool )
		ForcePageReset()
	endEvent

	event OnDefaultST()
		zzEstrusSpiderDisablePregnancy.SetValueInt( 0 )
		SetToggleOptionValueST( false )
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_PREGNANCY_INFO")
	endEvent
endState

state STATE_PERIOD ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusSpiderIncubationPeriod.GetValueInt() )
		SetSliderDialogDefaultValue( 3 )
		SetSliderDialogRange( 1, 30 )
		SetSliderDialogInterval( 1 )
	endEvent

	event OnSliderAcceptST(float value)
		int thisValue = value as int
		zzEstrusSpiderIncubationPeriod.SetValueInt( thisValue )
		SetSliderOptionValueST( thisValue )
	endEvent

	event OnDefaultST()
		zzEstrusSpiderIncubationPeriod.SetValueInt( 3 )
		SetSliderOptionValueST( 3 )
	endEvent

	event OnHighlightST()
		SetInfoText("$ES_PERIOD_INFO")
	endEvent
endState

state STATE_FERTILITY_CHANCE ; SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue( zzEstrusSpiderFertilityChance.GetValue() )
		SetSliderDialogDefaultValue( 5 )
		SetSliderDialogRange( 0, 25 )
		SetSliderDialogInterval( 1 )
	endEvent

	event OnSliderAcceptST(float value)
		int thisValue = value as int
		zzEstrusSpiderFertilityChance.SetValue( thisValue )
		SetSliderOptionValueST( thisValue )
	endEvent

	event OnDefaultST()
		zzEstrusSpiderFertilityChance.SetValue( 5 )
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
;Handled by EC
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
;Handled by EC
; NODE SCALE --------------------------------------------------------------------------------------
;Handled by EC
;EVENTS ------------------------------------------------------------------------------------
;Handled by EC
; ANIMATIONS --------------------------------------------------------------------------------------
;Handled by EC
; MODS & DLC --------------------------------------------------------------------------------------
;Handled by EC



; Scaling & stripping --------------------------------------------------------------------------------------
;moved here from ability/alias

function stripActor(actor akVictim)
	Keyword SexLabNoStrip = KeyWord.GetKeyword("SexLabNoStrip") as Keyword
	Form ItemRef = None
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(30))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(31))
	;StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(0x00000004) ;32
	StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(33))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(34))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(37)) #You can keep your boots on!#
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(38))
	;StripItem(akVictim, ItemRef)	
	ItemRef = akVictim.GetWornForm(0x00000200) ;39
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(0x00020000) ;47
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetEquippedWeapon(false)
	if ItemRef && !ItemRef.HasKeyword(SexLabNoStrip)
		akVictim.UnequipItemEX(ItemRef, 1, false)
	endIf
	ItemRef = akVictim.GetEquippedWeapon(true)
	if ItemRef && !ItemRef.HasKeyword(SexLabNoStrip)
		akVictim.UnequipItemEX(ItemRef, 2, false)
	endif
endfunction

function StripItem(actor akVictim, form ItemRef)
	Keyword SexLabNoStrip = KeyWord.GetKeyword("SexLabNoStrip") as Keyword
	If ItemRef && !ItemRef.HasKeyword(SexLabNoStrip)
		Armor akArmor = ItemRef as Armor
		akVictim.UnequipItem(ItemRef, false, true)
	endif
endfunction

Function SetNodeScaleBelly(Actor akActor, bool isFemale, float value)
	zzestrusspider_BodyMod BodyMod = Quest.GetQuest("zzestrusspider_BodyMod") as zzestrusspider_BodyMod

	BodyMod.SetNodeScale(akActor, NINODE_BELLY, value, isFemale)
EndFunction

Function SetNodeScaleButt(Actor akActor, bool isFemale, float value)
	zzestrusspider_BodyMod BodyMod = Quest.GetQuest("zzestrusspider_BodyMod") as zzestrusspider_BodyMod

	BodyMod.SetNodeScale(akActor, NINODE_LEFT_BUTT, value, isFemale)
	BodyMod.SetNodeScale(akActor, NINODE_RIGHT_BUTT, value, isFemale)
EndFunction

Function SetNodeScaleBreast(Actor akActor, bool isFemale, float value, float value01)
	zzestrusspider_BodyMod BodyMod = Quest.GetQuest("zzestrusspider_BodyMod") as zzestrusspider_BodyMod

	BodyMod.SetNodeScale(akActor, NINODE_LEFT_BREAST, value, isFemale)
	BodyMod.SetNodeScale(akActor, NINODE_RIGHT_BREAST, value, isFemale)
	if bTorpedoFixEnabled
		BodyMod.SetNodeScale(akActor, NINODE_LEFT_BREAST01, value01, isFemale)
		BodyMod.SetNodeScale(akActor, NINODE_RIGHT_BREAST01, value01, isFemale)
	endIf
EndFunction

float Function GetNodeTransformScale(Actor akActor, bool isFemale, string nodeName)
	zzestrusspider_BodyMod BodyMod = Quest.GetQuest("zzestrusspider_BodyMod") as zzestrusspider_BodyMod

	return BodyMod.GetNodeScale(akActor, nodeName, isFemale)
EndFunction
