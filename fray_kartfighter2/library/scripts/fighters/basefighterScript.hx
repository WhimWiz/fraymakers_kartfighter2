// STATE MACHINE
var currentState = -1;
var FS_WAIT = -1;
var FS_STAND = 0;
var FS_WALKFORWARD = 1;
var FS_WALKBACKWARD = 2;
var FS_DASHFORWARD = 3;
var FS_DASHBACKWARD = 4;
var FS_JUMP = 5;
var FS_FALL = 6;
var FS_CROUCH = 7;
var FS_ATTACK = 8;
var FS_HURT = 9;
var FS_TUMBLE = 10;
var FS_SPECIAL = 11;
var FS_GRABBED = 12;
var FS_THROW = 13;
var FS_BLOCK = 14;
var FS_DIZZY = 15;
var FS_DOWN = 16;
var FS_POSE = 17;

var OBJECTTYPE_FIGHTER = 0;
var OBJECTTYPE_PROJECTILE = 1;

var BLOCKTYPE_NONE = 0;
var BLOCKTYPE_HIGH = 1;
var BLOCKTYPE_LOW = 2;
var BLOCKTYPE_ALL = 3;
var BLOCKTYPE_INVINC = 4;

var FIGHTERTYPE_MARI = 0;
var FIGHTERTYPE_LOUIEG = 1;
var FIGHTERTYPE_PLUM = 2;
var FIGHTERTYPE_TODD = 3;

var STEF_NONE = -1;
var STEF_BIG = 0;
var STEF_SMALL = 1;

var activeStateGroup = [FS_STAND, FS_WALKFORWARD, FS_WALKBACKWARD, FS_JUMP, FS_FALL, FS_CROUCH];
var blockStateGroup = [FS_STAND, FS_WALKFORWARD, FS_WALKBACKWARD, FS_JUMP, FS_FALL, FS_CROUCH, FS_BLOCK];
var jumpStateGroup = [FS_STAND, FS_WALKFORWARD, FS_WALKBACKWARD, FS_CROUCH];
var unfocusStateGroup = [FS_SPECIAL, FS_TUMBLE, FS_GRABBED, FS_THROW, FS_DOWN];
var barrierIgnoreStateGroup = [FS_GRABBED, FS_THROW, FS_DOWN];
var lightAttackSounds = [];
var heavyAttackSounds = [];
var hurtSounds = [];

// HUD
var healthbarSpr:Sprite = null;
var matchPoints:Sprite = null;
var healthX = 20;
var scoreX = 20;
var currScore = 0;
var proposedScore = 0;
var scoreText:Array<Sprite> = null;

// META DATA
var player:Character = null;
var plyrSlot:Int = 0;
var fighterPrefix = "";
var formPrefix = "";
var allowControl = true;
var foe:Projectile = null;
var foeDirec = 0;
var disableControl = false;
var aerialOption = true;
var airdashUsed = false;

var fighterVar1 = null;
var fighterVar2 = null;
var fighterVar3 = null;
var fighterVar4 = null;
var fighterVar5 = null;
var fighterVar6 = null;
var fighterVar7 = null;

// DATA
var hurtType = 0;
var grabbedSubject:Projectile = null;
var grabbedBy:Projectile = null;
var readInput = false;
var bufferedButton = -1;
var bufferedDirection = -1;
var dizzyTime = 60;
var dizzyTimeCurr = 0;
var dizzyHits = 0;
var dizzyLimit = 5;
var isDizzy = false;
var heldDirection = 0;
var hasTumbleLanded = false;

var currentStatusEffect = -1;
var statusEffTimer = 0;

// CPU
var isCPU = false;
var cpuStateWait = 0;

// STATS
var walkSpd = 2;
var dashSpd = 10;
var airdashSpd = 7;
var jumpSpd = 8;
var jumpMulti = 1;

var currentHitstun = 0;

var menuTransitioning = false;

