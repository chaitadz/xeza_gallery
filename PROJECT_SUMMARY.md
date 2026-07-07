# สรุปโปรเจกต์ xeza_gallery — อธิบายทุกไฟล์

---

## โครงสร้างโฟลเดอร์

```
lib/
├── main.dart
├── injection_container.dart
├── core/
│   ├── constants/api_constants.dart              # (ว่างเปล่า)
│   ├── errors/
│   │   ├── exceptions.dart                       # (ว่างเปล่า)
│   │   └── failures.dart                         # (ว่างเปล่า)
│   ├── network/dio_client.dart                   # (ว่างเปล่า)
│   ├── storage/favorites_storage.dart            # เก็บรายการโปรดใน local storage
│   └── theme/app_theme.dart                      # กำหนดธีม Dark
└── features/
    ├── nasa_gallery/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── nasa_remote_data_source.dart          # interface
    │   │   │   └── nasa_remote_data_source_impl.dart     # ดึงข้อมูลจาก NASA API
    │   │   └── models/nasa_item_model.dart               # Model + JSON parse
    │   ├── domain/
    │   │   ├── entities/nasa_item.dart           # Entity หลัก
    │   │   ├── repositories/
    │   │   │   ├── nasa_repository.dart          # interface
    │   │   │   └── nasa_repository_impl.dart     # implementation
    │   │   └── usecases/get_nasa_images.dart     # (ว่างเปล่า)
    │   └── presentation/
    │       ├── view/                             # Layer: View (UI เท่านั้น)
    │       │   ├── pages/
    │       │   │   ├── home_screen.dart          # หน้าแรก (Grid ภาพ)
    │       │   │   └── detail_screen.dart        # หน้ารายละเอียดภาพ
    │       │   └── widgets/
    │       │       ├── nasa_image_card.dart      # Card แสดงภาพในกริด
    │       │       ├── favorite_button.dart      # ปุ่มดาว — BlocConsumer
    │       │       ├── info_badge.dart           # Badge แสดงข้อมูล
    │       │       └── keyword_chip.dart         # Chip แสดง keyword
    │       └── view_model/                       # Layer: ViewModel (logic + BLoC)
    │           ├── favorite_view_model.dart      # logic: loadFavorites, toggleFavorite
    │           └── bloc/
    │               ├── nasa/
    │               │   ├── nasa_bloc_bloc.dart   # BLoC: โหลดภาพ NASA
    │               │   ├── nasa_bloc_event.dart  # FetchNasaImages
    │               │   └── nasa_bloc_state.dart  # Initial/Loading/Loaded/Error
    │               └── favorite/
    │                   ├── favorites_bloc_bloc.dart   # BLoC: delegate → FavoriteViewModel
    │                   ├── favorites_bloc_event.dart  # LoadFavorites, ToggleFavorite
    │                   └── favorites_bloc_state.dart  # Initial/Loaded
```

---

## อธิบายทุกไฟล์

---

### `main.dart`
**หน้าที่:** จุดเริ่มต้นของแอป

```dart
void main() async {
  await GetStorage.init();   // เปิด local storage ก่อนแอปขึ้น
  runApp(const MyApp());
}
```

- `GetStorage.init()` ต้อง await ก่อนเสมอ มิฉะนั้น favorites จะอ่านค่าไม่ได้
- `MultiBlocProvider` วางอยู่เหนือ `MaterialApp` เพื่อให้ทุก route ที่ push ผ่าน `Navigator` เข้าถึง BLoC ทั้งสองได้
- สร้าง BLoC ทั้งสองผ่าน `InjectionContainer`

---

### `injection_container.dart`
**หน้าที่:** โรงงาน wiring dependencies ทั้งหมดไว้ที่เดียว

```dart
// NASA flow
Dio → NasaRemoteDataSourceImpl → NasaRepositoryImpl → NasaBlocBloc

// Favorites flow
FavoriteViewModel → FavoritesBlocBloc → ..add(LoadFavorites())
```

- ใช้ `..add(LoadFavorites())` (cascade operator) โหลด favorites จาก storage ทันทีที่ bloc ถูกสร้าง
- ไม่มี singleton — สร้าง instance ใหม่ทุกครั้งที่เรียก

