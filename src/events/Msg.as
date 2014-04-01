package events
{
	import flash.events.Event;
	
	public class Msg extends Event
	{
		public function Msg(type:String,obj:Object=null)
		{
			super(type);
			this.o = obj;
		}
		public var o:Object;
		
		public static const NEW_MAP:String = "new_map";//新建地图
		
		public static const DIVIDE_PREVIEW:String = "divide_preview";//预览切块大小
		public static const DIVIDE_BLOCK:String = "divide_block";//大地图切块
		
		public static const LAYER_UP:int = 1; //物品层级上移
		public static const LAYER_DOWN:int = 2; //物品层级下移
		public static const LAYER_EVENT:String = "layerEvent";
		
		public static const SET_ITEM_EVENT:String = "setItemEvent";//设置物品事件，调整物品类型，编号，坐标等 
		
		public static const IMPORT_ITEMS:String = "importItemsEvent";//导入物品配置
		
	}
}