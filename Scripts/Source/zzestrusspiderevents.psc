Scriptname zzestrusSpiderevents extends Quest

zzEstrusSpiderMCMScript  property mcm Auto

Actor[] sexActors

sslBaseAnimation[] animations

actor Property PlayerRef Auto

faction property ESTentaclefaction Auto
faction property ESVictimfaction Auto
faction property zzEstrusSpiderExclusionFaction  auto
faction property CurrentFollowerFaction auto

armor  property zzEstrusSpiderDwemerBinders  auto
armor  property zzEstrusSpiderDwemerBelt  auto
armor  property zzEstrusSpiderParasite auto 
armor  property zzEstrusChaurusEtc02 auto 

spell property zzSpiderParasite  auto 
spell property DwemerExhaustion Auto

explosion property TentacleExplosion Auto

sound Property zzEstrusTentacleFX Auto
sound property zzEstrusChaurusVibrate Auto

Quest property zzEstrusSpider Auto
Quest property zzestruschaurusVictims Auto
Quest property zzestruschaurusSpectators Auto

Actor[] Victim

Keyword property zzEstrusSpiderArmor Auto
Keyword ESpkg = None

int EventFxID0 = 0
int EventFxID1 = 0
int iNotifyStage = 0

String strCallback

bool dDLoaded = false
bool UseESFx = true

zadlibs dDlibs = None


