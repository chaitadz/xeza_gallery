# สรุปโปรเจกต์ xeza_gallery — อธิบายทุกไฟล์

---

## โครงสร้างโฟลเดอร์ (โครงสร้างจริง)

```
lib/
├── main.dart
├── injection_container.dart
├── core/
│   ├── constants/api_constants.dart              (ว่างเปล่า — ยังไม่ได้ใช้)
│   ├── errors/exceptions.dart                    (ว่างเปล่า — ยังไม่ได้ใช้)
│   ├── errors/failures.dart                      (ว่างเปล่า — ยังไม่ได้ใช้)
│   ├── network/dio_client.dart                   (ว่างเปล่า — ยังไม่ได้ใช้)
│   ├── storage/favorites_storage.dart
│   └── theme/app_theme.dart
├── nasa_repository/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── nasa_remote_data_source.dart      (abstract interface)
│   │   │   └── nasa_remote_data_source_impl.dart (Dio implementation)
│   │   └── models/nasa_item_model.dart
│   └── domain/
│       ├── entities/nasa_item.dart
│       ├── repositories/
│       │   ├── nasa_repository.dart              (abstract interface)
│       │   └── nasa_repository_impl.dart
│       └── usecases/get_nasa_images.dart         (ว่างเปล่า — ยังไม่ได้ใช้)
├── presentation/
│   ├── bloc/
│   │   ├── favorite/
│   │   │   ├── favorites_bloc_bloc.dart
│   │   │   ├── favorites_bloc_event.dart
│   │   │   └── favorites_bloc_state.dart
│   │   └── nasa/
│   │       ├── nasa_bloc_bloc.dart
│   │       ├── nasa_bloc_event.dart
│   │       └── nasa_bloc_state.dart
│   ├── view/
│   │   ├── pages/
│   │   │   ├── landing_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── favorites_screen.dart
│   │   │   └── detail_screen.dart
│   │   └── widgets/
│   │       ├── favorite_button.dart
│   │       ├── info_badge.dart
│   │       ├── keyword_chip.dart
│   │       └── nasa_image_card.dart
│   └── view_model/
│       └── favorite_view_model.dart
└── repository/
    └── data/datasources/nasa_remote_data_source.dart  (duplicate — ไม่ได้ใช้งาน)
```

---

## อธิบายทุกไฟล์

---

### `main.dart`

**หน้าที่:** จุดเริ่มต้นของแอป

```dart
void main() async {
  await GetStorage.init();   // ต้อง await ก่อน runApp เสมอ
  runApp(const MyApp());
}
```

- `GetStorage.init()` ต้อง await ก่อนเสมอ — ถ้าไม่ทำ storage จะอ่านค่า favorites ไม่ได้
- `MultiBlocProvider` วางเหนือ `MaterialApp` เพื่อให้ทุก route ที่ push ผ่าน `Navigator` เข้าถึง BLoC ทั้งสองได้
- สร้าง BLoC ทั้งสองผ่าน `InjectionContainer`
- เปลี่ยน `home` จาก `MyHomePage` เป็น `LandingScreen` (หน้าแรกใหม่)

---

### `injection_container.dart`

**หน้าที่:** wiring dependencies ทั้งหมดไว้ที่เดียว

```dart
// NASA flow
NasaRemoteDataSourceImpl → NasaRepositoryImpl → NasaBlocBloc

// Favorites flow
FavoriteViewModel → FavoritesBlocBloc → ..add(LoadFavorites())
```

- `NasaRemoteDataSourceImpl()` สร้าง `Dio` ภายในตัวเอง — ไม่รับ Dio จากภายนอกอีกต่อไป
- `..add(LoadFavorites())` (cascade operator) โหลด favorites จาก storage ทันทีที่ bloc ถูกสร้าง

---

## core/

---

### `core/storage/favorites_storage.dart`

**หน้าที่:** จัดการ read/write รายการโปรดใน local storage

