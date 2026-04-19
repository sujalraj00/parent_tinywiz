import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double? width;

  const NextButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: isEnabled
          ? SizedBox(
              height: 56,
              width: width ?? double.infinity,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF101010), Color(0xFFFFFFFF)],
                        ),
                        border: Border.all(
                          style: BorderStyle.solid,
                          color: Color(0xFF999999),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const RadialGradient(
                            radius: 7,
                            colors: [
                              Color(0xFF999999),
                              Color(0xFF222222),
                              Color(0xFF999999),
                            ],
                            tileMode: TileMode.clamp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Opacity(
              opacity: 0.3,
              child: SizedBox(
                height: 56,
                width: width ?? double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF101010), Color(0xFFFFFFFF)],
                    ),
                    border: Border.all(
                      style: BorderStyle.solid,
                      color: Color(0xFF999999),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const RadialGradient(
                        radius: 7,
                        colors: [
                          Color(0xFF999999),
                          Color(0xFF222222),
                          Color(0xFF999999),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/icons/next.png',
                            width: 14,
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