---

## core/

---

### `core/storage/favorites_storage.dart`
**หน้าที่:** จัดการ read/write รายการโปรดใน local storage

- ใช้ `GetStorage` เก็บข้อมูลเป็น key `'nasa_favorites'` → `List<String>` ของ image URL
- `_getAllSync()` อ่านข้อมูลแบบ sync แล้ว cast `List<dynamic>` → `List<String>`
- `saveFavorite(url)` — ตรวจก่อนว่ามีอยู่แล้วหรือยัง ถ้าไม่มีจึงเพิ่ม
- `removeFavorite(url)` — ลบด้วย `removeWhere`
- `getAllFavorites()` — คืน `List<String>` ทั้งหมด (ใช้โดย `FavoriteViewModel`)

---

### `core/theme/app_theme.dart`
**หน้าที่:** กำหนดธีมของแอป

- Dark Theme ด้วย `ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark)`
- ใช้ Material 3 (`useMaterial3: true`)

---

## data/

---

### `data/datasources/nasa_remote_data_source.dart`
**หน้าที่:** Abstract interface กำหนด contract ของ data source

```dart
abstract class NasaRemoteDataSource {
  Future<List<NasaItemModel>> fetchImages();
}
```

- บังคับให้ implementation ต้องมี `fetchImages()`
- ทำให้ swap implementation ได้ง่าย (เช่น เปลี่ยนจาก Dio เป็น http)

---

### `data/datasources/nasa_remote_data_source_impl.dart`
**หน้าที่:** ดึงข้อมูลจาก NASA API และ parse JSON

- GET `https://images-api.nasa.gov/search?q=earth&media_type=image`
- cast ทุก field อย่าง type-safe:
  - `raw as Map<String, dynamic>`
  - `(item['data'] as List<dynamic>).first as Map<String, dynamic>`
  - `item['links'] as List<dynamic>?`
  - field strings ใช้ `as String?`
- fallback image URL ถ้า links ว่าง
- จัดการ error แบ่งเป็น `DioException` (network) และ `Exception` ทั่วไป

---

### `data/models/nasa_item_model.dart`
**หน้าที่:** Data model สำหรับ serialize/deserialize ข้อมูลจาก API

- `extends NasaItem` — รับ property ทั้งหมดจาก entity
- `fromJson()` — แปลง `Map<String, dynamic>` เป็น object พร้อม default ทุก field
  - ทุก field cast ด้วย `as String? ?? 'default'`
  - `keywords` ใช้ `.map((e) => e as String)` แทน `List<String>.from()`
- `toJson()` — แปลงกลับเป็น Map (ใช้สำหรับ debug หรือ cache)

---

## domain/

---

### `domain/entities/nasa_item.dart`
**หน้าที่:** Entity หลักของโปรเจกต์ — pure Dart class ไม่มี dependency ใด ๆ

| Field | Type | ความหมาย |
|---|---|---|
| `title` | String | ชื่อภาพ |
| `center` | String | ศูนย์ NASA ที่ถ่าย |
| `dateCreated` | String | วันที่สร้าง (ISO format) |
| `description` | String | คำอธิบาย |
| `imageUrl` | String | URL ของภาพ |
| `keywords` | List\<String\> | คีย์เวิร์ดของภาพ |

---

### `domain/repositories/nasa_repository.dart`
**หน้าที่:** Abstract interface กำหนด contract ของ repository

```dart
abstract class NasaRepository {
  Future<List<NasaItem>> fetchImages();
}
```

- Domain layer ไม่รู้จัก implementation — รู้จักแค่ interface นี้
- `NasaBlocBloc` ใช้ type นี้ ไม่ใช่ impl โดยตรง

---

### `domain/repositories/nasa_repository_impl.dart`
**หน้าที่:** Implementation ของ repository ส่งต่อ call ไปยัง data source

```dart
Future<List<NasaItem>> fetchImages() async {
  return await remoteDataSource.fetchImages();
  // NasaItemModel extends NasaItem → return ได้โดยตรง
}
```

- รับ `NasaRemoteDataSource` ผ่าน constructor (dependency injection)
- ทำหน้าที่เป็น adapter ระหว่าง domain กับ data layer