function initialize(){

    toState(FS_STAND);

    self.addEventListener(GameObjectEvent.LAND, onLand, {persistent: true});
    self.addEventListener(GameObjectEvent.HITBOX_CONNECTED, analyzeHit, {persistent: true});
    self.addEventListener(GameObjectEvent.HIT_DEALT, onHitDealt, {persistent: true});
    self.addEventListener(GameObjectEvent.HIT_RECEIVED, onHitRecieved, {persistent: true});

    self.exports = {
        createHUDelements: function (slot: Int, score: Int, points: Int){
            healthbarSpr = Sprite.create(self.getResource().getContent("fighter"));
            camera.getForegroundContainer().addChild(healthbarSpr);
            healthbarSpr.currentAnimation = "healthbar";
            healthbarSpr.y = 15;
            healthbarSpr.scaleY = 1.5;
            matchPoints = Sprite.create(self.getResource().getContent("fighter"));
            camera.getForegroundContainer().addChild(matchPoints);
            matchPoints.currentAnimation = "matchpoints";
            matchPoints.y = 0;
            matchPoints.scaleY = 1.5;
            if(slot == 0){
                matchPoints.x = 275;
                matchPoints.scaleX = -1.5;
                healthX = 20;
                healthbarSpr.x = healthX;
                scoreX = 20;
                healthbarSpr.scaleX = 1.5;
            }
            else{
                matchPoints.x = 365;
                matchPoints.scaleX = 1.5;
                healthX = 620;
                healthbarSpr.x = healthX;
                scoreX = 550;
                healthbarSpr.scaleX = -1.5;
            }
            updateScore(score);
            matchPoints.currentFrame = points + 1;
        },
        checkObjectType: function (): Int{
            return 0;
        },
        setFighter: function (index){
            changeCharacter(index);
        },
        setPlayer: function (plyr){
            player = plyr;
        },
        setFoe: function (obj){
            foe = obj;
        },
        setPlyrSlot: function(newSlot){
            plyrSlot = newSlot;
        },
        setGrabbed: function (fighter){
            grabbedBy = fighter;
            if(grabbedBy != null){
                toState(FS_GRABBED);
                self.toggleGravity(false);
                self.updateGameObjectStats({ghost: true});
            }
            else{
                toState(FS_HURT);
                self.toggleGravity(true);
                self.updateGameObjectStats({ghost: false});
            }
        },
        checkBlock: function (): Int{
            checkBlockingType();
        },
        changeState: function(stateID: Int){
            toState(stateID);
        },
        getState: function() : Int{
            return currentState;
        },
        setControlState: function(isOn){
            disableControl = !isOn;
        },
        setScore: function(num){
            currScore = num;
        },
        addScore: function(num){
            currScore += num;
            updateScore(num);
        },
        setProposedScore: function(numAddedToCurr: Int){  
            proposedScore = currScore + numAddedToCurr;
        },
        onWin: function(){
            disableControl = true;
            matchPoints.currentFrame += 1;
        },
        setStatusEffect: function(effect:Int, time:Float, apply:Bool){
            if(apply){
                applyStatusEffect(effect, time);
            }
            else{
                removeStatusEffect(effect);
            }
        }
    };
}

function update(){
    self.setCostumeIndex(player.getCostumeIndex());
    if(healthbarSpr.currentFrame != self.getDamage() + 1){
        if(healthbarSpr.currentFrame < self.getDamage() + 1){
            healthbarSpr.currentFrame += 1;
        }
        else{
            healthbarSpr.currentFrame += -1;
        }
    }

    if(player.getPressedControls().ACTION){
        applyStatusEffect(STEF_BIG, 5 * 60);
    }

    if(player.getPressedControls().GRAB){
        applyStatusEffect(STEF_SMALL, 3 * 60);
    }

    if(currentStatusEffect >= 0){
        statusEffTimer--;
        if(statusEffTimer <= 0){
            removeStatusEffect(currentStatusEffect);
            currentStatusEffect = -1;
            statusEffTimer = 0;
        }
    }

    if(self.isOnFloor()){
        airdashUsed = false;
    }

    if(proposedScore > 0){
        updateScore(50);
        if(currScore >= proposedScore){
            currScore = proposedScore;
            proposedScore = 0;
        }
    }

    if(dizzyTimeCurr > 0){
        dizzyTimeCurr--;
    }
    else{
        dizzyHits = 0;
        dizzyTimeCurr = 0;
    }

    if(readInput){
        writeInputBuffer();
    }

    if(searchStateGroup(activeStateGroup) && !disableControl){
        if(player.getPressedControls().UP && self.isOnFloor() && searchStateGroup(jumpStateGroup)){
            self.unattachFromFloor();
            self.setYSpeed(-jumpSpd * jumpMulti);
            if(player.getHeldControls().RIGHT){
                self.setXVelocity(walkSpd);
            }
            else if(player.getHeldControls().LEFT){
                self.setXVelocity(-walkSpd);
            }
            else{
                self.setXVelocity(0);
            }
            toState(FS_JUMP);
        }

        heldDirection = findHeldDirection();

        if(player.getPressedControls().ATTACK){
            attemptAttack(0, heldDirection);
        }
        else if(player.getPressedControls().SPECIAL){
            attemptAttack(1, heldDirection);
        }
        else if(player.getPressedControls().JUMP){
            attemptAttack(2, heldDirection);
        }
    }
    else{
        heldDirection = 0;
    }

    if(player != null){
        if(isCPU){
            updateCPUStateOperations();
        }
        else{
            updateStateControlOperations();
        }
        updateStateOperations();
    }

    if(!searchStateGroup(unfocusStateGroup)){
        if(foe != null){
            updateFocus();
        }
        else if(!disableControl){
            if(player.getHeldControls().LEFT){
                self.faceLeft();
            }
            else if(player.getHeldControls().RIGHT){
                self.faceRight();
            }
        }
    }
    if(!searchStateGroup(barrierIgnoreStateGroup)){
        specialCollisionCheck();
    }
}

