/**
 * Created by IntelliJ IDEA.
 * User: jmorrison
 * Date: 2/1/11
 * Time: 10:58 AM
 * To change this template use File | Settings | File Templates.
 */
package sz.examples.deep_address {
	import com.core.mvc.locate;

	import fl.controls.Button;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ASection extends Sprite {
		public var title_txt : TextField;
		public var nextBtn : Button;
		public var prevBtn : Button;
		private var _data : SectionVO;

		protected var _depth : int = 0;
		protected var _controller : Controller;

		public function ASection() {
			_controller = locate(Controller);
			nextBtn.addEventListener(MouseEvent.CLICK, _onNext);
			prevBtn.addEventListener(MouseEvent.CLICK, _onPrev);
			visible = false;
			alpha = 0;
		}

		private function _onNext(event : MouseEvent) : void {
			_controller.deepAddress.goNextAt(_depth);
			_update();
		}

		private function _onPrev(event : MouseEvent) : void {
			_controller.deepAddress.goPrevAt(_depth);
			_update();
		}

		private function _update() : void {
			if(_controller.deepAddress.model.hasNextAt(_depth)) {
				nextBtn.alpha = 1;
				nextBtn.mouseEnabled = true;
			}
			else {
				nextBtn.alpha = .25;
				nextBtn.mouseEnabled = false;
			}
			if(_controller.deepAddress.model.hasPrevAt(_depth)) {
				prevBtn.alpha = 1;
				prevBtn.mouseEnabled = true;
			}
			else {
				prevBtn.alpha = .25;
				prevBtn.mouseEnabled = false;
			}
		}


		public function set data($data : SectionVO) {
			_data = $data;
			title_txt.text = $data.title;
			_update();
		}

		public function get data() : SectionVO {
			return _data;
		}
	}
}
