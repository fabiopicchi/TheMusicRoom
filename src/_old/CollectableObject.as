package  
{
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class CollectableObject extends GameObject 
	{
		
		public function CollectableObject() 
		{
			
		}
		
		override public function interact(fromPlayer:Boolean = true):void 
		{
			super.interact(fromPlayer);
			
			Game.addToInventory(_id);
			
			parent.removeChild(this);
		}
		
	}

}