Scriptname zzEstrusSpiderBreederEffectScript extends activemagiceffect

int function minInt(int iA, int iB)
	if iA < iB
		return iA
	else
		return iB
	endIf
endFunction

Float function eggChain()
	ObjectReference[] thisEgg = new ObjectReference[13]
	bool bHasScrotNode        = NetImmerse.HasNode(kTarget, NINODE_GENSCROT, false)

	Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
	Int idx = 0
	Int len = Utility.RandomInt( 5, 9 )
	while idx < len
		thisEgg[idx] = kTarget.PlaceAtme(zzSpiderEggs, abForcePersist = true)
		thisEgg[idx].SetActorOwner( kTarget.GetActorBase() )

			If bHasScrotNode
				thisEgg[idx].MoveToNode(kTarget, NINODE_GENSCROT)
				;thisEgg[idx].SplineTranslateToRefNode(kTarget, NINODE_GENSCROT, 100.0, 0.1)
			else
				thisEgg[idx].MoveToNode(kTarget, NINODE_SKIRT02)
				;thisEgg[idx].SplineTranslateToRefNode(kTarget, NINODE_SKIRT02, 100.0, 0.1)
			endif

		idx += 1
		Utility.Wait( Utility.RandomFloat( 3.5, 6.5 ) )
	endWhile

	return len / 4;(7)
endFunction

function oviposition()
	bool finished = false
	float fReduction
	float fBreastReduction
	float fButtReduction

	; make sure we have 3d loaded to access
	while ( !kTarget.Is3DLoaded() )
		Utility.Wait( 1.0 )
	endWhile
	if ( zzEstrusSpiderUninstall.GetValueInt() == 1 )
		GoToState("AFTERMATH")
		return
	endIf
	
	fReduction       = eggChain()
	fBreastReduction = fReduction / 2.0
	fButtReduction   = fReduction / 2.0
		
	; BELLY SWELL =====================================================
	if ( bBellyEnabled )
		fPregBelly = fPregBelly - fReduction

		if ( fPregBelly <= fOrigBelly )
			fPregBelly = fOrigBelly
			finished = true
		else
			finished = ( fPregBelly == fOrigBelly )
		endif

		self.SetNodeScale( kTarget, NINODE_BELLY, fPregBelly)
	endif
	
	; BUTT SWELL ======================================================
	if ( bButtEnabled )
		fPregLeftButt  = fPregLeftButt  - fButtReduction
		fPregRightButt = fPregRightButt - fButtReduction

		if ( fPregLeftButt <= fOrigLeftButt || fPregRightButt <= fOrigRightButt )
			fPregLeftButt  = fOrigLeftButt
			fPregRightButt = fOrigRightButt

			if ( !bBellyEnabled && !bBreastEnabled )
				finished = true
			endIF
		endif
		
		self.SetNodeScale( kTarget, NINODE_LEFT_BUTT, fPregLeftButt)
		self.SetNodeScale( kTarget, NINODE_RIGHT_BUTT, fPregLeftButt)
	endif

	
	; BREAST SWELL ====================================================
	if ( bBreastEnabled )
		fPregLeftBreast    = fPregLeftBreast - fBreastReduction
		fPregRightBreast   = fPregRightBreast - fBreastReduction
		if bTorpedoFixEnabled
			fPregLeftBreast01  = fOrigLeftBreast01 * (fOrigLeftBreast / fPregLeftBreast)
			fPregRightBreast01 = fOrigRightBreast01 * (fOrigRightBreast / fPregRightBreast)
		endIf

		if ( fPregLeftBreast <= fOrigLeftBreast || fPregRightBreast <= fOrigRightBreast)
			fPregLeftBreast  = fOrigLeftBreast
			fPregRightBreast = fOrigRightBreast

			if ( !bBellyEnabled && !bButtEnabled )
				finished = true
			endIF
		endif

		if bTorpedoFixEnabled
			if ( fPregLeftBreast01 < fOrigLeftBreast01 || fPregRightBreast01 < fOrigRightBreast01 )
				fPregLeftBreast01  = fOrigLeftBreast01
				fPregRightBreast01 = fOrigRightBreast01
			endif
		endif
		
		self.SetNodeScale( kTarget, NINODE_LEFT_BREAST, fPregLeftBreast)
		self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST, fPregRightBreast)
		if bTorpedoFixEnabled
			self.SetNodeScale( kTarget, NINODE_LEFT_BREAST01, fPregLeftBreast01)
			self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST01, fPregRightBreast01)
		endIf
	endif
	
	if !bBellyEnabled && !bBreastEnabled && !bButtEnabled
		fPregBelly = fPregBelly - fReduction

		if ( fPregBelly < fOrigBelly )
			finished = true
		endif
	endIf

	Utility.Wait( Utility.RandomFloat( fOviparityTime, fOviparityTime * 2.0 ) )

	if ( !finished && iBirthingLoops > 0 )
		iBirthingLoops -= 1
		oviposition()
	else
		if !finished
			debug.trace("_ES_::Oviposition timed out") 
		endif
		Debug.Trace("_ES_::GTS::AFTERMATH")
		GoToState("AFTERMATH")
	endif
