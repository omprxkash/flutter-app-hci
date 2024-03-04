import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/response.dart';
import '../entities/review.dart';

abstract class ResponseRepository {
  Future<Result<QuizResponse, Failure>> submitResponse(QuizResponse response);

  Future<Result<QuizResponse, Failure>> getResponse(String responseId);

  Stream<List<QuizResponse>> watchResponsesForPatient(String patientId);

  Stream<List<QuizResponse>> watchResponsesAwaitingReview(String doctorId);

  Future<Result<Review, Failure>> saveReview(Review review);

  Future<Result<Review?, Failure>> getReviewForResponse(String responseId);
}
