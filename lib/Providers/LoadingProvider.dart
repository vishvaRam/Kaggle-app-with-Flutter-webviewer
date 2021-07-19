import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier{
  int _progress = 0;
  bool _isLoading = false;

  int get progress => _progress;
  bool get isLoading => _isLoading;

  setProgress(int value){
    _progress = value;
    notifyListeners();
  }
  reSetProgress(){
    _progress =0;
    notifyListeners();
  }
  setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
}