endFunction

function manageSexLabAroused(int aiModRank = -1)
	if !MCM.kfSLAExposure
		return
	endIf
	
	int iRank = kTarget.GetFactionRank(MCM.kfSLAExposure)
	
	if aiModRank == 0 || iOrigSLAExposureRank < -2
		iOrigSLAExposureRank = iRank
	endIf
	if aiModRank < 0
		kTarget.SetFactionRank(MCM.kfSLAExposure, iOrigSLAExposureRank)
	endIf
	if aiModRank > 0 && iRank < 100
		kTarget.ModFactionRank(MCM.kfSLAExposure, minInt(aiModRank, 100 - aiModRank) )
	endIf
endFunction

function triggerNodeUpdate(bool abwait = false)
	iBreastSwellGlobal = zzEstrusSwellingBreasts.GetValueInt()
	iBellySwellGlobal  = zzEstrusSwellingBelly.GetValueInt()
	iButtSwellGlobal   = zzEstrusSwellingButt.GetValueInt()

	if !abwait && !kTarget.IsOnMount() && ( ( bBreastEnabled && iBreastSwellGlobal ) || ( bBellyEnabled && iBellySwellGlobal ) || ( bButtEnabled && iButtSwellGlobal ) )
		kTarget.QueueNiNodeUpdate()
	elseIf abwait
		while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
			Utility.Wait( 2.0 )
		endWhile	

		kTarget.QueueNiNodeUpdate()
	endIf
endFunction

event OnUpdateGameTime()
	Utility.Wait( 5.0 )

	Debug.Trace("_ES_::GTS::BIRTHING")
	GoToState("BIRTHING")
endEvent