function updateStateOperations(){
    if(self.isOnFloor()){
        aerialOption = true;
    }
    if(currentState == FS_STAND){

    }
    else if(currentState == FS_WALKFORWARD){
        self.setXSpeed(walkSpd);
    }
    else if(currentState == FS_WALKBACKWARD){
        self.setXSpeed(-walkSpd);
    }
    else if(currentState == FS_DASHFORWARD){

    }
    else if(currentState == FS_DASHBACKWARD){

    }
    else if(currentState == FS_JUMP){
        if(self.getYSpeed() >= 0 || self.isOnFloor()){
            toState(FS_FALL);
        }
    }
    else if(currentState == FS_FALL){
        if(self.isOnFloor()){
            toState(FS_STAND);
        }
    }
    else if(currentState == FS_CROUCH){

    }
    else if(currentState == FS_HURT){
        if(!self.isOnFloor()){
            toState(FS_TUMBLE);
            currentHitstun = 0;
            return;
        }
        currentHitstun--;
        if(currentHitstun <= 0){
            toState(FS_STAND);
        }
    }
    else if(currentState == FS_TUMBLE){
        if(self.isOnFloor()){
            if(self.getAnimation() != fighterPrefix + formPrefix + "hurt_land"){
                hasTumbleLanded = true;
                self.playAnimation(fighterPrefix + formPrefix + "hurt_land");
            }
        }
    }
    else if(currentState == FS_GRABBED){
        if(grabbedBy != null){
            var temp = grabbedBy.getCollisionBoxes(CollisionBoxType.CUSTOMC);
            if(temp != null){
                self.setX(grabbedBy.getX() + (temp[0].x * (grabbedBy.isFacingLeft() ? -1 : 1)) * grabbedBy.getScaleX());
                self.setY(grabbedBy.getY() + temp[0].y * grabbedBy.getScaleY());
            }
        }
    }
    else if(currentState == FS_ATTACK){
        
    }
    else if(currentState == FS_BLOCK){
        currentHitstun--;
        if(currentHitstun <= 0){
            if(self.getAnimation() == fighterPrefix + "block_crouch"){
                toState(FS_CROUCH);
            }
            else{
                toState(FS_STAND);
            }
        }
    }
    else if(currentState == FS_DOWN){
        if(self.isOnFloor()){
            if(self.getAnimation() != fighterPrefix + formPrefix + "down"){
                self.playAnimation(fighterPrefix + formPrefix + "down");
            }
        }
    }
    else if(currentState == FS_POSE){

    }
}

function updateStateControlOperations(){
    if(currentState == FS_STAND){
        if(player.getHeldControls().DOWN && !disableControl){
            toState(FS_CROUCH);
            return;
        }
        if(player.getHeldControls().LEFT && !disableControl || player.getHeldControls().RIGHT && !disableControl){
            if(self.isFacingLeft() && player.getHeldControls().RIGHT && foe != null || self.isFacingRight() && player.getHeldControls().LEFT && foe != null){
                toState(FS_WALKBACKWARD);
                return;
            }
            else{
                toState(FS_WALKFORWARD);
                return;
            }
        }
    }
    else if(currentState == FS_WALKFORWARD){
        if(player.getHeldControls().DOWN && !disableControl){
            toState(FS_CROUCH);
            return;
        }
        if(!player.getHeldControls().LEFT && !player.getHeldControls().RIGHT || disableControl){
            toState(FS_STAND);
            return;
        }
        else if(player.getHeldControls().LEFT && foeDirec > 0 && !disableControl || player.getHeldControls().RIGHT && foeDirec < 0  && !disableControl){
            toState(FS_WALKBACKWARD);
            return;
        }

        if(player.getPressedControls().SHIELD && !disableControl){
            toState(FS_DASHFORWARD);
        }
    }
    else if(currentState == FS_WALKBACKWARD){
        if(player.getHeldControls().DOWN && !disableControl){
            toState(FS_CROUCH);
            return;
        }
        if(!player.getHeldControls().LEFT && !player.getHeldControls().RIGHT || disableControl){
            toState(FS_STAND);
        }
        else if(player.getHeldControls().LEFT && foeDirec < 0 && !disableControl|| player.getHeldControls().RIGHT && foeDirec > 0 && !disableControl){
            toState(FS_WALKFORWARD);
        }

        if(player.getPressedControls().SHIELD && !disableControl){
            toState(FS_DASHBACKWARD);
        }
    }
    else if(currentState == FS_CROUCH){
        if(!player.getHeldControls().DOWN || disableControl){
            toState(FS_STAND);
        }
    }
    else if(currentState == FS_JUMP){
        if(!airdashUsed && player.getPressedControls().SHIELD && !disableControl){
            airdashUsed = true;
            if(self.isFacingLeft() && player.getHeldControls().RIGHT && foe != null || self.isFacingRight() && player.getHeldControls().LEFT && foe != null){
                toState(FS_DASHBACKWARD);
                return;
            }
            else{
                toState(FS_DASHFORWARD);
                return;
            }
        }
    }
    else if(currentState == FS_FALL){
        if(!airdashUsed && player.getPressedControls().SHIELD && !disableControl){
            airdashUsed = true;
            if(self.isFacingLeft() && player.getHeldControls().RIGHT && foe != null || self.isFacingRight() && player.getHeldControls().LEFT && foe != null){
                toState(FS_DASHBACKWARD);
                return;
            }
            else{
                toState(FS_DASHFORWARD);
                return;
            }
        }
    }
}

