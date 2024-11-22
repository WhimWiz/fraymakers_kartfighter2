// STATE MACHINE
var currentState = 0;
var currentSubState = 0;
var MS_TITLE = 0;
var MS_FIGHTERSELECT = 1;
var MS_MATCH = 2;
var MS_RESULTS = 3;
var MS_CUTSCENE = 4;

// FIGHTER SELECT
var fighterSelectContext = 0;
var p1FighterChoice = 1;
var p2FighterChoice = 0;
var stageChoice = 0;
var p1Highlight:Sprite = null;
var p2Highlight:Sprite = null;
var p1Shader:PaletteSwapShader = null;
var p2Shader:PaletteSwapShader = null;
var p1costumeIndex:Int = null;
var p2costumeIndex:Int = null;
var costumeRange = 2;
// -----------------LOUIEG-MARI
var fighterIndexes = [1, 0, 2, 3];
var fighterSlotPosX = [189, 212, 239, 264];
var fighterSlotPosY = [163, 164, 163, 164];

var stageAnims = ["fighterselect_peachstage", "fighterselect_donkeystage", "fighterselect_maristage", "fighterselect_kinopiostage"];
var defaultCamY = 0;

var cutsceneToLoad = 0;
var cutsceneAnims = ["cut_arcadeintro"];
var cutsceneActive = false;

// MATCH
var roundStartTimer = 0;
var matchActive = false;
var timerActive = false;
var timerNumbers = [];
var timerCount = 0;
var p1Rounds = 0;
var p2Rounds = 0;
var p1ScoreMemory = 0;
var p2ScoreMemory = 0;
var winSlot = 0;
var timerScoreUp = false;

// GENERIC
var plyr1:Character = null;
var plyr2:Character = null;
var currentFighters:Array<Projectile> = [];
var currentMenuAssets:Array<Sprite> = [];
var animatedMenuAssets:Array<Sprite> = [];
var gameManager = self.makeObject(null);
var blackScreen:Vfx = null;
var currentMusic:AudioClip = null;
var dontReloadScene = false;

function initialize(){
	// Don't animate the stage itself (we'll pause on one version for hazards on, and another version for hazards off)
	self.pause();
	gameManager.set(match.createProjectile(self.getResource().getContent("gameManager"), null));
	gameManager.get().pause();

	Engine.log("letsago!");
	createMenuAssets(currentState);
	self.exports = {
		loadNewScreen: function(state){
			toState(state);
		},
		playMusic: playMusicTrack,
		generateNumToText: generateNumbers,
		getCurrentMenuAssets: function() : Array<Sprite> {
			return currentMenuAssets;
		},
		matchEndEvent: function(winnerSlot){
			winSlot = winnerSlot;
			timerScoreUp = true;
		},
		setMatchTimer: function(active){
			timerActive = active;
		},
		updateScoreMemory: function (slot, score){
			if(slot == 0){
				p1ScoreMemory = score;
			}
			else{
				p2ScoreMemory = score;
			}
		}
	};

	defaultCamY = self.getCameraBounds().getY();

	// PLAYS INTRO
	temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "intro"}), null);
	blackScreen = temp;
	camera.getForegroundContainer().addChild(temp.getSprite());
}

function update(){
	holdPlayers();
	if(blackScreen != null){
		updateBlackScreen();
	}
	updateStateOperations();
	if(animatedMenuAssets.length > 0){
		animateMenuAssets();
	}
}

function updateBlackScreen(){
	if(blackScreen.getAnimation() == "intro"){
		if(plyr1 != null && plyr1.getPressedControls().ATTACK && blackScreen.getCurrentFrame() < 720){
			blackScreen.playFrame(720);
		}
	}
	if(blackScreen.getAnimation() == "blackfadeout"){
		if(blackScreen.getCurrentFrame() == 28){
			if(!dontReloadScene){
				if(timerNumbers != null){
					for(i in 0...timerNumbers.length){
						timerNumbers[i].dispose();
					}
				}
				deleteMenuAssets();
				currentSubState = 0;
				createMenuAssets(currentState);
				blackScreen.dispose();
			}
			else{
				onBlackScreenLoad();
			}
			if(currentState == MS_MATCH){
				timerCount = 99;
			}
			dontReloadScene = false;
			var temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "blackfadein"}), null);
			blackScreen = temp;
			camera.getForegroundContainer().addChild(temp.getSprite());
		}
	}
	if(blackScreen.isDisposed()){
		if(currentState == MS_TITLE){
			playMusicTrack(0);
		}
		else if(currentState == MS_FIGHTERSELECT){
			playMusicTrack(1);
			self.getCameraBounds().setY(defaultCamY);
		}
		blackScreen = null;
	}
	else{
		return;
	}
}

