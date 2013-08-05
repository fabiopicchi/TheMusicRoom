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
		private var _text : String;
		private var _arElementsCreated : Array;
		private var _arElementsDestroyed : Array;
		
		public function InventoryItem(objData : Object) 
		{
			_id = objData.name;
			_text = objData.text;
			_arElementsCreated = (objData.elementsCreated == "" ? [] : objData.elementsCreated);
			_arElementsDestroyed = (objData.elementsDestroyed == "" ? [] : objData.elementsDestroyed);
			
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