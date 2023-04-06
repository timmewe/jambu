import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambu/onboarding/bloc/onboarding_bloc.dart';
import 'package:jambu/onboarding/widgets/widgets.dart';

const _transitionDuration = Duration(milliseconds: 300);
const _transitionCurve = Curves.fastOutSlowIn;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        OnboardingContainer(
                          child: RegularAttendancesOnboarding(
                            weekdays: state.regularWeekdays,
                            onDayTap: (weekdays) {
                              context.read<OnboardingBloc>().add(
                                    OnboardingUpdateAttendances(
                                      weekdays: weekdays,
                                    ),
                                  );
                            },
                            onConfirmTap: () => _pageController.nextPage(
                              duration: _transitionDuration,
                              curve: _transitionCurve,
                            ),
                          ),
                        ),
                        OnboardingContainer(
                          child: NotificationsOnboarding(
                            onConfirmTap: () {},
                            onDeclineTap: () {
                              context
                                  .read<OnboardingBloc>()
                                  .add(OnboardingCompleted());
                            },
                            onBackTap: () {
                              _pageController.previousPage(
                                duration: _transitionDuration,
                                curve: _transitionCurve,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}