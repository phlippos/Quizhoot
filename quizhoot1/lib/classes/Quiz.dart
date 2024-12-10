import 'package:quizhoot/services/quiz_service.dart';

class Quiz{
  double _result;
  int _correct_answer;
  int _incorrect_answer;
  bool _type;

  QuizService _service = QuizService.instance;

  QuizService get service => _service;

  Quiz(this._result,this._correct_answer,this._incorrect_answer,this._type);

  double get result => _result;

  set result(double value) {
    _result = value;
  }

  int get correct_answer => _correct_answer;

  set correct_answer(int value) {
    _correct_answer = value;
  }

  int get incorrect_answer => _incorrect_answer;

  set incorrect_answer(int value) {
    _incorrect_answer = value;
  }

  bool get type => _type;

  set type(bool value) {
    _type = value;
  }

  Future<bool> add(int set_id) async{
    final response = await _service.add_quiz(set_id, result, correct_answer, incorrect_answer, type);
    if(response.statusCode == 201){
      return true;
    }else{
      throw Exception("Quiz not added");
    }
  }

  void calculateStatistics(List<String> answerKey, List<String> answers){
    correct_answer = _service.calculateCorrectAnswerNum(answerKey, answers);
    incorrect_answer = _service.calculateIncorrectAnswerNum(correct_answer, answers.length);
    result = _service.calculateResult(correct_answer, answers.length);
  }

}