package  
{
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
		private var _sceneElementsAffected : Array;
		private var _puzzleElementAffected : Array;
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
			_sceneElementsAffected = ((data.elementsAffected is Array) ? data.elementsAffected : [data.elementsAffected]);
			_puzzleElementAffected = ((data.puzzlesAffected is Array) ? data.puzzlesAffected : [data.puzzlesAffected]);
			_inventoryItemSpawned = data.itemSpawned;
			_teleport = data.teleport;
			_periodChange = (data.periodChange == "-" ? false : true);
		}
		
		override public function interact (item : InventoryItem = null) : void
		{			
			super.interact();
			if (item)
			{
				if (item.id == _inventoryItemNeeded)
				{
					Game.displayText(_textRightItem.split("\n\r"), interactionCallback);
				}
				else
				{
					Game.displayText(_textWrongItem.split("\n\r"));
				}
			}
			else
			{
				if (_inventoryItemNeeded == "-" && _inventoryItemSpawned)
				{
					Game.displayText(_textNoItem.split("\n\r"), interactionCallback);
				}
				else
				{
					Game.displayText(_textNoItem.split("\n\r"));
				}
			}
		}
		
		public function interactionCallback () : void
		{
			var i : int = 0;
			Game.addToInventory(_inventoryItemSpawned);
			for (i = 0; i < _sceneElementsAffected.length; i++)
			{
				Game.changeSceneElement(_sceneElementsAffected[i]);
			}
			if (_teleport)
			{
				Game.teleport(_teleport);
			}
			if (_periodChange)
			{
				Game.periodChange();
			}
			for (i = 0; i < _puzzleElementAffected.length; i++)
			{
				Game.changePuzzleElement(_puzzleElementAffected[i]);
			}
		}
	}

}