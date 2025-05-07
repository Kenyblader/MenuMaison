import 'package:flutter/material.dart';
import 'dart:async';

class GeminiProcessingAnimation extends StatefulWidget {
  final Future<dynamic> future;
  final Function(dynamic) onCompleted;
  final Function(dynamic) onError;
  final String title;

  const GeminiProcessingAnimation({
    Key? key,
    required this.future,
    required this.onCompleted,
    required this.onError,
    this.title = "Traitement en cours",
  }) : super(key: key);

  @override
  State<GeminiProcessingAnimation> createState() =>
      _GeminiProcessingAnimationState();
}

class _GeminiProcessingAnimationState extends State<GeminiProcessingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Étapes du traitement
  final List<ProcessingStep> _steps = [
    ProcessingStep(
      message: "Analyse de votre demande",
      icon: Icons.add_moderator,
      color: Colors.blue,
    ),
    ProcessingStep(
      message: "Recherche d'informations",
      icon: Icons.search,
      color: Colors.green,
    ),
    ProcessingStep(
      message: "Traitement des données",
      icon: Icons.data_usage,
      color: Colors.orange,
    ),
    ProcessingStep(
      message: "Formulation de la réponse",
      icon: Icons.text_format,
      color: Colors.purple,
    ),
    ProcessingStep(
      message: "Vérification finale",
      icon: Icons.check_circle,
      color: Colors.teal,
    ),
  ];

  int _currentStepIndex = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation pour la barre de progression
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 12,
      ), // Durée totale pour toutes les étapes
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController);

    _progressController.forward();

    // Timer pour changer d'étape toutes les 2 secondes
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStepIndex < _steps.length - 1 && !_isCompleted) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    // Écouteur pour la future
    widget.future
        .then((result) {
          setState(() {
            _isCompleted = true;
          });

          // Finaliser l'animation avec un court délai
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onCompleted(result);
            }
          });
        })
        .catchError((error) {
          widget.onError(error);
        });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Animation du personnage IA
          _buildAnimatedAiCharacter(),

          const SizedBox(height: 30),

          // Étapes de traitement
          SizedBox(
            height: 260,
            child: ListView.builder(
              itemCount: _steps.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final bool isCurrentStep = index == _currentStepIndex;
                final bool isPreviousStep = index < _currentStepIndex;

                return AnimatedOpacity(
                  opacity: index <= _currentStepIndex ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _steps[index].color.withOpacity(
                          isPreviousStep ? 0.2 : 1.0,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child:
                            isPreviousStep
                                ? const Icon(Icons.check, color: Colors.green)
                                : Icon(
                                  _steps[index].icon,
                                  color:
                                      isCurrentStep
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                ),
                      ),
                    ),
                    title: Text(
                      _steps[index].message,
                      style: TextStyle(
                        fontWeight:
                            isCurrentStep ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isCurrentStep && !_isCompleted
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            )
                            : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Barre de progression générale
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCompleted
                        ? "Terminé !"
                        : "${(_progressAnimation.value * 100).toInt()}% complété",
                    style: TextStyle(
                      color: _isCompleted ? Colors.green : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAiCharacter() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade100,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle pulsant
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.1),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100 * value,
                height: 100 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _isCompleted
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                ),
              );
            },
            child: const SizedBox(),
          ),

          // Icône AI
          Icon(
            _isCompleted ? Icons.check_circle : Icons.auto_awesome,
            size: 60,
            color: _isCompleted ? Colors.green : Colors.blue,
          ),

          // Petites particules qui tournent
          if (!_isCompleted)
            ...List.generate(8, (index) {
              final angle = index * 45.0;
              return AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle:
                        (_progressController.value * 2 * 3.14) +
                        (angle * 3.14 / 180),
                    child: Transform.translate(
                      offset: Offset(0, -55),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}

// Classe pour représenter une étape du traitement
class ProcessingStep {
  final String message;
  final IconData icon;
  final Color color;

  ProcessingStep({
    required this.message,
    required this.icon,
    required this.color,
  });
}
