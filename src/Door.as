package  
{
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
			var r : Room;
			var door : Door;
			var roomPosition : Number;
			var found : Boolean = false;
			
			for (var k : String in Game.ROOM_MAP)
			{
				r = Game.ROOM_MAP[k] as Room;
				if (r.name == _destiny)
				{
					for (var i : int = 0; i <  r.numChildren; i++)
					{
						if (door = r.getChildAt(i) as Door)
						{
							if (door.destiny == name)
							{
								roomPosition = door.x;
								found = true;
								break;
							}
						}
					}
				}
				if (found) break;
			}
			
			Game.setNextRoom(_destiny, roomPosition);
		}
		
		public function get destiny():String 
		{
			return _destiny;
		}
		
	}

}