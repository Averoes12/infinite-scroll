import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/post.dart';
import '../widget/item.dart';


class InfiniteScrollPaginatorDemo extends StatefulWidget {
  const InfiniteScrollPaginatorDemo({super.key});

  @override
  State<InfiniteScrollPaginatorDemo> createState() => _InfiniteScrollPaginatorDemoState();
}

class _InfiniteScrollPaginatorDemoState extends State<InfiniteScrollPaginatorDemo> {

  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Post> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$pageKey&_limit=$_numberOfPostsPerRequest"));
      List responseList = json.decode(response.body);
      List<Post> postList = responseList.map((data) =>
          Post(data['title'], data['body'], data['id'], false)).toList();
      final isLastPage = postList.length < _numberOfPostsPerRequest;
      if (isLastPage) {
        _pagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(postList, nextPageKey);
      }
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Blog App"), centerTitle: true,),
      body: Column(
        children: [
          TextFormField(
            onFieldSubmitted: (value){},
          ),
          Expanded(
            child: PagedListView<int, Post>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) =>
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: PostItem(
                          item.title, item.body, false, (value) => value!, item.id.toString()
                      ),
                    ),

              ),

            ),
          ),
        ],
      ),
    );
  }

}
