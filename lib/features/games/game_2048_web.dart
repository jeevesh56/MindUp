import 'package:flutter/widgets.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

bool _calm2048Registered = false;
const String _viewType = 'calm-2048-view';

Widget buildWebViewHtml(String htmlContent) {
	if (!_calm2048Registered) {
		// ignore: undefined_prefixed_name
		ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
			final iframe = html.IFrameElement()
				..style.border = '0'
				..style.width = '100%'
				..style.height = '100%'
				..setAttribute('allow', 'autoplay')
				..srcdoc = htmlContent;
			return iframe;
		});
		_calm2048Registered = true;
	}
	return const HtmlElementView(viewType: _viewType);
}


