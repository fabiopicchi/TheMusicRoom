package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class TriggerObject extends GameObject 
	{
		
		public function TriggerObject() 
		{
			
		}
		
		override public function interact(fromPlayer:Boolean = true):void 
		{
			super.interact(fromPlayer);
			
			switch (_id)
			{
				default:
					break;
			}
		}
	}

}