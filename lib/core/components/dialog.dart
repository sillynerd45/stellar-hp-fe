import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stellar_hp_fe/core/core.dart';

class MediDialog {
  MediDialog._();

  static Future<bool?> aiFailureDialog(
    BuildContext context, {
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) => LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double sizeToUse = maxWidth < maxHeight ? maxWidth : maxHeight;
        double adjustedLogoWidth = sizeToUse >= appMaxScreenWidth ? appMaxScreenWidth : sizeToUse;
        return AlertDialog(
          elevation: 4,
          insetPadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.25, 0.4, 0.5, 0.6, 0.75],
                colors: aiFailureGradients,
              ),
            ),
            width: adjustedLogoWidth - 100,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(builder: (_, constraints) {
                      return Image.asset(
                        key: aiWarningKey,
                        imgAiWarning,
                        width: constraints.maxWidth - 128,
                        fit: BoxFit.fitWidth,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.high,
                      );
                    }),
                  ),
                  LayoutBuilder(builder: (_, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8, bottom: 24),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text(
                        message ?? 'AI unable to answer for now',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: context.style.titleMedium?.copyWith(
                          color: orangeWarningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                  LayoutBuilder(builder: (_, constraints) {
                    return Container(
                      height: 56,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(orangeWarningColor),
                          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                          side: WidgetStateProperty.all(const BorderSide(color: orangeWarningColor)),
                          fixedSize: WidgetStateProperty.all<Size?>(const Size(100, 56)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'OK',
                          style: context.style.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  static Future<bool?> loading(
    BuildContext context, {
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) => LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double sizeToUse = maxWidth < maxHeight ? maxWidth : maxHeight;
        double adjustedLogoWidth = sizeToUse >= appMaxScreenWidth ? appMaxScreenWidth : sizeToUse;
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            // didPop wil return true in the case of popUntil, pushAndRemoveUntil, and etc
            if (didPop) return;
          },
          child: AlertDialog(
            elevation: 4,
            insetPadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.all(4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            backgroundColor: Colors.white,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.25, 0.4, 0.5, 0.6, 0.75],
                  colors: aiProcessingGradients,
                ),
              ),
              width: adjustedLogoWidth - 100,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(builder: (_, constraints) {
                        String lottieAsset = lottieStellarOrbs;
                        return Lottie.asset(
                          lottieAsset,
                          width: constraints.maxWidth - 16,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.high,
                          frameRate: FrameRate.max,
                        );
                      }),
                    ),
                    LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      return Container(
                        width: constraints.maxWidth,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(126, 125, 211, 0.7),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        child: Text(
                          message ?? 'please wait',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: context.style.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
