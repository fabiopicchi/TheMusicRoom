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
		private var _item : InventoryItem;
		private var _type : int;
		private var _selected : int;
		private var _arItems : Array = [];
		private var slotSelectMode : Boolean = false;
		
		public function PuzzleScreen() 
		{
			
		}
		
		public function initPuzzleScreen (p : PuzzleElement) : void
		{
			_pElement = p;
			_type = INSERT_SLOT;
			_selected = 1;
			for (var i : int = 0; i < p.nItemsNeeded; i++)
			{
				if (i == _selected -  1) 
				{
					(getChildByName("slot" + (i + 1)) as MovieClip).visible = true;
				}
				else
				{
					(getChildByName("slot" + (i + 1)) as MovieClip).visible = false;
				}
				(getChildByName("slot" + (i + 1)) as MovieClip).gotoAndStop(1);
			}
		}
		
		public function insertItem () : void
		{
			if (_pElement.itemBelongsToPuzzle(item.id))
			{
				_arItems.push (item);
				(getChildByName("slot" + _selected) as MovieClip).gotoAndStop(item.id);
				selectNextRight(false);
				Game.showInventory();
			}
			else
			{
				Game.displayText(["Edgard: I don't think this would make sense."], function () : void
				{
					Game.addToInventory(item.id);
					Game.showInventory();
				});
			}
			if (_arItems.length == _pElement.nItemsNeeded)
			{
				Game.hideInventory();
				var arAnswer : Array = [];
				for (var i : int = 0; i < _pElement.nItemsNeeded; i++)
				{
					arAnswer.push((getChildByName("slot" + (i + 1)) as MovieClip).currentFrameLabel);
				}
				if (_pElement.testResult(arAnswer))
				{
					Game.removePuzzleScreen(solveCallback);
				}
				else
				{
					for (var j : int = 0; j < _arItems.length; j++)
					{
						Game.addToInventory(_arItems[j].id);
					}
					
					Game.removePuzzleScreen(function () : void
					{
						Game.displayText(_pElement.textWrong.split("#pb"));
					});
				}
			}
			slotSelectMode = false;
		}
		
		private function solveCallback () : void
		{
			var i : int = 0;
			
			if (_pElement.inventoryItemReward)
			{
				Game.addToInventory(_pElement.inventoryItemReward);
			}
			for (i = 0; i < _pElement.elementsCreated.length; i++)
			{
				Game.changeElement(_pElement.elementsCreated[i], true);
			}
			for (i = 0; i < _pElement.elementsDestroyed.length; i++)
			{
				Game.changeElement(_pElement.elementsDestroyed[i], false);
			}
			Game.displayText(_pElement.textRight.split("#pb"));
		}
		
		public function update () : void
		{
			switch(_type)
			{
				case INSERT_SLOT:
					if (slotSelectMode)
					{
						if (Game.keyJustPressed(Action.RIGHT))
						{
							selectNextRight();
						}
						else if (Game.keyJustPressed(Action.LEFT))
						{
							selectNextLeft();
						}
						
						if (Game.keyJustPressed(Action.INTERACT))
						{
							insertItem();
						}
					}
					break;
				case CODE:
					break;
				default:
					break;
			}
		}
		
		public function get type():int 
		{
			return _type;
		}
		
		public function get item():InventoryItem 
		{
			return _item;
		}
		
		public function set item(value:InventoryItem):void 
		{
			_item = value;
			slotSelectMode = true;
		}
		
		private function selectNextRight (hideCurrent : Boolean = true) : void
		{
			var i : int;
			var index : int;
			for (i = _selected + 1; i < (_selected + _pElement.nItemsNeeded); i++)
			{
				index = (i - 1) % _pElement.nItemsNeeded + 1;
				if ((getChildByName("slot" + index) as MovieClip).currentFrame == 1)
				{
					(getChildByName("slot" + index) as MovieClip).visible = true;
					if (hideCurrent) (getChildByName("slot" + _selected) as MovieClip).visible = false;
					_selected = index;
					break;
				}
			}
		}
		
		private function selectNextLeft (hideCurrent : Boolean = true) : void
		{
			var i : int;
			var index : int;
			for (i = _selected - 1; i > (_selected - _pElement.nItemsNeeded); i--)
			{
				index = ((i - 1) + _pElement.nItemsNeeded) % _pElement.nItemsNeeded + 1;
				if ((getChildByName("slot" + index) as MovieClip).currentFrame == 1)
				{
					(getChildByName("slot" + index) as MovieClip).visible = true;
					if (hideCurrent)
					{
						(getChildByName("slot" + _selected) as MovieClip).visible = false;
					}
					_selected = index;
					break;
				}
			}
		}
	}

}