package model.vo
{
	[Bindable]
	public class PenWeightVO
	{
		public function PenWeightVO()
		{
		}
		
		public var penWeight:int = 1;//所选笔刷类型
		
		public static const PEN_COUNT:int = 10; //笔刷数量
		//===========笔刷类型
		public static const PEN_WEIGHT_1:int = 1;
		public static const PEN_WEIGHT_2:int = 3;
		public static const PEN_WEIGHT_3:int = 5;
		public static const PEN_WEIGHT_4:int = 7;
		public static const PEN_WEIGHT_5:int = 9;
		public static const PEN_WEIGHT_6:int = 11;
		public static const PEN_WEIGHT_7:int = 13;
		public static const PEN_WEIGHT_8:int = 15;
		public static const PEN_WEIGHT_9:int = 17;
		public static const PEN_WEIGHT_10:int = 19;
	}
}