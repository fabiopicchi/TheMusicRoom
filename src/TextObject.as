package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class TextObject extends GameObject 
	{
		
		private var _typing : Boolean = false;
		private var _textCounter : Number = 0;
		private var _textArray : Array;
		
		public function TextObject() 
		{
			_textArray = new Array();
			_textArray.push(new String("Qwerty uiop asd fghjkl\nçzxcvbnm qwe"));
			_textArray.push(new String("Uiop asdfg hjkl"));
		}
		
		override public function interact(fromPlayer : Boolean = true):void
		{
			super.interact();
			
			if (!_typing)
			{
				var text : String = _textArray[_textCounter];
				if (text)
				{
					Game.displayText(text);
					_typing = true;
					_textCounter++;
				}
				else
				{
					Game.closeText();
					_typing = false;
					_textCounter = 0;
				}
			}
			else if (Game.completedText())
			{
				_typing = false;
				interact();
			}
		}
	}

}