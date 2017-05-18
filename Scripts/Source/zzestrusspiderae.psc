Scriptname zzEstrusSpiderAE extends Quest

Faction                   property Spider                           auto
Spell                     property zzSpiderParasite                 auto 
Faction                   property zzEstrusSpiderExclusionFaction   auto

zzEstrusSpiderMCMScript   property mcm                              auto 
zzestrusspiderevents 	  property ESevents                         auto 

function RegisterForSLSpider()
	
	debug.notification("ES+ "+ mcm.GetStringVer() + " Registered...")
	RegisterForModEvent("OrgasmStart", "onOrgasm")
	RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	RegisterForModEvent("SexLabOrgasmSeparate", "onOrgasmS")

endfunction

; START ES FUNCTIONS ==========================================================

; // Our callback we registered onto the global event 
event onOrgasmS(Form ActorRef, Int Thread)
	actor akActor = ActorRef as actor
	string id = Thread as string
	
   ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(id)
 
	if mcm.zzEstrusDisablePregnancy2.GetValueInt()
    	return
    endif
	
	if actorList.Length > 1 && akActor != actorList[0]
		;See if spider was involved
		if IsSpiderRace(actorlist[actorList.Length - 1].GetRace()) == true ;SD+ Faction changes mean we can't rely on a faction check
			SpiderImpregnate(actorlist[0], actorlist[actorList.Length - 1])
			return
		else
			; // See if actor has spider penis from SexLab Parasites - Kyne's Blessing
			Keyword _SLP_ParasiteSpiderPenis = Keyword.GetKeyword("_SLP_ParasiteSpiderPenis")
			if _SLP_ParasiteSpiderPenis != none
				if actorlist[actorList.Length - 1].WornHasKeyword(_SLP_ParasiteSpiderPenis)
					SpiderImpregnate(actorlist[0], actorlist[actorList.Length - 1])
				endif
			endif
		endif
	endif

endEvent

; // Our callback we registered onto the global event 
event onOrgasm(string eventName, string argString, float argNum, form sender)
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(argString)
 
	if mcm.zzEstrusDisablePregnancy2.GetValueInt()
    	return
    endif
	
	if actorlist.Length > 1
		;See if spider was involved
		if IsSpiderRace(actorlist[actorList.Length - 1].GetRace()) == true ;SD+ Faction changes mean we can't rely on a faction check
			SpiderImpregnate(actorlist[0], actorlist[actorList.Length - 1])
			return
		else
			; // See if actor has spider penis from SexLab Parasites - Kyne's Blessing
			Keyword _SLP_ParasiteSpiderPenis = Keyword.GetKeyword("_SLP_ParasiteSpiderPenis")
			if _SLP_ParasiteSpiderPenis != none
				if actorlist[actorList.Length - 1].WornHasKeyword(_SLP_ParasiteSpiderPenis)
					SpiderImpregnate(actorlist[0], actorlist[actorList.Length - 1])
				endif
			endif
		endif
	endif

endEvent

; // Our callback we registered onto the global event 
event OnSexLabEnd(string eventName, string argString, float argNum, form sender)
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(argString)
 
	; // See if a Spider was involved, and try to fix broken spider animation it for SL1.62
   	if actorlist.Length > 1 && IsSpiderRace(actorlist[1].GetRace()) == true
		Utility.Wait(0.1)
   		actorlist[1].disable()
   		actorlist[1].enable()
		;Utility.Wait(1)
		;actorlist[1].MoveToMyEditorLocation()
   	endif

endEvent

bool function IsSpiderRace(race akRace)
	if akRace == (Game.GetFormFromFile(0x131F8 , "Skyrim.esm") as Race) ;FrostbiteSpiderRace
		return true
	elseif akRace == (Game.GetFormFromFile(0x4e507 , "Skyrim.esm") as Race) ;FrostbiteSpiderRaceGiant
		return true
	elseif akRace == (Game.GetFormFromFile(0x53477 , "Skyrim.esm") as Race) ;FrostbiteSpiderRaceLarge
		return true
	elseif Game.GetModbyName("Dragonborn.esm") != 255
		if akRace == (Game.GetFormFromFile(0x14449 , "Dragonborn.esm") as Race) ;DLC2ExpSpiderBaseRace
			return true
		elseif akRace == (Game.GetFormFromFile(0x27483 , "Dragonborn.esm") as Race) ;DLC2ExpSpiderPackmuleRace
			return true
		endif
	endif
	return false
endfunction


function SpiderImpregnate(actor akVictim, actor akAgressor)

	Bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akvictim.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || ( akVictim.IsInFaction(zzEstrusSpiderExclusionFaction) || akVictim.IsBleedingOut() || akVictim.isDead() )

	if invalidateVictim
		return
	endif

	ESevents.Oviposition(akvictim)

	if ( !akAgressor.IsInFaction(mcm.zzEstrusSpiderBreederFaction) )
		akAgressor.AddToFaction(mcm.zzEstrusSpiderBreederFaction)
	endIf
	
	mcm.SexLab.ApplyCum(akvictim, 7)
	
	utility.wait(5) ; Allow time for ES to register oviposition and crowd control to kick in
	akVictim.DispelSpell(zzSpiderParasite)

endfunction

function SpiderSpitAttack(Actor akVictim, Actor akAgressor)

	if mcm.TentacleSpitEnabled
		if utility.randomint(1,100) <= mcm.TentacleSpitChance
			
			if ESEvents.OnESStartAnimation(self, akVictim, 0, true, 0, true)
				if !akAgressor.IsInFaction(mcm.zzEstrusSpiderBreederFaction) 
					akAgressor.AddToFaction(mcm.zzEstrusSpiderBreederFaction)
				endif
			endIf
		endIf
	endif
	
endfunction
