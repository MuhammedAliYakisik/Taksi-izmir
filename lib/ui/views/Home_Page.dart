import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:izmir_taksi/data/model/Taksi.dart';
import 'package:izmir_taksi/ui/cubit/Homepage_Cubit.dart';
import 'package:izmir_taksi/ui/views/Taxi_Page.dart';
import 'package:izmir_taksi/ui/views/Search_Page.dart';
import 'package:izmir_taksi/ui/views/Settings_Page.dart';
import 'package:izmir_taksi/utils/Color_Page.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late final _motionTabBarController;
  bool _isLoading = false;
  bool _isSearching  = false;
  String _searchQuery  = "";

  Future<void> _changeloading() async {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> search() async {
    setState(() {
      _isSearching  = !_isSearching ;
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
    await context.read<Homepagecubit>().fetchtaksi();
    await _changeloading();
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = "";
        context.read<Homepagecubit>().fetchtaksi();
      }
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<Homepagecubit>().fetchsearch(query);
  }

  @override
  Widget build(BuildContext context) {
    var oran = MediaQuery.of(context);
    var genislik = oran.size.width;
    var uzunluk = oran.size.height;

    return Scaffold(
      backgroundColor: CustomColors.white.color,
      appBar: CustomAppBar(
        isSearching: _isSearching ,
        onSearchToggle: _toggleSearch,
        onSearchQueryChanged: _updateSearchQuery,
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _motionTabBarController,
        children: <Widget>[
          BlocBuilder<Homepagecubit, AnasayfaState>(
            builder: (context, state) {
              if (state is TaksiLoading) {
                return _buildLoadingIndicator();
              } else if (state is TaksiLoaded) {
                var allContents = state.taksi.data!
                    .expand((data) => data.subCategories ?? [])
                    .expand((subCategory) => subCategory.contents ?? [])
                    .toList();
                return ListView.builder(
                  itemCount: allContents.length,
                  itemBuilder: (context, index) {
                    var data = allContents[index];
                    return Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${data.title ?? 'boş title'}",
                                  style: GoogleFonts.rubik(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: genislik / 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: FaIcon(FontAwesomeIcons.locationDot)),
                                Gap(genislik / 100),
                                Expanded(
                                  child: Text(
                                    "${data.address ?? 'boş title'}",
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: genislik / 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Taxipage(data.location.lat,data.location.lon,data.title)));
                                    },
                                    icon: FaIcon(FontAwesomeIcons.mapLocationDot)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is SearchResultsLoaded) {
                return ListView.builder(
                  itemCount: state.searchResults.length,
                  itemBuilder: (context, index) {
                    var data = state.searchResults[index];
                    return SingleChildScrollView(
                      child: Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: uzunluk / 6,
                            child: Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${data ?? 'boş title'}",
                                      style: GoogleFonts.rubik(
                                        color: CustomColors.blue.color,
                                        fontSize: genislik / 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: FaIcon(FontAwesomeIcons.locationDot)),
                                    Gap(genislik / 100),
                                    Expanded(
                                      child: Text(
                                        "${data ?? 'boş title'}",
                                        style: TextStyle(
                                          color: CustomColors.blue.color,
                                          fontSize: genislik / 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Searchpage(37.8667,32.5,""),));

                                        },
                                        icon: FaIcon(FontAwesomeIcons.mapLocationDot)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is TaksiError) {
                return _buildErrorWidget("Hata: ${state.message}");
              } else {
                return _buildErrorWidget("Veriler Yüklenmedi");
              }
            },
          ),
          Searchpage(37.8667,32.5,""),
          const Settingspage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        controller: _motionTabBarController,
        onTabSelected: (index){
          setState(() {
            _motionTabBarController.index = index;
          });
        }
      )
    );
  }
  Widget _buildLoadingIndicator() {
    var oran = MediaQuery.of(context);
    var uzunluk = oran.size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Colors.yellow,
            size: 50.0,
          ),
          SizedBox(height: uzunluk / 30),
          Text(
            'Veriler Yükleniyor...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(child: Text("Hata: $message"));
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final Function(String) onSearchQueryChanged;

  const CustomAppBar({
    Key? key,
    required this.isSearching,
    required this.onSearchToggle,
    required this.onSearchQueryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? _buildSearchField()
          : Text(
        "~ Konya Taksi ~",
        style: GoogleFonts.baskervville(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.width / 15,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : FontAwesomeIcons.magnifyingGlassLocation, color: Colors.black),
          onPressed: onSearchToggle,
        ),
      ],
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 35),
        child: Image.asset("assets/taxi.png"),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: "Arama için birşey giriniz",
        hintStyle: TextStyle(color: Colors.black),
        icon: Icon(FontAwesomeIcons.taxi, color: Colors.black),
      ),
      onChanged: onSearchQueryChanged,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class CustomBottomNavigation extends StatelessWidget {
  final MotionTabBarController controller;
  final Function(int) onTabSelected;

  const CustomBottomNavigation({
    Key? key,
    required this.controller,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      controller: controller,
      initialSelectedTab: "Ana Sayfa",
      labels: const ["Ana Sayfa", "Harita", "Ayarlar"],
      icons: const [Icons.home, Icons.map_outlined, Icons.settings],
      tabSize: 50,
      tabBarHeight: 55,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      tabIconColor: CustomColors.yellow2.color,
      tabIconSize: 28.0,
      tabIconSelectedSize: 26.0,
      tabSelectedColor: CustomColors.yellow.color,
      tabIconSelectedColor: Colors.black,
      tabBarColor: Colors.black,
      onTabItemSelected: onTabSelected,
    );
  }
}
