package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class PuzzleElement extends InteractiveElement 
	{
		private var _inventoryItemReward : String;
		private var _itemsNeeded : Array;
		
		public function PuzzleElement() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_inventoryItemReward = data.inventoryItemReward;
			_itemsNeeded = ((data.itemsNeeded is Array) ? data.itemsNeeded : [data.itemsNeeded]);
		}
		
		override public function interact(item:InventoryItem = null):void 
		{
			super.interact(item);	
		}
		
		public function addItemToPuzzle (item : String) : Boolean
		{
			var itemFound : Boolean = false;
			for (var i : int = 0; i < _itemsNeeded.length; i++)
			{
				if (item == _itemsNeeded[i])
				{
					_itemsNeeded.splice(i, 1);
					itemFound = true;
					//Mudar frame do elemento do puzzle
					break;
				}
			}
			
			if (_itemsNeeded.length == 0)
			{
				Game.resetFlag(Game.PUZZLESCREEN_OPEN);
			}
			
			return itemFound;
		}
	}

}