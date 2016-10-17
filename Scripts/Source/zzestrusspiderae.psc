Scriptname zzEstrusSpiderAE extends Quest

; VERSION 1
sslSystemConfig           property SexLabMCM                        auto
SexLabFramework           property SexLab                           auto
Faction                   property Spider                           auto
Faction                   property SexLabAnimating                  auto
Spell                     property zzSpiderParasite                 auto 
MagicEffect[]             property crSpiderPoison                   auto 
Armor                     property zzEstrusSpiderParasite           auto  
Armor                     property zzEstrusChaurusFluid             auto  
GlobalVariable            property zzEstrusChaurusFluids            auto  

; VERSION 2
Spell                     property zzEstrusSpiderBreederAbility     auto
Faction                   property zzEstrusSpiderBreederFaction     auto

; VERSION 3
Faction                   property CurrentFollowerFaction           auto
Keyword                   property ActorTypeNPC                     auto

; VERSION 5
zzEstrusSpiderMCMScript   property mcm                              auto 

; VERSION 6
Faction                   property CurrentHireling                  auto

; VERSION 8
Armor                     property zzEstrusSpiderDwemerBinders      auto


; VERSION 11
Faction                   property zzEstrusSpiderExclusionFaction   auto


;Version 12 AE Removal
;Actor[] 				  Property myActorsList  					Auto    Deprecated in Version 16

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

; VERSION 16 - EC+ 4.11

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
		;myActorsList = New Actor[10] 			Deprecated
		;myActorsList[0] = Game.GetPlayer()		Deprecated

		CurrentFollowerFaction = Game.GetFormFromFile(0x0005c84e, "Skyrim.esm") as Faction
		ActorTypeNPC = Game.GetFormFromFile(0x00013794, "Skyrim.esm") as Keyword
	endIf
	if (myVersion >= 4 && aiVersion < 4)
		;myActorsList = New Actor[20]			Deprecated
		;myActorsList[0] = Game.GetPlayer()		Deprecated
	endIf
	if (myVersion >= 5 && aiVersion < 5)	
		mcm = ( self as quest ) as zzEstrusSpiderMCMScript
	endIf
	if (myVersion >= 6 && aiVersion < 6)
		CurrentHireling = Game.GetFormFromFile(0x000bd738, "Skyrim.esm") as Faction
	endIf
	if (myVersion >= 7 && aiVersion < 7)
		;myActorsList = New Actor[20] 			Deprecated

		;int idx = myActorsList.length			Deprecated
		;while idx > 1							Deprecated
		;	idx -= 1							Deprecated
		;	myActorsList[idx] = none			Deprecated
		;endWhile								Deprecated

		;myActorsList[0] = Game.GetPlayer()		Deprecated
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
	
	utility.wait(5) ; Allow time for ES to register oviposition and crowd control to kick in
	akVictim.DispelSpell(zzSpiderParasite)

endfunction

function SpiderSpitAttack(Actor akVictim, Actor akAgressor)

	if mcm.TentacleSpitEnabled
		if utility.randomint(1,100) <= mcm.TentacleSpitChance
			
			if ESEvents.OnESStartAnimation(self, akVictim, 0, true, 0, true)
				if !akAgressor.IsInFaction(zzEstrusSpiderBreederFaction) 
					akAgressor.AddToFaction(zzEstrusSpiderBreederFaction)
				endif
			endIf
		endIf
	endif
	
endfunction
