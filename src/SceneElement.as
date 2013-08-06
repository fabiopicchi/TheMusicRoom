package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class SceneElement extends InteractiveElement 
	{
		//Interaction properties
		private var _textNoItem : String;
		private var _textWrongItem : String;
		private var _textRightItem : String;
		private var _inventoryItemNeeded : String;
		
		//Triggers
		private var _elementsCreated : Array;
		private var _elementsDestroyed : Array;
		private var _inventoryItemSpawned : String;
		private var _teleport : String;
		private var _periodChange : Boolean;
		
		public function SceneElement() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_textNoItem = data.textNoItem;
			_textRightItem = data.textRightItem;
			_textWrongItem = data.textWrongItem;
			_inventoryItemNeeded = data.itemNeeded;
			_elementsCreated = ((data.elementsCreated is Array) ? data.elementsCreated : [data.elementsCreated]);
			_elementsDestroyed = ((data.elementsDestroyed is Array) ? data.elementsDestroyed : [data.elementsDestroyed]);
			_inventoryItemSpawned = data.itemSpawned;
			_teleport = data.teleport;
			
			_periodChange = (data.periodChange == "" ? false : true);
		}
		
		override public function interact (item : InventoryItem = null) : void
		{	
			if (item)
			{
				if (item.id == _inventoryItemNeeded)
				{
					Game.displayText(_textRightItem.split("#pb"), interactionCallback);
				}
				else
				{
					Game.displayText(_textWrongItem.split("#pb"));
					Game.addToInventory(item.id, false);
				}
			}
			else
			{
				if (_inventoryItemNeeded == "")
				{
					Game.displayText(_textNoItem.split("#pb"), interactionCallback);
				}
				else
				{
					Game.displayText(_textNoItem.split("#pb"));
				}
			}
		}
		
		private function interactionCallback () : void
		{
			if (_inventoryItemSpawned)
			{
				Game.addToInventory(_inventoryItemSpawned);
			}
			
			if (_periodChange || _teleport)
			{
				if (_teleport)
				{
					Game.teleport(_teleport, function () : void
					{
						affectElements();
					});
				}
				if (_periodChange)
				{
					if (_teleport)
					{
						Game.periodChange();
					}
					else
					{
						Game.periodChange(function () : void
						{
							affectElements();
						});
					}
				}
			}
			else
			{
				affectElements();
			}
		}
		
		private function affectElements () : void
		{
			var i : int;
			for (i = 0; i < _elementsCreated.length; i++)
			{
				Game.changeElement(_elementsCreated[i], true);
			}
			for (i = 0; i < _elementsDestroyed.length; i++)
			{
				Game.changeElement(_elementsDestroyed[i], false);
			}
		}
	}

}