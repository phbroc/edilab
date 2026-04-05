import 'dart:async';

import 'package:edilab/sunflower.dart';
import 'package:edilab/seed.dart';
import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';


class EdilabApp {
  bool modeDebug = false;
  List<Sunflower> sunflowers = <Sunflower>[];
  List<Sunflower> newSunflowers = <Sunflower>[];
  List<int> emptySfIndex = <int>[];
  List<int> freeSeeds = [0, 0, 0, 0, 0, 0, 0];
  int _width = 0;
  int _height = 0;
  double _centerX = 0.0;
  double _centerY = 0.0;
  num _scaleWorld = 1;
  num _scaleScreen = 1;
  int sunflowerIndex = 0;

  late CanvasElement _canvas;
  late CanvasRenderingContext2D _ctx2d;
  num _renderTime = DateTime.now().millisecondsSinceEpoch;
  Timer? prompting;
  Timer? starting;
  Timer? watching;
  bool pauseOn = false;
  final stopwatch = Stopwatch();
  bool audioOn = true;

  final HtmlElement prompter = querySelector("#prompter") as HtmlElement;
  final ParagraphElement watcher = querySelector("#watcher") as ParagraphElement;

  final LabelElement sliderGroup0lbl = querySelector("#sliderGroup0lbl") as LabelElement;
  final RangeInputElement sliderGroup0 = querySelector("#sliderGroup0") as RangeInputElement;
  final LabelElement sliderGroup1lbl = querySelector("#sliderGroup1lbl") as LabelElement;
  final RangeInputElement sliderGroup1 = querySelector("#sliderGroup1") as RangeInputElement;
  final LabelElement sliderGroup2lbl = querySelector("#sliderGroup2lbl") as LabelElement;
  final RangeInputElement sliderGroup2 = querySelector("#sliderGroup2") as RangeInputElement;
  final LabelElement sliderGroup6lbl = querySelector("#sliderGroup6lbl") as LabelElement;
  final RangeInputElement sliderGroup3 = querySelector("#sliderGroup3") as RangeInputElement;
  final LabelElement sliderGroup3lbl = querySelector("#sliderGroup3lbl") as LabelElement;
  final RangeInputElement sliderGroup4 = querySelector("#sliderGroup4") as RangeInputElement;
  final LabelElement sliderGroup4lbl = querySelector("#sliderGroup4lbl") as LabelElement;
  final RangeInputElement sliderGroup5 = querySelector("#sliderGroup5") as RangeInputElement;
  final LabelElement sliderGroup5lbl = querySelector("#sliderGroup5lbl") as LabelElement;
  final RangeInputElement sliderGroup6 = querySelector("#sliderGroup6") as RangeInputElement;
  final LabelElement sliderByGroupLbl = querySelector("#sliderByGroupLbl") as LabelElement;
  final RangeInputElement sliderByGroup = querySelector("#sliderByGroup") as RangeInputElement;

  final LabelElement sliderEqualityLbl = querySelector("#sliderEqualityLbl") as LabelElement;
  final RangeInputElement sliderEquality = querySelector("#sliderEquality") as RangeInputElement;
  final CheckboxInputElement inverseEquality = querySelector("#inverseEquality") as CheckboxInputElement;
  final LabelElement sliderDiversityLbl = querySelector("#sliderDiversityLbl") as LabelElement;
  final RangeInputElement sliderDiversity = querySelector("#sliderDiversity") as RangeInputElement;
  final LabelElement sliderInclusionLbl = querySelector("#sliderInclusionLbl") as LabelElement;
  final RangeInputElement sliderInclusion = querySelector("#sliderInclusion") as RangeInputElement;
  final CheckboxInputElement inverseInclusion = querySelector("#inverseInclusion") as CheckboxInputElement;

  final RadioButtonInputElement scaleWorldXS = querySelector("#scaleWorldXS") as RadioButtonInputElement;
  final RadioButtonInputElement scaleWorldS = querySelector("#scaleWorldS") as RadioButtonInputElement;
  final RadioButtonInputElement scaleWorldM = querySelector("#scaleWorldM") as RadioButtonInputElement;
  final RadioButtonInputElement scaleWorldL = querySelector("#scaleWorldL") as RadioButtonInputElement;
  final RadioButtonInputElement scaleWorldXL = querySelector("#scaleWorldXL") as RadioButtonInputElement;
  final CheckboxInputElement worldPortrait = querySelector("#worldPortrait") as CheckboxInputElement;

  final RadioButtonInputElement resume20s = querySelector("#resume20s") as RadioButtonInputElement;
  final RadioButtonInputElement resume40s = querySelector("#resume40s") as RadioButtonInputElement;
  final RadioButtonInputElement resume60s = querySelector("#resume60s") as RadioButtonInputElement;
  final RadioButtonInputElement resume90s = querySelector("#resume90s") as RadioButtonInputElement;

  final ButtonElement startBtn = querySelector("#startBtn") as ButtonElement;
  final ButtonElement pauseBtn = querySelector("#pauseBtn") as ButtonElement;
  final ButtonElement stopBtn = querySelector("#stopBtn") as ButtonElement;
  final ButtonElement fullscreenBtn = querySelector("#fullscreenBtn") as ButtonElement;
  final ButtonElement svgSaveBtn = querySelector("#svgSaveBtn") as ButtonElement;
  final CheckboxInputElement audioMode = querySelector("#audioMode") as CheckboxInputElement;


  final CheckboxInputElement blindMode = querySelector("#blindMode") as CheckboxInputElement;

  final CheckboxInputElement batchMode = querySelector("#batchMode") as CheckboxInputElement;
  final NumberInputElement batchIterations = querySelector("#batchIterations") as NumberInputElement;
  final NumberInputElement batchAutoEnding = querySelector("#batchAutoEnding") as NumberInputElement;
  final NumberInputElement batchFinalEnding = querySelector("#batchFinalEnding") as NumberInputElement;
  final HtmlElement csvLinesOutput = querySelector("#csvLinesOutput") as HtmlElement;
  final TableElement tableOutput = querySelector("#tableOutput") as TableElement;
  final ButtonElement csvSaveBtn = querySelector("#csvSaveBtn") as ButtonElement;
  final DivElement batchResult = querySelector("#batchResult") as DivElement;
  final UListElement screenResult = querySelector("#screenResult") as UListElement;

  late AudioElement tacSound;
  late AudioElement ticSound;
  late AudioElement tocSound;

  late int autoEndFrom;
  late int autoEndMinutes;
  late int autoEndMass;
  late int finalEndingMinutes;
  late int iterationsMax;
  late int iterationNumber;
  bool isBatch = false;

  static final EdilabApp _singleton = EdilabApp._internal();

  factory EdilabApp() {
    return _singleton;
  }

  EdilabApp._internal();

