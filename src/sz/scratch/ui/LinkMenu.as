package com.mazda.mazda5.main.ui
{
	import flash.display.Sprite;

	/**
	 * LinkMenu is used with MenuLink and Div subclasses/instances to provide
	 * a common menu of links separated by dividers. This is used for the header
	 * and footer menus in CommonLinks.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Nov 19, 2009
	 *
	 */

	public class LinkMenu extends Sprite
	{
		private var _data : XMLList;
		private var _links : Array;
		private var _divs : Array;
		private var _gap : Number = 20;
		private var _divClass : Class;
		private var _populateID : String;
		private var _originX : Number;

		private function _refresh() : void
		{
			_clearLinks();
			_createLinks();
			_layout();
			show();
		}

		private function _layout() : void
		{
			var tx : Number = 0;
			var i : int = 0;
			for each (var link : MenuLink in _links)
			{
				link.x = tx;
				addChild(link);
				if(i > 0)
				{
					var div : Div = _divs[i - 1] as Div;
					div.x = tx - _gap * .5;
					addChild(div);
				}
				tx += link.width + _gap;
				i++;
			}
			x = _originX - width;
		}

		private function _createLinks() : void
		{
			var i : int = 0;
			for each (var linkData : XML in _data..link)
			{
				var link : MenuLink = new MenuLink();
				link.setData(linkData, _populateID, linkData.@url, linkData.@target, linkData.@section, linkData.@js, linkData.@WTTag);
				_links.push(link);
				if(i > 0)
				{
					var div : Div = new _divClass();
					_divs.push(div);
				}
				i++;
			}
		}

		private function _clearLinks() : void
		{
			if(_links)
			{
				for each (var link : MenuLink in _links)
				{
					if(contains(link))removeChild(link);
				}
			}
			if(_divs)
			{
				for each (var div : Div in _links)
				{
					if(contains(div))removeChild(div);
				}
			}
			_links = new Array();
			_divs = new Array();
		}

		public function show() : void
		{
			visible = true;
		}

		public function setData($x : XMLList, $divClass : Class, $populateID : String, $gap : Number = 20) : void
		{
			_originX = x;
			_data = $x;
			_divClass = $divClass;
			_populateID = $populateID;
			_gap = $gap;
			_refresh();
		}

		override public function toString() : String
		{
			return '[LinkMenu]';
		}
	}
}
