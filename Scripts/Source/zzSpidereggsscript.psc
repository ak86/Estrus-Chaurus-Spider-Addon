Scriptname zzSpiderEggsScript extends ObjectReference  

GlobalVariable            Property zzEstrusFertilityChance2  Auto  
GlobalVariable            Property zzEstrusSpiderInfestation  Auto  
ActorBase                 Property zzEncSpiderHachling  Auto  
ImpactDataSet             Property MAGSpiderSpitImpactSet  Auto  
zzEstrusSpiderMCMScript   Property MCM Auto

Bool bIsTested             = False
Actor SpiderHachling      = None
Float fUpdate              = 0.0
Int iIncubationIdx         = 0
ObjectReference kContainer = none

function hatch()
	PlayImpactEffect(MAGSpiderSpitImpactSet, "Egg:0")
	if !kContainer
		SpiderHachling = PlaceActorAtMe( zzEncSpiderHachling ).EvaluatePackage()
	else
		SpiderHachling = kContainer.PlaceActorAtMe( zzEncSpiderHachling ).EvaluatePackage()
	endIf

	MCM.fHatchingDue[iIncubationIdx] = 0.0
	MCM.kHatchingEgg[iIncubationIdx] = none
	Delete()
endFunction

Event OnLoad()
	if ( !bIsTested && zzEstrusSpiderInfestation.GetValueInt() as bool && Utility.RandomInt( 0, 100 ) < zzEstrusFertilityChance2.GetValueInt() )
		bIsTested = True
		fUpdate = Utility.RandomFloat( 48.0, 96.0 )

		iIncubationIdx = 1
		while ( iIncubationIdx < MCM.kHatchingEgg.Length && MCM.kHatchingEgg[iIncubationIdx] != None )
			iIncubationIdx += 1
		endWhile
		
		MCM.fHatchingDue[iIncubationIdx] = (fUpdate/24.0) + Utility.GetCurrentGameTime()
		MCM.kHatchingEgg[iIncubationIdx] = self
		RegisterForSingleUpdateGameTime( fUpdate )
	endIf
EndEvent

Event OnUpdateGameTime()
	hatch()
EndEvent

event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	kContainer = akNewContainer
endEvent

