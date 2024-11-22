// BASE PROJECTILE STATS
{
    spriteContent: self.getResource().getContent("fighter"),
    stateTransitionMapOverrides: [
		PState.ACTIVE => {
			animation: "baseProj"
		}
	],
    gravity: 0.4,
    weight: 95,
    aerialHeadPosition: 25, // ^
    aerialHipWidth: 25, // <>
    aerialFootPosition: 0, // v
    floorHeadPosition: 25, // ^
    floorHipWidth: 25, // <>
    floorFootPosition: 0, // v
    terminalVelocity: 12,
    aerialFriction: 0,
    aerialSpeedCap: 12
}