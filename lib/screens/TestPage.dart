import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'RecommandPage.dart';
import 'ResourcesPage.dart';
import 'finalmain_page.dart';

class RecommendedTestsPage extends StatefulWidget {
  final String userId;
  final int courseId;

  const RecommendedTestsPage({super.key, required this.userId, required this.courseId});

  @override
  _RecommendedTestsPageState createState() => _RecommendedTestsPageState();
}

class _RecommendedTestsPageState extends State<RecommendedTestsPage> {
  late Future<List<Test>> recommendedTests;
  Map<int, String> userAnswers = {};
  int score = 0;
  bool isTestSubmitted = false;
  String resultMessage = '';
  bool isSubmitting = false;
  final ApiService apiService = ApiService(); // Instance de ApiService

  @override
  void initState() {
    super.initState();
    recommendedTests = apiService.fetchRecommendedTests(widget.userId, widget.courseId);
  }

  void selectAnswer(int questionId, String answer) {
    setState(() {
      userAnswers[questionId] = answer;
    });
  }

  void submitTest(List<Test> tests) async {
    if (isSubmitting || isTestSubmitted) return;

    int correctAnswers = 0;
    int totalQuestions = tests.fold(0, (sum, t) => sum + t.questions.length);

    for (var test in tests) {
      for (var question in test.questions) {
        String? selected = userAnswers[question.numQuestion];
        if (selected != null) {
          bool isCorrect = question.choices.any(
                (choice) => choice.suggestionText == selected && choice.correct,
          );
          if (isCorrect) correctAnswers++;
        }
      }
    }

    setState(() {
      score = correctAnswers * 5;
      isTestSubmitted = true;
      resultMessage = correctAnswers >= 2
          ? 'You Passed the Test!'
          : 'You Failed the Test! Try Again';
    });

    String evaluation = correctAnswers < 2
        ? 'Needs Improvement'
        : correctAnswers == 2
        ? 'Good'
        : 'Excellent';

    String emoji = evaluation == 'Excellent'
        ? '🏅'
        : evaluation == 'Good'
        ? '⭐'
        : '😞';

    setState(() {
      isSubmitting = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Save result to DB en utilisant ApiService
      bool resultSaved = await apiService.saveTestResult(
        idUtilisateur: int.parse(widget.userId),
        idTest: widget.courseId,
        nbrPassage: score >= 10,
        valeurObtenue: score,
        evaluation: evaluation,
        datePassage: DateTime.now(),
      );

      if (mounted) Navigator.pop(context); // dismiss loading spinner

      if (resultSaved) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              '🎯 Test Result',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Feather',
                color: Color(0xFF323B60),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Correct Answers: $correctAnswers/$totalQuestions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6880BC),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$resultMessage $emoji',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: correctAnswers >= 2
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog

                  if (correctAnswers >= 2) {
                    // Send result to backend if needed here...

                    // Navigate to FinalMainPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinalMainPage(userId: widget.userId),
                      ),
                    );
                  }
                  else {
                    // Failed
                    if (correctAnswers >= 2) {
                      // Passed → Go to FinalMainPage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinalMainPage(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    } else {
                      // Calculer isRecommendationUnlocked comme dans LetterDetailPage
                      int coursePositionInLevel;
                      if (widget.courseId >= 1 && widget.courseId <= 26) {
                        coursePositionInLevel = widget.courseId;
                      } else if (widget.courseId >= 27 && widget.courseId <= 52) {
                        coursePositionInLevel = widget.courseId - 26;
                      } else if (widget.courseId >= 53 && widget.courseId <= 78) {
                        coursePositionInLevel = widget.courseId - 52;
                      } else {
                        coursePositionInLevel = 0;
                      }

                      bool isRecommendationUnlocked = coursePositionInLevel >= 6;

                      if (isRecommendationUnlocked) {
                        // Failed & Recommendations Unlocked → Go to RecommandPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommandPage(
                              userId: widget.userId,
                              courseId: widget.courseId,
                            ),
                          ),
                        );
                      } else {
                        // Failed & Recommendations Locked → Go to ResourcesPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResourcesPage(
                              userId: widget.userId,
                              courseId: widget.courseId,
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  correctAnswers >= 2 ? '🎉 OK' : '→ Learn More',
                  style: const TextStyle(
                    color: Color(0xFF323B60),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error saving test result')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error saving test result')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6880BC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF323B60), size: 30),
            ),
            const SizedBox(width: 17),
            const Text(
              'Test',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Feather',
                  color: Color(0xFF323B60)),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Test>>(
        future: recommendedTests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recommended tests available',style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Feather',
              color: Color(0xFF323B60),
            ),));
          }

          final tests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
            itemCount: tests.length + 1,
            itemBuilder: (context, index) {
              if (index < tests.length) {
                final test = tests[index];
                return buildTestCard(test);
              } else {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => submitTest(tests),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        backgroundColor: const Color(0xFF6880BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: Color(0xFF323B60), width: 2),
                        ),
                      ),
                      child: const Text(
                        'Submit Test',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget buildTestCard(Test test) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: Color(0xFF323B60), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: Color(0xFFFFA500), size: 40),
                const SizedBox(width: 12),
                Text(
                  test.nom_test,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF323B60)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...test.questions.map((q) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Q${q.numQuestion}: ${q.nomQuestion}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF323B60))),
                    const SizedBox(height: 4),
                    ...q.choices.map((choice) {
                      return RadioListTile<String>(
                        title: Text(choice.suggestionText),
                        value: choice.suggestionText,
                        groupValue: userAnswers[q.numQuestion],
                        onChanged: (val) => selectAnswer(q.numQuestion, val!),
                        activeColor: const Color(0xFFFFA500),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Models
class Test {
  final int id;
  final String nom_test;
  final int score_test;
  final String difficulte;
  final String etat_test;
  final List<QuestionDTO> questions;

  Test({
    required this.id,
    required this.nom_test,
    required this.score_test,
    required this.difficulte,
    required this.etat_test,
    required this.questions,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id_test'],
      nom_test: json['nom_test'],
      score_test: json['score_test'],
      difficulte: json['difficulte'],
      etat_test: json['etat_test'],
      questions: List<QuestionDTO>.from(json['questions'].map((q) => QuestionDTO.fromJson(q))),
    );
  }
}

class QuestionDTO {
  final int numQuestion;
  final String nomQuestion;
  final List<ChoiceDTO> choices;

  QuestionDTO({
    required this.numQuestion,
    required this.nomQuestion,
    required this.choices,
  });

  factory QuestionDTO.fromJson(Map<String, dynamic> json) {
    return QuestionDTO(
      numQuestion: json['numQuestion'],
      nomQuestion: json['nomQuestion'],
      choices: List<ChoiceDTO>.from(json['choices'].map((c) => ChoiceDTO.fromJson(c))),
    );
  }
}

class ChoiceDTO {
  final String suggestionText;
  final bool correct;

  ChoiceDTO({
    required this.suggestionText,
    required this.correct,
  });

  factory ChoiceDTO.fromJson(Map<String, dynamic> json) {
    return ChoiceDTO(
      suggestionText: json['suggestionText'],
      correct: json['correct'],
    );
  }
}