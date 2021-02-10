import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatefulWidget {
  ResultsPage();

  _ResultsPage createState() => _ResultsPage();
}

class _ResultsPage extends State<ResultsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results"),),
      body: SafeArea(
        child: FutureBuilder(
          future: context.read<User>().showAnswers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Getting Results");
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) { 
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    child: Text(snapshot.data[index])
                  );
                },
              );
            }
          }
        )
      )
    );
  }
  
}