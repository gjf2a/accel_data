library accel_data;

import 'package:intl/intl.dart';

NumberFormat _format = NumberFormat(".000", "en_US");

class Value3D {
  double _x, _y, _z;
  int _hash;

  Value3D(this._x, this._y, this._z) {
    _hash = toString().hashCode;
  }

  Value3D operator + (Value3D other) => Value3D(_x + other._x, _y + other._y, _z + other._z);
  Value3D operator - (Value3D other) => Value3D(_x - other._x, _y - other._y, _z - other._z);
  Value3D operator - () => Value3D(-_x, -_y, -_z);
  Value3D operator * (double scalar) => Value3D(_x * scalar, _y * scalar, _z * scalar);
  Value3D operator / (double scalar) => this * (1.0 / scalar);

  Value3D mean(Value3D other) => (this + other) / 2;

  @override
  bool operator ==(o) => o is Value3D && _x == o._x && _y == o._y && _z == o._z;

  @override
  int get hashCode => _hash;

  String toString() => '($_x,$_y,$_z)';

  String uiString() => '(${_format.format(_x)}, ${_format.format(_y)}, ${_format.format(_z)})';
}

class TimeStamped3D {
  double _stampSec;
  Value3D _value;

  TimeStamped3D(this._value, this._stampSec);

  TimeStamped3D.zeros() {
    _value = Value3D(0, 0, 0);
    _stampSec = 0;
  }

  bool operator ==(o) => o is TimeStamped3D && value == o.value && stampSec == o.stampSec;

  String toString() => '$value;${stampSec}s';

  String uiString() => '${value.uiString()}; ${_format.format(stampSec)}s';

  TimeStamped3D operator + (TimeStamped3D later) =>
      TimeStamped3D(_value + later.value, later._stampSec);

  TimeStamped3D interpolate(TimeStamped3D later) =>
      TimeStamped3D(_value.mean(later.value) * (later._stampSec - _stampSec), later._stampSec);

  Value3D get value => _value;
  double get stampSec => _stampSec;
}


class Estimator {
  TimeStamped3D _position, _velocity, _acceleration, _prevAcceleration;
  int _numReadings;

  Estimator() {
    reset();
  }

  void reset() {
    _numReadings = 0;
    _position = TimeStamped3D.zeros();
    _velocity = TimeStamped3D.zeros();
    _acceleration = TimeStamped3D.zeros();
    _prevAcceleration = TimeStamped3D.zeros();
  }

  bool get ready => _numReadings >= 3;
  TimeStamped3D get position => _position;
  TimeStamped3D get velocity => _velocity;
  TimeStamped3D get acceleration => _acceleration;
  int get numReadings => _numReadings;

  void add(TimeStamped3D accelerometerReading) {
    if (_numReadings == 0) {
      _prevAcceleration = accelerometerReading;
    } else if (_numReadings == 1) {
      _acceleration = accelerometerReading;
      _velocity = _prevAcceleration.interpolate(_acceleration);
    } else {
      var velocityUpdate = _acceleration.interpolate(accelerometerReading);
      var newVelocity = _velocity + velocityUpdate;
      var positionUpdate = _velocity.interpolate(newVelocity);
      _prevAcceleration = _acceleration;
      _acceleration = accelerometerReading;
      _velocity = newVelocity;
      _position += positionUpdate;
    }
    _numReadings += 1;
  }
}

class Averager {
  Value3D _total = Value3D(0, 0, 0);
  Value3D _last = Value3D(0, 0, 0);
  double _count = 0;

  void accumulate(Value3D v) {
    _last = v;
    _total += v;
    _count += 1.0;
  }

  void reset() {
    _total = Value3D(0, 0, 0);
    _count = 0;
  }

  Value3D get average => _count == 0 ? Value3D(0, 0, 0) : _total / _count;

  Value3D get last => _last;
}