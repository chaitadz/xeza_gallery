import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../xeza_bloc.dart';
import '../xeza_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void checkPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      debugPrint('Running on Android');
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      debugPrint('Running on iOS');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPlatform();
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<XezaBloc, XezaState>(
        builder: (context, state) {
          if (state is XezaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is XezaError) {
            return Center(child: Text(state.message));
          }

          if (state is XezaLoaded) {
            final xezaList = state.items;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: xezaList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = xezaList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(item: item),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.black,
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.center.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('ไม่มีข้อมูล'));
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final XezaItem item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              color: Colors.black,
              child: Image.network(item.imageUrl, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge('Center: ${item.center}', Colors.blue),
                      const SizedBox(width: 8),
                      _buildBadge('Date: ${item.dateCreated.split('T')[0]}', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(item.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.keywords.map((keyword) {
                      return Chip(label: Text('#$keyword'), labelStyle: const TextStyle(fontSize: 12));
                    }).toList(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}