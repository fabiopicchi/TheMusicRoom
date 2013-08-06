package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Action 
	{
		public static const NONE:int = 0;
		public static const LEFT:int = 1 << 0;
		public static const RIGHT:int = 1 << 1;
		public static const UP:int = 1 << 2;
		public static const DOWN:int = 1 << 3;
		public static const INTERACT:int = 1 << 4;
		public static const INVENTORY:int = 1 << 5;
		public static const BACK:int = 1 << 6;
		public static const CONFIRM:int = 1 << 7;
		
		public function Action() 
		{
			
		}
		
		public static function getAction (keyCode : int) : int
		{
			switch (keyCode)
			{
				//case 65:
				case 37:
					return LEFT;
					
				//case 68:
				case 39:
					return RIGHT;
				
				//case 87:
				case 38:
					return UP;
				
				//case 83:
				case 40:
					return DOWN;
					
				case 67:
					return INTERACT;
				
				case 90:
					return BACK;
				
				case 88:
					return INVENTORY;
				
				default:
					return NONE;
			}
		}
		
	}

}