state IMPREGNATE
	event OnBeginState()
		Debug.Trace("_ES_::state::IMPREGNATE")
	endEvent

	event OnUpdate()
		if ( zzEstrusSpiderUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf

		if ( !kTarget.IsInFaction( SexLabAnimatingFaction ) )
			; all will be false if bDisableNodeChange is true
			if ( bBellyEnabled || bBreastEnabled || bButtEnabled )
				GoToState("INCUBATION_NODE")
			Else
				GoToState("INCUBATION")
			endif
		endif

		RegisterForSingleUpdate( fWaitingTime )
	endEvent
endState

state INCUBATION_NODE
	event OnBeginState()
		Debug.Trace("_ES_::state::INCUBATION_NODE" )
	endEvent
	
	event OnCellLoad()
		Debug.Trace("_ES_::oncellload" )
		triggerNodeUpdate()
	endEvent

	event OnUpdate()
		if ( zzEstrusSpiderUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf
		; catch a state change caused by RegisterForSingleUpdate
		if ( GetState() == "INCUBATION_NODE" )
			while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
				Utility.Wait( 2.0 )
			endWhile
			; make sure we have 3d loaded to access
			while ( !kTarget.Is3DLoaded() )
				Utility.Wait( 1.0 )
			endWhile
			fGameTime       = Utility.GetCurrentGameTime()
			fInfectionSwell = ( fGameTime - fInfectionStart ) / 1.6666 ;1.6666
			fBellySwell     = 0.0
			fBreastSwell    = 0.0
			fButtSwell      = 0.0
			
			; SexLab Aroused ==================================================
			manageSexLabAroused(1)
			
			; BREAST SWELL ====================================================
			iBreastSwellGlobal = zzEstrusSwellingBreasts.GetValueInt()
			if ( bBreastEnabled && iBreastSwellGlobal )
				fBreastSwell       = fInfectionSwell / iBreastSwellGlobal
				fPregLeftBreast    = fOrigLeftBreast + fBreastSwell
				fPregRightBreast   = fOrigRightBreast + fBreastSwell
				if bTorpedoFixEnabled
					fPregLeftBreast01  = fOrigLeftBreast01 * (fOrigLeftBreast / fPregLeftBreast)
					fPregRightBreast01 = fOrigRightBreast01 * (fOrigRightBreast / fPregRightBreast)
				endIf

				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					Debug.Notification(sSwellingMsgs[Utility.RandomInt(0, sSwellingMsgs.Length - 1)])
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregLeftBreast > NINODE_MAX_SCALE )
					fPregLeftBreast = NINODE_MAX_SCALE
				endif
				if ( fPregRightBreast > NINODE_MAX_SCALE )
					fPregRightBreast = NINODE_MAX_SCALE
				endif
				if bTorpedoFixEnabled
					if ( fPregLeftBreast01 < NINODE_MIN_SCALE )
						fPregLeftBreast01 = NINODE_MIN_SCALE
					endif
					if ( fPregRightBreast01 < NINODE_MIN_SCALE )
						fPregRightBreast01 = NINODE_MIN_SCALE
					endif
				endif
				if ( fPregLeftBreast > zzEstrusSpiderMaxBreastScale.GetValue() )
					fPregLeftBreast = zzEstrusSpiderMaxBreastScale.GetValue()
				endif
				if ( fPregRightBreast > zzEstrusSpiderMaxBreastScale.GetValue() )
					fPregRightBreast = zzEstrusSpiderMaxBreastScale.GetValue()
				endif

				kTarget.SetAnimationVariableFloat("ecBreastSwell", fBreastSwell)
				self.SetNodeScale( kTarget, NINODE_LEFT_BREAST, fPregLeftBreast)
				self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST, fPregRightBreast)
				if bTorpedoFixEnabled
					self.SetNodeScale( kTarget, NINODE_LEFT_BREAST01, fPregLeftBreast01)
					self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST01, fPregRightBreast01)
				endIf
			elseIf ( bBreastEnabled && ( fPregLeftBreast != fOrigLeftBreast || fPregRightBreast != fOrigRightBreast ) )
				fPregLeftBreast    = fOrigLeftBreast
				fPregRightBreast   = fOrigRightBreast
				if bTorpedoFixEnabled
					fPregLeftBreast01  = fOrigLeftBreast01
					fPregRightBreast01 = fOrigRightBreast01
				endIf
				
				kTarget.SetAnimationVariableFloat("ecBreastSwell", 0.0)
				self.SetNodeScale( kTarget, NINODE_LEFT_BREAST, fPregLeftBreast)
				self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST, fPregRightBreast)
				if bTorpedoFixEnabled
					self.SetNodeScale( kTarget, NINODE_LEFT_BREAST01, fPregLeftBreast01)
					self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST01, fPregRightBreast01)
				endIf
			endif

			; BELLY SWELL =====================================================
			iBellySwellGlobal = zzEstrusSwellingBelly.GetValueInt()
			if ( bBellyEnabled && iBellySwellGlobal )
				
				if iBellySwellGlobal == 1   ;fBellySwell = fInfectionSwell / iBellySwellGlobal
					fBellySwell = (fInfectionSwell / iBellySwellGlobal) * 2 
				else
					fBellySwell = fInfectionSwell / iBellySwellGlobal
				endif
				fPregBelly  = fOrigBelly + fBellySwell
				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregBelly > NINODE_MAX_SCALE * 2.0 ) 
					fPregBelly = NINODE_MAX_SCALE * 2.0 
				endif
				if ( fPregBelly > zzEstrusSpiderMaxBellyScale.GetValue() )
					fPregBelly = zzEstrusSpiderMaxBellyScale.GetValue()
				endif

				kTarget.SetAnimationVariableFloat("ecBellySwell", fBellySwell)
				self.SetNodeScale( kTarget, NINODE_BELLY, fPregBelly)
			elseIf ( bBellyEnabled && fPregBelly != fOrigBelly )
				fPregBelly = fOrigBelly
				kTarget.SetAnimationVariableFloat("ecBellySwell", 0.0)
				self.SetNodeScale( kTarget, NINODE_BELLY, fPregBelly)
			endif

			; BUTT SWELL ======================================================
			iButtSwellGlobal = zzEstrusSwellingButt.GetValueInt()
			if ( bButtEnabled && iButtSwellGlobal )
				fButtSwell     = fInfectionSwell / iButtSwellGlobal
				fPregLeftButt  = fOrigLeftButt  + fButtSwell
				fPregRightButt = fOrigRightButt + fButtSwell

				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregLeftButt > NINODE_MAX_SCALE )
					fPregLeftButt = NINODE_MAX_SCALE 
				endif
				if ( fPregRightButt > NINODE_MAX_SCALE )
					fPregRightButt = NINODE_MAX_SCALE 
				endif
				if ( fPregLeftButt > zzEstrusSpiderMaxButtScale.GetValue() )
					fPregLeftButt = zzEstrusSpiderMaxButtScale.GetValue()
				endif
				if ( fPregRightButt > zzEstrusSpiderMaxButtScale.GetValue() )
					fPregRightButt = zzEstrusSpiderMaxButtScale.GetValue()
				endif

				self.SetNodeScale( kTarget, NINODE_LEFT_BUTT, fPregLeftButt)
				self.SetNodeScale( kTarget, NINODE_RIGHT_BUTT, fPregRightButt)
			elseIf ( bButtEnabled && ( fPregLeftButt != fOrigLeftButt || fPregRightButt != fOrigRightButt ) )
				fPregLeftButt = fOrigLeftButt
				fPregRightButt = fOrigRightButt

				self.SetNodeScale( kTarget, NINODE_LEFT_BUTT, fPregLeftButt)
				self.SetNodeScale( kTarget, NINODE_RIGHT_BUTT, fPregRightButt)
			endif

			kTarget.SetFactionRank(zzEstrusSpiderBreederFaction, Math.Floor(fBellySwell + fBreastSwell) )
			RegisterForSingleUpdate( fUpdateTime )
		endif
	endEvent
