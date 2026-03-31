import 'seed.dart';
import 'dart:math';
import 'dart:html';
import 'package:vector_math/vector_math.dart';

class Sunflower {
  int index;
  // relative index permet d'identifier le sunflower en relation dans le cas de la fusion
  int? relativeIndex;
  CanvasRenderingContext2D canvas;

  double orientation = 0.0;
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double velocityAngular = 0.0;
  double radius = 0.0;
  double mass = 0.0;
  List<int> groups = [0, 0, 0, 0, 0, 0, 0];
  num diversity = 0;
  int maxColorIndex = -1;
  int inclusionCycle = 0;

  Vector2 contact = Vector2.zero();
  double contactAlpha = 0.0;
  double contactRadius = 0.0;
  int contactMode = 0;

  List<Seed> seeds = <Seed>[];
  List<Seed> waitingSeeds = <Seed>[];
  int seedsToAddFirst = 0;

  bool purgeOn = false;
  bool fusionOn = false;
  int birthCountdown = 10;

  static Vector2 positionMax = Vector2(0.0, 0.0);
  static double radiusMax = 0;
  static num TAU = pi * 2;
  static num PHI = (sqrt(5) + 1) / 2;
  static num SPIRALDIM = 4;
  static num EFFECTDIM = 1;

  static num diversityMax = 0;
  static num equalityMax = 0;
  static bool equalityInverse = false;
  static num inclusionMax = 0;
  static num inclusionInterval = 0;
  static bool inclusionInverse = false;
  static int currentMaxSize = 0;
  static int currentMaxSizeIndex = 0;
  static int currentMaxSize2 = 0;
  static int currentMaxSizeIndex2 = 0;
  static int currentMaxSize3 = 0;
  static int currentMaxSizeIndex3 = 0;

  static bool blindOn = false;

  Sunflower (this.index, this.canvas);

  int? getRandomColorIndex() {
    if (seeds.length > 0) {
      int seedPosition = (seeds.length * Random().nextDouble()).floor();
      final Seed  s = seeds.elementAt(seedPosition);
      return s.colorIndex;
    }
    else {
      return null;
    }
  }

  void addSeed(Seed s) {
    if (seedsToAddFirst > 0) {
      if (!equalityInverse) {
        if (s.colorIndex == maxColorIndex) {
          seeds.insert(0, s);
        }
        else {
          seeds.add(s);
        }
      }
      else {
        if (s.colorIndex != maxColorIndex) {
          seeds.insert(0, s);
        }
        else {
          seeds.add(s);
        }
      }

      seedsToAddFirst -= 1;
    }
    else {
      seeds.add(s);
    }
    mass += 1.0;
    groups[s.colorIndex] += 1;
  }

  void substractSeeds(int maxSeeds) {
    // subtilité il faut mettre <= pour que le processus soit complet
    if (seeds.length <= maxSeeds) {
      maxSeeds = seeds.length;
      if (purgeOn) {
        mass = 0;
        groups = [0, 0, 0, 0, 0, 0, 0];
        relativeIndex = null;
      }
      else {
        emptySeeds();
      }
    }
    else {
      for (var i = 0; i < maxSeeds; i++) {
        // il y a au minimum une seed dans le sunflower sauf en cas de purge.
        if (seeds.length > 1) {
          // subtilité, en cas de purge active il faut attendre l'action de fusion dans l'autre sunflower (qui peut arriver plus tard dans la boucle de traitemennts) et c'est alors seulement cette action qui fera le ménage en référençant la liste du sunflower à purger, sinon il y aura une perte de données avec la fusion. C'est sans doute ce qui expliquait que j'avais des sunflowers qui disparaissaient tout seuls avant de corriger cette anomalie
          if (!purgeOn) {
            groups[seeds.last.colorIndex] -= 1;
            seeds.removeLast();
          }
          else {
            // On ne peut pas utiliser last car l'action remove est maintenant dépendante de la fusion à un autre moment, mais il faut quand même bien mettre à jour les groupes.
            groups[seeds[seeds.length-1-i].colorIndex] -= 1;
          }
          mass -= 1.0;
        }
      }
    }
  }

