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
		private var _elementsCreated : Array;
		private var _elementsDestroyed : Array;
		private var _textRight : String;
		private var _textWrong : String;
		private var _nItemsNeeded : int;
		
		public function PuzzleElement() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_inventoryItemReward = data.inventoryItemReward;
			_itemsNeeded = ((data.itemsNeeded is Array) ? data.itemsNeeded : [data.itemsNeeded]);
			_elementsCreated = ((data.elementsCreated is Array) ? data.elementsCreated : []);
			_elementsDestroyed = ((data.elementsDestroyed is Array) ? data.elementsDestroyed : []);
			_textRight = "YES";
			_textWrong = "Unknown voice: Show me your moves!";
		}
		
		override public function interact(item:InventoryItem = null):void 
		{
			if (item == null)
			{
				Game.puzzleScreen(this);
			}
			else
			{
				Game.displayText([Game.DEFAULT_TEXT_NO_SENSE]);
			}
		}
		
		public function itemBelongsToPuzzle (id : String) : Boolean
		{
			return (_itemsNeeded.indexOf(id) != -1);
		}
		
		public function get nItemsNeeded () : int
		{
			if (_itemsNeeded.length > 0)
			{
				if (_nItemsNeeded == 0)
				{
					for (var i : int = 0; i < _itemsNeeded.length; i++)
					{
						if (_itemsNeeded[i] != "")
						{
							_nItemsNeeded++;
						}
					}
				}
				return _nItemsNeeded;
			}
			return 0;
		}
		
		public function get inventoryItemReward():String 
		{
			return _inventoryItemReward;
		}
		
		public function get itemsNeeded():Array 
		{
			return _itemsNeeded;
		}
		
		public function get elementsCreated():Array 
		{
			return _elementsCreated;
		}
		
		public function get elementsDestroyed():Array 
		{
			return _elementsDestroyed;
		}
		
		public function get textRight():String 
		{
			return _textRight;
		}
		
		public function get textWrong():String 
		{
			return _textWrong;
		}
		
		public function testResult (arAnswer : Array) : Boolean
		{
			for (var i : int = 0; i < arAnswer.length; i++)
			{
				if (arAnswer[i] != _itemsNeeded[i])
				{
					return false;
				}
			}
			return true;
		}
	}

}