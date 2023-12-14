import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_list_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';

class TodoListPageMaterialApp extends StatelessWidget {
  final File todoFile;
  final Filter? filter;

  const TodoListPageMaterialApp({
    required this.todoFile,
    this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (BuildContext context) {
        return TodoListRepository(
          api: LocalTodoListApi(todoFile: todoFile),
        );
      },
      child: Builder(
        builder: (BuildContext context) {
          return BlocProvider(
            create: (BuildContext context) => TodoListBloc(
              repository: context.read<TodoListRepository>(),
            )
              ..add(const TodoListSubscriptionRequested())
              ..add(const TodoListSynchronizationRequested()),
            child: MaterialApp(
              home: TodoListPage(filter: filter),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  final MemoryFileSystem fs = MemoryFileSystem();
  late File file;
  late Filter filter;

  setUp(() async {});

  group('Order', () {
    setUp(() async {
      file = fs.file('todoOrder.txt');
      await file.create();
      await file.writeAsString(
        [
          '2023-12-02 TodoC',
          '2023-12-02 TodoA',
          '2023-12-02 TodoB',
        ].join('\n'),
        flush: true,
      );
    });

    group('ascending', () {
      setUp(() async {
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        );
      });

      testWidgets('by filter', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(TodoListTile), findsNWidgets(3));
        Iterable<TodoListTile> todoTiles =
            tester.widgetList<TodoListTile>(find.byType(TodoListTile));
        expect(todoTiles.elementAt(0).todo.description, 'TodoA');
        expect(todoTiles.elementAt(1).todo.description, 'TodoB');
        expect(todoTiles.elementAt(2).todo.description, 'TodoC');
      });
    });

    group('descending', () {
      setUp(() async {
        filter = const Filter(
          order: ListOrder.descending,
          filter: ListFilter.all,
          group: ListGroup.none,
        );
      });

      testWidgets('by filter', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(TodoListTile), findsNWidgets(3));
        Iterable<TodoListTile> todoTiles =
            tester.widgetList<TodoListTile>(find.byType(TodoListTile));
        expect(todoTiles.elementAt(0).todo.description, 'TodoC');
        expect(todoTiles.elementAt(1).todo.description, 'TodoB');
        expect(todoTiles.elementAt(2).todo.description, 'TodoA');
      });
    });
  });

  group('Filter', () {
    setUp(() async {
      file = fs.file('todoFilter.txt');
      await file.create();
      await file.writeAsString(
        [
          'x 2023-12-04 2023-12-02 TodoC',
          '2023-12-02 TodoA',
          'x 2023-12-03 2023-12-02 TodoB',
        ].join('\n'),
        flush: true,
      );
    });

    group('all', () {
      setUp(() async {
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        );
      });

      testWidgets('by filter', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(TodoListTile), findsNWidgets(3));
        Iterable<TodoListTile> todoTiles =
            tester.widgetList<TodoListTile>(find.byType(TodoListTile));
        expect(todoTiles.elementAt(0).todo.description, 'TodoA');
        expect(todoTiles.elementAt(1).todo.description, 'TodoB');
        expect(todoTiles.elementAt(2).todo.description, 'TodoC');
      });
    });