function updateCPUStateOperations(){
    /*cpuStateWait--;
    if(cpuStateWait > 0){
        return;
    }
    else{
        cpuStateWait = 0;
    }*/
    var rand = 0;
    var chance = 0;
    var foeDist = Math.abs(self.getX() - foe.getX());
    if(currentState == FS_STAND){
        chance = 50;
        // WALK FORWARD CHANCE
        if(foe.getXSpeed() > 0){
            chance += 20;
        }
        else if(foe.getXSpeed() < 0){
            chance -= 15;
        }
        chance - Math.ceil(foeDist / 2);
        if(chance < 3){
            chance = 3;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_WALKFORWARD);
            return;
        }

        // WALK BACK CHANCE
        chance = 80;
        if(foe.getXSpeed() > 0){
            chance -= 20;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_WALKBACKWARD);
            return;
        }
    }
    else if(currentState == FS_WALKFORWARD){
        self.setXSpeed(walkSpd);
        // STOP CHANCE
        chance = 85;
        if(foe.getXSpeed() == 0){
            chance += 10;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_STAND);
        }

        // WALK BACK CHANCE
        chance = 80;
        if(foe.getXSpeed() > 0){
            chance -= 20;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_WALKBACKWARD);
            return;
        }
    }
    else if(currentState == FS_WALKBACKWARD){
        self.setXSpeed(-walkSpd);
        // STOP CHANCE
        chance = 45;
        if(foe.getXSpeed() == 0){
            chance -= 7;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_STAND);
        }

        // WALK FORWARD CHANCE
        chance = 35;
        if(foe.getXSpeed() > 0){
            chance += 15;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            toState(FS_WALKFORWARD);
            return;
        }
    }

    if(foeDist < 40 && searchStateGroup(activeStateGroup)){
        chance = 8;
        if(!foe.isOnFloor()){
            chance -= 3;
        }
        rand = Random.getInt(0, chance);
        if(rand == 0){
            attemptAttack(0, 1);
        }
    }
}

function updateFocus(){
    if(foe.getX() > self.getX()){
        self.faceRight();
        foeDirec = 1;
    }
    else{
        self.faceLeft();
        foeDirec = -1;
    }
}

function updateScore(add:Int){
    if(scoreText != null){
        for(i in 0...scoreText.length){
            scoreText[i].dispose();
        }
        scoreText.resize(0);
    }
    else{
        scoreText = new Array(0);
    }
    currScore += add;
    var scoreString = "" + currScore;
    stage.exports.generateNumToText(scoreX, 0, 1.5, camera.getForegroundContainer(), scoreText, "0000000".substring(0, 6 - scoreString.length) + scoreString);
}

function checkBlockingType(): Int{
    if(searchStateGroup(blockStateGroup) && self.isOnFloor()){
        if(self.isFacingLeft() && player.getHeldControls().RIGHT || self.isFacingRight() && player.getHeldControls().LEFT){
            if(player.getHeldControls().DOWN){
                return BLOCKTYPE_LOW;
            }
            else{
                return BLOCKTYPE_HIGH;
            }
        }
    }
    return BLOCKTYPE_NONE;
}

