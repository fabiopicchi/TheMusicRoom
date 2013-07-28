package  
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class InventoryItem extends MovieClip 
	{
		
		private var _textBox : TextField;
		
		public function InventoryItem(n : Number = 0) 
		{
			var s : Shape = new Shape;
			s.graphics.beginFill(0xAA900F);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
			
			_textBox = new TextField();
			_textBox.text = String(n);
			
			addChild(_textBox);
			setChildIndex(_textBox, numChildren - 1);
		}
		
		public function over () : void
		{
			removeChildAt(0);
			
			var s : Shape = new Shape;
			s.graphics.beginFill(0xF009AA);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
			setChildIndex(_textBox, numChildren - 1);
		}
		
		public function out () : void
		{
			removeChildAt(0);
			
			var s : Shape = new Shape;
			s.graphics.beginFill(0xAA900F);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
			setChildIndex(_textBox, numChildren - 1);
		}
	}
}