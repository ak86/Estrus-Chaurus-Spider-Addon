Scriptname zzEstrusSpiderAE extends Quest

Faction                   property Spider                           auto
Spell                     property zzSpiderParasite                 auto 
Faction                   property zzEstrusSpiderExclusionFaction   auto

zzEstrusSpiderMCMScript   property mcm                              auto 
zzestrusspiderevents 	  property ESevents                         auto 

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
    actor[] actorList = mcm.SexLab.HookActors(argString)
	
    ; // See if a Spider was involved
   	if actorlist.length > 1 && actorlist[1].IsInFaction(spider)
   		SpiderImpregnate(actorlist[0], actorlist[1])
   	endif
	
    ; // See if actor has spider penis from SexLab Parasites - Kyne's Blessing
    ; // if true, impregnate victim
	Keyword _SLP_ParasiteSpiderPenis = Keyword.GetKeyword("_SLP_ParasiteSpiderPenis")
	if _SLP_ParasiteSpiderPenis != none
		if actorlist[1].WornHasKeyword(_SLP_ParasiteSpiderPenis)
			if actorlist.length > 1
				SpiderImpregnate(actorlist[0], actorlist[1])
			endif
		endif
	endif

endEvent

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