// PLAYS BEFORE HITBOXSTATS ARE APPLIED
function analyzeHit(event:GameObjectEvent){
    var victim = event.data.foe;
    if(victim.exports.checkObjectType() == OBJECTTYPE_PROJECTILE){
        event.data.hitboxStats.damage = 0;
        event.data.hitboxStats.hitEffectOverride = "#n/a";
        event.data.hitboxStats.hitSoundOverride = self.getResource().getContent("block");
        return;
    }

    if(self.getScaleX() < 1){
        event.data.hitboxStats.damage *= 0.7;
        event.data.hitboxStats.hitstun *= 0.9;
    }
    else if(self.getScaleX() > 1){
        event.data.hitboxStats.damage *= 1.3;
        event.data.hitboxStats.hitstun *= 1.2;
    }

    if(victim.getScaleX() < 1){
        event.data.hitboxStats.damage *= 1.3;
        event.data.hitboxStats.hitstun *= 1.2;
    }
    else if(victim.getScaleX() > 1){
        event.data.hitboxStats.damage *= 0.7;
        event.data.hitboxStats.hitstun *= 0.9;
    }

    if(victim.exports.checkObjectType() == OBJECTTYPE_FIGHTER){
        var blockType = victim.exports.checkBlock();
        if(event.data.hitboxStats.limb == AttackLimb.UNDEFINED){
            return;
        }
        else if(event.data.hitboxStats.limb == AttackLimb.BODY){
            if(blockType == BLOCKTYPE_NONE){
                return;
            }
        }
        else if(event.data.hitboxStats.limb == AttackLimb.FIST){
            if(blockType != BLOCKTYPE_HIGH){
                return;
            }
        }
        else if(event.data.hitboxStats.limb == AttackLimb.FOOT){
            if(blockType != BLOCKTYPE_LOW){
                return;
            }
        }
        event.data.hitboxStats.selfHitstopOffset = 3;
        event.data.hitboxStats.damage = 0;
        event.data.hitboxStats.baseKnockback = event.data.hitboxStats.baseKnockback / 2;
        event.data.hitboxStats.hitstun = event.data.hitboxStats.hitstop / 2;
        event.data.hitboxStats.hitstun = event.data.hitboxStats.hitstun / 2;
        event.data.hitboxStats.hitEffectOverride = "#n/a";
        event.data.hitboxStats.hitSoundOverride = self.getResource().getContent("block");
    }
}

// PLAYS AFTER ANALYZEHIT
function onHitDealt(event:GameObjectEvent){
    updateScore(20);
    if(currentState == FS_ATTACK && self.isOnFloor()){
        self.setXSpeed(-event.data.hitboxStats.damage / 1.6);
    }
}

function onHitRecieved(event:GameObjectEvent){
    if(currentState == FS_GRABBED){
        self.exports.setGrabbed(null);
    }
    if(self.getDamage() >= 150){
        stage.exports.playMusic(12);
        toState(FS_DOWN);
        return;
    }
    currentHitstun = self.getHitstun();
    if(event.data.hitboxStats.limb == AttackLimb.FIST){
        if(checkBlockingType() == BLOCKTYPE_HIGH){
            toState(FS_BLOCK);
            self.setYKnockback(0);
            self.playAnimation(fighterPrefix + formPrefix + "block");
            return;
        }
        hurtType = 2;
    }
    else if(event.data.hitboxStats.limb == AttackLimb.FOOT){
        if(checkBlockingType() == BLOCKTYPE_LOW){
            toState(FS_BLOCK);
            self.setYKnockback(0);
            self.playAnimation(fighterPrefix + formPrefix + "block_crouch");
            return;
        }
        hurtType = 1;
    }
    else if(event.data.hitboxStats.limb == AttackLimb.BODY){
        if(checkBlockingType() != BLOCKTYPE_NONE){
            toState(FS_BLOCK);
            self.setYKnockback(0);
            self.playAnimation(fighterPrefix + formPrefix + "block");
            return;
        }
        hurtType = 0;
    }
    isDizzy = false;
    dizzyTimeCurr = dizzyTime;

    if(!event.data.hitboxStats.flinch){
        currentHitstun = 0;
        return;
    }

    if(dizzyHits >= dizzyLimit - 1){
        dizzyHits = 0;
        dizzyTimeCurr = 0;
        isDizzy = true;
        AudioClip.play(self.getResource().getContent("knockout"));
        match.freezeScreen(15, [camera]);
        self.unattachFromFloor();
        toState(FS_TUMBLE);
    }
    else{
        playHurtSound();
        toState(FS_HURT);
    }
}

function onLand(event:GameObjectEvent){
    if(currentState == FS_ATTACK){
        if(!readInputBuffer()){
            toState(FS_STAND);
        }
    }
}

function grabFoe(subject:Projectile){
    grabbedSubject = subject;
    subject.exports.setGrabbed(self);
    toState(FS_THROW);
}

function releaseGrabbedFoe(xSpd:Float, ySpd:Float){
    grabbedSubject.exports.setGrabbed(null);
    if(grabbedSubject.exports.checkObjectType() == 0){
        grabbedSubject.setXSpeed(xSpd);
        grabbedSubject.setYSpeed(ySpd);
    }
    grabbedSubject = null;
}

function specialCollisionCheck(){
    if(self.isOnFloor() && foe.isOnFloor() && Math.abs(self.getX() - foe.getX()) < 15){
        self.setX(foe.getX() + 15 * -foeDirec);
    }

    if(self.getX() < camera.getX() + -195){
        self.setX(camera.getX() + -195);
    }
    else if(self.getX() > camera.getX() + 195){
        self.setX(camera.getX() + 195);
    }
}

