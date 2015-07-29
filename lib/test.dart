import 'dart:math' as mt;

var totalAgents = 40;
var averageMoney = 2;
var minMoney = 1;
var winPercentaje = 0.05;
var iters = 1000;
var totalMoney = totalAgents * averageMoney;

void main() {


  List<Agent> agents = new Iterable.generate(totalAgents, (_) => new Agent (averageMoney)).toList();

  for (var _ in new Iterable.generate(iters)){
    agents.shuffle();

    for (var i in new Iterable.generate(totalAgents~/2, (x) => 2*x)){
      Agent.fight(agents[i], agents[i+1]);
    }



    Map<int,List<Agent>> map = groupBy(agents, (Agent a) => a.life.floor());
    var keys = map.keys.toList();
    keys.sort();
    List<Tuple> stats = keys
      .map ((num life) => new Tuple(life, map[life].length))
      .toList();

    print(map[keys.last]);

    if (_ == iters - 1)
      print (stats);
  }
}

class Tuple<A,B> {
  final A first;
  final B second;

  Tuple (this.first, this.second);

  String toString () => "($first, $second)";
}

class Agent {
  static final mt.Random random = new mt.Random();
  num life;
  Agent(this.life);

  static void fight (Agent a, Agent b) {
    var r = random.nextDouble();
    var aWins = r < (a.life / (a.life + b.life));

    if (aWins && b.life <= minMoney || !aWins && a.life <= minMoney)
      return;

    var gainA = aWins? b.life*winPercentaje : -a.life*winPercentaje;
    a.life += gainA;
    b.life -= gainA;
  }

  String toString () => life.toString();
}

Map<dynamic, List> groupBy (Iterable it, Function f) {
  Map<dynamic, List> map = {};

  for (var elem in it) {
    var key = f(elem);

    if (map.containsKey(key)) {
      map[key].add(elem);
    }
    else {
      map[key] = [elem];
    }
  }
  return map;
}
