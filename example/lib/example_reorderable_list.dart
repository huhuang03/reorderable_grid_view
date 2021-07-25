import 'package:flutter/material.dart';

class ExampleReorderableList extends StatefulWidget {
  @override
  _ExampleReorderableListState createState() => _ExampleReorderableListState();
}

class _ExampleReorderableListState extends State<ExampleReorderableList> {
   final List<int> _items = List<int>.generate(50, (int index) => index);

   @override
   Widget build(BuildContext context){
     final ColorScheme colorScheme = Theme.of(context).colorScheme;
     final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
     final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

     return ReorderableListView(
       padding: const EdgeInsets.symmetric(horizontal: 40),
       children: <Widget>[
         for (int index = 0; index < _items.length; index++)
           ListTile(
             key: Key('$index'),
             tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
             title: Text('Item ${_items[index]}'),
           ),
       ],
       onReorder: (int oldIndex, int newIndex) {
         setState(() {
           if (oldIndex < newIndex) {
             newIndex -= 1;
           }
           final int item = _items.removeAt(oldIndex);
           _items.insert(newIndex, item);
         });
       },
     );
   }

}
