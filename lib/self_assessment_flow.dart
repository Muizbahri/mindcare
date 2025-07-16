import 'package:flutter/material.dart';

class SelfAssessmentFlow extends StatefulWidget {
  const SelfAssessmentFlow({Key? key}) : super(key: key);

  @override
  State<SelfAssessmentFlow> createState() => _SelfAssessmentFlowState();
}

class _SelfAssessmentFlowState extends State<SelfAssessmentFlow> {
  // PHQ-9 and GAD-7 questions
  final List<String> phq9Questions = [
    'Little interest or pleasure in doing things',
    'Feeling down, depressed, or hopeless',
    'Trouble falling or staying asleep, or sleeping too much',
    'Feeling tired or having little energy',
    'Poor appetite or overeating',
    'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
    'Trouble concentrating on things, such as reading the newspaper or watching television',
    'Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
    'Thoughts that you would be better off dead, or of hurting yourself',
  ];
  final List<String> gad7Questions = [
    'Feeling nervous, anxious, or on edge',
    'Not being able to stop or control worrying',
    'Worrying too much about different things',
    'Trouble relaxing',
    'Being so restless that it is hard to sit still',
    'Becoming easily annoyed or irritable',
    'Feeling afraid as if something awful might happen',
  ];
  final List<String> options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  // State
  int step = 0; // 0: intro, 1-9: PHQ-9, 10-16: GAD-7, 17: results
  List<int?> phq9Answers = List.filled(9, null);
  List<int?> gad7Answers = List.filled(7, null);

  void next() {
    setState(() {
      if (step < 16) {
        step++;
      } else {
        step = 17;
      }
    });
  }

  void previous() {
    setState(() {
      if (step > 0) step--;
    });
  }

  void restart() {
    setState(() {
      step = 0;
      phq9Answers = List.filled(9, null);
      gad7Answers = List.filled(7, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FAFF),
        appBar: step == 0
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  step <= 9
                      ? 'PHQ-9 Assessment'
                      : step <= 16
                          ? 'GAD-7 Assessment'
                          : step == 17
                              ? 'Assessment Results'
                              : '',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
              ),
        body: Center(
          child: SingleChildScrollView(
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (step == 0) return _buildIntro();
    if (step >= 1 && step <= 9) {
      return _buildQuestion(
        title: 'PHQ-9 Assessment',
        subtitle: 'Question $step of 9',
        question: phq9Questions[step - 1],
        answer: phq9Answers[step - 1],
        onChanged: (v) => setState(() => phq9Answers[step - 1] = v),
        progress: step / 9,
        onNext: phq9Answers[step - 1] != null ? next : null,
        onPrevious: step > 1 ? previous : null,
        isLast: step == 9,
      );
    }
    if (step >= 10 && step <= 16) {
      int idx = step - 10;
      return _buildQuestion(
        title: 'GAD-7 Assessment',
        subtitle: 'Question ${idx + 1} of 7',
        question: gad7Questions[idx],
        answer: gad7Answers[idx],
        onChanged: (v) => setState(() => gad7Answers[idx] = v),
        progress: (idx + 1) / 7,
        onNext: gad7Answers[idx] != null ? next : null,
        onPrevious: previous,
        isLast: step == 16,
        isGad: true,
      );
    }
    if (step == 17) return _buildResults();
    return const SizedBox();
  }

  Widget _buildIntro() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mental Health Assessment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: 480,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.psychology, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Self-Assessment Tools',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About these assessments:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('• PHQ-9: Screens for depression symptoms',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)),
                          Text('• GAD-7: Screens for anxiety symptoms',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)),
                          Text('• Takes about 5-10 minutes to complete',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)),
                          Text('• Results are private and stored locally',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => setState(() => step = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 480,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFACC15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E42)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'This assessment is for informational purposes only and does not replace professional medical advice. If you\'re experiencing a mental health crisis, please seek immediate help.',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuestion({
    required String title,
    required String subtitle,
    required String question,
    required int? answer,
    required void Function(int) onChanged,
    required double progress,
    required VoidCallback? onNext,
    VoidCallback? onPrevious,
    bool isLast = false,
    bool isGad = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      isGad ? 'GAD-7' : 'PHQ-9',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE0E7FF),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 480,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(options.length, (i) {
                      return RadioListTile<int>(
                        value: i,
                        groupValue: answer,
                        onChanged: (v) => onChanged(v!),
                        title: Text(
                          options[i],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        activeColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onPrevious != null)
                    OutlinedButton(
                      onPressed: onPrevious,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onNext != null
                              ? (isLast && isGad
                                  ? const LinearGradient(
                                            colors: [
                                              Color(0xFF3B82F6),
                                              Color(0xFF10B981)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(const Rect.fromLTWH(
                                              0, 0, 200, 50)) !=
                                          null
                                      ? null
                                      : const Color(0xFF3B82F6)
                                  : const LinearGradient(
                                            colors: [
                                              Color(0xFF8B5CF6),
                                              Color(0xFF3B82F6)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(const Rect.fromLTWH(
                                              0, 0, 200, 50)) !=
                                          null
                                      ? null
                                      : const Color(0xFF8B5CF6))
                              : const Color(0xFFD1D5DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isLast
                              ? (isGad
                                  ? 'Continue to Results'
                                  : 'Continue to GAD-7')
                              : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildResults() {
    int phq9Score = phq9Answers.fold(0, (a, b) => a + (b ?? 0));
    int gad7Score = gad7Answers.fold(0, (a, b) => a + (b ?? 0));
    String phq9Level = _phq9Level(phq9Score);
    String gad7Level = _gad7Level(gad7Score);
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 480,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF22C55E), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Assessment Complete',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              _ScoreCard(
                title: 'Depression Screening (PHQ-9)',
                score: phq9Score,
                maxScore: 27,
                level: phq9Level,
                color: const Color(0xFFFFEDD5),
                textColor: const Color(0xFFB45309),
              ),
              const SizedBox(height: 16),
              _ScoreCard(
                title: 'Anxiety Screening (GAD-7)',
                score: gad7Score,
                maxScore: 21,
                level: gad7Level,
                color: const Color(0xFFE0E7FF),
                textColor: const Color(0xFF3730A3),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                        '• Consider speaking with a mental health professional',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                    Text('• Practice self-care activities regularly',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                    Text('• Stay connected with supportive friends and family',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                    Text('• Consider our calming music and reading resources',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                                const Rect.fromLTWH(0, 0, 200, 50)) !=
                            null
                        ? null
                        : const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Take Assessment Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _phq9Level(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  String _gad7Level(int score) {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    return 'Severe';
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final int maxScore;
  final String level;
  final Color color;
  final Color textColor;
  const _ScoreCard({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.level,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Score:',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
              const Text('Level:',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score}/$maxScore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(height: 0),
              Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
