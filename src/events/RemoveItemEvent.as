package events
{
	import flash.events.Event;
	
	public class RemoveItemEvent extends Event
	{
		public function RemoveItemEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
		public static const REMOVE_ITEM_EVENT:String = "removeItemEvent";
		public static const REMOVE_ALL_ITEMS_EVENT:String = "removeAllItemsEvent";
	}
}