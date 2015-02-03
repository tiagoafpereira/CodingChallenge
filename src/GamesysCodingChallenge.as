package 
{
	import starling.core.Starling;
	import flash.display.Sprite;
	
	[SWF(width="800", height="800", frameRate="60", backgroundColor="#000000")]
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