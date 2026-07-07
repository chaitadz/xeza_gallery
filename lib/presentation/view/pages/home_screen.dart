import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/presentation/view/widgets/nasa_image_card.dart';
import '../../bloc/nasa/nasa_bloc_bloc.dart';
import 'detail_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<NasaBlocBloc>().add(FetchNasaImages());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<NasaBlocBloc, NasaBlocState>(
        builder: (context, state) {
          // ====== loading state
          if (state is NasaBlocLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // =========================================

          // ====== error state
          if (state is NasaBlocError) {
            return Center(child: Text(state.message));
          }
          // =========================================

          // ====== loaded state
          if (state is NasaBlocLoaded) {
            final nasaList = state.items;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: nasaList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = nasaList[index];
                  return NasaImageCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            item: item,
                            //callBackRoute: 'main'
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          // =========================================
          
          // ====== unknown state
          return const Center(child: Text('ไม่มีข้อมูล'));
        },
      ),
    );
  }
}
