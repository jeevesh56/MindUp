class AssessmentQuestion {
  final String id;
  final String text;
  final String category; // 'depression', 'stress', 'happiness'
  final List<String> options;
  final List<int> scores;

  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.category,
    required this.options,
    required this.scores,
  });
}

class AssessmentResult {
  final String id;
  final String category;
  final int totalScore;
  final int maxScore;
  final String level; // 'Low', 'Mild', 'Moderate', 'High', 'Severe'
  final String description;
  final List<String> recommendations;
  final DateTime completedAt;

  const AssessmentResult({
    required this.id,
    required this.category,
    required this.totalScore,
    required this.maxScore,
    required this.level,
    required this.description,
    required this.recommendations,
    required this.completedAt,
  });

  double get percentage => (totalScore / maxScore) * 100;
}

