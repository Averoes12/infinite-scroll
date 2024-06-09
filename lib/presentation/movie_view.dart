import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/post.dart';
import '../widget/item.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final _numberOfPostsPerRequest = 10;
  List<dynamic> _list = [];
  List<dynamic> _filteredList = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 2;
  bool hasMore = true;
  int limit = 20;
  bool isSearching = false;
  List<Map<String, dynamic>> selectedList = [];
  List<bool> isChecked = [];
  bool? isCheckAll = false;
  bool isTriState = false;
  List<Map<String, dynamic>> testList = [];

  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _fetchPage(0).then((value) {
      _filteredList = value;
      for (final e in _filteredList) {
        testList.add({"id": e.id, "isSelected": false});
      }
    });
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        final list = await _fetchPage(currentPage);
        if (list.isNotEmpty) {
          for (final e in list) {
            if(_filteredList.where((element) => element.id == e.id).isEmpty){
              _filteredList.add(e);
              testList.add({"id": e.id, "isSelected": false});
            }
          }

          setState(() {
            if(testList.where((element) => element['isSelected']).isEmpty){
              isTriState = false;
              isCheckAll = false;
            } else if (testList.where((element) => element['isSelected']).length !=
                _filteredList.length) {
              isTriState = true;
              isCheckAll = null;
            } else {
              isTriState = false;
              isCheckAll = true;
            }
            currentPage++;
          });
        } else {
          setState(() {
            hasMore = false;
          });
        }
        if (isSearching) {
          final newList = _filteredList
              .where((element) => element.title
                  .toString()
                  .toLowerCase()
                  .contains(_searchController.text.toString().toLowerCase()))
              .toList();
          if (newList.isNotEmpty) {
            for(final e in newList){
              if(!_filteredList.contains(e)){
                _filteredList.add(e);
              }
            }
            hasMore = true;
          } else {
            _filteredList = [];
            hasMore = false;
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchPage(int pageKey) async {
    try {
      final response = await get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$pageKey&_limit=$_numberOfPostsPerRequest"));
      List responseList = json.decode(response.body);
      List<Post> postList = responseList.map((data) {
        return Post(data['title'], data['body'], data['id'], false);
      }).toList();
      _list = [];
      setState(() {
        _list = postList;
        hasMore = true;
      });
      return _list;
    } catch (e) {
      print("error --> $e");
      _pagingController.error = e;
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie Catalog"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isCheckAll,
                tristate: isTriState,
                onChanged: (value) {
                  setState(() {
                    isTriState = false;
                    isCheckAll = value;
                    if (value != null && value) {
                      for (int i = 0; i < _filteredList.length; i++) {
                        testList[i]["isSelected"] = true;
                      }
                    } else {
                      for (int i = 0; i < _filteredList.length; i++) {
                        testList[i]["isSelected"] = false;
                      }
                    }
                  });
                },
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                  "${testList.where((element) => element['isSelected']).length} Produk Terpilih")
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          TextFormField(
            controller: _searchController,
            onFieldSubmitted: (value) {
              currentPage = 2;
              if (value.isEmpty) {
                setState(() {
                  isSearching = false;
                  hasMore = true;
                  _filteredList.clear();
                  _list.clear();
                  _fetchPage(currentPage - 1)
                      .then((value) {
                        for(final e in value){
                          if(!_filteredList.contains(e)){
                            _filteredList.add(e);
                          }
                        }
                      });
                });
              }
              setState(() {
                isSearching = true;
                final newList = _filteredList
                    .where((element) => element.title
                        .toString()
                        .toLowerCase()
                        .contains(value.toString().toLowerCase()))
                    .toList();
                if (newList.isNotEmpty) {
                  _filteredList.clear();
                  _filteredList = newList;
                  hasMore = false;
                } else {
                  _filteredList = [];
                  hasMore = false;
                }
              });
              _scrollController.jumpTo(0.0);
            },
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _filteredList.length,
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              final item = _filteredList[index];
              final testChecked =
                  testList.firstWhere((element) => element["id"] == item.id);
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: InkWell(
                  onTap: () {
                    print("ITEM ID => ${item.id}");
                  },
                  child:
                      PostItem(item.title, item.body, testChecked['isSelected'],
                          (value) {
                    setState(() {
                      testChecked['isSelected'] = value!;
                      
                      if (testList.where((element) => element['isSelected']).length != _filteredList.length) {
                        isTriState = true;
                        isCheckAll = null;
                      } else {
                        isTriState = false;
                        isCheckAll = true;
                      }
                    });
                    return value!;
                  }, item.id.toString()),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
