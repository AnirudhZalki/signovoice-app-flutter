import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../learning/presentation/learning_controller.dart';
import '../domain/sign_dictionary.dart';
import 'category_labels.dart';
import 'dictionary_providers.dart';
import 'widgets/sign_card.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key, this.initialCategory, this.bookmarksOnly = false});
  final String? initialCategory;
  final bool bookmarksOnly;

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookmarksOnly ? l.savedSigns : l.dictionaryTitle)),
      body: AsyncValueView<SignDictionary>(
        value: ref.watch(dictionaryProvider),
        onRetry: () => ref.invalidate(dictionaryProvider),
        data: (dict) {
          final saved = ref.watch(learningProvider).bookmarked;
          final results = dict
              .search(_query, categoryId: _category)
              .where((e) => !widget.bookmarksOnly || saved.contains(e.id))
              .toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l.dictionarySearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l.clear,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(label: Text(l.allCategories), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                  ),
                  for (final c in dict.categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(categoryIcon(c.icon), size: 18),
                        label: Text(categoryName(l, c.id)),
                        selected: _category == c.id,
                        onSelected: (_) => setState(() => _category = c.id),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      icon: widget.bookmarksOnly ? Icons.bookmark_border_rounded : Icons.search_off_rounded,
                      title: widget.bookmarksOnly && _query.isEmpty ? l.noSavedSigns : l.dictionaryNoResults)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => SignCard(entry: results[i], onTap: () => context.push(Routes.dictionaryEntry(results[i].id))),
                    ),
            ),
          ]);
        },
      ),
    );
  }
}
