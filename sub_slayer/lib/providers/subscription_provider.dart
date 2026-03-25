import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final categoryListProvider = AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  () => CategoryListNotifier(),
);

final subscriptionListProvider = AsyncNotifierProvider<SubscriptionListNotifier, List<Subscription>>(
  () => SubscriptionListNotifier(),
);

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  ApiService get _api => ref.read(apiServiceProvider);

  @override
  Future<List<Category>> build() async {
    return _api.fetchCategories();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _api.fetchCategories());
  }
}

class SubscriptionListNotifier extends AsyncNotifier<List<Subscription>> {
  ApiService get _api => ref.read(apiServiceProvider);

  @override
  Future<List<Subscription>> build() async {
    return _api.fetchSubscriptions();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _api.fetchSubscriptions());
  }

  Future<void> addSubscription(Subscription subscription) async {
    final created = await _api.createSubscription(subscription);
    state = state.whenData((subs) => [...subs, created]);
  }

  Future<void> updateSubscription(Subscription subscription) async {
    final updated = await _api.updateSubscription(subscription);
    state = state.whenData((subs) => subs.map((s) => s.id == updated.id ? updated : s).toList());
  }

  Future<void> deleteSubscription(int id) async {
    await _api.deleteSubscription(id);
    state = state.whenData((subs) => subs.where((s) => s.id != id).toList());
  }
}
