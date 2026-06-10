import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyService();
  late Future<Map<String, double>> _ratesFuture;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  void _loadRates() {
    _ratesFuture = _currencyService.getCurrencyRates();
  }

  String _formatRate(double value) {
    return NumberFormat.currency(
      locale: 'tr_TR',
      symbol: 'TL',
      decimalDigits: 2,
    ).format(value);
  }

  Future<void> _refreshRates() async {
    setState(() {
      _loadRates();
    });

    await _ratesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Döviz Kurları'),
        actions: [
          IconButton(
            onPressed: _refreshRates,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<Map<String, double>>(
            future: _ratesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 42,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Döviz verileri alınamadı',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İnternet bağlantını kontrol edip tekrar deneyebilirsin.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _refreshRates,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final rates = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _refreshRates,
                child: ListView(
                  children: [
                    Text(
                      'Güncel döviz kurlarını Türk lirası karşılığıyla takip et.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CurrencyCard(
                      title: 'Amerikan Doları',
                      code: 'USD',
                      icon: Icons.attach_money_rounded,
                      amountText: '1 USD ≈ ${_formatRate(rates['USD']!)}',
                    ),
                    const SizedBox(height: 14),
                    _CurrencyCard(
                      title: 'Euro',
                      code: 'EUR',
                      icon: Icons.euro_rounded,
                      amountText: '1 EUR ≈ ${_formatRate(rates['EUR']!)}',
                    ),
                    const SizedBox(height: 14),
                    _CurrencyCard(
                      title: 'İngiliz Sterlini',
                      code: 'GBP',
                      icon: Icons.currency_pound_rounded,
                      amountText: '1 GBP ≈ ${_formatRate(rates['GBP']!)}',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Veriler TRY tabanlı kur servisinden alınır ve yabancı para birimleri için ters çevrilerek hesaplanır.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.title,
    required this.code,
    required this.icon,
    required this.amountText,
  });

  final String title;
  final String code;
  final IconData icon;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    amountText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