function updateFighterSelection (subject:Sprite, choice: Int){
	subject.x = fighterSlotPosX[choice] * 1.5;
	subject.y = fighterSlotPosY[choice] * 1.5;
	subject.currentFrame = choice + 1;
	if(currentSubState < 1){
		p1costumeIndex = 0;
		updateFighterPalette(0, subject, p1costumeIndex);
	}
	else{
		p2costumeIndex = 0;
		if(p2FighterChoice == p1FighterChoice && p2costumeIndex == p1costumeIndex){
			p2costumeIndex += 1;
			if(p2costumeIndex > costumeRange){
				p2costumeIndex = 0;
			}
		}
		updateFighterPalette(1, subject, p2costumeIndex);
	}
}

function updateFighterPalette(plyrSlot: Int, highlight:Sprite, index: Int){
	if(plyrSlot < 1){
		if(p1Shader != null){
			highlight.removeShader(p1Shader);
		}
		p1Shader = getPaletteShader(p1costumeIndex);
		highlight.addShader(p1Shader);
	}
	else{
		if(p2Shader != null){
			highlight.removeShader(p2Shader);
		}
		p2Shader = getPaletteShader(p2costumeIndex);
		highlight.addShader(p2Shader);
	}
}

function updateTimer(numToAdd){
	timerCount += numToAdd; 
	if(timerNumbers != null){
		for(i in 0...timerNumbers.length){
			timerNumbers[i].dispose();
		}
		timerNumbers.resize(0);
	}
	generateNumbers(213 * 1.5 - 15.5, 8 * 1.5 + 7, 2, camera.getForegroundContainer(), timerNumbers, "" + Math.ceil(timerCount));
}

function progressMatch(){
	match.freezeScreen(80, [camera]);
	var temp:Vfx = null;
	if(winSlot == 0){
		p1Rounds++;
		temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "wintext1"}), null);
	}
	else if(winSlot > 0){
		p2Rounds++;
		temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "wintext2"}), null);
	}

	if(temp != null){
		temp.getSprite().scaleX = 1.5;
		temp.getSprite().scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp.getSprite());
	}

	if(p1Rounds >= 2 || p2Rounds >= 2){
		p1Rounds = 0;
		p2Rounds = 0;
		p1ScoreMemory = 0;
		p2ScoreMemory = 0;
		toState(MS_RESULTS);
	}
	else{
		toState(MS_MATCH);
	}
}

function timeOutEvent(){
	timerActive = false;
	currentFighters[0].resetMomentum();
	currentFighters[0].exports.changeState(-1);
	currentFighters[1].resetMomentum();
	currentFighters[1].exports.changeState(-1);
	var temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "timeouttext"}), null);
	temp.getSprite().scaleX = 1.5;
	temp.getSprite().scaleY = 1.5;
	camera.getForegroundContainer().addChild(temp.getSprite());
	if(currentFighters[0].getDamage() > currentFighters[1].getDamage()){
		progressMatch(1);
	}
	else if(currentFighters[1].getDamage() > currentFighters[0].getDamage()){
		progressMatch(0);
	}
	else{
		progressMatch(-1);
	}
}

function getPaletteShader(costumeIndex): PaletteSwapShader{
	gameManager.get().setCostumeIndex(costumeIndex);
	return gameManager.get().getCostumeShader();
}

