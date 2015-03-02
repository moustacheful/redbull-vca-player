package{
	import flash.events.Event

	class VCAVideoEvent extends Event {
		public static const TIME:String = "time";
		public static const LOADED:String = "loaded";
		public static const PLAY_COMPLETE:String = "playComplete";
		public static const SCRUB:String = "scrub";
		public var data:Object = new Object();
		public function VCAVideoEvent(type:String,metaData:Object=null){
			data = metaData;
			super(type)
		}
	}
}