---

## presentation/view_model/

---

### `view_model/favorite_view_model.dart`
**หน้าที่:** ViewModel ของ MVVM — เก็บ state และ logic ของ Favorites ทั้งหมด

```dart
Set<String> _favorites = {};                          // state ภายใน
Set<String> get favorites => Set.unmodifiable(_favorites); // expose อ่านอย่างเดียว

Future<void> loadFavorites()            // โหลดจาก storage → เก็บใน _favorites
Future<void> toggleFavorite(imageUrl)   // เพิ่ม/ลบใน _favorites + เขียน storage
```

- `FavoritesBlocBloc` ไม่มี logic เลย — delegate ทุกอย่างมาที่นี่
- `Set.unmodifiable()` ป้องกันการแก้ไข set จากภายนอก

---

### `view_model/bloc/nasa/nasa_bloc_event.dart`
**หน้าที่:** กำหนด events ของ NASA BLoC

```dart
sealed class NasaBlocEvent {}
final class FetchNasaImages extends NasaBlocEvent {}
```

- มีแค่ event เดียว — ใช้ตอนเริ่มแอปใน `initState` ของ `MyHomePage`

---

### `view_model/bloc/nasa/nasa_bloc_state.dart`
**หน้าที่:** กำหนด states ของ NASA BLoC

| State | ข้อมูล | แสดงผล |
|---|---|---|
| `NasaBlocInitial` | — | ข้อความ "ไม่มีข้อมูล" |
| `NasaBlocLoading` | — | CircularProgressIndicator |
| `NasaBlocLoaded` | `List<NasaItem> items` | GridView |
| `NasaBlocError` | `String message` | ข้อความ error |

---

### `view_model/bloc/nasa/nasa_bloc_bloc.dart`
**หน้าที่:** จัดการ flow การโหลดภาพ NASA

```dart
on<FetchNasaImages>((event, emit) async {
  emit(NasaBlocLoading());
  try {
    final items = await repository.fetchImages();
    emit(NasaBlocLoaded(items));
  } catch (e) {
    emit(NasaBlocError('เกิดข้อผิดพลาด: $e'));
  }
});
```

- รับ `NasaRepository` ผ่าน constructor
- มี logic การจัดการ error อยู่ที่นี่

---

### `view_model/bloc/favorite/favorites_bloc_event.dart`
**หน้าที่:** กำหนด events ของ Favorites BLoC

```dart
final class LoadFavorites extends FavoritesBlocEvent {}
// ยิงตอนสร้าง bloc — โหลด favorites จาก storage

final class ToggleFavorite extends FavoritesBlocEvent {
  final String imageUrl;  // URL ของภาพที่ต้องการ toggle
}
// ยิงเมื่อกดปุ่มดาวใน FavoriteButton
```

---

### `view_model/bloc/favorite/favorites_bloc_state.dart`
**หน้าที่:** กำหนด states ของ Favorites BLoC

```dart
final class FavoritesBlocInitial extends FavoritesBlocState {}
// state เริ่มต้นก่อน LoadFavorites เสร็จ

final class FavoritesBlocLoaded extends FavoritesBlocState {
  final Set<String> favoriteUrls;
  bool isFavorite(String imageUrl) => favoriteUrls.contains(imageUrl);
}
// state หลัก — ทุก widget อ่านผ่าน isFavorite()
```

---

### `view_model/bloc/favorite/favorites_bloc_bloc.dart`
**หน้าที่:** BLoC บาง ๆ — รับ event → delegate ViewModel → emit state (ไม่มี logic)

```dart
on<LoadFavorites>((event, emit) async {
  await _viewModel.loadFavorites();
  emit(FavoritesBlocLoaded(_viewModel.favorites));
});

on<ToggleFavorite>((event, emit) async {
  await _viewModel.toggleFavorite(event.imageUrl);
  emit(FavoritesBlocLoaded(_viewModel.favorites));
});
```

- ไม่มี if/else, ไม่มีการอ่าน state เก่า — ทุกอย่างอยู่ใน `FavoriteViewModel`

---

## presentation/view/

---

