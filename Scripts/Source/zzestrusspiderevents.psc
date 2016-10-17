Scriptname zzestrusSpiderevents extends Quest

zzEstrusSpiderMCMScript  property mcm Auto

SexLabFramework  property SexLab Auto

Actor[] sexActors

sslBaseAnimation[] animations

faction property ESTentaclefaction Auto
faction property ESVictimfaction Auto
faction property zzEstrusSpiderExclusionFaction  auto
faction property zzEstrusSpiderBreederFaction auto

armor   property zzEstrusSpiderDwemerBinders  auto
armor   property zzEstrusSpiderDwemerBelt  auto
armor  property zzEstrusSpiderParasite auto 

spell property zzEstrusSpiderBreederAbility auto
spell property zzSpiderParasite  auto 
spell property DwemerExhaustion Auto

explosion property TentacleExplosion Auto

sound Property zzEstrusTentacleFX Auto
sound property zzEstrusChaurusVibrate Auto

Quest property SpectatorControl Auto

Actor[] Spectator
int SpectatorCount = 0

Keyword property zzEstrusSpiderArmor Auto
Keyword ESpkg = None

int EventFxID0 = 0
int EventFxID1 = 0

bool dDLoaded = false

zadlibs dDlibs = None



;************************************
;**Estrus Spider Public Interface **
;************************************
;
;The ES interface uses ModEvents.  This method can be used without loading ES as a master or using GetFormFromFile
; 
;To call an ES event use the following code:
;
; 	int ESTrap = ModEvent.Create("ESStartAnimation"); Int 			Does not have to be named "ESTrap" any name would do
;	if (ESTrap)	
;   	ModEvent.PushForm(ESTrap, self)             ; Form			Some SendModEvent scripting "black magic" - required
;   	ModEvent.PushForm(ESTrap, game.getplayer()) ; Form	 		The animation target
;   	ModEvent.PushInt(ESTrap, EstrusTraptype)    ; Int			The animation required    0 = Tentacles, 1 = Machine
;   	ModEvent.PushBool(ESTrap, true)             ; Bool			Apply the linked ES effect (Ovipostion for Tentacles, Exhaustion for Machine) 
;   	ModEvent.Pushint(ESTrap, 500)               ; Int			Alarm radius in units (0 to disable) 
;   	ModEvent.PushBool(ESTrap, true)             ; Bool			Use ES (basic) crowd control on hostiles 
;   	ModEvent.Send(EStrap)
;	else
;		;ES is not installed
;	endIf
;
;
;************************************
; Please do not link directly to ES functions - they are likely to change and break your mod!

function InitModEvents()

	RegisterForModEvent("ESStartAnimation", "OnESStartAnimation")
	
	if mcm.kwDeviousDevices != None && !dDLoaded
		dDlibs = Game.GetFormFromFile(0x0000F624, "Devious Devices - Integration.esm") as Zadlibs
		if dDlibs != None
			debug.trace("_ES_::Loaded dD Integration")
			dDLoaded = true
		else
			debug.trace("_ES_::Devious Devices - Integration.esm not found - Devices will not be supported")
			dDLoaded = false
		endif
	endif 

endFunction


bool function OnESStartAnimation(Form Sender, form akTarget, int intAnim, bool bUseFX, int intUseAlarm, bool bUseCrowdControl)

	actor akActor  = akTarget as Actor
	Bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akActor.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || akActor.IsInFaction(zzEstrusSpiderExclusionFaction) || akActor.IsBleedingOut() || akActor.isDead()

	if !invalidateVictim && SexLab.ValidateActor(akActor) == 1

		DoESAnimation(akActor, intAnim, bUseFX, intUseAlarm, bUseCrowdControl)
		
		return true

	else
		
		return false
		
	endIf	

endfunction



function DoESAnimation(actor akVictim, int AnimID, bool UseFX, int UseAlarm, bool UseCrowdControl)

		Spectator = New Actor[20]
		SpectatorCount = 0
		bool isPlayer = (akVictim == game.getplayer())
		string EstrusType
		string strVictimRefid = akVictim.getformid() as string

		int EstrusID = AnimID

		If EstrusID == 1
			EstrusType = "Dwemer"
		Else
			EstrusType = "Tentacle"
		Endif

		armor dDArmbinder = none

		if dDLoaded

			dDArmbinder = dDlibs.GetWornDeviceFuzzyMatch(akVictim, dDlibs.zad_DeviousArmbinder) 

			if akVictim.WornHasKeyword(dDlibs.zad_DeviousBelt)
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

		if isplayer
			SendModEvent("dhlp-Suspend") ;ES Scene starting - suspend Deviously Helpless Events
		endif 
		
		akVictim.StopCombatAlarm()
		akVictim.StopCombat()
	
		animations   = SexLab.GetAnimationsByTag(1, "Estrus", EstrusType)
		sexActors    = new actor[1]
		sexActors[0] = akVictim
		RegisterForModEvent("AnimationStart_" + strVictimRefid, "ESAnimStart")
		If UseFX
			RegisterForModEvent("StageEnd_" + strVictimRefid, "ESAnimStage")
		Endif
		RegisterForModEvent("AnimationEnd_" + strVictimRefid,   "ESAnimEnd")
		If dDArmbinder
			if isPlayer
				debug.notification("'Something' behind you deftly strips off your armbinder...")
				utility.wait(1)
			endIf
			dDlibs.ManipulateGenericDevice(akVictim, dDArmbinder, false)
			akVictim.DropObject(dDArmbinder, 1)
		Endif

		if UseFX && EstrusID == 0
			akvictim.placeatme(TentacleExplosion)
			if !isPlayer
				akvictim.pushactoraway(akVictim, 2)
				utility.wait(1)
			endif
		endif

		if isplayer && UseCrowdControl
			RegisterForUpdate(2)
		endif

		akVictim.AddToFaction(ESVictimfaction)
		
		if UseAlarm
			akVictim.CreateDetectionEvent(akVictim, UseAlarm)
		endif

		SexLab.StartSex(sexActors, animations, akVictim, none, false, strVictimRefid)

