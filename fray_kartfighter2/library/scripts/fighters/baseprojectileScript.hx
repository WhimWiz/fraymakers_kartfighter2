
var OBJECTTYPE_FIGHTER = 0;
var OBJECTTYPE_PROJECTILE = 1;

var BLOCKTYPE_NONE = 0;
var BLOCKTYPE_HIGH = 1;
var BLOCKTYPE_LOW = 2;
var BLOCKTYPE_ALL = 3;
var BLOCKTYPE_INVINC = 4;

var projID = -1;

var lifeTime = 60;
var isDestroying = false;
var isGrabbed = false;
var grabbedBy = null;
var grabYoffset = 0;
var spdMulti = 1;

function initialize(){

    self.addEventListener(GameObjectEvent.HITBOX_CONNECTED, analyzeHit, {persistent: true});
    self.addEventListener(GameObjectEvent.HIT_RECEIVED, onHitRecieved, {persistent: true});

    self.exports = {
        checkObjectType: function (): Int{
            return 1;
        },
        setProjectile: function (index){
            projID = index;
            updateProjectileIdentity(index);
        },
        setLifetimeInSeconds: function (newTime){
            lifeTime = newTime * 60;
        },
        setGrabbed: function (fighter){
            grabbedBy = fighter;
            var temp = self.getCollisionBoxes(CollisionBoxType.HIT);
            if(grabbedBy != null){
                if(temp != null){
                    for(i in 0...temp.length){
                        self.updateHitboxStats(i, {disabled: true});
                    }
                }
                self.setOwner(fighter);
                self.toggleGravity(false);
                self.updateGameObjectStats({ghost: true});
                isGrabbed = true;
                spdMulti += 0.5;
            }
            else{
                if(temp != null){
                    for(i in 0...temp.length){
                        self.updateHitboxStats(i, {disabled: false});
                    }
                    self.reactivateHitboxes();
                }
                self.flip();
                self.toggleGravity(true);
                self.updateGameObjectStats({ghost: false});
                isGrabbed = false;
            }
        },
        updateSpdMultiplier: function (add: Float){
            spdMulti += add;
        }
    };
}

function update(){
    if(!isDestroying){
        updateStateOperations();
        if(!isGrabbed){
            updateLifetime();
        }
    }
}

function updateStateOperations(){
    if(isGrabbed){
        if(grabbedBy != null){
            var temp = grabbedBy.getCollisionBoxes(CollisionBoxType.CUSTOMC);
            if(temp != null){
                self.setX(grabbedBy.getX() + (temp[0].x * (grabbedBy.isFacingLeft() ? -1 : 1)) * grabbedBy.getScaleX());
                self.setY(grabbedBy.getY() + (temp[0].y + grabYoffset) * grabbedBy.getScaleY());
            }
        }
        return;
    }
    if(projID == 0){
        self.setXSpeed(4 * spdMulti);
        if(self.isOnFloor()){
            self.unattachFromFloor();
            self.setYSpeed(-6);
        }
    }
    else if(projID == 1){
        self.setXSpeed(3 * spdMulti);
    }
    else if(projID == 2){
        self.setXSpeed(2.5 * spdMulti);
    }
    else if(projID == 3){
        if(self.isOnFloor()){
            self.setXSpeed(2 * spdMulti);
        }
    }
    else if(projID == 4){
        if(self.isOnFloor()){
            self.setXSpeed(2 * spdMulti);
        }
    }
    else if(projID == 5){
        self.setXSpeed(2 * spdMulti);
    }
}

// PLAYS BEFORE HITBOXSTATS ARE APPLIED
function analyzeHit(event:GameObjectEvent){
    var victim = event.data.foe;
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
        event.data.hitboxStats.damage = event.data.hitboxStats.damage / 3;
        event.data.hitboxStats.baseKnockback = event.data.hitboxStats.baseKnockback / 2;
        event.data.hitboxStats.hitstun = event.data.hitboxStats.hitstun / 2;
        event.data.hitboxStats.hitEffectOverride = "#n/a";
        event.data.hitboxStats.hitSoundOverride = self.getResource().getContent("block");
        //self.updateHitboxStats(event.data.hitboxStats.index, {damage: 0, baseKnockback: event.data.hitboxStats.baseKnockback / 2, hitstun: event.data.hitboxStats.hitstun / 2, angle: 0, hitEffectOverride: "#n/a"});
    }
}

function onHitRecieved(event: GameObjectEvent){
    if(event.data.foe.exports.checkObjectType() == 1){
        destroyProjectile(null);
    }
}

function updateLifetime(){
    lifeTime--;
    if(lifeTime <= 0){
        destroyProjectile(null);
    }
}

function updateProjectileIdentity(index){
    if(index == 0){
        grabYoffset = -24;
        self.playAnimation("mari_fireball");
        self.updateGameObjectStats({gravity: 0.6});
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
    else if(index == 1){
        grabYoffset = -24;
        self.playAnimation("louieg_fireball");
        self.updateGameObjectStats({gravity: 0});
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
    else if(index == 2){
        grabYoffset = -24;
        self.playAnimation("plum_blob");
        self.updateGameObjectStats({gravity: 0});
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
    else if(index == 3){
        grabYoffset = -24;
        self.playAnimation("todd_supershroom_air");
        self.setYSpeed(-6);
        self.updateGameObjectStats({gravity: 0.25});
        self.setOwner(null);
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
    else if(index == 4){
        grabYoffset = -24;
        self.playAnimation("todd_poisonshroom_air");
        self.setYSpeed(-6);
        self.updateGameObjectStats({gravity: 0.25});
        self.setOwner(null);
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
    else if(index == 5){
        grabYoffset = -24;
        self.playAnimation("todd_sporeshot");
        self.updateGameObjectStats({gravity: 0});
        self.addEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile, {persistent: true});
    }
}

function destroyProjectile (event:GameObjectEvent){
    isDestroying = true;
    if(projID == 0){
        self.playAnimation("mari_fireball_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
        self.updateGameObjectStats({gravity: 0});
    }
    else if(projID == 1){
        self.playAnimation("louieg_fireball_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
    }
    else if(projID == 2){
        self.playAnimation("plum_blob_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
    }
    else if(projID == 3){
        if(event != null){
            if(event.data.foe.exports.checkObjectType() == OBJECTTYPE_FIGHTER){
                event.data.foe.exports.setStatusEffect(0, 5 * 60, true);
            }
        }
        self.playAnimation("todd_supershroom_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
    }
    else if(projID == 4){
        if(event != null){
            if(event.data.foe.exports.checkObjectType() == OBJECTTYPE_FIGHTER){
                event.data.foe.exports.setStatusEffect(1, 5 * 60, true);
            }
        }
        self.playAnimation("todd_poisonshroom_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
    }
    else if(projID == 5){
        if(event != null){
            self.setX(event.data.foe.getX());
        }
        self.playAnimation("todd_sporeshot_destroy");
        self.resetMomentum();
        self.removeEventListener(GameObjectEvent.HIT_DEALT, destroyProjectile);
    }
}