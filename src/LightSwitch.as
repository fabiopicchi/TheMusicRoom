package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class LightSwitch extends InteractiveElement 
	{
		
		private var _shadows : Array;
		private var _room : Room;
		
		public function LightSwitch() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_shadows = ((data.shadows is Array) ? data.shadows : [data.shadows]);
			_room = data.room;
		}
		
		override public function interact(item : InventoryItem = null) : void
		{
			super.interact();
			var s : Shadow;
			for (var i : int = 0; i < _shadows.length; i++)
			{	
				s = parent.getChildByName(_shadows[i]) as Shadow;
				s.visible = !s.visible;
			}
		}
	}

}