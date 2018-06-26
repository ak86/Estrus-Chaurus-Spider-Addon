Scriptname zzEstrusSpider_AE extends Quest

zzEstrusSpider_MCMScript property mcm auto 
zzEstrusSpider_Events property ESevents auto 

Spell property zzEstrusSpiderParasite auto 
Spell property zzEstrusSpiderAnimationCooldown auto 

function RegisterForSLSpider()
	
	;debug.notification("ES+ "+ mcm.GetStringVer() + " Registered...")
	RegisterForModEvent("OrgasmStart", "onOrgasm")
	RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	RegisterForModEvent("SexLabOrgasmSeparate", "onOrgasmS")

endfunction

; START ES FUNCTIONS ==========================================================

; // Our callback we registered onto the global event 
event onOrgasmS(Form ActorRef, Int Thread)
	actor akActor = ActorRef as actor
	
   ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(Thread as string)
	sslThreadController controller = mcm.Sexlab.GetController(Thread)
 
	if mcm.zzEstrusSpiderDisablePregnancy.GetValueInt()
    	return
    endif
	
	if actorList.Length > 1 && akActor != actorList[0]
		;See if spider was involved
		if mcm.Sexlab.PregnancyRisk(Thread, actorlist[0], false, true)
			if IsSpider(akActor) == true					;Bane Master: - SD+ Faction changes mean we can't rely on a faction check. Ed86: - you cant, but i can muahahah!
				SpiderImpregnate(actorlist[0], akActor)
			endif
		endif
	endif

endEvent

; // Our callback we registered onto the global event 
event onOrgasm(string eventName, string argString, float argNum, form sender)
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(argString)
 	sslThreadController controller = mcm.Sexlab.GetController(argString as Int)

	if mcm.zzEstrusSpiderDisablePregnancy.GetValueInt()
    	return
    endif
	
	if actorlist.Length > 1
		int i = 1
		while i < actorlist.Length
			;See if spider was involved
			if mcm.Sexlab.PregnancyRisk(argString as Int, actorlist[0], false, true)
				if IsSpider(actorlist[i]) == true				;Bane Master: - SD+ Faction changes mean we can't rely on a faction check. Ed86: - you cant, but i can muahahah!
					SpiderImpregnate(actorlist[0], actorlist[i])
				endif
			endif
			i += 1
		endwhile
	endif
endEvent

; // Our callback we registered onto the global event 
event OnSexLabEnd(string eventName, string argString, float argNum, form sender)
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = mcm.SexLab.HookActors(argString)
 
	; // See if a Creature was involved, and try to fix broken spider animation it for SL1.62
   	if actorlist.Length > 1
		int i = 0
		while i < actorlist.Length
			if IsSpider(actorlist[i])
				Utility.Wait(0.1)
				actorlist[i].disable()
				actorlist[i].enable()
				;Utility.Wait(1)
				;actorlist[1].MoveToMyEditorLocation()
			endif
			i += 1
		endwhile
   	endif
endEvent

bool function IsSpider(Actor akActor)
	; // See if actor has spider penis from SexLab Parasites - Kyne's Blessing
	; // Non spider impregnation with _SLP_ParasiteSpiderPenis
	Keyword _SLP_ParasiteSpiderPenis = Keyword.GetKeyword("_SLP_ParasiteSpiderPenis")
	if _SLP_ParasiteSpiderPenis != none
		if akActor.WornHasKeyword(_SLP_ParasiteSpiderPenis)
			return true
		endif
	endif
	
	; // See if actor has is creature or animal and is in spider faction
	; // Vanilla+DLC+moded spiders
	if akActor.HasKeyword( Game.GetFormFromFile(0x13795, "Skyrim.esm") as Keyword ) || akActor.HasKeyword( Game.GetFormFromFile(0x13798, "Skyrim.esm") as Keyword ) ;ActorTypeCreature, ActorTypeAnimal Keyword
		if akActor.IsInFaction(Game.GetFormFromFile(0x2997F , "Skyrim.esm") as Faction)	;SpiderFaction
			return true
		endif
	endif
	
	; // See if actor is spider race
	; // Vanilla+DLC only spiders
	Race akRace = akActor.GetRace()
	if akRace == (Game.GetFormFromFile(0x131F8 , "Skyrim.esm") as Race)	;FrostbiteSpiderRace
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
	Bool invalidateVictim = !bGenderOk || ( akVictim.IsBleedingOut() || akVictim.isDead() )
	
	if invalidateVictim
		return
	endif

	ESevents.Oviposition(akvictim)

	if ( !akAgressor.IsInFaction(mcm.zzEstrusSpiderBreederFaction) )
		akAgressor.AddToFaction(mcm.zzEstrusSpiderBreederFaction)
	endIf
	
	mcm.SexLab.ApplyCum(akvictim, 7)
	
	utility.wait(5) ; Allow time for ES to register oviposition and crowd control to kick in
	akVictim.DispelSpell(zzEstrusSpiderParasite)

