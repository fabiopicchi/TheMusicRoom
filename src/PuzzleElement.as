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
		private var _itemsGot : Array;
		
		public function PuzzleElement() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_inventoryItemReward = data.inventoryItemReward;
			
			_itemsGot = [];
			
			_itemsNeeded = ((data.itemsNeeded is Array) ? data.itemsNeeded : [data.itemsNeeded]);
			for (var i : int = 0; i < _itemsNeeded.length; i++)
				_itemsGot.push(0);
		}
		
		override public function interact(item:InventoryItem = null):void 
		{
			super.interact(item);	
			Game.puzzleScreen(this);
		}
		
		public function addItemToPuzzle (item : String) : Boolean
		{
			var itemFound : Boolean = false;
			for (var i : int = 0; i < _itemsNeeded.length; i++)
			{
				if (item == _itemsNeeded[i])
				{
					_itemsGot[i] = 1;
					itemFound = true;
					//Mudar frame do elemento do puzzle
					break;
				}
			}
			
			for (i = 0; i < _itemsGot.length; i++)
			{
				if (_itemsGot[i] == 0)
					return itemFound;
			}
			
			if (_itemsNeeded.length == 0)
			{
				Game.resetFlag(Game.PUZZLESCREEN_OPEN);
			}
			return itemFound;
		}
		
		public function itemStatus (index : int) : Boolean
		{
			return _itemsGot[index];
		}
		
		public function get nItemsNeeded () : int
		{
			return _itemsNeeded.length;
		}
	}

}