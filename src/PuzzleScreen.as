package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author 
	 */
	public class PuzzleScreen extends MovieClip 
	{
		private var _pElement : PuzzleElement;
		private var _selected : int;
		private var _arItems : Array = [];
		private var slotSelectMode : Boolean = false;
		private var _nElements : int = 0;
		
		public function PuzzleScreen() 
		{
			
		}
		
		public function initPuzzleScreen (p : PuzzleElement) : void
		{
			while (getChildByName("slot" + (++_nElements)) != null){}
			_nElements--;
			
			_pElement = p;
			_selected = 1;
			var i : int = 0
			for (i = 0; i < _nElements; i++)
			{
				if (i == _selected -  1) 
				{
					(getChildByName("slot" + (i + 1)) as MovieClip).gotoAndStop(2);
				}
				else
				{
					(getChildByName("slot" + (i + 1)) as MovieClip).gotoAndStop(1);
				}
			}
			
			if (_pElement.type == PuzzleElement.CODE) slotSelectMode = true;
		}
		
		public function insertItem () : void
		{
			var item : InventoryItem = Game.getInventoryItem(false);
			if (item)
			{
				if (_pElement.itemBelongsToPuzzle(item.id))
				{
					_arItems.push ({pos:_selected - 1, item:item});
					(getChildByName("slot" + _selected) as MovieClip).gotoAndStop(item.id);
					selectNextRight(false);
					Game.removeFromInventory(false);
					Game.playSfx(Game.FIT_SLOT);
					if (_arItems.length == _pElement.itemsNeeded.length)
					{
						var arAnswer : Array = [];
						var i : int ;
						for (i = 0; i < _nElements; i++)
						{
							arAnswer.push("");
						}
						for (i = 0; i < _arItems.length; i++)
						{
							arAnswer[_arItems[i].pos] = _arItems[i].item.id;
						}
						if (_pElement.testResult(arAnswer))
						{
							Game.removePuzzleScreen(solveCallback);
						}
						else
						{
							for (i = 0; i < _arItems.length; i++)
							{
								Game.addToInventory(_arItems[i].item.id, false);
							}
							
							Game.removePuzzleScreen(function () : void
							{
								Game.displayText(_pElement.textWrong.split("#pb"));
							});
						}
					}
					else
					{
						Game.showInventory();
					}
				}
				else
				{
					Game.displayText([Game.DEFAULT_TEXT_NO_SENSE], function () : void
					{
						Game.showInventory();
					});
				}
			}
			else
			{
				Game.displayText([Game.DEFAULT_TEXT_NO_ITEMS], function () : void
				{
					for (var j : int = 0; j < _arItems.length; j++)
					{
						Game.addToInventory(_arItems[j].item.id, false);
					}
					Game.removePuzzleScreen();
				});
			}
			
			slotSelectMode = false;
		}
		
		public function pressButton () : void
		{
			_arItems.push(_selected);
			Game.playSfx(Game.FIT_SLOT);
			if (_pElement.testResult(_arItems))
			{
				Game.removePuzzleScreen(solveCallback);
			}
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
			}
			if (Game.keyJustPressed(Action.BACK))
			{
				Game.hideInventory();
				Game.removePuzzleScreen();
			}
			switch(_pElement.type)
			{
				case PuzzleElement.INSERT_SLOT:
					if (Game.keyJustPressed(Action.INTERACT))
					{
						if (!slotSelectMode)
						{
							slotSelectMode = true;
							Game.hideInventory();
						}
						else
						{
							insertItem();
						}
					}
					if (Game.keyJustPressed(Action.BACK))
					{
						for (var j : int = 0; j < _arItems.length; j++)
						{
							Game.addToInventory(_arItems[j].item.id, false);
						}
					}
					break;
				case PuzzleElement.CODE:
					if (Game.keyJustPressed(Action.INTERACT))
					{
						pressButton();
					}
					break;
				default:
					break;
			}
		}
		
		public function get arItems():Array 
		{
			return _arItems;
		}
		
		private function selectNextRight (hideCurrent : Boolean = true) : void
		{
			var i : int;
			var index : int;
			for (i = _selected + 1; i < (_selected + _nElements); i++)
			{
				index = (i - 1) % _nElements + 1;
				if ((getChildByName("slot" + index) as MovieClip).currentFrame == 1)
				{
					(getChildByName("slot" + index) as MovieClip).gotoAndStop(2);
					if (hideCurrent) (getChildByName("slot" + _selected) as MovieClip)..gotoAndStop(1);
					_selected = index;
					break;
				}
			}
		}
		
		public function get type () : int
		{
			return _pElement.type;
		}
		
		private function selectNextLeft (hideCurrent : Boolean = true) : void
		{
			var i : int;
			var index : int;
			for (i = _selected - 1; i > (_selected - _nElements); i--)
			{
				index = ((i - 1) + _nElements) % _nElements + 1;
				if ((getChildByName("slot" + index) as MovieClip).currentFrame == 1)
				{
					(getChildByName("slot" + index) as MovieClip).gotoAndStop(2);
					if (hideCurrent)
					{
						(getChildByName("slot" + _selected) as MovieClip).gotoAndStop(1);
					}
					_selected = index;
					break;
				}
			}
		}
	}

}