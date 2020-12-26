import 'package:flutter/material.dart';

import 'db_provider.dart';
import 'models/product.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO LIST',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _refresh = GlobalKey<RefreshIndicatorState>();

  DBProvider dbProvider;

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createDialog();
        },
      ),
    );
  }

  _buildAppBar() => AppBar(
        title: Text("Todo list by Flutter"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _refresh.currentState.show();
              dbProvider.deleteAll();
            },
          )
        ],
      );

  _buildContent() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        setState(() {});
      },
      child: FutureBuilder(
        future: dbProvider.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Product> products = snapshot.data;
            if (products.length > 0) {
              return _buildListView(products.reversed.toList());
            }
            return Center(
              child: Text("NO DATA"),
            );
          }
          // loading....
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _buildListView(List<Product> product) => ListView.separated(
        itemBuilder: (context, position) {
          Product item = product[position];
          return CheckboxListTile(
            title: Text(
              "${item.title}",
              style: TextStyle(color: Colors.black),
            ),
            value: item.ischeck != 0,
            onChanged: (bool value) {
              if (item.ischeck == 0) {
                item.ischeck = 1;
              }else {
                item.ischeck = 0;
              }
              setState(() {
                dbProvider.updateProduct(product[position]).then((row) {
                  print(row.toString());
                });
              });
            },
            secondary: InkWell(
              onTap: () async {
                _refresh.currentState.show();
                dbProvider.deleteProduct(item.id);
                await Future.delayed(Duration(seconds: 2));
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Item deleted"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      _refresh.currentState.show();
                      dbProvider.insertProduct(item).then((value) {
                        print(product);
                      });
                    },
                  ),
                ));
              },
              child: Container(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
              ),
            ),
            subtitle: Text("detail: ${item.detail}"),
          );
        },
        separatorBuilder: (context, position) {
          return Divider();
        },
        itemCount: product.length,
      );

  _buildBody() => FutureBuilder(
        future: dbProvider.initDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildContent();
          }
          // loading....
          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error.toString())
                : CircularProgressIndicator(),
          );
        },
      );

  createDialog() {
    var _formKey = GlobalKey<FormState>();
    Product product = Product();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(hintText: "Title"),
                  onSaved: (value) {
                    product.title = value;
                    product.ischeck = 0;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: "Detail"),
                  onSaved: (value) {
                    product.detail = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (product.title.isNotEmpty) {
                          _refresh.currentState.show();
                          Navigator.pop(context);
                          dbProvider.insertProduct(product).then((value) {
                            print(product);
                          });
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
