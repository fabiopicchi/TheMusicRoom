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
			
			var text : String = new String("Qwerty uiop asd fghjkl çzxcvbnm qwerty ui opas dfg hjklçzx cvbnm.");
			
			Game.displayText(text);
		}
	}

}