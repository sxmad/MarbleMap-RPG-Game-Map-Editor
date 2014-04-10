import controller.factory.DrawMapGrid;
import controller.utils.XTools;

import events.Msg;
import events.RemoveItemEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.LocalConnection;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import model.Data;
import model.vo.ItemDataVO;
import model.vo.MapDataVO;
import model.vo.MapTileVO;
import model.vo.PenWeightVO;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Image;
import mx.core.FlexGlobals;
import mx.events.DragEvent;
import mx.graphics.codec.IImageEncoder;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.managers.DragManager;

import spark.components.ComboBox;
import spark.components.Group;

import view.ItemInMap;

[Bindable]private var penCmbDP:ArrayCollection = new ArrayCollection();
private var _loader:Loader;

private function _init():void{
	Alert.okLabel = Data.INFO_OK_LABEL;
	_initLoader();
	_initTitleWindow();
	_initEvent();
	_initPos();
	_initPenWeight();
}
private function _initLoader():void{
	_loader = new Loader();
	bg.addChild(_loader);
}
private function _initPenWeight():void{
	penCmbDP.removeAll();
	for(var i:int=1;i<=PenWeightVO.PEN_COUNT;i++){
		var vo:PenWeightVO = new PenWeightVO();
		vo.penWeight = PenWeightVO["PEN_WEIGHT_"+i];
		penCmbDP.addItem(vo);
	}
	penConfigCbx.selectedItem = penCmbDP.getItemAt(0);
}
private function _initEvent():void{
	newMapView.addEventListener(Msg.NEW_MAP,_newMapHandler);
	divideView.addEventListener(Msg.DIVIDE_BLOCK,_divideBlockHandler);
	divideView.addEventListener(Msg.DIVIDE_PREVIEW,_dividePreviewHandler);
	mapGroup.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,mapBgDragStart);
	mapGroup.addEventListener(MouseEvent.RIGHT_MOUSE_UP,mapBgDragStop);
	addItemView.addEventListener(Msg.LAYER_EVENT,_layerEventHandler);
	addItemView.addEventListener(Msg.SET_ITEM_EVENT,_setItemEventHandler);
	addItemView.addEventListener(Msg.IMPORT_ITEMS,_onImportItems);
	this.addEventListener(RemoveItemEvent.REMOVE_ITEM_EVENT,_removeItemEventHandler);
	this.addEventListener(RemoveItemEvent.REMOVE_ALL_ITEMS_EVENT,_removeAllItemEventHandler);
	
	//gridContainer.addEventListener(MouseEvent.CLICK,gridClickHandler);
	gridContainer.addEventListener(MouseEvent.MOUSE_MOVE,gridMoveHandler);
	gridContainer.addEventListener(MouseEvent.MOUSE_OUT,gridOutHandler);
	gridContainer.addEventListener(MouseEvent.MOUSE_DOWN,gridDownHandler);
	gridContainer.addEventListener(MouseEvent.MOUSE_UP,gridUpHandler);
}
private function gridClickHandler(e:MouseEvent):void{
	
}
private function gridDownHandler(e:MouseEvent):void{
	MapTileVO.isMouseDown = true;
	_penGroupHandler();
}
private function gridMoveHandler(e:MouseEvent):void{
	if(MapTileVO.isMouseDown){
		_penGroupHandler();
	}else{
		DrawMapGrid.getInstance().movePenShape(gridContainer.mouseX,gridContainer.mouseY);
	}
}
private function gridOutHandler(e:MouseEvent):void{
	DrawMapGrid.getInstance().clearPenShape();
	gridUpHandler();
}
private function gridUpHandler(e:MouseEvent=null):void{
	MapTileVO.isMouseDown = false;
	_changePathFlag();
	DrawMapGrid.getInstance().resetTileShape();
}

