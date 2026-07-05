// lib/guides/BLOC_ACCESS_GUIDE.md
// 🎯 วิธีการเรียก BLoC จากพื้นที่ต่างๆ ของแอป

/*
========================================
3 วิธีการเรียก BLoC จาก DetailScreen
========================================
*/

// ✅ วิธี 1: context.read<NasaBlocBloc>() [RECOMMENDED]
// ใช้เมื่อ: ต้องเรียก method ครั้งเดียว (event dispatch)
// สิ่งสำคัญ: ไม่ rebuild when state changes

void favoriteButtonPressed() {
  context.read<NasaBlocBloc>().add(AddToFavorite(item));
  // ✅ ง่าย, มีประสิทธิภาพ, ไม่rebuild
}

/*
========================================
*/

// ✅ วิธี 2: BlocProvider.of<NasaBlocBloc>(context)
// ใช้เมื่อ: ต้อง access BLoC property หลายครั้ง
// สิ่งสำคัญ: ให้ผลลัพธ์เดียวกับ context.read() แต่ verbose กว่า

void anotherAction() {
  final bloc = BlocProvider.of<NasaBlocBloc>(context);
  bloc.add(AddToFavorite(item));
  bloc.add(RemoveFromFavorite(item.title)); // สามารถเรียกได้หลายครั้ง
}

/*
========================================
*/

// ✅ วิธี 3: BlocBuilder (สำหรับ reactive updates)
// ใช้เมื่อ: widget ต้อง rebuild when state changes
// ตัวอย่าง: ไอคอน favorite ต้อง update เมื่อ add/remove

@override
Widget build(BuildContext context) {
  return BlocBuilder<NasaBlocBloc, NasaBlocState>(
    builder: (context, state) {
      bool isFavorited = false;
      
      if (state is NasaBlocLoaded) {
        isFavorited = state.isFavorited(item.title);
      }

      return IconButton(
        icon: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : null,
        ),
        onPressed: () {
          // ✅ ตรงนี้เรียก BLoC
          context.read<NasaBlocBloc>().add(AddToFavorite(item));
        },
      );
    },
  );
}

/*
========================================
⚠️ IMPORTANT RULES
========================================
*/

// ❌ WRONG: สร้าง BLoC ใหม่ใน button callback
onPressed: () {
  NasaBlocBloc newBloc = NasaBlocBloc(repository); // ❌ สร้างใหม่!
  newBloc.add(AddToFavorite(item)); // State ของใหม่ ไม่ synchronized
}

// ✅ RIGHT: อ้างอิง BLoC เดิม
onPressed: () {
  context.read<NasaBlocBloc>().add(AddToFavorite(item)); // ✅ ใช้เดิม
}

/*
========================================
Flow ที่ควรเข้าใจ
========================================

1. main.dart: BlocProvider สร้าง BLoC (เก็บไว้ใน tree)
   
2. MyHomePage: GridView.builder → ผ่าน NasaImageCard

3. NasaImageCard.onTap:
   Navigator.push(
     MaterialPageRoute(
       builder: (context) => DetailScreen(item: item),
     ),
   )
   → DetailScreen ถูก push เข้ามา

4. DetailScreen: 
   ⚠️ ได้ context ใหม่จาก Navigator
   ❌ แต่ยังเข้าถึง BLoC parent ได้!
   
   เพราะว่า: DetailScreen.build(context) ได้ context 
            แต่ context tree ยังชี้ไป parent ที่มี BlocProvider
   
   ดังนั้น: context.read<NasaBlocBloc>() ก็ยังค้นหาได้

/*
========================================
ทำไม context.read() ทำงานได้?
========================================

Widget Tree:
  MyApp
    └─ BlocProvider<NasaBlocBloc>  ← BLoC อยู่ตรงนี้
       └─ MaterialApp
          └─ Home: MyHomePage
             └─ Navigator
                └─ DetailScreen  ← context เป็น child ของ BlocProvider!

เมื่อ DetailScreen เรียก context.read<NasaBlocBloc>():
  → Flutter ค้นหา parent tree ขึ้นไปจาก DetailScreen
  → เจอ BlocProvider
  → Return ตัว BLoC นั้น!

ดังนั้นการ navigate ไม่ทำให้หลุดจาก BLoC tree!
*/

/*
========================================
Pattern ที่ดี
========================================
*/

class DetailScreen extends StatelessWidget {
  final NasaItem item;
  
  const DetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          // ✅ Pattern 1: BlocBuilder สำหรับ reactive
          BlocBuilder<NasaBlocBloc, NasaBlocState>(
            builder: (context, state) {
              final isFavorited = 
                state is NasaBlocLoaded 
                  ? state.isFavorited(item.title)
                  : false;

              return IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : null,
                ),
                // ✅ Pattern 2: context.read() สำหรับ dispatch
                onPressed: () {
                  context.read<NasaBlocBloc>()
                    .add(AddToFavorite(item));
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... image ...
            
            // ✅ Pattern 3: Separate button
            ElevatedButton(
              onPressed: () {
                // ✅ เรียก event อื่น
                context.read<NasaBlocBloc>()
                  .add(RemoveFromFavorite(item.title));
              },
              child: Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }
}