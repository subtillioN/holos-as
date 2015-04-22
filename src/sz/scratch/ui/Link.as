package sz.scratch.ui {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import sz.scratch.utils.jsCall;
	import sz.scratch.utils.navigate;
	import sz.scratch.vo.LinkVO;

	/**
	 * Link is used to centralize and facilitate text embedding
	 * and formatting of common textual link elements.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Nov 18, 2009
	 *
	 */

	public class Link extends Sprite {
		public var title : Text;
		private var _clickHandler : Function;
		private var _hit : Sprite;
		private var _data : LinkVO;
		public static const PID : String = "Link_";

		public function Link() : void {
			_hit = new Sprite();
			_hit.graphics.beginFill(0xFF0000, 0);
			_hit.graphics.drawRect(0, 0, 100, 100);
			title = new Text();
			addChild(title);
			addChild(_hit);
			disableMouse(title);
		}

		private function _activate() : void {
//			trace(this + '_activate ');
			_hit.buttonMode = true;
			_hit.addEventListener(MouseEvent.MOUSE_OVER, _onOver);
			_hit.addEventListener(MouseEvent.MOUSE_OUT, _onOut);
			_hit.addEventListener(MouseEvent.CLICK, _onClick);
		}

		private function _onClick(event : MouseEvent) : void {
//			trace(this + '_onClick ');
			if(_clickHandler != null)_clickHandler();
			else if(_data.URL) navigate(_data.URL, _data.target);
			if (_data.jsCall) jsCall(_data.jsCall);
		}


		protected function _onOut(event : MouseEvent) : void {
			_setText();
		}

		protected function _onOver(event : MouseEvent) : void {
			_setText(true);
		}

		public function setData($data : LinkVO) : void {
			_data = $data;
			trace('' + this + '_data = ' + _data);
			if(!isNaN(_data.x))x = _data.x;
			if(!isNaN(_data.y))y = _data.y;
			if(_data.id)_setText();
			_activate();
		}

		protected function _setText($over : Boolean = false) : void {
			var pid : String = PID + _data.id + (($over) ? "_over" : "");
			title.setText(_data.title, pid);

			_hit.width = title.field.textWidth;
			_hit.height = title.height;
			_hit.x = title.x;
			_hit.y = title.y;
		}

		public function set clickHandler($click : Function) : void {
			_clickHandler = $click;
		}

		override public function toString() : String {
			return '[Link]';
		}
	}
}
