import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class ConsultationRequestList extends StatelessWidget {
  const ConsultationRequestList({
    super.key,
    required this.consultList,
  });

  final ValueNotifier<List<Consult>> consultList;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Consultation Request',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: context.style.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: consultList,
                builder: (context, content, _) {
                  if (content.isEmpty) {
                    return Container(
                      width: constraints.maxWidth,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(187, 187, 187, 0.3),
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              emptyListReport,
                              width: 250,
                              fit: BoxFit.fitWidth,
                              isAntiAlias: true,
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.high,
                            ),
                            Text(
                              'No request for now.',
                              textAlign: TextAlign.start,
                              style: context.style.titleMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: stellarHpGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: content.length,
                    itemBuilder: (BuildContext viewContext, int index) {
                      return DoctorConsultationDetails(
                        consultData: content[index],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