function updateStateOperations(){
	if(currentState == MS_TITLE){
		if(blackScreen != null){
			return;
		}
		if(currentSubState > 0){
			if(plyr1.getPressedControls().UP){
				AudioClip.play(GlobalSfx.MENU_CLICK);
				currentSubState -= 1;
				if(currentSubState <= 0){
					currentSubState = 4;
				}
				toSubState(currentSubState);
			}
			else if(plyr1.getPressedControls().DOWN){
				AudioClip.play(GlobalSfx.MENU_CLICK);
				currentSubState += 1;
				if(currentSubState >= 5){
					currentSubState = 1;
				}
				toSubState(currentSubState);
			}
		}
		if(plyr1.getPressedControls().ATTACK){
			AudioClip.play(self.getResource().getContent("plup"));
			if(currentSubState == 0){
				currentMenuAssets[2].currentAnimation = "titlescreen_text2";
				currentSubState = 1;
			}
			else if(currentSubState == 1){
				fighterSelectContext = 1;
				toState(MS_FIGHTERSELECT);
			}
			else if(currentSubState == 2){
				fighterSelectContext = 0;
				toState(MS_FIGHTERSELECT);
			}
		}
	}
	else if(currentState == MS_FIGHTERSELECT){
		if(blackScreen != null){
			return;
		}
		if(currentSubState == 0){
			// RETURN
			if(plyr1.getPressedControls().SPECIAL || !plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().SPECIAL){
				toState(MS_TITLE);
				return;
			}
			// PROCEED
			if(plyr1.getPressedControls().ATTACK){
				AudioClip.play(self.getResource().getContent("plup"));
				if(fighterSelectContext == 0){
					updateFighterSelection(p2Highlight, p2FighterChoice);
					toSubState(1);
				}
				else{
					p2FighterChoice = 0;
					stageChoice = 2;
					cutsceneToLoad = 0;
					toState(MS_CUTSCENE);
				}
				return;
			}
			// SELECTING
			if(plyr1.getPressedControls().RIGHT){
				p1FighterChoice += 1;
				if(p1FighterChoice >= fighterIndexes.length){
					p1FighterChoice = fighterIndexes.length - 1;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				updateFighterSelection(p1Highlight, p1FighterChoice);
			}
			else if(plyr1.getPressedControls().LEFT){
				p1FighterChoice -= 1;
				if(p1FighterChoice < 0){
					p1FighterChoice = 0;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				updateFighterSelection(p1Highlight, p1FighterChoice);
			}
		}
		else if(currentSubState == 1){
			// RETURN
			if(plyr1.getPressedControls().SPECIAL || !plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().SPECIAL){
				updateFighterPalette(1, p2Highlight, 0);
				toSubState(0);
				return;
			}
			// PROCEED
			if(!plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().ATTACK || plyr2.getPlayerConfig().cpu && plyr1.getPressedControls().ATTACK){
				AudioClip.play(self.getResource().getContent("plup"));
				toSubState(2);
				return;
			}
			// SELECTING
			if(!plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().RIGHT || plyr2.getPlayerConfig().cpu && plyr1.getPressedControls().RIGHT){
				p2FighterChoice += 1;
				if(p2FighterChoice >= fighterIndexes.length){
					p2FighterChoice = fighterIndexes.length - 1;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				updateFighterSelection(p2Highlight, p2FighterChoice);
			}
			else if(!plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().LEFT || plyr2.getPlayerConfig().cpu && plyr1.getPressedControls().LEFT){
				p2FighterChoice -= 1;
				if(p2FighterChoice < 0){
					p2FighterChoice = 0;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				updateFighterSelection(p2Highlight, p2FighterChoice);
			}
		}
		else if(currentSubState == 2){
			// RETURN
			if(plyr1.getPressedControls().SPECIAL || !plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().SPECIAL){
				currentMenuAssets[3].alpha = 1;
				p1Highlight.alpha = 1;
				p2Highlight.alpha = 1;
				var scroll = currentMenuAssets[2].currentFrame;
				currentMenuAssets[2].currentAnimation = "fighterselect_scrollingtext1";
				currentMenuAssets[2].currentFrame = scroll;
				currentMenuAssets[1].currentAnimation = "fighterselect_selectfightertext";
				currentMenuAssets[3].currentAnimation = "fighterselect_fighterbacking";
				toSubState(1);
				return;
			}
			// PROCEED
			if(plyr1.getPressedControls().ATTACK){
				p1ScoreMemory = 0;
				p2ScoreMemory = 0;
				toState(MS_MATCH);
				return;
			}
			// SELECTING
			if(!plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().RIGHT || plyr1.getPressedControls().RIGHT){
				stageChoice += 1;
				if(stageChoice >= stageAnims.length){
					stageChoice = stageAnims.length - 1;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				currentMenuAssets[3].currentAnimation = stageAnims[stageChoice];
			}
			else if(!plyr2.getPlayerConfig().cpu && plyr2.getPressedControls().LEFT || plyr1.getPressedControls().LEFT){
				stageChoice -= 1;
				if(stageChoice < 0){
					stageChoice = 0;
				}
				else{
					AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				}
				currentMenuAssets[3].currentAnimation = stageAnims[stageChoice];
			}
		}
	}
	else if(currentState == MS_MATCH){
		if(timerCount <= 0 && timerActive){
			timeOutEvent();
			timerCount = 99;
		}
		else if(roundStartTimer >= 0){
			roundStartTimer--;
		}
		else if(!matchActive){
			roundStartTimer = 0;
			for(i in 0...currentFighters.length){
				currentFighters[i].exports.setControlState(true);
			}
			playMusicTrack(stageChoice + 2);
			timerActive = true;
			matchActive = true;
		}
		if(timerActive && blackScreen == null){
			updateTimer(-0.0125);
		}
		else if(timerScoreUp){
			if(timerCount < 0){
				timerCount = 0;
				timerScoreUp = false;
				progressMatch();
			}
			else{
				updateTimer(-1);
				currentFighters[winSlot].exports.addScore(50);
				AudioClip.play(GlobalSfx.MENU_CLICK);
			}
		}
	}
	else if(currentState == MS_RESULTS){
		if(blackScreen != null){
			return;
		}
		if(plyr1.getPressedControls().ATTACK){
			AudioClip.play(self.getResource().getContent("accept"));
			toState(MS_FIGHTERSELECT);
		}
	}
	else if(currentState == MS_CUTSCENE){
		if(!cutsceneActive){
			return;
		}
		if(animatedMenuAssets[0].currentFrame >= animatedMenuAssets[0].totalFrames - 15){
			cutsceneActive = false;
			toState(MS_MATCH);
		}
	}
}

function toState(state){
	currentState = state;
	temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "blackfadeout"}), null);
	blackScreen = temp;
	camera.getForegroundContainer().addChild(temp.getSprite());
	if(currentState == MS_MATCH){
		if(currentMusic != null){
			currentMusic.stop();
		}
		matchActive = false;
		roundStartTimer = 132;
	}
}

function toSubState(subState){
	currentSubState = subState;
	if(currentState == MS_TITLE){
		if(currentSubState == 0){
			currentMenuAssets[2].currentAnimation = "titlescreen_text1";
		}
		else if(currentSubState == 1){
			currentMenuAssets[2].currentAnimation = "titlescreen_text2";
		}
		else if(currentSubState == 2){
			currentMenuAssets[2].currentAnimation = "titlescreen_text3";
		}
		else if(currentSubState == 3){
			currentMenuAssets[2].currentAnimation = "titlescreen_text4";
		}
		else if(currentSubState == 4){
			currentMenuAssets[2].currentAnimation = "titlescreen_text5";
		}
	}
	else if(currentState == MS_FIGHTERSELECT){
		if(currentSubState == 0){
			p2Highlight.alpha = 0;
		}
		else if(currentSubState == 1){
			p2Highlight.alpha = 1;
		}
		else if(currentSubState == 2){
			p1Highlight.alpha = 0;
			p2Highlight.alpha = 0;
			currentMenuAssets[3].currentAnimation = stageAnims[stageChoice];
			var scroll = currentMenuAssets[2].currentFrame;
			currentMenuAssets[2].currentAnimation = "fighterselect_scrollingtext2";
			currentMenuAssets[2].currentFrame = scroll;
			currentMenuAssets[1].currentAnimation = "fighterselect_selectstagetext";
		}
	}
}

function onBlackScreenLoad(state){
	if(state == MS_MATCH){
		for(i in 0...currentFighters.length){
			currentFighters[i].setX(130 * i == 0 ? -1 : 1);
			currentFighters[i].setY(84);
			currentFighters[i].setDamage(0);
			currentFighters[i].exports.changeState(0);
			currentFighters[i].exports.setControlState(true);
		}
	}
}

function createMenuAssets(state){
	var temp:Sprite = null;
	if(state == MS_TITLE){
		// 0 - BACKGROUND
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "titlescreen_background";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 1 - KART FIGHTER LOGO
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "titlescreen_title";
		temp.x = 167;
		temp.y = 50;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// OPTION TEXTS
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "titlescreen_text1";
		temp.x = 290;
		temp.y = 200;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
	}
	else if(currentState == MS_FIGHTERSELECT){
		// 0 - BACKGROUND
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_background";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// 1 - SELECT FIGHTER TEXT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_selectfightertext";
		temp.x = 115 * 1.5;
		temp.y = 7 * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 2 - SCROLLING TEXT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_scrollingtext1";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 3 - FIGHTER B/W STAND
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_fighterbacking";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 4 - P1 HIGHLIGHT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_fightersP1";
		temp.currentFrame = p1FighterChoice + 1;
		temp.x = fighterSlotPosX[p1FighterChoice] * 1.5;
		temp.y = fighterSlotPosY[p1FighterChoice] * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		p1Highlight = temp;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// 5 - P2 HIGHTLIGHT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterselect_fightersP2";
		temp.currentFrame = p2FighterChoice + 1;
		temp.alpha = 0;
		temp.x = fighterSlotPosX[p2FighterChoice] * 1.5;
		temp.y = fighterSlotPosY[p2FighterChoice] * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		p2Highlight = temp;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
	}
	else if(currentState == MS_MATCH){
		spawnStageDecor(stageChoice);
		var fighter1 = spawnFighter(fighterIndexes[p1FighterChoice], match.getCharacters()[0], -130);
		var fighter2 = spawnFighter(fighterIndexes[p2FighterChoice], match.getCharacters()[1], 130);
		fighter1.exports.setPlyrSlot(0);
		fighter2.exports.setPlyrSlot(1);
		fighter1.exports.createHUDelements(0, p1ScoreMemory, p1Rounds);
		fighter2.exports.createHUDelements(1, p2ScoreMemory, p2Rounds);
		fighter1.exports.setFoe(fighter2);
		fighter2.exports.setFoe(fighter1);
		fighter1.exports.setControlState(false);
		fighter2.exports.setControlState(false);
		currentFighters.push(fighter1);
		currentFighters.push(fighter2);

		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "time";
		temp.x = 213 * 1.5;
		temp.y = 8 * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);

		if(p1Rounds + p2Rounds == 0){
			temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "roundtext1"}), null);
		}
		else if(p1Rounds + p2Rounds == 1){
			temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "roundtext2"}), null);
		}
		else{
			temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("kartfight"), animation: "roundtext3"}), null);
		}
		temp.getSprite().scaleX = 1.5;
		temp.getSprite().scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp.getSprite());

		generateNumbers(213 * 1.5 - 15.5, 8 * 1.5 + 7, 2, camera.getForegroundContainer(), timerNumbers, "" + 99);
	}
	else if(currentState == MS_RESULTS){
		playMusicTrack(13);
		// 0 - BACKGROUND
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "resultsscreen_background";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 1 - PORTRAIT 1
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterportraits";
		temp.currentFrame = fighterIndexes[p1FighterChoice] + 1;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// 2 - PORTRAIT 2
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "fighterportraits";
		temp.currentFrame = fighterIndexes[p2FighterChoice] + 1;
		temp.x = 426.26 * 1.5;
		temp.scaleX = -1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// 3 - OVERLAY
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "resultsscreen_overlay";
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		// 4 - SCROLLING TEXT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		if(winSlot < 1){
			temp.currentAnimation = "resultsscreen_scrollingtext1";
		}
		else{
			temp.currentAnimation = "resultsscreen_scrollingtext2";
		}
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 5 - RESULTS TEXT
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "resultsscreen_resultstext";
		temp.x = 100 * 1.5;
		temp.y = 5 * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		// 6 - P1 QUOTE
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		if(winSlot < 1){
			temp.currentAnimation = getPrefixFromIndex(fighterIndexes[p1FighterChoice]) + "winquotes";
		}
		else{
			temp.currentAnimation = getPrefixFromIndex(fighterIndexes[p1FighterChoice]) + "losequotes";
		}
		temp.currentFrame = Random.getInt(1, temp.totalFrames);
		temp.x = 85 * 1.5;
		temp.y = 205 * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);

		// 6 - P2 QUOTE
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		if(winSlot >= 1){
			temp.currentAnimation = getPrefixFromIndex(fighterIndexes[p2FighterChoice]) + "winquotes";
		}
		else{
			temp.currentAnimation = getPrefixFromIndex(fighterIndexes[p2FighterChoice]) + "losequotes";
		}
		temp.currentFrame = Random.getInt(1, temp.totalFrames);
		temp.x = 342 * 1.5;
		temp.y = 205 * 1.5;
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
	}
	else if(currentState == MS_CUTSCENE){
		// 0 - BACKGROUND
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.scaleX = 1.5;
		temp.scaleY = 1.5;
		camera.getForegroundContainer().addChild(temp);
		currentMenuAssets.push(temp);
		animatedMenuAssets.push(temp);
		cutsceneActive = true;
		if(cutsceneToLoad == 0){
			temp.currentAnimation = "cut_arcadeintro";
		}
	}
}