  void init() {
    _canvas = querySelector("#screen") as CanvasElement;
    _canvas.style.backgroundColor = "black";
    _ctx2d = _canvas.context2D;

    scaleScreen();

    Sunflower.positionMax = Vector2(_width.toDouble(), _height.toDouble());
    Seed.positionMax = Vector2(_width.toDouble(), _height.toDouble());

    sliderGroup0.onChange.listen((e) => sliderGroup0lbl.innerText = "${Seed.colorsFr[0]} (${sliderGroup0.value})");
    sliderGroup1.onChange.listen((e) => sliderGroup1lbl.innerText = "${Seed.colorsFr[1]} (${sliderGroup1.value})");
    sliderGroup2.onChange.listen((e) => sliderGroup2lbl.innerText = "${Seed.colorsFr[2]} (${sliderGroup2.value})");
    sliderGroup3.onChange.listen((e) => sliderGroup3lbl.innerText = "${Seed.colorsFr[3]} (${sliderGroup3.value})");
    sliderGroup4.onChange.listen((e) => sliderGroup4lbl.innerText = "${Seed.colorsFr[4]} (${sliderGroup4.value})");
    sliderGroup5.onChange.listen((e) => sliderGroup5lbl.innerText = "${Seed.colorsFr[5]} (${sliderGroup5.value})");
    sliderGroup6.onChange.listen((e) => sliderGroup6lbl.innerText = "${Seed.colorsFr[6]} (${sliderGroup6.value})");
    sliderByGroup.onChange.listen((e) => sliderByGroupLbl.innerText = "par groupes de (${sliderByGroup.value})");

    sliderEquality.onChange.listen((e) => sliderEqualityLbl.innerText = "Égalité (${sliderEquality.value}%)");
    sliderDiversity.onChange.listen((e) => sliderDiversityLbl.innerText = "Diversité (${sliderDiversity.value}%)");
    sliderInclusion.onChange.listen((e) => sliderInclusionLbl.innerText = "Inclusion (${sliderInclusion.value}%)");

    resume20s.onClick.listen(promptSet);
    resume40s.onClick.listen(promptSet);
    resume60s.onClick.listen(promptSet);
    resume90s.onClick.listen(promptSet);

    startBtn.onClick.listen(start);
    pauseBtn.onClick.listen(pause);
    stopBtn.onClick.listen(stop);
    fullscreenBtn.onClick.listen(goFullscreen);
    svgSaveBtn.onClick.listen(svgDownload);
    svgSaveBtn.hidden = true;
    audioMode.onClick.listen((event) {audioOn = !audioOn;});
    blindMode.onClick.listen((event) {Sunflower.blindOn = !Sunflower.blindOn;});

    csvSaveBtn.onClick.listen(csvDownload);
    csvSaveBtn.hidden = true;
    batchResult.hidden = true;

    tacSound = AudioElement("assets/tac.mp3");
    ticSound = AudioElement("assets/tic.mp3");
    tocSound = AudioElement("assets/toc.mp3");

    window.animationFrame.then(refreshScreen);
    window.onKeyPress.listen((event) {keyboardAction(event);});

  }

  void scaleScreen() {
    if (scaleWorldXL.checked!) {
      _scaleWorld = 0.6;
      _scaleScreen = 4;
      if (worldPortrait.checked!) {
        prompter.className = "xlPoPrompt";
      }
      else {
        prompter.className = "xlLaPrompt";
      }
    }
    else if (scaleWorldL.checked!) {
      _scaleWorld = 0.8;
      _scaleScreen = 2.66;
      if (worldPortrait.checked!) {
        prompter.className = "lPoPrompt";
      }
      else {
        prompter.className = "lLaPrompt";
      }
    }
    else if (scaleWorldM.checked!) {
      _scaleWorld = 1;
      _scaleScreen = 2;
      if (worldPortrait.checked!) {
        prompter.className = "mPoPrompt";
      }
      else {
        prompter.className = "mLaPrompt";
      }
    }
    else if (scaleWorldS.checked!) {
      _scaleWorld = 1.5;
      _scaleScreen = 1.33;
      if (worldPortrait.checked!) {
        prompter.className = "sPoPrompt";
      }
      else {
        prompter.className = "sLaPrompt";
      }
    }
    else if (scaleWorldXS.checked!) {
      _scaleWorld = 3;
      _scaleScreen = 1;
      if (worldPortrait.checked!) {
        prompter.className = "xsPoPrompt";
      }
      else {
        prompter.className = "xsLaPrompt";
      }
    }

    _width = (480 * _scaleScreen).round();
    _height = (270 * _scaleScreen).round();
    if (worldPortrait.checked!) {
      int h = _width;
      _width = _height;
      _height = h;
    }
    _centerX = (_width/2);
    _centerY = (_height/2);
    _canvas.width = _width;
    _canvas.height = _height;
    Sunflower.EFFECTDIM = max(1, _scaleScreen * _scaleWorld);
    Sunflower.positionMax = Vector2(_width.toDouble(), _height.toDouble());
    Seed.positionMax = Vector2(_width.toDouble(), _height.toDouble());
    // for the world
    Sunflower.SPIRALDIM = 4 * _scaleWorld * _scaleScreen;
    Seed.SEED_RADIUS = max(1, 3 * _scaleWorld * _scaleScreen);
    Sunflower.radiusMax = (min(_height, _width) / 2) + Seed.SEED_RADIUS;
  }

  void promptSet(MouseEvent? event) {
    if ((prompting != null) && (prompting!.isActive)) {
      prompting!.cancel();
    }

    int resumeFreq = 20;

    if (resume20s.checked!) {
      resumeFreq = 20;
    }
    else if (resume40s.checked!) {
      resumeFreq = 40;
    }
    else if (resume60s.checked!) {
      resumeFreq = 60;
    }
    else if (resume90s.checked!) {
      resumeFreq = 90;
    }

    prompting = Timer.periodic(Duration(seconds: resumeFreq), promptSituation);
  }

