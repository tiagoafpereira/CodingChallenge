package
{
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import starling.display.Button;
	import starling.display.Image;
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

		/**
		 * TEXTURES
		 **/
		[Embed(source = "/assets/images/startButtonUp.png")]
		private static const StartButtonUpTex:Class;
		[Embed(source = "/assets/images/startButtonDisabled.png")]
		private static const StartButtonDisabledTex:Class;		
		private var startButton:Button = new Button(Texture.fromEmbeddedAsset(StartButtonUpTex), "", null, null, Texture.fromEmbeddedAsset(StartButtonDisabledTex));

		[Embed(source = "/assets/images/plus.png")]
		private static const PlusTexture:Class;			
		private var increaseBetButton:Button = new Button(Texture.fromEmbeddedAsset(PlusTexture));		

		[Embed(source = "/assets/images/tiki.jpg")]
		private static const MonkeyTexture:Class;			
		private var monkeyImage:Image = new Image(Texture.fromEmbeddedAsset(MonkeyTexture));		
		
		[Embed(source = "/assets/images/betButton.png")]
		private static const BetButtonTexture:Class;			
		private var betLabel:Image = new Image(Texture.fromEmbeddedAsset(BetButtonTexture));			

		[Embed(source = "/assets/images/win.png")]
		private static const WinTexture:Class;			
		private var winLabel:Image = new Image(Texture.fromEmbeddedAsset(WinTexture));		
		
		[Embed(source = "/assets/images/background.png")]
		private static const BackgroundTex:Class;			
		private var backgroundImage:Image = new Image(Texture.fromEmbeddedAsset(BackgroundTex));		
		
		[Embed(source="/assets/images/monkey.xml", mimeType="application/octet-stream")]
		public static const AtlasXml:Class;
		
		[Embed(source="/assets/images/monkeySpriteSheet.png")]
		public static const AtlasTexture:Class;		
		
		private var _texture:Texture 	= Texture.fromEmbeddedAsset(AtlasTexture);
		private var _xml:XML 			= XML(new AtlasXml());
		private var _atlas:TextureAtlas = new TextureAtlas(_texture, _xml);		
		
		[Embed(source="/assets/sounds/coinDrop.mp3")]
		private static var CoinDropSound:Class;
		private var _coinDropSound:Sound = new CoinDropSound(); 
		
		/**
		 * TILE REFERENCE
		 **/
		private var _tilesDict:Dictionary = new Dictionary(true);
		private var _validTiles:Array 	  = new Array();
		
		/**
		 * PLAY RESULTS
		 **/
		private var _playResult:Array 			= new Array();
		private var _validSectionOverlay:Sprite = new Sprite();
		
		/**
		 * NUMBERS
		 **/
		private var _allowedBets:Array 			= [1, 2, 5, 10, 50, 100];
		private var _currentBetIndex:Number 	= 0;
		private var _startingMoney:Number 		= 1000;
		private var _currentBet:Number 			= 1;
		private var _winMoney:Number 			= 0;
		private var _currentSpinProfit:Number 	= 0;
		private var _finishedTilesCount:Number 	= 0;
		private var _betMultiplier:Number 		= 0;
		
		/**
		 * TEXT FIELDS
		 **/
		private var startingMoneyTextField:TextField;
		private var betTextField:TextField;
		private var winTextField:TextField;
		
		/**
		 * CONSTS
		 **/
		private const SIZE:Number 				= 6;
		private const TILE_SIZE:Number 			= 50;
		private const TILES_X:Number 			= 100;
		private const TILES_Y:Number 			= 175;
		
		/**
		 * TEST MODE
		 * When enabled it repeats play indefinitely, useful for checking results
		 **/
		private const TEST_MODE:Boolean 		= false;
		private const MAX_STOP_DELAY:Number 	= 1000;
		private var _waitTestTimer:Timer 		= new Timer(500, 1);
		
		public function Game()
		{
			
			addChild(backgroundImage);
			
			//TILES
			for(var row:Number = 0; row < SIZE; row++){
				for(var col:Number = 0; col < SIZE; col++){
					var tile:Tile 				= new Tile(_atlas, row+"-"+col, MAX_STOP_DELAY);
					tile.width 					= TILE_SIZE;
					tile.height 				= TILE_SIZE;
					tile.x 						= col*tile.width+TILES_X;
					tile.y 						= row*tile.height+TILES_Y;
					addChild(tile);
					_tilesDict[tile.tileName] 	= tile;
					tile.addEventListener(Tile.FINISHED, handleFinishedTileEvent);
				}
			}
			
			//TEXT
			startingMoneyTextField 			= new TextField(200, 30, _startingMoney.toString(), "Verdana", 12, 0xFF9900);
			startingMoneyTextField.hAlign 	= HAlign.LEFT;
			startingMoneyTextField.vAlign 	= VAlign.CENTER;
			startingMoneyTextField.x 		= 10;
			startingMoneyTextField.y 		= TILES_Y+SIZE*TILE_SIZE+5;
			addChild(startingMoneyTextField);
			
			betTextField 					= new TextField(50, 30, _currentBet.toString(), "Verdana", 20, 0xFF9900);
			betTextField.hAlign 			= HAlign.LEFT;
			betTextField.vAlign 			= VAlign.CENTER;
			betTextField.x 					= TILES_X-10;
			betTextField.y 					= TILES_Y+SIZE*TILE_SIZE+45;
			addChild(betTextField);

			betLabel.x 						= betTextField.x-betLabel.width-2;
			betLabel.y 						= betTextField.y-(Math.abs(betTextField.height-betLabel.height)/2);
			addChild(betLabel);

			//INCREASE BET BUTTON
			increaseBetButton.addEventListener(TouchEvent.TOUCH, handleTouchEvent);
			increaseBetButton.x 			= betTextField.x+betTextField.width+5;
			increaseBetButton.y 			= betTextField.y+(betTextField.height-increaseBetButton.height)/2;
			addChild(increaseBetButton);
			
			winTextField					= new TextField(120, 30, _winMoney.toString(), "Verdana", 20, 0xFF9900);
			winTextField.hAlign 			= HAlign.LEFT;
			winTextField.vAlign 			= VAlign.CENTER;
			winTextField.x 					= betTextField.x+betTextField.width+200;
			winTextField.y 					= TILES_Y+SIZE*TILE_SIZE+45;
			addChild(winTextField);

			winLabel.x 						= winTextField.x-winLabel.width-2;
			winLabel.y 						= winTextField.y-(Math.abs(winTextField.height-winLabel.height)/2);
			addChild(winLabel);	

			//SPIN BUTTON
			startButton.addEventListener(TouchEvent.TOUCH, handleTouchEvent);
			startButton.x 					= winTextField.x+winTextField.width-50;
			startButton.y 					= winTextField.y-winTextField.height/2;
			addChild(startButton);			
			
			//ORIGINAL IMAGE
			monkeyImage.x 					= TILES_X;
			monkeyImage.y 					= TILES_Y;
			monkeyImage.width 				= SIZE*TILE_SIZE;
			monkeyImage.height 				= SIZE*TILE_SIZE;
			addChild(monkeyImage);
			
			//TESTS
			_waitTestTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleWaitTestTimerEvent);
			
		}
		
		private function onSoundLoaded(event:Event):void{
			_coinDropSound = event.target as Sound;
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
			
			//goodbye monkey
			monkeyImage.alpha = 0;
			
			//reset counters
			_finishedTilesCount = 0;
			
			//prepare play
			var validSection:Rectangle = generatePlay();				
			
			_currentSpinProfit = 0;
			
			if(validSection.width*validSection.height == 0){
				_startingMoney -= _currentBet;
				winTextField.text = _currentSpinProfit.toString();

			}
			
			for each(var tile:Tile in _tilesDict){
				tile.start();
			}			
			
		}
		
		//Called when a tile is done shuffling
		private function handleFinishedTileEvent(event:Event):void{
			
			var _matchColor:uint;
			
			_finishedTilesCount++;
			
			//valid tiles
			if(event.data[1] == true){
				
				_coinDropSound.play();
				
				_validTiles.push(event.target);
				
				_currentSpinProfit 	+= _currentBet;
				_winMoney 			+= _currentSpinProfit;
				_startingMoney 		+= _currentSpinProfit;					
				
			}
			
			winTextField.text 			= _currentSpinProfit.toString();
			startingMoneyTextField.text = _startingMoney.toString();			
			
			if(_finishedTilesCount == SIZE*SIZE){
				
				//got all the tiles!
				if(_betMultiplier > 1)
					_currentSpinProfit *= _betMultiplier;		

				winTextField.text 			= _currentSpinProfit.toString();
				startingMoneyTextField.text = _startingMoney.toString();				
				
				//show the multiplier color
				for each(var tile:Tile in _validTiles){
					tile.betMultiplier = _betMultiplier;
				}
				
				startButton.enabled 		= true;
				
				_validTiles = new Array();
				
				if(TEST_MODE)
					_waitTestTimer.start();
				
			}	
			
		}
		
		//for testing purposes
		private function handleWaitTestTimerEvent(event:TimerEvent):void{
			spin();
		}
		
		private function increaseBet():void{
			
			_currentBetIndex++;
			
			if(_currentBetIndex > _allowedBets.length-1)
				_currentBetIndex = 0;
			
			_currentBet = _allowedBets[_currentBetIndex];
			
			betTextField.text = _currentBet.toString();
			
		}
		
		/**
		 * GENERATES A PLAY RESULT
		 * 
		 * 0 means an 'invalid' tile, it should display something other than the correct image
		 * > 1 is the bet multiplier
		 * 
		 * e.g.
		 * 
		 * [[0,0,0,0,0,0],
		 * [0,0,0,0,0,0],
		 * [0,1,1,0,0,0],
		 * [0,1,1,0,0,0],
		 * [0,1,1,0,0,0],
		 * [0,0,0,0,0,0]]
		 * 
		 */
		private function generatePlay():Rectangle{
			
			var validSection:Rectangle 	= new Rectangle(0,0,0,0);
			var randRow:Number 			= 0;
			var randCol:Number 			= 0;
			var randWidth:Number 		= 0;
			var randHeight:Number 		= 0;
			
			_betMultiplier 				= 0;
			
			//zeroes
			for(var row:Number = 0; row < SIZE; row++){
				_playResult[row] = new Array();
				for(var col:Number = 0; col < SIZE; col++){
					_playResult[row][col] = 0;
				}
			}
			
			//LUCKY TIME!
			if(Math.random() > 0.85){
				
				if(Math.random() > 0.75){
					
					//MAKE A LINE
					randRow 		= Math.floor(Math.random()*SIZE);
					randCol			= 0;
					randWidth		= SIZE;
					randHeight		= 1;
					_betMultiplier 	= 2;
					
				}else if(Math.random() > 0.85){
					
					//MAKE A COLUMN
					randRow 		= 0;
					randCol			= Math.floor(Math.random()*SIZE);
					randWidth		= 1;
					randHeight		= SIZE;
					_betMultiplier 	= 3;					
				
				}else if(Math.random() > 0.95){

					//ALL! LUCKY MONKEY!
					randRow 		= 0;
					randCol			= 0;
					randWidth		= SIZE;
					randHeight		= SIZE;
					_betMultiplier 	= 4;						
					
				}else{
					
					//RANDOM RECT
					randRow 		= Math.floor(Math.random()*((SIZE-1)-2));
					randCol 		= Math.floor(Math.random()*((SIZE-1)-2));
					randWidth 		= Math.floor(Math.random()*((SIZE-1)-randCol));
					randHeight 		= Math.floor(Math.random()*((SIZE-1)-randRow));
					
					if(randWidth < 2)
						randWidth = 2;
					
					if(randHeight < 2)
						randHeight = 2;					
					
					_betMultiplier = 1;
				}
				
				validSection.x = randRow;
				validSection.y = randCol;
				validSection.width = randWidth;
				validSection.height = randHeight;
				
				for(row = randRow; row < SIZE; row++){
					if(row <= randRow+(randHeight-1)){
						for(col = randCol; col < SIZE; col++){
							if(col <= randCol+(randWidth-1)){
								_playResult[row][col] = _betMultiplier;
							}
						}
					}
				}
			}
			
			/**
			 * 
			 * Sets up each tile
			 * Notice that the _tilesDict is used as quick reference
			 * 
			 */
			for(row = 0; row < SIZE; row++){
				for(col = 0; col < SIZE; col++){
					(_tilesDict[row+"-"+col] as Tile).clear();
					(_tilesDict[row+"-"+col] as Tile).isValid 	= _playResult[row][col] > 0;
					(_tilesDict[row+"-"+col] as Tile).betValue 	= _currentBet;
				}
			}			
			
			//returns a rectangle with the valid area
			return validSection;
			
		}
		
	}
}