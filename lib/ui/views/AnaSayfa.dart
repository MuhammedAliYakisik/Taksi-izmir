import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:izmir_taksi/data/model/Taksi.dart';
import 'package:izmir_taksi/ui/cubit/AnaSayfa_cubit.dart';
import 'package:izmir_taksi/ui/views/SearchPage.dart';
import 'package:izmir_taksi/ui/views/SettingsPage.dart';
import 'package:izmir_taksi/utils/color.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  bool _isLoading = false;

  Future<void> _changeloading() async {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    _fetchTaksi();
  }

  Future<void> _fetchTaksi() async {
    await _changeloading();
    await context.read<AnasayfaCubit>().fetchtaksi();
    await _changeloading();

  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var oran = MediaQuery.of(context);
    var genislik = oran.size.width;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(
          "~ Bey Taksi ~",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: genislik / 15,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: EdgeInsets.only(left: genislik / 35),
          child: Image.asset("assets/taxi.png"),
        ),
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Home",
        labels: const ["Home", "Search", "Settings"],
        icons: const [Icons.home, Icons.search, Icons.settings],
        badges: null,
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: yellow2,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: yellow,
        tabIconSelectedColor: Colors.black,
        tabBarColor: Colors.black,
        onTabItemSelected: (int value) {
          setState(() {
            _motionTabBarController!.index = value;
          });
        },
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _motionTabBarController,
        children: <Widget>[
          BlocBuilder<AnasayfaCubit, List<Taksi>>(
            builder: (context, taksilist) {
              print("taksi: $taksilist");
              if (_isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(
                        color: Colors.yellow,
                        size: 50.0,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Veriler Yükleniyor...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              } else if(taksilist.isNotEmpty){
                return ListView.builder(
                  itemCount: taksilist.length,
                  itemBuilder: (context, indeks) {
                    var taksi = taksilist[indeks];
                    return Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text( "${taksi.title?? 'boş title'}",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }else {
                return Center(
                  child: Text(
                    "Veriler yüklenemedi.",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              }
            },
          ),



          const Searchpage(),
          const Settingspage(),
        ],
      ),
    );
  }
}
