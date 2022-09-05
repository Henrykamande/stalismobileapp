import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Add Products',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    Navigator.pushNamed(context, '/searchproduct');
                  },
                  icon: const Icon(
                    Icons.widgets_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Add Payment',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    Navigator.pushNamed(context, '/paymentsearch');
                  },
                  icon: const Icon(
                    Icons.widgets_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ],
          ),
          /* Column(
            children: [
              Text(
                'Add Sourced',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: IconButton(
                  enableFeedback: false,
                  onPressed: _showoutsourcedPane,
                  icon: const Icon(
                    Icons.widgets_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ],
          ), */
        ],
      ),
    );
  }
}
