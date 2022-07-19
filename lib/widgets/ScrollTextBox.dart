import 'package:flutter/material.dart';

class ScrollTextBox extends StatelessWidget {
  final List<String>? entries;
  final Function(int index)? tapEntry;
  const ScrollTextBox({Key? key, this.entries, this.tapEntry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      alignment: Alignment.center,
      child: entries != null
          ? ListView.builder(
              reverse: true,
              itemCount: entries!.length,
              itemBuilder: (context, index) {
                Color textColour = Color.fromARGB(200, 0, 0, 0);
                if (index == 1)
                  textColour = Color.fromARGB(100, 0, 0, 0);
                else if (index == 2)
                  textColour = Color.fromARGB(50, 0, 0, 0);
                else if (index > 2) textColour = Color.fromARGB(20, 0, 0, 0);

                return Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    child: InkWell(
                        onTap: () => {
                              if (tapEntry != null)
                                tapEntry!(entries!.length - index - 1)
                            },
                        child: Text(entries![entries!.length - index - 1],
                            style: TextStyle(
                              fontSize: 40,
                              color: textColour,
                            ))));
              },
            )
          : Container(),
    );
  }
}
