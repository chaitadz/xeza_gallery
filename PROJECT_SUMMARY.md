# สรุปโปรเจกต์ xeza_gallery

## ภาพรวม

**xeza_gallery** คือแอปพลิเคชัน Flutter สำหรับแสดงภาพถ่ายโลก (Earth) จาก NASA Image API
โดยใช้สถาปัตยกรรม **Clean Architecture + MVVM** ร่วมกับ **BLoC Pattern** โดย BLoC ทำหน้าที่เป็น bridge บาง ๆ ส่วน logic จริงอยู่ใน ViewModel

| รายละเอียด | ค่า |
|---|---|
| ชื่อโปรเจกต์ | `xeza_gallery` |
| เวอร์ชัน | 1.0.0+1 |
| Flutter SDK | ^3.12.2 |
| ธีม | Dark Theme / Material 3 / สีม่วง |

---

## โครงสร้างโฟลเดอร์

```
lib/
├── main.dart                                      # จุดเริ่มต้นของแอป (MultiBlocProvider)
├── injection_container.dart                       # สร้างและฉีด dependencies
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

## Dependencies

| Package | เวอร์ชัน | หน้าที่ |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | State Management (BLoC Pattern) |
| `dio` | ^5.9.2 | HTTP Client สำหรับเรียก API |
| `get_storage` | ^2.1.1 | Local Storage สำหรับบันทึก Favorites |
| `dartz` | ^0.10.1 | Functional Programming (import แต่ยังไม่ได้ใช้) |
| `http` | ^1.6.0 | HTTP Client สำรอง (import แต่ยังไม่ได้ใช้) |
| `platform` | ^3.1.6 | ตรวจสอบ Platform |
| `cupertino_icons` | ^1.0.8 | ไอคอนสไตล์ iOS |

---

## API

**NASA Images API**
- **URL:** `https://images-api.nasa.gov/search?q=earth&media_type=image`
- **Method:** GET
- **Auth:** ไม่ต้องใช้ API Key (Public endpoint)

**รูปแบบ JSON Response:**
```json
{
  "collection": {
    "items": [
      {
        "data": [{ "title", "center", "date_created", "description", "keywords" }],
        "links": [{ "href": "<image_url>" }]
      }
    ]
  }
}
```

---

## BLoC — NASA Gallery

### Events
| Event | คำอธิบาย |
|---|---|
| `FetchNasaImages` | สั่งให้โหลดภาพจาก NASA API |

### States
| State | คำอธิบาย |
|---|---|
| `NasaBlocInitial` | สถานะเริ่มต้น |
| `NasaBlocLoading` | กำลังโหลดข้อมูล |
| `NasaBlocLoaded(items)` | โหลดสำเร็จ มี List ภาพ |
| `NasaBlocError(message)` | เกิดข้อผิดพลาด |

---

## BLoC — Favorites ★ใหม่

ใช้ชื่อไฟล์และ class ตาม pattern เดียวกับ `NasaBlocBloc`

| ไฟล์ | Class |
|---|---|
| `favorites_bloc_bloc.dart` | `FavoritesBlocBloc` |
| `favorites_bloc_event.dart` | `FavoritesBlocEvent` |
| `favorites_bloc_state.dart` | `FavoritesBlocState` |

### Events
| Event | คำอธิบาย |
|---|---|
| `LoadFavorites` | โหลดรายการโปรดทั้งหมดจาก local storage ตอน init |
| `ToggleFavorite(imageUrl)` | เพิ่ม/ลบ favorite ของภาพนั้น ๆ |

### States
| State | คำอธิบาย |
|---|---|
| `FavoritesBlocInitial` | สถานะเริ่มต้นก่อนโหลด |
| `FavoritesBlocLoaded(favoriteUrls)` | มี `Set<String>` ของ URL ที่บันทึกไว้ พร้อม `isFavorite(url)` |

### MVVM Role
| Layer | Class | หน้าที่ |
|---|---|---|
| **View** | `FavoriteButton` | แสดงผล + รับ event จากผู้ใช้ |
| **ViewModel** | `FavoriteViewModel` | logic: โหลด/บันทึก/ลบ favorites ผ่าน `FavoritesStorage` |
| **BLoC** (bridge) | `FavoritesBlocBloc` | รับ event → delegate ViewModel → emit state |

### Flow
```
FavoritesBlocBloc สร้าง → add(LoadFavorites)
    → FavoriteViewModel.loadFavorites()
    → FavoritesStorage.getAllFavorites()
    → emit FavoritesBlocLoaded({...urls})

ผู้ใช้กดดาว → add(ToggleFavorite(url))
    → FavoriteViewModel.toggleFavorite(currentUrls, url)
    → FavoritesStorage.saveFavorite / removeFavorite
    → emit FavoritesBlocLoaded(updatedSet)
    → FavoriteButton BlocConsumer rebuild + animate
```

---

## Domain Layer

