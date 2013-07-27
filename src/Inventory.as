package  
{
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.display.Shape;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Inventory extends MovieClip
	{
		public var menu : Array = [];
		public static const X_0: Number = 100;
		public static const ITEMS_DISPLAYED: Number = 5;
		public static const ITEM_WIDTH: Number = 50;
		public static var spacing : Number;
		
		private var _currentItem : int = 0;
		
		public function Inventory() 
		{
			var s : Shape = new Shape;
			s.graphics.beginFill(0x888888);
			s.graphics.drawRect(0, 0, 1024, 100);
			s.graphics.endFill();
			addChild(s);
			
			spacing = (1024 - 2 * X_0 - ITEM_WIDTH) / ITEMS_DISPLAYED;
			
			for (var i : int = 0; i < 15; i++)
				addItem(new InventoryItem);
		}
		
		public function nextRight () : void
		{
			_currentItem++;
			if (_currentItem > menu.length - 1)
			{
				_currentItem = menu.length - 1;
				return;
			}
			
			moveItems();
		}
		
		public function nextLeft () : void
		{
			_currentItem--;
			if (_currentItem < 0)
			{
				_currentItem = 0;
				return;
			}
			
			moveItems();
		}
		
		private function moveItems () : void
		{
			for (var j : int = 0; j < menu.length; j++)
			{
				menu[j].out();
			}
			menu[_currentItem].over();
			
			if (_currentItem > ITEMS_DISPLAYED && _currentItem < menu.length - ITEMS_DISPLAYED)
			{
				for (var i : int = 0; i < menu.length; i++)
				{
					TweenLite.to(menu[i], 0.5, { ease: Elastic.easeInOut, x : (X_0 + (i - _currentItem) * spacing) } );
				}
			}
		}
		
		public function addItem (i : InventoryItem) : void
		{
			i.y = 25;
			i.x = X_0 + (menu.length - _currentItem) * spacing;
			menu.push(i);
			
			addChild(i);
		}
	}

}