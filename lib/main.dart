import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //permite que faça as requisições
import 'dart:async'; //requisição asyncrona para nao esperar os dados para rodar o código
import 'dart:convert'; //Para converter em JSON
import 'dart:io';

const request = "https://api.hgbrasil.com/finance?key=a0ba8795";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        //thema pro app todo
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  //função asyncrona para retornar no futuro esperar receber os dados e retornara em mapa
  http.Response response = await http.get(Uri.parse((request)),
      headers: {
      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
      },
  ); //Uri.parse = transforma em uri pois o request é uma String
  //await = esperar os dados chegarem, por isso tem async
  return jsonDecode(response.body); //transforma os dados da API em JSON
  //esse arquivo JSON vai se transformar em um Map
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    btcController.text = "";
  }

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar = 0;
  double euro = 0;
  double btc = 0;

  void _realChanged(String Text){
    if(Text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(Text);
    dolarController.text = (real/dolar).toStringAsFixed(2);//toStringAsFixed = mostrar 2 digitos
    euroController.text = (real/euro).toStringAsFixed(2);
    btcController.text = (real/btc).toStringAsFixed(2);
  }
  void _dolarChanged(String Text){
    if(Text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(Text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);//toStringAsFixed = mostrar 2 digitos
    euroController.text = (dolar * this.dolar /euro).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar /btc).toStringAsFixed(2);
  }
  void _euroChanged(String Text){
    if(Text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(Text);
    realController.text = (euro * this.euro).toStringAsFixed(2);//toStringAsFixed = mostrar 2 digitos
    dolarController.text = (euro * this.euro /dolar).toStringAsFixed(2);
    btcController.text = (euro * this.euro /btc).toStringAsFixed(2);
  }
  void _btcChanged(String Text){
    if(Text.isEmpty) {
      _clearAll();
      return;
    }
    double btc = double.parse(Text);
    realController.text = (btc * this.btc).toStringAsFixed(2);//toStringAsFixed = mostrar 2 digitos
    euroController.text = (btc * this.btc /euro).toStringAsFixed(2);
    dolarController.text = (btc * this.btc /dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(onPressed:_clearAll,
              icon: Icon(Icons.refresh))
        ],
        title: Text("\$Conversor de Moedas\$"),
        //para utilizar o cifrao ou uma aspas colocar barra invertida
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(), //espeficica o futuro q sera construido
        builder: (context, snapshot) {
          //snapshot é uma fotografia momentanea dos dados
          switch (snapshot.connectionState) {
            case ConnectionState.none: //caso esteja sem nada
            case ConnectionState.waiting: //caso esteja esperando
              return Center(
                  //retorne Center que centraliza um widget
                  child: Text(
                "Carregando Dados",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ));
            default: //caso não esteja sem nada e não esteja esperando
              if (snapshot.hasError) {
                //se tiver erro
                return Center(
                    //retorne Center que centraliza um widget
                    child: Text(
                  "Erro ao carregar Dados :(",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ));
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"][
                    "buy"]; //atribuindo ao dolar o caminho do JSON até o numero da compra
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                btc = snapshot.data!["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  //tela rolavel
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),//da um espaço
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                      Divider(),
                      buildTextField("BTC", "₿", btcController, _btcChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function(String) f){//criou um Widget, pois utiliza 3 vezes uma textfield, só muda a label e o prefix
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );

}