private function _initPos():void{
	controlPanelWindow.x = (this.width - controlPanelWindow.width)/2;
	newMapView.x = (this.width - newMapView.width)/2;
	newMapView.y = controlPanelWindow.height;
	divideView.x = (this.width - divideView.width)/2;
	divideView.y = controlPanelWindow.height;
	addItemView.x = this.width - addItemView.width;
	addItemView.y = controlPanelWindow.height;
	pathWindow.x = (this.width - pathWindow.width)/2;
	pathWindow.y = controlPanelWindow.height;
	audioView.x = this.width - audioView.width;
	audioView.y = controlPanelWindow.height;
}
private function _initTitleWindow():void{
	controlPanelWindow.isPopUp = true;
	newMapView.isPopUp = true;
	divideView.isPopUp = true;
	addItemView.isPopUp = true;
	pathWindow.isPopUp = true;
	audioView.isPopUp = true;
}
private function mapBgDragStart(e:MouseEvent):void{
	mapGroup.startDrag();
}
private function mapBgDragStop(e:MouseEvent):void{
	mapGroup.stopDrag();
}
private function _newMap():void{
	newMapView.visible = !newMapView.visible;
}
private function _loadMap():void{
	var fileToOpen:File = new File();
	fileToOpen = File.applicationDirectory;
	var txtFilter:FileFilter = new FileFilter("地图文件", "*.txt;*.json");
	try 
	{
		fileToOpen.browseForOpen("Load MapPath", [txtFilter]);
		fileToOpen.addEventListener(Event.SELECT, _mapPathFileSelected);
	}catch (error:Error){
		trace("Failed:", error.message);
	}
}
private function _mapPathFileSelected(event:Event):void 
{
	//重置标记类型
	pathFlagTypeTxt.text = "1";
	
	var stream:FileStream = new FileStream();
	var pathFile:File = event.target as File;
	stream.open(pathFile, FileMode.READ);
	var fileData:String = stream.readMultiByte(stream.bytesAvailable,"GBK");
	DrawMapGrid.getInstance().loadMapPath(gridContainer,fileData);
}
private function _divideMap():void{
	divideView.visible = !divideView.visible;
}
private function _pathOp():void{
	pathWindow.visible = !pathWindow.visible;
}
private function _clearPath():void{
	DrawMapGrid.getInstance().clearMapPath();
}
private function _saveMap():void{
	_saveMapPatchHandler();
}

private function _saveMapPatchHandler():void{
	var mapsDir:File = new File();
	mapsDir = File.applicationDirectory;
	try
	{
		mapsDir.browseForSave("保存地图信息");
		mapsDir.addEventListener(Event.SELECT, _saveData);
	}catch (error:Error){
		trace("操作失败:", error.message);
	}
}
private function _saveData(event:Event):void 
{
	var newFile:File = event.target as File;
	var str:String = DrawMapGrid.getInstance().generateMapArray();
	var stream:FileStream = new FileStream();
	//write模式存在就替换
	stream.open(newFile, FileMode.WRITE);
	
	stream.writeUTFBytes(str);
	stream.close();
}
private function _showGridHandler():void{
	gridContainer.visible = showGridCheckBox.selected;
}
private function _markPathHandler():void{
	Data.markPathFlag = markPathCheckBox.selected;
}
private function _overrideFlagHandler():void{
	Data.overrideFlag = overrideFlagCheckBox.selected;
}
private function _flagPathHandler():void{
	Data.unCancelFlag = flagPathCheckBox.selected;
	if(!Data.unCancelFlag){
		MapTileVO.block_flag = MapTileVO.CROSS_FLAG;
	}else{
		_changePathFlag();
	}
}
private function _changePathFlag():void{
	if(pathFlagTypeTxt.text.length==0 || pathFlagTypeTxt.text == "0"){
		pathFlagTypeTxt.text = "1";
	}
	MapTileVO.block_flag = Number(pathFlagTypeTxt.text);
}
private function _newMapHandler(e:Msg):void{
	_loader.load(new URLRequest(Data.mapDataVO.mapBgPath));
	_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,_mapBgLoaded);
	//_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,_progressHandler);
	
}
private function _progressHandler(e:ProgressEvent):void{
	trace(e.bytesLoaded/e.bytesTotal+" -- "+e.bytesLoaded+":"+e.bytesTotal);
}
private function _mapBgLoaded(e:Event):void{
	_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,_mapBgLoaded);
	Data.mapDataVO.mapW = _loader.width;
	Data.mapDataVO.mapH = _loader.height;
	DrawMapGrid.getInstance().drawGrid(
		gridContainer,
		Data.mapDataVO.mapW,Data.mapDataVO.mapH,
		Data.mapDataVO.mapGridW,Data.mapDataVO.mapGridH
	);
}