  void emptySeeds() {
    seeds.clear();
    mass = 0;
    groups = [0, 0, 0, 0, 0, 0, 0];
    relativeIndex = null;
  }

  void fusionSeeds(int maxSeeds) {
    if (waitingSeeds.length <= maxSeeds) {
      maxSeeds = waitingSeeds.length;
      fusionOn = false;
      relativeIndex = null;
    }
    for (var i = 0; i < maxSeeds; i++) {
      Seed s = waitingSeeds.last;
      addSeed(s);
      // Il faut retirer la seed de la liste d'attente, maintenant car la transfert a été fait. La liste d'attente référence l'objet liste du sunflower à purger.
      waitingSeeds.removeLast();
    }
  }

  num calcDiversity(List<int>? withGroups) {
    num diversityResult = 0;
    int fusionGroup = 0;
    int groupMajor = 0;
    int colorResult = -1;
    int withMass = 0;
    int i = 0;

    for (int group in groups) {
      if ((withGroups != null) && (i < withGroups.length) && (withGroups[i] != null)) {
        fusionGroup = group + withGroups[i];
        withMass += withGroups[i];
      }
      else {
        fusionGroup = group;
      }
      if (fusionGroup > groupMajor) {
        groupMajor = fusionGroup;
        colorResult = i;
      }
      i++;
    }

    diversityResult = ((mass + withMass) - groupMajor) / (mass + withMass);

    if (withGroups == null) {
      diversity = diversityResult;
      maxColorIndex = colorResult;
    }

    return diversityResult;
  }

  void draw() {
    // commencer par le cycle d'inclusion
    if (inclusionInterval != 0) {
      inclusionCycle = ((inclusionCycle + 1) % inclusionInterval).toInt();
      if ((inclusionCycle == 0) && (seeds.length > 6)) {
        if (inclusionInverse) {
          for (var i=0; i<5; i++ ) {
            seeds.add(seeds.first);
            seeds.removeAt(0);
          }
        }
        else {
          for (var i=0; i<5; i++ ) {
            seeds.insert(0, seeds.last);
            seeds.removeLast();
          }
        }

      }
    }

    // fin du cycle d'inclusion
    int i = 0;
    double r = 0.0;
    double theta = 0.0;
    if (!blindOn) {
      for (Seed s in seeds) {
        theta = (i * TAU / PHI) + orientation;
        r = sqrt(i) * SPIRALDIM;
        s.posX = position.x + (r * cos(theta));
        s.posY = position.y + (r * sin(theta));
        s.draw();
        i++;
      }
    }
    else {
      r = sqrt(seeds.length - 1) * SPIRALDIM;
    }

    // radius minimum pour permettre de détecter des collisions
    radius = r + Seed.SEED_RADIUS;

    if ((contactAlpha > 0) && (contactRadius > 0) && (!blindOn)) {
      switch (contactMode) {
        case 1 : canvas..beginPath()
          ..setFillColorRgb(255, 255, 255, contactAlpha)
          ..arc(contact.x, contact.y, contactRadius, 0, TAU, false)
          ..closePath()
          ..fill();
          contactAlpha -= 0.03;
          contactRadius += 0.2 * EFFECTDIM;
          break;
        case 2 : canvas..beginPath()
          ..lineWidth = EFFECTDIM
          ..setStrokeColorRgb(255, 255, 255, contactAlpha)
          ..arc(contact.x, contact.y, contactRadius, 0, TAU, false)
          ..closePath()
          ..stroke();
          contactAlpha -= 0.03;
          contactRadius += EFFECTDIM;
          break;
        case 3 : canvas..beginPath()
          ..lineWidth = EFFECTDIM
          ..setStrokeColorRgb(255, 255, 255, contactAlpha)
          ..moveTo(contact.x - (contactRadius/4), contact.y - (contactRadius / 4))
          ..lineTo(contact.x + (contactRadius/4), contact.y + (contactRadius / 4))
          ..moveTo(contact.x + (contactRadius/4), contact.y - (contactRadius / 4))
          ..lineTo(contact.x - (contactRadius/4), contact.y + (contactRadius / 4))
          ..closePath()
          ..stroke();
          contactAlpha -= 0.03;
          contactRadius += EFFECTDIM;
          break;
      }
    }
    else {
      contactMode = 0;
    }
  }

