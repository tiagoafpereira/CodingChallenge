package 
{
	import starling.core.Starling;
	import flash.display.Sprite;
	
	[SWF(width="605", height="600", frameRate="60", backgroundColor="#FFFFFF", verticalAlign="middle")]
	public class GamesysCodingChallenge extends Sprite
	{
		private var mStarling:Starling;
		
		public function GamesysCodingChallenge()
		{
			// Create a Starling instance that will run the "Game" class
			mStarling = new Starling(Game, stage);
			mStarling.start();
		}
	}
}