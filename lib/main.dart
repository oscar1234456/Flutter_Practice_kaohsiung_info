import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'news.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _HttpPageState(),
    );
  }
}

class _HttpPageState extends StatefulWidget {
  @override
  _HttpPageStateState createState() => _HttpPageStateState();
}

class _HttpPageStateState extends State<_HttpPageState> {
  String content = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kaohsiung')),
      body: FutureBuilder<List<News>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.separated(
              itemBuilder: (context, index){
                return NewsWidget(news: snapshot.data[index]);
              },
              itemCount: snapshot.data.length,
              separatorBuilder: (_,__)=>Divider(
                height: 0.0,
              ),
            );
          } else
            return Center(child: CircularProgressIndicator());
        },
        future: getData,
      ),
    );
  }

  Future<List<News>> get getData async {
    List<News> list = [];
    var data = await http.get(
        "https://api.kcg.gov.tw/api/service/Get/02a18991-bed7-439a-867f-75d3e2920223");
    print(data.body);
    var map = json.decode(data.body);
    print(map['contentType']);
    for (var data in map['data']) {
      list.add(News(
          title: data['subject'],
          description: data['summary'],
          date: data["publishStartDate"],
          department: data["orgName"]));
    }
    return list;
  }
}

class NewsWidget extends StatelessWidget {
  final News news;

  const NewsWidget({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(
            CupertinoPageRoute(
            builder: (context){
              return Scaffold(
                appBar: AppBar(title:Text(news.title),),
                body: Text(news.description),

              );
            }
          )
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0,vertical: 5.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(news.title,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
              Container(
                margin: EdgeInsets.only(top:2.0),
                child: Row(
                  children: [
                    Text(news.department),
                    Expanded(child: Text(news.date,textAlign: TextAlign.end,)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
