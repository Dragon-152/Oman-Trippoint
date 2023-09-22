import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uuid/uuid.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Map<String, Map<String, String?>?> prices = {};
  List pricesCount = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Row(
          key: Key(Uuid().v4()),
          children: [
            Expanded(
              child: InputTextFieldWidget(
                labelText: "OMR *",
                validator: (val) {
                  bool empty = true;
                  print(prices.values);
                  prices.values.map((e) {
                    if (e != null) {
                      if (e.toString().trim() != "") {
                        empty = false;
                      }
                    }
                  });
                  if (val.toString().trim() != "") {
                    empty = false;
                  }
                  if (empty) {
                    return AppHelper.returnText(
                        context, "One price at least", "سعر واحد على الأقل");
                  }

                  if (val.length > 10) {
                    return AppHelper.returnText(
                        context, "Too long", "النص طويل جدا");
                  }
                  //   if (val.contains(r'[A-Za-z]')) {
                  //     return "The name should only consist of letters";
                  //   }
                  return null;
                },
                onSaved: (val) {
                  prices["1"] = {
                    "price": val?.trim(),
                  };
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: InputTextFieldWidget(
                labelText: AppHelper.returnText(context, "Price *", "السعر *"),
                validator: (val) {
                  if (prices["1"]?["price"] != null) {
                    if (val == null)
                      return AppHelper.returnText(
                          context, "Type the price", "اكتب السعر");
                    if (val.trim() == "" || val.length < 1)
                      return AppHelper.returnText(
                          context, "Type the price", "اكتب السعر");
                  }
                  if (val.length > 50) {
                    return AppHelper.returnText(
                        context, "Too long", "النص طويل جدا");
                  }
                  //   if (val.contains(r'[A-Za-z]')) {
                  //     return "The name should only consist of letters";
                  //   }
                  return null;
                },
                onSaved: (val) {
                  if (prices["1"]?["price"] != null) {
                    prices["1"] = {
                      "price": prices["1"]?["price"],
                      "des": val?.trim(),
                    };
                  }
                },
              ),
            ),
          ],
        ),
        if (pricesCount.contains(2))
          const SizedBox(
            height: 10,
          ),
        if (pricesCount.contains(2))
          Row(
            key: Key(Uuid().v4()),
            children: [
              Expanded(
                child: InputTextFieldWidget(
                  labelText: "OMR ",
                  validator: (val) {
                    //   if (val.contains(r'[A-Za-z]')) {
                    //     return "The name should only consist of letters";
                    //   }
                    if (val.length > 10) {
                      return AppHelper.returnText(
                          context, "Too long", "النص طويل جدا");
                    }
                    return null;
                  },
                  onSaved: (val) {
                    if (val.toString().trim() != "") {
                      prices["2"] = {
                        "price": val?.trim(),
                      };
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: InputTextFieldWidget(
                  labelText: AppHelper.returnText(context, "Price", "السعر"),
                  validator: (val) {
                    if (prices["2"]?["price"] != null) {
                      if (val == null)
                        return AppHelper.returnText(
                            context, "Type the price", "اكتب السعر");

                      if (val.trim() == "" || val.length < 1)
                        return AppHelper.returnText(
                            context, "Type the price", "اكتب السعر");
                    }
                    if (val.length > 50) {
                      return AppHelper.returnText(
                          context, "Too long", "النص طويل جدا");
                    }
                    return null;
                  },
                  onSaved: (val) {
                    if (prices["2"]?["price"] != null) {
                      prices["2"] = {
                        "price": prices["2"]?["price"],
                        "des": val?.trim(),
                      };
                    }
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    pricesCount.remove(2);
                  },
                  icon: Icon(Icons.delete_rounded))
            ],
          ),
        if (pricesCount.contains(3))
          const SizedBox(
            height: 10,
          ),
        if (pricesCount.contains(3))
          Row(
            key: Key(Uuid().v4()),
            children: [
              Expanded(
                child: InputTextFieldWidget(
                  labelText: "OMR",
                  validator: (val) {
                    //   if (val.contains(r'[A-Za-z]')) {
                    //     return "The name should only consist of letters";
                    //   }
                    if (val.length > 10) {
                      return AppHelper.returnText(
                          context, "Too long", "النص طويل جدا");
                    }
                    return null;
                  },
                  onSaved: (val) {
                    if (val.toString().trim() != "") {
                      prices["3"] = {
                        "price": val?.trim(),
                      };
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: InputTextFieldWidget(
                  labelText: AppHelper.returnText(context, "Price", "السعر"),
                  validator: (val) {
                    if (prices["3"]?["price"] != null) {
                      if (val == null) {
                        return AppHelper.returnText(
                            context, "Type the price", "اكتب السعر");
                      }
                      if (val.trim() == "" || val.length < 1) {
                        return AppHelper.returnText(
                            context, "Type the price", "اكتب السعر");
                      }
                    }
                    if (val.length > 50) {
                      return AppHelper.returnText(
                          context, "Too long", "النص طويل جدا");
                    }
                    return null;
                  },
                  onSaved: (val) {
                    if (prices["3"]?["price"] != null) {
                      prices["3"] = {
                        "price": prices["2"]?["price"],
                        "des": val?.trim(),
                      };
                    }
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    pricesCount.remove(3);
                  },
                  icon: Icon(Icons.delete_rounded))
            ],
          ),
        OutlinedButton.icon(
            icon: Icon(Icons.add_rounded),
            onPressed: () {
              setState(() {
                if (pricesCount.length < 3) {
                  pricesCount.add(pricesCount.length + 1);
                }
              });
            },
            label:
                Text(AppHelper.returnText(context, "Add Price", "إضافة سعر")))
      ]),
    );
  }
}
