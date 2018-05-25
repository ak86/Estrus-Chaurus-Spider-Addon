Scriptname zzEstrusSpider_HachlingScript extends Actor

SPELL Property crSpider01PoisonSpit  Auto  

event OnLoad()
	self.SetAV("SpeedMult", 150.0 / Self.GetScale() )
endEvent

event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	self.RemoveAllItems()

	if ( self.GetScale() >= 5.0 && !self.HasSpell(crSpider01PoisonSpit) )
		self.AddSpell( crSpider01PoisonSpit )
	endIf
endEvent