### Entity: `NasaItem`
| Field | Type | คำอธิบาย |
|---|---|---|
| `title` | String | ชื่อภาพ |
| `center` | String | ชื่อศูนย์ NASA |
| `dateCreated` | String | วันที่สร้าง (ISO format) |
| `description` | String | คำอธิบาย |
| `imageUrl` | String | URL ของภาพ |
| `keywords` | List\<String\> | คีย์เวิร์ด |

### Model: `NasaItemModel`
- `extends NasaItem`
- `fromJson()` — แปลง API response พร้อม default values
- `toJson()` — แปลงกลับเป็น JSON

---

## Data Layer

### `NasaRemoteDataSourceImpl`
- ใช้ Dio เรียก NASA API
- parse nested JSON → `List<NasaItemModel>`
- มี fallback image URL เมื่อ API ไม่ส่ง links

### `NasaRepositoryImpl`
- รับ `NasaRemoteDataSource` ผ่าน constructor
- ส่งต่อ call ไปที่ data source คืนค่า `List<NasaItem>`

---

## Presentation Layer

### `main.dart` — MultiBlocProvider ★อัปเดต
```
MultiBlocProvider
  ├── BlocProvider(NasaBlocBloc)        ← โหลดภาพ NASA
  └── BlocProvider(FavoritesBlocBloc)   ← จัดการ favorites
      └── MaterialApp
            └── MyHomePage / DetailScreen / ...
```
`MultiBlocProvider` อยู่เหนือ `MaterialApp` เพื่อให้ทุก route ที่ push ผ่าน `Navigator` เข้าถึง BLoC ได้ (รวมถึง `DetailScreen`)

### `injection_container.dart` ★อัปเดต
```dart
InjectionContainer.createNasaBlocBloc()       // Dio → DataSource → Repo → NasaBlocBloc
InjectionContainer.createFavoritesBlocBloc()  // FavoriteViewModel → FavoritesBlocBloc + LoadFavorites
```

### `DetailScreen` ★อัปเดต
- ภาพใช้ความสูงคงที่ `height: 300` (แทน `constraints: BoxConstraints(maxHeight: 400)` ที่ทำให้ Stack ไม่รู้ขนาด)
- เพิ่ม `errorBuilder` แสดงไอคอน `broken_image` เมื่อโหลดภาพไม่สำเร็จ
- ปุ่มดาวแสดงผลได้ถูกต้องเพราะ `FavoritesBlocBloc` อยู่เหนือ `MaterialApp`

### `FavoriteButton` ★อัปเดต
- ลบ local state ออกทั้งหมด (`_isFavorite`, `_isLoading`, async methods)
- คง `AnimationController` ไว้ (ต้องการ `StatefulWidget`)
- ใช้ `BlocConsumer<FavoritesBlocBloc, FavoritesBlocState>`:
  - `listener` — เรียก `forward()`/`reverse()` เมื่อ favorite status เปลี่ยน
  - `builder` — render ไอคอนดาวตาม BLoC state
- กดปุ่ม → `context.read<FavoritesBlocBloc>().add(ToggleFavorite(imageUrl))`
- ลบ `onChanged` callback ออกแล้ว

---

## Local Storage

```dart
FavoritesStorage.getAllFavorites()       // โหลดทั้งหมด (ใช้ใน LoadFavorites)
FavoritesStorage.saveFavorite(url)      // บันทึก (ใช้ใน ToggleFavorite)
FavoritesStorage.removeFavorite(url)    // ลบ (ใช้ใน ToggleFavorite)
```

**Storage Key:** `'nasa_favorites'` — เก็บเป็น `List<String>` ใน GetStorage

---

## Flow การทำงานทั้งหมด

```
1. main() → GetStorage.init() → runApp(MyApp)
2. MultiBlocProvider สร้าง NasaBlocBloc + FavoritesBlocBloc
3. FavoritesBlocBloc → add(LoadFavorites) → โหลด favorites จาก storage
4. MyHomePage.initState() → add(FetchNasaImages)
5. NasaBlocBloc → Dio GET NASA API → emit NasaBlocLoaded(items)
6. GridView แสดงภาพทั้งหมด
7. ผู้ใช้กดภาพ → Navigator.push → DetailScreen
8. ผู้ใช้กดปุ่มดาว → add(ToggleFavorite(url)) → FavoritesBlocBloc
9. FavoritesBlocBloc → เขียน/ลบจาก storage → emit FavoritesBlocLoaded
10. BlocConsumer → drive animation + rebuild ไอคอนดาว
```

---

## ไฟล์ที่ยังไม่ได้ implement

| ไฟล์ | สถานะ |
|---|---|
| `core/constants/api_constants.dart` | ว่างเปล่า — URL ยังฝังตรงใน data source |
| `core/errors/exceptions.dart` | ว่างเปล่า |
| `core/errors/failures.dart` | ว่างเปล่า |
| `core/network/dio_client.dart` | ว่างเปล่า — Dio สร้างตรงใน injection |
| `domain/usecases/get_nasa_images.dart` | ว่างเปล่า |
| `view_model/favorite_view_model.dart` | ว่างเปล่า |
| `dartz` package | import แต่ไม่ได้ใช้ Either type |
