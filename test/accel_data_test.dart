import 'package:accel_data/accel_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one', () {
    Value3D v1 = Value3D(1, 2, 3);
    expect(-v1, Value3D(-1, -2, -3));
    expect(v1.toString(), "(1.0,2.0,3.0)");
    expect((-v1).toString(), "(-1.0,-2.0,-3.0)");

    Value3D v2 = Value3D(4, 5, 6);
    expect(v1 + v2, Value3D(5, 7, 9));
    expect(v1 - v2, Value3D(-3, -3, -3));
    expect(v2 - v1, Value3D(3, 3, 3));
  });

  test('formatting', () {
    Value3D v = Value3D(1000.48888, 100.008, 1.49999);
    expect(v.uiString(), '(1000.489, 100.008, 1.500)');
  });

  test('Estimator', () {
    Estimator est = Estimator();
    expect(est.ready, false);
    expect(est.numReadings, 0);
    est.add(TimeStamped3D(Value3D(.1, .0, .2), .1));
    expect(est.ready, false);
    expect(est.numReadings, 1);
    est.add(TimeStamped3D(Value3D(.1, .1, .3), .2));
    expect(est.ready, false);
    expect(est.numReadings, 2);
    expect(est.velocity.uiString(), "(.010, .005, .025); .200s");
    est.add(TimeStamped3D(Value3D(0, 0, 0), .4));
    expect(est.ready, true);
    expect(est.numReadings, 3);
    expect(est.velocity.uiString(), "(.020, .015, .055); .400s");
    expect(est.position.uiString(), "(.003, .002, .008); .400s");
  });

  test('Averager', () {
    Averager avg = Averager();
    avg.accumulate(Value3D(1, 1, 1));
    expect(avg.last, Value3D(1, 1, 1));
    avg.accumulate(Value3D(2, 0, 5));
    expect(avg.last, Value3D(2, 0, 5));
    expect(avg.average, Value3D(1.5, 0.5, 3.0));
  });
}