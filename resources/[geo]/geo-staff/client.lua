local playerList = {}

VehicleBones = {
    "chassis",
    "chassis_lowlod",
    "chassis_dummy",
    "seat_dside_f",
    "seat_dside_r",
    "seat_dside_r1",
    "seat_dside_r2",
    "seat_dside_r3",
    "seat_dside_r4",
    "seat_dside_r5",
    "seat_dside_r6",
    "seat_dside_r7",
    "seat_pside_f",
    "seat_pside_r",
    "seat_pside_r1",
    "seat_pside_r2",
    "seat_pside_r3",
    "seat_pside_r4",
    "seat_pside_r5",
    "seat_pside_r6",
    "seat_pside_r7",
    "window_lf1",
    "window_lf2",
    "window_lf3",
    "window_rf1",
    "window_rf2",
    "window_rf3",
    "window_lr1",
    "window_lr2",
    "window_lr3",
    "window_rr1",
    "window_rr2",
    "window_rr3",
    "door_dside_f",
    "door_dside_r",
    "door_pside_f",
    "door_pside_r",
    "handle_dside_f",
    "handle_dside_r",
    "handle_pside_f",
    "handle_pside_r",
    "wheel_lf",
    "wheel_rf",
    "wheel_lm1",
    "wheel_rm1",
    "wheel_lm2",
    "wheel_rm2",
    "wheel_lm3",
    "wheel_rm3",
    "wheel_lr",
    "wheel_rr",
    "suspension_lf",
    "suspension_rf",
    "suspension_lm",
    "suspension_rm",
    "suspension_lr",
    "suspension_rr",
    "spring_rf",
    "spring_lf",
    "spring_rr",
    "spring_lr",
    "transmission_f",
    "transmission_m",
    "transmission_r",
    "hub_lf",
    "hub_rf",
    "hub_lm1",
    "hub_rm1",
    "hub_lm2",
    "hub_rm2",
    "hub_lm3",
    "hub_rm3",
    "hub_lr",
    "hub_rr",
    "windscreen",
    "windscreen_r",
    "window_lf",
    "window_rf",
    "window_lr",
    "window_rr",
    "window_lm",
    "window_rm",
    "bodyshell",
    "bumper_f",
    "bumper_r",
    "wing_rf",
    "wing_lf",
    "bonnet",
    "boot",
    "exhaust",
    "exhaust_2",
    "exhaust_3",
    "exhaust_4",
    "exhaust_5",
    "exhaust_6",
    "exhaust_7",
    "exhaust_8",
    "exhaust_9",
    "exhaust_10",
    "exhaust_11",
    "exhaust_12",
    "exhaust_13",
    "exhaust_14",
    "exhaust_15",
    "exhaust_16",
    "engine",
    "overheat",
    "overheat_2",
    "petrolcap",
    "petroltank",
    "petroltank_l",
    "petroltank_r",
    "steering",
    "hbgrip_l",
    "hbgrip_r",
    "headlight_l",
    "headlight_r",
    "taillight_l",
    "taillight_r",
    "indicator_lf",
    "indicator_rf",
    "indicator_lr",
    "indicator_rr",
    "brakelight_l",
    "brakelight_r",
    "brakelight_m",
    "reversinglight_l",
    "reversinglight_r",
    "extralight_1",
    "extralight_2",
    "extralight_3",
    "extralight_4",
    "numberplate",
    "interiorlight",
    "siren1",
    "siren2",
    "siren3",
    "siren4",
    "siren5",
    "siren6",
    "siren7",
    "siren8",
    "siren9",
    "siren10",
    "siren11",
    "siren12",
    "siren13",
    "siren14",
    "siren15",
    "siren16",
    "siren17",
    "siren18",
    "siren19",
    "siren20",
    "siren_glass1",
    "siren_glass2",
    "siren_glass3",
    "siren_glass4",
    "siren_glass5",
    "siren_glass6",
    "siren_glass7",
    "siren_glass8",
    "siren_glass9",
    "siren_glass10",
    "siren_glass11",
    "siren_glass12",
    "siren_glass13",
    "siren_glass14",
    "siren_glass15",
    "siren_glass16",
    "siren_glass17",
    "siren_glass18",
    "siren_glass19",
    "siren_glass20",
    "spoiler",
    "struts",
    "misc_a",
    "misc_b",
    "misc_c",
    "misc_d",
    "misc_e",
    "misc_f",
    "misc_g",
    "misc_h",
    "misc_i",
    "misc_j",
    "misc_k",
    "misc_l",
    "misc_m",
    "misc_n",
    "misc_o",
    "misc_p",
    "misc_q",
    "misc_r",
    "misc_s",
    "misc_t",
    "misc_u",
    "misc_v",
    "misc_w",
    "misc_x",
    "misc_y",
    "misc_z",
    "misc_1",
    "misc_2",
    "weapon_1a",
    "weapon_1b",
    "weapon_1c",
    "weapon_1d",
    "weapon_1a_rot",
    "weapon_1b_rot",
    "weapon_1c_rot",
    "weapon_1d_rot",
    "weapon_2a",
    "weapon_2b",
    "weapon_2c",
    "weapon_2d",
    "weapon_2a_rot",
    "weapon_2b_rot",
    "weapon_2c_rot",
    "weapon_2d_rot",
    "weapon_3a",
    "weapon_3b",
    "weapon_3c",
    "weapon_3d",
    "weapon_3a_rot",
    "weapon_3b_rot",
    "weapon_3c_rot",
    "weapon_3d_rot",
    "weapon_4a",
    "weapon_4b",
    "weapon_4c",
    "weapon_4d",
    "weapon_4a_rot",
    "weapon_4b_rot",
    "weapon_4c_rot",
    "weapon_4d_rot",
    "turret_1base",
    "turret_1barrel",
    "turret_2base",
    "turret_2barrel",
    "turret_3base",
    "turret_3barrel",
    "ammobelt",
    "searchlight_base",
    "searchlight_light",
    "attach_female",
    "roof",
    "roof2",
    "soft_1",
    "soft_2",
    "soft_3",
    "soft_4",
    "soft_5",
    "soft_6",
    "soft_7",
    "soft_8",
    "soft_9",
    "soft_10",
    "soft_11",
    "soft_12",
    "soft_13",
    "forks",
    "mast",
    "carriage",
    "fork_l",
    "fork_r",
    "forks_attach",
    "frame_1",
    "frame_2",
    "frame_3",
    "frame_pickup_1",
    "frame_pickup_2",
    "frame_pickup_3",
    "frame_pickup_4",
    "freight_cont",
    "freight_bogey",
    "freightgrain_slidedoor",
    "door_hatch_r",
    "door_hatch_l",
    "tow_arm",
    "tow_mount_a",
    "tow_mount_b",
    "tipper",
    "combine_reel",
    "combine_auger",
    "slipstream_l",
    "slipstream_r",
    "arm_1",
    "arm_2",
    "arm_3",
    "arm_4",
    "scoop",
    "boom",
    "stick",
    "bucket",
    "shovel_2",
    "shovel_3",
    "Lookat_UpprPiston_head",
    "Lookat_LowrPiston_boom",
    "Boom_Driver",
    "cutter_driver",
    "vehicle_blocker",
    "extra_1",
    "extra_2",
    "extra_3",
    "extra_4",
    "extra_5",
    "extra_6",
    "extra_7",
    "extra_8",
    "extra_9",
    "extra_ten",
    "extra_11",
    "extra_12",
    "break_extra_1",
    "break_extra_2",
    "break_extra_3",
    "break_extra_4",
    "break_extra_5",
    "break_extra_6",
    "break_extra_7",
    "break_extra_8",
    "break_extra_9",
    "break_extra_10",
    "mod_col_1",
    "mod_col_2",
    "mod_col_3",
    "mod_col_4",
    "mod_col_5",
    "handlebars",
    "forks_u",
    "forks_l",
    "wheel_f",
    "swingarm",
    "wheel_r",
    "crank",
    "pedal_r",
    "pedal_l",
    "static_prop",
    "moving_prop",
    "static_prop2",
    "moving_prop2",
    "rudder",
    "rudder2",
    "wheel_rf1_dummy",
    "wheel_rf2_dummy",
    "wheel_rf3_dummy",
    "wheel_rb1_dummy",
    "wheel_rb2_dummy",
    "wheel_rb3_dummy",
    "wheel_lf1_dummy",
    "wheel_lf2_dummy",
    "wheel_lf3_dummy",
    "wheel_lb1_dummy",
    "wheel_lb2_dummy",
    "wheel_lb3_dummy",
    "bogie_front",
    "bogie_rear",
    "rotor_main",
    "rotor_rear",
    "rotor_main_2",
    "rotor_rear_2",
    "elevators",
    "tail",
    "outriggers_l",
    "outriggers_r",
    "rope_attach_a",
    "rope_attach_b",
    "prop_1",
    "prop_2",
    "elevator_l",
    "elevator_r",
    "rudder_l",
    "rudder_r",
    "prop_3",
    "prop_4",
    "prop_5",
    "prop_6",
    "prop_7",
    "prop_8",
    "rudder_2",
    "aileron_l",
    "aileron_r",
    "airbrake_l",
    "airbrake_r",
    "wing_l",
    "wing_r",
    "wing_lr",
    "wing_rr",
    "engine_l",
    "engine_r",
    "nozzles_f",
    "nozzles_r",
    "afterburner",
    "wingtip_1",
    "wingtip_2",
    "gear_door_fl",
    "gear_door_fr",
    "gear_door_rl1",
    "gear_door_rr1",
    "gear_door_rl2",
    "gear_door_rr2",
    "gear_door_rml",
    "gear_door_rmr",
    "gear_f",
    "gear_rl",
    "gear_lm1",
    "gear_rr",
    "gear_rm1",
    "gear_rm",
    "prop_left",
    "prop_right",
    "legs",
    "attach_male",
    "draft_animal_attach_lr",
    "draft_animal_attach_rr",
    "draft_animal_attach_lm",
    "draft_animal_attach_rm",
    "draft_animal_attach_lf",
    "draft_animal_attach_rf",
    "wheelcover_l",
    "wheelcover_r",
    "barracks",
    "pontoon_l",
    "pontoon_r",
    "no_ped_col_step_l",
    "no_ped_col_strut_1_l",
    "no_ped_col_strut_2_l",
    "no_ped_col_step_r",
    "no_ped_col_strut_1_r",
    "no_ped_col_strut_2_r",
    "light_cover",
    "emissives",
    "neon_l",
    "neon_r",
    "neon_f",
    "neon_b",
    "dashglow",
    "doorlight_lf",
    "doorlight_rf",
    "doorlight_lr",
    "doorlight_rr",
    "unknown_id",
    "dials",
    "engineblock",
    "bobble_head",
    "bobble_base",
    "bobble_hand",
    "chassis_Control"
}

