import 'dart:math';

import 'package:flame/components.dart';

import 'game.dart';
import 'power_ups.dart';
import 'knows_game_size.dart';

// Represents the types of power up we have to offer.
enum PowerUpTypes { Health, Freeze, Nuke, MultiFire }

// This class/component is responsible for spawning random power ups
// at random locations in the game world.
class PowerUpManager extends BaseComponent
    with KnowsGameSize, HasGameRef<SpacescapeGame> {
  // Controls the frequency of spawning power ups.
  late Timer _spawnTimer;

  // Controls the amount of time for which this component
  /// should be freezed when [Freeze] power is activated.
  late Timer _freezeTimer;

  // A random number generator.
  Random random = Random();

  // A private static map which stores a generator function for each power up.
  static Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)>
      _powerUpMap = {
    PowerUpTypes.Health: (position, size) => Health(
          position: position,
          size: size,
        ),
    PowerUpTypes.Freeze: (position, size) => Freeze(
          position: position,
          size: size,
        ),
    PowerUpTypes.Nuke: (position, size) => Nuke(
          position: position,
          size: size,
        ),
    PowerUpTypes.MultiFire: (position, size) => MultiFire(
          position: position,
          size: size,
        ),
  };

  PowerUpManager() : super() {
    // Makes sure that a new power up is spawned every 5 seconds.
    _spawnTimer = Timer(5, callback: _spawnPowerUp, repeat: true);

    // Restarts the spawn timer after 2 seconds are
    // elapsed from start of freeze timer.
    _freezeTimer = Timer(2, callback: () {
      _spawnTimer.start();
    });
  }

  // This method is responsible for generating a
  // random power up at random location on the screen.
  void _spawnPowerUp() {
    Vector2 initialSize = Vector2(64, 64);
    Vector2 position = Vector2(
      random.nextDouble() * gameSize.x,
      random.nextDouble() * gameSize.y,
    );

    // Clamp so that the power up does not
    // go outside the screen.
    position.clamp(
      Vector2.zero() + initialSize / 2,
      gameSize - initialSize / 2,
    );

    // Returns a random integer from 0 to (PowerUpTypes.values.length - 1).
    int randomIndex = random.nextInt(PowerUpTypes.values.length);

    // Tried to get the generator function corresponding to selected random power.
    final fn = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];

    // If the generator function is valid call it and get the power up.
    var powerUp = fn?.call(position, initialSize);

    // If power up is valid, set anchor to center.
    powerUp?.anchor = Anchor.center;

    // If power up is valid, add it to game world.
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onMount() {
    // Start the spawn timer as soon as this component is mounted.
    _spawnTimer.start();
    super.onMount();
  }

  @override
  void onRemove() {
    // Stop the spawn timer as soon as this component is removed.
    _spawnTimer.stop();
    super.onRemove();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
    super.update(dt);
  }

  // This method gets called when the game is being restarted.
  void reset() {
    // Stop all the timers.
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  // This method gets called when freeze power is activated.
  void freeze() {
    // Stop the spawn timer.
    _spawnTimer.stop();

    // Restart the freeze timer.
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
