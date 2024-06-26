import 'dart:convert';

import 'package:Khabar/models/NewsDataModel.dart';
import 'package:Khabar/models/source_response_model.dart';
import 'package:Khabar/screens/bloc/states.dart';
import 'package:Khabar/shared/constants.dart';
import 'package:Khabar/shared/network/remote/endPoints.dart';
import 'package:Khabar/shared/styles/app_strings.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitState());
  static HomeCubit get(context) => BlocProvider.of(context);
  List<Sources> sources = [];
  List<Articles> articles = [];
  int selectedIndex = 0;
  void changeSelectedSourceIndex(int index) {
    selectedIndex = index;
    emit(ChangeSelectedSource());
  }

  Future<void> getSources(String categoryId, BuildContext context) async {
     emit(HomeGetSourcesLoadingState());
    try {
       // var provider = Provider.of<MyProvider>(context);

      Uri url = Uri.https(Constants.BASE_URL, EndPoints.sources, {
        AppString.apiKey: Constants.API_KEY_VALUE,
        AppString.category: categoryId,
         // AppString.language :provider.languageCode
      });
      http.Response response = await http.get(url);
      Map<String, dynamic> json = jsonDecode(response.body);
      SourceResponseModel sourceResponseModel =
          SourceResponseModel.fromJson(json);
      sources = sourceResponseModel.sources ?? [];
      emit(HomeGetSourcesSuccessState());
    } catch (e) {
      emit(
        HomeGetSourcesErrorState(
          e.toString(),
        ),
      );
      print(e);
    }
  }

  Future<void> getNewsData(String searchedVal, BuildContext context,int pageSize,int page) async {
     // var provider = Provider.of<MyProvider>(context);
    try {
       emit(HomeGetNewsLoadingState());
      Uri url = Uri.https(Constants.BASE_URL, EndPoints.newsData, {
        AppString.apiKey: Constants.API_KEY_VALUE,
        AppString.sources: sources[selectedIndex].id,
        'q': searchedVal,
        // 'pageSize':'$pageSize',
        // 'page':'$page',
         // AppString.language :provider.languageCode
      });
      http.Response response = await http.get(url);
      Map<String, dynamic> json = jsonDecode(response.body);
      NewsDataModel newsDataModel = NewsDataModel.fromJson(json);
      articles = newsDataModel.articles ?? [];
      emit(HomeGetNewsSuccessState());
    } catch (e) {
      emit(HomeGetNewsErrorState(e.toString()));
    }
  }
}