### `view/pages/home_screen.dart`
**หน้าที่:** หน้าแรกของแอป — แสดง Grid ภาพ NASA

- `initState` ยิง `FetchNasaImages` event
- `BlocBuilder<NasaBlocBloc>` render ตาม state:
  - Loading → `CircularProgressIndicator`
  - Error → ข้อความ error
  - Loaded → `GridView.builder`
  - Initial → ข้อความ "ไม่มีข้อมูล"
- Responsive: `screenWidth > 600` → 3 คอลัมน์, อื่น ๆ → 2 คอลัมน์
- กด card → `Navigator.push` ไป `DetailScreen`

---

### `view/pages/detail_screen.dart`
**หน้าที่:** หน้ารายละเอียดภาพ

- รับ `NasaItem` เป็น parameter
- ภาพ: `height: 300`, `BoxFit.contain`, พื้นหลังดำ, มี `errorBuilder`
- `FavoriteButton` วางด้วย `Positioned(bottom: 16, right: 16)` ซ้อนบนภาพ
- แสดง `InfoBadge` (center + วันที่), title, description, keywords

---

### `view/widgets/nasa_image_card.dart`
**หน้าที่:** Card แต่ละอันในหน้า Home

- แสดงภาพ (`BoxFit.cover`), center, title (1 บรรทัด), description (2 บรรทัด)
- `BlocBuilder<FavoritesBlocBloc>` แสดงไอคอนดาวเล็กมุมขวาบนถ้า `isFavorite`
- `buildWhen` rebuild เฉพาะเมื่อ favorite status ของ URL นั้นเปลี่ยน
- กด → เรียก `onTap` callback (navigate ไป detail)

---

### `view/widgets/favorite_button.dart`
**หน้าที่:** ปุ่มดาวกดได้ใน DetailScreen พร้อม animation

- `StatefulWidget` เพื่อถือ `AnimationController` (scale 1.0 → 1.15, elasticOut, 500ms)
- `initState` sync animation กับ BLoC state ปัจจุบันผ่าน `addPostFrameCallback`
- `BlocConsumer`:
  - `listener` — forward/reverse animation เมื่อ favorite status เปลี่ยน
  - `builder` — render `Icons.star` หรือ `Icons.star_border`
- กดปุ่ม → `context.read<FavoritesBlocBloc>().add(ToggleFavorite(imageUrl))`

---

### `view/widgets/info_badge.dart`
**หน้าที่:** Badge แสดงข้อมูล metadata

- รับ `text` และ `color` — ใช้ใน DetailScreen แสดง center (สีน้ำเงิน) และวันที่ (สีเขียว)
- สไตล์: พื้นหลังสีอ่อน 10% + เส้นขอบสี 50% + ข้อความ bold

---

### `view/widgets/keyword_chip.dart`
**หน้าที่:** Chip แสดง keyword ของภาพ

- Material `Chip` แสดงข้อความในรูปแบบ `#keyword`
- ใช้ใน DetailScreen ใน `Wrap` เพื่อ wrap หลาย keyword

---

---

## Favorite Workflow — ไหลของระบบ Favorite ทั้งหมด

ระบบ Favorite เริ่มต้นตั้งแต่แอปขึ้น และสิ้นสุดเมื่อข้อมูลถูกบันทึกลง storage ถาวร โดยแบ่งเป็น 3 ช่วงหลัก:

---

### ช่วงที่ 1 — App Startup: โหลด Favorites จาก Storage

```
main.dart
  └── await GetStorage.init()              ← ต้อง await ก่อนเสมอ
  └── MultiBlocProvider
        └── InjectionContainer.createFavoritesBlocBloc()
              └── FavoritesBlocBloc(FavoriteViewModel())
                    └── ..add(LoadFavorites())   ← ยิง event ทันทีตอนสร้าง
```

**LoadFavorites event flow:**
```
FavoritesBlocBloc.on<LoadFavorites>
  └── FavoriteViewModel.loadFavorites()
        └── FavoritesStorage.getAllFavorites()
              └── GetStorage.read('nasa_favorites')  ← อ่านจาก disk
                    └── List<String> (URLs)
  └── _favorites = urls.toSet()            ← เก็บใน Set ภายใน ViewModel
  └── emit FavoritesBlocLoaded(favorites)  ← broadcast ให้ทุก widget
```