- ใช้ `GetStorage` เก็บข้อมูลด้วย key `'nasa_favorites'` → `List<String>` ของ image URL
- `_getAllSync()` อ่านข้อมูลแบบ sync แล้ว cast `List<dynamic>` → `List<String>` (หรือคืน `[]` ถ้าว่าง)
- `saveFavorite(url)` — ตรวจก่อนว่ามีอยู่แล้วหรือยัง ถ้าไม่มีจึงเพิ่มแล้ว write
- `removeFavorite(url)` — ลบด้วย `removeWhere` แล้ว write
- `getAllFavorites()` — คืน `List<String>` ทั้งหมด (ใช้โดย `FavoriteViewModel`)

---

### `core/theme/app_theme.dart`

**หน้าที่:** กำหนดธีมของแอป

- Dark Theme ด้วย `ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark)`
- ใช้ Material 3 (`useMaterial3: true`)

---

### ไฟล์ว่างใน core/ (ยังไม่ได้ implement)

| ไฟล์ | วัตถุประสงค์ที่วางแผนไว้ |
| --- | --- |
| `core/constants/api_constants.dart` | เก็บ URL คงที่ของ NASA API |
| `core/errors/exceptions.dart` | Custom exception classes |
| `core/errors/failures.dart` | Failure classes สำหรับ Either pattern |
| `core/network/dio_client.dart` | Shared Dio instance พร้อม interceptors |

---

## nasa_repository/

---

### `nasa_repository/data/datasources/nasa_remote_data_source.dart`

**หน้าที่:** Abstract interface กำหนด contract ของ data source

```dart
abstract class NasaRemoteDataSource {
  Future<List<NasaItemModel>> fetchImages();
}
```

- บังคับให้ implementation ต้องมี `fetchImages()`

---

### `nasa_repository/data/datasources/nasa_remote_data_source_impl.dart`

**หน้าที่:** ดึงข้อมูลจาก NASA API จริง ๆ และ parse JSON

- สร้าง `_dio = Dio()` ภายในตัวเอง (ไม่รับจาก constructor)
- GET `https://images-api.nasa.gov/search?q=earth&media_type=image`
- parse `response.data['collection']['items']` → สร้าง `List<NasaItemModel>`
- fallback image URL ถ้า `links` ว่างหรือ null
- จัดการ error: `DioException` (network), `Exception` ทั่วไป

---

### `nasa_repository/data/models/nasa_item_model.dart`

**หน้าที่:** Data model สำหรับ serialize/deserialize ข้อมูลจาก API

- `extends NasaItem` — รับ properties ทั้งหมดจาก entity
- `fromJson()` — แปลง `Map<String, dynamic>` เป็น object พร้อม default ทุก field
- `toJson()` — แปลงกลับเป็น Map (ใช้สำหรับ debug หรือ cache)

---

### `nasa_repository/domain/entities/nasa_item.dart`

**หน้าที่:** Entity หลักของโปรเจกต์ — pure Dart class ไม่มี dependency ใด ๆ

| Field | Type | ความหมาย |
| --- | --- | --- |
| `title` | String | ชื่อภาพ |
| `center` | String | ศูนย์ NASA ที่ถ่าย |
| `dateCreated` | String | วันที่สร้าง (ISO format) |
| `description` | String | คำอธิบาย |
| `imageUrl` | String | URL ของภาพ |
| `keywords` | List\<String\> | คีย์เวิร์ดของภาพ |

---

### `nasa_repository/domain/repositories/nasa_repository.dart`

**หน้าที่:** Abstract interface กำหนด contract ของ repository

```dart
abstract class NasaRepository {
  Future<List<NasaItem>> fetchImages();
}
```

- `NasaBlocBloc` ใช้ type นี้ ไม่ใช่ impl โดยตรง (dependency inversion)

---

### `nasa_repository/domain/repositories/nasa_repository_impl.dart`

**หน้าที่:** Implementation ของ repository — ส่งต่อ call ไปยัง data source

```dart
Future<List<NasaItem>> fetchImages() async {
  return await remoteDataSource.fetchImages();
  // NasaItemModel extends NasaItem → return ได้โดยตรง
}
```

- รับ `NasaRemoteDataSource` ผ่าน constructor (dependency injection)

---

### `nasa_repository/domain/usecases/get_nasa_images.dart`

**หน้าที่:** ยังไม่ได้ implement — ไฟล์ว่าง (วางแผนไว้สำหรับ Use Case layer)

---

