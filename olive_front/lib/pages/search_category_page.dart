import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:untitled/pages/add_book_page.dart';
import 'package:untitled/functions/recommend_functions.dart';
import 'package:untitled/functions/user_info.dart';


class SearchCategoryPage extends StatefulWidget {
  final VoidCallback onBookAdded;
  final Map<String, dynamic>? selectedBook;
  List<Category>? selectedCategories;
  final List<YoutubeVideoInfo> youtubeInfos;
  SearchCategoryPage({Key? key, required this.onBookAdded, required this.youtubeInfos, required this.selectedBook, required this.selectedCategories}) : super(key: key);

  @override
  _SearchCategoryPageState createState() => _SearchCategoryPageState();
}

class Category extends ChangeNotifier {
  String name;
  bool isChecked;

  Category({required this.name, this.isChecked = false});

  void toggleCheck() {
    isChecked = !isChecked;
    notifyListeners();
  }
}

class _SearchCategoryPageState extends State<SearchCategoryPage> {
  List<Category> _categories = userInfo!.categories.map((category) => Category(name: category.categoryName)).toList();

  List<Category> _selectedCategories = []; // 체크된 카테고리를 담을 리스트

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // AddBookPage에서 전달받은 선택된 카테고리 정보를 기반으로 체크 표시를 설정합니다.
      _categories.forEach((category) {
        if (widget.selectedCategories != null && widget.selectedCategories!.contains(category.name)) {
          category.isChecked = true;
        }
      });
      _showDialog();
    });
  }


  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _selectedCategories = _categories.where((category) => category.isChecked).toList();
            if (_selectedCategories.isEmpty) {
              Fluttertoast.showToast(
                msg: "카테고리를 선택해주세요!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return Future.value(false); // Prevent the pop-up from being closed.
            }
            return Future.value(true); // Allow the pop-up to be closed.
          },
          child: AlertDialog(
            title: Text('카테고리 선택하기'),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                children: _categories.map((category) => CategoryItem(category)).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  _selectedCategories = _categories.where((category) => category.isChecked).toList();
                  if (_selectedCategories.isNotEmpty) {
                    Navigator.of(context).pop(_selectedCategories);
                  }
                },
              ),
            ],
          ),
        );
      },
    ).then((selectedCategories) {
      // This will be called when the dialog is closed, and selectedCategories will hold the list of selected categories.
      // Navigate to the AddBookPage with the selected categories
      if (selectedCategories != null && selectedCategories.isNotEmpty)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
              AddBookPage(
                onBookAdded: widget.onBookAdded,
                youtubeInfos: widget.youtubeInfos,
                selectedBook: widget.selectedBook,
                selectedCategories: selectedCategories,
              ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }


//@override
  //Widget build(BuildContext context) {
    //return AlertDialog();
  //}
}

class CategoryItem extends StatefulWidget {
  final Category category;

  CategoryItem(this.category);

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.category.name),
      value: widget.category.isChecked,
      onChanged: (bool? value) {
        setState(() {
          widget.category.toggleCheck();
        });
      },
    );
  }
}
