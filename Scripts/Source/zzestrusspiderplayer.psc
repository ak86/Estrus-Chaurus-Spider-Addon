Scriptname zzEstrusSpiderPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusSpiderMCMScript ).registerMenus()	;start/restart mcm on saveload
	( me as zzEstrusSpiderevents ).InitModEvents()		;register tentacle anims/event
	( me as zzEstrusSpiderAE ).RegisterForSLSpider()	;register sexlab anims/event

endEvent
