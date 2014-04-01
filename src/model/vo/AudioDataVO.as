package model.vo
{
	/**
	 * 声音数据模型 
	 * @author sxmad
	 * 
	 */	
	[Bindable]
	public class AudioDataVO
	{
		public function AudioDataVO()
		{
		}
		
		public var audioID:String; //声音ID
		public var audioType:int; //声音类型
		public var audioSN:int; //声音编号
		
		public var removeFlag:Boolean=false;//删除声音标识
	}
}