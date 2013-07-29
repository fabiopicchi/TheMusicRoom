package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class InteractiveElement extends Entity 
	{
		//Possible entity status
		public static const OUT : int = 1 << 0;
		public static const OVER : int = 1 << 1;
		public static const HIDDEN : int = 1 << 2;
		
		public function InteractiveElement() 
		{
			
		}
		
		public function interact (item : InventoryItem = null) : void
		{
			
		}
		
	}

}