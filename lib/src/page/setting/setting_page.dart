import 'package:church/src/page/setting/setting_page_viewmodel.dart';
import 'package:church/src/theme/theme_primary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = 'settingpage';

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  SettingPageViewModel viewModel = SettingPageViewModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar() {
      return AppBar(
        title: Text(viewModel.titleAppbar),
        leading: IconButton(
          onPressed: (){
            viewModel.onPushBackButtonClick();
          },
          icon: Icon(Icons.arrow_back, color: ThemePrimary.textPrimaryWhite,),
        ),
      );
    }

    Widget body() {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(15),
//        width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bán kính: ${viewModel.radiusSliderValue.toInt()} km',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      label: viewModel.radiusSliderValue.toString(),
                      value: viewModel.radiusSliderValue,
                      onChanged: (value) {
                        viewModel.onRadiusSliderValueChange(value);
                      },
                      min: 0,
                      max: 10,
                    ),
                    Divider(),
                    Text(
                      'Thời gian thông báo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Text('15p'),
                              Checkbox(
                                onChanged: (value) {
                                  
                                },
                                value: true,
                              ),
                              Divider(),
                              Checkbox(
                                onChanged: (value) {
                                  
                                },
                                value: false,
                              ),
                              Text('45p'),
                              Checkbox(
                                onChanged: (value) {
                                  
                                },
                                value: false,
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => SettingPageViewModel(),
      child: Consumer<SettingPageViewModel>(
        builder: (context, model, child) {
          viewModel = model;
          viewModel.context = context;
          return Scaffold(
            backgroundColor: ThemePrimary.backgroundColor,
            appBar: appBar(),
            body: body(),
          );
        },
      ),
    );
  }
}
