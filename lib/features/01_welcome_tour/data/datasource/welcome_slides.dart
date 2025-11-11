import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/slide.dart';

final slidesProvider = Provider<List<Slide>>((ref) => [
      // COMPLEMENT
      Slide(
        title: 'The perfect complement for daily practice',
        textContent: Wrap(children: [
          Text.rich(TextSpan(
              text: 'mironline ',
              style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              children: <InlineSpan>[
                TextSpan(
                    text:
                        'is a platform that has been developed based on contexts, situations and interactions that will allow you to  make the most of the system and technologies to practice the English language in a new way and beyond your textbook.',
                    style: TextStyle(
                        color: Colors.purple[400],
                        fontSize: 18,
                        fontWeight: FontWeight.w300))
              ]))
        ]),
        assetUrl: 'assets/animations/landing_hands_animation.riv',
      ),

      // FIELD OF STUDY
      Slide(
        title: 'English in your field of study*',
        textContent: Text.rich(TextSpan(
            text: 'mironline',
            style: const TextStyle(
                color: Colors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            children: <InlineSpan>[
              TextSpan(
                  text:
                      ' offers modules to develop English for the fields of Agriculture, Environment, Construction, Engineering, Computing, Electronics, Economics, Administration, Health Sciences, Humanities and Arts. Enjoy!',
                  style: TextStyle(
                      color: Colors.purple[400],
                      fontSize: 18,
                      fontWeight: FontWeight.w300))
            ])),
        assetUrl: 'assets/animations/landing_stars_animation.riv',
        note:
            '*ESP modules are only available for the Make it Real! Professional and Make it Real! English for Higher Education in Latin America book series',
      ),

      // INTEGRATED ACTIVITIES
      Slide(
        title: 'Integrated Skills Activities*',
        textContent: Text(
            style: TextStyle(
                color: Colors.purple[400],
                fontSize: 18,
                fontWeight: FontWeight.w300),
            'Improve your listening, writing and speaking skills through integrated activities that will be unlocked at the end of each General English unit.'),
        note: '*ISA activities are just available for the Go high! book series',
        assetUrl: 'assets/animations/landing_isa_animation.riv',
      ),

      // PRACTICING
      Slide(
        title: 'Practicing is fun',
        textContent: Wrap(children: [
          Text.rich(TextSpan(
              text:
                  'General English activities are organized by levels. You must unlock each level to progress to the next one. With ',
              style: TextStyle(
                  color: Colors.purple[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w300),
              children: <InlineSpan>[
                const TextSpan(
                    text: 'mironline',
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        ', practicing English is as fun as playing your favorite game on your phone, tablet or other device.',
                    style: TextStyle(
                        color: Colors.purple[400],
                        fontSize: 18,
                        fontWeight: FontWeight.w300))
              ]))
        ]),
        assetUrl: 'assets/animations/landing_stars_animation.riv',
      ),

      // PROGRESS
      Slide(
        title: 'Follow your progress',
        textContent: Wrap(children: [
          Text.rich(TextSpan(
              text: 'mironline ',
              style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              children: <InlineSpan>[
                TextSpan(
                    text:
                        'tracks your progress. You will be able to review your progress in skills, work and language activities. This will help you identify your strengths and areas for improvement.',
                    style: TextStyle(
                        color: Colors.purple[400],
                        fontSize: 18,
                        fontWeight: FontWeight.w300))
              ]))
        ]),
        assetUrl: '',
        // multimedia: const RadarChart()),
      )
    ]);
