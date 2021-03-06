import 'dart:async';
import 'dart:math';

import 'package:adhan_flutter/adhan_flutter.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah_example/model/player-model.dart';
import 'package:flutter_qiblah_example/provider/prayer_times.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/umm_alqura_calendar.dart';
import 'package:provider/provider.dart';
import 'Prayer_Time_Setting.dart';

class PrayerTime extends StatefulWidget {
  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  Map<Prayer, DateTime> mapNext = Map<Prayer, DateTime>();

  PrayerModel _prayerModel = PrayerModel();
  Color appColor = Color.fromRGBO(78, 161, 181, 1);
  DateTime time;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  int hourNum;
  int minNum;
  int secNum;

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
    _getCurrentLocation();
  }

  UmmAlquraCalendar selectedDate = UmmAlquraCalendar.now();

  getPicker(BuildContext ctx) {
    showRoundedDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 25),
      lastDate: DateTime(DateTime.now().year + 200),
      borderRadius: 16,
      theme: ThemeData(
        fontFamily: 'Sukar',
        primaryColor: Color(0xFF4EA1B5),
        accentColor:  Color(0xFF4EA1B5),
      ),
    );
  }
  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    print("dddddddddddddddddddddddddddddddddddd");
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude,
          localeIdentifier: 'ar');

      Placemark place = p[0];

      setState(() {
        _currentAddress = "${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _alertLocation(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.8),
          child: AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  child: Image.asset(
                    'assets/cancel.png',
                    width: 15,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                Text(
                  'تم تحديث موقعك الحالي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Sukar',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E824C)),
                ),
                Image.asset(
                  'assets/success.png',
                  width: 20,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
          ),
        );
      },
    );
  }

  Widget itemTime(String name, TimeOfDay time) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                time.format(context),
                style: TextStyle(fontFamily: 'Sukar', fontWeight: FontWeight.w600),
              ),
              Text(
                name,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Sukar', fontWeight: FontWeight.w300,color: Colors.black12),
              ),
            ],
          ),
          SizedBox(height: 8,)
        ],
      ),
    );
  }

  Widget itemTimer(String name, String number) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            name,
            style: TextStyle(fontFamily: 'Sukar', fontWeight: FontWeight.w900),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            color: appColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                number,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Sukar',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemDivider() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.75, child: Divider());
  }

  timerValue() {
    setState(() {
      hourNum =
          mapNext[mapNext.keys.elementAt(0)].difference(DateTime.now()).inHours;
      minNum = (mapNext[mapNext.keys.elementAt(0)]
          .difference(DateTime.now())
          .inMinutes -
          (mapNext[mapNext.keys.elementAt(0)]
              .difference(DateTime.now())
              .inHours *
              60));
      secNum = (mapNext[mapNext.keys.elementAt(0)]
          .difference(DateTime.now())
          .inSeconds -
          (mapNext[mapNext.keys.elementAt(0)]
              .difference(DateTime.now())
              .inMinutes *
              60));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color background = Color(0xFF116B7B);
    final Color fill = appColor;
    final List<Color> gradient = [
      background,
      background,
      fill,
      fill,
    ];
    final double fillPercent = 50; // fills 56.23% for container from bottom
    final double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    Provider.of<PrayerTimes>(context, listen: false).getTimes(31.2444, 30.5497);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'مواقيت الصلاة',
            style: TextStyle(
                fontFamily: 'Sukar',
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(78, 161, 181, 1),
                fontSize: 23),
          ),
          elevation: 1,
          backgroundColor: Colors.grey[100],
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrayerTimeSetting())),
              icon: Icon(
                Icons.settings,
                color: appColor,
              ),
            )
          ],
        ),
        body: _currentPosition == null
            ? Center(child: Text('Waiting...'))
            : Stack(
          children: <Widget>[

            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/mosque.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitHeight
                  // height: 200,
                  //  alignment: Alignment.center,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: getNextPrayer(),
                        builder:
                            (context, AsyncSnapshot<Prayer> snapshot) {
                          if (snapshot.hasData) {
                            final prayer = snapshot.data;
                            print("prayer.toString()");
                            print(prayer.toString());

                            return Text(
                              prayer == Prayer.FAJR
                                  ? "الفجر"
                                  : prayer == Prayer.SUNRISE
                                  ? "الشروق"
                                  : prayer == Prayer.DHUHR
                                  ? "الظهر"
                                  : prayer == Prayer.ASR
                                  ? "العصر"
                                  : prayer == Prayer.MAGHRIB
                                  ? "المغرب"
                                  : prayer == Prayer.ISHA
                                  ? "العشاء"
                                  : 'الفجر',
                              style: TextStyle(
                                  fontFamily: 'Sukar',
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromRGBO(159, 70, 51, 1),
                                  fontSize: 25),
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return Text('Waiting...');
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: FutureBuilder(
                        future: getNextPrayer(),
                        builder:
                            (context, AsyncSnapshot<Prayer> snapshot) {
                          if (snapshot.hasData) {
                            final prayer = snapshot.data;

                            return Container(
                              margin: EdgeInsets.only(left: 35),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
//                                      Countdown(
//                                        duration: Duration(
//                                            hours: 1,
//                                            minutes: 5,
//                                            seconds: 5),
//                                        onFinish: () {
//                                          print('finished!');
//                                        },
//                                        builder: (BuildContext ctx,
//                                            Duration remaining) {
//                                          return FlipClock.countdown(
//                                            duration: Duration(
//                                                hours: remaining.inHours,
//                                                minutes:
//                                                remaining.inMinutes,
//                                                seconds:
//                                                remaining.inSeconds),
//                                            width: MediaQuery.of(context)
//                                                .size
//                                                .width *
//                                                .05,
//                                            height: MediaQuery.of(context)
//                                                .size
//                                                .height *
//                                                .05,
//                                            startTime: DateTime.now(),
//                                            digitColor: Colors.white,
//                                            backgroundColor: appColor,
//                                            digitSize: 20,
//                                            borderRadius:
//                                            BorderRadius.circular(3),
//                                            onDone: () => print('ih'),
//                                          );
//                                        },
//                                      ),
                                    Row(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text('ساعة',
                                              style:TextStyle(
                                              fontFamily: 'Sukar',),),
                                            SizedBox(height: 8,),
                                            Container(
                                              width: MediaQuery.of(context).size.width* .1,
                                              height: MediaQuery.of(context).size.width* .1,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                gradient: LinearGradient(
                                                  colors: gradient,
                                                  stops: stops,
                                                  end: Alignment.bottomCenter,
                                                  begin: Alignment.topCenter,
                                                ),
                                              ),

                                              child: Center(child: Text('03' ,
                                                style: TextStyle(
                                                  fontFamily: 'Sukar',
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900
                                                ),
                                                textAlign: TextAlign.center,)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10,),
                                        Column(
                                          children: <Widget>[
                                            Text('دقيقة',
                                              style:TextStyle(
                                                fontFamily: 'Sukar',),),
                                            SizedBox(height: 8,),
                                            Container(
                                              width: MediaQuery.of(context).size.width* .1,
                                              height: MediaQuery.of(context).size.width* .1,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                gradient: LinearGradient(
                                                  colors: gradient,
                                                  stops: stops,
                                                  end: Alignment.bottomCenter,
                                                  begin: Alignment.topCenter,
                                                ),
                                              ),

                                              child: Center(child: Text('23' ,
                                                style: TextStyle(
                                                    fontFamily: 'Sukar',
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900
                                                ),
                                                textAlign: TextAlign.center,)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10,),
                                        Column(
                                          children: <Widget>[
                                            Text('ثانية',
                                              style:TextStyle(
                                                fontFamily: 'Sukar',),),
                                            SizedBox(height: 8,),
                                            Container(
                                              width: MediaQuery.of(context).size.width* .1,
                                              height: MediaQuery.of(context).size.width* .1,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                gradient: LinearGradient(
                                                  colors: gradient,
                                                  stops: stops,
                                                  end: Alignment.bottomCenter,
                                                  begin: Alignment.topCenter,
                                                ),
                                              ),

                                              child: Center(child: Text('46' ,
                                                style: TextStyle(
                                                    fontFamily: 'Sukar',
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900
                                                ),
                                                textAlign: TextAlign.center,)),
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, left: 10),
                                        child: Text(
                                          "بعد",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Sukar',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return Text('Waiting...');
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Provider.of<PrayerTimes>(context, listen: false)
                        .prayer !=
                        null
                        ? Text(
                      Provider.of<PrayerTimes>(context,
                          listen: false)
                          .prayer
                          .date,
                      // " ${DateFormat.yMMMd().format(DateTime.now())} - ${UmmAlquraCalendar.fromDate(DateTime.now()).toFormat("MMMM dd, yyyy")} - ${DateFormat.EEEE().format(DateTime.now())}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sukar',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    )
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _currentAddress != null ? _currentAddress : "",
                          style: TextStyle(
                              fontFamily: 'Sukar',
                              fontWeight: FontWeight.w200,
                              fontSize: 14),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 14,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Provider.of<PrayerTimes>(context, listen: false)
                        .prayer !=
                        null
                        ? Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20.0)),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              color: appColor,
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      time = time.subtract(
                                          Duration(days: 1));
                                    });
                                  },
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Container(
                                      //margin: EdgeInsets.only(left: 20),
                                      child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "${Provider.of<PrayerTimes>(context, listen: false).prayer.date.split('-')[1]} \n${Provider.of<PrayerTimes>(context, listen: false).prayer.date.split('-')[2]} \n${Provider.of<PrayerTimes>(context, listen: false).prayer.date.split('-')[0]}",
                                            // "${UmmAlquraCalendar.fromDate(time).toFormat("MMMM dd, yyyy")}\n${DateFormat.yMMMd().format(time)}\n${DateFormat.EEEE().format(time)}",
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Sukar',
                                                fontWeight:
                                                FontWeight.w200,
                                                color:
                                                Colors.white),
                                          ),
                                          IconButton(
                                            onPressed:()=>
                                                getPicker(context),
                                            icon: Icon(
                                              Icons.date_range,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    print("object");
                                    setState(() {
                                      time = time
                                          .add(Duration(days: 1));
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          itemTime(
                              "الفجر",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .fajr
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .fajr
                                          .split(':')[1]))),
                          itemDivider(),
                          itemTime(
                              "الشروق",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .sunrise
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .sunrise
                                          .split(':')[1]))),
                          itemDivider(),
                          itemTime(
                              "الظهر",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .dhuhr
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .dhuhr
                                          .split(':')[1]))),
                          itemDivider(),
                          itemTime(
                              "العصر",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .asr
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .asr
                                          .split(':')[1]))),
                          itemDivider(),
                          itemTime(
                              "المغرب",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .maghrib
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .maghrib
                                          .split(':')[1]))),
                          itemDivider(),
                          itemTime(
                              "العشاء",
                              TimeOfDay(
                                  hour: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .isha
                                          .split(':')[0]),
                                  minute: int.parse(
                                      Provider.of<PrayerTimes>(
                                          context,
                                          listen: false)
                                          .prayer
                                          .isha
                                          .split(':')[1]))),

                          /*
                                  FutureBuilder(
                                    future: getTodayFajrTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        //   _prayerModel.setFajr(dateTime);

                                        return itemTime("الفجر", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),
                                  itemDivider(),



                                  itemTime("الشروق",DateTime.now()),

                                  Text(Provider.of<PrayerTimes>(context,listen: true).prayer != null ?

                                      Provider.of<PrayerTimes>(context,listen: true).prayer.sunrise :""),

                                  FutureBuilder(
                                    future: getTodaySunriseTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        //  _prayerModel.setSun(dateTime);

                                        return itemTime("الشروق", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),
                                  itemDivider(),
                                  FutureBuilder(
                                    future: getTodayDhuhrTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        //  _prayerModel.setDhor(dateTime);

                                        return itemTime("الظهر", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),
                                  itemDivider(),
                                  FutureBuilder(
                                    future: getTodayAsrTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        //  _prayerModel.setDhor(dateTime);
                                        return itemTime("العصر", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),
                                  itemDivider(),
                                  FutureBuilder(
                                    future: getTodayMaghribTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        // _prayerModel.setMaghrib(dateTime);
                                        return itemTime("المغرب", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),
                                  itemDivider(),
                                  FutureBuilder(
                                    future: getTodayIshaTime(),
                                    builder: (context,
                                        AsyncSnapshot<DateTime> snapshot) {
                                      if (snapshot.hasData) {
                                        final dateTime = snapshot.data.toLocal();
                                        // _prayerModel.setIsa(dateTime);

                                        return itemTime("العشاء", dateTime);
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        return Text('Waiting...');
                                      }
                                    },
                                  ),

                                  */
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                        : Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            elevation: 0.5,
            backgroundColor: Colors.white,
            //rgba(78, 161, 181, 1) 78, 161, 181
            child: Icon(
              Icons.my_location,
              color: Color.fromRGBO(78, 161, 181, 1),
            ),
            onPressed: () => _alertLocation(context)),
      ),
    );
  }

  Future<DateTime> getTodayFajrTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.fajr;
  }

  Future<DateTime> getTodaySunriseTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.sunrise;
  }

  Future<DateTime> getTodayDhuhrTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.dhuhr;
  }

  Future<DateTime> getTodayAsrTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.asr;
  }

  Future<DateTime> getTodayMaghribTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.maghrib;
  }

  Future<DateTime> getTodayIshaTime() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.isha;
  }

  Future<Prayer> getCurrentPrayer() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        time,
        CalculationMethod.KARACHI);
    return await adhan.currentPrayer();
  }

  Future<Prayer> getNextPrayer() async {
    final adhan = AdhanFlutter.create(
        Coordinates(_currentPosition.latitude, _currentPosition.longitude),
        DateTime.now(),
        CalculationMethod.EGYPTIAN);

    adhan.nextPrayer().then((prayer) {
      print("mapNext[prayer]");

      print(prayer);

      print(mapNext[prayer]);

      if (mapNext[prayer] == null) {
        if (prayer == Prayer.FAJR) {
          adhan.fajr.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.SUNRISE) {
          adhan.sunrise.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.DHUHR) {
          adhan.dhuhr.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.ASR) {
          adhan.asr.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.MAGHRIB) {
          adhan.maghrib.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.ISHA) {
          adhan.isha.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        } else if (prayer == Prayer.NONE) {
          adhan.fajr.then((p) {
            setState(() {
              mapNext[prayer] = p;
            });
            timerValue();
          });
        }
      }
    });

    return await adhan.nextPrayer();
  }
}
