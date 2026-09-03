import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Creator Stats Models ─────────────────────────────────────────────────────

class StatsCardData {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  StatsCardData({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });
}

// ─── Creator Dashboard Providers ──────────────────────────────────────────────

final statsCardsProvider = StateProvider<List<StatsCardData>>((ref) => [
      StatsCardData(
        label: 'Reach',
        value: '248.5K',
        change: '+12.5%',
        isPositive: true,
        icon: Icons.visibility_rounded,
      ),
      StatsCardData(
        label: 'Views',
        value: '1.2M',
        change: '+8.3%',
        isPositive: true,
        icon: Icons.play_circle_outline_rounded,
      ),
      StatsCardData(
        label: 'Likes',
        value: '89.4K',
        change: '+15.2%',
        isPositive: true,
        icon: Icons.favorite_rounded,
      ),
      StatsCardData(
        label: 'Followers Growth',
        value: '+3.2K',
        change: '+4.7%',
        isPositive: true,
        icon: Icons.trending_up_rounded,
      ),
    ]);

final selectedPeriodProvider = StateProvider<String>((ref) => '7D');
final selectedAudienceInsightProvider = StateProvider<int>((ref) => 0);

// ─── Creator Dashboard Screen ─────────────────────────────────────────────────

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  static const List<String> _periods = ['24H', '7D', '30D', '90D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsCards = ref.watch(statsCardsProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Creator Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Period Selector ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _periods.map((period) {
                final isSelected = selectedPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(selectedPeriodProvider.notifier)
                        .state = period,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          period,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          // ── Stats Cards Grid ───────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: statsCards.length,
            itemBuilder: (context, index) {
              final stat = statsCards[index];
              return _StatsCard(stat: stat)
                  .animate(delay: Duration(milliseconds: 80 * index))
                  .fade(duration: 400.ms)
                  .scale(duration: 400.ms, curve: Curves.easeOutBack);
            },
          ),

          const SizedBox(height: 20),

          // ── Reach Over Time Chart Placeholder ──────────────────────────────
          _SectionHeader(
            title: 'Reach Over Time',
            subtitle: 'Last $selectedPeriod',
          ),
          const SizedBox(height: 12),
          _ChartPlaceholder(
            height: 220,
            label: 'Reach',
          )
              .animate()
              .fade(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ── Engagement Chart Placeholder ───────────────────────────────────
          _SectionHeader(
            title: 'Engagement',
            subtitle: 'Likes, comments & shares',
          ),
          const SizedBox(height: 12),
          _EngagementChartPlaceholder()
              .animate()
              .fade(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ── Audience Insights ──────────────────────────────────────────────
          _SectionHeader(
            title: 'Audience Insights',
            subtitle: 'Who follows you',
          ),
          const SizedBox(height: 12),
          _AudienceInsights()
              .animate()
              .fade(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ── Top Posts ──────────────────────────────────────────────────────
          _SectionHeader(
            title: 'Top Performing Posts',
            subtitle: 'Based on engagement',
          ),
          const SizedBox(height: 12),
          _TopPostsGrid()
              .animate()
              .fade(delay: 500.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // ── Boost Button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.rocket_launch_rounded, size: 20),
              label: const Text(
                'Boost Your Content',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          )
              .animate()
              .fade(delay: 600.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final StatsCardData stat;

  const _StatsCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stat.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stat.isPositive
                      ? const Color(0xFF4CAF50).withOpacity(0.12)
                      : const Color(0xFFF44336).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stat.change,
                  style: TextStyle(
                    color: stat.isPositive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See all',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Chart Placeholder ────────────────────────────────────────────────────────

class _ChartPlaceholder extends StatelessWidget {
  final double height;
  final String label;

  const _ChartPlaceholder({required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) => Container(
                  width: 24,
                  height: 40 + (index * 17) % 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$label trend chart placeholder',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Engagement Chart Placeholder ─────────────────────────────────────────────

class _EngagementChartPlaceholder extends StatelessWidget {
  const _EngagementChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: Theme.of(context).colorScheme.primary,
                label: 'Likes',
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: Theme.of(context).colorScheme.secondary,
                label: 'Comments',
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: const Color(0xFFFF6B35),
                label: 'Shares',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Simulated line chart
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _LineChartPainter(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Engagement line chart placeholder',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final Color color;

  _LineChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.65),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width, size.height * 0.35),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(
        midX,
        prev.dy,
        midX,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }

    // Fill area
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Audience Insights ────────────────────────────────────────────────────────

class _AudienceInsights extends ConsumerWidget {
  const _AudienceInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInsight = ref.watch(selectedAudienceInsightProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Insight tabs
          Row(
            children: [
              _InsightTab(
                label: 'Gender',
                isSelected: selectedInsight == 0,
                onTap: () => ref
                    .read(selectedAudienceInsightProvider.notifier)
                    .state = 0,
              ),
              _InsightTab(
                label: 'Age',
                isSelected: selectedInsight == 1,
                onTap: () => ref
                    .read(selectedAudienceInsightProvider.notifier)
                    .state = 1,
              ),
              _InsightTab(
                label: 'Location',
                isSelected: selectedInsight == 2,
                onTap: () => ref
                    .read(selectedAudienceInsightProvider.notifier)
                    .state = 2,
              ),
            ],
          ),

          // Insight content
          Padding(
            padding: const EdgeInsets.all(16),
            child: IndexedStack(
              index: selectedInsight,
              children: [
                // Gender
                Column(
                  children: [
                    _InsightBar(
                      label: 'Female',
                      percentage: 62,
                      color: const Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: 'Male',
                      percentage: 35,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: 'Other',
                      percentage: 3,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),

                // Age
                Column(
                  children: [
                    _InsightBar(
                      label: '18-24',
                      percentage: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: '25-34',
                      percentage: 31,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: '35-44',
                      percentage: 18,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: '45+',
                      percentage: 9,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),

                // Location
                Column(
                  children: [
                    _InsightBar(
                      label: 'United States',
                      percentage: 45,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: 'United Kingdom',
                      percentage: 22,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: 'Canada',
                      percentage: 15,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 12),
                    _InsightBar(
                      label: 'Others',
                      percentage: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InsightTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _InsightBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor:
                    Theme.of(context).colorScheme.outline.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${percentage.toInt()}%',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
      ],
    );
  }
}

// ─── Top Posts Grid ───────────────────────────────────────────────────────────

class _TopPostsGrid extends StatelessWidget {
  const _TopPostsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/seed/toppost${index + 1}/300/300',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(12 - index * 3)}K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
