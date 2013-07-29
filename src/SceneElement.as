package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class SceneElement extends Entity 
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
		
		//Possible entity status
		public static const OUT : int = 1 << 0;
		public static const OVER : int = 1 << 1;
		public static const HIDDEN : int = 1 << 2;
		
		public function SceneElement() 
		{
			
		}
		
		public function interact (item : InventoryItem = null) : void
		{			
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
				if (!_inventoryItemNeeded && _inventoryItemSpawned)
				{
					Game.displayText(_textNoItem.split("\n\r"), interactionCallback);
				}
				else
				{
					Game.displayText(_textNoItem.split("\n\r"));
				}
			}
		}
		
		private function interactionCallback () : void
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