function animateMenuAssets(){
	for(i in 0...animatedMenuAssets.length){
		animatedMenuAssets[i].advance();
	}
}

function deleteMenuAssets(){
	if(currentMenuAssets.length > 0){
		for(a in 0...currentMenuAssets.length){
			currentMenuAssets[a].dispose();
		}
		currentMenuAssets.resize(0);
		animatedMenuAssets.resize(0);
	}
	if(currentFighters.length > 0){
		for(a in 0...currentFighters.length){
			currentFighters[a].destroy();
		}
		currentFighters.resize(0);
	}
}

function playMusicTrack(trackIndex){
	Engine.log("Playing Track...");
	if(currentMusic != null){
		currentMusic.stop();
	}
	if(trackIndex == 0){
		currentMusic = AudioClip.play(self.getResource().getContent("title_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 1){
		currentMusic = AudioClip.play(self.getResource().getContent("fighterselect_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 2){
		currentMusic = AudioClip.play(self.getResource().getContent("peachstage_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 3){
		currentMusic = AudioClip.play(self.getResource().getContent("donkeystage_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 4){
		currentMusic = AudioClip.play(self.getResource().getContent("maristage_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 5){
		currentMusic = AudioClip.play(self.getResource().getContent("kinopiostage_music"), {channel: "bgm", loop: true});
	}
	else if(trackIndex == 12){
		currentMusic = AudioClip.play(self.getResource().getContent("victory_music"), {channel: "bgm", loop: false});
	}
	else if(trackIndex == 13){
		currentMusic = AudioClip.play(self.getResource().getContent("results_music"), {channel: "bgm", loop: true});
	}
}

function getPrefixFromIndex(index: Int) : string{
	if(index == 0){
		return "mari_";
	}
	else if(index == 1){
		return "louieg_";
	}
	else if(index == 2){
		return "plum_";
	}
	else if(index == 3){
		return "brutus_";
	}
}

function spawnFighter(fighterIndex:Int, player:Character, xPos:Float): Projectile{
	var temp = match.createProjectile(self.getResource().getContent("fighter"), null);
	temp.exports.setFighter(fighterIndex);
	if(fighterIndex < 1){
		Engine.log(p1costumeIndex);
		temp.setCostumeIndex(p1costumeIndex);
	}
	else{
		Engine.log(p2costumeIndex);
		temp.setCostumeIndex(p2costumeIndex);
	}
	temp.setX(xPos);
	temp.setY(84);
	temp.exports.setPlayer(player);
	camera.addForcedTarget(temp);
	return temp;
}

function spawnStageDecor(stageIndex){
	var ground = Sprite.create(self.getResource().getContent("kartfight"));
	self.getBackgroundStructuresContainer().addChild(ground);
	ground.x = 0;
	ground.y = 85;
	currentMenuAssets.push(ground);
	var bg0 = Sprite.create(self.getResource().getContent("kartfight"));
	camera.getBackgroundContainers()[3].addChild(bg0);
	bg0.x = 0;
	bg0.y = 82;
	currentMenuAssets.push(bg0);
	var bg1 = Sprite.create(self.getResource().getContent("kartfight"));
	camera.getBackgroundContainers()[2].addChild(bg1);
	bg1.x = 0;
	bg1.y = 82;
	currentMenuAssets.push(bg1);
	var bg2 = Sprite.create(self.getResource().getContent("kartfight"));
	camera.getBackgroundContainers()[1].addChild(bg2);
	bg2.x = 0;
	bg2.y = 82;
	currentMenuAssets.push(bg2);
	var bg = Sprite.create(self.getResource().getContent("kartfight"));
	camera.getBackgroundContainers()[0].addChild(bg);
	bg.x = 0;
	bg.y = 0;
	currentMenuAssets.push(bg);
	if(stageIndex == 0){
		ground.currentAnimation = "peachstage_ground";
		bg2.currentAnimation = "peachstage_bgElement2";
		bg.currentAnimation = "peachstage_background";
	}
	else if(stageIndex == 1){
		ground.currentAnimation = "donkeystage_ground";
		bg2.currentAnimation = "donkeystage_bgElement2";
		bg.currentAnimation = "background";
	}
	else if(stageIndex == 2){
		ground.currentAnimation = "maristage_ground";
		bg2.currentAnimation = "maristage_bgElement2";
		bg1.currentAnimation = "maristage_bgElement1";
		animatedMenuAssets.push(bg1);
		bg0.currentAnimation = "maristage_bgElement0";
		animatedMenuAssets.push(bg0);
		var temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = -467;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = -299;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = -181;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = -13;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = 155;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = 277;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		temp = Sprite.create(self.getResource().getContent("kartfight"));
		temp.currentAnimation = "maristage_candles";
		camera.getBackgroundContainers()[1].addChild(temp);
		temp.x = 445;
		temp.y = -62;
		currentMenuAssets.push(bg);
		animatedMenuAssets.push(temp);
		self.getCameraBounds().setY(defaultCamY + 15);
		bg.currentAnimation = "background";
	}
	else if(stageIndex == 3){
		ground.currentAnimation = "kinopiostage_ground";
		bg1.currentAnimation = "kinopiostage_bgElement2";
		bg2.currentAnimation = "kinopiostage_bgElement1";
		bg.currentAnimation = "background";
	}
}

// GENERIC FUNCTIONS
// -----------------------------------------------------------------------------------------

function holdPlayers(){
	var plyrs:Array<Character> = match.getCharacters();
	for(i in 0...plyrs.length){
		plyrs[i].setX(gameManager.get().getX());
		plyrs[i].setY(-115);
		if(plyrs[i].getAnimation() != "stand"){
			plyrs[i].setVisible(false);
			plyrs[i].toggleGravity(false);
			plyrs[i].playAnimation("stand");
			plyrs[i].setState(CState.EMOTE);
			plyrs[i].setScaleX(0);
			plyrs[i].setScaleY(0);
			plyrs[i].getDamageCounterContainer().alpha = 0;
			plyrs[i].pause();
			if(plyr1 == null && i == 0){
				plyr1 = plyrs[i];
			}
			else if(plyr2 == null && i == 1){
				plyr2 = plyrs[i];
			}
		}
	}
}

function generateNumbers(xPos: Float, yPos: Float, scale: Float, container: Container, array:Array, nmbrToText: string){
	var letter:string = null;
	var letterX = xPos;
	for(i in 0...nmbrToText.length){
		letter = nmbrToText.charAt(i);
		var spr = Sprite.create(self.getResource().getContent("kartfight"));
		spr.currentAnimation = "numbers";
		container.addChild(spr);
		spr.x = letterX;
		spr.y = yPos;
		spr.scaleX = scale;
		spr.scaleY = scale;
		if(array != null){
			array.push(spr);
		}
		if(letter == "0"){
			spr.currentFrame = 1;}
		else if(letter == "1"){
			spr.currentFrame = 2;}
		else if(letter == "2"){
			spr.currentFrame = 3;}
		else if(letter == "3"){
			spr.currentFrame = 4;}
		else if(letter == "4"){
			spr.currentFrame = 5;}
		else if(letter == "5"){
			spr.currentFrame = 6;}
		else if(letter == "6"){
			spr.currentFrame = 7;}
		else if(letter == "7"){
			spr.currentFrame = 8;}
		else if(letter == "8"){
			spr.currentFrame = 9;}
		else if(letter == "9"){
			spr.currentFrame = 10;}
		letterX = letterX + 8 * scale;
	}
}

function onTeardown(){
}
function onKill(){
}
function onStale(){
}
function afterPushState(){
}
function afterPopState(){
}
function afterFlushStates(){
}

