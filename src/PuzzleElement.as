package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class PuzzleElement extends InteractiveElement 
	{
		public static const INSERT_SLOT : int = 0;
		public static const CODE : int = 1;
		
		private var _inventoryItemReward : String;
		private var _answer : Array;
		private var _elementsCreated : Array;
		private var _elementsDestroyed : Array;
		private var _textRight : String;
		private var _textWrong : String;
		private var _type : int;
		private var _itemsNeeded : Array = [];
		
		public function PuzzleElement() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_inventoryItemReward = data.inventoryItemReward;
			_answer = ((data.answer is Array) ? data.answer : []);
			_elementsCreated = ((data.elementsCreated is Array) ? data.elementsCreated : []);
			_elementsDestroyed = ((data.elementsDestroyed is Array) ? data.elementsDestroyed : []);
			_textRight = "Edgar: There seems to be something inside.";
			_textWrong = "Edgar: It is no use.";
			_type = Number(data.type);
			
			if (_type == INSERT_SLOT)
			{
				for (var i : int = 0; i < _answer.length; i++)
				{
					if (_answer[i] != "")
						_itemsNeeded.push(_answer[i]);
				}
			}
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
		
		public function get inventoryItemReward():String 
		{
			return _inventoryItemReward;
		}
		
		public function get itemsNeeded():Array 
		{
			return _answer;
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
		
		public function get type():int 
		{
			return _type;
		}
		
		public function testResult (arAnswer : Array) : Boolean
		{
			for (var i : int = 0; i < _answer.length; i++)
			{
				if (arAnswer[i] != _answer[i])
				{
					return false;
				}
			}
			return true;
		}
	}

}