function changeCharacter(fighterIndex:Int){
    fighterVar1 = null;
    fighterVar2 = null;
    fighterVar3 = null;
    fighterVar4 = null;
    fighterVar5 = null;
    fighterVar6 = null;
    fighterVar7 = null;
    if(fighterIndex == FIGHTERTYPE_MARI){
        fighterPrefix = "mari_";
        walkSpd = 1.5;
        dashSpd = 10;
        airdashSpd = 8;
        jumpSpd = 8;
        self.updateGameObjectStats({gravity: 0.4});
        lightAttackSounds = ["mari_oh", "mari_wah", "mari_yah", "mari_haha"];
        heavyAttackSounds = ["mari_waha", "mari_yippee", "mari_hoo"];
        hurtSounds = ["mari_doh", "mari_ooph", "mari_ooh"];
    }
    else if(fighterIndex == FIGHTERTYPE_LOUIEG){
        fighterPrefix = "louieg_";
        walkSpd = 2;
        dashSpd = 7.5;
        airdashSpd = 6;
        jumpSpd = 9;
        self.updateGameObjectStats({gravity: 0.3});
        lightAttackSounds = ["louieg_huh", "louieg_hey", "louieg_hooyeah", "louieg_yuh"];
        heavyAttackSounds = ["louieg_gotcha", "louieg_yeahhoo", "louieg_aha"];
        hurtSounds = ["louieg_ow", "louieg_woah", "louieg_uh"];
    }
    else if(fighterIndex == FIGHTERTYPE_PLUM){
        fighterPrefix = "plum_";
        walkSpd = 1.45;
        dashSpd = 8.5;
        airdashSpd = 8;
        jumpSpd = 7.5;
        self.updateGameObjectStats({gravity: 0.36});
        lightAttackSounds = [];
        heavyAttackSounds = [];
        hurtSounds = [];
    }
    else if(fighterIndex == FIGHTERTYPE_TODD){
        fighterPrefix = "todd_";
        walkSpd = 2.2;
        dashSpd = 12;
        airdashSpd = 9;
        jumpSpd = 7.2;
        self.updateGameObjectStats({gravity: 0.34});
        lightAttackSounds = [];
        heavyAttackSounds = [];
        hurtSounds = [];
        fighterVar1 = false;
    }
    toState(currentState);
}

function findHeldDirection(): Int{
    var temp = 0;
    var plyrControls = player.getHeldControls();
    if(plyrControls.RIGHT){
        if(plyrControls.UP){
            temp = 2;
        }
        else{
            temp = 1;
        }
    }
    else if(plyrControls.UP){
        if(plyrControls.LEFT){
            temp = 4;
        }
        else{
            temp = 3;
        }
    }
    else if(plyrControls.LEFT){
        if(plyrControls.DOWN){
            temp = 6;
        }
        else{
            temp = 5;
        }
    }
    else if(plyrControls.DOWN){
        if(plyrControls.RIGHT){
            temp = 8;
        }
        else{
            temp = 7;
        }
    }
    return temp;
}

function attemptAttack(attackType:Int, attackDirection:Int){
    if(attackType == 2 && self.isOnFloor()){
        playHeavySound();
        if(attackDirection == 5 && foeDirec > 0 || attackDirection == 1 && foeDirec < 0){
            self.playAnimation(fighterPrefix + formPrefix + "grab");
        }
        else if(attackDirection == 1 && foeDirec > 0 || attackDirection == 5 && foeDirec < 0){
            self.playAnimation(fighterPrefix + formPrefix + "tatsumakisenpukyaku");
        }
        else if(attackDirection >= 6 && attackDirection <= 8){
            self.playAnimation(fighterPrefix + formPrefix + "shoryuken");
        }
        else{
            self.playAnimation(fighterPrefix + formPrefix + "hadouken");
        }
        toState(FS_SPECIAL);
        return;
    }
    if(attackType == 0 || attackType == 2 && !self.isOnFloor()){
        if(!self.isOnFloor()){
            self.playAnimation(fighterPrefix + formPrefix + "jab_air");
        }
        else if(attackDirection >= 6 && attackDirection <= 8){
            self.playAnimation(fighterPrefix + formPrefix + "jab_crouch");
        }
        else{
            self.playAnimation(fighterPrefix + formPrefix + "jab");
        }
        toState(FS_ATTACK);
    }
    else if(attackType == 1){
        if(!self.isOnFloor()){
            self.playAnimation(fighterPrefix + formPrefix + "kick_air");
        }
        else if(attackDirection >= 6 && attackDirection <= 8){
            self.playAnimation(fighterPrefix + formPrefix + "kick_crouch");
        }
        else{
            self.playAnimation(fighterPrefix + formPrefix + "kick");
        }
        toState(FS_ATTACK);
    }
}

