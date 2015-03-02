package {
	import flash.display.Sprite;
	import flash.net.NetStream;
   	import flash.net.NetConnection;
   	import flash.utils.Timer;
	import flash.media.Video;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event
	import VCAVideoEvent;
	
	class VCAVideo extends Sprite {
		private var stream:NetStream;
		private var client:Object;
		private var video:Video;
		public var meta:Object = new Object();
		public function VCAVideo(source:Object):void{
			meta = source;
			var nc = new NetConnection()
   			nc.connect(null);
   			
   			stream = new NetStream(nc)
   			stream.client = this;
   			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, function(){}); 
   			stream.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus)
   			stream.play(source.file);
   			stream.pause();

   			video = new Video()
   			video.addEventListener(Event.ENTER_FRAME,onPlayStatus)
   			video.attachNetStream(stream)
   			addChild(video)
		}
		private function onPlayStatus(evt:Event){
			meta.time = stream.time;
			dispatchEvent(new VCAVideoEvent(VCAVideoEvent.TIME,meta))
		}
		public function onMetaData(e:Object){
			meta.duration = e.duration;
		}
		private function onNetStatus(evt):void{
   	   		switch(evt.info.code){
	   			case 'NetStream.Buffer.Full':
	   				dispatchEvent(new VCAVideoEvent(VCAVideoEvent.LOADED))
	   			break;
	   			case 'NetStream.Play.Stop':
	   				dispatchEvent(new VCAVideoEvent(VCAVideoEvent.PLAY_COMPLETE))
	   			default:
	   				//trace(evt.info.code + 'was called')
	   			break
	   		}
		}
		public function play():void{
			stream.resume()
		}
		public function seek(where:Number):void{
			stream.seek(where)
		}
		public function pause():void{
			stream.pause()
		}

		public function resize(w:int,h:int){
	   		video.width = w;
	   		video.height = h;
	   }
	}

}