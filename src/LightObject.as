package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class LightObject extends GameObject 
	{
		private var shadows : Array = [];
		
		public function LightObject() 
		{
			
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			shadows = id.split("x");
		}
		
		override public function interact(fromPlayer:Boolean = true):void 
		{
			super.interact(fromPlayer);
			
			var s : Shadow;
			for (var i : int = 0; i < shadows.length; i++)
			{	
				if ((s = (parent as Room).getChildByName("shadow_" + shadows[i]) as Shadow))
				{
					s.visible = !s.visible;
				}
			}
		}
	}

}