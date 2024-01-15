import 'package:flutter/material.dart';

import 'chat.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> customListTiles = [
      _item(
        'Minería',
        'Chatbot especializado en minería',
        'pickaxe',
        const ChatView(), // 'mining-db' 
      ),
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('AInstein'),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.93,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(
                        height: 10,
                      ),
                  itemCount: customListTiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return customListTiles[index];
                  }),
            ),
          ),
        ));
  }

  Widget _item(String title, String subtitle, String icon, Widget nextPage) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Image.asset('assets/$icon.png', height: 25),
      ),
    );
  }
}
