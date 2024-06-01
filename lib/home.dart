import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final url = 'https://dummyjson.com/users/';
  int skip = 0;
  final int limit = 15;
  bool isFirstloadingisRenning = false;
  bool isMoreloadingisRenning = false;
  List post = [];
  bool hasNextPage = true;

  firstLoad() async {
    setState(() {
      isFirstloadingisRenning = true;
    });
    try {
      final res = await http.get(Uri.parse("$url?limit=$limit&skip=$skip"));
      setState(() {
        post = json.decode(res.body)['users'];
      });
    } catch (e) {
      rethrow;
    }
    setState(() {
      isFirstloadingisRenning = false;
    });
  }

  loadMore() async {
    if (hasNextPage == true &&
        isFirstloadingisRenning == false &&
        isMoreloadingisRenning == false) {
      setState(() {
        isMoreloadingisRenning = true;
      });
      skip += 10;
      try {
        final res = await http.get(Uri.parse("$url?limit=$limit&skip=$skip"));
        final List fetchedpost = json.decode(res.body)['users'];
        if (fetchedpost.isNotEmpty) {
          setState(() {
            post.addAll(fetchedpost);
          });
        } else {
          hasNextPage = false;
        }
      } catch (e) {
        rethrow;
      }
      setState(() {
        isMoreloadingisRenning = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: isFirstloadingisRenning
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                      child: RefreshIndicator(
                    onRefresh: () => loadMore(),
                    child: ListView.builder(
                      itemCount: post.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(post[index]['firstName']),
                      ),
                    ),
                  )),
                  if (isMoreloadingisRenning == true)
                    CircularProgressIndicator()
                ],
              ));
  }
}