;************************************
;**Estrus Spider Public Interface **
;************************************
;
;The ES interface uses ModEvents.  This method can be used without loading ES as a master or using GetFormFromFile
; 
;To call an ES event use the following code:
;
; 	int ESTrap = ModEvent.Create("ESStartAnimation"); Int 			Int does not have to be named "ECTrap" any name would do
;	if (ESTrap)	
;   	ModEvent.PushForm(ESTrap, self)             ; Form			Pass the calling form to the event
;   	ModEvent.PushForm(ESTrap, akActor) 			; Form	 		The animation target
;   	ModEvent.PushInt(ESTrap, EstrusTraptype)    ; Int			The animation required   -1 = Impregnation only with No Amimation ,  0 = Tentacles, 1 = Machines 2 = Slime 3 = Ooze
;   	ModEvent.PushBool(ESTrap, true)             ; Bool			Apply the linked ES effect (Ovipostion for Tentacles, Slime & Ooze, Exhaustion for Machine) 
;   	ModEvent.Pushint(ESTrap, 500)               ; Int			Alarm radius in units (0 to disable) 
;   	ModEvent.PushBool(ESTrap, true)             ; Bool			Use ES (basic) crowd control on hostiles if the Player is trapped
;   	ModEvent.Send(EStrap)
;	else
;		;ES is not installed
;	endIf
;
; Setting the animation required to -1 applies ES breeder effect without any animation or visual effects, alarms, chastity device checks, or crowd control however ALL 6 parameters still
; need to be passed for the modevent to function.
;
; To use impregnation only the required parameter values are:  self, akActor, -1, False, 0, False
;
;
;
;To register a callback to trigger on a specific stage of the next animation played use this modevent immediately BEFORE calling the ES event
;
;	SendModEvent("ESRegisterforStage,"MyModsCallbackName", CallbackAnimationStage as Float)
;
; 	**NB** Only one stage can be registered & the callback registration is cleared once the animation plays, it must therefore be sent each time you trigger the EC animation event that needs a stage callback
;	Don't forget to Register for the callback event (e.g. RegisterForModEvent("MyModsCallbackName", "OnESStage" ) in your own mod 
;
;************************************
; Please do not link directly to ES functions - they are likely to change and break your mod!

function InitModEvents()

	RegisterForModEvent("ESRegisterforStage", "OnESRegisterforStage")
	RegisterForModEvent("ESStartAnimation", "OnESStartAnimation")
	
	if Keyword.GetKeyword("zad_deviousBelt") as Keyword && !dDLoaded
		dDlibs = Game.GetFormFromFile(0xF624, "Devious Devices - Integration.esm") as Zadlibs
		if dDlibs != None
			debug.trace("_ES_::Loaded dD Integration")
			dDLoaded = true
		else
			debug.trace("_ES_::Devious Devices - Integration.esm not found - Devices will not be supported")
			dDLoaded = false
		endif
	endif 

endFunction

Function OnESRegisterforStage(String strEventName, String strReqCB, Float fStage, Form kSender)
	iNotifyStage = fStage as Int
	strCallback = strReqCB
EndFunction

bool function OnESStartAnimation(Form Sender, form akTarget, int intAnim, bool bUseFX, int intUseAlarm, bool bUseCrowdControl)

	actor akActor  = akTarget as Actor
	Bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akActor.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || akActor.IsInFaction(zzEstrusSpiderExclusionFaction) || akActor.IsBleedingOut() || akActor.isDead()

	if !invalidateVictim 
		int SexlabValidation = mcm.SexLab.ValidateActor(akActor)
		if intAnim == -1 && SexlabValidation != -12 ; Exclude Child Races
			Oviposition(akActor, false)
		elseif SexlabValidation == 1
			DoESAnimation(akActor, intAnim, bUseFX, intUseAlarm, bUseCrowdControl)
		else
			return false
		endif
		
		return true
	else
		return false
	endIf	
endfunction

function DoESAnimation(actor akVictim, int AnimID, bool UseFX, int UseAlarm, bool UseCrowdControl)

		bool isPlayer = (akVictim == PlayerRef)
		string EstrusType
		string strVictimRefid = akVictim.getformid() as string
		UseESFx = UseFx

		int EstrusID = AnimID

		If EstrusID == 1
			EstrusType = "Dwemer"
		Elseif EstrusID == 2
			EstrusType = "Slime"
		Elseif EstrusID == 3
			EstrusType = "Ooze"
		Else
			EstrusType = "Tentacle"
		Endif

		if UseFX
			If EstrusID == 0
				akvictim.placeatme(TentacleExplosion)
				if !isPlayer
					akvictim.pushactoraway(akVictim, 2)
					utility.wait(1)
				endif
			Elseif EstrusID == 3
				akvictim.placeatme(TentacleExplosion)
				utility.wait(1)
			endif
		endif

		armor dDArmbinder = none

		if dDLoaded

			dDArmbinder = dDlibs.GetWornDeviceFuzzyMatch(akVictim, dDlibs.zad_DeviousArmbinder) 

			if akVictim.WornHasKeyword(dDlibs.zad_DeviousBelt) || ( akVictim.WornHasKeyword(dDlibs.zad_DeviousHeavyBondage) && !dDArmbinder) || (dDArmbinder && dDArmbinder.HasKeyword(dDlibs.zad_BlockGeneric))
				if isPlayer
					if EstrusID == 1 
						debug.notification("A red dot scans over your devious devices and vanishes...")
					else
						debug.notification("Something nasty was warded away by your devious aura...")
					endIf
						if UseAlarm
							akvictim.CreateDetectionEvent(akVictim, UseAlarm)
						endif
					return
				endif
			endif
		endif

		If dDArmbinder
			dDlibs.ManipulateGenericDevice(akVictim, dDArmbinder, false)
			utility.wait(1)
			If !akVictim.GetWornForm(0x00010000) as Armor
				if isPlayer
					debug.notification("'Something' behind you deftly stripped off your armbinder...")					
				endIf
				akVictim.DropObject(dDArmbinder, 1)
			Else
				debug.notification("Something nasty was warded away by your devious aura...")
				if UseAlarm
					akvictim.CreateDetectionEvent(akVictim, UseAlarm)
				endif 
				return
			Endif
		Endif

		if isplayer
			SendModEvent("dhlp-Suspend") ;ES Scene starting - suspend Deviously Helpless Events
		endif 
		
		animations   = mcm.SexLab.GetAnimationsByTag(1, "Estrus", EstrusType)
		sexActors    = new actor[1]
		sexActors[0] = akVictim
		RegisterForModEvent("AnimationStart_" + strVictimRefid, "ESAnimStart")
		RegisterForModEvent("StageEnd_" + strVictimRefid, "ESAnimStage")
		RegisterForModEvent("AnimationEnd_" + strVictimRefid,   "ESAnimEnd")

		akVictim.StopCombatAlarm()
		akVictim.StopCombat()
	
		if mcm.SexLab.StartSex(sexActors, animations, akVictim, none, false, strVictimRefid) > -1
			if !zzestruschaurusVictims.IsRunning()
				zzestruschaurusVictims.start()
				utility.wait(0.5)
			endif
			int VictimRefs = zzestruschaurusVictims.GetNumAliases()
			while VictimRefs > 0
				VictimRefs -= 1
				If (zzestruschaurusVictims.GetNthAlias(VictimRefs)  as ReferenceAlias).ForceRefIfEmpty(akVictim)
					(zzestruschaurusVictims.GetNthAlias(VictimRefs)  as ReferenceAlias).RegisterForSingleUpdate(5)
					VictimRefs = 0
				endif
			endwhile

			if isplayer && UseCrowdControl
				zzestruschaurusSpectators.start()
				OnUpdate()
			endif
		endIf
		
		if UseAlarm
			akVictim.CreateDetectionEvent(akVictim, UseAlarm)
		endif

endFunction

event ESAnimStart(string hookName, string argString, float argNum, form sender)
	
	actor[] actorList = mcm.SexLab.HookActors(argString)
	sslBaseAnimation animation = mcm.SexLab.HookAnimation(argString)
	string strVictimRefid = actorList[0].getformid() as string
	bool isPlayer = (actorlist[0] == PlayerRef)
	armor zzEstrusArmorItem = none

	actorList[0].RestoreActorValue("health", 10000)

	if animation.hastag("Machine")
		
		if animation.name == "Dwemer Machine"
			zzEstrusArmorItem = zzEstrusSpiderDwemerBinders
		else
			zzEstrusArmorItem = zzEstrusSpiderDwemerBelt
		endif

		utility.wait(0.3)
		if isplayer
			actorList[0].EquipItem(zzEstrusArmorItem, true, true)
			actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			utility.wait(5)
			EventFxID0 = zzEstrusChaurusVibrate.Play(actorList[0]) 
		else	
			actorList[0].EquipItem(zzEstrusArmorItem, true, true)
			actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			stripFollower(actorList[0])
			if EventFxID1 == 0
				EventFxID1 = zzEstrusChaurusVibrate.Play(actorList[0]) 
			endif
		endif
	elseif animation.name == "Tentacle Side"
		;utility.wait(5)
		if isplayer
			actorList[0].EquipItem(zzEstrusSpiderParasite, true, true)
		else	
			actorList[0].EquipItem(zzEstrusSpiderParasite, true, true)
			stripFollower(actorList[0])
		endif
		actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches
	elseif animation.name == "Slime Creature"
		utility.wait(3)
		if isplayer
			actorList[0].EquipItem(zzEstrusChaurusEtc02, true, true)
		else	
			actorList[0].EquipItem(zzEstrusChaurusEtc02, true, true)
			stripFollower(actorList[0])
		endif
		actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches
	endif
endevent

event ESAnimStage(string hookName, string argString, float argNum, form sender)
	
	int stage = mcm.SexLab.HookStage(argString)
	actor[] actorList = mcm.SexLab.HookActors(argString)
	bool isPlayer = (actorlist[0] == PlayerRef)
	sslBaseAnimation animation = mcm.SexLab.HookAnimation(argString)
	armor ESArmor = none

	if Stage == iNotifyStage && strCallback != ""
		actorlist[0].SendModEvent(strCallback)
		iNotifyStage = 0
		strCallback = ""
	endif

	if animation.hastag("Tentacle") ||  animation.hastag("Slime")  ||  animation.hastag("Ooze") 
		if stage >= 2 && stage < 9 
			mcm.SexLab.ApplyCum(actorlist[0], 5)
		endif
		
		if stage < 9
			if isplayer && !EventFxID0 
				EventFxID0 = zzEstrusTentacleFX.Play(actorList[0])
			elseif !isplayer && !EventFxID1
				EventFxID1 = zzEstrusTentacleFX.Play(actorList[0])
			endif
		endif

		;if stage == 9 &&  animation.name == "Tentacle Side"
			;actorlist[0].RemoveItem(zzEstrusSpiderParasite, 1, true)
			;actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			;if !isPlayer
				;stripFollower(actorlist[0])
			;endif
		;endif

		if stage == 7 && !(mcm.zzEstrusDisablePregnancy2.GetValueInt() as Bool) && UseESFX
			Oviposition(actorlist[0], true)
		endIf
	elseif animation.hastag("Machine")
		if stage == 3 && UseESFX
			if isPlayer
				debug.notification("You are losing control...")
			endif
		elseif stage == 5
			if isPlayer && UseESFX
				debug.notification("You begin to orgasm uncontrollably...")
			endif
			mcm.SexLab.ApplyCum(actorlist[0], 5)
		elseif stage == 8
			if  UseESFX
				DwemerExhaustion.RemoteCast(actorlist[0],actorlist[0],actorlist[0])
			endIf
			if isPlayer && UseESFX
				debug.notification("The machine absorbs your sexual energy...")
			endif
		;elseif stage == 9
			;actorlist[0].RemoveItem(zzEstrusSpiderDwemerBinders, 1, true)
			;actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			;if !isPlayer
				;stripFollower(actorlist[0])
			;endif
		elseif stage == 10
			if isPlayer && UseESFX
				debug.notification("You have been forced to orgasm until exhausted...")
			endif
		elseif stage == 11
			if isPlayer && UseESFX
				debug.notification("You are almost too weak to stand...")
			endif
		endif
	endif
	
	if stage > 8 ;Safety Check for active sounds and Estrus Armor at each stage >8 to allow for stage interrupts/lag
		
		if actorlist[0].WornHasKeyword(zzEstrusSpiderArmor)
			if  animation.name == "Tentacle Side"
				ESArmor = zzEstrusSpiderParasite
			elseif animation.name == "Slime Creature"
					ESArmor = zzEstrusChaurusEtc02
					utility.wait(0.2) ;Sync with Anim
			else
				if animation.name == "Dwemer Machine"
					ESArmor = zzEstrusSpiderDwemerBinders
				else
					ESArmor = zzEstrusSpiderDwemerBelt
				endif
			endif
			actorList[0].RemoveItem(ESArmor, 1, true)
			if !isplayer
				stripFollower(actorList[0])
			endif
		endif

		if !isPlayer && EventFxID1 > 0
			Sound.StopInstance(EventFxID1)
			EventFxID1 = 0
		elseif EventFxID0 >0
			Sound.StopInstance(EventFxID0)
			EventFxID0 = 0
		endif
	endif
endevent

event ESAnimEnd(string hookName, string argString, float argNum, form sender)
	
	actor[] actorList = mcm.SexLab.HookActors(argString)
	sslBaseAnimation animation = mcm.SexLab.HookAnimation(argString)
	unregisterforupdate()
	string strVictimRefid = actorList[0].getformid() as string
	unregisterformodevent("StageEnd_" + strVictimRefid)
	armor ESArmor = none
	
	int stage = mcm.SexLab.HookStage(argString)
	
	bool isPlayer = (actorlist[0] == PlayerRef)
	
	if animation.hastag("Tentacle") 
		actorList[0].DispelSpell(zzSpiderParasite)
	endif

	if actorlist[0].WornHasKeyword(zzEstrusSpiderArmor)
		if  animation.name == "Tentacle Side"
			ESArmor = zzEstrusSpiderParasite
		else
			ESArmor = zzEstrusSpiderDwemerBinders
		endif
		actorList[0].RemoveItem(ESArmor, 1, true)
	endif

	if !isPlayer && EventFxID1 > 0 ;Sound failsafe for stage skipping sound bug
		Sound.StopInstance(EventFxID1)
		EventFxID1 = 0
	elseif EventFxID0 >0
		Sound.StopInstance(EventFxID0)
		EventFxID0 = 0
	endif
	
	unregisterformodevent("AnimationStart_" + strVictimRefid)
	unregisterformodevent("AnimationEnd_" + strVictimRefid)

	if isplayer
		SendModEvent("dhlp-Resume") ;Resume Deviously Helpless Events
	else
		;Debug.SendAnimationEvent(actorlist[0], "IdleForceDefaultState");Prevent "AI Frozen" Followers
		actorlist[0].evaluatepackage()
	endif

endevent

Function Oviposition(actor akVictim, bool UseParasiteSpell = true)
	if akVictim == PlayerRef
		if akVictim.IsInFaction(mcm.zzEstrusSpiderBreederFaction)
			return
		endIf
		if ( !akVictim.HasSpell(mcm.zzEstrusSpiderBreederAbility ) );
			akVictim.AddSpell(mcm.zzEstrusSpiderBreederAbility , false)
			mcm.SexLab.AdjustPlayerPurity(-5.0)
		endIf
	else
		If MCM.kIncubationDue.Find(akVictim, 1) < 0
			Int BreederIdx = MCM.kIncubationDue.Find(none, 1)
			if BreederIdx > 0
				(zzEstrusSpider.GetNthAlias(BreederIdx) as ReferenceAlias).ForceRefTo(akVictim)
				(zzEstrusSpider.GetNthAlias(BreederIdx) as zzestrusspidersaliasscript).OnBreederStart(akVictim, BreederIdx)
			endif
		else
			return
		endif
	endif	
	if UseParasiteSpell
		zzSpiderParasite.RemoteCast(akVictim, akVictim, akVictim)
	endif
	
endFunction

Event OnUpdate()

    Cell c = PlayerRef.GetParentCell()
	Actor akactor
	int followerIndex = 0
	Int NumRefs = c.GetNumRefs(43)
	bool FoundVictim = False

	While (NumRefs > 0)
		NumRefs -= 1
		akactor = c.GetNthRef(NumRefs, 43) as Actor
		if akactor.IsInFaction(ESVictimfaction)
			FoundVictim = true
		Endif
		actor aktarget = akactor.GetCombatTarget()
		If aktarget != none  && !akactor.IsInFaction(CurrentFollowerFaction) && akactor.HasLOS(aktarget)
			if aktarget.IsInFaction(ESVictimfaction) 
				if ( !akactor.IsInFaction(ESTentaclefaction) )
					int SpectatorRefs = zzestruschaurusSpectators.GetNumAliases()
						while SpectatorRefs > 1
							SpectatorRefs -= 1
							If (zzestruschaurusSpectators.GetNthAlias(SpectatorRefs)  as ReferenceAlias).ForceRefIfEmpty(akactor)
								akactor.stopcombat()
								SpectatorRefs = 0
							endif
						endwhile

				;elseif aktarget.IsInFaction(ECTentaclefaction) 
				;	aktarget.removefromFaction(ECTentaclefaction); Clear Alias
				;	aktarget.StartCombat(akactor)
				endif
			endif
		Endif
	EndWhile 
	if FoundVictim
		RegisterforSingleUpdate(1)
	else
		;int SpectatorRefs = zzestruschaurusSpectators.GetNumAliases() **********************************************!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!************************************************
		;while SpectatorRefs > 1
			;SpectatorRefs -= 1
			;(zzestruschaurusSpectators.GetNthAlias(SpectatorRefs)  as ReferenceAlias).Clear()
		;EndWhile
		zzestruschaurusSpectators.stop()
		zzestruschaurusVictims.stop()
	endif

EndEvent

function stripFollower(actor akVictim)

	Form ItemRef = None
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(32))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(31))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(30))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(33))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(34))
	StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(37)) #You can keep your boots on!#
	;StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(38))
	StripItem(akVictim, ItemRef)	
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(39))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetEquippedWeapon(false)
	if ItemRef
		akVictim.UnequipItemEX(ItemRef, 1, false)
	endIf
	ItemRef = akVictim.GetEquippedWeapon(true)
	if ItemRef
		akVictim.UnequipItemEX(ItemRef, 2, false)
	endif
endfunction

function StripItem(actor akVictim, form ItemRef)
	If ItemRef
		Armor akArmor = ItemRef as Armor
		if !akArmor.haskeyword(zzEstrusSpiderArmor)
			akVictim.UnequipItem(ItemRef, false, true)
		endif
	endif
endfunction