endState

state INCUBATION
	event OnBeginState()
		fOrigBelly = 1.0
		fPregBelly = NINODE_MAX_SCALE * 2.0
		Debug.Trace("_ES_::state::INCUBATION")
	endEvent

	event OnUpdate()
		if ( zzEstrusSpiderUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf

		; catch a state change caused by RegisterForSingleUpdate
		if ( GetState() == "INCUBATION" )
			; SexLab Aroused ==================================================
			manageSexLabAroused(1)

			RegisterForSingleUpdate( fUpdateTime )
		endif
	endEvent
endState

state BIRTHING
	event OnBeginState()
		Debug.Trace("_ES_::state::BIRTHING")
		while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
			Utility.Wait( 2.0 )
		endWhile

		if kTarget.IsWeaponDrawn()
			kTarget.SheatheWeapon()
		endIf		
		;Debug.SendAnimationEvent(kTarget, "BleedOutStart")
		stripActor(kTarget)
		Debug.SendAnimationEvent(kTarget, "IdleBedRollFrontEnterStart")
		Utility.Wait( 10.0 )
		;iAnimationIndex += 1
		;Debug.SendAnimationEvent(kTarget, "Arrok_Missionary_A1_S"+iAnimationIndex)
		Debug.SendAnimationEvent(kTarget, "zzEstrusCommon01Up")

		if ( MCM.zzEstrusSpiderBirth.GetValueInt() == 1 )
			iBirthingLoops = 1
		else
			iBirthingLoops = 3
		endif

		if bIsFemale && MCM.zzEstrusChaurusFluids.GetValue() as bool
			;kTarget.AddItem(zzEstrusChaurusFluid, 1, true)
			kTarget.EquipItem(zzEstrusChaurusFluid, true, true)
			;kTarget.AddItem(zzEstrusChaurusMilkR, 1, true)
			kTarget.EquipItem(zzEstrusChaurusRMilk, true, true)
			;kTarget.AddItem(zzEstrusChaurusMilkL, 1, true)
			kTarget.EquipItem(zzEstrusChaurusLMilk, true, true)
		endIf
		
		if ( MCM.zzEstrusChaurusResidual.GetValueInt() == 1 )
			float fResidualScale = MCM.zzEstrusChaurusResidualScale.GetValue()

			fResiLeftBreast  = fOrigLeftBreast * fResidualScale
			fResiRightBreast = fOrigRightBreast * fResidualScale
			if bTorpedoFixEnabled
				fOrigLeftBreast01  = fOrigLeftBreast01 * (fOrigLeftBreast / fResiLeftBreast)
				fOrigRightBreast01 = fOrigRightBreast01 * (fOrigRightBreast / fResiRightBreast)
			endIf
			fOrigLeftBreast  = fResiLeftBreast
			fOrigRightBreast = fResiRightBreast
		endIf
		
		if kTarget == kPlayer
			Game.ForceThirdPerson()
			Game.SetPlayerAIDriven()
		else
			kTarget.SetRestrained(true)
			kTarget.SetDontMove(true)
		endIf
		oviposition()
	endEvent

	event OnUpdate()
		; catch any pending updates
	endEvent
endState

state AFTERMATH
	event OnBeginState()
		Debug.Trace("_ES_::state::AFTERMATH")

		if bIsFemale
			;kTarget.UnequipItem(zzEstrusChaurusFluid, false, true)
			kTarget.RemoveItem(zzEstrusChaurusFluid, 1, true)
			;kTarget.UnequipItem(zzEstrusChaurusMilkR, false, true)
			kTarget.RemoveItem(zzEstrusChaurusRMilk, 1, true)
			;kTarget.UnequipItem(zzEstrusChaurusMilkL, false, true)
			kTarget.RemoveItem(zzEstrusChaurusLMilk, 1, true)
		endIf

		if kTarget == kPlayer
			Game.SetPlayerAIDriven(false)
		else
			kTarget.SetRestrained(false)
			kTarget.SetDontMove(false)
		endIf

		Debug.SendAnimationEvent(kTarget, "zzEstrusGetUpFaceUp")
		;Debug.SendAnimationEvent(kTarget, "BleedOutStop")
		kTarget.RemoveSpell(zzEstrusSpiderBreederAbility)
	
		SendModEvent("ESBirthCompleted") ;as requested by Skyrimll

	endEvent

	event OnUpdate()
		; catch any pending updates
	endEvent
endState

event OnEffectStart(Actor akTarget, Actor akCaster)
	kTarget            = akTarget
	kCaster            = akCaster
	kPlayer            = Game.GetPlayer()
	bDisableNodeChange = zzEstrusDisableNodeResize2.GetValue() as Bool
	
	sSwellingMsgs      = new String[3]
	sSwellingMsgs[0]   = "$ES_SWELLING_1_3RD"
	sSwellingMsgs[1]   = "$ES_SWELLING_2_3RD"
	sSwellingMsgs[2]   = "$ES_SWELLING_3_3RD"

	GoToState("IMPREGNATE")
	zzEstrusSpiderInfected.Mod( 1.0 )
	kTarget.StopCombatAlarm()

	Float fMinTime     = zzEstrusIncubationPeriod2.GetValue() * fIncubationTimeMin
	Float fMaxTime     = zzEstrusIncubationPeriod2.GetValue() * fIncubationTimeMax
	fIncubationTime    = Utility.RandomFloat( fMinTime, fMaxTime )
	fInfectionStart    = Utility.GetCurrentGameTime()
	fthisIncubation    = fInfectionStart + ( fIncubationTime / 24.0 )
	bEnableSkirt02     = NetImmerse.HasNode(kTarget, NINODE_SKIRT02, false)
	bEnableSkirt03     = NetImmerse.HasNode(kTarget, NINODE_SKIRT03, false)
	bIsFemale          = kTarget.GetLeveledActorBase().GetSex() == 1
	bTorpedoFixEnabled = zzEstrusChaurusTorpedoFix.GetValueInt() as Bool

	;kCaster.PathToReference(kTarget, 1.0)
	
	if ( !kTarget.IsInFaction(zzEstrusSpiderBreederFaction) )
		kTarget.AddToFaction(zzEstrusSpiderBreederFaction)
	endIf

	if kTarget == kPlayer
		iIncubationIdx = 0
		MCM.fIncubationDue[iIncubationIdx] = fthisIncubation
		MCM.kIncubationDue[iIncubationIdx] = kTarget

		if kPlayer.GetAnimationVariableInt("i1stPerson") as bool
			Game.ForceThirdPerson()
		endIf
	else
		iIncubationIdx = MCM.kIncubationDue.Find(none, 1)
		if iIncubationIdx != -1
			MCM.fIncubationDue[iIncubationIdx] = fthisIncubation
			MCM.kIncubationDue[iIncubationIdx] = kTarget
			
			(ES.GetAlias(iIncubationIdx) as ReferenceAlias).ForceRefTo(kTarget)
		else
			kTarget.RemoveSpell(zzEstrusSpiderBreederAbility)
			return
		endif
	endif

	; SexLab Aroused
	manageSexLabAroused(0)

	if ( !bDisableNodeChange )
		; make sure we have loaded 3d to access
		while ( !kTarget.Is3DLoaded() )
			Utility.Wait( 1.0 )
		endWhile

		bEnableLeftBreast  = NetImmerse.HasNode(kTarget, NINODE_LEFT_BREAST, false)
		bEnableRightBreast = NetImmerse.HasNode(kTarget, NINODE_RIGHT_BREAST, false)
		bEnableLeftButt    = NetImmerse.HasNode(kTarget, NINODE_LEFT_BUTT, false)
		bEnableRightButt   = NetImmerse.HasNode(kTarget, NINODE_RIGHT_BUTT, false)
		bEnableBelly       = NetImmerse.HasNode(kTarget, NINODE_BELLY, false)

		bBreastEnabled     = ( bEnableLeftBreast && bEnableRightBreast && zzEstrusSwellingBreasts.GetValueInt() as bool )
		bButtEnabled       = ( bEnableLeftButt && bEnableRightButt && zzEstrusSwellingButt.GetValueInt() as bool )
		bBellyEnabled      = ( bEnableBelly && zzEstrusSwellingBelly.GetValueInt() as bool )

		if ( bBreastEnabled && kTarget.GetLeveledActorBase().GetSex() == 1 )
			fOrigLeftBreast  = NetImmerse.GetNodeScale(kTarget, NINODE_LEFT_BREAST, false)
			fOrigRightBreast = NetImmerse.GetNodeScale(kTarget, NINODE_RIGHT_BREAST, false)
			if bTorpedoFixEnabled
				fOrigLeftBreast01  = NetImmerse.GetNodeScale(kTarget, NINODE_LEFT_BREAST01, false)
				fOrigRightBreast01 = NetImmerse.GetNodeScale(kTarget, NINODE_RIGHT_BREAST01, false)
			endif
		endif
		if ( bButtEnabled )
			fOrigLeftButt    = NetImmerse.GetNodeScale(kTarget, NINODE_LEFT_BUTT, false)
			fOrigRightButt   = NetImmerse.GetNodeScale(kTarget, NINODE_RIGHT_BUTT, false)
		endif
		if ( bBellyEnabled )
			fOrigBelly       = NetImmerse.GetNodeScale(kTarget, NINODE_BELLY, false)
		endif
	endif

	if bEnableSkirt02
		RegisterForSingleUpdate( fUpdateTime )
		RegisterForSingleUpdateGameTime( fIncubationTime )
	Else
		Debug.MessageBox("$ES_INCOMPATIBLE")
		kTarget.RemoveSpell(zzEstrusSpiderBreederAbility)
	endif
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	zzEstrusSpiderInfected.Mod( -1.0 )
	bUninstall = zzEstrusSpiderUninstall.GetValueInt() as Bool

	if iIncubationIdx != -1
		MCM.fIncubationDue[iIncubationIdx] = 0.0
		MCM.kIncubationDue[iIncubationIdx] = None
		if kTarget != kPlayer
			(ES.GetAlias(iIncubationIdx) as ReferenceAlias).Clear()
		endif
	endIf

	if ( kTarget.IsInFaction(zzEstrusSpiderBreederFaction) )
		kTarget.RemoveFromFaction(zzEstrusSpiderBreederFaction)
	endIf

	; if we are uninstalling, report the first 128 infected NPCs
	if ( bUninstall )
		iIncubationIdx = MCM.kIncubationOff.Find(none)
		if ( iIncubationIdx >= 0 )
			MCM.kIncubationOff[iIncubationIdx] = kTarget
		endif
	endIf
	
	; SexLab Aroused
	manageSexLabAroused()

	if ( !bDisableNodeChange )
		; make sure we have loaded 3d to access
		while ( !kTarget.Is3DLoaded() || kTarget.IsOnMount() || Utility.IsInMenuMode() )
			Utility.Wait( 1.0 )
		endWhile

		if ( bBellyEnabled )
			self.SetNodeScale( kTarget, NINODE_BELLY, fOrigBelly)
		endif

		if ( bButtEnabled )
			self.SetNodeScale( kTarget, NINODE_LEFT_BUTT, fOrigLeftButt)
			self.SetNodeScale( kTarget, NINODE_RIGHT_BUTT, fOrigRightButt)
		endif

		if ( bBreastEnabled )
			self.SetNodeScale( kTarget, NINODE_LEFT_BREAST, fOrigLeftBreast)
			self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST, fOrigRightBreast)
			if bTorpedoFixEnabled
				self.SetNodeScale( kTarget, NINODE_LEFT_BREAST01, fOrigLeftBreast01)
				self.SetNodeScale( kTarget, NINODE_RIGHT_BREAST01, fOrigRightBreast01)
			endIf
		endif
		
		triggerNodeUpdate(true)
	endif
