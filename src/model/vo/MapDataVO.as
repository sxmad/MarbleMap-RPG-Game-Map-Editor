package model.vo
{
	[Bindable]
	public class MapDataVO
	{
		public function MapDataVO()
		{
		}
		public var mapBgPath:				String;//背景图路径
		public var mapName:			String;//地图名称
		
		public var mapW:				int;//地图宽
		public var mapH:				int;//地图高
				
		public var mapGridW:			int;//地图网格宽
		public var mapGridH:			int;//地图风格高
		
		public var mapFlagArr:			Array=[];//地图可通过标记0-通过，1-阻挡
		
	}
}