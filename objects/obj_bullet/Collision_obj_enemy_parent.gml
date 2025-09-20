// Apply 1 damage; if enemy dies, it will handle loot drop
with (other) {
    enemyApplyDamage(1, other.owner);
}

instance_destroy();
