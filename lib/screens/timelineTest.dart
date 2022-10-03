import 'package:euro_mobile/classes/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';



class DeliveryTimeline extends StatelessWidget {
  late final List<String> timeList;
  late String inv_type;
  late int lastTimestmp;
  late int currentStep;
  late ScrollController _scrollController;
  var deliverySteps;

    DeliveryTimeline ( {required this.timeList,required this.lastTimestmp, required this.inv_type})  {
         _scrollController = ScrollController();
          currentStep = lastTimestmp;


         if(inv_type!="1"){
           deliverySteps = [
             translate('chegada_obra'),
             translate('inicio_descarga'),
             translate('fim_descarga'),
             translate('saida_obra'),
           ];
         }else{
      deliverySteps = [
      translate('inicio_carga'),
      translate('saida_central'),
      translate('chegada_obra'),
      translate('inicio_descarga'),
      translate('saida_obra'),
      translate('chegada_central'),
      ];
         }
       }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 10),
      constraints: const BoxConstraints(maxHeight: 150),
      color: AppColors.transparent,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: deliverySteps.length,
        itemBuilder: (BuildContext context, int index) {
          final step = deliverySteps[index];
          var indicatorSize = 30.0;
          var beforeLineStyle = LineStyle(
            color: Colors.white.withOpacity(0.8),
          );

          _DeliveryStatus status;
          LineStyle? afterLineStyle;
          if (index < currentStep) {
            status = _DeliveryStatus.done;
          } else if (index > currentStep) {
            status = _DeliveryStatus.todo;
            indicatorSize = 20;
            beforeLineStyle = const LineStyle(color: Color(0xFF747888));
          } else {
            afterLineStyle = const LineStyle(color: Color(0xFF747888));
            status = _DeliveryStatus.doing;
          }

          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.6,
            isFirst: index == 0,
            isLast: index == deliverySteps.length - 1,
            beforeLineStyle: beforeLineStyle,
            afterLineStyle: afterLineStyle,
            indicatorStyle: IndicatorStyle(
              width: indicatorSize,
              height: indicatorSize,
              indicator: _IndicatorDelivery(status: status),
            ),
            startChild: _StartChildDelivery(index: index,timeList: timeList),
            endChild: _EndChildDelivery(
              text: step,
              current: index == currentStep,
            ),
          );
        },
      ),
    );

  }

}


enum _DeliveryStatus { done, doing, todo }

class _StartChildDelivery extends StatelessWidget {
  const _StartChildDelivery({ required this.index,required this.timeList});
  final List<String> timeList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(timeList[index] ==null ? '': timeList[index],style: TextStyle(color: AppColors.textColorOnDarkBG),),
    );
  }
}

class _EndChildDelivery extends StatelessWidget {
  const _EndChildDelivery({
    required this.text,
    required this.current,
  });

  final String text;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sniglet(
                    fontSize: 16,
                    color: current ?  AppColors.buttonSecondaryColor : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorDelivery extends StatelessWidget {
  const _IndicatorDelivery({ required this.status});

  final _DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DeliveryStatus.done:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Color(0xFF5D6173)),
          ),
        );
      case _DeliveryStatus.doing:
        return Container(
          decoration:   BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.buttonSecondaryColor,//Color(0xFF2ACA8E),
          ),
          child: const Center(
            child: SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      case _DeliveryStatus.todo:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF747888),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5D6173),
              ),
            ),
          ),
        );
    }
  }
}