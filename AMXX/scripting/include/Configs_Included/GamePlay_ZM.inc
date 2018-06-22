
#if defined _Configs_ZM_included
  #endinput
#endif
#define _Configs_ZM_included

#include <amxmodx>


#define WEAPON_STAY_TIME 5.0

#define DEFAULT_ROUND_TIME 2.5
#define DEFAULT_ZM3_TIME 4.0
#define NEMESIS_ROUND_TIME 10.0	// Round time of The Nemesis GamePlay
#define DEFAULT_ZM4_TIME 3.5 // Round time of Zombie Mod 4 GamePlay

new FIX_HIT_BOX = 1


#define ZM3_RESPAWN_SPRITE "sprites/ZM3_RESPAWN.spr" // Sprite displayed when a Zombie is killed and he can be respawned
#define ZM4_RESPAWN_SPRITE "sprites/ZOMBIE_HERO_EF_SPAWN.spr"
#define MAX_CLASS 64 // MAX CLASS ZOMBIE SUB PLUGIN CAN REGISTER

/*			NVG CONFIGURATION			*/

new SURVIVOR_GLOW_COLOR[] = {255, 255, 255} // White - Survivor's body will glow when he/she killes a Zombie
#define SURVIVOR_GLOW_TIME 5.0
new SURVIVOR_NVG_COLOR[3] = {127, 170, 255}
#define SURVIVOR_NVG_RADIUS 60
#define SURVIVOR_NVG_ALPHA 100

new ZM4_HERO_NVG_COLOR[] = {255, 212, 0}
#define ZM4_HERO_NVG_RADIUS 50
#define ZM4_HERO_NVG_ALPHA 100

new SPECTATOR_NVG_COLOR[] = {0, 235, 0}
#define SPECTATOR_NVG_RADIUS 45
#define SPECTATOR_NVG_ALPHA 70

new NEMESIS_NVG_COLOR[] = {42, 255, 255}
#define NEMESIS_NVG_RADIUS 50
#define NEMESIS_NVG_ALPHA 75

new ZM3_HERO_NVG_COLOR[] = {127, 255, 85}
#define ZM3_HERO_NVG_RADIUS 40
#define ZM3_HERO_NVG_ALPHA 50

/*****************************************************************/

new const REHEALTH_SOUND_MALE[][] = {"zombiemod/RegainHealthMale-1.wav", "zombiemod/RegainHealth-1.wav"}
new const REHEALTH_SOUND_FEMALE[][] = {"zombiemod/RegainHealth_FeMale-1.wav", "zombiemod/RegainHealth-1.wav"}
new const EVOLUTION_SOUND_MALE[][] = {"zombiemod/ZombieEvolution_Male.wav"}
new const EVOLUTION_SOUND_FEMALE[][] = {"zombiemod/ZombieEvolution_Female.wav"}

new const NEMESIS_APPEAR_SOUND[][] = {"zombiemod/NemesisAppear-1.wav", "zombiemod/NemesisAppear-2.wav"}


#define ZOMBIEMOD_SOUND_DIR "zombiemod" // Directory of Sound - where sounds of CS RED zombie are stored
#define DICTIONARY_FILE "csred_dictionary.txt"

/*		INFECTION SOUND - ONLY VICTIM CAN HEAR		*/

new const InfectionSound_Male[][] = {"human_death_01", "human_death_02"}
new const InfectionSound_Female[][] = {"human_death_female_01", "human_death_female_02"}

/*		SOUND PLAYED WHEN A ZOMBIE RESPAWNS		*/
new const ZOMBIE_APPEAR_SOUND[][] = {"zombiemod/zombie_infec2.wav", "zombiemod/zombie_infec1.wav", "zombiemod/ZM_RESPAWN_1.wav",
				"zombiemod/ZM_RESPAWN_2.wav", "zombiemod/ZM_RESPAWN_3.wav"}
				

/*		SOUND PLAYED WHEN A HERO APPEAR - (HERO MODE)		*/

new const HERO_APPEAR_SOUND[][] = {"HeroAppeared.wav"}

/*		SOME STUFF OF SOUND FOR ZOMBIE (ATK, HIT, PAIN, ETC....)	*/

