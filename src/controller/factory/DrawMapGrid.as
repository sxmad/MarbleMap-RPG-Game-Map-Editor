package controller.factory
{
	import com.adobe.serialization.json.JSON;
	
	import de.polygonal.ds.Array2;
	
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import model.Data;
	import model.vo.MapDataVO;
	import model.vo.MapTileVO;
	import model.vo.PenWeightVO;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * 绘制地图网格，可调密度 
	 * 添加相应地图块到相应的网格
	 * @author sxmad
	 * 
	 */	
	public class DrawMapGrid
	{
		public function DrawMapGrid()
		{
		}
		
		private var divideGrid:Shape = new Shape();//切割网格块
		private var grid:Shape = new Shape();//网格线
		private var tilesShape:Shape = new Shape();//网格块操作区
		private var tempShape:Shape = new Shape();//网格块临时操作区
		private var penShape:Shape = new Shape();//笔刷区域
		
		public static var mapTileArray:Array2;
		
		private var mapPathArray:Array;
		private var mapPathArray2:Array2;
		
		private static var _instance:DrawMapGrid;
		
		public static function getInstance():DrawMapGrid{
			if(!_instance){
				_instance = new DrawMapGrid();
			}
			return _instance;
		}
		public function clearDivedeGrid():void{
			divideGrid.graphics.clear();
		}
		public function drawDivideGrid(sv:SpriteVisualElement,mapWidth:int, mapHeight:int, tilePixelWidth:int, tilePixelHeight:int):void { 
			//trace("绘制切块网格");  
			divideGrid.graphics.clear();
			
			var row:int = Math.ceil(mapHeight / tilePixelHeight);   //格子行数
			var col:int = Math.ceil(mapWidth / tilePixelWidth);   //格子列数
			
			//设置地图大小，用来显示滚动条
			sv.width = mapWidth;
			sv.height = mapHeight;
			sv.addChild(divideGrid);
			divideGrid.graphics.beginFill(0x00ff00,.2);   
			divideGrid.graphics.drawRect(0,0,mapWidth,mapHeight);   
			divideGrid.graphics.endFill();   
			divideGrid.graphics.lineStyle(1, 0x00ff00, 1);   
			
			var verLineCount:int=col+1;   //竖线数
			var horLineCount:int = row + 1;   //横线数
			if(!Data.leftBottomOriginFlag){
				for (var m:int=0; m<verLineCount; m++) {                    
					divideGrid.graphics.moveTo( m*tilePixelWidth, 0);   
					divideGrid.graphics.lineTo( m*tilePixelWidth,mapHeight );   
				}
				for (var n:int=0; n<horLineCount; n++) {                    
					divideGrid.graphics.moveTo( 0, n*tilePixelHeight);   
					divideGrid.graphics.lineTo( mapWidth,n*tilePixelHeight );   
				}
				return;
			}
			
			for (var i:int=verLineCount - 1; i>-1; i--) {                    
				divideGrid.graphics.moveTo( i*tilePixelWidth, mapHeight);   
				divideGrid.graphics.lineTo( i*tilePixelWidth, 0);   
			}
			for (var j:int=horLineCount - 1; j>-1; j--) {                    
				divideGrid.graphics.moveTo( 0, mapHeight - j*tilePixelHeight);   
				divideGrid.graphics.lineTo( mapWidth, mapHeight - j*tilePixelHeight );   
			} 
		}
		
		//====================================================
		private var tileShapColor:uint = 0xcc6600;
		public function drawGrid(sv:SpriteVisualElement,mapWidth:int, mapHeight:int, tilePixelWidth:int, tilePixelHeight:int, isExistPathMap:Boolean = false):void {   
			//trace("绘制网格");
			grid.graphics.clear();
			tilesShape.graphics.clear();
			tempShape.graphics.clear();
			penShape.graphics.clear();
			
			var row:int = Math.ceil(mapHeight / tilePixelHeight);   //格子行数
			var col:int = Math.ceil(mapWidth / tilePixelWidth);   //格子列数
			//调用生成mapTile函数
			if(isExistPathMap){
				//如果是加载的文件，则用自己的规则生成
				generateMapPathTile(sv,row,col,tilePixelWidth,tilePixelHeight,mapWidth, mapHeight);
			}else{
				generateMapTile(sv,row,col,tilePixelWidth,tilePixelHeight,mapWidth, mapHeight);
			}
			
			//设置地图大小，用来显示滚动条
			sv.width = mapWidth;
			sv.height = mapHeight;
			
			sv.addChild(tilesShape);
			tilesShape.graphics.beginFill(tileShapColor,.1);
			tilesShape.graphics.drawRect(0,0,mapWidth,mapHeight);
			tilesShape.graphics.endFill();
			
			sv.addChild(tempShape);
			sv.addChild(penShape);
			
			sv.addChild(grid);
			grid.graphics.beginFill(tileShapColor,.1);   
			grid.graphics.drawRect(0,0,mapWidth,mapHeight);   
			grid.graphics.endFill();   
			grid.graphics.lineStyle(1, 0xff0000, 1);
			
			var verLineCount:int=col+1;   //竖线数
			var horLineCount:int = row + 1;   //横线数
			//坐标第原点判定，左上角
			if(!Data.leftBottomOriginFlag){
				for (var m:int=0; m<verLineCount; m++) {                    
					grid.graphics.moveTo( m*tilePixelWidth, 0);   
					grid.graphics.lineTo( m*tilePixelWidth,mapHeight );   
				}
				for (var n:int=0; n<horLineCount; n++) {                    
					grid.graphics.moveTo( 0, n*tilePixelHeight);   
					grid.graphics.lineTo( mapWidth,n*tilePixelHeight );   
				} 
				return;
			}
			
			for (var i:int=verLineCount-1; i>-1; i--) {                    
				grid.graphics.moveTo( i*tilePixelWidth, mapHeight);   
				grid.graphics.lineTo( i*tilePixelWidth, 0 );   
			}
			//坐标第原点判定，左下角
			for (var j:int=horLineCount-1; j>-1; j--) {                    
				grid.graphics.moveTo( 0, mapHeight - j*tilePixelHeight);   
				grid.graphics.lineTo( mapWidth,mapHeight -j*tilePixelHeight );   
			}
		}
		private function clearGrid():void{
			tempShape.graphics.clear();
			tilesShape.graphics.clear();
			grid.graphics.clear();
			divideGrid.graphics.clear();
		}
		/**
		 * 生成地图块 
		 * @param row 行数
		 * @param col 列数
		 * @param tilePixelWidth 单元格宽度
		 * @param tilePixelHeight 单元格高度
		 * 
		 */		
		private function generateMapTile(sv:SpriteVisualElement,row:int,col:int,tilePixelWidth:int,tilePixelHeight:int,mapWidth:int, mapHeight:int):void{
			removeMapTile(sv);
			if(mapTileArray){
				mapTileArray.clear();
			}
			mapTileArray = new Array2(col,row);
			for(var i:int=0;i<mapTileArray.width;i++){
				for(var j:int=0;j<mapTileArray.height;j++){
					var vo:MapTileVO = new MapTileVO();
					vo.tileW = tilePixelWidth;
					vo.tileH = tilePixelHeight;
					//具体坐标
					var posX:int = tilePixelWidth*i;
					var posY:int = tilePixelHeight*j;
					//显示坐标
					var showPosX:int;
					var showPosY:int;
					showPosX = tilePixelWidth*i;
					//判定坐标系原点
					if(Data.leftBottomOriginFlag){
						showPosY = mapHeight - tilePixelHeight*j - tilePixelHeight;
					}else{
						showPosY = tilePixelHeight*j;
					}
					vo.tileShowPos = new Array(showPosX,showPosY);
					vo.tilePosArr = new Array(posX,posY);
					vo.tileLocArr = new Array(i,j);
					
					mapTileArray.set(i,j,vo);
				}
			}
		}
		
		/**
		 * 生成地图块 
		 * @param row 行数
		 * @param col 列数
		 * @param tilePixelWidth 单元格宽度
		 * @param tilePixelHeight 单元格高度
		 * 
		 */		
		private function generateMapPathTile(sv:SpriteVisualElement,row:int,col:int,tilePixelWidth:int,tilePixelHeight:int,mapWidth:int, mapHeight:int):void{
			removeMapTile(sv);
			if(mapTileArray){
				mapTileArray.clear();
			}
			mapTileArray = new Array2(col,row);
			for(var i:int=0;i<mapTileArray.width;i++){
				for(var j:int=0;j<mapTileArray.height;j++){
					var vo:MapTileVO = new MapTileVO();
					//当前要设置的二维数组对应的一维位置
					var pos:int = j+i+(mapTileArray.width-1)*j;
					var mapTileState:int = int(mapPathArray[pos]);
					vo.tileW = tilePixelWidth;
					vo.tileH = tilePixelHeight;
					vo.tileState = mapTileState;
					vo.tileColor = getTileColor(vo.tileState);
					//具体坐标
					var posX:int = tilePixelWidth*i;
					var posY:int = tilePixelHeight*j;
					//显示坐标
					var showPosX:int;
					var showPosY:int;
					showPosX = tilePixelWidth*i;
					//判定坐标系原点
					if(Data.leftBottomOriginFlag){
						showPosY = mapHeight - tilePixelHeight*j - tilePixelHeight;
					}else{
						showPosY = tilePixelHeight*j;
					}
					vo.tileShowPos = new Array(showPosX,showPosY);
					vo.tilePosArr = new Array(posX,posY);
					vo.tileLocArr = new Array(i,j);
					
					mapTileArray.set(i,j,vo);
				}
			}
			resetTileShape();
			MapTileVO.block_flag = 1;
		}
		private function removeMapTile(sv:SpriteVisualElement):void{
			if(mapTileArray!=null){
				mapTileArray.clear();
				tilesShape.graphics.clear();
				tempShape.graphics.clear();
			}
		}
		/**
		 * 生成地图数组 
		 * @return 
		 * 
		 */		
		public function generateMapArray():String{
			var mapPath:String = "";
			mapPath += '{';
			mapPath += '"'+'mapW'+'":'+Data.mapDataVO.mapW+",";
			mapPath += '"'+'mapH'+'":'+Data.mapDataVO.mapH+",";
			mapPath += '"'+'mapGridW'+'":'+Data.mapDataVO.mapGridW+",";
			mapPath += '"'+'mapGridH'+'":'+Data.mapDataVO.mapGridH+",";
			mapPath += '"'+'divideBlockW'+'":'+Data.divideBlockW+",";
			mapPath += '"'+'divideBlockH'+'":'+Data.divideBlockH+",";
			mapPath += '"'+'mapFlagArr'+'":[';
			
			for(var i:int=0;i<mapTileArray.height;i++){
				for(var j:int=0;j<mapTileArray.width;j++){
					//trace(j+":"+i+" -- "+MapTile(mapTileArray.get(j,i)).tileState);
					var tileState:int = MapTileVO(mapTileArray.get(j,i)).tileState;
					mapPath += tileState + ',';
				}
			}
			mapPath = mapPath.substring(0,mapPath.length-1);
			mapPath += ']}';
			return mapPath;
		}
		/**
		 * 清除已标记的路径 
		 * 
		 */		
		public function clearMapPath():void{
			for(var i:int=0;i<mapTileArray.height;i++){
				for(var j:int=0;j<mapTileArray.width;j++){
					MapTileVO(mapTileArray.get(j,i)).tileState = MapTileVO.CROSS_FLAG;
				}
			}
			tilesShape.graphics.clear();
			tempShape.graphics.clear();
		}
		/**
		 * 载入已编写过的路径 
		 * 
		 */		
		public function loadMapPath(sv:SpriteVisualElement,pathData:String):void{
			var l_map:Object = new Object();
			l_map = com.adobe.serialization.json.JSON.decode(pathData);
			mapPathArray = l_map.mapFlagArr as Array;
			Data.mapDataVO.mapW = int(l_map.mapW);
			Data.mapDataVO.mapH = int(l_map.mapH);
			Data.mapDataVO.mapGridW = int(l_map.mapGridW);
			Data.mapDataVO.mapGridH = int(l_map.mapGridH);
			Data.divideBlockW = int(l_map.divideBlockW);
			Data.divideBlockH = int(l_map.divideBlockH);
			
			drawGrid(sv, Data.mapDataVO.mapW, Data.mapDataVO.mapH, Data.mapDataVO.mapGridW, Data.mapDataVO.mapGridH, true);
		}
		/**
		 * 获取鼠标点处的网格处的数据
		 * @param mX 鼠标X坐标
		 * @param mY 鼠标Y坐标
		 * @param gridW 网格宽
		 * @param gridH 网格高
		 * @return 当前风格数据
		 * 
		 */		
		public function getTileVO(mX:Number,mY:Number,vo:MapDataVO):MapTileVO{
			var tempY:int = mY;
			if(Data.leftBottomOriginFlag){
				tempY = vo.mapH - mY;
			}
			var col:int = mX / vo.mapGridW;
			var row:int = tempY / vo.mapGridH;
			var tileVO:MapTileVO = mapTileArray.get(col,row) as MapTileVO;
			return tileVO;
		}
		private var color1:uint = 0x000000;
		private var color2:uint = 0xffff00;
		private var col:uint;
		public function markTile(vo:MapTileVO):void{
			if(!Data.markPathFlag){
				return;
			}
			var col:int = vo.tileLocArr[0];
			var row:int = vo.tileLocArr[1];
			if(vo.tileState == MapTileVO.block_flag && Data.unCancelFlag){
				return;
			}
			if(!Data.unCancelFlag){
				vo.tileState = MapTileVO.CROSS_FLAG;
			}else{
				if(Data.overrideFlag){
					vo.tileState = MapTileVO.block_flag;
				}else{
					if(vo.tileState == MapTileVO.CROSS_FLAG){
						vo.tileState = MapTileVO.block_flag;
					}
				}
			}
			vo.tileColor = getTileColor(vo.tileState);
			if(vo.tileState == MapTileVO.CROSS_FLAG){
				drawTempUnSelectedShap(vo);
			}else{
				drawTempSelectedShap(vo);
			}
		}
		private function drawTempSelectedShap(vo:MapTileVO):void{
			var showX:int = vo.tileShowPos[0];
			var showY:int = vo.tileShowPos[1];
			//col = MapTileVO.block_flag/100*color2+color1;
			tempShape.graphics.beginFill(vo.tileColor,0.8);
			tempShape.graphics.drawRect(showX,showY,vo.tileW,vo.tileH);
			tempShape.graphics.endFill();
		}
		private function drawTempUnSelectedShap(vo:MapTileVO):void{
			var showX:int = vo.tileShowPos[0];
			var showY:int = vo.tileShowPos[1];
			tempShape.graphics.beginFill(tileShapColor,0.8);
			tempShape.graphics.drawRect(showX,showY,vo.tileW,vo.tileH);
			tempShape.graphics.endFill();
		}
		private function drawSelectedShap(vo:MapTileVO):void{
			var showX:int = vo.tileShowPos[0];
			var showY:int = vo.tileShowPos[1];
			//col = MapTileVO.block_flag/100*color2+color1;
			tilesShape.graphics.beginFill(vo.tileColor,0.8);
			tilesShape.graphics.drawRect(showX,showY,vo.tileW,vo.tileH);
			tilesShape.graphics.endFill();
		}
		private function drawUnSelectedShap(vo:MapTileVO):void{
			var showX:int = vo.tileShowPos[0];
			var showY:int = vo.tileShowPos[1];
			tilesShape.graphics.beginFill(tileShapColor,0.1);
			tilesShape.graphics.drawRect(showX,showY,vo.tileW,vo.tileH);
			tilesShape.graphics.endFill();
		}
		private function getTileColor(flag:Number):uint{
			return flag/100*color2+color1;
		}
		public function resetTileShape():void{
			tilesShape.graphics.clear();
			tempShape.graphics.clear();
			for(var i:int=0;i<mapTileArray.width;i++){
				for(var j:int=0;j<mapTileArray.height;j++){
					var vo:MapTileVO = MapTileVO(mapTileArray.get(i,j));
					if(vo.tileState == MapTileVO.CROSS_FLAG){
						drawUnSelectedShap(vo);
					}else{
						drawSelectedShap(vo);
					}
				}
			}
		}
		
		public function clearPenShape():void{
			penShape.graphics.clear();
		}
		private var tempMapTileVO:MapTileVO = new MapTileVO();
		public function movePenShape(mX:Number,mY:Number):void{
			var vo:MapTileVO = getTileVO(mX,mY,Data.mapDataVO);
			if(tempMapTileVO == vo){
				return;
			}else{
				tempMapTileVO = vo;
			}
			if(!vo){
				return;
			}
			var penX:int = vo.tileShowPos[0] - (int(Data.penWeight/2) * Data.mapDataVO.mapGridW);
			var penY:int = vo.tileShowPos[1] - (int(Data.penWeight/2) * Data.mapDataVO.mapGridH);
			
			penShape.graphics.clear();
			penShape.graphics.beginFill(getTileColor(MapTileVO.block_flag),0.6);
			penShape.graphics.drawRect(penX,penY,Data.mapDataVO.mapGridW*Data.penWeight,Data.mapDataVO.mapGridH*Data.penWeight);
			penShape.graphics.endFill();
		}
	}
}