import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
      (ref) => FirestoreService(),
);


// Saare products ka stream
final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(firestoreServiceProvider).getProducts();
});

// User role provider
final userRoleProvider = FutureProvider<String>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return 'customer';
      return ref.read(firestoreServiceProvider).getUserRole(user.uid);
    },
    loading: () async => 'customer',
    error: (_, __) async => 'customer',
  );
});