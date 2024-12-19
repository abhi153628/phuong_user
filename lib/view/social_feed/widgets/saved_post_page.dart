// class SavedPostsPage extends StatelessWidget {
//   const SavedPostsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           'Saved Posts',
//           style: GoogleFonts.syne(
//             color: const Color(0xFFAFEB2B),
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFFAFEB2B)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         elevation: 0,
//       ),
//       body: StreamBuilder<List<Post>>(
//         stream: // TODO: Add your saved posts stream here,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.bookmark_border,
//                     color: Color(0xFFAFEB2B),
//                     size: 48,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No saved posts yet',
//                     style: GoogleFonts.notoSans(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) => _PostCard(post: snapshot.data![index]),
//           );
//         },
//       ),
//     );
//   }
// }
// Last edited just now