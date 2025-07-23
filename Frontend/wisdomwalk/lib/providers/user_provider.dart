// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../models/user_model.dart';
// import 'package:wisdomwalk/services/local_storage_service.dart';

// class UserProvider with ChangeNotifier {
//   final LocalStorageService _localStorageService;
//   final List<UserModel> _allUsers = [];
//   List<UserModel> _searchResults = [];
//   bool _isLoading = false;
//   String? _error;
//   DateTime? _lastFetchTime;

//   // Cache duration - 5 minutes
//   static const Duration cacheDuration = Duration(minutes:5);

//   // Correct constructor - only one parameter needed
//   UserProvider({required LocalStorageService localStorageService})
//       : _localStorageService = localStorageService;

//   List<UserModel> get allUsers => List.unmodifiable(_allUsers);
//   List<UserModel> get searchResults => List.unmodifiable(_searchResults);
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> fetchAllUsers({bool forceRefresh = false}) async {
//     // Return cached data if it's fresh and not forcing refresh
//     if (!forceRefresh &&
//         _lastFetchTime != null &&
//         DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
//       return;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     final token = await _localStorageService.getAuthToken();
//     if (token == null) {
//       _error = 'Authentication required';
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     const url = 'https://wisdom-walk-app.onrender.com/api/admin/users';

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         _allUsers
//           ..clear()
//           ..addAll(data.map((e) => UserModel.fromJson(e)));
//         _searchResults = List.from(_allUsers);
//         _lastFetchTime = DateTime.now();

//         debugPrint("Fetched ${_allUsers.length} users");
//       } else {
//         _error = 'Failed to fetch users: ${response.statusCode} - ${response.body}';
//       }
//     } catch (e) {
//       _error = 'Error fetching users: ${e.toString()}';
//       debugPrint('Error in fetchAllUsers: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void searchLocally(String query) {
//     if (query.isEmpty) {
//       clearSearch();
//       return;
//     }

//     final lowerQuery = query.toLowerCase();
//     _searchResults = _allUsers.where((user) {
//       return (user.name?.toLowerCase().contains(lowerQuery) ?? false) ||
//              user.email.toLowerCase().contains(lowerQuery) ||
//              (user.fullName?.toLowerCase().contains(lowerQuery) ?? false);
//     }).toList();

//     notifyListeners();
//   }

//   void clearSearch() {
//     _searchResults = List.from(_allUsers);
//     notifyListeners();
//   }

//   Future<bool> blockUser(String userId) async {
//     final token = await _localStorageService.getAuthToken();
//     if (token == null) return false;

//     const url = 'https://wisdom-walk-app.onrender.com/api/admin/users/block';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'userId': userId}),
//       );

//       if (response.statusCode == 200) {
//         // Update the user's blocked status locally
//         final index = _allUsers.indexWhere((user) => user.id == userId);
//         if (index != -1) {
//           _allUsers[index] = _allUsers[index].copyWith(isBlocked: true);
//           notifyListeners();
//         }
//         return true;
//       } else {
//         _error = 'Failed to block user: ${response.statusCode}';
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = 'Error blocking user: ${e.toString()}';
//       notifyListeners();
//       return false;
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../models/user_model.dart';
// import 'package:wisdomwalk/services/local_storage_service.dart';
// import 'package:wisdomwalk/providers/auth_provider.dart';
// import 'package:wisdomwalk/services/user_service.dart';
// import 'package:go_router/go_router.dart';

// class UserProvider with ChangeNotifier {
//   final LocalStorageService _localStorageService;
//   UserModel _currentUser = UserModel.empty();
//   String? _userId;
//   final List<UserModel> _allUsers = [];
//   List<UserModel> _searchResults = [];
//   bool _isLoading = false;
//   String? _error;
//   DateTime? _lastFetchTime;
//   static const Duration cacheDuration = Duration(minutes: 5);

//   UserProvider({required LocalStorageService localStorageService})
//     : _localStorageService = localStorageService {
//     _initialize();
//   }

//   UserModel get currentUser => _currentUser;
//   List<UserModel> get allUsers => List.unmodifiable(_allUsers);
//   List<UserModel> get searchResults => List.unmodifiable(_searchResults);
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   String? get userId => _userId;

//   Future<void> _initialize() async {
//     _userId = await _localStorageService.getUserId();
//     if (_userId != null) {
//       await fetchCurrentUser(forceRefresh: true);
//     } else {
//       _error = 'User ID not found';
//       _currentUser = UserModel.empty();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchCurrentUser({
//     bool forceRefresh = false,
//     BuildContext? context,
//   }) async {
//     if (_userId == null) {
//       _userId = await _localStorageService.getUserId();
//       if (_userId == null) {
//         _error = 'User ID not found';
//         _isLoading = false;
//         _currentUser = UserModel.empty();
//         if (context != null) {
//           Provider.of<AuthProvider>(
//             context,
//             listen: false,
//           ).setCurrentUser(null);
//           if (context.mounted) {
//             context.go('/login');
//           }
//         }
//         notifyListeners();
//         return;
//       }
//     }

//     if (!forceRefresh &&
//         _lastFetchTime != null &&
//         DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
//       if (context != null &&
//           (!_currentUser.isVerified || _currentUser.isBlocked)) {
//         Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
//         if (context.mounted) {
//           context.go('/pending-screen');
//         }
//       } else if (context != null) {
//         Provider.of<AuthProvider>(
//           context,
//           listen: false,
//         ).setCurrentUser(_currentUser);
//       }
//       return;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     final token = await _localStorageService.getAuthToken();
//     if (token == null) {
//       _error = 'Authentication required';
//       _isLoading = false;
//       _currentUser = UserModel.empty();
//       if (context != null) {
//         Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
//         if (context.mounted) {
//           context.go('/login');
//         }
//       }
//       notifyListeners();
//       return;
//     }

//     const url = 'https://wisdom-walk-app.onrender.com/api/users/profile';
//     const maxRetries = 3;
//     int retryCount = 0;

//     while (retryCount < maxRetries) {
//       try {
//         final user = await UserService.getCurrentUser();
//         _currentUser = user;
//         _lastFetchTime = DateTime.now();
//         debugPrint(
//           'Fetched current user: ${_currentUser.displayName}, isAdminVerified: ${_currentUser.isVerified}, isBlocked: ${_currentUser.isBlocked}',
//         );

//         if (context != null) {
//           Provider.of<AuthProvider>(
//             context,
//             listen: false,
//           ).setCurrentUser(_currentUser);
//           if (!_currentUser.isVerified || _currentUser.isBlocked) {
//             if (context.mounted) {
//               context.go('/pending-screen');
//             }
//           } else if (context.mounted) {
//             context.go('/dashboard');
//           }
//         }
//         break;
//       } catch (e) {
//         debugPrint('Error in UserService.getCurrentUser: $e');
//         try {
//           final response = await http
//               .get(
//                 Uri.parse(url),
//                 headers: {
//                   'Content-Type': 'application/json',
//                   'Authorization': 'Bearer $token',
//                 },
//               )
//               .timeout(const Duration(seconds: 15));

//           debugPrint('fetchCurrentUser Response: ${response.statusCode}');
//           if (response.statusCode == 200) {
//             final data = json.decode(response.body);
//             final userData = data['data'] ?? data;
//             _currentUser = UserModel.fromJson(userData);
//             _lastFetchTime = DateTime.now();
//             debugPrint(
//               'Fetched current user: ${_currentUser.displayName}, isAdminVerified: ${_currentUser.isVerified}, isBlocked: ${_currentUser.isBlocked}',
//             );

//             if (context != null) {
//               Provider.of<AuthProvider>(
//                 context,
//                 listen: false,
//               ).setCurrentUser(_currentUser);
//               if (!_currentUser.isVerified || _currentUser.isBlocked) {
//                 if (context.mounted) {
//                   context.go('/pending-screen');
//                 }
//               } else if (context.mounted) {
//                 context.go('/dashboard');
//               }
//             }
//             break;
//           } else if (response.statusCode == 401) {
//             _error = 'Session expired. Please log in again.';
//             _currentUser = UserModel.empty();
//             if (context != null && context.mounted) {
//               Provider.of<AuthProvider>(
//                 context,
//                 listen: false,
//               ).setCurrentUser(null);
//               context.go('/login');
//             }
//             break;
//           } else {
//             _error = 'Failed to fetch user: ${response.statusCode}';
//             retryCount++;
//             if (retryCount >= maxRetries) {
//               _currentUser = UserModel.empty();
//               break;
//             }
//             await Future.delayed(const Duration(seconds: 2));
//           }
//         } catch (httpError) {
//           _error = 'Error fetching user: ${httpError.toString()}';
//           retryCount++;
//           if (retryCount >= maxRetries) {
//             _currentUser = UserModel.empty();
//             if (context != null && context.mounted) {
//               Provider.of<AuthProvider>(
//                 context,
//                 listen: false,
//               ).setCurrentUser(null);
//               context.go('/login');
//             }
//             break;
//           }
//           await Future.delayed(const Duration(seconds: 2));
//           debugPrint('Error in fetchCurrentUser HTTP call: $httpError');
//         }
//       }
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> fetchAllUsers({bool forceRefresh = false}) async {
//     if (!forceRefresh &&
//         _lastFetchTime != null &&
//         DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
//       return;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     final token = await _localStorageService.getAuthToken();
//     if (token == null) {
//       _error = 'Authentication required';
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     const url = 'https://wisdom-walk-app.onrender.com/api/admin/users';

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         _allUsers
//           ..clear()
//           ..addAll(data.map((e) => UserModel.fromJson(e)));
//         _searchResults = List.from(_allUsers);
//         _lastFetchTime = DateTime.now();
//         debugPrint("Fetched ${_allUsers.length} users");
//       } else {
//         _error =
//             'Failed to fetch users: ${response.statusCode} - ${response.body}';
//       }
//     } catch (e) {
//       _error = 'Error fetching users: ${e.toString()}';
//       debugPrint('Error in fetchAllUsers: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void searchLocally(String query) {
//     if (query.isEmpty) {
//       clearSearch();
//       return;
//     }

//     final lowerQuery = query.toLowerCase();
//     _searchResults =
//         _allUsers.where((user) {
//           return (user.name?.toLowerCase().contains(lowerQuery) ?? false) ||
//               user.email.toLowerCase().contains(lowerQuery) ||
//               (user.fullName.toLowerCase().contains(lowerQuery));
//         }).toList();

//     notifyListeners();
//   }

//   void clearSearch() {
//     _searchResults = List.from(_allUsers);
//     notifyListeners();
//   }

//   Future<bool> blockUser(String userId) async {
//     final token = await _localStorageService.getAuthToken();
//     if (token == null) return false;

//     const url = 'https://wisdom-walk-app.onrender.com/api/admin/users/block';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'userId': userId}),
//       );

//       if (response.statusCode == 200) {
//         final index = _allUsers.indexWhere((user) => user.id == userId);
//         if (index != -1) {
//           _allUsers[index] = _allUsers[index].copyWith(isBlocked: true);
//           if (_currentUser.id == userId) {
//             _currentUser = _currentUser.copyWith(isBlocked: true);
//           }
//           notifyListeners();
//         }
//         return true;
//       } else {
//         _error = 'Failed to block user: ${response.statusCode}';
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = 'Error blocking user: ${e.toString()}';
//       notifyListeners();
//       return false;
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/services/user_service.dart';
import 'package:go_router/go_router.dart';

class UserProvider with ChangeNotifier {
  final LocalStorageService _localStorageService;
  UserModel _currentUser = UserModel.empty();
  UserModel _viewedUser = UserModel.empty(); // New field for viewed user
  String? _userId;
  final List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  UserProvider({required LocalStorageService localStorageService})
    : _localStorageService = localStorageService {
    _initialize();
  }

  UserModel get currentUser => _currentUser;
  UserModel get viewedUser => _viewedUser; // Getter for viewed user
  List<UserModel> get allUsers => List.unmodifiable(_allUsers);
  List<UserModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  Future<void> _initialize() async {
    _userId = await _localStorageService.getUserId();
    if (_userId != null) {
      await fetchCurrentUser(forceRefresh: true);
    } else {
      _error = 'User ID not found';
      _currentUser = UserModel.empty();
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser({
    bool forceRefresh = false,
    BuildContext? context,
    bool skipRedirect = false, // New parameter
  }) async {
    if (_userId == null) {
      _userId = await _localStorageService.getUserId();
      if (_userId == null) {
        _error = 'User ID not found';
        _isLoading = false;
        _currentUser = UserModel.empty();
        if (context != null && !skipRedirect && context.mounted) {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setCurrentUser(null);
          context.go('/login');
        }
        notifyListeners();
        return;
      }
    }

    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      if (context != null &&
          !skipRedirect &&
          (!_currentUser.isVerified || _currentUser.isBlocked)) {
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
        if (context.mounted) context.go('/pending-screen');
      } else if (context != null && !skipRedirect) {
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setCurrentUser(_currentUser);
      }
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await _localStorageService.getAuthToken();
    if (token == null) {
      _error = 'Authentication required';
      _isLoading = false;
      _currentUser = UserModel.empty();
      if (context != null && !skipRedirect && context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
        context.go('/login');
      }
      notifyListeners();
      return;
    }

    const url = 'https://wisdom-walk-app.onrender.com/api/users/profile';
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final user = await UserService.getCurrentUser();
        _currentUser = user;
        _lastFetchTime = DateTime.now();
        debugPrint(
          'Fetched current user: ${_currentUser.displayName}, '
          'isAdminVerified: ${_currentUser.isVerified}, '
          'isBlocked: ${_currentUser.isBlocked}, '
          'avatarUrl: ${_currentUser.avatarUrl}',
        );

        if (context != null && !skipRedirect) {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setCurrentUser(_currentUser);
          if (!_currentUser.isVerified || _currentUser.isBlocked) {
            if (context.mounted) context.go('/pending-screen');
          } else if (context.mounted) {
            context.go('/dashboard');
          }
        }
        break;
      } catch (e) {
        debugPrint('Error in UserService.getCurrentUser: $e');
        try {
          final response = await http
              .get(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 45));

          debugPrint('fetchCurrentUser Response: ${response.statusCode}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final userData = data['data'] ?? data;
            _currentUser = UserModel.fromJson(userData);
            _lastFetchTime = DateTime.now();
            debugPrint(
              'Fetched current user: ${_currentUser.displayName}, '
              'isAdminVerified: ${_currentUser.isVerified}, '
              'isBlocked: ${_currentUser.isBlocked}, '
              'avatarUrl: ${_currentUser.avatarUrl}',
            );

            if (context != null && !skipRedirect) {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).setCurrentUser(_currentUser);
              if (!_currentUser.isVerified || _currentUser.isBlocked) {
                if (context.mounted) context.go('/pending-screen');
              } else if (context.mounted) {
                context.go('/dashboard');
              }
            }
            break;
          } else if (response.statusCode == 401) {
            _error = 'Session expired. Please log in again.';
            _currentUser = UserModel.empty();
            if (context != null && !skipRedirect && context.mounted) {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).setCurrentUser(null);
              context.go('/login');
            }
            break;
          } else {
            _error = 'Failed to fetch user: ${response.statusCode}';
            retryCount++;
            if (retryCount >= maxRetries) {
              _currentUser = UserModel.empty();
              break;
            }
            await Future.delayed(const Duration(seconds: 2));
          }
        } catch (httpError) {
          _error = 'Error fetching user: ${httpError.toString()}';
          retryCount++;
          if (retryCount >= maxRetries) {
            _currentUser = UserModel.empty();
            if (context != null && !skipRedirect && context.mounted) {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).setCurrentUser(null);
              context.go('/login');
            }
            break;
          }
          await Future.delayed(const Duration(seconds: 2));
          debugPrint('Error in fetchCurrentUser HTTP call: $httpError');
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserById({
    required BuildContext context,
    required String userId,
    bool forceRefresh = false,
    bool skipRedirect = false, // New parameter
  }) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration &&
        _viewedUser.id == userId) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await _localStorageService.getAuthToken();
    if (token == null) {
      _error = 'Authentication required';
      _isLoading = false;
      _viewedUser = UserModel.empty();
      if (!skipRedirect && context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
        context.go('/login');
      }
      notifyListeners();
      return;
    }

    final url = 'https://wisdom-walk-app.onrender.com/api/users/$userId';
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 45));

        debugPrint('fetchUserById Response: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final userData = data['data'] ?? data;
          _viewedUser = UserModel.fromJson(userData);
          _lastFetchTime = DateTime.now();
          debugPrint(
            'Fetched user: ${_viewedUser.displayName}, '
            'isAdminVerified: ${_viewedUser.isVerified}, '
            'isBlocked: ${_viewedUser.isBlocked}, '
            'avatarUrl: ${_viewedUser.avatarUrl}',
          );
          break;
        } else if (response.statusCode == 401) {
          _error = 'Session expired. Please log in again.';
          _viewedUser = UserModel.empty();
          if (!skipRedirect && context.mounted) {
            Provider.of<AuthProvider>(
              context,
              listen: false,
            ).setCurrentUser(null);
            context.go('/login');
          }
          break;
        } else if (response.statusCode == 404) {
          _error = 'User not found';
          _viewedUser = UserModel.empty();
          break;
        } else {
          _error = 'Failed to fetch user: ${response.statusCode}';
          retryCount++;
          if (retryCount >= maxRetries) {
            _viewedUser = UserModel.empty();
            break;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        _error = 'Error fetching user: ${e.toString()}';
        retryCount++;
        if (retryCount >= maxRetries) {
          _viewedUser = UserModel.empty();
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('Error in fetchUserById HTTP call: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllUsers({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await _localStorageService.getAuthToken();
    if (token == null) {
      _error = 'Authentication required';
      _isLoading = false;
      notifyListeners();
      return;
    }

    const url = 'https://wisdom-walk-app.onrender.com/api/admin/users';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allUsers
          ..clear()
          ..addAll(data.map((e) => UserModel.fromJson(e)));
        _searchResults = List.from(_allUsers);
        _lastFetchTime = DateTime.now();
        debugPrint("Fetched ${_allUsers.length} users");
      } else {
        _error =
            'Failed to fetch users: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _error = 'Error fetching users: ${e.toString()}';
      debugPrint('Error in fetchAllUsers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchLocally(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    final lowerQuery = query.toLowerCase();
    _searchResults =
        _allUsers.where((user) {
          return (user.name?.toLowerCase().contains(lowerQuery) ?? false) ||
              user.email.toLowerCase().contains(lowerQuery) ||
              (user.fullName.toLowerCase().contains(lowerQuery));
        }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = List.from(_allUsers);
    notifyListeners();
  }

  Future<bool> blockUser(String userId) async {
    final token = await _localStorageService.getAuthToken();
    if (token == null) return false;

    const url = 'https://wisdom-walk-app.onrender.com/api/admin/users/block';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final index = _allUsers.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(isBlocked: true);
          if (_currentUser.id == userId) {
            _currentUser = _currentUser.copyWith(isBlocked: true);
          }
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to block user: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error blocking user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