private function _dividePreviewHandler(e:Msg):void{
	if(!Data.dividePreViewFlag){
		DrawMapGrid.getInstance().clearDivedeGrid();
		return;
	}
	DrawMapGrid.getInstance().drawDivideGrid(
		divideGridView.divideGridContainer,
		Data.mapDataVO.mapW,Data.mapDataVO.mapH,
		Data.divideBlockW,Data.divideBlockH
	);
}
private function _divideBlockHandler(e:Msg):void{
	if(!divedeFs){
		divedeFs = new FileStream();
	}
	
	var l_rows:int = Math.ceil(Data.mapDataVO.mapH/Data.divideBlockH);
	var l_cols:int = Math.ceil(Data.mapDataVO.mapW/Data.divideBlockW);
	for(var i:int = 0;i<l_rows;i++){
		for(var j:int = 0;j<l_cols;j++){
			var l_divideBmd:BitmapData;
			var l_tempW:int = Data.divideBlockW;
			var l_tempH:int = Data.divideBlockH;
			var l_tempX:Number = j*Data.divideBlockW;
			var l_tempY:Number;
			var l_mat:Matrix;
			var l_rect:Rectangle;
			if(i == l_rows - 1){
				l_tempH = Data.mapDataVO.mapH - i*Data.divideBlockH;
			}
			if(j == l_cols - 1){
				l_tempW = Data.mapDataVO.mapW - j*Data.divideBlockW;
			}
			
			if(Data.leftBottomOriginFlag){
				l_tempY = Data.mapDataVO.mapH - i*Data.divideBlockH - l_tempH;
			}else{
				l_tempY = i*Data.divideBlockH;
			}
			l_mat = new Matrix(1,0,0,1,-l_tempX,-l_tempY);
			l_rect = new Rectangle(l_tempX,l_tempY,l_tempW,l_tempH);
			l_divideBmd = new BitmapData(l_tempW,l_tempH,true,0x0000);
			//===================
//			l_divideBmd.draw(Bitmap(_loader.content).bitmapData,l_mat,null,null,null,true);
//			l_divideBmd.draw(l_divideBmd,null,null,null,l_rect,true);
			//====================
			l_divideBmd.copyPixels(Bitmap(_loader.content).bitmapData,l_rect,new Point(0,0));
			//====================
			var l_encoder:IImageEncoder = new JPEGEncoder(100.0);
			var l_ba:ByteArray	= l_encoder.encode(l_divideBmd);
			var l_divide_file:File = new File(Data.divideBlockPath+"//"+Data.divideBlockPreName+"_"+i+"_"+j+".jpg");
			divedeFs.open(l_divide_file,FileMode.WRITE);
			divedeFs.writeBytes(l_ba,0,l_ba.length);
			divedeFs.close();
			trace(l_divide_file.url);
		}
	}
}
private var divedeFs:FileStream;
private function _addItem():void{
	addItemView.visible = !addItemView.visible;
}
private var _itemInMap:ItemInMap;

