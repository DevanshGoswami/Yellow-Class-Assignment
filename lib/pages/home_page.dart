import 'package:flutter/material.dart';
import '../controllers/_dbHelper.dart';
import '../models/movie.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CrudApp extends StatefulWidget {
  @override
  CrudAppState createState() => CrudAppState();
}

class CrudAppState extends State<CrudApp> {

  int? selectedId;



  void _pushAddForm() {
    String? _name;
    String? _director;
    String? _poster;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


    Widget _form() {
      return Form(

          key: _formKey,
          child: Column(children: [
            Padding(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Name is required.';
                  }
                },
                onSaved: (String? value) {
                  _name = value;
                },
              ),
              padding: EdgeInsets.all(10.0),
            ),
            Padding(
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Director',
                      border: OutlineInputBorder(),
                      focusColor: Colors.amber[400]),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Name of director is required.';
                    }
                  },
                  onSaved: (String? value) {
                    _director = value;
                  },
                ),
                padding: EdgeInsets.all(10.0)),
            Padding(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Poster URL',
                    border: OutlineInputBorder(),
                    focusColor: Colors.amber[400]),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Poster URL is Required.';
                  }
                },
                onSaved: (String? value) {
                  _poster = value;
                },
              ),
              padding: EdgeInsets.all(10.0),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if(selectedId != null){
                      await DatabaseHelper.instance.update(
                        Movie(selectedId, _name, _director, _poster)
                      );
                    }
                    else {
                      int currentID = UniqueKey().hashCode;
                      await DatabaseHelper.instance.add(
                          Movie(currentID, _name, _director, _poster)
                      );
                    }

                    Fluttertoast.showToast(
                      msg: selectedId != null ? "Movie Updated":"Movie Added",
                      toastLength: Toast.LENGTH_SHORT,
                      textColor: Colors.black,
                      fontSize: 16,
                      backgroundColor: Colors.grey[200],
                    );

                    _formKey.currentState!.reset();
                  }
                },
                child: Text(selectedId != null ? 'Update':'Add'))
          ]));
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(appBar: AppBar(title: Text(selectedId !=null ? 'Update Movie':'Add Movie'), automaticallyImplyLeading: false, leading: Builder(
        builder: (context) => IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> CrudApp()));
            }),
      ),), body: _form());
    }));
  }

  Widget _buildListView() {
    return FutureBuilder<List<Movie>>(
      future: DatabaseHelper.instance.getMovies(),
      builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Loading..'),
          );
        }
        return snapshot.data!.isEmpty
            ? Center(
                child: Text('No Movies in List'),
              )
            : ListView(
                children: snapshot.data!.map((movie) {
                  return Card(child: Row(
                    children: [
                      Image(image: NetworkImage(movie.poster.toString()), width: 100,height: 150,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.all(14),
                            child: Text(movie.name.toString(), style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),),

                          Padding(padding: EdgeInsets.all(14),
                            child: Text(movie.director.toString(), style: const TextStyle(fontWeight: FontWeight.w300)),),

                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            IconButton(icon: Icon(Icons.delete, color: Colors.red,), onPressed: () {
                              setState(() {
                                DatabaseHelper.instance.remove(movie.id);
                              });
                            }),
                            IconButton(icon: Icon(Icons.edit, color: Colors.amber,), onPressed: () {
                              setState(() {
                                selectedId = movie.id;
                              });
                              _pushAddForm();
                            })
                          ])
                        ],
                      )
                    ],
                  ));
                }).toList(),
              );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Movie WatchList')),
        body: Center(child: _buildListView()),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _pushAddForm,
        ));
  }
}
