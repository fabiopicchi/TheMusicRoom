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
		public static const INTERACT:int = 1 << 2;
		public static const INVENTORY:int = 1 << 3;
		
		public function Action() 
		{
			
		}
		
		public static function getAction (keyCode : int) : int
		{
			switch (keyCode)
			{
				case 65:
				case 37:
					return LEFT;
					
				case 68:
				case 39:
					return RIGHT;
				
				case 32:
					return INTERACT;
					
				case 73:
					return INVENTORY;
				
				default:
					return NONE;
			}
		}
		
	}

}