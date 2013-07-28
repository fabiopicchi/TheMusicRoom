package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class TextObject extends GameObject 
	{	
		public function TextObject() 
		{
			
		}
		
		override public function interact(fromPlayer : Boolean = true):void
		{
			super.interact();
			Game.displayText(_id);
		}
	}

}