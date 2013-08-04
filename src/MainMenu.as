package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class MainMenu extends MovieClip 
	{
		
		public static const ENTER : int = 0;
		public static const LOAD : int = 1;
		public static const CREDITS : int = 2;
		public static const RUN_AWAY : int = 3;
		
		private const _arMenuItem : Array = ["itemEnter", "itemLoad", "itemCredits", "itemRunAway"];
		private var _currentItem : int = ENTER;
		
		public function MainMenu() 
		{
			(getChildByName(_arMenuItem[ENTER]) as MovieClip).gotoAndStop(2);
			
			for (var i : int = 1; i <= 3; i++)
			{
				(getChildByName(_arMenuItem[i]) as MovieClip).gotoAndStop(1);
			}
		}
		
		public function nextItem() : void
		{
			if (_currentItem >= 3)
			{
				_currentItem = ENTER;
			}
			else
			{
				_currentItem++;
			}
			
			for (var i : int = 0; i < 4; i++)
			{
				if (i == _currentItem)
				{
					(getChildByName(_arMenuItem[i]) as MovieClip).gotoAndStop(2);
				}
				else
				{
					(getChildByName(_arMenuItem[i]) as MovieClip).gotoAndStop(1);
				}
			}
		}
		
		public function previousItem() : void
		{
			if (_currentItem <= 0)
			{
				_currentItem = RUN_AWAY;
			}
			else
			{
				_currentItem--;
			}
			
			for (var i : int = 0; i < 4; i++)
			{
				if (i == _currentItem)
				{
					(getChildByName(_arMenuItem[i]) as MovieClip).gotoAndStop(2);
				}
				else
				{
					(getChildByName(_arMenuItem[i]) as MovieClip).gotoAndStop(1);
				}
			}
		}
		
		public function select() : int
		{
			return _currentItem;
		}
	}

}