หลังจากนี้ทุก `BlocBuilder` ที่ฟัง `FavoritesBlocBloc` จะได้รับ state พร้อม URL ทั้งหมด

---

### ช่วงที่ 2 — User Interaction: กดปุ่มดาว

ผู้ใช้กด `FavoriteButton` ใน `DetailScreen`:

```
FavoriteButton.onPressed
  └── context.read<FavoritesBlocBloc>().add(ToggleFavorite(imageUrl))

FavoritesBlocBloc.on<ToggleFavorite>
  └── FavoriteViewModel.toggleFavorite(imageUrl)
        ├── [ถ้า URL อยู่ใน _favorites แล้ว]
        │     ├── FavoritesStorage.removeFavorite(url)
        │     │     └── list.removeWhere(...)
        │     │           └── GetStorage.write('nasa_favorites', list)  ← บันทึก
        │     └── _favorites.remove(url)
        └── [ถ้า URL ยังไม่อยู่ใน _favorites]
              ├── FavoritesStorage.saveFavorite(url)
              │     └── list.add(url)
              │           └── GetStorage.write('nasa_favorites', list)  ← บันทึก
              └── _favorites.add(url)
  └── emit FavoritesBlocLoaded(_viewModel.favorites)  ← broadcast state ใหม่
```

---

### ช่วงที่ 3 — UI Reaction: อัปเดต Widget พร้อมกัน

state ใหม่ถูก broadcast ไปยัง widget ทุกตัวที่ฟัง `FavoritesBlocBloc`:

**FavoriteButton (DetailScreen):**
```
BlocConsumer.listener
  ├── isFavorite → _animationController.forward()  ← scale 1.0 → 1.15 (elasticOut)
  └── ไม่ใช่  → _animationController.reverse()

BlocConsumer.builder
  ├── isFavorite → Icons.star (สีทอง)
  └── ไม่ใช่  → Icons.star_border (สีทองจาง)
```

**NasaImageCard (HomeScreen Grid):**
```
BlocBuilder.buildWhen
  └── rebuild เฉพาะเมื่อ isFavorite ของ URL นั้น ๆ เปลี่ยน
BlocBuilder.builder
  ├── isFavorite → แสดงไอคอนดาวเล็กมุมขวาบน
  └── ไม่ใช่  → ซ่อน
```

---

### สรุปภาพรวม Favorite Lifecycle

```
[App Start]
    │
    ▼
GetStorage.init()  ←── ต้อง await ก่อน runApp()
    │
    ▼
FavoritesBlocBloc created
    │
    ▼
LoadFavorites event ──► FavoriteViewModel.loadFavorites()
                              │
                              ▼
                        FavoritesStorage.getAllFavorites()
                              │
                              ▼
                        _favorites = Set<String>  ←── state ใน memory
                              │
                              ▼
                        emit FavoritesBlocLoaded  ──► widgets rebuild

[User taps star]
    │
    ▼
ToggleFavorite(url) event ──► FavoriteViewModel.toggleFavorite()
                                    │
                        ┌───────────┴───────────┐
                    remove(url)             add(url)
                        │                       │
                  Storage.remove()        Storage.save()
                        │                       │
                    GetStorage.write()    GetStorage.write()  ←── persist to disk
                        │                       │
                        └───────────┬───────────┘
                                    ▼
                        emit FavoritesBlocLoaded  ──► animation + icon update
```

**จุดเริ่มต้น:** `GetStorage.init()` ใน `main.dart` — ถ้าไม่ await ขั้นตอนนี้ ข้อมูล favorites จะอ่านไม่ได้
**จุดสิ้นสุด (persist):** `GetStorage.write('nasa_favorites', list)` ใน `FavoritesStorage` — ข้อมูลอยู่ถาวรแม้ปิดแอป

---

### File → Function Chain (เส้นทางแบบละเอียด)

#### Path A — โหลด Favorites ตอนแอปเริ่ม

