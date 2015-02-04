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
		private var _stopTimer:Timer = new Timer(MAX_STOP_DELAY);
		private var _validFrameNumber:Number;
		
		private const MAX_STOP_DELAY:Number = 2000;
		
		public var isValid:Boolean = false;
		
		public function Tile(textureAtlas:TextureAtlas, name:String)
		{
				
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			_textureAtlas = textureAtlas;
			_name = name;
			_validFrameNumber = Number(_name.split("-")[0])*6+Number(_name.split("-")[1]);
			
			//_currentTexture = _textureAtlas.getTexture(getRandomTexName+".jpeg");
			//_currentImage = new Image(_currentTexture);
			//addChild(_currentImage);

			// create movie clip
			_movie = new MovieClip(textureAtlas.getTextures());
			addChild(_movie);
			
			// control playback
			//_movie.play();
			
			//_movie.stop();
			
			// important: add movie to juggler
			Starling.juggler.add(_movie);
			//Starling.juggler.add(_movieTween);			
			
			_movie.pause();
			_movie.currentFrame = getRandomFrameNumer();
			
			_stopTimer.addEventListener(TimerEvent.TIMER, handleStopTimerEvent);
			
		}

		private function init():void{
			addEventListener((EnterFrameEvent.ENTER_FRAME), gameLoop);		
		}		
		
		public function get tileName():String{
			return _name;
		}
		
		public function start():void{
			_running = true;
			_stopTimer.delay = Math.floor(Math.random()*MAX_STOP_DELAY);
			_stopTimer.start();
		}
		
		public function stop():void{
			_running = false;
			_stopTimer.reset();
		}
		
		private function gameLoop(event:EnterFrameEvent):void{
			
			if(_running){
				_movie.currentFrame = getRandomFrameNumer();
				_movie.color = Color.WHITE;
			}else{
				if(isValid){
					_movie.currentFrame = _validFrameNumber;
					_movie.color = Color.RED;
				}
			}
			
		}
		
		private function handleStopTimerEvent(event:TimerEvent):void{
			stop();
		}
		
		private function getRandomTexName():String{
			return getRandomFrameNumer()+"-"+getRandomFrameNumer();
		}
		
		private function getRandomFrameNumer():Number{
			
			var randomFrameNumber:Number = Math.floor(Math.random()*_movie.numFrames);
			
			while(randomFrameNumber == _validFrameNumber){
				randomFrameNumber = Math.floor(Math.random()*_movie.numFrames);
			}
			
			return randomFrameNumber;
		}
		
	}
}