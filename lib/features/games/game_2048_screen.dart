import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
// No external browser fallback; run in-app when supported
// Windows WebView2
import 'package:webview_windows/webview_windows.dart' as wvwin;
// macOS (wkWebView) controller not strictly needed; webview_flutter handles via platform interface
import 'game_2048_web_stub.dart' if (dart.library.html) 'game_2048_web.dart' as webhelper;

class Calm2048Screen extends StatefulWidget {
	const Calm2048Screen({super.key});

	@override
	State<Calm2048Screen> createState() => _Calm2048ScreenState();
}

class _Calm2048ScreenState extends State<Calm2048Screen> {
	late final WebViewController _controller;
	final wvwin.WebviewController _winController = wvwin.WebviewController();

	@override
	void initState() {
		super.initState();
		if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
			// Include Linux in the standard WebView path
			_controller = WebViewController()
				..setJavaScriptMode(JavaScriptMode.unrestricted)
				..loadHtmlString(_html);
		}
		if (!kIsWeb && Platform.isWindows) {
			_initWindowsWebView();
		}
	}

	Future<void> _initWindowsWebView() async {
		await _winController.initialize();
		await _winController.loadStringContent(_html);
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		if (kIsWeb) {
			return Scaffold(
				appBar: AppBar(title: const Text('Calm 2048')),
				body: webhelper.buildWebViewHtml(_html),
			);
		}
		final bool isAndroidiOS = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
		final bool isMacOS = !kIsWeb && (Platform.isMacOS || Platform.isLinux);
		final bool isWindows = !kIsWeb && Platform.isWindows;
		if (isAndroidiOS || isMacOS) {
			return Scaffold(
				appBar: AppBar(title: const Text('Calm 2048')),
				body: WebViewWidget(controller: _controller),
			);
		}
		if (isWindows) {
			return Scaffold(
				appBar: AppBar(title: const Text('Calm 2048')),
				body: _winController.value.isInitialized
					? wvwin.Webview(_winController)
					: const Center(child: CircularProgressIndicator()),
			);
		}
		return Scaffold(
			appBar: AppBar(title: Text('Calm 2048')),
			body: Center(child: Text('This platform is not supported for in-app WebView.')),
		);
	}

	// Minimal, soothing 2048 implementation with ambient audio and mute toggle
	static const String _html = '''
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<title>Calm 2048</title>
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&family=Quicksand:wght@500;600&display=swap" rel="stylesheet">
	<style>
		* { box-sizing: border-box; }
		:root {
			--bg1: #a18cd1;
			--bg2: #fbc2eb;
			--card: #ffffffcc;
			--text: #445;
			--btn: #81d4fa;
		}
		html, body { height:100%; }
		body {
			margin: 0;
			font-family: 'Poppins', 'Quicksand', system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
			background: linear-gradient(135deg, var(--bg1), var(--bg2));
			display: grid;
			place-items: center;
			color: var(--text);
		}
		.wrapper {
			width: min(92vw, 460px);
			padding: 18px;
		}
		.header {
			display:flex; align-items:center; justify-content:space-between; gap:12px;
			margin-bottom: 16px;
		}
		.score {
			background: var(--card);
			backdrop-filter: blur(4px);
			border-radius: 14px;
			padding: 10px 14px;
			box-shadow: 0 6px 18px rgba(0,0,0,0.08);
		}
		.score small { display:block; opacity:.7; font-size:12px; }
		.score b { font-size:20px; }
		.controls { display:flex; align-items:center; gap:10px; }
		.btn {
			background: var(--btn);
			color: #fff;
			border: none;
			border-radius: 12px;
			padding: 10px 14px;
			font-weight: 600;
			cursor: pointer;
			box-shadow: 0 6px 16px rgba(0,0,0,0.12);
			transition: transform .12s ease, box-shadow .2s ease;
		}
		.btn:active { transform: translateY(1px); box-shadow: 0 4px 12px rgba(0,0,0,0.12); }
		.mute {
			background: var(--card); color: var(--text);
			width:40px; height:40px; display:grid; place-items:center; padding:0;
		}
		.grid { width: 100%; aspect-ratio: 1 / 1; }
		.board { position: relative; padding: 12px; }
		.cells { position:absolute; inset:12px; display:grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: repeat(4, 1fr); gap: 12px; }
		.tiles { position:absolute; inset:12px; display:grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: repeat(4, 1fr); gap: 12px; }
		.cell, .tile { border-radius: 14px; display:grid; place-items:center; width: 100%; height: 100%; }
		.cell { background: rgba(255,255,255,0.28); }
		.tile { font-weight: 600; font-size: 22px; color: #334; box-shadow: 0 8px 18px rgba(0,0,0,0.08); transition: transform .22s cubic-bezier(.22,.61,.36,1), box-shadow .22s ease, background-color .25s ease; will-change: transform; }
		.tile.new { animation: pop .26s cubic-bezier(.2,.8,.2,1) both; }
		@keyframes pop { 0% { transform: scale(.88); opacity:.6; } 60% { transform: scale(1.06); opacity:1; } 100% { transform: scale(1); } }
		.footer { margin-top: 14px; opacity:.8; font-size: 12px; text-align:center; }
	</style>
</head>
<body>
	<div class="wrapper">
		<div class="header">
			<div class="score">
				<small>Score</small>
				<b id="score">0</b>
			</div>
			<div class="controls">
				<button class="btn" id="restart">Restart</button>
				<button class="btn mute" id="mute" aria-label="Toggle sound">🔈</button>
			</div>
		</div>
		<div class="grid board" id="board">
			<div class="cells">
				<div class="cell"></div><div class="cell"></div><div class="cell"></div><div class="cell"></div>
				<div class="cell"></div><div class="cell"></div><div class="cell"></div><div class="cell"></div>
				<div class="cell"></div><div class="cell"></div><div class="cell"></div><div class="cell"></div>
				<div class="cell"></div><div class="cell"></div><div class="cell"></div><div class="cell"></div>
			</div>
			<div class="tiles" id="tiles"></div>
		</div>
		<div class="footer">Swipe or use arrow keys. Relax and enjoy.</div>
	</div>

	<audio id="bgm" loop>
		<source src="https://cdn.pixabay.com/audio/2021/11/18/audio_d1a4b4b4b2.mp3" type="audio/mpeg" />
	</audio>

	<!-- subtle sfx -->
	<audio id="sfx-move" preload="auto">
		<source src="https://cdn.pixabay.com/audio/2022/03/15/audio_1a7f4a0d7a.mp3" type="audio/mpeg" />
	</audio>
	<audio id="sfx-merge" preload="auto">
		<source src="https://cdn.pixabay.com/audio/2022/03/15/audio_0a5b9f5b3e.mp3" type="audio/mpeg" />
	</audio>

	<script>
	const pastel = {
		2:'#e0f7fa',4:'#f1f8e9',8:'#fff9c4',16:'#ffe0b2',32:'#f8bbd0',64:'#d1c4e9',128:'#c5cae9',256:'#b2ebf2',512:'#b2dfdb',1024:'#f0f4c3',2048:'#ffe082'
	};
	const size = 4;
	let grid, score;
	const scoreEl = document.getElementById('score');
	const tilesEl = document.getElementById('tiles');
	const bgm = document.getElementById('bgm');
	const sfxMove = document.getElementById('sfx-move');
	const sfxMerge = document.getElementById('sfx-merge');
	bgm.volume = 0.18; // calm volume
	sfxMove.volume = 0.45; sfxMerge.volume = 0.50;
	let muted = false; // start with sound enabled
	bgm.muted = muted; sfxMove.muted = muted; sfxMerge.muted = muted;

	function playOnce(a){ try{ a.pause(); a.currentTime = 0; a.play(); }catch(_){} }

	function init() {
		grid = Array.from({length:size}, ()=>Array(size).fill(0));
		score = 0; updateScore();
		spawn(); spawn();
		render();
	}
	function updateScore(){ scoreEl.textContent = score; }
	function spawn(){
		const empty = [];
		for(let r=0;r<size;r++) for(let c=0;c<size;c++) if(grid[r][c]===0) empty.push([r,c]);
		if(!empty.length) return;
		const [r,c] = empty[Math.floor(Math.random()*empty.length)];
		grid[r][c] = Math.random()<0.9?2:4;
	}
	function render(){
		tilesEl.innerHTML = '';
		for(let r=0;r<size;r++){
			for(let c=0;c<size;c++){
				const v = grid[r][c]; if(!v) continue;
				const t = document.createElement('div');
				t.className = 'tile';
				t.textContent = v;
				t.style.background = pastel[v]||'#fff';
				// Position the tile in the CSS grid at (r,c)
				t.style.gridRowStart = String(r+1);
				t.style.gridColumnStart = String(c+1);
				tilesEl.appendChild(t);
			}
		}
	}

	// Returns { row: newRowArray, moved: bool, gained: number }
	function slideRowLeft(row){
		const filtered = row.filter(v => v !== 0);
		const result = [];
		let gained = 0;
		for(let i=0; i<filtered.length; i++){
			if(i < filtered.length - 1 && filtered[i] === filtered[i+1]){
				const merged = filtered[i] * 2;
				result.push(merged);
				gained += merged;
				i++; // skip next as it merged
			}else{
				result.push(filtered[i]);
			}
		}
		while(result.length < size) result.push(0);
		const moved = result.some((v, idx) => v !== row[idx]);
		return { row: result, moved, gained };
	}

	function gridsEqual(a,b){
		for(let r=0;r<size;r++) for(let c=0;c<size;c++) if(a[r][c]!==b[r][c]) return false;
		return true;
	}

	function cloneGrid(){ return grid.map(row=>row.slice()); }

	function moveLeft(){
		const before = cloneGrid(); let gainedTotal = 0;
		for(let r=0; r<size; r++){
			const {row: newRow, gained} = slideRowLeft(grid[r]);
			grid[r] = newRow; gainedTotal += gained;
		}
		if(!gridsEqual(before, grid)){
			score += gainedTotal; spawn(); render(); updateScore(); checkEnd();
			if(!muted){ setTimeout(()=>{ playOnce(sfxMove); }, 0); }
			if(gainedTotal>0 && !muted){ setTimeout(()=>{ playOnce(sfxMerge); }, 0); }
		}
	}
	function moveRight(){
		const before = cloneGrid(); let gainedTotal = 0;
		for(let r=0; r<size; r++){
			const reversed = grid[r].slice().reverse();
			const {row: newRow, gained} = slideRowLeft(reversed);
			grid[r] = newRow.reverse(); gainedTotal += gained;
		}
		if(!gridsEqual(before, grid)){
			score += gainedTotal; spawn(); render(); updateScore(); checkEnd();
			if(!muted){ setTimeout(()=>{ playOnce(sfxMove); }, 0); }
			if(gainedTotal>0 && !muted){ setTimeout(()=>{ playOnce(sfxMerge); }, 0); }
		}
	}
	function moveUp(){
		const before = cloneGrid(); let gainedTotal = 0;
		for(let c=0; c<size; c++){
			const col = [grid[0][c], grid[1][c], grid[2][c], grid[3][c]];
			const {row: newCol, gained} = slideRowLeft(col);
			for(let r=0; r<size; r++) grid[r][c] = newCol[r];
			gainedTotal += gained;
		}
		if(!gridsEqual(before, grid)){
			score += gainedTotal; spawn(); render(); updateScore(); checkEnd();
			if(!muted){ setTimeout(()=>{ playOnce(sfxMove); }, 0); }
			if(gainedTotal>0 && !muted){ setTimeout(()=>{ playOnce(sfxMerge); }, 0); }
		}
	}
	function moveDown(){
		const before = cloneGrid(); let gainedTotal = 0;
		for(let c=0; c<size; c++){
			const col = [grid[0][c], grid[1][c], grid[2][c], grid[3][c]].reverse();
			const {row: newCol, gained} = slideRowLeft(col);
			const written = newCol.reverse();
			for(let r=0; r<size; r++) grid[r][c] = written[r];
			gainedTotal += gained;
		}
		if(!gridsEqual(before, grid)){
			score += gainedTotal; spawn(); render(); updateScore(); checkEnd();
			if(!muted){ setTimeout(()=>{ playOnce(sfxMove); }, 0); }
			if(gainedTotal>0 && !muted){ setTimeout(()=>{ playOnce(sfxMerge); }, 0); }
		}
	}

	function canMove(){
		for(let r=0;r<size;r++) for(let c=0;c<size;c++) if(grid[r][c]===0) return true;
		for(let r=0;r<size;r++) for(let c=0;c<size-1;c++) if(grid[r][c]===grid[r][c+1]) return true;
		for(let c=0;c<size;c++) for(let r=0;r<size-1;r++) if(grid[r][c]===grid[r+1][c]) return true;
		return false;
	}
	function checkEnd(){ if(!canMove()) setTimeout(()=>alert('No moves left. Keep calm and try again!'), 50); }

	// input with throttling to avoid repeated moves
	let busy = false;
	function doMove(fn){ if(busy) return; busy = true; fn(); setTimeout(()=>{ busy=false; }, 120); }
	window.addEventListener('keydown', (e)=>{
		switch(e.key){
			case 'ArrowLeft': e.preventDefault(); doMove(moveLeft); break;
			case 'ArrowRight': e.preventDefault(); doMove(moveRight); break;
			case 'ArrowUp': e.preventDefault(); doMove(moveUp); break;
			case 'ArrowDown': e.preventDefault(); doMove(moveDown); break;
		}
	});
	let touchStartX=0, touchStartY=0;
	document.addEventListener('touchstart', (e)=>{
		const t=e.changedTouches[0]; touchStartX=t.clientX; touchStartY=t.clientY;
	},{passive:true});
	document.addEventListener('touchend', (e)=>{
		const t=e.changedTouches[0];
		const dx=t.clientX-touchStartX, dy=t.clientY-touchStartY;
		if(Math.abs(dx)>Math.abs(dy)) { if(dx>20) doMove(moveRight); else if(dx<-20) doMove(moveLeft); }
		else { if(dy>20) doMove(moveDown); else if(dy<-20) doMove(moveUp); }
	});

	// controls
	document.getElementById('restart').addEventListener('click', ()=>{ init(); });
	const muteBtn = document.getElementById('mute');
	muteBtn.addEventListener('click', ()=>{
		muted=!muted; bgm.muted=muted; sfxMove.muted=muted; sfxMerge.muted=muted;
		muteBtn.textContent = muted? '🔇':'🔊'; if(!muted){ bgm.play().catch(()=>{}); sfxMove.load(); sfxMerge.load(); }
	});

	// unlock audio on first interaction + focus window
	window.addEventListener('load', ()=>{ try{ window.focus(); }catch(_){} });
	document.addEventListener('pointerdown', ()=>{ if(!muted){ bgm.play().catch(()=>{}); playOnce(sfxMove); } }, {once:true});
	document.addEventListener('touchstart', ()=>{ if(!muted){ bgm.play().catch(()=>{}); playOnce(sfxMove); } }, {once:true});
	window.addEventListener('keydown', ()=>{ if(!muted){ bgm.play().catch(()=>{}); playOnce(sfxMove); } }, {once:true});

	init();
	</script>
</body>
</html>
''';
}




