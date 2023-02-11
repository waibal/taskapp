import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskapp/modules/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  int selectedIndex = 0;

  String? _newTaskContent;
  Box? _box;

  _HomePageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    //print("Input Value: $_newTaskContent");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //toolbarHeight: _deviceHeight * 0.1,
        backgroundColor: const Color.fromARGB(121, 255, 87, 146),
        title: const Text(("Todos"),
            style: TextStyle(
                fontSize: 20, fontFamily: 'BebasNeue', color: Colors.white)),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (index) => setState(() {
                selectedIndex = index;
              }),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.fact_check_outlined), label: "Todos"),
            BottomNavigationBarItem(
                icon: Icon(Icons.done, size: 28), label: "Completed")
          ]),
    );
  }

  Widget _taskView() {
    Hive.openBox('tasks');
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.connectionState == ConnectionState.done) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(task.timestamp.toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _box!.deleteAt(index);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
        onPressed: _displayTaskPopup,
        child: const Icon(
          Icons.add,
        ));
  }

  FocusNode focusNode = FocusNode();

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add New Task!"),
          content: TextField(
            autofocus: true,
            onSubmitted: (_value) {
              if (_newTaskContent != null) {
                var task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(task.toMap());
                setState(() {
                  _newTaskContent = null;
                });
              }
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
                //Navigator.pop(_context);
              });
            },
          ),
        );
      },
    );
  }
}
