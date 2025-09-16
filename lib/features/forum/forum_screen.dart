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
		if (text.isEmpty || _uid == null) return;
		await _service.createPost(content: text, authorUid: _uid!);
		_controller.clear();
	}

	@override
	Widget build(BuildContext context) {
		final alias = _uid == null ? 'Offline Mode' : AuthService().aliasForUid(_uid!);
		return Column(
			children: [
				Padding(
					padding: const EdgeInsets.all(12),
					child: Row(
						children: [
							CircleAvatar(child: Text(alias.split(' ').last.substring(0,1))),
							const SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _controller,
									maxLines: 3,
									minLines: 1,
									decoration: const InputDecoration(hintText: 'Share a thought or ask a question…', border: OutlineInputBorder()),
								),
							),
							const SizedBox(width: 8),
							ElevatedButton(onPressed: _uid == null ? null : _post, child: const Text('Post')),
						],
					),
				),
				Expanded(
					child: StreamBuilder<List<ForumPost>>(
						stream: _service.streamRecent(),
						builder: (context, snapshot) {
							final posts = snapshot.data ?? const <ForumPost>[];
							if (posts.isEmpty) {
								return const Center(child: Text('No posts yet. Sign in to share.'));
							}
							return ListView.separated(
								padding: const EdgeInsets.all(12),
								itemCount: posts.length,
								separatorBuilder: (_, __) => const SizedBox(height: 8),
								itemBuilder: (context, i) {
									final p = posts[i];
									final a = AuthService().aliasForUid(p.authorUid);
									return Card(
										child: Padding(
											padding: const EdgeInsets.all(12),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Row(
														children: [
															CircleAvatar(child: Text(a.split('#').last)),
															const SizedBox(width: 8),
															Text(a, style: Theme.of(context).textTheme.labelLarge),
													],
													),
													const SizedBox(height: 8),
													Text(p.content),
													const SizedBox(height: 8),
													Row(
														children: [
															TextButton.icon(onPressed: _uid == null ? null : () => _service.react(id: p.id, field: 'hugs'), icon: const Text('🤗'), label: Text('${p.hugs}')),
															TextButton.icon(onPressed: _uid == null ? null : () => _service.react(id: p.id, field: 'highFives'), icon: const Text('✋'), label: Text('${p.highFives}')),
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