endfunction

function SpiderSpitAttack(Actor akVictim, Actor akAgressor)

	if !akVictim.HasSpell(zzEstrusSpiderAnimationCooldown)
		if mcm.TentacleSpitEnabled
			if utility.randomint(1,100) <= mcm.TentacleSpitChance
				zzEstrusSpiderAnimationCooldown.cast(akVictim,akVictim)
				
				if ESevents.OnESStartAnimation(self, akVictim, 0, true, 0, true)
					if !akAgressor.IsInFaction(mcm.zzEstrusSpiderBreederFaction) 
						akAgressor.AddToFaction(mcm.zzEstrusSpiderBreederFaction)
					endif
				endIf
			endIf
		elseif mcm.ParalyzeSpitEnabled
			if utility.randomint(1,100) <= mcm.ParalyzeSpitChance
				zzEstrusSpiderAnimationCooldown.cast(akVictim,akVictim)
				
;				Spell paralyzeSpell = (Game.GetFormFromFile(0x52DE4 , "EstrusSpider.esp") as Spell)
;				if paralyzeSpell
;					paralyzeSpell.cast(akVictim,akVictim)
;					
;					;cocoon test
;					if akVictim == game.GetPlayer()
;						;disable pc moving
;						Game.DisablePlayerControls()
;					Else
;						;disable npc moving
;						akVictim.Setunconscious(true)
;					EndIf
;					Debug.SendAnimationEvent(akVictim,"ZapWriPose14")
;					;akVictim.EquipItem(Game.GetFormFromFile(0x5960, "ZaZAnimationPack.esm"), 1, true)
;					;akVictim.EquipItem(Game.GetFormFromFile(0x6436 , "ZaZAnimationPack.esm"), 1, true)
;
;					;Utility.wait(20.0)
;					akVictim.dispelSpell(paralyzeSpell)
					Utility.wait(2.0)
;
;					;akVictim.UNEquipItem(Game.GetFormFromFile(0x5960, "ZaZAnimationPack.esm"), true)
;					;akVictim.UNEquipItem(Game.GetFormFromFile(0x6436 , "ZaZAnimationPack.esm"), true)
;					;akVictim.RemoveItem(Game.GetFormFromFile(0x5960, "ZaZAnimationPack.esm"), 1, true)
;					;akVictim.RemoveItem(Game.GetFormFromFile(0x6436 , "ZaZAnimationPack.esm"), 1, true)
;					Debug.SendAnimationEvent(akVictim, "IdleForceDefaultState")
;					if akVictim == game.GetPlayer()
;						;enable pc moving
;						Game.EnablePlayerControls()
;					Else
;						;enable npc moving
;						akVictim.Setunconscious(false)
;					EndIf
;			   endif
				
				if ESevents.OnESStartAnimation_xjAlt(self, akVictim, akAgressor)
					if !akAgressor.IsInFaction(mcm.zzEstrusSpiderBreederFaction) 
						akAgressor.AddToFaction(mcm.zzEstrusSpiderBreederFaction)
					endif
				endIf
			endIf
		endif
	endif
	
endfunction