endEvent

Function SetNodeScale(Actor akActor, string nodeName, float value)
	string modName = "ECSA"
	bool isFemale = false
	if akActor.GetLeveledActorBase().GetSex() == 1
		isFemale = true
	else
		isFemale = false
	endif
	if NetImmerse.HasNode(akActor, nodeName, false)
		If SKSE.GetPluginVersion("NiOverride") >= 3 && NiOverride.GetScriptVersion() >= 2
			if akActor == Game.GetPlayer()
				If value != 1.0
					NiOverride.AddNodeTransformScale(akActor, false, isFemale, nodeName, modName, value)
					NiOverride.AddNodeTransformScale(akActor, true, isFemale, nodeName, modName, value)
				Else
					NiOverride.RemoveNodeTransformScale(akActor, false, isFemale, nodeName, modName)
					NiOverride.RemoveNodeTransformScale(akActor, true, isFemale, nodeName, modName)
				Endif
				NiOverride.UpdateNodeTransform(akActor, true, isFemale, nodeName)
			else
				If value != 1.0
					NiOverride.AddNodeTransformScale(akActor, false, isFemale, nodeName, modName, value)
				Else
					NiOverride.RemoveNodeTransformScale(akActor, false, isFemale, nodeName, modName)
				Endif
			Endif
			NiOverride.UpdateNodeTransform(akActor, false, isFemale, nodeName)
		Else
			if akActor == Game.GetPlayer()
				NetImmerse.SetNodeScale(akActor, nodeName, value, true)
			Endif
			NetImmerse.SetNodeScale(akActor, nodeName, value, false)
		Endif
	Endif
