package  
{
	import flash.globalization.Collator;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Shadow extends Entity 
	{
		
		private var _nightInitialState : Boolean;
		private var _room : Room;
		
		public function Shadow() 
		{
			
		}
		
		public function resetNightState() : void
		{
			if (_nightInitialState)
			{
				visible = true;
			}
			else
			{
				visible = false;
			}
		}
	}

}