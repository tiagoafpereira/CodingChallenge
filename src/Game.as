package
{
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Game extends Sprite
	{

		[Embed(source = "/assets/images/startButtonUp.png")]
		private static const StartButtonUpTex:Class;
		[Embed(source = "/assets/images/startButtonDisabled.png")]
		private static const StartButtonDisabledTex:Class;		
		private var startButton:Button = new Button(Texture.fromEmbeddedAsset(StartButtonUpTex), "", null, null, Texture.fromEmbeddedAsset(StartButtonDisabledTex));

		[Embed(source = "/assets/images/plus.png")]
		private static const PlusTexture:Class;			
		private var increaseBetButton:Button = new Button(Texture.fromEmbeddedAsset(PlusTexture));		
		
		// Embed the Atlas XML
		[Embed(source="/assets/images/stackEmAtlas.xml", mimeType="application/octet-stream")]
		public static const AtlasXml:Class;
		
		// Embed the Atlas Texture:
		[Embed(source="/assets/images/stackEmSpriteSheet.png")]
		public static const AtlasTexture:Class;		
		
		// create atlas
		private var _texture:Texture = Texture.fromEmbeddedAsset(AtlasTexture);
		private var _xml:XML = XML(new AtlasXml());
		private var _atlas:TextureAtlas = new TextureAtlas(_texture, _xml);		
		
		[Embed(source="/assets/sounds/coinDrop.mp3")]
		private var CoinDropSound:Class;
		private var _coindDropSound:Sound = new CoinDropSound(); 
		
		//tiles dict
		private var _tilesDict:Dictionary = new Dictionary(true);
		
		//play result
		private var _playResult:Array = new Array();
		private var _validSectionOverlay:Sprite = new Sprite();
		
		//numbers
		private var _allowedBets:Array = [1, 2, 5, 10, 50, 100];
		private var _currentBetIndex:Number = 0;
		private var _startingMoney:Number = 5000;
		private var _currentBet:Number = 1;
		private var _winMoney:Number = 0;
		private var _currentSpinProfit:Number = 0;
		private var _finishedTilesCount:Number = 0;
		
		private var startingMoneyTextField:TextField;
		private var betTextField:TextField;
		private var winTextField:TextField;
		
		private const SIZE:Number = 6;
		private const TILE_SIZE:Number = 50;
		private const TILES_X:Number = 10;
		private const TILES_Y:Number = 50;
		
		public function Game()
		{
			
			//TILES
			for(var row:Number = 0; row < SIZE; row++){
				for(var col:Number = 0; col < SIZE; col++){
					var tile:Tile = new Tile(_atlas, row+"-"+col);
					tile.width = TILE_SIZE;
					tile.height = TILE_SIZE;
					tile.x = col*tile.width+TILES_X;
					tile.y = row*tile.height+TILES_Y;
					addChild(tile);
					_tilesDict[tile.tileName] = tile;
					tile.addEventListener(Tile.FINISHED, handleFinishedTileEvent);
				}
			}
			
			//SPIN BUTTON
			startButton.addEventListener(TouchEvent.TOUCH, handleTouchEvent);
			startButton.width = 50;
			startButton.height = 50;
			startButton.x = this.width+20;
			startButton.y = this.height+20;
			addChild(startButton);
			
			//TEXT
			startingMoneyTextField = new TextField(200, 30, "Deposit: "+_startingMoney, "Verdana", 15, 0xFFFFFF);
			startingMoneyTextField.hAlign = HAlign.LEFT;
			startingMoneyTextField.vAlign = VAlign.CENTER;
			startingMoneyTextField.border = true;
			startingMoneyTextField.x = 0;
			startingMoneyTextField.y = 10;
			addChild(startingMoneyTextField);
			
			betTextField = new TextField(200, 30, "Bet: "+_currentBet, "Verdana", 12, 0xFFFFFF);
			betTextField.hAlign = HAlign.LEFT;
			betTextField.vAlign = VAlign.CENTER;
			betTextField.border = true;
			betTextField.x = 0;
			betTextField.y = SIZE*TILE_SIZE+50;
			addChild(betTextField);				

			winTextField = new TextField(200, 30, "Win: "+_winMoney, "Verdana", 12, 0xFFFFFF);
			winTextField.hAlign = HAlign.LEFT;
			winTextField.vAlign = VAlign.CENTER;
			winTextField.border = true;
			winTextField.x = betTextField.x+betTextField.width;
			winTextField.y = SIZE*TILE_SIZE+50;
			addChild(winTextField);

			//INCREASE BET BUTTON
			increaseBetButton.addEventListener(TouchEvent.TOUCH, handleTouchEvent);
			increaseBetButton.width = 20;
			increaseBetButton.height = 20;
			increaseBetButton.x = betTextField.x+betTextField.width-increaseBetButton.width-5;
			increaseBetButton.y = betTextField.y+(betTextField.height-increaseBetButton.height)/2;
			addChild(increaseBetButton);			
			
		}
		
		private function onSoundLoaded(event:Event):void{
			_coindDropSound = event.target as Sound;
		}
		
		private function handleTouchEvent(event:TouchEvent):void{
			
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);			
			
			if(touch != null){
				
				switch(event.target){
					
					case startButton:
						if(startButton.enabled){
							startButton.enabled = false;
							spin();							
						}
						break;
					
					case increaseBetButton:
						increaseBet();
						break;
					
				}

			}
		}
		
		private function spin():void{
			
			//reset counters
			_finishedTilesCount = 0;
			
			//prepare play
			var validSection:Rectangle = generatePlay();				
			
			if(validSection.width*validSection.height == 0){
				_startingMoney -= _currentBet;
				_currentSpinProfit = 0;
			}else{
				_currentSpinProfit = Math.floor((validSection.width/TILE_SIZE))*Math.floor((validSection.height/SIZE))*_currentBet;
				_winMoney += _currentSpinProfit;
				_startingMoney += _currentSpinProfit;					
			}
			
			for each(var tile:Tile in _tilesDict){
				tile.start();
			}			
			
		}
		
		private function handleFinishedTileEvent(event:Event):void{
			
			_finishedTilesCount++;
			
			if(event.data[1] == true)
				_coindDropSound.play();
			
			if(_finishedTilesCount == SIZE*SIZE){
				startButton.enabled = true;
				winTextField.text 			= "Win: "+_currentSpinProfit.toString();
				startingMoneyTextField.text = "Deposit: "+_startingMoney.toString();				
			}			
			
		}
		
		private function increaseBet():void{
			
			_currentBetIndex++;
			
			if(_currentBetIndex > _allowedBets.length-1)
				_currentBetIndex = 0;
			
			_currentBet = _allowedBets[_currentBetIndex];
			
			betTextField.text = "Bet: "+_currentBet;
			
		}
		
		private function generatePlay():Rectangle{
			
			var validSection:Rectangle = new Rectangle(0,0,0,0);
			
			//zeroes
			for(var row:Number = 0; row < SIZE; row++){
				_playResult[row] = new Array();
				for(var col:Number = 0; col < SIZE; col++){
					_playResult[row][col] = 0;
				}
			}
			
			//LUCKY TIME!
			if(Math.random() > 0.75){

				var randRow:Number 		= Math.floor(Math.random()*(SIZE-2));
				var randCol:Number 		= Math.floor(Math.random()*(SIZE-2));
				var randWidth:Number 	= Math.floor(Math.random()*(SIZE-randCol));
				var randHeight:Number 	= Math.floor(Math.random()*(SIZE-randRow));
				
				if(randWidth < 2)
					randWidth = 2;
				
				if(randHeight < 2)
					randHeight = 2;
				
				trace("randRow "+randRow);
				trace("randCol "+randCol);
				trace("randWidth "+randWidth);
				trace("randHeight "+randHeight);
				
				validSection.x = randRow;
				validSection.y = randCol;
				validSection.width = randWidth*TILE_SIZE;
				validSection.height = randHeight*TILE_SIZE;
				
				for(row = randRow; row < SIZE; row++){
					if(row <= randRow+randHeight){
						for(col = randCol; col < SIZE; col++){
							if(col <= randCol+randWidth){
								_playResult[row][col] = 1;
							}
						}
					}
				}
			
			}
				
			trace(_playResult);

			for(row = 0; row < SIZE; row++){
				for(col = 0; col < SIZE; col++){
					(_tilesDict[row+"-"+col] as Tile).isValid = _playResult[row][col] == 1;
				}
			}			
			
			return validSection;
			
		}
		
	}
}