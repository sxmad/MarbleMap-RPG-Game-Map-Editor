package model.vo
{
	import flash.geom.Point;

	[Bindable]
	public class ItemDataVO
	{
		public function ItemDataVO()
		{
		}
		
		public var itemId:String;//物品ID，利用Date.gettime()生成不重复id
		public var itemFileName:String;//物品文件名，xxx.png
		public var itemFilePath:String;//物品路径，c:/xxx.png
		
		public var itemType:int;//物品类型
		public var itemSN:int;//物品编号
		public var itemPosX:int;//物品坐标
		public var itemPosY:int;//物品坐标，左下角坐标系
		
		public var itemRegPosX:Number = 0.5; //物品X轴注册点，用百分比表示
		public var itemRegPosY:Number = 0.0; //物品Y轴注册点，用百分比表示
		
		public var isPortal:Boolean = false;
		public var portalToMap:int;//要传送的目标地图编号
		public var portalToPos:int;//要传送目标地图上的出生点编号
		
		public var isNpc:Boolean = false;//是否是NPC
		public var npcDirection:int;//npc方向
		//public var flag:Boolean = true;//允许鼠标事件
		
	}
}