  void start(MouseEvent event) {
    stop(MouseEvent(""));

    scaleScreen();

    int launch0 = int.parse(sliderGroup0.value!);
    int launch1 = int.parse(sliderGroup1.value!);
    int launch2 = int.parse(sliderGroup2.value!);
    int launch3 = int.parse(sliderGroup3.value!);
    int launch4 = int.parse(sliderGroup4.value!);
    int launch5 = int.parse(sliderGroup5.value!);
    int launch6 = int.parse(sliderGroup6.value!);
    int group = int.parse(sliderByGroup.value!);

    while ((launch0 > 0) || (launch1 > 0) || (launch2 > 0) || (launch3 > 0) || (launch4 > 0) || (launch5 > 0) || (launch6 > 0)) {
      if (launch0 > 0) {
        addRandomSunflower(min(launch0, group), 0);
        launch0 -= group;
      }
      if (launch1 > 0) {
        addRandomSunflower(min(launch1, group), 1);
        launch1 -= group;
      }
      if (launch2 > 0) {
        addRandomSunflower(min(launch2, group), 2);
        launch2 -= group;
      }
      if (launch3 > 0) {
        addRandomSunflower(min(launch3, group), 3);
        launch3 -= group;
      }
      if (launch4 > 0) {
        addRandomSunflower(min(launch4, group), 4);
        launch4 -= group;
      }
      if (launch5 > 0) {
        addRandomSunflower(min(launch5, group), 5);
        launch5 -= group;
      }
      if (launch6 > 0) {
        addRandomSunflower(min(launch6, group), 6);
        launch6 -= group;
      }
    }

    Sunflower.equalityMax = int.parse(sliderEquality.value!)/100;
    Sunflower.equalityInverse = inverseEquality.checked!;
    Sunflower.diversityMax = int.parse(sliderDiversity.value!)/100;
    Sunflower.inclusionMax = int.parse(sliderInclusion.value!)/100;
    Sunflower.inclusionInverse = inverseInclusion.checked!;
    // calcul d'un frame rate pour la boucle d'inclusion.
    if (Sunflower.inclusionMax != 0) {
      Sunflower.inclusionInterval = 10 /  Sunflower.inclusionMax;
    }
    else {
      Sunflower.inclusionInterval = 0;
    }

    autoEndFrom = 0;
    autoEndMass = 0;
    stopwatch.reset();
    stopwatch.start();

    // si le déclenchement est manuel
    if (event.type != "") {
      if (batchMode.checked!) {
        isBatch = true;
        iterationsMax = max(1, int.parse(batchIterations.value!));
        iterationNumber = 1;
        autoEndMinutes = max(1, int.parse(batchAutoEnding.value!));
        finalEndingMinutes = max(1, int.parse(batchFinalEnding.value!));
        batchResult.hidden = false;
      }
      else {
        isBatch = false;
        iterationNumber = 0;
        batchResult.hidden = true;
      }
      screenResult.innerHtml = "";
      csvLinesOutput.innerText = "";
      csvSaveBtn.hidden = true;
      tableOutput.innerHtml = "";
    }

    starting = Timer(Duration(seconds: 1), promptStart);
    watching = Timer.periodic(Duration(seconds: 1), watch);

    promptSet(null);

    sliderGroup0.disabled = true;
    sliderGroup1.disabled = true;
    sliderGroup2.disabled = true;
    sliderGroup3.disabled = true;
    sliderGroup4.disabled = true;
    sliderGroup5.disabled = true;
    sliderGroup6.disabled = true;
    sliderByGroup.disabled = true;

    sliderEquality.disabled = true;
    sliderDiversity.disabled = true;
    sliderInclusion.disabled = true;
    inverseEquality.disabled = true;
    inverseInclusion.disabled = true;

    scaleWorldXS.disabled = true;
    scaleWorldS.disabled = true;
    scaleWorldM.disabled = true;
    scaleWorldL.disabled = true;
    scaleWorldXL.disabled = true;
    worldPortrait.disabled = true;

    batchMode.disabled = true;
    batchIterations.disabled = true;
    batchAutoEnding.disabled = true;
    batchFinalEnding.disabled = true;
  }

  void promptStart() {
    if (starting != null) starting!.cancel();
    // calcul de la couleur majoritaire dans le milieu libre
    int maxColor = 0;
    int maxColorIndex = -1;
    int i = 0;
    int nbColors = 0;
    int freeSeedsTotal = 0;
    for (int color in freeSeeds) {
      if (color > maxColor) {
        maxColor = color;
        maxColorIndex = i;
      }
      if (color > 0) nbColors++;
      freeSeedsTotal += color;
      i++;
    }

    String freeSeedsColor = "";
    String freeSeedsInfo = "";
    if (maxColorIndex >= 0) {
      freeSeedsColor = Seed.colorsFr[maxColorIndex];
      freeSeedsInfo = "Le milieu libre contient $freeSeedsTotal graines de $nbColors couleurs. La couleur majoritaire est $freeSeedsColor.";
    }

    prompter.innerText = "Démarrage de l'expérience. $freeSeedsInfo";
  }

