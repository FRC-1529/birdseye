enum ShootingDistance { fender, hanger, wallRed, wallBlue, varies }
const ShootingDistanceLabels = {
  ShootingDistance.fender: "Fender",
  ShootingDistance.hanger: "Hanger",
  ShootingDistance.wallRed: "Wall (Red)",
  ShootingDistance.wallBlue: "Wall (Blue)",
  ShootingDistance.varies: "Varies"
};
enum HangingSelection { low, mid, high, traversal }
const HangingSelectionLabels = {
  HangingSelection.low: "Low",
  HangingSelection.mid: "Mid",
  HangingSelection.high: "High",
  HangingSelection.traversal: "Traversal"
};
enum HangingCompletion { noAttempt, attempted, accomplished }
const HangingCompletionLabels = {
  HangingCompletion.noAttempt: "No Attempt",
  HangingCompletion.attempted: "Attempted",
  HangingCompletion.accomplished: "Accomplished"
};
enum GoalPosition { low, high }