private function _onImportItems(e:Msg):void{
	var len:int = Data.importItemAc.length;
	for(var i:int=0;i<len;i++){
		var vo:ItemDataVO = Data.importItemAc.getItemAt(i) as ItemDataVO;
		_itemInMap = new ItemInMap();
		_itemInMap.itemDataVO = vo;
		itemGroup.addElement(_itemInMap);
		_itemInMap.layerIndex = itemGroup.getElementIndex(_itemInMap);
		
		var tempY:int;
		if(Data.leftBottomOriginFlag){
			tempY = Data.mapDataVO.mapH - Data.ITEM_IMPORT_IMG_H - vo.itemPosY;
		}else{
			tempY = vo.itemPosY;
		}
		_itemInMap.x = vo.itemPosX;
		_itemInMap.y = tempY;
		
		_itemInMap.removeItemImg.width = Data.ITEM_IMPORT_IMG_W;
		_itemInMap.removeItemImg.height = Data.ITEM_IMPORT_IMG_H;
		
		_itemInMap.itemRadioButton.width = Data.ITEM_IMPORT_IMG_W/2;
		_itemInMap.itemRadioButton.height = Data.ITEM_IMPORT_IMG_H/2;
		_itemInMap.itemRadioButton.x = (Data.ITEM_IMPORT_IMG_W - _itemInMap.itemRadioButton.width)/2;
		_itemInMap.itemRadioButton.y = (Data.ITEM_IMPORT_IMG_H - _itemInMap.itemRadioButton.height)/2;
		_itemInMap.itemRadioButton.selected = true;
		
		_itemInMap.regImg.x = 
			XTools.getInstance().getItemRegPosX(
				Data.ITEM_IMPORT_IMG_W,
				_itemInMap.regImg.width,
				_itemInMap.itemDataVO.itemRegPosX);
		
		_itemInMap.regImg.y = 
			XTools.getInstance().getItemRegPosY(
				Data.ITEM_IMPORT_IMG_H,
				_itemInMap.regImg.height,
				_itemInMap.itemDataVO.itemRegPosY,
				Data.leftBottomOriginFlag);
		
		_itemInMap.itemDataVO.itemFilePath = Data.ITEM_IMPORT_IMG;
		_itemInMap.itemDataVO.itemId = XTools.getInstance().getUniquelyId();
		
		//添加到“已添加物品”列表
		Data.addedItemAc.addItem(_itemInMap);
		Data.maxLayerIndex = Data.addedItemAc.length - 1;
	}
	Data.currentItemInMap = _itemInMap;
}

