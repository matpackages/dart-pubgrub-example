import 'dart:convert';
import 'dart:io';

void main() {
    var jsonString = File('scores.json').readAsStringSync();
    var scores = jsonDecode(jsonString);
    var score = scores[1];
    print('The score is ${score["score"]}');
    print(scores);
}
