package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class LightSwitch extends Entity 
	{
		
		private var _shadows : Array = new Array();
		private var _room : Room;
		
		public function LightSwitch() 
		{
			
		}
		
		public function interact()
		{
			var s : Shadow;
			for (var i : int = 0; i < shadows.length; i++)
			{	
				if ((s = _room.getChildByName("s_" + i) as Shadow))
				{
					s.visible = !s.visible;
				}
			}
		}
	}

}