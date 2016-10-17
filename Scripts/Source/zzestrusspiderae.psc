Scriptname zzEstrusSpiderAE extends Quest

; VERSION 1
sslSystemConfig           property SexLabMCM                        auto
SexLabFramework           property SexLab                           auto
Faction                   property Spider                          auto
Faction                   property SexLabAnimating                  auto
Spell                     property zzSpiderParasite                auto 
MagicEffect[]             property crSpiderPoison                  auto 
Armor                     property zzEstrusSpiderParasite          auto  
Armor                     property zzEstrusChaurusFluid             auto  
GlobalVariable            property zzEstrusChaurusFluids            auto  

; VERSION 2
Spell                     property zzEstrusSpiderBreederAbility    auto
Faction                   property zzEstrusSpiderBreederFaction    auto

; VERSION 3
Faction                   property CurrentFollowerFaction           auto
Keyword                   property ActorTypeNPC                     auto

; VERSION 5
zzEstrusSpiderMCMScript  property mcm                              auto 

; VERSION 6
Faction                   property CurrentHireling                  auto

; VERSION 8
Armor                     property zzEstrusSpiderDwemerBinders     auto


; VERSION 11
Faction                   property zzEstrusSpiderExclusionFaction  auto


;Version 12 AE Removal
Actor[] 				  Property myActorsList  					Auto

;Version 13

;zadlibs dDlibs = None
;bool dDLoaded = false

sound 					 Property zzEstrusTentacleFX				Auto

; VERSION 14 - ES+ 3.382
;Actor[]            sexActors *Deprecated*
;sslBaseAnimation[] animations *Deprecated*
;int FxID0 = 0 *Deprecated*
;int FXID1 = 0 *Deprecated*
; VERSION 15 - ES+ 3.383
zzestrusspiderevents  property ESevents                            Auto 

; START AE VERSIONING =========================================================
; This functions exactly as and has the same purpose as the SkyUI function
; GetVersion(). It returns the static version of the AE script.
int function aeGetVersion()
	return 11
endFunction

function aeUpdate( int aiVersion )
	
	int myVersion = 11 

	if (myVersion >= 2 && aiVersion < 2)
		zzEstrusSpiderBreederAbility = Game.GetFormFromFile(0x0004e255, "EstrusSpider.esp") as Spell
		zzEstrusSpiderBreederFaction = Game.GetFormFromFile(0x0004e258, "EstrusSpider.esp") as Faction
	endIf
	if (myVersion >= 3 && aiVersion < 3)
		myActorsList = New Actor[10]
		myActorsList[0] = Game.GetPlayer()

		CurrentFollowerFaction = Game.GetFormFromFile(0x0005c84e, "Skyrim.esm") as Faction
		ActorTypeNPC = Game.GetFormFromFile(0x00013794, "Skyrim.esm") as Keyword
	endIf
	if (myVersion >= 4 && aiVersion < 4)
		myActorsList = New Actor[20]
		myActorsList[0] = Game.GetPlayer()
	endIf
	if (myVersion >= 5 && aiVersion < 5)	
		mcm = ( self as quest ) as zzEstrusSpiderMCMScript
	endIf
	if (myVersion >= 6 && aiVersion < 6)
		CurrentHireling = Game.GetFormFromFile(0x000bd738, "Skyrim.esm") as Faction
	endIf
	if (myVersion >= 7 && aiVersion < 7)
		myActorsList = New Actor[20]

		int idx = myActorsList.length
		while idx > 1
			idx -= 1
			myActorsList[idx] = none
		endWhile

		myActorsList[0] = Game.GetPlayer()
	endIf
	if (myVersion >= 10 && aiVersion < 10)
		zzEstrusSpiderDwemerBinders = Game.GetFormFromFile(0x0004e267, "EstrusSpider.esp") as Armor
	endIf
	if (myVersion >= 11 && aiVersion < 11)
		zzEstrusSpiderExclusionFaction = Game.GetFormFromFile(0x0004e265, "EstrusSpider.esp") as Faction
	endIf

endFunction

function RegisterForSLSpider()
	
	debug.notification("ES+ "+ mcm.GetStringVer() + " Registered...")
	RegisterForModEvent("OrgasmStart", "onOrgasm")

endfunction

; START ES FUNCTIONS ==========================================================
int function AddCompanions()
	myActorsList[0] = Game.GetPlayer()

	Actor thisActor = none
	Int   thisCount = 0
	Cell  thisCell  = myActorsList[0].GetParentCell()
	Int   idxNPC    = thisCell.GetNumRefs(43)
	
	Bool  check1    = false
	Bool  check2    = false
	Bool  check3    = false
	
	Debug.TraceConditional("$ES_COMPANIONS_CHECK", true)
	
	while idxNPC > 0 && thisCount < 19
		idxNPC -= 1
		thisActor = thisCell.GetNthRef(idxNPC,43) as Actor
		
		check1 = thisActor && !thisActor.IsDead() && !thisActor.IsDisabled()
		check2 = check1 && myActorsList.Find(thisActor) < 0 && thisActor.HasKeyword(ActorTypeNPC)
		check3 = check2 && ( thisActor.GetFactionRank(CurrentHireling) >= 0 || thisActor.GetFactionRank(CurrentFollowerFaction) >= 0 || thisActor.IsPlayerTeammate() )

		if check3
			thisCount += 1
			myActorsList[thisCount] = thisActor
			Debug.TraceConditional("ES::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + "@"+thisCount, true) ;ae.VERBOSE)
		else
			Debug.TraceConditional("ES::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + ":false", true) ;ae.VERBOSE)
		endif
	endWhile
	
	return thisCount
endFunction

function RemoveCompanions()
	Int idxNPC = myActorsList.length
	while idxNPC > 1
		idxNPC -= 1
		myActorsList[idxNPC] = none
	endWhile
endFunction


; // Our callback we registered onto the global event 
event onOrgasm(string eventName, string argString, float argNum, form sender)
	if mcm.zzEstrusDisablePregnancy2.GetValueInt()
    	return
    endif	
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = SexLab.HookActors(argString)
    ; // See if a Spider was involved
   	if actorlist.length > 1 && actorlist[1].IsInFaction(spider)
   		SpiderImpregnate(actorlist[0], actorlist[1])
   	endif

endEvent


function SpiderImpregnate(actor akVictim, actor akAgressor)

	Bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akvictim.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || ( akVictim.IsInFaction(zzEstrusSpiderExclusionFaction) || akVictim.IsBleedingOut() || akVictim.isDead() )

	if invalidateVictim
		return
	endif

	ESevents.Oviposition(akvictim)

	if ( !akAgressor.IsInFaction(zzEstrusSpiderBreederFaction) )
		akAgressor.AddToFaction(zzEstrusSpiderBreederFaction)
	endIf
	
	SexLab.ApplyCum(akvictim, 7)
	
	utility.wait(5) ; Allow time for ES to register oviposition
	akVictim.DispelSpell(zzSpiderParasite)

endfunction

function SpiderSpitAttack(Actor akVictim, Actor akAgressor)

	if mcm.TentacleSpitEnabled
		if utility.randomint(1,100) <= mcm.TentacleSpitChance
			
			if ESEvents.OnESStartAnimation(self, akVictim, 0, true, 0, true)
				if !akAgressor.IsInFaction(zzEstrusSpiderBreederFaction) 
					;ESEvents.OnESStartAnimation(self, akVictim, 0, true, 0, true)
					akAgressor.AddToFaction(zzEstrusSpiderBreederFaction)
				endif
			endIf
		endIf
	endif
	
endfunction