EndFunction

float Function GetNodeScale(Actor akActor, string nodeName)
	string modName = "ECSA"
	bool isFemale = false
	if akActor.GetLeveledActorBase().GetSex() == 1
		isFemale = true
	else
		isFemale = false
	endif
	return NiOverride.GetNodeTransformScale(akActor, false, isFemale, nodeName, modName)
EndFunction

function stripActor(actor akVictim)

	Form ItemRef = None
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(30))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(31))
	;StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(32))
	StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(33))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(34))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(37)) #You can keep your boots on!#
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(38))
	;StripItem(akVictim, ItemRef)	
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
		akVictim.UnequipItem(ItemRef, false, true)
	endif
endfunction


Actor kTarget            = None
Actor kCaster            = None
Actor kPlayer            = None
Bool  bDisableNodeChange = False
Bool  bEnableLeftBreast  = False
Bool  bEnableRightBreast = False
Bool  bEnableLeftButt    = False
Bool  bEnableRightButt   = False
Bool  bEnableBelly       = False
Bool  bEnableSkirt02     = False
Bool  bEnableSkirt03     = False
Bool  bBreastEnabled     = False
Bool  bButtEnabled       = False
Bool  bBellyEnabled      = False
Bool  bUninstall         = False
Bool  bIsFemale          = False
Bool  bTorpedoFixEnabled = True
Float fOrigLeftBreast    = 1.0
Float fPregLeftBreast    = 1.0
Float fResiLeftBreast    = 1.0
Float fOrigLeftBreast01  = 1.0
Float fPregLeftBreast01  = 1.0
Float fOrigLeftButt      = 1.0
Float fPregLeftButt      = 1.0
Float fOrigRightBreast   = 1.0
Float fPregRightBreast   = 1.0
Float fResiRightBreast   = 1.0
Float fOrigRightBreast01 = 1.0
Float fPregRightBreast01 = 1.0
Float fOrigRightButt     = 1.0
Float fPregRightButt     = 1.0
Float fOrigBelly         = 1.0
Float fPregBelly         = 1.0
Float fInfectionStart    = 0.0
Float fInfectionSwell    = 0.0
Float fInfectionLastMsg  = 0.0
Float fBreastSwell       = 0.0
Int   iBreastSwellGlobal = 0
Float fButtSwell         = 0.0
Int   iButtSwellGlobal   = 0
Float fBellySwell        = 0.0
Int   iBellySwellGlobal  = 0
Float fUpdateTime        = 5.0
Float fWaitingTime       = 10.0
Float fOviparityTime     = 7.5
; * zzEstrusIncubationPeriod2 ( days )
Float fIncubationTimeMin = 22.6
Float fIncubationTimeMax = 26.6
Float fthisIncubation    = 0.0
Float fGameTime          = 0.0
Int iIncubationIdx       = -1
Int iBirthingLoops       = 3
; SexLab Aroused
Int iOrigSLAExposureRank = -3
Int iAnimationIndex      = 1

