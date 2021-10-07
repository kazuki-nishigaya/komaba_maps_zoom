import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:location/location.dart';



class GoogleMaps extends StatefulWidget {
  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}



Set<Marker> _createMarker() {
  return {
    Marker(
      markerId: MarkerId("destination"),
      position: LatLng(lat[num], long[num]),
    ),
  };
}

//Set<Polyline> _polyline={};

int num=18;

List<double> lat = [35.6598397,35.6593117,35.6607411,35.6605338,35.6610601,35.6599659,
  35.6607347,35.6605018,35.659832,35.6606455,35.6603639,35.660281,35.6605001,35.6591107,
  35.6605044,35.6598812,35.6611821,35.6611838,35.6587374];
List<double> long = [139.6848356,139.6836729, 139.6860089,139.6863858,139.6844503,139.6873125,
  139.6845799,139.6854947,139.6838042,139.6849458,139.684239,139.683548,139.6837391,139.6853381,
  139.6877397,139.6865876,139.6836969,139.6851203,139.6840927];
//List<int> min = [101,21,101,011,511,1,721,110,900,101,1101,1211,1311,1];//教室番号の最小値
//List<int> max = [192,49,502,214,534,4,762,422,900,405,1109,1233,1341,3];//教室番号の最大値
List<String> name = ["1号館","情報教育棟","21KOMCEE West","21KOMCEE East","5号館",
  "コミニケーションプラザ(北)","7号館","8号館","講堂","10号館","11号館","12号館","13号館",
  "アドミニストレーション棟","第一体育館","駒場図書館","17号館","18号館"];

String destination='';
final myController = TextEditingController();

class _GoogleMapsState extends State<GoogleMaps> {
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  String dropdownValue='1号館';
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDSEFIrVbRPeaFm2W_585Sn07nTWqciPho";
  Map<MarkerId, Marker> markers = {};

  @override

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(35.6587374,139.6840927), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(lat[num],long[num]), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(35.6587374,139.6840927),
      PointLatLng(lat[num],long[num]),
      travelMode: TravelMode.walking,
      //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(
        markerId: markerId, icon: descriptor, position: position,infoWindow: InfoWindow(title: destination)
    );
    markers[markerId] = marker;
  }
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("komaba_map"),
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: Colors.pink,
                    height:300,
                    width:MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child:GoogleMap(
                      onMapCreated: _onMapCreated,
                      scrollGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationEnabled: true,
                      markers: _createMarker(),
                      initialCameraPosition: const CameraPosition(  // 最初のカメラ位置
                        target: LatLng(35.6603865, 139.6853525),
                        bearing: 16,
                        zoom: 16.002,
                      ),
                      polylines: Set<Polyline>.of(polylines.values),
                    ),
                  ),
                  Container(
                      padding:EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(child:
                            TextFormField(
                              controller: myController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.school),
                                border: OutlineInputBorder(),
                                hintText: 'どこへ行きますか?',
                                labelText: '部屋番号 *',
                              ),
                              onSaved: (String? value) {
                                // This optional block of code can be used to run
                                // code when the user saves the form.
                              },
                            )
                            ),
                            Flexible(child:
                            ElevatedButton(
                              onPressed:  () {
                                setState(() {
                                  if(roomToBuilding(myController.text)!=''){
                                    destination=roomToBuilding(myController.text);
                                    num=name.indexOf(destination);
                                  }else{
                                    destination='存在しない部屋です';
                                  }
                                  polylines = {};
                                  polylineCoordinates = [];
                                  _getPolyline();
                                });
                              },
                              child: Text('Go!'),
                            )
                            ),
                          ]
                      )
                  ),

                  Center(child:
                  Container(
                      padding:EdgeInsets.fromLTRB(30, 40, 30, 0),
                      child:Column(
                          children: <Widget>[
                            Text('あなたが向かうのは...'),
                            Text(
                                destination,
                                style:
                                TextStyle(
                                  fontSize:50,
                                  color: Colors.red,
                                )
                            ),
                          ]
                      )
                  )
                  )
                ]
            )
        )
    );
  }
}



Map<String, String> rooms = {
  '進学情報センター': '1号館',
  '学生相談所': '1号館',
  'ロッカー室': '7号館',
  'バリアフリー支援室': '8号館',
  '学際交流ホール': 'アドミニストレーション棟',
  '学際交流室': 'アドミニストレーション棟',
  '学際交流ラウンジ': 'アドミニストレーション棟',
  '外国語メディア学習室': '10号館',
  '英語教育支援室': '10号館',
  '身体運動実習室1': 'コミュニケーシ進学情報センターョンプラザ(北館)',
  '身体運動実習室2': 'コミュニケーションプラザ(北館)',
  '身体運動実習室3': 'コミュニケーションプラザ(北館)',
  '音楽実習室': 'コミュニケーションプラザ(北館)',
  '舞台芸術実習室': 'コミュニケーションプラザ(北館)',
  '多目的室1': 'コミュニケーションプラザ(北館)',
  '多目的室2': 'コミュニケーションプラザ(北館)',
  '多目的室3': 'コミュニケーションプラザ(北館)',
  '多目的室4': 'コミュニケーションプラザ(北館)',
};
List<int> numroom=[101,102,103,104,105,106,107,108,109,
  112,113,114,115,116,117,118,119,120,121,122,127,
  149,150,151,152,153,154,155,156,157,158,159,
  160,161,162,163,164,165,166,167,
  184,185,186,187,188,189,191,192,
  511,512,513,514,515,516,517,518,
  521,522,523,524,525,531,532,533,534,
  721,722,723,724,741,742,743,761,762,
  1101,1102,1103,1105,1106,1107,1108,1109,
  1211,1212,1213,1214,1221,1222,1223,1224,1225,1226,1231,1232,1233,
  1311,1312,1313,1321,1322,1323,1331,1341];

String roomToBuilding(String room){
  String building='';
  if(int.tryParse(room)!=null){
    if(room=='900'){
      building='講堂';
    }else if(numroom.contains(int.parse(room))){
      building=((int.parse(myController.text)/100).floor()).toString()+'号館';
    }
  }else if(room[0]=='8'){
    building='8号館';
  }else if(room[0]=='1'&& room[1]=='0'){
    building='10号館';
  }else{
    if(rooms.containsKey(room)){
      building=rooms[room].toString();
    }
  }
  return building;
}

/*
// Object for PolylinePoints
PolylinePoints polylinePoints=PolylinePoints();

// List of coordinates to join
List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting
// two points
Map<PolylineId, Polyline> polylines = {};

_createPolylines(slat,slong,glat,glong) async {
  // Initializing PolylinePoints
  polylinePoints = PolylinePoints();

  // Generating the list of coordinates to be used for
  // drawing the polylines
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    'AIzaSyDZZYAKL6CXCP6-UjD-E1DJPnzmFiZLcqA', // Google Maps API Key
    PointLatLng(slat, slong),
    PointLatLng(glat, glong),
    travelMode: TravelMode.transit,
  );

  // Adding the coordinates to the list
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  }

  // Defining an ID
  PolylineId id = PolylineId('poly');

  // Initializing Polyline
  Polyline polyline = Polyline(
    polylineId: id,
    color: Colors.red,
    points: polylineCoordinates,
    width: 3,
  );

  // Adding the polyline to the map
  polylines[id] = polyline;
}*/
