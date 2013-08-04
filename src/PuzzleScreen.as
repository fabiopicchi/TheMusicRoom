package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author 
	 */
	public class PuzzleScreen extends MovieClip 
	{
		public static const INSERT_SLOT : int = 0;
		public static const CODE : int = 1;
		
		private var _pElement : PuzzleElement;
		private var _type : int;
		private var _selected : int;
		
		public function PuzzleScreen() 
		{
			
		}
		
		public function initPuzzleScreen (p : PuzzleElement) : void
		{
			_pElement = p;
			_type = INSERT_SLOT;
			var firstAvailable : Boolean = true;
			for (var i : int = 0; i < p.nItemsNeeded; i++)
			{
				if (!p.itemStatus(i))
				{
					if (firstAvailable) 
					{
						firstAvailable = false;
						_selected = (i + 1);
					}
					else
					{
						(getChildByName("slot" + (i + 1)) as MovieClip).visible = false;
					}
					(getChildByName("slot" + (i + 1)) as MovieClip).gotoAndStop(1);
				}
				else
				{
					(getChildByName("slot" + (i + 1)) as MovieClip).gotoAndStop(2);
				}
			}
		}
		
		public function insertItem (item : InventoryItem) : Boolean
		{
			if (_pElement.addItemToPuzzle(item.id))
			{
				this[item.id].gotoAndStop(2);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function close () : void
		{
			
		}
		
		public function update () : void
		{
			switch(_type)
			{
				case INSERT_SLOT:
					var i : int;
					var index : int;
					if (Game.keyJustPressed(Action.RIGHT))
					{
						for (i = _selected + 1; i < (_selected + _pElement.nItemsNeeded); i++)
						{
							index = (i - 1) % _pElement.nItemsNeeded + 1;
							if (!_pElement.itemStatus(index - 1))
							{
								(getChildByName("slot" + index) as MovieClip).visible = true;
								(getChildByName("slot" + _selected) as MovieClip).visible = false;
								_selected = index;
								break;
							}
						}
					}
					else if (Game.keyJustPressed(Action.LEFT))
					{
						for (i = _selected - 1; i > (_selected - _pElement.nItemsNeeded); i--)
						{
							index = ((i - 1) + _pElement.nItemsNeeded) % _pElement.nItemsNeeded + 1;
							if (!_pElement.itemStatus(index - 1))
							{
								(getChildByName("slot" + index) as MovieClip).visible = true;
								(getChildByName("slot" + _selected) as MovieClip).visible = false;
								_selected = index;
								break;
							}
						}
					}
					break;
				case CODE:
					break;
				default:
					break;
			}
		}
	}

}