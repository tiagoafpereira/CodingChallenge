package
{
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.Color;
	
	public class Tile extends Sprite
	{
			
		private var _textureAtlas:TextureAtlas;
		private var _currentTexture:Texture;
		private var _currentImage:Image;
		private var _movie:MovieClip;
		private var _movieTween:Tween;
		
		private var _name:String = "";
		private var _running:Boolean = false;
		private var _stopTimer:Timer = new Timer(_stopDelay);
		private var _validFrameNumber:Number;
		private var _betMultiplier:Number = 1;
		private var _isValid:Boolean = false;
		private var _betValue:Number = 0;
		private var _matchColor:uint = Color.RED;
		
		private var _stopDelay:Number = 2000;
		
		public static const FINISHED:String = "finishedEvent";
		
		//ANIMATION
		private var _overlay:Image;
		private var _tween:Tween;
		private var _betValueTextField:TextField = new TextField(100, 100, getValue(), "Verdana", 50, 0xFFFFFF);
		
		public function Tile(textureAtlas:TextureAtlas, name:String, stopDelay:Number=2000)
		{
				
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			this.pivotX = this.width/2;
			this.pivotY = this.height/2;
			
			resetTween();
			
			_textureAtlas = textureAtlas;
			_name = name;
			_validFrameNumber = Number(_name.split("-")[0])*6+Number(_name.split("-")[1]);
			_stopDelay = stopDelay
			
			_movie = new MovieClip(textureAtlas.getTextures());
			addChild(_movie);
			
			Starling.juggler.add(_movie);
			
			_movie.pause();
			_movie.currentFrame = getRandomFrameNumber();
			
			_stopTimer.addEventListener(TimerEvent.TIMER, handleStopTimerEvent);
			
			//overlay sprite
/*			_overlay = new Image(Texture.fromEmbeddedAsset(CoinTex));
			_overlay.width = this.width/2;
			_overlay.height = this.height/2;
			_overlay.x = this.width/2-_overlay.width/2;
			_overlay.y = this.height/2-_overlay.height/2;
			_overlay.alpha = 0;
			addChild(_overlay);*/
			
			//bet value
			_betValueTextField.x = this.width/2-_betValueTextField.width/2;
			_betValueTextField.y = this.height/2-_betValueTextField.height/2;
			_betValueTextField.alpha = 0;
			addChild(_betValueTextField);	
			
		}

		private function init():void{
			addEventListener((EnterFrameEvent.ENTER_FRAME), gameLoop);		
		}		
		
		public function get tileName():String{
			return _name;
		}
		
		public function start():void{
			resetTween();
			_running = true;
			_betValueTextField.alpha = 0;
			_betValueTextField.text = "+"+getValue();
			_betMultiplier = 1;
			_matchColor = Color.RED;
			_stopTimer.delay = Math.floor(Math.random()*_stopDelay);
			_stopTimer.start();
		}
		
		public function stop():void{
			_running = false;
			_stopTimer.reset();
			if(isValid){
				_tween.animate("alpha", 1);
			}
			dispatchEventWith(FINISHED, false, [_name, isValid]);
		}
		
		public function set betMultiplier(value:Number):void{
			
			_betMultiplier = value;
			
			switch(betMultiplier){
				
				case 1:
					_matchColor = Color.RED;
					break;

				case 2:
					_matchColor = Color.BLUE;
					break;
				
				case 3:
					_matchColor = Color.GREEN;
					break;
				
				case 4:
					_matchColor = Color.FUCHSIA;
					break;				
				
			}
			
			_betValueTextField.text = "+"+getValue();
			
		}
		
		public function showColor(color:uint):void{
			_matchColor = color;
		}
		
		public function set betValue(value:Number):void{
			_betValue = value;
			_betValueTextField.text = "+"+getValue();
		}
		
		public function get betMultiplier():Number{
			return _betMultiplier;
		}
		
		public function get isValid():Boolean{
			return _isValid;
		}

		public function set isValid(value:Boolean):void{
			_isValid = value;
		}		
		
		private function getValue():String{
			return (_betValue*_betMultiplier).toString();
		}
		
		public function clear():void{
			_betValue = 1;
			_betMultiplier = 1;
			_betValueTextField.text = "+"+getValue();
		}
		
		private function resetTween():void{
			_tween = new Tween(_betValueTextField, 0.5, Transitions.EASE_OUT);
			_tween.repeatCount = 1;
			_tween.reverse = false;
			_tween.onComplete = handleTweenOnComplete;			
			Starling.juggler.add(_tween);
		}

		private function handleTweenOnComplete():void{
			resetTween(); 	
		}		
		
		private function gameLoop(event:EnterFrameEvent):void{
			
			if(_running){
				_movie.currentFrame = getRandomFrameNumber();
				_movie.color = Color.WHITE;
			}else{
				if(isValid){
					_movie.currentFrame = _validFrameNumber;
					_movie.color = _matchColor;
				}
			}
			
		}
		
		private function handleStopTimerEvent(event:TimerEvent):void{
			stop();
		}
		
		private function getRandomTexName():String{
			return getRandomFrameNumber()+"-"+getRandomFrameNumber();
		}
		
		private function getRandomFrameNumber():Number{
			
			var randomFrameNumber:Number = Math.floor(Math.random()*_movie.numFrames);
			
			while(randomFrameNumber == _validFrameNumber){
				randomFrameNumber = Math.floor(Math.random()*_movie.numFrames);
			}
			
			return randomFrameNumber;
		}
		
	}
}