import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/response.dart';
import '../domain/entities/review.dart';
import '../domain/repositories/response_repository.dart';

class InMemoryResponseRepository implements ResponseRepository {
  final Map<String, QuizResponse> _responses = <String, QuizResponse>{};
  final Map<String, Review> _reviewsByResponseId = <String, Review>{};
  final Map<String, StreamController<List<QuizResponse>>> _patientStreams =
      <String, StreamController<List<QuizResponse>>>{};
  final Map<String, StreamController<List<QuizResponse>>> _doctorStreams =
      <String, StreamController<List<QuizResponse>>>{};
  final Uuid _uuid = const Uuid();

  @override
  Future<Result<QuizResponse, Failure>> submitResponse(
    QuizResponse response,
  ) async {
    final QuizResponse toSave = response.id.isEmpty
        ? QuizResponse(
            id: _uuid.v4(),
            assignmentId: response.assignmentId,
            quizId: response.quizId,
            patientId: response.patientId,
            doctorId: response.doctorId,
            answers: response.answers,
            submittedAt: DateTime.now(),
            autoScore: response.autoScore,
            maxPossibleScore: response.maxPossibleScore,
            severityLabel: response.severityLabel,
            durationSeconds: response.durationSeconds,
          )
        : response;
    _responses[toSave.id] = toSave;
    _notify(toSave.patientId, toSave.doctorId);
    return Success<QuizResponse, Failure>(toSave);
  }

  @override
  Future<Result<QuizResponse, Failure>> getResponse(String responseId) async {
    final QuizResponse? r = _responses[responseId];
    if (r == null)
      return const Err<QuizResponse, Failure>(
        NotFoundFailure('Response not found.'),
      );
    return Success<QuizResponse, Failure>(r);
  }

  @override
  Stream<List<QuizResponse>> watchResponsesForPatient(String patientId) {
    final StreamController<List<QuizResponse>> c = _patientStreams.putIfAbsent(
      patientId,
      () => StreamController<List<QuizResponse>>.broadcast(),
    );
    scheduleMicrotask(() => c.add(_forPatient(patientId)));
    return c.stream;
  }

  @override
  Stream<List<QuizResponse>> watchResponsesAwaitingReview(String doctorId) {
    final StreamController<List<QuizResponse>> c = _doctorStreams.putIfAbsent(
      doctorId,
      () => StreamController<List<QuizResponse>>.broadcast(),
    );
    scheduleMicrotask(() => c.add(_awaitingReview(doctorId)));
    return c.stream;
  }

  List<QuizResponse> _forPatient(String patientId) =>
      _responses.values
          .where((QuizResponse r) => r.patientId == patientId)
          .toList()
        ..sort(
          (QuizResponse a, QuizResponse b) =>
              b.submittedAt.compareTo(a.submittedAt),
        );

  List<QuizResponse> _awaitingReview(String doctorId) =>
      _responses.values
          .where(
            (QuizResponse r) =>
                r.doctorId == doctorId &&
                !_reviewsByResponseId.containsKey(r.id),
          )
          .toList()
        ..sort(
          (QuizResponse a, QuizResponse b) =>
              a.submittedAt.compareTo(b.submittedAt),
        );

  void _notify(String patientId, String doctorId) {
    _patientStreams[patientId]?.add(_forPatient(patientId));
    _doctorStreams[doctorId]?.add(_awaitingReview(doctorId));
  }

  @override
  Future<Result<Review, Failure>> saveReview(Review review) async {
    final Review toSave = review.id.isEmpty
        ? Review(
            id: _uuid.v4(),
            responseId: review.responseId,
            doctorId: review.doctorId,
            finalScore: review.finalScore,
            reviewedAt: DateTime.now(),
            notes: review.notes,
            recommendedFollowUpInDays: review.recommendedFollowUpInDays,
          )
        : review;
    _reviewsByResponseId[toSave.responseId] = toSave;
    final QuizResponse? resp = _responses[toSave.responseId];
    if (resp != null) _notify(resp.patientId, resp.doctorId);
    return Success<Review, Failure>(toSave);
  }

  @override
  Future<Result<Review?, Failure>> getReviewForResponse(
    String responseId,
  ) async {
    return Success<Review?, Failure>(_reviewsByResponseId[responseId]);
  }

  void dispose() {
    for (final StreamController<List<QuizResponse>> c
        in _patientStreams.values) {
      c.close();
    }
    for (final StreamController<List<QuizResponse>> c
        in _doctorStreams.values) {
      c.close();
    }
  }
}
