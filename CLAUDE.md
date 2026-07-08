# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run          # run the app
flutter test         # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter analyze      # lint
flutter pub get      # install dependencies
```

## Architecture

Clean Architecture with BLoC pattern. Data flows strictly top-down:

```
View (pages/widgets)
  └── BlocBuilder reads state; context.read().add() fires events
BLoC (presentation/bloc/)
  └── Delegates all logic — no business logic lives here
ViewModel / Repository
  └── Holds in-memory state or calls a data source
DataSource / Storage
  └── Dio (NASA API) or GetStorage (local favorites)
```

### Two independent BLoC flows

**NASA images** (`NasaBlocBloc`)
- Single event `FetchNasaImages` → `NasaRemoteDataSourceImpl` → Dio GET `https://images-api.nasa.gov/search?q=earth&media_type=image`
- States: `NasaBlocInitial` → `NasaBlocLoading` → `NasaBlocLoaded(items)` / `NasaBlocError(message)`
- There is an intentional `Future.delayed(2s)` in the bloc to make the loading state visible

**Favorites** (`FavoritesBlocBloc`)
- `LoadFavorites` fires at bloc creation via `..add(LoadFavorites())` in `InjectionContainer`
- `ToggleFavorite(imageUrl)` → `FavoriteViewModel.toggleFavorite()` → `FavoritesStorage` (GetStorage, key `'nasa_favorites'`, stores `List<String>` of image URLs)
- All favorite logic lives in `FavoriteViewModel`; the BLoC is a thin delegating wrapper
- Both `FavoriteButton` (detail screen) and `NasaImageCard` (grid) use `buildWhen` to rebuild only when their specific URL's favorite status changes

### Dependency injection

`InjectionContainer` (manual, no service locator) wires everything at startup:
- `NasaRemoteDataSourceImpl` → `NasaRepositoryImpl` → `NasaBlocBloc`
- `FavoriteViewModel` → `FavoritesBlocBloc`

Both BLoC instances are provided at app root via `MultiBlocProvider` in `main.dart` so they survive navigation.

### Critical startup constraint

`GetStorage.init()` must be awaited before `runApp`. Skipping the await causes favorites to silently fail to load.

## Dead code to be aware of

Two directories are duplicates and are not imported anywhere:
- `lib/repository/` — unused
- `lib/features/` — unused

Empty stub files not yet implemented:
- `lib/core/constants/api_constants.dart`
- `lib/core/errors/exceptions.dart` and `failures.dart`
- `lib/core/network/dio_client.dart`
- `lib/nasa_repository/domain/usecases/get_nasa_images.dart`

## Other notes

- Theme is dark-only (`AppTheme.getDarkTheme()`), Material 3, seed color `Colors.deepPurple`. No light theme exists.
- Home grid is responsive: 2 columns when `screenWidth <= 600`, 3 columns when wider.
- After every code change, update `PROJECT_SUMMARY.md` before reporting done.
