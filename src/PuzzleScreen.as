package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author 
	 */
	public class PuzzleScreen extends MovieClip 
	{
		public static const TYPE_CHEST : int = 1 << 0;
		
		private var _pElement : PuzzleElement;
		
		public function PuzzleScreen(p : PuzzleElement) 
		{
			_pElement = p;
		}
		
		public function insertItem (item : InventoryItem) : Boolean
		{
			if (_pElement.addItemToPuzzle(item.id))
			{
				this[item.id].gotoAndStop(2);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function close () : void
		{
			
		}
	}

}