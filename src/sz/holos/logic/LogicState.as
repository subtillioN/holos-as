/**
 */
package sz.holos.logic {
	import flash.events.EventDispatcher;

	import sz.holos.collections.HashMap;
	import sz.holos.ops.bool.and;

	public class LogicState extends EventDispatcher implements ILogicState {
		public var id : String = "";
		protected var _operands : HashMap,
				_updateHandler : FunctionList,
				_op : Function;

		private var _state : Boolean,
				_currentOperand : String,
				_defaultState : Boolean;

		public function LogicState($operation : Function = null) {
			_operands = new HashMap();
			if($operation)_op=$operation;
			else _op = and;
		}

		public function initStates($operands : Array, $callBack : Function = null, $defaultState : Boolean = false) : void {
			_state = _defaultState = $defaultState;
			addStates($operands);
			_updateHandler = new FunctionList([$callBack]);
		}

		public function addStates($operands : Array) : void {
			var vals : Array = [];
			for(var i : int = 0; i < $operands.length; i++) {vals.push(_defaultState); }
			_operands.addGroup($operands, vals);
			evaluate();
		}

		public function setVal($operands : *, $val : Boolean) : void {
			_currentOperand = $operands;
			_operands.setVal($operands, $val);
			evaluate();
		}


		public function getState($operands : *) : * {
			return _operands[$operands];
		}

		public function evaluate() : void {
			if(_op != null && _operands.length)state = _op(_operands.valsArray);
		}

		public function report() : void {
			trace("\r\r"+ this);
			var s : String =  ":: Waiting for:";
			var k : String;
			for(var i : int = 0; i < _operands.length; i++) {
				k = _operands.keys[i];
				if(!_operands.getVal(k)) {
					s += "\r" + k;
				}
				else trace(k + ' = true');
			}
			s += "\r\r";
			trace(s);
		}

		public function set state($tempState : Boolean) : void {
			if(_state != $tempState) {
				_state = $tempState;
				if(_updateHandler)_updateHandler.run([_state]);
				dispatchEvent(new LogicStateEvent(LogicStateEvent.CHANGED, _currentOperand, _state));
			}
//			report();
		}

		public function resetState() : void {
			for(var k : String in _operands.keys) {
				if(_operands.getVal(k)) {
					_operands.setVal(k, _defaultState);
					_trace(this + '_operands.getVal(k) = ' + _operands.getVal(k));
				}
				else _trace(k + ' = true');
			}
		}

		protected function _trace(...rest) : void {
			//trace(rest);
		}

		public function addUpdateHandler($f : Function) : void {_updateHandler.add([$f]);}

		public function get op() : Function {
			return _op;
		}

		public function set op($op : Function) : void {
			_op = $op;
		}
	}
}
