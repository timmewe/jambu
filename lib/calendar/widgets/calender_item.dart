import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jambu/calendar/model/model.dart';
import 'package:jambu/calendar/widgets/tag_chip.dart';

typedef CreateTagCallback = void Function(String, String);
typedef RemoveTagCallback = void Function(String, String);
typedef UpdateTagNameCallback = void Function(String, String);

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    required this.user,
    required this.tags,
    required this.onCreateTag,
    required this.onRemoveTag,
    required this.onUpdateTagName,
    super.key,
  });

  final CalendarUser user;
  final List<String> tags;
  final CreateTagCallback onCreateTag;
  final RemoveTagCallback onRemoveTag;
  final UpdateTagNameCallback onUpdateTagName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.2),
                  foregroundImage:
                      user.image != null ? NetworkImage(user.image!) : null,
                  radius: 30,
                ),
                const SizedBox(width: 10),
                Text(user.name),
              ],
            ),
            _TagsSection(
              user: user,
              tags: tags,
              onCreateTag: onCreateTag,
              onRemoveTag: onRemoveTag,
              onUpdateTagName: onUpdateTagName,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({
    required this.user,
    required this.tags,
    required this.onCreateTag,
    required this.onRemoveTag,
    required this.onUpdateTagName,
  });

  final CalendarUser user;
  final List<String> tags;
  final CreateTagCallback onCreateTag;
  final RemoveTagCallback onRemoveTag;
  final UpdateTagNameCallback onUpdateTagName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 5,
            children: user.tags
                .map(
                  (tagName) => TagChip(
                    tags: tags,
                    name: tagName,
                    onRemove: () => onRemoveTag(tagName, user.id),
                    onUpdateName: (newName) =>
                        onUpdateTagName(tagName, newName),
                  ),
                )
                .toList(),
          ),
        ),
        _TagButton(
          user: user,
          tags: tags,
          onCreateTag: onCreateTag,
          onRemoveTag: onRemoveTag,
        ),
      ],
    );
  }
}

class _TagButton extends StatelessWidget {
  const _TagButton({
    required this.user,
    required this.tags,
    required this.onCreateTag,
    required this.onRemoveTag,
  });

  final CalendarUser user;
  final List<String> tags;
  final CreateTagCallback onCreateTag;
  final RemoveTagCallback onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 25,
      child: PopupMenuButton(
        icon: const Icon(Icons.sell),
        iconSize: 20,
        padding: const EdgeInsets.all(3.5),
        tooltip: 'Tag hinzufügen',
        onSelected: (String? value) {
          if (value == null || value.isEmpty) return;
          onCreateTag(value, user.id);
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<String?>(
              child: TextField(
                autofocus: true,
                onSubmitted: (String text) {
                  if (text.isEmpty) return;
                  onCreateTag(text, user.id);
                  context.pop();
                },
              ),
            ),
            ...tags.where((t) => !user.tags.contains(t)).map(
                  (tag) => PopupMenuItem(
                    value: tag,
                    child: Row(
                      children: [
                        const Icon(Icons.sell_outlined),
                        const SizedBox(width: 10),
                        Text(tag),
                      ],
                    ),
                  ),
                )
          ];
        },
      ),
    );
  }
}
