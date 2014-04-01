package controller.utils
{
	import com.adobe.crypto.MD5;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	/**
	 * 工具类 
	 * @author sxmad
	 * 
	 */	
	public class XTools
	{
		public function XTools()
		{
		}
		
		private static var _instance:XTools;
		
		public static function getInstance():XTools{
			if(null == _instance){
				_instance = new XTools();
			}
			return _instance;
		}
		/**
		 * 生成唯一ID 
		 * @return 
		 */		
		public function getUniquelyId():String{
			var date:Date = new Date();
			var itemId:String = MD5.hash("sxmad"+String(date.time)+String(Math.random()*date.time)).toUpperCase();
			return itemId;
		}
		/**
		 * 转换锚点图片Y坐标 
		 * @param parentH 父容器高度
		 * @param regImgH 锚点图片高度
		 * @param regPosY 锚点坐标X轴位置
		 * @param leftBottomOriginFlag 是否是左下角坐标系
		 * @return 
		 * 
		 */		
		public function getItemRegPosY(parentH:int,regImgH:int,regPosY:Number,leftBottomOriginFlag:Boolean = true):int{
			var tempRegY:int;
			if(leftBottomOriginFlag){
				tempRegY = int(parentH - parentH * regPosY - regImgH/2);
			}else{
				tempRegY = int(parentH * regPosY - regImgH/2);
			}
			return tempRegY;
		}
		/**
		 * 转换锚点图片X坐标 
		 * @param parentW 父容器宽度
		 * @param regImgW 锚点图片宽度
		 * @param regPosX 锚点坐标X轴位置
		 * @return 
		 * 
		 */		
		public function getItemRegPosX(parentW:int,regImgW:int,regPosX:Number):int{
			var tempRegX:int;
			tempRegX = int(parentW * regPosX - regImgW / 2);
			return tempRegX;
		}
	}
}