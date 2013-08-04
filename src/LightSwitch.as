package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class LightSwitch extends InteractiveElement 
	{
		
		private var _lights : Array;
		
		public function LightSwitch() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_lights = ((data.lights is Array) ? data.lights : [data.lights]);
		}
		
		override public function interact(item : InventoryItem = null) : void
		{
			super.interact();
			
			if (_lights)
			{
				if ((parent as Room).time == "night")
				{
					var l : Light;
					for (var i : int = 0; i < _lights.length; i++)
					{	
						l = parent.getChildByName(_lights[i]) as Light;
						l.toggle();
						if (l.visible)
						{
							Game.playSfx(Game.SWITCH_ON);
						}
						else
						{
							Game.playSfx(Game.SWITCH_OFF);
						}
					}
				}
			}
			else
			{
				trace (this.name + " has no lights associated with it.");
			}
		}
	}

}