PedBones = {
    SKEL_ROOT = 0x0,
    SKEL_Pelvis = 0x2E28,
    SKEL_L_Thigh = 0xE39F,
    SKEL_L_Calf = 0xF9BB,
    SKEL_L_Foot = 0x3779,
    SKEL_L_Toe0 = 0x83C,
    EO_L_Foot = 0x84C5,
    EO_L_Toe = 0x68BD,
    IK_L_Foot = 0xFEDD,
    PH_L_Foot = 0xE175,
    MH_L_Knee = 0xB3FE,
    SKEL_R_Thigh = 0xCA72,
    SKEL_R_Calf = 0x9000,
    SKEL_R_Foot = 0xCC4D,
    SKEL_R_Toe0 = 0x512D,
    EO_R_Foot = 0x1096,
    EO_R_Toe = 0x7163,
    IK_R_Foot = 0x8AAE,
    PH_R_Foot = 0x60E6,
    MH_R_Knee = 0x3FCF,
    RB_L_ThighRoll = 0x5C57,
    RB_R_ThighRoll = 0x192A,
    SKEL_Spine_Root = 0xE0FD,
    SKEL_Spine0 = 0x5C01,
    SKEL_Spine1 = 0x60F0,
    SKEL_Spine2 = 0x60F1,
    SKEL_Spine3 = 0x60F2,
    SKEL_L_Clavicle = 0xFCD9,
    SKEL_L_UpperArm = 0xB1C5,
    SKEL_L_Forearm = 0xEEEB,
    SKEL_L_Hand = 0x49D9,
    SKEL_L_Finger00 = 0x67F2,
    SKEL_L_Finger01 = 0xFF9,
    SKEL_L_Finger02 = 0xFFA,
    SKEL_L_Finger10 = 0x67F3,
    SKEL_L_Finger11 = 0x1049,
    SKEL_L_Finger12 = 0x104A,
    SKEL_L_Finger20 = 0x67F4,
    SKEL_L_Finger21 = 0x1059,
    SKEL_L_Finger22 = 0x105A,
    SKEL_L_Finger30 = 0x67F5,
    SKEL_L_Finger31 = 0x1029,
    SKEL_L_Finger32 = 0x102A,
    SKEL_L_Finger40 = 0x67F6,
    SKEL_L_Finger41 = 0x1039,
    SKEL_L_Finger42 = 0x103A,
    PH_L_Hand = 0xEB95,
    IK_L_Hand = 0x8CBD,
    RB_L_ForeArmRoll = 0xEE4F,
    RB_L_ArmRoll = 0x1470,
    MH_L_Elbow = 0x58B7,
    SKEL_R_Clavicle = 0x29D2,
    SKEL_R_UpperArm = 0x9D4D,
    SKEL_R_Forearm = 0x6E5C,
    SKEL_R_Hand = 0xDEAD,
    SKEL_R_Finger00 = 0xE5F2,
    SKEL_R_Finger01 = 0xFA10,
    SKEL_R_Finger02 = 0xFA11,
    SKEL_R_Finger10 = 0xE5F3,
    SKEL_R_Finger11 = 0xFA60,
    SKEL_R_Finger12 = 0xFA61,
    SKEL_R_Finger20 = 0xE5F4,
    SKEL_R_Finger21 = 0xFA70,
    SKEL_R_Finger22 = 0xFA71,
    SKEL_R_Finger30 = 0xE5F5,
    SKEL_R_Finger31 = 0xFA40,
    SKEL_R_Finger32 = 0xFA41,
    SKEL_R_Finger40 = 0xE5F6,
    SKEL_R_Finger41 = 0xFA50,
    SKEL_R_Finger42 = 0xFA51,
    PH_R_Hand = 0x6F06,
    IK_R_Hand = 0x188E,
    RB_R_ForeArmRoll = 0xAB22,
    RB_R_ArmRoll = 0x90FF,
    MH_R_Elbow = 0xBB0,
    SKEL_Neck_1 = 0x9995,
    SKEL_Head = 0x796E,
    IK_Head = 0x322C,
    FACIAL_facialRoot = 0xFE2C,
    FB_L_Brow_Out_000 = 0xE3DB,
    FB_L_Lid_Upper_000 = 0xB2B6,
    FB_L_Eye_000 = 0x62AC,
    FB_L_CheekBone_000 = 0x542E,
    FB_L_Lip_Corner_000 = 0x74AC,
    FB_R_Lid_Upper_000 = 0xAA10,
    FB_R_Eye_000 = 0x6B52,
    FB_R_CheekBone_000 = 0x4B88,
    FB_R_Brow_Out_000 = 0x54C,
    FB_R_Lip_Corner_000 = 0x2BA6,
    FB_Brow_Centre_000 = 0x9149,
    FB_UpperLipRoot_000 = 0x4ED2,
    FB_UpperLip_000 = 0xF18F,
    FB_L_Lip_Top_000 = 0x4F37,
    FB_R_Lip_Top_000 = 0x4537,
    FB_Jaw_000 = 0xB4A0,
    FB_LowerLipRoot_000 = 0x4324,
    FB_LowerLip_000 = 0x508F,
    FB_L_Lip_Bot_000 = 0xB93B,
    FB_R_Lip_Bot_000 = 0xC33B,
    FB_Tongue_000 = 0xB987,
    RB_Neck_1 = 0x8B93,
    SPR_L_Breast = 0xFC8E,
    SPR_R_Breast = 0x885F,
    IK_Root = 0xDD1C,
    SKEL_Neck_2 = 0x5FD4,
    SKEL_Pelvis1 = 0xD003,
    SKEL_PelvisRoot = 0x45FC,
    SKEL_SADDLE = 0x9524,
    MH_L_CalfBack = 0x1013,
    MH_L_ThighBack = 0x600D,
    SM_L_Skirt = 0xC419,
    MH_R_CalfBack = 0xB013,
    MH_R_ThighBack = 0x51A3,
    SM_R_Skirt = 0x7712,
    SM_M_BackSkirtRoll = 0xDBB,
    SM_L_BackSkirtRoll = 0x40B2,
    SM_R_BackSkirtRoll = 0xC141,
    SM_M_FrontSkirtRoll = 0xCDBB,
    SM_L_FrontSkirtRoll = 0x9B69,
    SM_R_FrontSkirtRoll = 0x86F1,
    SM_CockNBalls_ROOT = 0xC67D,
    SM_CockNBalls = 0x9D34,
    MH_L_Finger00 = 0x8C63,
    MH_L_FingerBulge00 = 0x5FB8,
    MH_L_Finger10 = 0x8C53,
    MH_L_FingerTop00 = 0xA244,
    MH_L_HandSide = 0xC78A,
    MH_Watch = 0x2738,
    MH_L_Sleeve = 0x933C,
    MH_R_Finger00 = 0x2C63,
    MH_R_FingerBulge00 = 0x69B8,
    MH_R_Finger10 = 0x2C53,
    MH_R_FingerTop00 = 0xEF4B,
    MH_R_HandSide = 0x68FB,
    MH_R_Sleeve = 0x92DC,
    FACIAL_jaw = 0xB21,
    FACIAL_underChin = 0x8A95,
    FACIAL_L_underChin = 0x234E,
    FACIAL_chin = 0xB578,
    FACIAL_chinSkinBottom = 0x98BC,
    FACIAL_L_chinSkinBottom = 0x3E8F,
    FACIAL_R_chinSkinBottom = 0x9E8F,
    FACIAL_tongueA = 0x4A7C,
    FACIAL_tongueB = 0x4A7D,
    FACIAL_tongueC = 0x4A7E,
    FACIAL_tongueD = 0x4A7F,
    FACIAL_tongueE = 0x4A80,
    FACIAL_L_tongueE = 0x35F2,
    FACIAL_R_tongueE = 0x2FF2,
    FACIAL_L_tongueD = 0x35F1,
    FACIAL_R_tongueD = 0x2FF1,
    FACIAL_L_tongueC = 0x35F0,
    FACIAL_R_tongueC = 0x2FF0,
    FACIAL_L_tongueB = 0x35EF,
    FACIAL_R_tongueB = 0x2FEF,
    FACIAL_L_tongueA = 0x35EE,
    FACIAL_R_tongueA = 0x2FEE,
    FACIAL_chinSkinTop = 0x7226,
    FACIAL_L_chinSkinTop = 0x3EB3,
    FACIAL_chinSkinMid = 0x899A,
    FACIAL_L_chinSkinMid = 0x4427,
    FACIAL_L_chinSide = 0x4A5E,
    FACIAL_R_chinSkinMid = 0xF5AF,
    FACIAL_R_chinSkinTop = 0xF03B,
    FACIAL_R_chinSide = 0xAA5E,
    FACIAL_R_underChin = 0x2BF4,
    FACIAL_L_lipLowerSDK = 0xB9E1,
    FACIAL_L_lipLowerAnalog = 0x244A,
    FACIAL_L_lipLowerThicknessV = 0xC749,
    FACIAL_L_lipLowerThicknessH = 0xC67B,
    FACIAL_lipLowerSDK = 0x7285,
    FACIAL_lipLowerAnalog = 0xD97B,
    FACIAL_lipLowerThicknessV = 0xC5BB,
    FACIAL_lipLowerThicknessH = 0xC5ED,
    FACIAL_R_lipLowerSDK = 0xA034,
    FACIAL_R_lipLowerAnalog = 0xC2D9,
    FACIAL_R_lipLowerThicknessV = 0xC6E9,
    FACIAL_R_lipLowerThicknessH = 0xC6DB,
    FACIAL_nose = 0x20F1,
    FACIAL_L_nostril = 0x7322,
    FACIAL_L_nostrilThickness = 0xC15F,
    FACIAL_noseLower = 0xE05A,
    FACIAL_L_noseLowerThickness = 0x79D5,
    FACIAL_R_noseLowerThickness = 0x7975,
    FACIAL_noseTip = 0x6A60,
    FACIAL_R_nostril = 0x7922,
    FACIAL_R_nostrilThickness = 0x36FF,
    FACIAL_noseUpper = 0xA04F,
    FACIAL_L_noseUpper = 0x1FB8,
    FACIAL_noseBridge = 0x9BA3,
    FACIAL_L_nasolabialFurrow = 0x5ACA,
    FACIAL_L_nasolabialBulge = 0xCD78,
    FACIAL_L_cheekLower = 0x6907,
    FACIAL_L_cheekLowerBulge1 = 0xE3FB,
    FACIAL_L_cheekLowerBulge2 = 0xE3FC,
    FACIAL_L_cheekInner = 0xE7AB,
    FACIAL_L_cheekOuter = 0x8161,
    FACIAL_L_eyesackLower = 0x771B,
    FACIAL_L_eyeball = 0x1744,
    FACIAL_L_eyelidLower = 0x998C,
    FACIAL_L_eyelidLowerOuterSDK = 0xFE4C,
    FACIAL_L_eyelidLowerOuterAnalog = 0xB9AA,
    FACIAL_L_eyelashLowerOuter = 0xD7F6,
    FACIAL_L_eyelidLowerInnerSDK = 0xF151,
    FACIAL_L_eyelidLowerInnerAnalog = 0x8242,
    FACIAL_L_eyelashLowerInner = 0x4CCF,
    FACIAL_L_eyelidUpper = 0x97C1,
    FACIAL_L_eyelidUpperOuterSDK = 0xAF15,
    FACIAL_L_eyelidUpperOuterAnalog = 0x67FA,
    FACIAL_L_eyelashUpperOuter = 0x27B7,
    FACIAL_L_eyelidUpperInnerSDK = 0xD341,
    FACIAL_L_eyelidUpperInnerAnalog = 0xF092,
    FACIAL_L_eyelashUpperInner = 0x9B1F,
    FACIAL_L_eyesackUpperOuterBulge = 0xA559,
    FACIAL_L_eyesackUpperInnerBulge = 0x2F2A,
    FACIAL_L_eyesackUpperOuterFurrow = 0xC597,
    FACIAL_L_eyesackUpperInnerFurrow = 0x52A7,
    FACIAL_forehead = 0x9218,
    FACIAL_L_foreheadInner = 0x843,
    FACIAL_L_foreheadInnerBulge = 0x767C,
    FACIAL_L_foreheadOuter = 0x8DCB,
    FACIAL_skull = 0x4221,
    FACIAL_foreheadUpper = 0xF7D6,
    FACIAL_L_foreheadUpperInner = 0xCF13,
    FACIAL_L_foreheadUpperOuter = 0x509B,
    FACIAL_R_foreheadUpperInner = 0xCEF3,
    FACIAL_R_foreheadUpperOuter = 0x507B,
    FACIAL_L_temple = 0xAF79,
    FACIAL_L_ear = 0x19DD,
    FACIAL_L_earLower = 0x6031,
    FACIAL_L_masseter = 0x2810,
    FACIAL_L_jawRecess = 0x9C7A,
    FACIAL_L_cheekOuterSkin = 0x14A5,
    FACIAL_R_cheekLower = 0xF367,
    FACIAL_R_cheekLowerBulge1 = 0x599B,
    FACIAL_R_cheekLowerBulge2 = 0x599C,
    FACIAL_R_masseter = 0x810,
    FACIAL_R_jawRecess = 0x93D4,
    FACIAL_R_ear = 0x1137,
    FACIAL_R_earLower = 0x8031,
    FACIAL_R_eyesackLower = 0x777B,
    FACIAL_R_nasolabialBulge = 0xD61E,
    FACIAL_R_cheekOuter = 0xD32,
    FACIAL_R_cheekInner = 0x737C,
    FACIAL_R_noseUpper = 0x1CD6,
    FACIAL_R_foreheadInner = 0xE43,
    FACIAL_R_foreheadInnerBulge = 0x769C,
    FACIAL_R_foreheadOuter = 0x8FCB,
    FACIAL_R_cheekOuterSkin = 0xB334,
    FACIAL_R_eyesackUpperInnerFurrow = 0x9FAE,
    FACIAL_R_eyesackUpperOuterFurrow = 0x140F,
    FACIAL_R_eyesackUpperInnerBulge = 0xA359,
    FACIAL_R_eyesackUpperOuterBulge = 0x1AF9,
    FACIAL_R_nasolabialFurrow = 0x2CAA,
    FACIAL_R_temple = 0xAF19,
    FACIAL_R_eyeball = 0x1944,
    FACIAL_R_eyelidUpper = 0x7E14,
    FACIAL_R_eyelidUpperOuterSDK = 0xB115,
    FACIAL_R_eyelidUpperOuterAnalog = 0xF25A,
    FACIAL_R_eyelashUpperOuter = 0xE0A,
    FACIAL_R_eyelidUpperInnerSDK = 0xD541,
    FACIAL_R_eyelidUpperInnerAnalog = 0x7C63,
    FACIAL_R_eyelashUpperInner = 0x8172,
    FACIAL_R_eyelidLower = 0x7FDF,
    FACIAL_R_eyelidLowerOuterSDK = 0x1BD,
    FACIAL_R_eyelidLowerOuterAnalog = 0x457B,
    FACIAL_R_eyelashLowerOuter = 0xBE49,
    FACIAL_R_eyelidLowerInnerSDK = 0xF351,
    FACIAL_R_eyelidLowerInnerAnalog = 0xE13,
    FACIAL_R_eyelashLowerInner = 0x3322,
    FACIAL_L_lipUpperSDK = 0x8F30,
    FACIAL_L_lipUpperAnalog = 0xB1CF,
    FACIAL_L_lipUpperThicknessH = 0x37CE,
    FACIAL_L_lipUpperThicknessV = 0x38BC,
    FACIAL_lipUpperSDK = 0x1774,
    FACIAL_lipUpperAnalog = 0xE064,
    FACIAL_lipUpperThicknessH = 0x7993,
    FACIAL_lipUpperThicknessV = 0x7981,
    FACIAL_L_lipCornerSDK = 0xB1C,
    FACIAL_L_lipCornerAnalog = 0xE568,
    FACIAL_L_lipCornerThicknessUpper = 0x7BC,
    FACIAL_L_lipCornerThicknessLower = 0xDD42,
    FACIAL_R_lipUpperSDK = 0x7583,
    FACIAL_R_lipUpperAnalog = 0x51CF,
    FACIAL_R_lipUpperThicknessH = 0x382E,
    FACIAL_R_lipUpperThicknessV = 0x385C,
    FACIAL_R_lipCornerSDK = 0xB3C,
    FACIAL_R_lipCornerAnalog = 0xEE0E,
    FACIAL_R_lipCornerThicknessUpper = 0x54C3,
    FACIAL_R_lipCornerThicknessLower = 0x2BBA,
    MH_MulletRoot = 0x3E73,
    MH_MulletScaler = 0xA1C2,
    MH_Hair_Scale = 0xC664,
    MH_Hair_Crown = 0x1675,
    SM_Torch = 0x8D6,
    FX_Light = 0x8959,
    FX_Light_Scale = 0x5038,
    FX_Light_Switch = 0xE18E,
    BagRoot = 0xAD09,
    BagPivotROOT = 0xB836,
    BagPivot = 0x4D11,
    BagBody = 0xAB6D,
    BagBone_R = 0x937,
    BagBone_L = 0x991,
    SM_LifeSaver_Front = 0x9420,
    SM_R_Pouches_ROOT = 0x2962,
    SM_R_Pouches = 0x4141,
    SM_L_Pouches_ROOT = 0x2A02,
    SM_L_Pouches = 0x4B41,
    SM_Suit_Back_Flapper = 0xDA2D,
    SPR_CopRadio = 0x8245,
    SM_LifeSaver_Back = 0x2127,
    MH_BlushSlider = 0xA0CE,
    SKEL_Tail_01 = 0x347,
    SKEL_Tail_02 = 0x348,
    MH_L_Concertina_B = 0xC988,
    MH_L_Concertina_A = 0xC987,
    MH_R_Concertina_B = 0xC8E8,
    MH_R_Concertina_A = 0xC8E7,
    MH_L_ShoulderBladeRoot = 0x8711,
    MH_L_ShoulderBlade = 0x4EAF,
    MH_R_ShoulderBladeRoot = 0x3A0A,
    MH_R_ShoulderBlade = 0x54AF,
    FB_R_Ear_000 = 0x6CDF,
    SPR_R_Ear = 0x63B6,
    FB_L_Ear_000 = 0x6439,
    SPR_L_Ear = 0x5B10,
    FB_TongueA_000 = 0x4206,
    FB_TongueB_000 = 0x4207,
    FB_TongueC_000 = 0x4208,
    SKEL_L_Toe1 = 0x1D6B,
    SKEL_R_Toe1 = 0xB23F,
    SKEL_Tail_03 = 0x349,
    SKEL_Tail_04 = 0x34A,
    SKEL_Tail_05 = 0x34B,
    SPR_Gonads_ROOT = 0xBFDE,
    SPR_Gonads = 0x1C00,
    FB_L_Brow_Out_001 = 0xE3DB,
    FB_L_Lid_Upper_001 = 0xB2B6,
    FB_L_Eye_001 = 0x62AC,
    FB_L_CheekBone_001 = 0x542E,
    FB_L_Lip_Corner_001 = 0x74AC,
    FB_R_Lid_Upper_001 = 0xAA10,
    FB_R_Eye_001 = 0x6B52,
    FB_R_CheekBone_001 = 0x4B88,
    FB_R_Brow_Out_001 = 0x54C,
    FB_R_Lip_Corner_001 = 0x2BA6,
    FB_Brow_Centre_001 = 0x9149,
    FB_UpperLipRoot_001 = 0x4ED2,
    FB_UpperLip_001 = 0xF18F,
    FB_L_Lip_Top_001 = 0x4F37,
    FB_R_Lip_Top_001 = 0x4537,
    FB_Jaw_001 = 0xB4A0,
    FB_LowerLipRoot_001 = 0x4324,
    FB_LowerLip_001 = 0x508F,
    FB_L_Lip_Bot_001 = 0xB93B,
    FB_R_Lip_Bot_001 = 0xC33B,
    FB_Tongue_001 = 0xB987
}

