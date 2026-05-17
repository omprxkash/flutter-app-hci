import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
  );

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
      backgroundColor: const Color(0xFFF7F8FB),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1565C0),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: _gradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Assessment Submitted',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your responses have been sent to your doctor.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.goNamed(RouteNames.patientHome),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                // Score card
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        quiz.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF52596B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${response.autoScore}',
                            style: GoogleFonts.poppins(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: tone,
                              height: 1,
                            ),
                          ),
                          if (response.maxPossibleScore != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                ' / ${response.maxPossibleScore}',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (band != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: tone.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            band.label.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: tone,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                      if (band?.guidance != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          band!.guidance!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF52596B),
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.info.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.info, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Auto-calculated screening score — your doctor will review and may adjust the final result.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF52596B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Doctor feedback
                if (review != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _card(
                    borderColor: AppColors.secondary.withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.medical_services_rounded,
                                color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Doctor's Notes",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        if (review.finalScore != response.autoScore) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Text('Reviewed score: ',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              Text(
                                '${review.finalScore}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              if (response.maxPossibleScore != null)
                                Text(' / ${response.maxPossibleScore}',
                                    style: GoogleFonts.poppins(fontSize: 14)),
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
                              color: const Color(0xFFF7F8FB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              review.notes!,
                              style:
                                  GoogleFonts.poppins(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                        if (review.recommendedFollowUpInDays != null) ...<Widget>[
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Follow-up: ',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy').format(
                                  review.reviewedAt.add(Duration(
                                      days: review.recommendedFollowUpInDays!)),
                                ),
                                style: GoogleFonts.poppins(
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

                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => context.goNamed(RouteNames.patientHome),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
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
