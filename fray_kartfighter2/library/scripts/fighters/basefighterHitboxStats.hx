{
    // MARI HITBOXES
    mari_jab: {
        hitbox0: {damage: 4, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 22, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    mari_jab_crouch: {
        hitbox0: {damage: 4, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 22, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FOOT}
    },
    mari_jab_air: {
        hitbox0: {damage: 4, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 25, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    mari_kick: {
        hitbox0: {damage: 7, baseKnockback: 46, knockbackGrowth: 0, angle: 15, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 5, baseKnockback: 22, knockbackGrowth: 0, angle: 10, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    mari_kick_crouch: {
        hitbox0: {damage: 7, baseKnockback: 40, knockbackGrowth: 0, angle: 45, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT},
        hitbox1: {damage: 5, baseKnockback: 25, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT}
    },
    mari_kick_air: {
        hitbox0: {damage: 7, baseKnockback: 22, knockbackGrowth: 0, angle: 10, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 5, baseKnockback: 14, knockbackGrowth: 0, angle: 10, hitstun: 32, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    mari_tatsumakisenpukyaku: {
        hitbox0: {damage: 8, baseKnockback: 40, knockbackGrowth: 0, angle: 20, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.BODY}
    },
    mari_shoryuken: {
        hitbox0: {damage: 13, baseKnockback: 80, knockbackGrowth: 0, angle: 80, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.BODY}
    },
    mari_fireball: {
        hitbox0: {damage: 5, baseKnockback: 25, knockbackGrowth: 0, angle: 10, hitstun: 26, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("firehit"), limb: AttackLimb.BODY} //hitEffectOverride: "#n/a"
    },
    mari_grab: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: GlobalSfx.GRAB_CONFIRM, hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED} //hitEffectOverride: "#n/a"
    },

    // LOUIE G HITBOXES
    louieg_jab: {
        hitbox0: {damage: 3, baseKnockback: 8, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    louieg_jab_crouch: {
        hitbox0: {damage: 3, baseKnockback: 8, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FOOT}
    },
    louieg_jab_air: {
        hitbox0: {damage: 3, baseKnockback: 8, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    louieg_kick: {
        hitbox0: {damage: 5, baseKnockback: 18, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 7, baseKnockback: 35, knockbackGrowth: 0, angle: 10, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    louieg_kick_crouch: {
        hitbox0: {damage: 5, baseKnockback: 15, knockbackGrowth: 0, angle: 10, hitstun: 21, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT},
        hitbox1: {damage: 7, baseKnockback: 40, knockbackGrowth: 0, angle: 75, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT}
    },
    louieg_kick_air: {
        hitbox0: {damage: 5, baseKnockback: 20, knockbackGrowth: 0, angle: 10, hitstun: 22, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 7, baseKnockback: 35, knockbackGrowth: 0, angle: 20, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    louieg_shoryuken: {
        hitbox0: {damage: 24, baseKnockback: 120, knockbackGrowth: 0, angle: 88, hitstun: 30, hitstopOffset: 6, selfHitstopOffset: 6, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.BODY},
        hitbox1: {damage: 8, baseKnockback: 65, knockbackGrowth: 0, angle: 65, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.BODY}
    },
    louieg_fireball: {
        hitbox0: {damage: 5, baseKnockback: 15, knockbackGrowth: 0, angle: 10, hitstun: 26, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("firehit"), limb: AttackLimb.BODY} //hitEffectOverride: "#n/a"
    },
    louieg_grab: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: GlobalSfx.GRAB_CONFIRM, hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED} //hitEffectOverride: "#n/a"
    },

    // PLUM HITBOXES
    plum_jab: {
        hitbox0: {damage: 3, baseKnockback: 12, knockbackGrowth: 0, angle: 10, hitstun: 18, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    plum_jab_crouch: {
        hitbox0: {damage: 3, baseKnockback: 12, knockbackGrowth: 0, angle: 10, hitstun: 18, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FOOT}
    },
    plum_jab_air: {
        hitbox0: {damage: 3, baseKnockback: 12, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    plum_kick: {
        hitbox0: {damage: 7, baseKnockback: 46, knockbackGrowth: 0, angle: 15, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 5, baseKnockback: 22, knockbackGrowth: 0, angle: 10, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    plum_kick_crouch: {
        hitbox0: {damage: 6, baseKnockback: 35, knockbackGrowth: 0, angle: 40, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT},
        hitbox1: {damage: 7, baseKnockback: 66, knockbackGrowth: 0, angle: 92, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT}
    },
    plum_kick_air: {
        hitbox0: {damage: 7, baseKnockback: 25, knockbackGrowth: 0, angle: 300, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST},
        hitbox1: {damage: 5, baseKnockback: 18, knockbackGrowth: 0, angle: 10, hitstun: 32, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    plum_blob: {
        hitbox0: {damage: 3, baseKnockback: 25, knockbackGrowth: 0, angle: 170, hitstun: 22, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("firehit"), limb: AttackLimb.BODY} //hitEffectOverride: "#n/a"
    },
    plum_tatsumakisenpukyaku: {
        hitbox0: {damage: 2, baseKnockback: 32, knockbackGrowth: 0, angle: 5, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.BODY}
    },
    plum_shoryuken: {
        hitbox0: {damage: 1, baseKnockback: 35, knockbackGrowth: 0, angle: 5, hitstun: 0, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED, flinch: false}
    },
    plum_grab: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: GlobalSfx.GRAB_CONFIRM, hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED} //hitEffectOverride: "#n/a"
    },

    // TODD
    todd_jab: {
        hitbox0: {damage: 5, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 32, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    todd_jab_crouch: {
        hitbox0: {damage: 5, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 32, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FOOT}
    },
    todd_jab_air: {
        hitbox0: {damage: 5, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 37, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST}
    },
    todd_kick: {
        hitbox0: {damage: 4, baseKnockback: 15, knockbackGrowth: 0, angle: 10, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST},
        hitbox1: {damage: 6, baseKnockback: 38, knockbackGrowth: 0, angle: 70, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    todd_kick_crouch: {
        hitbox0: {damage: 6, baseKnockback: 38, knockbackGrowth: 0, angle: 80, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FOOT},
        hitbox1: {damage: 4, baseKnockback: 15, knockbackGrowth: 0, angle: 10, hitstun: 30, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FOOT}
    },
    todd_kick_air: {
        hitbox0: {damage: 4, baseKnockback: 20, knockbackGrowth: 0, angle: 10, hitstun: 32, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_light"), limb: AttackLimb.FIST},
        hitbox1: {damage: 6, baseKnockback: 35, knockbackGrowth: 0, angle: 88, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.FIST}
    },
    todd_tatsumakisenpukyaku: {
        hitbox0: {damage: 10, baseKnockback: 50, knockbackGrowth: 0, angle: 55, hitstun: 35, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("hurt_heavy"), limb: AttackLimb.BODY}
    },
    todd_grab: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: GlobalSfx.GRAB_CONFIRM, hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED} //hitEffectOverride: "#n/a"
    },
    todd_supershroom: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: "#n/a", hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED, flinch: false}
    },
    todd_poisonshroom: {
        hitbox0: {damage: 0, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 0, hitSoundOverride: "#n/a", hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED, flinch: false}
    },
    todd_sporeshot: {
        hitbox0: {damage: 3, baseKnockback: 10, knockbackGrowth: 0, angle: 10, hitstun: 20, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("poof"), limb: AttackLimb.BODY} //hitEffectOverride: "#n/a"
    },
    todd_sporeshot_destroy: {
        hitbox0: {damage: 2, baseKnockback: 0, knockbackGrowth: 0, angle: 0, hitstun: 16, reversibleAngle: false, hitSoundOverride: self.getResource().getContent("poison"), hitEffectOverride: "#n/a", limb: AttackLimb.UNDEFINED, stackKnockback: true} //hitEffectOverride: "#n/a"
    }
}