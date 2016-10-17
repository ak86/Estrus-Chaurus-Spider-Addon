Scriptname zzEncSpiderHachlingScript extends Actor

event OnLoad()
	self.SetAV("SpeedMult", 150.0 / Self.GetScale() )
endEvent

event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	self.RemoveAllItems()

	if ( self.GetScale() >= 5.0 && !self.HasSpell(crSpider01PoisonSpit) )
		self.AddSpell( crSpider01PoisonSpit )
	endIf
endEvent

SPELL Property crSpider01PoisonSpit  Auto  