String[] sSwellingMsgs

Quest				     Property ES                             Auto
zzEstrusSpiderMCMscript Property MCM                            Auto 

Armor                    Property zzEstrusChaurusFluid           Auto
Armor                    Property zzEstrusChaurusRMilk           Auto
Armor                    Property zzEstrusChaurusLMilk           Auto
Faction                  Property CurrentFollowerFaction         Auto
Faction                  Property zzEstrusSpiderBreederFaction  Auto
Faction                  Property SexLabAnimatingFaction         Auto
GlobalVariable           Property zzEstrusDisableNodeResize2      Auto
GlobalVariable           Property zzEstrusIncubationPeriod2       Auto
GlobalVariable           Property zzEstrusSwellingBreasts        Auto
GlobalVariable           Property zzEstrusSwellingBelly          Auto
GlobalVariable           Property zzEstrusSwellingButt           Auto
GlobalVariable           Property zzEstrusSpiderUninstall       Auto
GlobalVariable           Property zzEstrusSpiderInfected        Auto
GlobalVariable           Property zzEstrusSpiderMaxBreastScale  Auto  
GlobalVariable           Property zzEstrusSpiderMaxBellyScale   Auto
GlobalVariable           Property zzEstrusSpiderMaxButtScale    Auto
GlobalVariable           Property zzEstrusChaurusTorpedoFix      Auto  
Ingredient               Property zzSpiderEggs                  Auto
Spell                    Property zzEstrusSpiderBreederAbility  Auto
Sound                    Property zzEstrusBreastPainMarker       Auto
Static                   Property xMarker                        Auto
Float                    Property fIncubationTime                Auto