## presentation/bloc/

---

### `presentation/bloc/nasa/nasa_bloc_event.dart`

**หน้าที่:** กำหนด events ของ NASA BLoC

```dart
sealed class NasaBlocEvent {}
final class FetchNasaImages extends NasaBlocEvent {}
```

- มีแค่ event เดียว — ยิงตอน `initState` ของ `MyHomePage`

---

### `presentation/bloc/nasa/nasa_bloc_state.dart`

**หน้าที่:** กำหนด states ของ NASA BLoC

| State | ข้อมูล | แสดงผล |
| --- | --- | --- |
| `NasaBlocInitial` | — | ข้อความ "ไม่มีข้อมูล" |
| `NasaBlocLoading` | — | `CircularProgressIndicator` |
| `NasaBlocLoaded` | `List<NasaItem> items` | `GridView` |
| `NasaBlocError` | `String message` | ข้อความ error |

---

### `presentation/bloc/nasa/nasa_bloc_bloc.dart`

**หน้าที่:** จัดการ flow การโหลดภาพ NASA

```dart
on<FetchNasaImages>((event, emit) async {
  emit(NasaBlocLoading());
  await Future.delayed(Duration(seconds: 2)); // จำลอง loading
  try {
    final items = await repository.fetchImages();
    emit(NasaBlocLoaded(items));
  } catch (e) {
    emit(NasaBlocError('เกิดข้อผิดพลาด: $e'));
  }
});
```

- มี `Future.delayed(2s)` เพื่อจำลอง loading state ให้เห็นชัด

---

### `presentation/bloc/favorite/favorites_bloc_event.dart`

**หน้าที่:** กำหนด events ของ Favorites BLoC

```dart
final class LoadFavorites extends FavoritesBlocEvent {}
// ยิงตอนสร้าง bloc ใน InjectionContainer

final class ToggleFavorite extends FavoritesBlocEvent {
  final String imageUrl;
}
// ยิงเมื่อกดปุ่มดาวใน FavoriteButton
```

---

### `presentation/bloc/favorite/favorites_bloc_state.dart`

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

### `presentation/bloc/favorite/favorites_bloc_bloc.dart`

**หน้าที่:** BLoC บาง ๆ — รับ event → delegate ViewModel → emit state

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

- ไม่มี logic เลย — ทุกอย่าง delegate ไปที่ `FavoriteViewModel`

---

## presentation/view_model/

---

### `presentation/view_model/favorite_view_model.dart`

**หน้าที่:** ViewModel — เก็บ state และ logic ของ Favorites ทั้งหมด

```dart
Set<String> _favorites = {};
Set<String> get favorites => Set.unmodifiable(_favorites);

Future<void> loadFavorites()           // โหลดจาก storage → เก็บใน _favorites
Future<void> toggleFavorite(imageUrl)  // เพิ่ม/ลบใน _favorites + เขียน storage
```

- `Set.unmodifiable()` ป้องกันการแก้ไข set จากภายนอก
- `FavoritesBlocBloc` ไม่มี logic เลย — delegate ทุกอย่างมาที่นี่

---

## presentation/view/pages/

---

### `presentation/view/pages/landing_screen.dart`

**หน้าที่:** หน้าแรกของแอป — เลือกว่าจะไป Explore Gallery หรือ My Favorites

- `StatelessWidget` แสดง gradient background (purple → dark)
- ไอคอน "search" ขนาด 80 และ title "Xeza Gallery"
- 2 ปุ่ม (Material buttons) พร้อม icon, title, description และ arrow:
  - **Explore Gallery** → `Navigator.push` ไป `MyHomePage`
  - **My Favorites** → `Navigator.push` ไป `FavoritesScreen`
- ใช้ `_NavButton` widget เพื่อ reuse styling (border, icon, text)
- ธีม: Dark, Material 3, seed color deepPurple

---

### `presentation/view/pages/home_screen.dart`

**หน้าที่:** หน้าแรกของแอป — แสดง Grid ภาพ NASA

- `initState` ยิง `FetchNasaImages` event
- `BlocBuilder<NasaBlocBloc>` render ตาม state:
  - `NasaBlocLoading` → `CircularProgressIndicator`
  - `NasaBlocError` → ข้อความ error
  - `NasaBlocLoaded` → `GridView.builder`
  - อื่น ๆ → ข้อความ "ไม่มีข้อมูล"
