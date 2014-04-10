package model
{
	import model.vo.AudioDataVO;
	import model.vo.ItemDataVO;
	import model.vo.MapDataVO;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.RadioButtonGroup;
	
	import view.ItemInMap;

	/**
	 * 共享数据类 
	 * @author sxmad
	 * 
	 */	
	[Bindable]
	public class Data
	{
		public function Data()
		{
		}
		public static const ITEM_IMPORT_IMG:String = "../icon/itemFlag.png";
		public static const ITEM_IMPORT_IMG_W:int = 48;
		public static const ITEM_IMPORT_IMG_H:int = 109;
		
		public static const INFO_TITLE:String = "提示";
		public static const INFO_OK_LABEL:String = "好吧";
		public static const ITEM_UP_URL:String = "../icon/up.png";
		public static const ITEM_DOWN_URL:String = "../icon/down.png";
		public static const ITEM_REMOVE_URL:String = "../icon/del.png";
		public static const ITEM_REG_URL:String = "../icon/reg.png";
		public static var itemRadioGroup:RadioButtonGroup = new RadioButtonGroup();
		public static var itemGroupName:String = "itemRadiobuttonGroup";
		
		public static var blockFlag:int = 1;//可自定义标识块的类型，默认是1
		/**
		 * 坐标系原点标识
		 * true 左下角坐标系
		 * false 克上角坐标系 
		 */		
		public static var leftBottomOriginFlag:Boolean = true;
		/**
		 * 是否可取消已选择的标记 
		 */		
		public static var unCancelFlag:Boolean = true;
		/**
		 * 地图规格数据 
		 */		
		public static var mapDataVO:MapDataVO = new MapDataVO();
		/**
		 * 是否做 路径标识 标志位
		 */		
		public static var markPathFlag:Boolean = true;
		
		/**
		 * 设置切块大小 
		 */		
		public static var divideBlockW:int;
		public static var divideBlockH:int;
		public static var dividePreViewFlag:Boolean = false;
		/**
		 * 地图切块的前缀 
		 */		
		public static var divideBlockPreName:String;
		/**
		 * 地图切块的存储路径 
		 */		
		public static var divideBlockPath:String;
		/**
		 * 当前选择的物品 
		 */		
		public static var currentItemInMap:ItemInMap;
		/**
		 * 导入的物品数据列表 
		 */		
		public static var importItemAc:ArrayCollection = new ArrayCollection();
		/**
		 * 被添加的物品列表 
		 */		
		public static var addedItemAc:ArrayCollection = new ArrayCollection();
		/**
		 * 被拖放物品的数据格式 
		 */		
		public static const ITEM_FORMAT:String = "itemFormat";
		/**
		 * 物品层中最高层级 
		 */		
		public static var maxLayerIndex:int;
		/**
		 * 删除物品标识 
		 */		
		public static var removeItemFlag:Boolean = false;
		/**
		 * 设置物品是否可穿透
		 */		
		public static var isPenetrate:Boolean = false;
//		/**
//		 * 是否是传送门 
//		 */		
//		public static var isPortal:Boolean = false;
		/**
		 * 声音列表数据源 
		 */		
		public static var audioAC:ArrayCollection = new ArrayCollection();
		public static var currentAudioDataVO:AudioDataVO = new AudioDataVO();
		/**
		 * 设置笔刷大小 
		 */		
		public static var penWeight:int=1;
		public static var overrideFlag:Boolean = true;
	}
}