RegisterCommand('veh', function(source, args)
	if MyCharacter.username == nil then return end
	local veh = Shared.SpawnVehicle(args[1], GetEntityCoords(PlayerPedId()))
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
	TriggerEvent('AddKey', veh)
	SetOwned(veh)
end)

local bones = false
RegisterCommand('bones', function()
	bones = not bones
	Citizen.CreateThread(function()
		while bones do
			Wait(0)
			local veh = GetVehiclePedIsIn(PlayerPedId(), false)
			for k,v in pairs(VehicleBones) do
				local ind = GetEntityBoneIndexByName(veh, v)
				if ind ~= -1 then
					local pos = GetWorldPositionOfEntityBone(veh, ind)
					Shared.WorldText(v, pos)
				end
			end

			--[[ local ped = PlayerPedId()
			for k,v in pairs(PedBones) do
				local ind = GetEntityBoneIndexByName(ped, k)
				local pos = GetWorldPositionOfEntityBone(ped, ind)
				Shared.WorldText(k, pos)
			end ]]
		end
	end)
end)

local _ids = false
RegisterKeyMapping('+players', '[General] Player IDs', 'keyboard', 'HOME')

RegisterCommand('+players', function(source, args, raw)
	if not ControlModCheck(raw) then return end
	_ids = true
	TriggerServerEvent('GetPlayerList')
	local nTime = GetGameTimer()
	local staff = MyCharacter.username
	while _ids do
		Wait(0)
		for k,v in pairs(GetActivePlayers()) do
			local pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(v), 0.0, 0.0, 1.1)
			if Vdist3(pos, GetEntityCoords(Shared.Ped)) <= 5.0 then
				local sid = GetPlayerServerId(v)
				local str = Player(sid).state.cid
				if staff then
					str = str..' ['..sid..']'
				end
				local a, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
				if a then
					Shared.DrawText(str, x, y, 1, {255, 255, 255, 255}, 1.0, true, true, false)
				end
			end
		end

		if GetGameTimer() - nTime >= 30000 then
			TriggerServerEvent('GetPlayerList')
			nTime = GetGameTimer()
		end
		
		Shared.DrawText(('%s Player(s) Online'):format(#playerList), 0.9, 0.965, 4, {255, 255, 255, 255}, 0.55, true, true, false)
	end
end)

RegisterCommand('-players', function()
	_ids = false
end)

local debug = false
function EntityDeubbger()
	debug = not debug
	if debug then
		Citizen.CreateThread(function()
			while debug do
				Wait(0)
				local ray = Shared.Raycast(100)
				local ent = ray.HitEntity
				if GetEntityType(ent) == 0 then
					ent = lastHit
				else
					lastHit = ent
				end
				local pos = GetEntityCoords(ent)
				local found, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
				if found then
					DebugText('Health: '..GetEntityHealth(ent), x, y)
					DebugText('Model: '..GetEntityModel(ent), x, y + 0.03)
					DebugText('Coordinates: '..GetEntityCoords(ent), x, y + 0.06)
					DebugText('Rotation: '..GetEntityRotation(ent), x, y + 0.09)
					DebugText(('Is Networked: %s'):format(NetworkGetEntityIsNetworked(ent)), x, y + 0.12)
					DebugText(('Player Server ID: %s'):format(GetPlayerServerId(NetworkGetPlayerIndexFromPed(ent))), x, y + 0.15)
					DebugText(('Exists: %s'):format(DoesEntityExist(ent)), x, y + 0.18)
					DebugText(('Heading: %s'):format(GetEntityHeading(ent)), x, y + 0.21)
				end
			end
		end)
	end
end

RegisterCommand('debug', EntityDeubbger)

function DebugText(str, x, y, width, height)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(str)
	DrawText(x,y)
	local factor = (string.len(str)) / 370
    DrawRect(x,y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 150)
end

Menu.CreateMenu('Staff', 'Staff')
Menu.CreateSubMenu('Users', 'Staff', 'Users')
Menu.CreateSubMenu('Duty', 'Staff', 'Duty')
Menu.CreateSubMenu('UserManagement', 'Users', 'User')
Menu.CreateSubMenu('Utils', 'Staff', 'Utils')

local _duties = {
	'Police',
	'EMS',
	'DOJ'
}

local noclip = false
function Staff()

	if Menu.CurrentMenu then
		return
	end

	if MyCharacter.username ~= nil then
		local players = {}
		local aPlayer = {}
		local sid = -1

		Menu.OpenMenu('Staff')
		TriggerServerEvent('GetPlayerList')
		while Menu.CurrentMenu do
			Wait(0)

			if Menu.CurrentMenu == 'Staff' then
				if Menu.Button('Manage Users') then
					Menu.OpenMenu('Users')
				end

				if Menu.Button('Teleport to Waypoint') then
					local blip = GetFirstBlipInfoId(8)
					if blip ~= 0 then
						local pos = GetBlipCoords(blip)
						SetEntityCoords(Shared.Ped, pos.x, pos.y, 100.0)
						local found, z = false, nil
						while not found do
							Wait(0)
							found, z = GetGroundZFor_3dCoord(pos.x, pos.y, 1000.0, 0)
						end

						SetEntityCoords(Shared.Ped, pos.x, pos.y, z)
						SetEntityCoords(Shared.Ped, pos.x, pos.y, z)
					end
				end

				if Menu.Button('Teleport to Coords') then
					local coords = Shared.TextInput('Coords')
					local list = SplitString(coords, ' ')
					if #list > 2 then
						for k,v in pairs(list) do
							list[k] = tonumber(v)
						end
						SetEntityCoords(Shared.Ped, table.unpack(list))
					end
				end

				if Menu.Button('Spawn Vehicle') then
					local model = Shared.TextInput('Vehicle Model')
					local veh = Shared.SpawnVehicle(model, GetEntityCoords(PlayerPedId()))
    				SetPedIntoVehicle(PlayerPedId(), veh, -1)
    				TriggerEvent('AddKey', veh)
				end

				if Menu.Button('Spawn Item') then
					TriggerServerEvent('give', Shared.TextInput('Item'), Shared.TextInput('Amount'))
				end

				Menu.MenuButton('Utils', 'Utils')
				Menu.MenuButton('Duty', 'Duty')

			elseif Menu.CurrentMenu == 'Users' then
				for k,v in pairs(playerList) do
					local id = GetPlayerFromServerId(v.serverID)
					if Menu.Button(('%s [%s] %s'):format(v.name, v.serverID, IsAvailable(id))) then
						aPlayer = v
						sid = v.serverID
						Menu.OpenMenu('UserManagement')
					end
				end
			elseif Menu.CurrentMenu == 'UserManagement' then
				if Menu.Button('Teleport to Player') then
					TriggerServerEvent('StaffTPMe', aPlayer.serverID)
				end

				if Menu.Button('Teleport to You') then
					TriggerServerEvent('Staff:TP', sid, GetEntityCoords(PlayerPedId()))
				end

				if Menu.Button('Kick Player') then
					local reason = Shared.TextInput('Kick Reason')
					if reason ~= '' then
						ExecuteCommand('kick '..sid..' '..reason)
					end
				end

				if Menu.Button('Ban Player') then
					local reason = Shared.TextInput('Ban Reason')
					if reason ~= '' then
						ExecuteCommand('ban '..sid..' '..reason)
					end
				end

				if Menu.Button('Freeze') then
					TriggerServerEvent('Staff:Freeze', sid)
				end
			elseif Menu.CurrentMenu == 'Utils' then
				if Menu.Button('Noclip', noclip == true and 'On' or 'Off') then
					Noclip()
				end

				if Menu.Button('Fix Vehicle') then
					SetVehicleFixed(Shared.CurrentVehicle)
				end
			elseif Menu.CurrentMenu == 'Duty' then
				for k,v in pairs(_duties) do
					if Menu.Button(v) then
						TriggerServerEvent('Duty', v)
					end
				end
			end

			Menu.Display()
		end
	end
end

RegisterCommand('staff', Staff)

RegisterCommand('anim', function(source, args)
	LoadAnim(args[1])
	TaskPlayAnim(PlayerPedId(), args[1], args[2], 8.0, -8, 2000, 1, 0, 0, 0, 0)
end)

local _x = false
RegisterCommand('xyz', function()
	_x = not _x
	while _x do
		Wait(0)
		local pos = GetEntityCoords(PlayerPedId())
		DrawRect(0.98, 0.15, 0.1, 0.11, 25, 25, 25, 150)
		Shared.DrawText('X: '..string.format('%.2f', pos.x), 0.94, 0.1, 0, {255, 255, 255, 255}, 0.35, false, false, false)
		Shared.DrawText('Y: '..string.format('%.2f', pos.y), 0.94, 0.125, 0, {255, 255, 255, 255}, 0.35, false, false, false)
		Shared.DrawText('Z: '..string.format('%.2f', pos.z), 0.94, 0.15, 0, {255, 255, 255, 255}, 0.35, false, false, false)
		Shared.DrawText('W: '..string.format('%.2f', GetEntityHeading(PlayerPedId())), 0.94, 0.175, 0, {255, 255, 255, 255}, 0.35, false, false, false)
	end
end)

RegisterNetEvent('GetPlayerList')
AddEventHandler('GetPlayerList', function(list)
	playerList = list
end)

RegisterNetEvent('Heal')
AddEventHandler('Heal', function()
	SetEntityHealth(Shared.Ped, 200)
end)

function IsAvailable(id)
	return id ~= -1 and '' or '[In Another Region]'
end

local speed = 0.5
local controls = {220, 221}
function Noclip()
	noclip = not noclip
	if noclip then
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
		SetCamCoord(cam, GetEntityCoords(Shared.Ped))
		SetEntityCoords(Shared.Ped, GetEntityCoords(Shared.Ped))
		SetCamRot(cam, GetEntityRotation(Shared.Ped))
		RenderScriptCams(1, 0, 0, 1, 1)
		CreateThread(function()
			while noclip do
				Wait(0)
				SetEntityVisible(Shared.Ped, false, 0)
				SetEntityCoords(Shared.Ped, GetCamCoord(cam))
				DisableControlAction(0, 220, true)
				DisableControlAction(0, 221, true)
				DisableControlAction(0, 36, true)

				local rot = {}
				rot.x, rot.y, rot.z =  table.unpack(GetCamRot(cam))
				SetEntityHeading(Shared.Ped, rot.z)
				local x = GetDisabledControlNormal(0, 220)
				local y = GetDisabledControlNormal(0, 221)

				if math.abs(x) > 0 and math.abs(y) > 0 then
					rot.z = rot.z + x * -10.0

					local yX = y * -5.0
					rot.x = rot.x + yX
					SetCamRot(cam, rot.x, rot.y, rot.z)
				end

				local right, forward, up, pos = GetCamMatrix(cam)
				local _speed = speed

				if IsDisabledControlPressed(0, 36) then
					_speed = 0.1
				end

				if IsControlPressed(0, 32) then
					SetCamCoord(cam, GetCamCoord(cam) + (forward * _speed))
				end

				if IsControlPressed(0, 31) then
					SetCamCoord(cam, GetCamCoord(cam) - (forward * _speed))
				end

				if IsControlPressed(0, 30) then
					SetCamCoord(cam, GetCamCoord(cam) + (right * _speed))
				end

				if IsControlPressed(0, 34) then
					SetCamCoord(cam, GetCamCoord(cam) - (right * _speed))
				end

				if IsControlJustPressed(0, 21) then
					speed = speed + 0.5 <= 10.0 and speed + 0.5 or 0.5
				end

				Shared.InteractText('Speed: '..speed)
			end
			local rot = {}
			rot.x, rot.y, rot.z =  table.unpack(GetCamRot(cam))

			print(GetCamRot(cam), GetCamCoord(cam))

			SetEntityVisible(Shared.Ped, true, 0)
			DestroyCam(cam)
			RenderScriptCams(0, 0, 0, 1, 1)
			SetFocusEntity(ped)
			SetGameplayCamRawPitch(rot.y)
			SetGameplayCamRawYaw(rot.z)
			Wait(0)
			SetEntityHeading(Shared.Ped, rot.z)
			SetGameplayCamRelativeHeading(0.0)
		end)
	end
end

RegisterKeyMapping('noclip', '[General] Noclip', 'keyboard', 'F2')

RegisterCommand('noclip', function()
	local dev = GetConvar('sv_dev', 'false') == 'true'
	if MyCharacter and MyCharacter.username or dev then
		Noclip()
	end
end)

local conceal = {}
RegisterNetEvent('Conceal', function(id, val, sid)
    local myID = GetPlayerServerId(PlayerId())

    if myID ~= id then
        conceal[id] = val

        while conceal[id] do
            Wait(1000)
            local player = GetPlayerFromServerId(id)
            if player ~= -1 and sid ~= myID then
                NetworkConcealPlayer(player, true)
            end
        end

        local player = GetPlayerFromServerId(id)
        if player ~= -1 then
            NetworkConcealPlayer(player, false)
        end
    end
end)

--[[ RegisterCommand('wepa', function(source, args)
    local wep = GetHashKey(args[1])
    RequestWeaponAsset(wep)
    while not HasWeaponAssetLoaded(wep) do
        Wait(0)
    end
    local prop = CreateWeaponObject(wep, 0, vector3(436.19, -993.66, 31.09), true, 1.0, 0);
    SetEntityRotation(prop, 0.0, 0.0, 90.0, 0)
    SetWeaponObjectTintIndex(prop, tonumber(args[2]))
    GiveWeaponComponentToWeaponObject(prop, `COMPONENT_SNIPERRIFLE_VARMOD_LUXE`)
    Wait(5000)
    DeleteEntity(prop)
end) ]]