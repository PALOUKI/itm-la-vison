import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/local_storage_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Suivi Académique Complet',
      description: "Gardez un œil attentif sur le parcours scolaire de vos enfants en temps réel. Accédez instantanément aux emplois du temps, aux programmes des cours et suivez l'évolution pédagogique jour après jour pour ne rien manquer de leur réussite.",
      image: AppConstants.onboardingImage1, // onBoarding.png
    ),
    OnboardingData(
      title: 'Communication & Réactivité',
      description: "Échangez en toute simplicité avec le corps enseignant et l'administration. Recevez des notifications immédiates pour les messages importants, les circulaires et les événements de la vie scolaire, garantissant une réactivité optimale.",
      image: AppConstants.onboardingImage2, // picture.png
    ),
    OnboardingData(
      title: 'Transparence & Sérénité',
      description: "Consultez en un clic les relevés de notes, les bulletins trimestriels ainsi que l'état de vos paiements. Notre plateforme centralise toutes les informations cruciales pour vous offrir une tranquillité d'esprit totale dans le suivi de vos enfants.",
      image: AppConstants.onboardingImage2, // picture.png encore
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(localStorageServiceProvider).setOnboardingCompleted(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Zone Image : Background Full
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Image.asset(
                  _pages[index].image,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Gradient supérieur pour la lisibilité
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Bouton Passer
          Positioned(
            top: 50.h,
            right: 20.w,
            child: TextButton(
              onPressed: _completeOnboarding,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
              child: Text(
                'Passer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 3. Conteneur style "Bottom Sheet" (Optimisé : Texte plus long & moins d'espace vide)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.48, // Augmenté légèrement pour accueillir plus de texte
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h), // Padding réduit pour serrer le contenu
              child: Column(
                children: [
                  // Indicateurs de page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  SizedBox(height: 24.h), // Espace réduit
                  
                  // Titre
                  Text(
                    _pages[_currentPage].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h), // Espace réduit
                  
                  // Description (Texte plus long et informatif)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        _pages[_currentPage].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey.shade600,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h), // Espace contrôlé avant le bouton
                  
                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    height: 58.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuart,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3a8a),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1e3a8a).withOpacity(0.4),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'COMMENCER' : 'SUIVANT',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 6.h,
      width: isSelected ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1e3a8a) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}
