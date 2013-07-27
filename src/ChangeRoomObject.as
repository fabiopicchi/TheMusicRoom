package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class ChangeRoomObject extends GameObject 
	{
		
		
		public function ChangeRoomObject() 
		{
			
		}
		
		override public function interact(fromPlayer:Boolean = true):void 
		{
			super.interact(fromPlayer);
			Game.setNextRoom(_id);
		}
	}

}