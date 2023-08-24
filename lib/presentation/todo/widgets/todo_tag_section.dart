import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag_dialog.dart';

abstract class TodoTagSection extends StatelessWidget {
  final Icon leadingIcon;
  final Color tagColor;
  final bool readOnly;

  const TodoTagSection({
    required this.leadingIcon,
    this.tagColor = defaultChipColor,
    this.readOnly = false,
    super.key,
  });

  void _showDialog({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  void _onSelected(BuildContext context, String value, bool selected);

  Widget _buildChips({
    required BuildContext context,
    required List<String> tags,
    required List<String?> selectedTags,
  }) {
    return GenericChipGroup(
      children: [
        for (var t in tags)
          GenericChoiceChip(
            label: t,
            selected: selectedTags.contains(t),
            color: tagColor,
            onSelected: !readOnly
                ? (bool selected) => _onSelected(context, t, selected)
                : null,
          ),
      ],
    );
  }
}

class TodoPriorityTags extends TodoTagSection {
  const TodoPriorityTags({
    super.leadingIcon = const Icon(Icons.outlined_flag),
    super.tagColor = priorityChipColor,
    super.readOnly,
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoPriorityAdded(value));
    } else {
      context.read<TodoBloc>().add(const TodoPriorityRemoved());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (previousState.todo.priority == state.todo.priority) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildChips(
            context: context,
            tags: priorities,
            selectedTags: [state.todo.priority],
          ),
        );
      },
    );
  }
}

class TodoProjectTags extends TodoTagSection {
  const TodoProjectTags({
    super.leadingIcon = const Icon(Icons.rocket_launch_outlined),
    super.tagColor = projectChipColor,
    super.readOnly,
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoProjectAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoProjectRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoProjectTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const IterableEquality()
            .equals(previousState.todo.projects, state.todo.projects)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildChips(
            context: context,
            tags: state.todo.projects,
            selectedTags: state.todo.projects,
          ),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new project tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}

class TodoContextTags extends TodoTagSection {
  const TodoContextTags({
    super.leadingIcon = const Icon(Icons.sell_outlined),
    super.tagColor = keyValueChipColor,
    super.readOnly,
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoContextAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoContextRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoContextTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const IterableEquality()
            .equals(previousState.todo.contexts, state.todo.contexts)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildChips(
            context: context,
            tags: state.todo.contexts,
            selectedTags: state.todo.contexts,
          ),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new context tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}

class TodoKeyValueTags extends TodoTagSection {
  const TodoKeyValueTags({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    super.readOnly,
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoKeyValueAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoKeyValueRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoKeyValueTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const DeepCollectionEquality()
            .equals(previousState.todo.keyValues, state.todo.keyValues)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildChips(
            context: context,
            tags: state.todo.formattedKeyValues,
            selectedTags: state.todo.formattedKeyValues,
          ),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new key:value tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}