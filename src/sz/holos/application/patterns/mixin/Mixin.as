package sz.holos.application.patterns.mixin {
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	/**
	 *
	 *
	 The MIT License

	 Copyright (c) 2010 Nicolas Bottarini

	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the "Software"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:

	 The above copyright notice and this permission notice shall be included in
	 all copies or substantial portions of the Software.

	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	 THE SOFTWARE.
	 *
	 * @todo Make accesors work
	 */
	public class Mixin {
		private var _prototype : *;
		private var _mixinClassName : String;
		private var _mixinNamespace : String;

		public function Mixin(prototype : *) {
			_prototype = prototype;
			_mixinClassName = getClassName(this);
			_mixinNamespace = '__mixin__' + _mixinClassName;
			doInstall();
		}

		private function doInstall() : void {
			// Internal property with installed mixins
			var mixinsVar : String = '__mixins__';
			if(!_prototype.hasOwnProperty(mixinsVar)) {
				_prototype[mixinsVar] = new Array();
				_prototype.setPropertyIsEnumerable(mixinsVar, false);
			}

			//Mixin already installed
			if(Array(_prototype[mixinsVar]).indexOf(_mixinClassName) != -1) {
				return;
			}

			var info : XML = new XML(describeType(this));
			for each (var method : * in info.elements('method')) {
				var name : String = method.attribute('name');
				var declaredBy : String = method.attribute('declaredBy');
				if(declaredBy != "avatar.util::Mixin" && !_prototype.hasOwnProperty(name)) {
					_prototype[name] = this[name];
					_prototype.setPropertyIsEnumerable(name, false);
				}
			}

			_prototype[mixinsVar].push(_mixinClassName);
		}

		protected function getVariable(name : String) : Object {
			if(!_prototype.hasOwnProperty(_mixinNamespace + name)) {
				return undefined;
			}
			return _prototype[_mixinNamespace + name];
		}

		protected function setVariable(name : String, value : Object) : void {
			_prototype[_mixinNamespace + name] = value;
		}

		public static function install(mixin : Class, extended : Class) : void {
			var m : Mixin = new mixin(extended.prototype);
		}

		private function getClassName(obj : Object) : String {
			var fullName : String = getQualifiedClassName(obj);
			var parts : Array = fullName.split('::');
			if(parts.length == 0) {
				return null;
			} else if(parts.length > 1) {
				return parts[1];
			} else {
				return parts[0];
			}
		}
	}
}