  void promptSituation(Timer t) {
    bool autoEndDetected = false;
    // calcul de la couleur majoritaire dans le milieu libre
    int maxFreeColor = 0;
    int maxFreeColorIndex = -1;
    int i = 0;
    int nbColors = 0;
    int freeSeedsTotal = 0;
    for (int color in freeSeeds) {
      if (color > maxFreeColor) {
        maxFreeColor = color;
        maxFreeColorIndex = i;
      }
      if (color > 0) nbColors++;
      freeSeedsTotal += color;
      i++;
    }

    String freeSeedsTendency = "";
    num maxFreeColorRatio = maxFreeColor / freeSeedsTotal;
    if (maxFreeColorRatio == 1) {
      freeSeedsTendency = "totalement";
    }
    else if (maxFreeColorRatio > 0.7) {
      freeSeedsTendency = "très majoritairement";
    }
    else if (maxFreeColorRatio > 0.5) {
      freeSeedsTendency = "majoritairement";
    }
    else if (maxFreeColorRatio > 0.33) {
      freeSeedsTendency = "assez";
    }
    else {
      freeSeedsTendency = "plutôt";
    }

    String freeSeedsColor = "";
    String freeSeedsInfo = "";
    if (maxFreeColorIndex >= 0) {
      freeSeedsColor = Seed.colorsFr[maxFreeColorIndex];
      freeSeedsInfo = "Le milieu libre contient $freeSeedsTotal graines de $nbColors couleurs. Il est $freeSeedsTendency $freeSeedsColor.";
      if ((freeSeedsTotal == 1) && (Sunflower.currentMaxSize == 1)) {
        // cas où il ne reste plus qu'une seule graine dans l'espace, sans groupe
        if (autoEndFrom == 0) {
          autoEndFrom = stopwatch.elapsed.inMinutes;
        }
        else {
          if (stopwatch.elapsed.inMinutes >= autoEndFrom + autoEndMinutes) {
            autoEndDetected = true;
          }
        }
      }
      else {
        autoEndFrom = 0;
      }
    }
    else {
      if (Sunflower.currentMaxSize > 1) {
        double massTotal = 0;
        for (Sunflower sf in sunflowers) {
          massTotal += sf.mass;
        }
        freeSeedsInfo = "Le milieu libre est vide. Il y a ${sunflowers.length} groupes, totalisant ${massTotal.round()} graines.";
        if (autoEndFrom == 0) {
          autoEndFrom = stopwatch.elapsed.inMinutes;
          autoEndMass = massTotal.round();
        }
        else {
          if (stopwatch.elapsed.inMinutes >= autoEndFrom + autoEndMinutes) {
            if (autoEndMass == massTotal.round()) {
              autoEndDetected = true;
            }
            else {
              autoEndFrom = stopwatch.elapsed.inMinutes;
              autoEndMass = massTotal.round();
            }
          }
        }
      }
      else {
        freeSeedsInfo = "Le milieu libre est vide.";
      }

    }
    // verifier alors si on a dépassé le temps maximum autorisé finalEnding...
    if ((!autoEndDetected) && (isBatch) && (stopwatch.elapsed.inMinutes >= finalEndingMinutes)) {
      autoEndDetected = true;
    }

    String maxSunflower1Info = "";
    String maxSunflower1Csv = "";
    // composition du plus gros sunflower
    if (Sunflower.currentMaxSize > 1) {
      try {
        Sunflower? sfMax1 = sunflowers.firstWhere((sunflower) => sunflower.index == Sunflower.currentMaxSizeIndex);
        sfMax1.calcDiversity(null);
        String sfMax1Color = Seed.colorsFr[sfMax1.maxColorIndex];
        int sfMax1Radius = ((sfMax1.radius / Sunflower.radiusMax) * 100).round();
        int sfMax1Diversity = (sfMax1.diversity * 100).round();
        maxSunflower1Info = "Le plus grand groupe est $sfMax1Color. Il contient ${sfMax1.mass} graines, son rayon est à $sfMax1Radius % du maximum et sa diversité est $sfMax1Diversity %.";
        maxSunflower1Csv = "$sfMax1Color;${sfMax1.mass};$sfMax1Radius;$sfMax1Diversity";
      } catch (e) {
        maxSunflower1Info = "Pas de plus grand groupe trouvé.";
        maxSunflower1Csv = ";;;";
      }
    }
    else {
      maxSunflower1Info = "Il n'y a pas de groupe.";
      maxSunflower1Csv = ";;;";
    }

    String maxSunflower2Info = "";
    String maxSunflower2Csv = "";
    // composition du deuxième plus gros sunflower
    if (Sunflower.currentMaxSize2 > 1) {
      try {
        Sunflower? sfMax2 = sunflowers.firstWhere((sunflower) => sunflower.index == Sunflower.currentMaxSizeIndex2);
        sfMax2.calcDiversity(null);
        String sfMax2Color = Seed.colorsFr[sfMax2.maxColorIndex];
        int sfMax2Radius = ((sfMax2.radius / Sunflower.radiusMax) * 100).round();
        int sfMax2Diversity = (sfMax2.diversity * 100).round();
        maxSunflower2Info = "Le groupe suivant est $sfMax2Color. Il contient ${sfMax2.mass} graines et sa diversité est $sfMax2Diversity %.";
        maxSunflower2Csv = "$sfMax2Color;${sfMax2.mass};$sfMax2Radius;$sfMax2Diversity";
      } catch (e) {
        maxSunflower2Info = "Pas de second groupe trouvé.";
        maxSunflower2Csv = ";;;";
      }
    }
    else {
      maxSunflower2Info = "Il n'y a pas d'autre groupe.";
      maxSunflower2Csv = ";;;";
    }

    String maxSunflower3Info = "";
    String maxSunflower3Csv = "";
    if ((maxFreeColorIndex == -1) && (sunflowers.length > 2)) {
      // des infos sur le groupe 3 quand le mileu libre est vide.
      try {
        Sunflower? sfMax3 = sunflowers.firstWhere((sunflower) => sunflower.index == Sunflower.currentMaxSizeIndex3);
        sfMax3.calcDiversity(null);
        String sfMax3Color = Seed.colorsFr[sfMax3.maxColorIndex];
        int sfMax3Radius = ((sfMax3.radius / Sunflower.radiusMax) * 100).round();
        int sfMax3Diversity = (sfMax3.diversity * 100).round();
        maxSunflower3Info = "Un troisième groupe est de couleur $sfMax3Color avec ${sfMax3.mass} graines et sa diversité est $sfMax3Diversity %.";
        maxSunflower3Csv = "$sfMax3Color;${sfMax3.mass};$sfMax3Radius;$sfMax3Diversity";
      } catch (e) {
        maxSunflower3Info = "Pas de troisième groupe trouvé.";
        maxSunflower3Csv = ";;;";
      }
    }
    else {
      maxSunflower3Csv = ";;;";
    }

    if ((!autoEndDetected) || (!isBatch)) {
      String status = "En cours.";
      if (pauseOn) status = "En pause.";
      prompter.innerText = "$status $freeSeedsInfo $maxSunflower1Info $maxSunflower2Info $maxSunflower3Info";
    }
    else if (!pauseOn) {
      pause(MouseEvent(""));
      prompter.innerText = "Fin automatique de l'expérience.";
      autoEndProcess(maxSunflower1Csv, maxSunflower2Csv, maxSunflower3Csv);
    }
  }

  void watch(Timer t) {
    Duration elapsed = stopwatch.elapsed;
    final int minutes = elapsed.inMinutes%60;
    final int seconds = elapsed.inSeconds%60;
    final int hours = elapsed.inHours;
    String inHours = "";
    if (hours < 10) {
      inHours = "0$hours";
    }
    else {
      inHours = hours.toString();
    }
    String inMinutes = "";
    if (minutes < 10) {
      inMinutes = "0$minutes";
    }
    else {
      inMinutes = minutes.toString();
    }
    String inSeconds = "";
    if (seconds < 10) {
      inSeconds = "0$seconds";
    }
    else {
      inSeconds = seconds.toString();
    }

    String iterationInfo = "";
    if (isBatch) {
      iterationInfo = " $iterationNumber/$iterationsMax";
    }

    String chronoDisplay = "Durée de l'expérience$iterationInfo : $inHours:$inMinutes:$inSeconds";
    watcher.innerText = chronoDisplay;
  }

  void pause(MouseEvent event) {
    if (pauseOn) {
      pauseOn = false;
      stopwatch.start();
      svgSaveBtn.hidden = true;
    }
    else {
      pauseOn = true;
      stopwatch.stop();
      svgSaveBtn.hidden = false;
    }
    // ne pas rappeler le prompt en cas de pause automatique
    if (event.type != "") promptSituation(prompting!);
  }