new const ZombieAmbienceSound[][] = {"HandDraw.wav", "Hand_HitBody.wav", "Hand_HitWall.wav",
				"Hand_Slash.wav", "Hand_Stab.wav", "Zombie_Pain.wav", "Zombie_Die.wav", "Zombie_FallScream.wav"}


#define HERO_MODE_MAX_LIFE 3 // How many time Zombie can respawn (ONLY IN HERO MODE)


/*		PERSONAL INFO OF NEMESIS					*/

#define NEMESIS_HEALTH 8000.0 //Max health of Nemesis
#define NEMESIS_GRAVITY 0.5 // Gravity of Nemesis
#define NEMESIS_MODEL "nemesis" // Model of nemesis - the model has to put in xxx/cstrike/models/player/<MODEL NAME/<MODEL NAME>.mdl
#define NEMESIS_SOUND_DIRECTORY "default_zombie" // Sound directory of Nemesis (Pain sound, hand draw sound, ....)
#define NEMESIS_HUD "nemesis" // HUD HEALTH OF NEMESIS
#define NEMESIS_HUD_KILL "nemesis_hand" // HUD displayed on DeathMsg
#define NEMESIS_HAND "nemesis_hand" // Model of claw of Nemesis
#define NEMESIS_MAXSPEED 290.0 // How fast the Nemesis can run
#define NEMESIS_KNOCKBACK 2.25 

#define NEMESIS_SKILL_TIME 25.0
#define NEMESIS_SKILL_DURATION 10.0

#define NEMESIS_DAMAGE 500.0
#define NEMESIS_RESPAWN_TIME 15.0


/*		SURVIVOR (HERO MODE)		*/

#define SURVIVOR_HEALTH 200

/*		PERSONAL INFO OF TERMINATOR (ZOMBIE MOD 4)		*/


// Zombie Hero's Info
#define ZOMBIE_HERO_SOUND_DIRECTORY "TerminatorSound"
#define ZOMBIE_HERO_HEALTH 8000.0
#define ZOMBIE_HERO_GRAVITY 0.75
#define ZOMBIE_HERO_SPEED 280.0
#define ZOMBIE_HERO_KNOCKBACK 2.35
#define ZOMBIE_HERO_SKILL_TIME 25.0
#define ZOMBIE_HERO_DAMAGE 500.0
#define ZOMBIE_HERO_MODEL "zombie_hero"
#define ZOMBIE_HERO_HUD_KILL "zb_hr_hand"
#define ZOMBIE_HERO_HAND "zb_hero_hand"
#define ZOMBIE_HERO_DMG_HUMAN 0.0
#define ZOMBIE_HERO_DMG_HERO 10.0
#define ZOMBIE_HERO_GENDER 1 // The gender of the Terminator is Male

#define ZM4_ZOMBIE_HERO_HUD "ZombieHero"
#define ZM4_ZOMBIE_HERO_HAND "ZombieHeroHand"


/*		PERSONAL INFO OF SUPER HERO (ZOMBIE MOD 4)		*/

#define HM_HERO_HEALTH 2000.0
#define HM_HERO_DMG_ZOMBIE 500.0





#define TIME_REHEALTH 3.0 // Seconds zombie needs to Regain his / her health
#define ZU_TIME_REHEALTH 5.0 // Seconds zombie ness to Regain his / her health (Only in Zombie United GamePlay)
#define ZM3_TIME_REHEALTH 1.0 // Seconds zombie ness to Regain his / her health (Only in Zombie Mod 3 GamePlay)
#define ZM4_TIME_REHEALTH 5.0 // Seconds zombie needs to Regain his / her health

new const Float:fRegainAmount = 200.0 // Amount of Health zombie can Regain a time

#define DEFAULT_RESPAWN_TIME 5 // Seconds zombie needs to wait to be respawned
#define DEFAULT_UN_RESPAWN_TIME 10.0 // Seconds zombie needs to wait to be respawned (Only in Zombie United GamePlay)


#define DEFAULT_ZOMBIE_DAMAGE 500.0 // Damage that Zombie gives Super Hero (Zombie Mod 4)



/* SOME CONSTANTS - DONT CHANGE THIS */

const USE_USING = 2
const HIDE_MONEY = (1<<5)
const ATTRIB_BOMB = (1<<1)
const UNIT_SECOND = (1<<12)