| ลำดับ | File | Function |
| --- | --- | --- |
| 1 | `main.dart` | `main()` → `await GetStorage.init()` |
| 2 | `main.dart` | `MyApp.build()` → `MultiBlocProvider` |
| 3 | `injection_container.dart` | `createFavoritesBlocBloc()` → สร้าง `FavoriteViewModel()` + `FavoritesBlocBloc()` |
| 4 | `favorites_bloc_bloc.dart` | `FavoritesBlocBloc()` constructor → `..add(LoadFavorites())` |
| 5 | `favorites_bloc_bloc.dart` | `on<LoadFavorites>` handler → เรียก `_viewModel.loadFavorites()` |
| 6 | `favorite_view_model.dart` | `loadFavorites()` → เรียก `FavoritesStorage.getAllFavorites()` |
| 7 | `favorites_storage.dart` | `getAllFavorites()` → เรียก `_getAllSync()` |
| 8 | `favorites_storage.dart` | `_getAllSync()` → `GetStorage.read('nasa_favorites')` → คืน `List<String>` |
| 9 | `favorite_view_model.dart` | `_favorites = urls.toSet()` → เก็บใน memory |
| 10 | `favorites_bloc_bloc.dart` | `emit(FavoritesBlocLoaded(_viewModel.favorites))` |
| 11 | `nasa_image_card.dart` | `BlocBuilder.builder` → `state.isFavorite(item.imageUrl)` → แสดง/ซ่อนดาว |

---

#### Path B — กดปุ่มดาว (Toggle Favorite)

| ลำดับ | File | Function |
| --- | --- | --- |
| 1 | `favorite_button.dart` | `IconButton.onPressed` → `context.read<FavoritesBlocBloc>().add(ToggleFavorite(imageUrl))` |
| 2 | `favorites_bloc_event.dart` | สร้าง `ToggleFavorite(imageUrl)` event |
| 3 | `favorites_bloc_bloc.dart` | `on<ToggleFavorite>` handler → เรียก `_viewModel.toggleFavorite(event.imageUrl)` |
| 4 | `favorite_view_model.dart` | `toggleFavorite(imageUrl)` → ตรวจ `_favorites.contains(url)` |
| 5a | `favorites_storage.dart` | (ถ้ามีอยู่แล้ว) `removeFavorite(url)` → `_getAllSync()` + `list.removeWhere()` + `GetStorage.write()` |
| 5b | `favorites_storage.dart` | (ถ้ายังไม่มี) `saveFavorite(url)` → `_getAllSync()` + `list.add()` + `GetStorage.write()` |
| 6 | `favorites_bloc_bloc.dart` | `emit(FavoritesBlocLoaded(_viewModel.favorites))` → broadcast state ใหม่ |
| 7 | `favorite_button.dart` | `BlocConsumer.listener` → `_animationController.forward()` หรือ `.reverse()` |
| 8 | `favorite_button.dart` | `BlocConsumer.builder` → สลับ `Icons.star` / `Icons.star_border` |
| 9 | `nasa_image_card.dart` | `BlocBuilder.builder` → `state.isFavorite(item.imageUrl)` → อัปเดตดาวบน Grid card |

---

#### จุดเริ่มต้น → จุดสิ้นสุด

```
เริ่ม: main.dart → main()
  ↓
สิ้นสุด (persist): favorites_storage.dart → _getAllSync() + GetStorage.write()
```

ทุกครั้งที่กดดาว ข้อมูลไหลจาก `favorite_button.dart:onPressed`
ผ่าน BLoC → ViewModel → Storage แล้วสะท้อนกลับมาที่ UI สองจุดพร้อมกัน:
`favorite_button.dart` (animation + icon) และ `nasa_image_card.dart` (ดาวมุมบน grid)

---

## สรุป Dependency ระหว่าง Layer

```
View
  └── อ่าน State จาก BLoC
  └── ยิง Event ไปที่ BLoC

BLoC (bridge)
  └── delegate logic ไปที่ ViewModel / Repository

ViewModel
  └── เรียก Storage (FavoritesStorage)

Repository
  └── เรียก DataSource

DataSource
  └── เรียก Dio (HTTP)

Storage / Dio
  └── ติดต่อ External (GetStorage / NASA API)
```
