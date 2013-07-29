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
		
		public function Shadow() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_nightInitialState = data.nightInitialState;
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