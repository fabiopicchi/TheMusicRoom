package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class TextObject extends GameObject 
	{
		
		private var _reading : Boolean = false;
		
		public function TextObject() 
		{
			
		}
		
		override public function interact(fromPlayer : Boolean = true):void
		{
			super.interact();
			
			if (!_reading)
			{
				var text : String = new String("Qwerty uiop asd fghjkl çzxcvbnm qwerty ui opas dfg hjklçzx cvbnm.");
				Game.displayText(text);
			}
			else
			{
				Game.scrollText();
			}
		}
	}

}