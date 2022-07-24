import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Todo> deletPost(int id) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
  );
  if (response.statusCode == 200) {
    //print(' ${response.body} ${id}');
    return //true;
        Todo.fromJson(jsonDecode(response.body));
  } else {
    return throw Exception(
        'Failed to delet todo.${response.statusCode} with body ${jsonDecode(response.body)}');
  }
}

Future<Todo> fetchTodo() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Todo.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load todo');
  }
}

Future<Todo> createTodo(Todo todo) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/todos'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': todo.title!,
      'userId': todo.userId,
      'completed': todo.completed!
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    // print('create ${response.body}');
    return Todo.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

Future<List<Todo>> fetchTodos() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Iterable todoMap = jsonDecode(response.body);
    return List<Todo>.from(todoMap.map((e) => Todo.fromJson(e)));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load todo');
  }
}

Future<Todo> updateTodo(
  Todo todo,
) async {
  final response = await http.put(
    Uri.parse("https://jsonplaceholder.typicode.com/todos/${todo.id}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': todo.title!,
      'completed': todo.completed!,
      //'userId': todo.userId,
    }),
  );

  if (response.statusCode == 200) {
    //print('update ${response.body}');
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Todo.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update todo.');
  }
}

class Todo {
  int? id;
  String? title;
  String? completed;
  final String userId;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      id: json['id'],
      completed: json['completed'].toString(),
      userId: json['userId'].toString(),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Todo>> _futureTodos;
  int? indexg;

  bool _editing = false;

  Todo? _update;

  late List<Todo> todos;

  bool _saving = false;

  bool _new = false;
  @override
  void initState() {
    _futureTodos = fetchTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: const Text('Todo'),
          leading: _saving || !_editing
              ? null
              : IconButton(
                  onPressed: () => setState(() {
                    _controller.clear();
                    _editing = false;
                    _new = false;
                  }),
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        floatingActionButton: _new
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => setState(() {
                  _update = Todo(
                      id: null, title: null, completed: "false", userId: "1");
                  _controller.clear();
                  _editing = true;
                  _saving = false;
                  _new = false;
                }),
              ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: _editing
              ? _saving
                  ? const CircularProgressIndicator()
                  : ListTile(
                      leading: Checkbox(
                        value: _update!.completed == "false" ? false : true,
                        onChanged: (value) => setState(() {
                          _update!.completed = value.toString();
                        }),
                      ),
                      title: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter Title',
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          _update!.title = _controller.text;
                          _saving = true;

                          setState(() {});
                          if (_new == false) {
                            await createTodo(_update!).then((todo) {
                              todos.insert(0, todo);
                              _editing = false;
                              // _update = null;
                              _controller.clear();
                              _saving = false;

                              _new = false;
                              setState(() {});
                            });
                          } else {
                            if (_update!.id == 201) {
                              _update!.id = 1;
                            }
                            await updateTodo(_update!).then((todo) {
                              int index = todos.indexWhere(
                                  (element) => element.id == _update!.id);

                              todos[index] = todo;
                              _editing = false;
                              _update = null;
                              _controller.clear();
                              _saving = false;
                              _new = false;
                            });
                          }
                          setState(() {});
                        },
                        child: const Text('Save'),
                      ),
                    )
              : FutureBuilder<List<Todo>>(
                  future: _futureTodos,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        todos = snapshot.data!;
                        return ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            indexg = index;
                            return ListTile(
                                title: todos[index].completed == "false"
                                    ? Text(todos[index].title!)
                                    : Text(todos[index].title!,
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                        )),
                                onTap: () {
                                  _editing = true;
                                  _saving = false;
                                  _new = true;
                                  _controller.text = todos[index].title!;
                                  if (_saving == false) {
                                    _update = Todo(
                                        id: todos[index].id,
                                        title: todos[index].title,
                                        completed: todos[index].completed,
                                        userId: todos[index].userId);
                                    setState(() {});
                                  }
                                },
                                trailing: IconButton(
                                  onPressed: () {
                                    deletPost(todos[index].id!).then((todo) {
                                      todos.remove(todos[index]);

                                      setState(() {});
                                    });
                                  },
                                  icon: const Icon(Icons.delete_forever),
                                ));
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                    }

                    return const CircularProgressIndicator();
                  },
                ),
        ),
      ),
    );
  }
}
