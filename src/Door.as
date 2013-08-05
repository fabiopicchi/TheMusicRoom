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
		
		public function Door() 
		{
			
		}
		
		public function loadData (data : Object) : void
		{
			_destiny = data.destiny;
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
								break;
							}
						}
					}
				}
				
				if (found)
				{
					Game.setNextRoom(_destiny, roomPosition);
				}
			}
			else
			{
				Game.displayText(["Edgard: I don't think this would make sense."]);
			}
		}
		
		public function get destiny():String 
		{
			return _destiny;
		}
		
	}

}