    group('completed only', () {
      setUp(() async {
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.completedOnly,
          group: ListGroup.none,
        );
      });

      testWidgets('by filter', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(TodoListTile), findsNWidgets(2));
        Iterable<TodoListTile> todoTiles =
            tester.widgetList<TodoListTile>(find.byType(TodoListTile));
        expect(todoTiles.elementAt(0).todo.description, 'TodoB');
        expect(todoTiles.elementAt(1).todo.description, 'TodoC');
      });
    });

    group('incompleted only', () {
      setUp(() async {
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.incompletedOnly,
          group: ListGroup.none,
        );
      });

      testWidgets('by filter', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(TodoListTile), findsNWidgets(1));
        Iterable<TodoListTile> todoTiles =
            tester.widgetList<TodoListTile>(find.byType(TodoListTile));
        expect(todoTiles.elementAt(0).todo.description, 'TodoA');
      });
    });
  });

  group('Group by', () {
    setUp(() async {});

    group('none', () {
      setUp(() async {
        file = fs.file('todoGroupByNone.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-13-04 2023-12-02 TodoB',
            '2023-12-02 TodoA',
          ].join('\n'),
          flush: true,
        );
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        );
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(ExpansionTile), findsNWidgets(1));
        Iterable<ExpansionTile> todoListSections =
            tester.widgetList<ExpansionTile>(find.byType(ExpansionTile));
        expect((todoListSections.elementAt(0).title as Text).data, 'All');

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching:
                find.text('TodoA'), // 'TodoA' is undone but in group 'All'.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoB'), // 'TodoB' is done but in group 'All'.
          ),
          findsOneWidget,
        );
      });
    });

    group('upcoming', () {
      setUp(() async {
        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final String tomorrow =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}';

        file = fs.file('todoGroupByUpcoming.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-12-03 2023-12-02 TodoA',
            '1970-01-01 TodoB due:1970-01-01',
            '2023-12-02 TodoC due:$today',
            '2023-12-02 TodoD due:$tomorrow',
            '2023-12-02 TodoE',
          ].join('\n'),
          flush: true,
        );
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.upcoming,
        );
      });

      testWidgets('check sections', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(ExpansionTile), findsNWidgets(4));
        Iterable<ExpansionTile> todoListSections =
            tester.widgetList<ExpansionTile>(find.byType(ExpansionTile));
        expect((todoListSections.elementAt(0).title as Text).data,
            'Deadline passed');
        expect((todoListSections.elementAt(1).title as Text).data, 'Today');
        expect((todoListSections.elementAt(2).title as Text).data, 'Upcoming');
        expect(
            (todoListSections.elementAt(3).title as Text).data, 'No deadline');

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoB'), // 'TodoB's deadline is passed.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoC'), // 'TodoC' is today.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' is upcoming.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching: find.text('TodoE'), // 'TodoE' has no deadline.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching:
                find.text('TodoA'), // 'TodoA' is done but has no deadline.
          ),
          findsOneWidget,
        );
      });
    });

    group('priority', () {
      setUp(() async {
        file = fs.file('todoGroupByPriority.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-13-04 2023-12-02 TodoA',
            '(E) 2023-12-02 TodoB',
            '(F) 2023-12-02 TodoC',
            '2023-12-02 TodoD',
          ].join('\n'),
          flush: true,
        );
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.priority,
        );
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(ExpansionTile), findsNWidgets(3));
        Iterable<ExpansionTile> todoListSections =
            tester.widgetList<ExpansionTile>(find.byType(ExpansionTile));
        expect((todoListSections.elementAt(0).title as Text).data, 'E');
        expect((todoListSections.elementAt(1).title as Text).data, 'F');
        expect(
            (todoListSections.elementAt(2).title as Text).data, 'No priority');

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoB'), // 'TodoB' has priority E.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoC'), // 'TodoC' has priority F.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' has no priority.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching:
                find.text('TodoA'), // 'TodoA' is done but has no priority.
          ),
          findsOneWidget,
        );
      });
    });

    group('project', () {
      setUp(() async {
        file = fs.file('todoGroupByProject.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-13-04 2023-12-02 TodoC',
            '2023-12-02 TodoA +project1',
            '2023-12-02 TodoB +project2',
            '2023-12-02 TodoD',
          ].join('\n'),
          flush: true,
        );
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.project,
        );
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(ExpansionTile), findsNWidgets(3));
        Iterable<ExpansionTile> todoListSections =
            tester.widgetList<ExpansionTile>(find.byType(ExpansionTile));
        expect((todoListSections.elementAt(0).title as Text).data, 'project1');
        expect((todoListSections.elementAt(1).title as Text).data, 'project2');
        expect(
            (todoListSections.elementAt(2).title as Text).data, 'No project');

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoA'), // 'TodoA' containts project1.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoB'), // 'TodoB' contains project2.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' contains no project.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoC'), // 'TodoC' is done but has no project.
          ),
          findsOneWidget,
        );
      });
    });

    group('context', () {
      setUp(() async {
        file = fs.file('todoGroupByContext.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-13-04 2023-12-02 TodoC',
            '2023-12-02 TodoA @context1',
            '2023-12-02 TodoB @context2',
            '2023-12-02 TodoD',
          ].join('\n'),
          flush: true,
        );
        filter = const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.context,
        );
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(TodoListPageMaterialApp(
          todoFile: file,
          filter: filter,
        ));
        await tester.pump();

        expect(find.byType(ExpansionTile), findsNWidgets(3));
        Iterable<ExpansionTile> todoListSections =
            tester.widgetList<ExpansionTile>(find.byType(ExpansionTile));
        expect((todoListSections.elementAt(0).title as Text).data, 'context1');
        expect((todoListSections.elementAt(1).title as Text).data, 'context2');
        expect(
            (todoListSections.elementAt(2).title as Text).data, 'No context');

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoA'), // 'TodoA' containts context1.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoB'), // 'TodoB' contains context2.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' contains no context.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoC'), // 'TodoC' is done but has no context.
          ),
          findsOneWidget,
        );
      });
    });
  });
}
