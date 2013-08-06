package  
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class TextBox extends TextBoxVisual 
	{
		
		public function TextBox() 
		{
			
		}
		
		public function get text () : String
		{
			return box.text;
		}
		
		public function set text (t : String) : void
		{
			box.text = t;
		}
		
	}

}