// BASE FIGHTER STATS
{
    spriteContent: self.getResource().getContent("fighter"),
    stateTransitionMapOverrides: [
		PState.ACTIVE => {
			animation: "base"
		}
	],
    gravity: 0.4,
    weight: 95,
    aerialHeadPosition: 60, // ^
    aerialHipWidth: 30, // <>
    aerialFootPosition: 0, // v
    floorHeadPosition: 60, // ^
    floorHipWidth: 30, // <>
    floorFootPosition: 0, // v
    terminalVelocity: 12,
    aerialFriction: 0,
    aerialSpeedCap: 12
}