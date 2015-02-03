package
{
	import flash.utils.Dictionary;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class Game extends Sprite
	{

		[Embed(source = "/assets/images/startButtonUp.png")]
		private static const startButtonUp:Class;			
		private var startButton:Button = new Button(Texture.fromEmbeddedAsset(startButtonUp));
		
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
		
		//tiles dict
		private var _tilesDict:Dictionary = new Dictionary(true);
		
		//play result
		private var playResult:Array = new Array();
		
		private const SIZE:Number = 6;
		
		public function Game()
		{
			
			//TILES
			for(var row:Number = 0; row < SIZE; row++){
				for(var col:Number = 0; col < SIZE; col++){
					var tile:Tile = new Tile(_atlas, row+"-"+col);
					tile.width = 50;
					tile.height = 50;
					tile.x = col*tile.width;
					tile.y = row*tile.height;
					addChild(tile);
					_tilesDict[tile.tileName] = tile;
					tile.isValid = true;
				}
			}
			
			//SPIN BUTTON
			startButton.addEventListener(TouchEvent.TOUCH, spin);
			startButton.width = 50;
			startButton.height = 50;
			startButton.x = this.width+20;
			startButton.y = this.height+20;
			addChild(startButton);
			
		}
		
		private function spin(event:TouchEvent):void{
			
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if(touch != null){
				for each(var tile:Tile in _tilesDict){
					tile.start();
				}
			}
		}
		
		private function generatePlay():void{
			
			
		}
		
	}
}