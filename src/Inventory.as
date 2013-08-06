package  
{
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Inventory extends InventoryVisual
	{
		public var menu : Array = [];
		public static const X_0: Number = 107;
		public static const ITEMS_DISPLAYED: Number = 5;
		public static const ITEM_WIDTH: Number = 162;
		static private const Y_0:Number = 85;
		
		private var _currentItem : int = 0;
		
		public function Inventory() 
		{
			
		}
		
		public function nextRight () : void
		{
			_currentItem++;
			if (_currentItem > menu.length - 1)
			{
				_currentItem = menu.length - 1;
				return;
			}
			
			moveItems(true);
		}
		
		public function nextLeft () : void
		{
			_currentItem--;
			if (_currentItem < 0)
			{
				_currentItem = 0;
				return;
			}
			
			moveItems(false);
		}
		
		private function moveItems (movingRight : Boolean) : void
		{
			for (var j : int = 0; j < menu.length; j++)
			{
				menu[j].out();
			}
			menu[_currentItem].over();
			
			if (movingRight && (_currentItem % ITEMS_DISPLAYED == 0))
			{
				for (var i : int = 0; i < menu.length; i++)
				{
					TweenLite.to(menu[i], 0.5, { ease: Elastic.easeInOut, x : (X_0 + (i - _currentItem) * ITEM_WIDTH) } );
				}
			}
			else if (!movingRight && ((_currentItem + 1) % ITEMS_DISPLAYED == 0))
			{
				for (var h : int = 0; h < menu.length; h++)
				{
					TweenLite.to(menu[h], 0.5, { ease: Elastic.easeInOut, x : (X_0 + (h - (_currentItem + 1) + ITEMS_DISPLAYED) * ITEM_WIDTH) } );
				}
			}
			testArrows();
		}
		
		public function addItem (i : InventoryItem) : void
		{
			i.y = Y_0;
			i.x = X_0 + menu.length * ITEM_WIDTH;
			menu.push(i);
			
			if (menu.length == 1)
			{
				menu[0].over();
			}
			
			addChildAt(i, getChildIndex(inventoryContainer));
			testArrows();
		}
		
		public function removeItem () : InventoryItem
		{
			var ar : Array = menu.splice(_currentItem, 1);
			for (var i : int = 0; i < menu.length; i++)
			{
				menu[i].x = X_0 + i * ITEM_WIDTH;
			}
			if (menu[_currentItem = 0])
			{
				menu[_currentItem = 0].over();
			}
			if (ar.length)
			{
				removeChild(ar[0]);
				return ar[0];
			}
			else
			{
				return null;
			}
			testArrows();
		}
		
		public function reset () : void
		{
			_currentItem = 0;
		}
		
		private function testArrows () : void
		{
			if (Math.floor(_currentItem / ITEMS_DISPLAYED) > 0)
				left.visible = true;
			else
				left.visible = false;
			
			if (Math.floor(_currentItem / ITEMS_DISPLAYED) < Math.floor(menu.length / ITEMS_DISPLAYED))
				right.visible = true;
			else
				right.visible = false;
		}
	}

}