- Responsive: `screenWidth > 600` → 3 คอลัมน์, อื่น ๆ → 2 คอลัมน์
- กด card → `Navigator.push` ไป `DetailScreen`

---

### `presentation/view/pages/favorites_screen.dart`

**หน้าที่:** หน้าแสดงรายการภาพที่บันทึกไว้ (favorites)

- `StatefulWidget` — fetch NASA images ในตัว (เพื่อให้ได้ชื่อ/คำอธิบาย ไม่ใช่แค่ URL)
- `initState` ยิง `FetchNasaImages` (โหลดจาก API)
- `BlocBuilder` double — อ่าน `NasaBlocBloc` (NASA images) และ `FavoritesBlocBloc` (favorites URLs)
- Filter `nasaItems` ที่มี URL อยู่ใน `favoriteUrls` set
- ถ้าว่าง → แสดง empty state (ไอคอนหัวใจ + ข้อความ)
- ถ้ามีข้อมูล → แสดง `GridView` (เหมือน `home_screen`)
- Responsive: `screenWidth > 600` → 3 คอลัมน์, อื่น ๆ → 2 คอลัมน์

---

### `presentation/view/pages/detail_screen.dart`

**หน้าที่:** หน้ารายละเอียดภาพ

- รับ `NasaItem` เป็น parameter
- ภาพ: `height: 300`, `BoxFit.contain`, พื้นหลังดำ, มี `errorBuilder`
- `FavoriteButton` วางด้วย `Positioned(bottom: 16, right: 16)` ซ้อนบนภาพ
- แสดง `InfoBadge` (center สีน้ำเงิน + วันที่สีเขียว), title, description, keywords

---

## presentation/view/widgets/

---

### `presentation/view/widgets/favorite_button.dart`

**หน้าที่:** ปุ่มดาวกดได้ใน `DetailScreen`

- `StatelessWidget` — ไม่มี animation (ต่างจาก version เก่า)
- `BlocBuilder<FavoritesBlocBloc>` พร้อม `buildWhen` — rebuild เฉพาะเมื่อ status ของ URL นั้นเปลี่ยน
- กดปุ่ม → `context.read<FavoritesBlocBloc>().add(ToggleFavorite(imageUrl))`
- icon: `Icons.star` (สีทอง) หรือ `Icons.star_border` (สีทองจาง) ตาม `isFavorite`

---

### `presentation/view/widgets/nasa_image_card.dart`

**หน้าที่:** Card แต่ละอันในหน้า Home Grid

- แสดงภาพ (`BoxFit.cover`), center (uppercase), title (1 บรรทัด), description (2 บรรทัด)
- `BlocBuilder<FavoritesBlocBloc>` แสดงไอคอนดาวเล็กมุมขวาบนถ้า `isFavorite`
- `buildWhen` rebuild เฉพาะเมื่อ favorite status ของ URL นั้นเปลี่ยน
- มี `ValueKey('onTap_card')` บน Card
- กด → เรียก `onTap` callback (navigate ไป detail)

---

### `presentation/view/widgets/info_badge.dart`

**หน้าที่:** Badge แสดงข้อมูล metadata

- รับ `text` และ `color` — ใช้ใน `DetailScreen` แสดง center (สีน้ำเงิน) และวันที่ (สีเขียว)
- สไตล์: พื้นหลังสีอ่อน 10% + เส้นขอบสี 50% + ข้อความ bold

---

### `presentation/view/widgets/keyword_chip.dart`

**หน้าที่:** Chip แสดง keyword ของภาพ

- Material `Chip` แสดงข้อความในรูปแบบ `#keyword`
- ใช้ใน `DetailScreen` ใน `Wrap` เพื่อ wrap หลาย keyword

---

## Favorite Workflow — File → Function Chain

### Path A — App Startup (โหลด Favorites)

