Scriptname zzEstrusSpiderPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusSpiderMCMScript ).registerMenus()
	( me as zzEstrusSpiderevents ).InitModEvents()
endEvent