  void updatePosition() {
    position += velocity;
    position.x = position.x % positionMax.x;
    position.y = position.y % positionMax.y;
    orientation = (orientation + velocityAngular) % (pi * 2);
    if (birthCountdown > 0) {
      birthCountdown--;
    }
    else {
      birthCountdown = 0;
    }
  }

  int hitTestSunflower(Sunflower sf) {
    // distance alternatives corrigées selon les huit cases qui entourent l'écran, dans le sens horaire
    List<double> distances = <double>[];
    distances.add(position.distanceToSquared(sf.position));
    distances.add(position.distanceToSquared(sf.position + Vector2(0, -1*positionMax.y)));
    distances.add(position.distanceToSquared(sf.position + Vector2(positionMax.x, -1*positionMax.y)));
    distances.add(position.distanceToSquared(sf.position + Vector2(positionMax.x, 0)));
    distances.add(position.distanceToSquared(sf.position + Vector2(positionMax.x, positionMax.y)));
    distances.add(position.distanceToSquared(sf.position + Vector2(0, positionMax.y)));
    distances.add(position.distanceToSquared(sf.position + Vector2(-1*positionMax.x, positionMax.y)));
    distances.add(position.distanceToSquared(sf.position + Vector2(-1*positionMax.x, 0)));
    distances.add(position.distanceToSquared(sf.position + Vector2(-1*positionMax.x, -1*positionMax.y)));

    double distance = distances.first;
    int i = 0;
    int nearestIndex = 0;
    for (double d in distances) {
      if (d < distance) {
        distance = d;
        nearestIndex = i;
      }
      i++;
    }
    distance = sqrt(distance);

    double distanceMin = radius + sf.radius;
    if (distance < distanceMin) {
      switch (nearestIndex) {
        case 1 : sf.position += Vector2(0, -1*positionMax.y); break;
        case 2 : sf.position += Vector2(positionMax.x, -1*positionMax.y); break;
        case 3 : sf.position += Vector2(positionMax.x, 0); break;
        case 4 : sf.position += Vector2(positionMax.x, positionMax.y); break;
        case 5 : sf.position += Vector2(0, positionMax.y); break;
        case 6 : sf.position += Vector2(-1*positionMax.x, positionMax.y); break;
        case 7 : sf.position += Vector2(-1*positionMax.x, 0); break;
        case 8 : sf.position += Vector2(-1*positionMax.x, -1*positionMax.y); break;
      }

      // calculs mathématiques pour un rebond élastique
      Vector2 n = (sf.position - position) / distance;
      // calcul du point d'impact
      contact = (n * radius) + position;
      contact.x = contact.x % positionMax.x;
      contact.y = contact.y % positionMax.y;
      // suite du calcul pour la vélocité de rebond élastique
      double vn = dot2(velocity, n);
      double sfvn = dot2(sf.velocity, n);
      double vnp = (((mass - sf.mass) * vn) + (2 * sf.mass * sfvn)) / (mass + sf.mass);
      double sfvnp = (((sf.mass - mass) * sfvn) + (2 * mass * vn)) / (mass + sf.mass);
      velocity = velocity + (n * (vnp - vn));
      sf.velocity = sf.velocity + (n * (sfvnp - sfvn));
      // modification de la velocité angulaire en prenant un peu celle de l'autre
      velocityAngular = max(-0.02, min(0.02, velocityAngular - ((sf.radius / radius) * (sf.velocityAngular / 4))));
      // modification de la velocité angulaire en prenant en compte un peu celle de l'autre
      sf.velocityAngular = max(-0.02, min(0.02, sf.velocityAngular - ((radius / sf.radius) * (velocityAngular / 4))));
      // repositionnement du sunflower pour sortir de la zone de contact. J'applique un coef multiplicateur 1 pour un peu plus écarter les deux disques.
      // Je supprime l'ajout de SEED_RADIUS dans le calcul de l'éloignement des positions.
      // (1 * (radius + sf.radius + (0*Seed.SEED_RADIUS) - distance) / 2))
      position = position - (n * ((radius + sf.radius - distance) / 2));
      sf.position = sf.position + (n * ((radius + sf.radius - distance) / 2));

      // mise en place de l'effet graphique de la collision
      contactAlpha = 1.0;
      contactRadius = 2.0;

      // interaction avec les seeds de l'autre sunflower
      if ((!purgeOn) && (!sf.purgeOn) && (!fusionOn) && (!sf.fusionOn)
          && (radius < radiusMax) && (sf.radius < radiusMax)
          && (birthCountdown == 0) && (sf.birthCountdown == 0)) {
        // cas d'une action possible, fusion ou friction
        final num fusionDiversity = calcDiversity(sf.groups);
        if (fusionDiversity <= Sunflower.diversityMax) {
          contactMode = 2;
        }
        else {
          if ((mass == 1) && (sf.mass == 1)) {
            contactMode = 2;
          }
          else {
            contactMode = 3;
          }
        }
      }
      else {
        final num fusionDiversity = calcDiversity(sf.groups);
        if (fusionDiversity <= Sunflower.diversityMax) {
          // cas d'un rebond elactique sans interactions
          contactMode = 1;
        }
        else {
          contactMode = 3;
        }
      }
      return contactMode;
    }
    // quand il n'y a pas de choc
    else {
      return 0;
    }

  }