function spawnFighterProjectile(projID:Int, xOffset: Float, yOffset: Float, lifeTime: Float){
    var temp = match.createProjectile(self.getResource().getContent("fighterProjectile"), self);
    temp.setScaleX(self.getScaleX());
    temp.setScaleY(self.getScaleY());
    temp.setY(self.getY() + yOffset * self.getScaleY());
    if(self.isFacingLeft()){
        temp.faceLeft();
        temp.setX(self.getX() + -xOffset * self.getScaleX());
    }
    else{
        temp.faceRight();
        temp.setX(self.getX() + xOffset * self.getScaleX());
    }
    temp.exports.setProjectile(projID);
    temp.exports.setLifetimeInSeconds(lifeTime);
}

function toState(state:Int){
    cpuStateWait = 12;
    bufferedButton = -1;
    bufferedDirection = -1;
    readInput = false;

    if(state == FS_WAIT){
        self.playAnimation(fighterPrefix + formPrefix + "stand");
    }
    else if(state == FS_STAND){
        self.playAnimation(fighterPrefix + formPrefix + "stand");
    }
    else if(state == FS_WALKFORWARD){
        self.playAnimation(fighterPrefix + formPrefix + "walkforward");
    }
    else if(state == FS_WALKBACKWARD){
        self.playAnimation(fighterPrefix + formPrefix + "walkbackward");
    }
    else if(state == FS_DASHFORWARD){
        self.playAnimation(fighterPrefix + formPrefix + "dashforward");
        AudioClip.play(self.getResource().getContent("skid"));
    }
    else if(state == FS_DASHBACKWARD){
        self.playAnimation(fighterPrefix + formPrefix + "dashbackward");
        AudioClip.play(self.getResource().getContent("skid"));
    }
    else if(state == FS_JUMP){
        AudioClip.play(self.getResource().getContent("bigjump"));
        self.playAnimation(fighterPrefix + formPrefix + "jump");
    }
    else if(state == FS_FALL){
        self.playAnimation(fighterPrefix + formPrefix + "fall");
    }
    else if(state == FS_CROUCH){
        self.playAnimation(fighterPrefix + formPrefix + "crouch");
    }
    else if(state == FS_ATTACK){
        self.addEventListener(GameObjectEvent.HIT_DEALT, function(event:GameObjectEvent){
            readInput = true;
        });
    }
    else if(state == FS_HURT){
        if(hurtType == 2){
            self.playAnimation(fighterPrefix + formPrefix + "hurt_high");
        }
        else{
            self.playAnimation(fighterPrefix + formPrefix + "hurt_low");
        }
    }
    else if(state == FS_TUMBLE){
        self.playAnimation(fighterPrefix + formPrefix + "hurt_air");
    }
    else if(state == FS_GRABBED){
        self.playAnimation(fighterPrefix + formPrefix + "hurt_low");
    }
    else if(state == FS_THROW){
        self.playAnimation(fighterPrefix + formPrefix + "throw");
    }
    else if(state == FS_BLOCK){
        
    }
    else if(state == FS_DIZZY){
        self.playAnimation(fighterPrefix + formPrefix + "dizzy");
    }
    else if(state == FS_DOWN){
        stage.exports.setMatchTimer(false);
        self.unattachFromFloor();
        self.playAnimation(fighterPrefix + formPrefix + "down_fall");
        foe.exports.onWin();
        match.freezeScreen(100, [camera]);
        camera.horizontalShake(20, 30);
    }
    else if(state == FS_POSE){
        Engine.log("congrats!!");
        stage.exports.matchEndEvent(plyrSlot);
        self.playAnimation(fighterPrefix + formPrefix + "victory");
    }
    currentState = state;
    self.playFrame(1);
}

function searchStateGroup(group:Array<Int>) : Boolean {
    for(i in 0...group.length){
        if(group[i] == currentState){
            return true;
        }
    }
    return false;
}

function writeInputBuffer(){
    if(player.getPressedControls().UP && self.isOnFloor()){
        bufferedButton = 4;
        bufferedDirection = findHeldDirection();
        readInput = false;
    }
    else if(player.getPressedControls().ATTACK){
        bufferedButton = 0;
        bufferedDirection = findHeldDirection();
        readInput = false;
    }
    else if(player.getPressedControls().SPECIAL){
        bufferedButton = 1;
        bufferedDirection = findHeldDirection();
        readInput = false;
    }
    else if(player.getPressedControls().JUMP){
        bufferedButton = 2;
        bufferedDirection = findHeldDirection();
        readInput = false;
    }
    else if(player.getPressedControls().SHIELD){
        bufferedButton = 3;
        bufferedDirection = findHeldDirection();
        readInput = false;
    }
}

