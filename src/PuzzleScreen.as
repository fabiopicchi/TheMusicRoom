package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author 
	 */
	public class PuzzleScreen extends MovieClip 
	{
		
		private var _inventoryItemReward : String;
		private var _itemsNeeded : Array;
		
		public static const TYPE_CHEST : int = 1 << 0;
		
		public function PuzzleScreen() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_inventoryItemReward = data.inventoryItemReward;
			_itemsNeeded = ((data.itemsNeeded is Array) ? data.itemsNeeded : [data.itemsNeeded]);
		}
		
		public function addItemToPuzzle (item : String) : void
		{
			for (var i : int = 0; i < _itemsNeeded.length; i++)
			{
				if (item == _itemsNeeded[i])
				{
					_itemsNeeded.splice(i, 1);
					//Mudar frame do elemento do puzzle
				}
			}
			
			if (_itemsNeeded.length == 0)
			{
				fadeToBlack(function () : void
				{
					Game.addToInventory(_inventoryItemReward);
					parent.removeChild(this);
				});
			}
		}
		
	}

}