endFunction

event ESAnimStart(string hookName, string argString, float argNum, form sender)
	
	actor[] actorList = SexLab.HookActors(argString)
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	string strVictimRefid = actorList[0].getformid() as string
	bool isPlayer = (actorlist[0] == game.getplayer())
	armor zzEstrusArmorItem = none

	actorList[0].RestoreActorValue("health", 10000)

	if animation.hastag("Machine") ;********************************************apply generic armor item "binders" ?
		
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
		utility.wait(5)
		if isplayer
			actorList[0].EquipItem(zzEstrusSpiderParasite, true, true)
		else	
			actorList[0].EquipItem(zzEstrusSpiderParasite, true, true)
			stripFollower(actorList[0])
		endif
		actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches
	endif
endevent

event ESAnimStage(string hookName, string argString, float argNum, form sender)
	
	int stage = SexLab.HookStage(argString)
	actor[] actorList = SexLab.HookActors(argString)
	bool isPlayer = (actorlist[0] == game.getplayer())
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	armor ESArmor = none

	if animation.hastag("Tentacle") 
		if stage >= 2 && stage < 9 
			SexLab.ApplyCum(actorlist[0], 5)
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

		if stage == 7
			Oviposition(actorlist[0])
		endIf
	elseif animation.hastag("Machine")
		if stage == 3
			if isPlayer
				debug.notification("You are losing control...")
			endif
		elseif stage == 5
			if isPlayer
				debug.notification("You begin to orgasm uncontrollably...")
			endif
			SexLab.ApplyCum(actorlist[0], 5)
		elseif stage == 8
			DwemerExhaustion.RemoteCast(actorlist[0],actorlist[0],actorlist[0])
			if isPlayer
				debug.notification("The machine absorbs your sexual energy...")
			endif
		;elseif stage == 9
			;actorlist[0].RemoveItem(zzEstrusSpiderDwemerBinders, 1, true)
			;actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			;if !isPlayer
				;stripFollower(actorlist[0])
			;endif
		elseif stage == 10
			if isPlayer
				debug.notification("You have been forced to orgasm until exhausted...")
			endif
		elseif stage == 11
			if isPlayer
				debug.notification("You are almost too weak to stand...")
			endif
		endif
	endif
	
	if stage > 8 ;Safety Check for active sounds and Estrus Armor at each stage >8 to allow for stage interrupts/lag
		
		if actorlist[0].WornHasKeyword(zzEstrusSpiderArmor)
			if  animation.name == "Tentacle Side"
				ESArmor = zzEstrusSpiderParasite
			else
				if animation.name == "Dwemer Machine"
					ESArmor = zzEstrusSpiderDwemerBinders
				else
					ESArmor = zzEstrusSpiderDwemerBelt
				endif
			endif
			actorList[0].RemoveItem(ESArmor, 1, true) ;*********************************************or - clear slot?
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
	
	actor[] actorList = SexLab.HookActors(argString)
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	unregisterforupdate()
	string strVictimRefid = actorList[0].getformid() as string
	unregisterformodevent("StageEnd_" + strVictimRefid)
	armor ESArmor = none
	
	int stage = SexLab.HookStage(argString)
	
	bool isPlayer = (actorlist[0] == game.getplayer())
	
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

	SpectatorControl.stop()

	actorList[0].removefromFaction(ESVictimfaction)

	while SpectatorCount > 0
		SpectatorCount -= 1
		Spectator[SpectatorCount].removefromFaction(ESTentaclefaction)
	endwhile

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
		Debug.SendAnimationEvent(actorlist[0], "IdleForceDefaultState");Prevent "AI Frozen" Followers
	endif

endevent

Function Oviposition(actor akVictim)
	if ( !akVictim.IsInFaction(zzEstrusSpiderBreederFaction) )
		akVictim.AddToFaction(zzEstrusSpiderBreederFaction)
	endIf
	if ( !akVictim.HasSpell(zzEstrusSpiderBreederAbility ) );
		akVictim.AddSpell(zzEstrusSpiderBreederAbility , false)
	endIf	
	zzSpiderParasite.RemoteCast(akVictim, akVictim, akVictim)
	
	if akVictim == game.getplayer()
		SexLab.AdjustPlayerPurity(-5.0)
	endIf
endFunction

Event OnUpdate()

    Cell c = game.getplayer().GetParentCell()
	Actor akactor
	int followerIndex = 0
	Int NumRefs = c.GetNumRefs(43)
	While (NumRefs > 0)
		NumRefs -= 1
		akactor = c.GetNthRef(NumRefs, 43) as Actor
		actor aktarget = akactor.GetCombatTarget()
		If aktarget != none 
			if aktarget.IsInFaction(ESVictimfaction) && akactor.GetDistance(aktarget) < 2500
				if ( !akactor.IsInFaction(ESTentaclefaction) )
					akactor.AddToFaction(ESTentaclefaction)
					Spectator[SpectatorCount] = akactor as Actor
					SpectatorCount +=  1
				endif
				aktarget.stopcombatAlarm()
				akactor.stopcombat()
				if SpectatorControl.isStopped()
					SpectatorControl.start()
				endif
			endif
		Endif
	EndWhile 


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
