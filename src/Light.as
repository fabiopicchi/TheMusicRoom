package  
{
	import flash.globalization.Collator;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Light extends Entity 
	{
		
		private var _nightInitialState : Boolean = true;
		
		public function Light() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_nightInitialState = (Number(data.nightInitialState) ? true : false);
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
		
		override public function get visible():Boolean 
		{
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
		}
		
		public function toggle () : void
		{
			if ((parent as Room).time == "night")
			{
				visible = !visible;
			}
		}
	}

}