  String toSvg() {
    final buffer = StringBuffer("<g>");
    buffer.write(String.fromCharCode(13));
    for (Seed s in seeds) {
      buffer..write(s.toSvg())
            ..write(String.fromCharCode(13));
    }
    buffer..write("</g>")
          ..write(String.fromCharCode(13));

    if ((contactAlpha > 0) && (contactRadius > 0)) {
      final cx = contact.x.round();
      final cy = contact.y.round();
      final cr = contactRadius.round();
      final ca = ((contactAlpha*10).round()/10);
      switch (contactMode) {
        case 1 : buffer..write('<circle cx="$cx" cy="$cy" r="$cr" fill="white" fill-opacity="$ca" />')
          ..write(String.fromCharCode(13));
        break;
        case 2 : buffer..write('<circle cx="$cx" cy="$cy" r="$cr" fill="none" stroke="white" stroke-opacity="$ca" stroke-width="${EFFECTDIM.round()}"/>')
          ..write(String.fromCharCode(13));
        break;
        case 3 : final int x1 = (contact.x - (contactRadius/4)).round();
          final int y1 = (contact.y - (contactRadius / 4)).round();
          final int x2 = (contact.x + (contactRadius/4)).round();
          final int y2 = (contact.y + (contactRadius / 4)).round();
          buffer..write('<g stroke="white" stroke-width="${EFFECTDIM.round()}" stroke-opacity="$ca">')
            ..write(String.fromCharCode(13))
            ..write('<line x1="$x1" y1="$y1" x2="$x2" y2="$y2"/>')
            ..write(String.fromCharCode(13))
            ..write('<line x1="$x1" y1="$y2" x2="$x2" y2="$y1"/>')
            ..write(String.fromCharCode(13))
            ..write('</g>')
            ..write(String.fromCharCode(13));
          break;
      }
    }

    return buffer.toString();
  }
}