function readInputBuffer(): Boolean{
    if(bufferedButton == -1){
        bufferedButton = -1;
        bufferedDirection = -1;
        return false;
    }
    if(bufferedButton < 3){
        attemptAttack(bufferedButton, bufferedDirection);
    }
    else if(bufferedButton == 3){
        if(!self.isOnFloor() && airdashUsed){
            bufferedButton = -1;
            bufferedDirection = -1;
            return false;
        }
        if(bufferedDirection == 5 && foeDirec > 0 || bufferedDirection == 1 && foeDirec < 0){
            toState(FS_DASHBACKWARD);
        }
        else{
            toState(FS_DASHFORWARD);
        }
    }
    else if(bufferedButton == 4){
        if(self.isOnFloor()){
            self.unattachFromFloor();
            self.setYSpeed(-jumpSpd);
            if(bufferedDirection == 0){
                self.setXVelocity(0);
            }
            else if(bufferedDirection <= 2 || bufferedDirection == 8){
                self.setXVelocity(walkSpd);
            }
            else if(bufferedDirection >= 4 && bufferedDirection <= 6){
                self.setXVelocity(-walkSpd);
            }
            toState(FS_JUMP);
        }
    }
    bufferedButton = -1;
    bufferedDirection = -1;
    return true;
}

function applyStatusEffect(stef:Int, time:Float){
    if(currentStatusEffect >= 0){
        removeStatusEffect(currentStatusEffect);
    }
    currentStatusEffect = stef;
    statusEffTimer = time;
    if(stef == STEF_BIG){
        AudioClip.play(self.getResource().getContent("powerup"));
        walkSpd *= 0.7;
        dashSpd *= 0.8;
        airdashSpd *= 0.8;
        self.updateGameObjectStats({gravity: self.getGameObjectStat("gravity") * 1.2});
        self.setScaleX(self.getScaleX() * 1.5);
        self.setScaleY(self.getScaleY() * 1.5);
    }
    else if(stef == STEF_SMALL){
        AudioClip.play(self.getResource().getContent("powerdown"));
        walkSpd *= 1.3;
        dashSpd *= 1.3;
        airdashSpd *= 1.3;
        self.updateGameObjectStats({gravity: self.getGameObjectStat("gravity") * 0.6});
        self.setScaleX(self.getScaleX() * 0.5);
        self.setScaleY(self.getScaleY() * 0.5);
    }
}

function removeStatusEffect(stef:Int){
    if(stef == STEF_BIG){
        walkSpd /= 0.7;
        dashSpd /= 0.8;
        airdashSpd /= 0.8;
        self.updateGameObjectStats({gravity: self.getGameObjectStat("gravity") / 1.2});
        AudioClip.play(self.getResource().getContent("powerdown"));
        self.setScaleX(self.getScaleX() / 1.5);
        self.setScaleY(self.getScaleY() / 1.5);
    }
    else if(stef == STEF_SMALL){
        walkSpd /= 1.3;
        dashSpd /= 1.3;
        airdashSpd /= 1.3;
        self.updateGameObjectStats({gravity: self.getGameObjectStat("gravity") / 0.6});
        AudioClip.play(self.getResource().getContent("powerup"));
        self.setScaleX(self.getScaleX() / 0.5);
        self.setScaleY(self.getScaleY() / 0.5);
    }
}

function playLightSound(){
    if(lightAttackSounds.length > 0){
        var rand = Random.getInt(0, 1);
        if(rand == 1){
            rand = Random.getInt(0, lightAttackSounds.length - 1);
            AudioClip.play(self.getResource().getContent(lightAttackSounds[rand]));
        }
    }
}

function playHeavySound(){
    if(heavyAttackSounds.length > 0){
        var rand = Random.getInt(0, heavyAttackSounds.length - 1);
        AudioClip.play(self.getResource().getContent(heavyAttackSounds[rand]));
    }
}

function playHurtSound(){
    if(hurtSounds.length > 0){
        var rand = Random.getInt(0, 1);
        if(rand == 1){
            rand = Random.getInt(0, hurtSounds.length - 1);
            AudioClip.play(self.getResource().getContent(hurtSounds[rand]));
        }
    }
}

function onTeardown(){
    self.removeEventListener(GameObjectEvent.LAND, onLand);
    self.removeEventListener(GameObjectEvent.HITBOX_CONNECTED, analyzeHit);
    self.removeEventListener(GameObjectEvent.HIT_DEALT, onHitDealt);
    self.removeEventListener(GameObjectEvent.HIT_RECEIVED, onHitRecieved);
    camera.deleteForcedTarget(self);
    healthbarSpr.dispose();
    matchPoints.dispose();
    Engine.log("ded");
    if(scoreText != null){
        for(i in 0...scoreText.length){
            scoreText[i].dispose();
        }
        scoreText.resize(0);
    }

    stage.exports.updateScoreMemory(plyrSlot, currScore);
}