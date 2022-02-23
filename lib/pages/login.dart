import 'package:personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.title});

  final String title;
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading;
  String _errorMessage;
  String _email;
  String _password;
  String _firstName;
  String _lastName;
  bool _showPassword;

  BuildContext context;
  
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _errorMessage = "";
    _email = "";
    _password = "";
    _showPassword = false;
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return Container(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          _errorMessage,
          key: Key("loginError"),
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        )
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget emailInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              //color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
        key: Key("loginEmail")
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: Icon(Icons.lock),
          suffix: IconButton(
            constraints: BoxConstraints(maxHeight: 38),
            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ) 
        ),  
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
        key: Key("loginPassword")
      ),
    );
  }

  Widget firstNameInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextFormField(
        maxLines: 1,
        decoration: InputDecoration(
          hintText: 'First Name',
          icon: Icon(Icons.account_circle),
        ),  
        validator: (value) => value.isEmpty ? 'Field can\'t be empty' : null,
        onSaved: (value) => _firstName = value.trim(),
        key: Key("loginFirstName")
      ),
    );
  }

  Widget lastNameInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextFormField(
        maxLines: 1,
        decoration: InputDecoration(
          hintText: 'Last Name',
          icon: Icon(Icons.account_circle),
        ),  
        validator: (value) => value.isEmpty ? 'Field can\'t be empty' : null,
        onSaved: (value) => _lastName = value.trim(),
        key: Key("loginLastName")
      ),
    );
  }

  Widget primaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: TextButton(
          key: Key("loginPrimaryButton"),
          child: new Text('signup', style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          onPressed: validateAndSubmit,
        ),
      )
    );
  }

  Widget loginForm() {
    List<Widget> items = <Widget>[
      //showLogo(),
      emailInput(),
      passwordInput(),
      firstNameInput(),
      lastNameInput(),
      showErrorMessage(),
      primaryButton(),
      //showSecondaryButton(),
    ];
    return Container(
      padding: EdgeInsets.all(16.0),
      child: new Form(
        key: _formKey,
        child: new ListView.builder(
          key: Key("loginScroll"),
          itemCount: items.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return items[index];
          },
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      body: Stack(
        children: [
          loginForm(),
          showCircularProgress()
        ],
      )
    );
  }

  void validateAndSubmit() async {
    FormState form = _formKey.currentState;
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    
    if (form.validate()) {
      form.save();
      try {
        context.read<User>().signup(_email, _password, _firstName, _lastName);
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _formKey.currentState.reset();
        });
      }
    }
    _isLoading = false;
  }
}