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
		
		private var _id : String;
		
		public function InventoryItem(id : String = "") 
		{
			_id = id;
			
			var s : Shape = new Shape;
			s.graphics.beginFill(0xAA900F);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
		}
		
		public function over () : void
		{
			removeChildAt(0);
			
			var s : Shape = new Shape;
			s.graphics.beginFill(0xF009AA);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
		}
		
		public function out () : void
		{
			removeChildAt(0);
			
			var s : Shape = new Shape;
			s.graphics.beginFill(0xAA900F);
			s.graphics.drawRect(0, 0, 50, 50);
			s.graphics.endFill();
			
			addChild(s);
		}
		
		public function get id():String 
		{
			return _id;
		}
	}
}