//物品拖放到场景中
private function _onItemDrop(e:DragEvent):void{
	var vo:ItemDataVO = e.dragSource.dataForFormat(Data.ITEM_FORMAT) as ItemDataVO;
	_itemInMap = new ItemInMap();
	_itemInMap.itemDataVO = new ItemDataVO();
	var tempItemType:int = 0;
	var tempItemSN:int = 0;
	if(addItemView.itemTypeTxt.text.length != 0){
		tempItemType = int(addItemView.itemTypeTxt.text);
	}
	if(addItemView.itemSNTxt.text.length != 0){
		tempItemSN = int(addItemView.itemSNTxt.text);
	}
	_itemInMap.itemDataVO.itemType = tempItemType;
	_itemInMap.itemDataVO.itemSN = tempItemSN;
	_itemInMap.itemDataVO.itemFileName = vo.itemFileName;
	_itemInMap.itemDataVO.itemFilePath = vo.itemFilePath;
	itemGroup.addElement(_itemInMap);
	_itemInMap.layerIndex = itemGroup.getElementIndex(_itemInMap);
	_itemInMap.itemImg.addEventListener(Event.COMPLETE,itemImgLoaded);
}
//成功加载物品图片文件
private function itemImgLoaded(e:Event):void{
	_itemInMap.itemImg.removeEventListener(Event.COMPLETE,itemImgLoaded);
	_itemInMap.x = itemGroup.mouseX-_itemInMap.itemImg.bitmapData.width/2;
	_itemInMap.y = itemGroup.mouseY-_itemInMap.itemImg.bitmapData.height/2;
	
	_itemInMap.removeItemImg.width = _itemInMap.itemImg.bitmapData.width;
	_itemInMap.removeItemImg.height = _itemInMap.itemImg.bitmapData.height;
	
	_itemInMap.itemRadioButton.width = _itemInMap.itemImg.bitmapData.width/2;
	_itemInMap.itemRadioButton.height = _itemInMap.itemImg.bitmapData.height/2;
	_itemInMap.itemRadioButton.x = (_itemInMap.itemImg.bitmapData.width - _itemInMap.itemRadioButton.width)/2;
	_itemInMap.itemRadioButton.y = (_itemInMap.itemImg.bitmapData.height - _itemInMap.itemRadioButton.height)/2;
	_itemInMap.itemRadioButton.selected = true;
	
	var tempY:int;
	var tempRegY:int;
	if(Data.leftBottomOriginFlag){
		tempY = Data.mapDataVO.mapH - _itemInMap.itemImg.bitmapData.height - _itemInMap.y;
	}else{
		tempY = _itemInMap.y;
	}
	
	_itemInMap.itemDataVO.itemPosX = _itemInMap.x;
	_itemInMap.itemDataVO.itemPosY = tempY;
	
	
	_itemInMap.regImg.x = 
		XTools.getInstance().getItemRegPosX(
			_itemInMap.itemImg.bitmapData.width,
			_itemInMap.regImg.width,
			_itemInMap.itemDataVO.itemRegPosX);
	
	_itemInMap.regImg.y = 
		XTools.getInstance().getItemRegPosY(
			_itemInMap.itemImg.bitmapData.height,
			_itemInMap.regImg.height,
			_itemInMap.itemDataVO.itemRegPosY,
			Data.leftBottomOriginFlag);
	
	
	_itemInMap.itemDataVO.itemId = XTools.getInstance().getUniquelyId();
	
	Data.currentItemInMap = _itemInMap;
	//添加到“已添加物品”列表
	Data.addedItemAc.addItem(_itemInMap);
	Data.maxLayerIndex = Data.addedItemAc.length - 1;
}
private function _onItemDragEnter(e:DragEvent):void{
	if(e.dragSource.hasFormat(Data.ITEM_FORMAT)){
		DragManager.acceptDragDrop(Group(e.target));
	}
}
//设置层级关系
private function _layerEventHandler(e:Msg):void{
	var changeLayerType:int = int(e.o);
	var len:int = Data.addedItemAc.length;
	for(var i:int=0;i<len;i++){
		var item:ItemInMap = Data.addedItemAc.getItemAt(i) as ItemInMap;
		if(item.itemDataVO.itemId == Data.currentItemInMap.itemDataVO.itemId){
			if(changeLayerType == Msg.LAYER_UP){
				if(item.layerIndex<Data.maxLayerIndex){
					(Data.addedItemAc.getItemAt(i) as ItemInMap).layerIndex += 1;
					itemGroup.setElementIndex((Data.addedItemAc.getItemAt(i) as ItemInMap),(Data.addedItemAc.getItemAt(i) as ItemInMap).layerIndex);
					(Data.addedItemAc.getItemAt(i+1) as ItemInMap).layerIndex -= 1;
					itemGroup.setElementIndex((Data.addedItemAc.getItemAt(i+1) as ItemInMap),(Data.addedItemAc.getItemAt(i+1) as ItemInMap).layerIndex);
					//交换i和i+1数据
					var tempItem_1:ItemInMap = new ItemInMap();
					tempItem_1 = Data.addedItemAc.getItemAt(i) as ItemInMap;
					Data.addedItemAc.setItemAt(Data.addedItemAc.getItemAt(i+1),i);
					Data.addedItemAc.setItemAt(tempItem_1,i+1);
					break;
				}
			}else if(changeLayerType == Msg.LAYER_DOWN){
				if(item.layerIndex > 0){
					(Data.addedItemAc.getItemAt(i) as ItemInMap).layerIndex -= 1;
					itemGroup.setElementIndex((Data.addedItemAc.getItemAt(i) as ItemInMap),(Data.addedItemAc.getItemAt(i) as ItemInMap).layerIndex);
					(Data.addedItemAc.getItemAt(i-1) as ItemInMap).layerIndex += 1;
					itemGroup.setElementIndex((Data.addedItemAc.getItemAt(i-1) as ItemInMap),(Data.addedItemAc.getItemAt(i-1) as ItemInMap).layerIndex);
					//交换i和i-1数据
					var tempItem_2:ItemInMap = new ItemInMap();
					tempItem_2 = Data.addedItemAc.getItemAt(i) as ItemInMap;
					Data.addedItemAc.setItemAt(Data.addedItemAc.getItemAt(i-1),i);
					Data.addedItemAc.setItemAt(tempItem_2,i-1);
					break;
				}
			}
		}
	}
}
private function _setItemEventHandler(e:Msg):void{
	var len:int = Data.addedItemAc.length;
	for(var i:int=0;i<len;i++){
		var vo:ItemDataVO = (Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO;
		if(vo.itemId == Data.currentItemInMap.itemDataVO.itemId){
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemType = Data.currentItemInMap.itemDataVO.itemType;
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemSN = Data.currentItemInMap.itemDataVO.itemSN;
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemPosX = Data.currentItemInMap.itemDataVO.itemPosX;
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemPosY = Data.currentItemInMap.itemDataVO.itemPosY;
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemRegPosX = Data.currentItemInMap.itemDataVO.itemRegPosX;
			(Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO.itemRegPosY = Data.currentItemInMap.itemDataVO.itemRegPosY;
			break;
		}
	}
}
private function _removeItemEventHandler(e:RemoveItemEvent):void{
	var len:int = Data.addedItemAc.length;
	for(var i:int=0;i<len;i++){
		var vo:ItemDataVO = (Data.addedItemAc.getItemAt(i) as ItemInMap).itemDataVO;
		if(vo.itemId == Data.currentItemInMap.itemDataVO.itemId){
			itemGroup.removeElement(Data.addedItemAc.getItemAt(i) as ItemInMap);
			Data.addedItemAc.removeItemAt(i);
			Data.currentItemInMap = null;
			break;
		}
	}
}
private function _removeAllItemEventHandler(e:RemoveItemEvent):void{
	itemGroup.removeAllElements();
	Data.addedItemAc.removeAll();
	Data.currentItemInMap = null;
}
private function _audioOp():void{
	audioView.visible = !audioView.visible;
}
private function _penConfigHandler(e:Event):void{
	var vo:PenWeightVO = ComboBox(e.currentTarget).selectedItem;
	Data.penWeight = vo.penWeight;
}
private function _penGroupHandler():void{
	DrawMapGrid.getInstance().clearPenShape();
	if(PenWeightVO.PEN_WEIGHT_1 == Data.penWeight){
		DrawMapGrid.getInstance().markTile(DrawMapGrid.getInstance().getTileVO(gridContainer.mouseX,gridContainer.mouseY,Data.mapDataVO));
		return;
	}
	var vo:MapTileVO = DrawMapGrid.getInstance().getTileVO(gridContainer.mouseX,gridContainer.mouseY,Data.mapDataVO);
	if(!vo){
		return;
	}
	var row:int = vo.tileLocArr[0];
	var col:int = vo.tileLocArr[1];
	var r:int = row - int(Data.penWeight / 2);
	var c:int = col - int(Data.penWeight / 2);
	
	for(var i:int = 0;i<Data.penWeight;i++){
		for(var j:int=0;j<Data.penWeight;j++){
			var tempR:int = r+i;
			var tempC:int = c+j;
			//超出范围不做处理。
			if(tempR < 0 || tempC < 0 || tempC > (DrawMapGrid.mapTileArray.height - 1) || tempR > (DrawMapGrid.mapTileArray.width - 1)){
				continue;
			}
			if(DrawMapGrid.mapTileArray.get(tempR,tempC)){
				DrawMapGrid.getInstance().markTile(MapTileVO(DrawMapGrid.mapTileArray.get(tempR,tempC)));
			}
		}
	}
}


