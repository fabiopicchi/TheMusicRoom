package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class LightObject extends GameObject 
	{
		
		public function LightObject() 
		{
			
		}
		
		override public function interact(fromPlayer:Boolean = true):void 
		{
			super.interact(fromPlayer);
			
			var s : Shadow;
			if ((s = (parent as Room).getChildByName("shadow_" + _id) as Shadow))
			{
				s.visible = !s.visible;
			}
		}
	}

}