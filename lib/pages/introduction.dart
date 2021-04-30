import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';


class IntroducitonPage extends StatefulWidget {
  IntroducitonPage({Key key}) : super(key: key);

  @override
  _IntroducitonPage createState() => _IntroducitonPage();
}

class _IntroducitonPage extends State<IntroducitonPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/images/testVideo.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      body: SafeArea(
        child: ListView( 
          children: [
            Center(
              child: _controller.value.initialized
                ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    FlatButton(
                      child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Container(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: !_controller.value.isPlaying 
                          ? Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          )
                          : Container()
                        ),
                      ), 
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      }
                    ),
                  ]
                )
                : Center(child: CircularProgressIndicator())
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis, elit sed tincidunt imperdiet, dolor nisl tempor lorem, vel vehicula magna quam vitae leo. Vestibulum euismod, enim a sagittis mattis, eros tortor congue eros, at consequat arcu velit eget nulla. Quisque condimentum sem et neque tempor convallis. Nulla egestas pellentesque consequat. Curabitur sed molestie erat. Integer at nunc aliquet, luctus ex id, mattis dolor. Quisque blandit tellus vitae nisi fringilla consequat. Donec finibus pulvinar turpis vitae semper. In rutrum id odio in pellentesque. Fusce blandit est a dolor vestibulum, vel consequat libero dapibus. Sed pulvinar eros non libero consectetur, nec molestie odio dignissim. Nullam et nisl orci. Phasellus ac viverra libero. Curabitur ultrices dolor sed elit placerat, nec aliquam lectus sagittis. Morbi eu tincidunt diam, eu congue est. Proin volutpat nec justo quis volutpat. Cras volutpat turpis non mi eleifend pretium. In condimentum, lacus nec aliquet malesuada, lacus sem feugiat."
              )
            ),
            RaisedButton(
              child: Text("Continue"),
              onPressed: () {
                context.read<User>().watchIntro();
                Navigator.of(context).popUntil(ModalRoute.withName("/"));
              }
            )
          ]
        )
      ),
    );
  }
}