import 'package:flutter/material.dart';

/// Paywall screen shown when a free-tier user tries to access a Pro feature.
///
/// Integrates with Stripe / RevenueCat for purchase flow.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, this.featureBlocked});

  /// Optional: the specific feature that triggered the paywall.
  final String? featureBlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // ── Hero ──
              Text(
                'Unlock LocoTrader Pro',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (featureBlocked != null)
                Text(
                  '"$featureBlocked" requires Pro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 32),

              // ── Features ──
              _FeatureRow(icon: Icons.all_inclusive, label: 'Unlimited trades'),
              _FeatureRow(
                icon: Icons.upload_file,
                label:
                    'CSV broker import (MT4, MT5, cTrader, TradingView, Binance)',
              ),
              _FeatureRow(
                icon: Icons.insights,
                label: 'Edge Map analytics — personalized per-user',
              ),
              _FeatureRow(
                icon: Icons.picture_as_pdf,
                label: 'PDF tear sheet export',
              ),
              _FeatureRow(
                icon: Icons.cloud_sync,
                label: 'Cloud sync across devices',
              ),
              _FeatureRow(
                icon: Icons.smart_toy,
                label: 'AI Coach (bring your own key)',
              ),
              _FeatureRow(
                icon: Icons.business_center,
                label: 'Prop-firm profiles (FTMO, TFT...)',
              ),

              const Spacer(flex: 2),

              // ── Pricing ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                  color: theme.colorScheme.primary.withAlpha(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '\$7.99 / month',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'or \$59.99 / year (save 37%)',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── CTA ──
              FilledButton(
                onPressed: () => _handlePurchase(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Start 7-Day Free Trial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _restorePurchases(context),
                child: const Text('Restore Purchases'),
              ),

              const SizedBox(height: 16),
              Text(
                'Cancel anytime. No charge during trial. '
                'Subscription auto-renews unless cancelled 24h before period end.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context) {
    // TODO: Integrate with RevenueCat / Stripe IAP
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment integration coming soon.')),
    );
  }

  void _restorePurchases(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Restoring purchases...')));
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
