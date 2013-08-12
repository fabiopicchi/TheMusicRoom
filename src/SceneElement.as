package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
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
		private var _sfx : String;
		private var _sfxType : int;
		
		//Triggers
		private var _elementsCreated : Array;
		private var _elementsDestroyed : Array;
		private var _inventoryItemSpawned : String;
		private var _teleport : String;
		private var _periodChange : Boolean;
		
		private const ON_USE : int = 0;
		private const CONSTANT : int = 1;
		
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
			_sfx = data.soundEffect;
			_sfxType = data.soundEffectType;
			
			_periodChange = (data.periodChange == "" ? false : true);
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			
			var child : DisplayObject;
			if (_sfx && this.visible)
			{
				for (var i : int = 0; i < numChildren; i++)
				{
					child = getChildAt(i);
					if (child is MovieClip)
					{
						(child as MovieClip).gotoAndPlay(1);
					}
				}
				Game.playSfx(_sfx, true);
			}
		}
		
		override public function interact (item : InventoryItem = null) : void
		{	
			if (item)
			{
				if (item.id == _inventoryItemNeeded)
				{
					if (_sfx != "")
					{
						if (_sfxType == ON_USE)
						{
							Game.playSfx(_sfx);
						}
					}
					Game.displayText(_textRightItem.split("#pb"), interactionCallback);
					Game.removeFromInventory(false);
				}
				else
				{
					Game.displayText(_textWrongItem.split("#pb"));
				}
			}
			else
			{
				if (_inventoryItemNeeded == "")
				{
					if (_sfx != "")
					{
						if (_sfxType == ON_USE)
						{
							Game.playSfx(_sfx);
						}
					}
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
		
		public function onEnterRoom () : void
		{
			var child : DisplayObject;
			if (_sfx && this.visible)
			{
				for (var i : int = 0; i < numChildren; i++)
				{
					child = getChildAt(i);
					if (child is MovieClip)
					{
						(child as MovieClip).gotoAndPlay(1);
					}
				}
				Game.playSfx(_sfx, true);
			}
		}
	}

}