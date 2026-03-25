import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';

class AboListScreen extends ConsumerStatefulWidget {
  const AboListScreen({super.key});

  @override
  ConsumerState<AboListScreen> createState() => _AboListScreenState();
}

class _AboListScreenState extends ConsumerState<AboListScreen> {
  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(subscriptionListProvider);
    final currencyState = ref.watch(currencyProvider);
    final language = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate(language, 'app_title'),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: subsAsync.when(
        data: (subscriptions) => _buildSubscriptionList(context, ref, subscriptions, isDarkMode, currencyState, language),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${AppLocalizations.translate(language, 'error_loading')} $error',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.add, size: 40, color: theme.primaryColor),
      ),
    );
  }

  Widget _buildSubscriptionTile(
    BuildContext context,
    WidgetRef ref,
    Subscription sub,
    bool isDarkMode,
    CurrencyState currencyState,
    Language language,
  ) {
    return Dismissible(
      key: ValueKey(sub.id ?? sub.name),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF2A2A40) : Colors.white,
              title: Text(AppLocalizations.translate(language, 'delete_subscription'),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              content: Text(
                AppLocalizations.translate(language, 'delete_confirm').replaceFirst('{name}', sub.name),
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.translate(language, 'cancel'),
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.translate(language, 'delete'), style: const TextStyle(color: Colors.redAccent)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        final messenger = ScaffoldMessenger.of(context);
        if (sub.id != null) {
          try {
            await ref.read(subscriptionListProvider.notifier).deleteSubscription(sub.id!);
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(AppLocalizations.translate(language, 'subscription_deleted'))),
            );
          } catch (e) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(AppLocalizations.translate(language, 'delete_error').replaceFirst('{error}', e.toString()))),
            );
            if (mounted) {
              ref.read(subscriptionListProvider.notifier).refresh();
            }
          }
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/add-edit', arguments: sub);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A2A40) : Colors.grey.shade200,
            border: Border.all(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getCategoryColor(sub.categoryName),
                radius: 25,
                child: Icon(
                  _getCategoryIcon(sub.categoryName),
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${currencyState.formatPrice(sub.price)} | ${_formatDate(sub.startDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: isDarkMode ? const Color(0xFF2A2A40) : Colors.white,
                        title: Text('Abo löschen',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        content: Text(
                          'Möchtest du ${sub.name} wirklich löschen?',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Abbrechen', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Löschen', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    );
                  },
                );
                if (shouldDelete == true && sub.id != null) {
                  try {
                    await ref.read(subscriptionListProvider.notifier).deleteSubscription(sub.id!);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Abonnement gelöscht')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Fehler beim Löschen: $e')),
                    );
                    if (mounted) {
                      ref.read(subscriptionListProvider.notifier).refresh();
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    ) );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'gaming':
        return Icons.sports_esports;
      case 'streaming':
        return Icons.movie;
      case 'mobile':
        return Icons.smartphone;
      case 'musik':
        return Icons.music_note;
      case 'bildung':
        return Icons.school;
      default:
        return Icons.subscriptions_outlined;
    }
  }
  Widget _buildSubscriptionList(
    BuildContext context,
    WidgetRef ref,
    List<Subscription> subscriptions,
    bool isDarkMode,
    CurrencyState currencyState,
    Language language,
  ) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.subscriptions_outlined,
                size: 56,
                color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.translate(language, 'no_subscriptions'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.translate(language, 'tap_to_add'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(subscriptionListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final sub = subscriptions[index];
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _buildSubscriptionTile(context, ref, sub, isDarkMode, currencyState, language),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'gaming':
        return Colors.deepPurple;
      case 'streaming':
        return Colors.purple;
      case 'mobile':
        return Colors.orange;
      case 'musik':
        return Colors.blueAccent;
      case 'bildung':
        return Colors.green;
      default:
        return Colors.white24;
    }
  }
}
