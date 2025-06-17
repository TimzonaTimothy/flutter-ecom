import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import '../../base/res/styles/app_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        title: Container(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Location", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppStyles.primaryColor,
                  ),
                  Text(
                    "Please select a location",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppStyles.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppStyles.whiteSmokeColor),
              child: Icon(
                Icons.notifications,
                color: AppStyles.textColor,
              )),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      backgroundColor: AppStyles.bgColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppStyles.whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(width: 1, color: AppStyles.whiteColor)),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.search,
                        color: AppStyles.whiteSmokeColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Search',
                        style: AppStyles.textStyle
                            .copyWith(color: AppStyles.whiteSmokeColor),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: AppStyles.textColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  FluentSystemIcons.ic_fluent_filter_filled,
                  color: AppStyles.whiteColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
