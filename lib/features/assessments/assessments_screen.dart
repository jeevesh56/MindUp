import 'package:flutter/material.dart';
import 'models/assessment_question.dart';
import 'assessment_service.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  final AssessmentService _service = AssessmentService();
  String? _selectedCategory;

  final Map<String, List<AssessmentQuestion>> _assessments = {
    'depression': [
      AssessmentQuestion(
        id: 'dep_1',
        text: 'I feel sad, down, or empty most of the time, and this feeling persists throughout my day',
        category: 'depression',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'dep_2',
        text: 'I have lost interest or pleasure in activities that I used to enjoy, and I no longer look forward to things',
        category: 'depression',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'dep_3',
        text: 'I feel hopeless about the future and believe that things will not get better for me',
        category: 'depression',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'dep_4',
        text: 'I have significant trouble concentrating, making decisions, or remembering things that I normally would',
        category: 'depression',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'dep_5',
        text: 'I feel worthless, guilty, or like I am a burden to others around me',
        category: 'depression',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
    ],
    'stress': [
      AssessmentQuestion(
        id: 'stress_1',
        text: 'I feel overwhelmed by my daily responsibilities and feel like I cannot keep up with everything',
        category: 'stress',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'stress_2',
        text: 'I have trouble falling asleep or staying asleep because my mind is racing with worries and concerns',
        category: 'stress',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'stress_3',
        text: 'I feel tense, anxious, or on edge most of the time, even when there is no immediate threat',
        category: 'stress',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'stress_4',
        text: 'I experience physical symptoms like headaches, muscle tension, stomach problems, or fatigue due to stress',
        category: 'stress',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'stress_5',
        text: 'I feel like I cannot cope with the daily challenges and demands of my life',
        category: 'stress',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
    ],
    'happiness': [
      AssessmentQuestion(
        id: 'happy_1',
        text: 'I feel positive and optimistic about my life overall, and I believe good things are ahead',
        category: 'happiness',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'happy_2',
        text: 'I genuinely enjoy spending quality time with my friends, family, and loved ones',
        category: 'happiness',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'happy_3',
        text: 'I regularly feel grateful for the good things in my life and appreciate what I have',
        category: 'happiness',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'happy_4',
        text: 'I feel confident in my abilities and believe I can handle the challenges that come my way',
        category: 'happiness',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
      AssessmentQuestion(
        id: 'happy_5',
        text: 'I look forward to the future with excitement and anticipation for what is to come',
        category: 'happiness',
        options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
        scores: [0, 1, 2, 3, 4],
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assessments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _selectedCategory == null ? _buildCategorySelection() : _buildAssessment(),
    );
  }

  Widget _buildCategorySelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose an Assessment',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Select a mental health assessment to understand your current state and get personalized recommendations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        _buildCategoryCard(
          'Depression Assessment',
          'Evaluate your mood and emotional well-being',
          Icons.sentiment_dissatisfied,
          Colors.blue,
          'depression',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Stress Assessment',
          'Check your stress levels and coping mechanisms',
          Icons.psychology,
          Colors.orange,
          'stress',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Happiness Assessment',
          'Measure your life satisfaction and positive emotions',
          Icons.sentiment_very_satisfied,
          Colors.green,
          'happiness',
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Results',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AssessmentResult>>(
          stream: _service.getRecentResults(days: 30),
          builder: (context, snapshot) {
            final results = snapshot.data ?? [];
            if (results.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No assessments completed yet. Take your first assessment above!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: results.take(3).map((result) => _buildResultCard(result)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color color, String category) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(AssessmentResult result) {
    final color = _getCategoryColor(result.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.category.toUpperCase()} Assessment',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${result.level} (${result.totalScore}/${result.maxScore})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(result.completedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'depression': return Colors.blue;
      case 'stress': return Colors.orange;
      case 'happiness': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAssessment() {
    final questions = _assessments[_selectedCategory!]!;
    return AssessmentWidget(
      questions: questions,
      onComplete: (result) async {
        await _service.saveAssessmentResult(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedCategory!.toUpperCase()} assessment completed!'),
              backgroundColor: _getCategoryColor(_selectedCategory!),
            ),
          );
          setState(() => _selectedCategory = null);
        }
      },
      onCancel: () => setState(() => _selectedCategory = null),
    );
  }
}

class AssessmentWidget extends StatefulWidget {
  final List<AssessmentQuestion> questions;
  final Function(AssessmentResult) onComplete;
  final VoidCallback onCancel;

  const AssessmentWidget({
    super.key,
    required this.questions,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<AssessmentWidget> createState() => _AssessmentWidgetState();
}

class _AssessmentWidgetState extends State<AssessmentWidget> {
  final Map<String, int> _answers = {};
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / widget.questions.length,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Question text
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: Text(
                        question.text,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          height: 1.4,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Answer options
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _answers[question.id] == index;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => setState(() => _answers[question.id] = index),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ] : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected 
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected 
                                            ? Colors.white
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected 
                                        ? const Icon(Icons.check, size: 18, color: Colors.black)
                                        : null,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isSelected ? Colors.white : null,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentQuestionIndex--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _answers[question.id] != null
                          ? (isLastQuestion ? _completeAssessment : () => setState(() => _currentQuestionIndex++))
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _answers[question.id] != null 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isLastQuestion ? 'Complete Assessment' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _completeAssessment() {
    final totalScore = widget.questions.fold<int>(0, (sum, question) {
      final answerIndex = _answers[question.id];
      return sum + (answerIndex != null ? question.scores[answerIndex] : 0);
    });
    
    final maxScore = widget.questions.fold<int>(0, (sum, question) => sum + question.scores.last);
    final category = widget.questions.first.category;
    
    final result = _calculateResult(category, totalScore, maxScore);
    
    // Show results dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AssessmentResultDialog(
        result: result,
        onClose: () {
          Navigator.of(context).pop();
          widget.onComplete(result);
        },
      ),
    );
  }

  AssessmentResult _calculateResult(String category, int totalScore, int maxScore) {
    final percentage = (totalScore / maxScore) * 100;
    String level;
    String description;
    List<String> recommendations;

    switch (category) {
      case 'depression':
        if (percentage < 20) {
          level = 'Low';
          description = 'You show minimal signs of depression. Keep up your positive habits!';
          recommendations = [
            'Continue maintaining healthy routines',
            'Stay connected with supportive people',
            'Engage in activities you enjoy'
          ];
        } else if (percentage < 40) {
          level = 'Mild';
          description = 'You may be experiencing mild depressive symptoms. Consider self-care strategies.';
          recommendations = [
            'Practice regular exercise',
            'Maintain a consistent sleep schedule',
            'Consider talking to a trusted friend or family member'
          ];
        } else if (percentage < 60) {
          level = 'Moderate';
          description = 'You are showing moderate signs of depression. Professional support may be helpful.';
          recommendations = [
            'Consider speaking with a mental health professional',
            'Practice mindfulness and relaxation techniques',
            'Maintain social connections'
          ];
        } else if (percentage < 80) {
          level = 'High';
          description = 'You are experiencing significant depressive symptoms. Professional help is recommended.';
          recommendations = [
            'Seek professional mental health support',
            'Consider therapy or counseling',
            'Reach out to a healthcare provider'
          ];
        } else {
          level = 'Severe';
          description = 'You are experiencing severe depressive symptoms. Please seek immediate professional help.';
          recommendations = [
            'Contact a mental health professional immediately',
            'Consider crisis support services',
            'Reach out to your healthcare provider or emergency services if needed'
          ];
        }
        break;
      case 'stress':
        if (percentage < 20) {
          level = 'Low';
          description = 'You have low stress levels. Great job managing your stress!';
          recommendations = [
            'Continue your current stress management strategies',
            'Maintain work-life balance',
            'Keep practicing relaxation techniques'
          ];
        } else if (percentage < 40) {
          level = 'Mild';
          description = 'You have mild stress levels. Some stress management techniques may be helpful.';
          recommendations = [
            'Practice deep breathing exercises',
            'Take regular breaks during work',
            'Engage in physical activity'
          ];
        } else if (percentage < 60) {
          level = 'Moderate';
          description = 'You are experiencing moderate stress. Consider implementing stress reduction strategies.';
          recommendations = [
            'Practice mindfulness meditation',
            'Improve time management skills',
            'Consider reducing your workload'
          ];
        } else if (percentage < 80) {
          level = 'High';
          description = 'You have high stress levels. Professional support may be beneficial.';
          recommendations = [
            'Consider stress management counseling',
            'Practice regular relaxation techniques',
            'Evaluate and adjust your commitments'
          ];
        } else {
          level = 'Severe';
          description = 'You are experiencing severe stress. Please seek professional help.';
          recommendations = [
            'Contact a mental health professional',
            'Consider taking time off if possible',
            'Implement immediate stress reduction strategies'
          ];
        }
        break;
      case 'happiness':
        if (percentage >= 80) {
          level = 'Very High';
          description = 'You have very high happiness levels! You\'re doing great!';
          recommendations = [
            'Continue your positive practices',
            'Share your happiness with others',
            'Help others find their joy'
          ];
        } else if (percentage >= 60) {
          level = 'High';
          description = 'You have high happiness levels. Keep up the great work!';
          recommendations = [
            'Maintain your current positive habits',
            'Continue engaging in meaningful activities',
            'Share your positive energy'
          ];
        } else if (percentage >= 40) {
          level = 'Moderate';
          description = 'You have moderate happiness levels. There\'s room for improvement.';
          recommendations = [
            'Practice gratitude daily',
            'Engage in activities you enjoy',
            'Spend time with positive people'
          ];
        } else if (percentage >= 20) {
          level = 'Low';
          description = 'You have low happiness levels. Consider strategies to improve your well-being.';
          recommendations = [
            'Seek professional support if needed',
            'Practice self-care regularly',
            'Connect with supportive people'
          ];
        } else {
          level = 'Very Low';
          description = 'You have very low happiness levels. Please consider seeking professional help.';
          recommendations = [
            'Contact a mental health professional',
            'Reach out to trusted friends or family',
            'Consider therapy or counseling'
          ];
        }
        break;
      default:
        level = 'Unknown';
        description = 'Assessment completed.';
        recommendations = [];
    }

    return AssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      totalScore: totalScore,
      maxScore: maxScore,
      level: level,
      description: description,
      recommendations: recommendations,
      completedAt: DateTime.now(),
    );
  }
}

class AssessmentResultDialog extends StatelessWidget {
  final AssessmentResult result;
  final VoidCallback onClose;

  const AssessmentResultDialog({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(result.category);
    final emoji = _getMoodEmoji(result.category, result.percentage);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(result.category),
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.category.toUpperCase()} Assessment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completed Successfully',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Score and Level
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.level,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.totalScore}/${result.maxScore} (${result.percentage.toStringAsFixed(0)}%)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Description
            Text(
              result.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Recommendations
            if (result.recommendations.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommendations:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...result.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        rec,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
            ],
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'depression': return Colors.blue;
      case 'stress': return Colors.orange;
      case 'happiness': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'depression': return Icons.sentiment_dissatisfied;
      case 'stress': return Icons.psychology;
      case 'happiness': return Icons.sentiment_very_satisfied;
      default: return Icons.assessment;
    }
  }

  String _getMoodEmoji(String category, double percentage) {
    switch (category) {
      case 'depression':
        if (percentage < 20) return '😊';
        if (percentage < 40) return '😐';
        if (percentage < 60) return '😔';
        if (percentage < 80) return '😞';
        return '😢';
      case 'stress':
        if (percentage < 20) return '😌';
        if (percentage < 40) return '😐';
        if (percentage < 60) return '😰';
        if (percentage < 80) return '😫';
        return '😵';
      case 'happiness':
        if (percentage >= 80) return '😄';
        if (percentage >= 60) return '😊';
        if (percentage >= 40) return '🙂';
        if (percentage >= 20) return '😐';
        return '😔';
      default:
        return '😐';
    }
  }
}