String                   Property NINODE_LEFT_BREAST    = "NPC L Breast" AutoReadOnly
String                   Property NINODE_LEFT_BREAST01  = "NPC L Breast01" AutoReadOnly
String                   Property NINODE_LEFT_BUTT      = "NPC L Butt" AutoReadOnly
String                   Property NINODE_RIGHT_BREAST   = "NPC R Breast" AutoReadOnly
String                   Property NINODE_RIGHT_BREAST01 = "NPC R Breast01" AutoReadOnly
String                   Property NINODE_RIGHT_BUTT     = "NPC R Butt" AutoReadOnly
String                   Property NINODE_SKIRT02        = "SkirtBBone02" AutoReadOnly
String                   Property NINODE_SKIRT03        = "SkirtBBone03" AutoReadOnly
String                   Property NINODE_BELLY          = "NPC Belly" AutoReadOnly
String                   Property NINODE_PELVIS         = "NPC Pelvis [Pelv]" AutoReadOnly
String                   Property NINODE_GENSCROT       = "NPC GenitalsScrotum [GenScrot]" AutoReadOnly
String                   Property NINODE_EGG            = "Egg:0" AutoReadOnly
Float                    Property NINODE_MAX_SCALE      = 3.0 AutoReadOnly
Float                    Property NINODE_MIN_SCALE      = 0.1 AutoReadOnly
