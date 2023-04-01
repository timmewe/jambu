import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jambu/calendar/model/model.dart';
import 'package:jambu/calendar/widgets/tag_chip.dart';
import 'package:jambu/calendar/widgets/widgets.dart';

typedef CreateTagCallback = void Function(String, String);

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    required this.user,
    required this.tags,
    required this.onCreate,
    super.key,
  });

  final CalendarUser user;
  final List<String> tags;
  final CreateTagCallback onCreate;

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
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 5,
              children: [
                PopupMenuButton(
                  icon: const Icon(Icons.sell),
                  onSelected: (value) {
                    if (value == 'Erstellen') {
                      showDialog<void>(
                        context: context,
                        builder: (context) => TagDialog(
                          onSave: (name) => onCreate(name, user.id),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'Erstellen',
                        child: TextField(
                          autofocus: true,
                          onSubmitted: (text) {
                            onCreate(text, user.id);
                            context.pop();
                          },
                        ),
                      ),
                      ...tags.map(
                        (tag) => PopupMenuItem(
                          value: tag,
                          child: Row(
                            children: [
                              Icon(
                                user.tags.contains(tag)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                              ),
                              const SizedBox(width: 10),
                              Text(tag),
                            ],
                          ),
                        ),
                      )
                    ];
                  },
                ),
                ...user.tags.map((tag) => TagChip(name: tag, onRemove: () {})),
              ],
            )
          ],
        ),
      ),
    );
  }
}
