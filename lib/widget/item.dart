import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {

  final String id;
  final String title;
  final String body;
  final bool isSelected;
  final bool Function(bool?)? onChanged;


  PostItem(this.title, this.body, this.isSelected, this.onChanged, this.id);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.amber
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value){
                onChanged?.call(value);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                    ),),
                  const SizedBox(height: 10,),
                  Text(body,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 15
                    ),)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}