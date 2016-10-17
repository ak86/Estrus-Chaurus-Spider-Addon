Scriptname zzEstrusSpiderPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusSpiderMCMScript ).registerMenus()
	( me as zzEstrusSpiderevents ).InitModEvents()
endEvent

event OnCellLoad()
	Quest me = self.GetOwningQuest()

	if ( me as zzEstrusSpiderMCMScript ).bRegisterCompanions
		( me as zzEstrusSpiderAE ).AddCompanions()
	endIf
endEvent
