import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/response.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/severity_band.dart';
import '../providers/quiz_providers.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({required this.responseId, super.key});
  final String responseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(responseByIdProvider(responseId));
    return responseAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: ErrorView(message: e.toString()),
      ),
      data: (response) {
        final quizAsync = ref.watch(quizByIdProvider(response.quizId));
        return quizAsync.when(
          loading: () => const Scaffold(body: LoadingIndicator()),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Result')),
            body: ErrorView(message: e.toString()),
          ),
          data: (quiz) => _buildContent(context, ref, response, quiz),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, QuizResponse response, Quiz quiz) {
    final SeverityBand? band = quiz.bandFor(response.autoScore);
    final Color tone = band?.color ?? AppColors.info;
    final Review? review = ref.watch(reviewForResponseProvider(responseId)).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: CustomScrollView(
        slivers: <Widget>[
          // ── Clean top bar ─────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0A0A0A)),
              onPressed: () => context.goNamed(RouteNames.patientHome),
            ),
            title: const Text(
              'Your Result',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE2E8F0)),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[

                // ── Score hero card ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'SUBMITTED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 22),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${response.autoScore}',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          if (response.maxPossibleScore != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                ' / ${response.maxPossibleScore}',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (band != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          band.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Severity scale card ───────────────────────────
                if (quiz.severityBands.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Severity scale',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SeverityScale(
                          bands: quiz.severityBands,
                          score: response.autoScore,
                        ),
                        if (band?.guidance != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            band!.guidance!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF52596B),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // ── Info note ────────────────────────────────────
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.info.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.info, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Auto-calculated score. Your doctor will review this and may adjust the final result.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF52596B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Doctor feedback ───────────────────────────────
                if (review != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _card(
                    borderColor: AppColors.secondary.withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.secondary
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.medical_services_rounded,
                                  color: AppColors.secondary,
                                  size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Doctor's Notes",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                          ],
                        ),
                        if (review.finalScore != response.autoScore) ...<Widget>[
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              const Text('Reviewed score: ',
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                '${review.finalScore}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              if (response.maxPossibleScore != null)
                                Text(' / ${response.maxPossibleScore}',
                                    style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                        if (review.notes != null &&
                            review.notes!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(review.notes!,
                                style: const TextStyle(
                                    fontSize: 14, height: 1.5)),
                          ),
                        ],
                        if (review.recommendedFollowUpInDays !=
                            null) ...<Widget>[
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text('Follow-up: ',
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                DateFormat('MMM d, yyyy').format(
                                  review.reviewedAt.add(Duration(
                                      days: review
                                          .recommendedFollowUpInDays!)),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.goNamed(RouteNames.patientHome),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE3E6EE),
          width: borderColor != null ? 1.5 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SeverityScale extends StatelessWidget {
  const _SeverityScale({required this.bands, required this.score});

  final List<SeverityBand> bands;
  final int score;

  @override
  Widget build(BuildContext context) {
    if (bands.isEmpty) return const SizedBox.shrink();
    final int minScore = bands.first.minInclusive;
    final int maxScore = bands.last.maxInclusive;
    final int range = (maxScore - minScore).clamp(1, 1 << 30);
    final double markerPos =
        ((score - minScore) / range).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double width = c.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: <Widget>[
                    for (final SeverityBand b in bands)
                      Expanded(
                        flex: (b.maxInclusive - b.minInclusive + 1),
                        child: Container(color: b.color.withValues(alpha: 0.85)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: (markerPos * width).clamp(0.0, width - 2),
                    top: -4,
                    child: Container(
                      width: 2,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F36),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '$minScore',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF8A90A2),
                  ),
                ),
                Text(
                  '$maxScore',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF8A90A2),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
