package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import VCAVideoEvent;

	public class ProgressBar extends Sprite{
		public var percentage:Number;
		private var totalTime:Number;
		private var currentTime:Number;
		public function ProgressBar(total:Number){
			addEventListener(MouseEvent.CLICK,scrub);
			totalTime = total;
			setProgress(0);
		}
		public function setTotalTime(t:Number){
			totalTime = t;
			setProgress(currentTime);
		}
		public function setProgress(t:Number){
			currentTime = t;
			percentage = currentTime/totalTime;
			elapsed.scaleX = percentage;
		}
		public function scrub(evt:MouseEvent){
			//trace(evt.stageX+','+this.width+': '+(evt.stageX/this.width));
			dispatchEvent(
				new VCAVideoEvent(VCAVideoEvent.SCRUB,{
					position:evt.stageX/this.width
				})
			);
		}
	}
}