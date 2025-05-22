//   List<Map<String, TextEditingController>> rows = [];

//   void _addRow() {
//     setState(() {
//       rows.add({
//         'field1': TextEditingController(),
//         'field2': TextEditingController(),
//       });
//     });
//   }
  
//   // "row.asMap" make it a map where key is index and value is the map
//   // "entries" store list of pair<key, value>
//   // "entries.map((entry){})" entry is a pair
//   children: rows.asMap().entries.map((entry) {
//   int index = entry.key;
//   Map<String, TextEditingController> controllers = entry.value;

//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 5),
//     child: Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(right: 8.0),
//           child: Text(
//             '${index + 1}.',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           child: TextField(
//             controller: controllers['field1'],
//             decoration: const InputDecoration(
//               hintText: 'Field 1',
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: TextField(
//             controller: controllers['field2'],
//             decoration: const InputDecoration(
//               hintText: 'Field 2',
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }).toList(),
