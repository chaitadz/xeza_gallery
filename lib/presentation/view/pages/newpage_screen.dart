import 'package:flutter/material.dart';

class NewPageScreen extends StatelessWidget {
  const NewPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จ่ายบิลเบอร์ที่สิ้นสุดบริการ'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF333333),
      ),
      body: Container(
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF212121),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'This is the New Page Screen',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}