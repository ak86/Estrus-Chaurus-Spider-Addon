Scriptname zzEstrusSpider_Player extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusSpider_MCMScript ).registerMenus()	;start/restart mcm on saveload
	( me as zzEstrusSpider_Events ).InitModEvents()		;register tentacle anims/event
	( me as zzEstrusSpider_AE ).RegisterForSLSpider()	;register sexlab anims/event

endEvent
