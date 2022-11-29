::Combat <- {
    /**
     * CombatStats for a single combat actor, for instance an opponent or the player.
     */
    "CombatStats": class{
        mHealth = 10;

        mDead = false;

        constructor(){

        }

        function alterHealth(amount){
            setHealth(mHealth + amount.getDamage());
        }

        function setHealth(health){
            mHealth = health;
            if(mHealth <= 0){
                mHealth = 0;
                mDead = true;
            }
        }
    },

    /**
     * Damage value contains a definition of an attacking move, for instance damage amount, status afflictions, etc.
     * TODO could rename this to something like MoveValues?
     */
    "DamageValue": class{
        mDamage = 0;

        constructor(damage){
            mDamage = damage;
        }

        function getDamage(){
            return mDamage;
        }
    },

    /**
     * Encapsulates all the data needed for an individual combat scene.
     * This includes, the player's stats, enemy stats, any other combat attributes which might effect the combat outcome.
     */
    "CombatData": class{
        mPlayerStats = null;
        mOpponentStats = null;

        constructor(playerStats, opponentStats){
            mPlayerStats = playerStats;
            mOpponentStats = opponentStats;
        }

        function getNumOpponents(){
            return mOpponentStats.len();
        }

        /**
         * Perform an attack on an opponent.
         * -1 will apply to all opponents.
         */
        function performAttackOnOpponent(damage, opponentId){
            local stats = mOpponentStats[opponentId];

            local dead = stats.mDead;
            stats.alterHealth(damage);

            //The opponent died as a result of this attack.
            return (dead != stats.mDead);
        }
    }
};