  void stop(MouseEvent event) {
    pauseOn = false;
    svgSaveBtn.hidden = true;
    for (Sunflower sf in sunflowers) {
      sf.emptySeeds();
    }
    sunflowers.clear();

    if ((prompting != null) && (prompting!.isActive)) {
      prompting!.cancel();
      prompter.innerText = "Expérience arrêtée";
    }

    if ((watching != null) && (watching!.isActive)) {
      watching!.cancel();
      watcher.innerText = "Durée de l'expérience 00:00:00";
    }

    stopwatch.stop();

    if ((csvLinesOutput.innerText != "") && (event.type != "")) {
      csvSaveBtn.hidden = false;
    }

    sliderGroup0.disabled = false;
    sliderGroup1.disabled = false;
    sliderGroup2.disabled = false;
    sliderGroup3.disabled = false;
    sliderGroup4.disabled = false;
    sliderGroup5.disabled = false;
    sliderGroup6.disabled = false;
    sliderByGroup.disabled = false;

    sliderEquality.disabled = false;
    sliderDiversity.disabled = false;
    sliderInclusion.disabled = false;
    inverseEquality.disabled = false;
    inverseInclusion.disabled = false;

    scaleWorldXS.disabled = false;
    scaleWorldS.disabled = false;
    scaleWorldM.disabled = false;
    scaleWorldL.disabled = false;
    scaleWorldXL.disabled = false;
    worldPortrait.disabled = false;

    batchMode.disabled = false;
    batchIterations.disabled = false;
    batchAutoEnding.disabled = false;
    batchFinalEnding.disabled = false;
  }

  void svgDownload(MouseEvent event) {
    final data = toSvg();
    final blob = Blob([data], "image/svg+xml");
    final url = Url.createObjectUrlFromBlob(blob);
    final AnchorElement a = AnchorElement();
    a.href = url;
    a.download = "edilab.svg";
    batchResult.append(a);
    a.click();
    batchResult.lastChild?.remove();
    Url.revokeObjectUrl(url);
  }

  void csvDownload(MouseEvent event) {
    if (csvLinesOutput.innerText != "") {
      final data = csvLinesOutput.innerText;
      final blob = Blob([data], "text/csv");
      final url = Url.createObjectUrlFromBlob(blob);
      final AnchorElement a = AnchorElement();
      a.href = url;
      a.download = "edilab.csv";
      batchResult.append(a);
      a.click();
      batchResult.lastChild?.remove();
      Url.revokeObjectUrl(url);
    }
    else {
      csvLinesOutput.innerText = "Contenu vide !";
    }
  }

