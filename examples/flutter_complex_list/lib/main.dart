import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_complex_list/bloc/bloc.dart';
import 'package:flutter_complex_list/models/models.dart';
import 'package:flutter_complex_list/repository.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Complex List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Complex List'),
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Repository _repository = Repository();
  ListBloc _listBloc;

  @override
  void initState() {
    super.initState();
    _listBloc = ListBloc(repository: _repository);
    _listBloc.dispatch(Fetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _listBloc,
      builder: (BuildContext context, ListState state) {
        if (state is Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is Failure) {
          return Center(
            child: Text('Oops something went wrong!'),
          );
        }
        if (state is Loaded) {
          if (state.items.isEmpty) {
            return Center(
              child: Text('no content'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ItemTile(
                item: state.items[index],
                onDeletePressed: (id) {
                  _listBloc.dispatch(Delete(id: id));
                },
              );
            },
            itemCount: state.items.length,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _listBloc.dispose();
    super.dispose();
  }
}

class ItemTile extends StatelessWidget {
  final Item item;
  final Function(String) onDeletePressed;

  const ItemTile({
    Key key,
    @required this.item,
    @required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('#${item.id}'),
      title: Text(item.value),
      trailing: item.isDeleting
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeletePressed(item.id),
            ),
    );
  }
}
