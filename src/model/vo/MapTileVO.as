package model.vo
{
	/**
	 * maptile数据结构 
	 * @author sxmad
	 * 
	 */	
	public class MapTileVO
	{
		public function MapTileVO()
		{
		}
		//以下假设地图网格的大小为30*30
		public var tileShowPos:Array; //地图块要显示出来的实际坐标 -- 显示位置处理坐标
		public var tilePosArr:Array; //地块在地图中的顶点坐标，[30,30] -- 导出到文件的坐标 
		public var tileLocArr:Array; //地块在二维数组中的位置，[30,30]的具体坐标对应二维数组中的[0,0]位置
		
		public var tileColor:uint; //当前块的颜色
		
		public var tileW:int;
		public var tileH:int;
		
		public static const CROSS_FLAG:int = 0; //可通过
		public static var block_flag:Number = 1; //层标记，如阻挡层1，或其他
		
		public var tileState:int = CROSS_FLAG;//选择地图块和取消选择不同的状态
		public static var isMouseDown:Boolean = false;
		
	}
}