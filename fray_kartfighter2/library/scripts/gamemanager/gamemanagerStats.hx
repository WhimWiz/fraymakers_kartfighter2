// GAME MANAGER STATS

{
	spriteContent: self.getResource().getContent("kartfight"),
	stateTransitionMapOverrides: [
		PState.ACTIVE => {
			animation: "gameManagerSprite"
		}
	]
}