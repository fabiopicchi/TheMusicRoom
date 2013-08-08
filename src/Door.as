package  
{
	import flash.display.Shape;
	/**
	 * ...
	 * @author 
	 */
	public class Door extends InteractiveElement 
	{
		private var _destiny : String;
		private var _soundCode : int = 1;
		
		public function Door() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_destiny = data.destiny;
			_soundCode = data.sound;
		}
		
		override public function interact(item : InventoryItem = null) : void
		{
			if (item == null)
			{
				var r : Room = Game.ROOM_MAP[_destiny];
				var door : Door;
				var roomPosition : Number;
				var found : Boolean = false;
				
				if (r)
				{
					for (var i : int = 0; i <  r.numChildren; i++)
					{
						if ((door = r.getChildAt(i) as Door))
						{
							if (door.destiny == parent.name)
							{
								roomPosition = door.x;
								found = true;
							}
						}
					}
				}
				
				if (found)
				{
					switch (_soundCode)
					{
						case 0:
							break;
						case 1:
							Game.playSfx(Game.DOOR);
							break;
						case 2:
							Game.playSfx(Game.STAIRS);
							break;
					}
					Game.setNextRoom(_destiny, roomPosition);
				}
			}
			else
			{
				Game.displayText([Game.DEFAULT_TEXT_NO_SENSE]);
			}
		}
		
		public function get destiny():String 
		{
			return _destiny;
		}
		
	}

}