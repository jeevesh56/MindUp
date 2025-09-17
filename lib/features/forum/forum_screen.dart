import 'package:flutter/material.dart';
import 'forum_service.dart';
import 'models/forum_post.dart';
import '../../services/auth_service.dart';

class ForumScreen extends StatefulWidget {
	const ForumScreen({super.key});

	@override
	State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
	final ForumService _service = ForumService();
	final AuthService _auth = AuthService();
	final TextEditingController _controller = TextEditingController();
	String? _uid;
	bool _postAnonymously = true;

	@override
	void initState() {
		super.initState();
		_auth.ensureSignedIn().then((user) => setState(() { _uid = user?.uid; }));
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

Future<void> _post() async {
		final text = _controller.text.trim();
		if (text.isEmpty) return;
		final author = _postAnonymously ? 'anonymous' : (_uid ?? 'anonymous');
		await _service.createPost(content: text, authorUid: author);
		_controller.clear();
	}

	@override
	Widget build(BuildContext context) {
		final alias = _postAnonymously
			? 'Anonymous'
			: (_uid == null ? 'Anonymous' : AuthService().aliasForUid(_uid!));
		return Column(
			children: [
				Padding(
					padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
					child: Card(
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
						child: Padding(
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									Row(
										children: [
											CircleAvatar(child: Text(alias.split(' ').last.substring(0,1))),
											const SizedBox(width: 12),
											Expanded(
												child: TextField(
													controller: _controller,
													maxLines: 3,
													minLines: 1,
													decoration: InputDecoration(hintText: 'Share a thought or ask a question…', filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
												),
											),
											const SizedBox(width: 8),
											FilledButton.icon(onPressed: _post, icon: const Icon(Icons.send), label: const Text('Post')),
										],
									),
									const SizedBox(height: 8),
									Row(
										mainAxisAlignment: MainAxisAlignment.end,
										children: [
											Switch(value: _postAnonymously, onChanged: (v) => setState(() => _postAnonymously = v)),
											const Text('Post anonymously'),
										],
									),
								],
							),
						),
					),
				),
				Expanded(
					child: StreamBuilder<List<ForumPost>>(
						stream: _service.streamRecent(),
						builder: (context, snapshot) {
							final posts = snapshot.data ?? const <ForumPost>[];
							if (posts.isEmpty) {
								return const Center(child: Text('No posts yet. Be the first to share.'));
							}
							return ListView.separated(
								padding: const EdgeInsets.all(12),
								itemCount: posts.length,
								separatorBuilder: (_, __) => const SizedBox(height: 8),
								itemBuilder: (context, i) {
									final p = posts[i];
									final a = p.authorUid == 'anonymous' ? 'Anonymous' : AuthService().aliasForUid(p.authorUid);
								return Card(
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
									child: Padding(
										padding: const EdgeInsets.all(12),
										child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															CircleAvatar(child: Text(a.split('#').last)),
															const SizedBox(width: 8),
														Expanded(child: Text(a, style: Theme.of(context).textTheme.labelLarge)),
													],
													),
													const SizedBox(height: 8),
													Text(p.content),
													const SizedBox(height: 8),
													Row(
														children: [
														OutlinedButton.icon(onPressed: () => _service.react(id: p.id, field: 'hugs'), icon: const Text('🤗'), label: Text('${p.hugs}')),
														const SizedBox(width: 8),
														OutlinedButton.icon(onPressed: () => _service.react(id: p.id, field: 'highFives'), icon: const Text('✋'), label: Text('${p.highFives}')),
													],
												),
											],
										),
									),
								);
							},
							);
						},
					),
				),
			],
		);
	}
}
