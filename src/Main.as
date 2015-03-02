 package  {

   import flash.display.Sprite;
   import flash.display.LoaderInfo;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.net.URLRequest;
   import flash.net.URLLoader;
   import flash.net.NetStream;
   import flash.net.NetConnection;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.MouseEvent;
   import flash.media.Video;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.utils.Timer;

   import VCAVideo;
   import VCAVideoEvent;
   import ProgressBar;
   import w11k.flash.AngularJSAdapter;
   import com.greensock.TweenLite;
   import com.greensock.easing.*;

   public class Main extends Sprite {
   		private var state:String = 'loading';
		
		private var sources:Array = [];
		private var videoData:Object;
		
		private var videos:Array = [];
		private var master:VCAVideo;
		private var progressBar:ProgressBar;

		private var loadProgress:int = 0;
		
		private var soundtrack:Sound;
		private var soundChannel:SoundChannel;
   		
   		private var _isReady:Boolean;
		private var _cursorAt:Object;
		
		private var ng:AngularJSAdapter;

		function Main():void {


			this.loaderInfo.addEventListener(Event.COMPLETE,onReady);
			stage.addEventListener(Event.RESIZE, onResize); 
			stage.align=StageAlign.TOP_LEFT;
			stage.scaleMode=StageScaleMode.NO_SCALE;

			progressBar = new ProgressBar(0);
			progressBar.addEventListener(VCAVideoEvent.SCRUB,function(evt:VCAVideoEvent){
				seek(master.meta.duration * evt.data.position)
			})

			stage.dispatchEvent(new Event(Event.RESIZE));

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEnter);
			playbutton.buttonMode = true;
			playbutton.addEventListener(MouseEvent.CLICK,function(){
				if(state=='playing'){
					pause();
				}else{
					play();
				}
			})
	   }

	   function onReady(evt:Event){
			var flashVars:Object = stage.loaderInfo.parameters
			ng = AngularJSAdapter.getInstance();
			ng.setFlashId(flashVars.w11kFlashId || 'NONE');
			ng.expose('setSources',getSources);
			ng.expose('setAudio',getAudio);
			ng.expose('setVideoData',getVideoData)
			ng.expose('play',play)
			ng.expose('pause',pause)
			ng.fireFlashReady();
	   }
	   private function getAudio(incomingAudio:Object){
		   loadAudio(incomingAudio.file)
	   }
	   private function getSources(incomingSources:Array){
		   isReady = false;
		   sources = incomingSources;
		   init();
	   }
	   private function getVideoData(data){
	   		videoData = data;
	   		init();
	   }
	   private function init(){
	   		var i:int = 0;
	   		for each(var source:Object in sources){
	   			var v:VCAVideo = new VCAVideo(source)
	   			v.addEventListener(VCAVideoEvent.LOADED,onLoadProgress)
	   			
	   			if(i==0) {
	   				master = v;
	   				master.addEventListener(VCAVideoEvent.TIME,onPlayProgress)
	   				master.addEventListener(VCAVideoEvent.PLAY_COMPLETE,function(){
	   					seek(0);
	   					pause();
	   				})
	   			}
	   			v.resize(stage.stageWidth,stage.stageHeight);
	   			addChild(v);
	   			videos.push(v);
	   			i++;
	   		}

	   		addChild(playbutton)
	   		
	   		addChild(progressBar)
			addChild(log)
	   		pause();

	   }
	   private function loadAudio(url:String){
	   		isReady = false;
	   		pause();
	   		soundtrack = new Sound(new URLRequest(url))
	   		soundtrack.addEventListener(Event.COMPLETE,function(evt){
	   			isReady = true;
	   			onLoadProgress(evt)
	   		})
	   }
	   private function play(){
	   		for each(var video:VCAVideo in videos){
	   			video.play()
	   		}
	   		soundChannel = soundtrack.play(master.meta.time*1000);
	   		state = 'playing'
	   		playbutton.gotoAndStop(state);
	   }
   	   private function pause(){
	   		for each(var video:VCAVideo in videos){
	   			video.pause()
	   		}
	   		if(soundChannel != null) soundChannel.stop();
		   	state = 'paused'
	   		playbutton.gotoAndStop(state);
	   		
	   }
	   private function seek(time){
	   		trace('going to:' + time)
	   		for each(var video:VCAVideo in videos){
	   			video.seek(time);
	   		}
	   		if(state == 'playing'){
	   			if(soundChannel != null) soundChannel.stop();
	   			play();
	   		}
	   }
	   private function set cursorAt(timelineEl:Object){
	   		if(_cursorAt==null || timelineEl.videoId != _cursorAt.videoId){
	   			_cursorAt = timelineEl;
	   			trace('current video changed!: '+ cursorAt.videoId)
	   			ng.call('getCursorAt(data)',{data:cursorAt})// Notify angular
	   		}
	   }
	   private function get cursorAt():Object{
	   	return _cursorAt;
	   }

	   private function set isReady(newVal:Boolean) {
	   		if(newVal != _isReady){
	   			_isReady = newVal
	   			ng.call('setIsReady(val)',{val:isReady})// Notify angular
	   		}
	   }
	   private function get isReady():Boolean {
	   		return _isReady;
	   }

	   private function onPlayProgress(evt:VCAVideoEvent){
	   		var currentVideoId:int;
	   		for each(var data:Object in videoData.timeline){
	   			if(data.to*evt.data.duration > evt.data.time){
	   				cursorAt = data;
	   				currentVideoId = data.videoId;
	   				break;
	   			}
	   		}
	   		for each(var v:VCAVideo in videos){
	   			if(currentVideoId == v.meta.id){
	   				v.visible = true
	   			}else{
	   				v.visible = false
	   			}
	   		}
	   		progressBar.setProgress(evt.data.time);
	   }
	   private function onLoadProgress(evt:Event){
			loadProgress++
   			if(loadProgress == videos.length+1){
	   			trace('Done loading')
	   			progressBar.setTotalTime(master.meta.duration)
	   			state = 'paused';				
			}
	   }

	   private function onResize(evt:Event){
	   		playbutton.x = stage.stageWidth/2;
	   		playbutton.y = stage.stageHeight/2;
	   		progressBar.width = stage.stageWidth;
	   		progressBar.y = stage.stageHeight;
	   		progressBar.x = 0;
	   		for each(var video:VCAVideo in videos){
	   			video.resize(stage.stageWidth,stage.stageHeight);
	   		}
	   }
	   
	   private function onMouseLeave(evt:Event){
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEnter);
	   		
			TweenLite.to(progressBar,.5,{
				height: 5,
				ease: Expo.easeOut
			})

	   		TweenLite.to(playbutton,.5,{
				alpha:0,
				scaleY:0.8,
				scaleX:0.8,
				ease: Expo.easeOut
			})
	   }

	   private function onMouseEnter(evt:Event){
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEnter);

			TweenLite.to(progressBar,.5,{
				height: 10,
				ease: Expo.easeOut
			})

	   		TweenLite.to(playbutton,.5,{
				alpha:1,
				scaleY: 1,
				scaleX: 1,
				ease: Expo.easeOut
			})
	   }
	}
 }