| ลำดับ | File | Function |
| --- | --- | --- |
| 1 | `main.dart` | `main()` → `await GetStorage.init()` |
| 2 | `main.dart` | `MyApp.build()` → `MultiBlocProvider` |
| 3 | `injection_container.dart` | `createFavoritesBlocBloc()` → สร้าง `FavoriteViewModel()` + `FavoritesBlocBloc()` |
| 4 | `favorites_bloc_bloc.dart` | `FavoritesBlocBloc()` constructor → `..add(LoadFavorites())` |
| 5 | `favorites_bloc_bloc.dart` | `on<LoadFavorites>` → เรียก `_viewModel.loadFavorites()` |
| 6 | `favorite_view_model.dart` | `loadFavorites()` → เรียก `FavoritesStorage.getAllFavorites()` |
| 7 | `favorites_storage.dart` | `getAllFavorites()` → `_getAllSync()` → `GetStorage.read('nasa_favorites')` |
| 8 | `favorite_view_model.dart` | `_favorites = urls.toSet()` |
| 9 | `favorites_bloc_bloc.dart` | `emit(FavoritesBlocLoaded(_viewModel.favorites))` |
| 10 | `nasa_image_card.dart` | `BlocBuilder.builder` → `state.isFavorite(item.imageUrl)` → แสดง/ซ่อนดาว |

---

### Path B — กดปุ่มดาว (Toggle Favorite)

| ลำดับ | File | Function |
| --- | --- | --- |
| 1 | `favorite_button.dart` | `IconButton.onPressed` → `add(ToggleFavorite(imageUrl))` |
| 2 | `favorites_bloc_bloc.dart` | `on<ToggleFavorite>` → `_viewModel.toggleFavorite(event.imageUrl)` |
| 3 | `favorite_view_model.dart` | `toggleFavorite()` → ตรวจ `_favorites.contains(url)` |
| 4a | `favorites_storage.dart` | (มีอยู่แล้ว) `removeFavorite()` → `removeWhere()` + `GetStorage.write()` |
| 4b | `favorites_storage.dart` | (ยังไม่มี) `saveFavorite()` → `list.add()` + `GetStorage.write()` |
| 5 | `favorites_bloc_bloc.dart` | `emit(FavoritesBlocLoaded(_viewModel.favorites))` |
| 6 | `favorite_button.dart` | `BlocBuilder.builder` → สลับ `Icons.star` / `Icons.star_border` |
| 7 | `nasa_image_card.dart` | `BlocBuilder.builder` → อัปเดตดาวบน Grid card |

---

### Path C — โหลดภาพจาก NASA API

| ลำดับ | File | Function |
| --- | --- | --- |
| 1 | `home_screen.dart` | `initState()` → `add(FetchNasaImages())` |
| 2 | `nasa_bloc_bloc.dart` | `on<FetchNasaImages>` → `emit(NasaBlocLoading())` |
| 3 | `nasa_bloc_bloc.dart` | `Future.delayed(2s)` → `repository.fetchImages()` |
| 4 | `nasa_repository_impl.dart` | `fetchImages()` → `remoteDataSource.fetchImages()` |
| 5 | `nasa_remote_data_source_impl.dart` | `fetchImages()` → `_dio.get(NASA_API_URL)` |
| 6 | `nasa_remote_data_source_impl.dart` | parse JSON → สร้าง `List<NasaItemModel>` |
| 7 | `nasa_bloc_bloc.dart` | `emit(NasaBlocLoaded(items))` |
| 8 | `home_screen.dart` | `BlocBuilder.builder` → render `GridView` |

---

## สรุป Dependency ระหว่าง Layer

```
View (widgets/pages)
  └── อ่าน state จาก BLoC ผ่าน BlocBuilder
  └── ยิง event ไปที่ BLoC ผ่าน context.read().add()

BLoC (presentation/bloc/)
  └── delegate logic ทั้งหมดไปที่ ViewModel หรือ Repository
  └── ไม่มี business logic ในตัวเอง

ViewModel (presentation/view_model/)
  └── เก็บ state ใน memory (Set<String>)
  └── เรียก FavoritesStorage

Repository (nasa_repository/domain/repositories/)
  └── เรียก DataSource

DataSource (nasa_repository/data/datasources/)
  └── เรียก Dio (HTTP request)

Storage / Dio
  └── ติดต่อ External (GetStorage / NASA API)
```