  void autoEndProcess(String max1csv, String max2csv, String max3csv) {
    List<int> allColors = [0, 0, 0, 0, 0, 0, 0];
    double massTotal = 0;
    int nbGroups = 0;
    for (Sunflower sf in sunflowers) {
      massTotal += sf.mass;
      if (sf.mass > 1) nbGroups += 1;
      int i = 0;
      for (int color in sf.groups) {
        allColors[i] += color;
        i++;
      }
    }

    final initialGroupsHeaders = "${Seed.colorsFr[0]} début;${Seed.colorsFr[1]} début;${Seed.colorsFr[2]} début;${Seed.colorsFr[3]} début;${Seed.colorsFr[4]} début;${Seed.colorsFr[5]} début;${Seed.colorsFr[6]} début;par groupes";
    final endingGroupsHeaders = "${Seed.colorsFr[0]} fin;${Seed.colorsFr[1]} fin;${Seed.colorsFr[2]} fin;${Seed.colorsFr[3]} fin;${Seed.colorsFr[4]} fin;${Seed.colorsFr[5]} fin;${Seed.colorsFr[6]} fin";
    final ediSettingsHeaders = "égalité;inversée;diversité;inclusion;inversée";
    final initialGroups = "${sliderGroup0.value};${sliderGroup1.value};${sliderGroup2.value};${sliderGroup3.value};${sliderGroup4.value};${sliderGroup5.value};${sliderGroup6.value};${sliderByGroup.value}";
    final endingGroups = "${allColors[0]};${allColors[1]};${allColors[2]};${allColors[3]};${allColors[4]};${allColors[5]};${allColors[6]}";
    final ediSettings = "${sliderEquality.value};${inverseEquality.checked};${sliderDiversity.value};${sliderInclusion.value};${inverseEquality.checked}";

    String sizeSetting = "";
    if (scaleWorldXL.checked!) {
      sizeSetting = "XL";
    }
    else if (scaleWorldL.checked!) {
      sizeSetting = "L";
    }
    else if (scaleWorldM.checked!) {
      sizeSetting = "M";
    }
    else if (scaleWorldS.checked!) {
      sizeSetting = "S";
    }
    else if (scaleWorldXS.checked!) {
      sizeSetting = "XS";
    }

    final DateTime dayhour = DateTime.now();

    final endingGlobalsHeaders = "taille;nombre de groupes;masse totale;durée minutes;date et heure";
    final max1headers = "groupe 1 couleur;groupe 1 masse;groupe 1 rayon;groupe 1 diversité";
    final max2headers = "groupe 2 couleur;groupe 2 masse;groupe 2 rayon;groupe 2 diversité";
    final max3headers = "groupe 3 couleur;groupe 3 masse;groupe 3 rayon;groupe 3 diversité";
    final endingGlobals = "$sizeSetting;$nbGroups;${massTotal.round()};${stopwatch.elapsed.inMinutes};${dayhour.toIso8601String()}";
    final csvHeaders = "$initialGroupsHeaders;$ediSettingsHeaders;$endingGroupsHeaders;$endingGlobalsHeaders;$max1headers;$max2headers;$max3headers";
    final csvLine = "$initialGroups;$ediSettings;$endingGroups;$endingGlobals;$max1csv;$max2csv;$max3csv";

    if (iterationNumber == 1) {
      csvLinesOutput.innerText = csvHeaders;
      var th = tableOutput.createTHead();
      th.insertRow(-1)..insertCell(0).text = "${Seed.colorsFr[0]} début"
        ..insertCell(1).text = "${Seed.colorsFr[1]} début"
        ..insertCell(2).text = "${Seed.colorsFr[2]} début"
        ..insertCell(3).text = "${Seed.colorsFr[3]} début"
        ..insertCell(4).text = "${Seed.colorsFr[4]} début"
        ..insertCell(5).text = "${Seed.colorsFr[5]} début"
        ..insertCell(6).text = "${Seed.colorsFr[6]} début"
        ..insertCell(7).text = "par groupes"
        ..insertCell(8).text = "égalité"
        ..insertCell(9).text = "inversée"
        ..insertCell(10).text = "diversité"
        ..insertCell(11).text = "inclusion"
        ..insertCell(12).text = "inversée"
        ..insertCell(13).text = "${Seed.colorsFr[0]} fin"
        ..insertCell(14).text = "${Seed.colorsFr[1]} fin"
        ..insertCell(15).text = "${Seed.colorsFr[2]} fin"
        ..insertCell(16).text = "${Seed.colorsFr[3]} fin"
        ..insertCell(17).text = "${Seed.colorsFr[4]} fin"
        ..insertCell(18).text = "${Seed.colorsFr[5]} fin"
        ..insertCell(19).text = "${Seed.colorsFr[6]} fin"
        ..insertCell(20).text = "taille"
        ..insertCell(21).text = "nombre de groupes"
        ..insertCell(22).text = "masse totale"
        ..insertCell(23).text = "durée minutes"
        ..insertCell(24).text = "date et heure"
        ..insertCell(25).text = "groupe 1 couleur"
        ..insertCell(26).text = "groupe 1 masse"
        ..insertCell(27).text = "groupe 1 rayon"
        ..insertCell(28).text = "groupe 1 diversité"
        ..insertCell(29).text = "groupe 2 couleur"
        ..insertCell(30).text = "groupe 2 masse"
        ..insertCell(31).text = "groupe 2 rayon"
        ..insertCell(32).text = "groupe 2 diversité"
        ..insertCell(33).text = "groupe 3 couleur"
        ..insertCell(34).text = "groupe 3 masse"
        ..insertCell(35).text = "groupe 3 rayon"
        ..insertCell(36).text = "groupe 3 diversité";

      for (var i=0; i<37; i++) {
        th.rows[0].cells[i].attributes["scope"] = "col";
      }

      var tb = tableOutput.createTBody();
      var tf = tableOutput.createTFoot();
      tf.insertRow(-1);
      for (var i=0; i<37; i++) {
        tf.rows[0].insertCell(i);
      }
    }

    final List<String> g1m = max1csv.split(";");
    final List<String> g2m = max2csv.split(";");
    final List<String> g3m = max3csv.split(";");
    tableOutput.tBodies[0].insertRow(-1)..insertCell(0).text = sliderGroup0.value
      ..insertCell(1).text = sliderGroup1.value
      ..insertCell(2).text = sliderGroup2.value
      ..insertCell(3).text = sliderGroup3.value
      ..insertCell(4).text = sliderGroup4.value
      ..insertCell(5).text = sliderGroup5.value
      ..insertCell(6).text = sliderGroup6.value
      ..insertCell(7).text = sliderByGroup.value
      ..insertCell(8).text = sliderEquality.value
      ..insertCell(9).text = inverseEquality.checked.toString()
      ..insertCell(10).text = sliderDiversity.value
      ..insertCell(11).text = sliderInclusion.value
      ..insertCell(12).text = inverseInclusion.checked.toString()
      ..insertCell(13).text = allColors[0].toString()
      ..insertCell(14).text = allColors[1].toString()
      ..insertCell(15).text = allColors[2].toString()
      ..insertCell(16).text = allColors[3].toString()
      ..insertCell(17).text = allColors[4].toString()
      ..insertCell(18).text = allColors[5].toString()
      ..insertCell(19).text = allColors[6].toString()
      ..insertCell(20).text = sizeSetting
      ..insertCell(21).text = nbGroups.toString()
      ..insertCell(22).text = massTotal.round().toString()
      ..insertCell(23).text = stopwatch.elapsed.inMinutes.toString()
      ..insertCell(24).text = dayhour.toIso8601String()
      ..insertCell(25).text = g1m[0]
      ..insertCell(26).text = g1m[1]
      ..insertCell(27).text = g1m[2]
      ..insertCell(28).text = g1m[3]
      ..insertCell(29).text = g2m[0]
      ..insertCell(30).text = g2m[1]
      ..insertCell(31).text = g2m[2]
      ..insertCell(32).text = g2m[3]
      ..insertCell(33).text = g3m[0]
      ..insertCell(34).text = g3m[1]
      ..insertCell(35).text = g3m[2]
      ..insertCell(36).text = g3m[3];

    int debut0 = 0;
    int debut1 = 0;
    int debut2 = 0;
    int debut3 = 0;
    int debut4 = 0;
    int debut5 = 0;
    int debut6 = 0;
    int fin0 = 0;
    int fin1 = 0;
    int fin2 = 0;
    int fin3 = 0;
    int fin4 = 0;
    int fin5 = 0;
    int fin6 = 0;
    int nSf = 0;
    int mSf = 0;
    int elapsedExp = 0;
    int gr1m = 0;
    int gr1r = 0;
    int gr1d = 0;
    int gr1iterations = 0;
    int gr2m = 0;
    int gr2r = 0;
    int gr2d = 0;
    int gr2iterations = 0;
    int gr3m = 0;
    int gr3r = 0;
    int gr3d = 0;
    int gr3iterations = 0;

    for (TableRowElement r in tableOutput.tBodies[0].rows) {
      debut0 += int.parse(r.cells[0].innerText);
      debut1 += int.parse(r.cells[1].innerText);
      debut2 += int.parse(r.cells[2].innerText);
      debut3 += int.parse(r.cells[3].innerText);
      debut4 += int.parse(r.cells[4].innerText);
      debut5 += int.parse(r.cells[5].innerText);
      debut6 += int.parse(r.cells[6].innerText);
      fin0 += int.parse(r.cells[13].innerText);
      fin1 += int.parse(r.cells[14].innerText);
      fin2 += int.parse(r.cells[15].innerText);
      fin3 += int.parse(r.cells[16].innerText);
      fin4 += int.parse(r.cells[17].innerText);
      fin5 += int.parse(r.cells[18].innerText);
      fin6 += int.parse(r.cells[19].innerText);
      nSf += int.parse(r.cells[21].innerText);
      mSf += int.parse(r.cells[22].innerText);
      elapsedExp += int.parse(r.cells[23].innerText);
      if (r.cells[26].innerText != "") {
        gr1m += int.parse(r.cells[26].innerText);
        gr1iterations++;
      }
      if (r.cells[27].innerText != "") gr1r += int.parse(r.cells[27].innerText);
      if (r.cells[28].innerText != "") gr1d += int.parse(r.cells[28].innerText);
      if (r.cells[30].innerText != "") {
        gr2m += int.parse(r.cells[30].innerText);
        gr2iterations++;
      }
      if (r.cells[31].innerText != "") gr2r += int.parse(r.cells[31].innerText);
      if (r.cells[32].innerText != "") gr2d += int.parse(r.cells[32].innerText);
      if (r.cells[34].innerText != "") {
        gr3m += int.parse(r.cells[34].innerText);
        gr3iterations++;
      }
      if (r.cells[35].innerText != "") gr3r += int.parse(r.cells[35].innerText);
      if (r.cells[36].innerText != "") gr3d += int.parse(r.cells[36].innerText);
    }

    tableOutput.tFoot!.rows[0].cells[0].innerText = (debut0/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[1].innerText = (debut1/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[2].innerText = (debut2/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[3].innerText = (debut3/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[4].innerText = (debut4/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[5].innerText = (debut5/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[6].innerText = (debut6/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[13].innerText = (fin0/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[14].innerText = (fin1/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[15].innerText = (fin2/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[16].innerText = (fin3/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[17].innerText = (fin4/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[18].innerText = (fin5/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[19].innerText = (fin6/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[21].innerText = ((nSf*100/iterationNumber).round()/100).toString();
    tableOutput.tFoot!.rows[0].cells[22].innerText = (mSf/iterationNumber).round().toString();
    tableOutput.tFoot!.rows[0].cells[23].innerText = "${(elapsedExp/iterationNumber).floor()}' ${(((elapsedExp/iterationNumber)%1)*60).round()}''";
    if (gr1iterations > 0) {
      tableOutput.tFoot!.rows[0].cells[26].innerText = (gr1m/gr1iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[27].innerText = (gr1r/gr1iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[28].innerText = (gr1d/gr1iterations).round().toString();
    }
    if (gr2iterations > 0) {
      tableOutput.tFoot!.rows[0].cells[30].innerText = (gr2m/gr2iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[31].innerText = (gr2r/gr2iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[32].innerText = (gr2d/gr2iterations).round().toString();
    }
    if (gr3iterations > 0) {
      tableOutput.tFoot!.rows[0].cells[34].innerText = (gr3m/gr3iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[35].innerText = (gr3r/gr3iterations).round().toString();
      tableOutput.tFoot!.rows[0].cells[36].innerText = (gr3d/gr3iterations).round().toString();
    }
    

    csvLinesOutput.innerText += String.fromCharCode(13);
    csvLinesOutput.innerText += csvLine;



    final LIElement screenItem = LIElement();

    final SpanElement dh = SpanElement();
    String dateStr = dayhour.toIso8601String().substring(0, 19);
    dateStr = dateStr.replaceAll(RegExp(r'T'), "_");
    dateStr = dateStr.replaceAll(RegExp(r'-'), "");
    dateStr = dateStr.replaceAll(RegExp(r':'), "");
    dh.innerText = dateStr;

    // prendre un screenshot
    String dataStr = "";
    if (Sunflower.blindOn) {
      Sunflower.blindOn = false;
      draw();
      dataStr = _canvas.toDataUrl('image/jpeg', 0.92);
      Sunflower.blindOn = true;
    }
    else {
      dataStr = _canvas.toDataUrl('image/jpeg', 0.92);
    }
    final ImageElement sc = ImageElement();
    sc.width = _width;
    sc.height = _height;
    sc.src = dataStr;

    // ajouter le screenshot à la liste
    screenItem.append(sc);
    screenItem.append(BRElement());
    screenItem.append(dh);
    screenResult.append(screenItem);

    if (iterationNumber < iterationsMax) {
      iterationNumber++;
      start(MouseEvent(""));
    }
    else {
      stop(MouseEvent(""));
      final StringBuffer sb = StringBuffer(String.fromCharCode(13));
      sb.write(tableOutput.tFoot!.rows[0].cells[0].innerText);
      for (var i=1; i<36; i++) {
        sb..write(";")
            ..write(tableOutput.tFoot!.rows[0].cells[i].innerText);
      }
      csvLinesOutput.innerText += sb.toString();
      csvSaveBtn.hidden = false;
    }
  }

  String toSvg() {
    final buffer = StringBuffer('<svg viewBox="0 0 $_width $_height" xmlns="http://www.w3.org/2000/svg">');
    buffer..write(String.fromCharCode(13))
          ..write('<rect x="0" y="0" width="$_width" height="$_height" fill="black" />')
          ..write(String.fromCharCode(13));

    for (Sunflower sf in sunflowers) {
      buffer.write(sf.toSvg());
    }

    buffer..write(String.fromCharCode(13))
          ..write("</svg>");
    return buffer.toString();
  }

  void goFullscreen(MouseEvent event) {
    _canvas.requestFullscreen();
  }

  void addRandomSunflower(int seedsMax, int colorIndex) {
    final Sunflower sf = Sunflower(sunflowerIndex++, _ctx2d);
    sunflowers.add(sf);
    for (var i = 0; i < seedsMax; i++) {
      final Seed s = Seed(i, colorIndex, _ctx2d);
      sf.addSeed(s);
    }

    sf.position.x = (_width * Random().nextDouble()).toDouble();
    sf.position.y = (_height * Random().nextDouble()).toDouble();

    double power = (sqrt(_height)/ ( _scaleWorld * min(2, 1 + (seedsMax / 10))));

    sf.velocity = Vector2.random() * (Random().nextDouble() - 0.5) * power;
    sf.velocityAngular = 0.02 - ((4 * Random().nextDouble())/100);
  }

  void launchNewSunflowers(int sunflowersMax, Vector2 position, double radius, int colorIndex, int colorIndex2) {
    int color = colorIndex;
    for (var i = 0; i < sunflowersMax; i++) {
      double orientation = 2 * pi * Random().nextDouble();
      double power = (1.5+(Random().nextDouble()))*(sqrt(_height) / (10*radius));
      Vector2 launchPosition = position + Vector2((radius)*cos(orientation), (radius)*sin(orientation));

      final Sunflower sf = Sunflower(sunflowerIndex++, _ctx2d);
      newSunflowers.add(sf);
      sf.position = launchPosition;
      sf.velocity = (launchPosition - position) * power;
      sf.velocityAngular = 0.05 - ((Random().nextDouble())/10);
      if (i%2 == 0) {
        color = colorIndex;
      }
      else {
        color = colorIndex2;
      }
      final Seed s = Seed(1, color, _ctx2d);
      sf.addSeed(s);
    }
  }

  void draw() {
    _ctx2d.clearRect(0, 0, _width, _height);
    // recalculer à chaque fois car ça peut baisser.
    Sunflower.currentMaxSize = 0;
    Sunflower.currentMaxSize2 = 0;
    Sunflower.currentMaxSize3 = 0;
    freeSeeds = [0, 0, 0, 0, 0, 0, 0];
    // calcul des collisions, purges et inclusions
    for (Sunflower sf in sunflowers) {
      if (sf.mass > 0) {
        sf.updatePosition();
        for (Sunflower sh in sunflowers) {
          // traiter les collisions
          if ((sf.index < sh.index) && (sh.birthCountdown == 0) && (!sh.purgeOn) && (!sf.fusionOn) && (!sf.purgeOn) && (!sh.fusionOn)) {
            int hit = sf.hitTestSunflower(sh);
            if (hit != 0) {
              // cas du rebond élestique avec trois possibilités
              // cas de la fusion
              if (hit == 2) {
                if (sf.mass >= sh.mass) {
                  sf.fusionOn = true;
                  sf.birthCountdown = 5;
                  sf.waitingSeeds = sh.seeds;
                  // calcul de la diversité avant la fusion permet de savoir la couleur dominante.
                  sf.diversity = sf.calcDiversity(null);
                  sf.seedsToAddFirst = (sf.waitingSeeds.length * (1 - Sunflower.equalityMax)).round();
                  // l'échange des index sert en cas d'arrêt prématuré de la fusion
                  sf.relativeIndex = sh.index;
                  sh.relativeIndex = sf.index;
                  sh.birthCountdown = 5;
                  sh.purgeOn = true;
                  ticSound.volume = max(0.05, min(1, sh.mass/20));
                }
                else {
                  sh.fusionOn = true;
                  sh.birthCountdown = 5;
                  sh.waitingSeeds = sf.seeds;
                  // calcul de la diversité avant la fusion permet de savoir la couleur dominante.
                  sh.diversity = sh.calcDiversity(null);
                  sh.seedsToAddFirst = (sh.waitingSeeds.length * (1 - Sunflower.equalityMax)).round();
                  // l'échange des index sert en cas d'arrêt prématuré de la fusion
                  sh.relativeIndex = sf.index;
                  sf.relativeIndex = sh.index;
                  sf.birthCountdown = 5;
                  sf.purgeOn = true;
                  ticSound.volume = max(0.05, min(1, sf.mass/20));
                }
                if (audioOn) ticSound.play();
              }
              // cas du rejet
              else if (hit == 3) {
                int lastColor = -1;
                if (sh.mass > 0) lastColor = sh.seeds.last.colorIndex;
                int newFriction = (Random().nextDouble()).round();
                if ((newFriction > 0) && (lastColor >= 0)) launchNewSunflowers(newFriction, sh.position, sh.radius + 5, lastColor, lastColor);
                lastColor = -1;
                if (sf.mass > 0) lastColor = sf.seeds.last.colorIndex;
                newFriction = (Random().nextDouble()).round();
                if ((newFriction > 0) && (lastColor >= 0)) launchNewSunflowers(newFriction, sf.position, sf.radius + 5, lastColor, lastColor);
                sh.substractSeeds(1);
                sf.substractSeeds(1);

                tocSound.volume = max(0.05, min(1, min(sh.mass, sf.mass)/20));
                if (audioOn) tocSound.play();
              }
              // cas du hit neutre car la plus sunflower taille max.
              else {
                tacSound.volume = max(0.05, min(1, min(sh.mass, sf.mass)/20));
                if (audioOn) tacSound.play();
                // pour supprimer les tout petits groupes qui restent.
                if (sh.mass < 3) {
                  emptySfIndex.add(sh.index);
                }
              }
            }
          }
        }

        // traiter la purge ou l'inclusion

        if (sf.fusionOn) {
          if (sf.radius <= Sunflower.radiusMax) {
            sf.fusionSeeds((sf.waitingSeeds.length/10).ceil());
          }
          else {
            sf.fusionOn = false;
            // il faut aussi arrêter la purge du sunflower correspondant
            if (sf.relativeIndex != null) {
              try {
                Sunflower? sfPurge = sunflowers.firstWhere((sunflower) =>
                sunflower.index == sf.relativeIndex);
                sfPurge.relativeIndex = null;
              } catch (e) {
                sf.relativeIndex = null;
              }
            }
          }
          if (!sf.fusionOn) {
            final colorIndex = sf.getRandomColorIndex();
            if (colorIndex != null) {
              // we need sometimes 2 new sunflowers to grow the population
              final newMax = (Random().nextDouble() * 1.5).ceil();
              if (newMax > 1) {
                final colorIndex2 = sf.getRandomColorIndex();
                if (colorIndex2 != null) {
                  launchNewSunflowers(newMax, sf.position, sf.radius + 5, colorIndex, colorIndex2);
                }
                else {
                  launchNewSunflowers(newMax, sf.position, sf.radius + 5, colorIndex, colorIndex);
                }
              }
              else {
                launchNewSunflowers(newMax, sf.position, sf.radius + 5, colorIndex, colorIndex);
              }
            }
          }
        }
        else if (sf.purgeOn) {
          if (sf.relativeIndex != null) {
            sf.substractSeeds((sf.mass/10).ceil());
          }
          else {
            // en cas de perte de relativeIndex la purge doit s'arrêter
            sf.purgeOn = false;
            // pour terminer proprement il faut vérifier que tout n'a pas déjà été aspiré juste avant.
            if (sf.seeds.isEmpty) {
              sf.emptySeeds();
            }
            else {
              sf.recountSeeds();
            }
          }
        }
        else if (sf.mass == 1) {
          // calcul des sunfolwers avec une seule seed
          freeSeeds[sf.seeds.first.colorIndex] += 1;
        }

        if (sf.mass > 0) {
          sf.draw();
        }

        if (sf.mass >= Sunflower.currentMaxSize) {
          Sunflower.currentMaxSize3 = Sunflower.currentMaxSize2;
          Sunflower.currentMaxSizeIndex3 = Sunflower.currentMaxSizeIndex2;
          Sunflower.currentMaxSize2 = Sunflower.currentMaxSize;
          Sunflower.currentMaxSizeIndex2 = Sunflower.currentMaxSizeIndex;
          Sunflower.currentMaxSize = sf.mass.round();
          Sunflower.currentMaxSizeIndex = sf.index;
        }
        else if (sf.mass >= Sunflower.currentMaxSize2) {
          Sunflower.currentMaxSize3 = Sunflower.currentMaxSize2;
          Sunflower.currentMaxSizeIndex3 = Sunflower.currentMaxSizeIndex2;
          Sunflower.currentMaxSize2 = sf.mass.round();
          Sunflower.currentMaxSizeIndex2 = sf.index;
        }
        else if (sf.mass >= Sunflower.currentMaxSize3) {
          Sunflower.currentMaxSize3 = sf.mass.round();
          Sunflower.currentMaxSizeIndex3 = sf.index;
        }
      }
      // le sunflower est vide, il faut le supprimer de la liste
      else {
        emptySfIndex.add(sf.index);
      }
    }
    // fin de l'itération sunflowers
    if (newSunflowers.length > 0) {
      sunflowers.addAll(newSunflowers);
      newSunflowers.clear();
    }
    if (emptySfIndex.length > 0) {
      for (int index in emptySfIndex) {
        sunflowers.removeWhere((sunflower) => sunflower.index == index);
      }
      emptySfIndex.clear();
    }
  }

  void refreshScreen(num delta) {
    num time = DateTime
        .now()
        .millisecondsSinceEpoch;
    if (_renderTime >= 0) {
      num fps = (1000 / (time - _renderTime));
    }
    _renderTime = time;
    if (!pauseOn) draw();

    window.animationFrame.then(refreshScreen);
  }

  void debug() {
    for (Sunflower sf in sunflowers) {
      print("Suflower: ${sf.index} ${sf.fusionOn} ${sf.waitingSeeds.length} ${sf.purgeOn}");
    }
  }

  void keyboardAction(KeyboardEvent event) {
    print("key pressed :  ${event.keyCode.toString()}");

    switch (event.keyCode) {
      /*
      case 112 : debug();
      break;

      case 97 : sunflowers.first.position.y -= 10;
      break;
      case 113 : sunflowers.first.position.y += 10;
      break;
      case 119 : sunflowers.first.position.x -= 10;
      break;
      case 120 : sunflowers.first.position.x += 10;
      break;*/
    }


  }

}