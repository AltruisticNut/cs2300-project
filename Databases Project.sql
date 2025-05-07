-- Create database for Minecraft Advancements Tracker
-- Sys was the default name of the database schema created, so we're just using that :P
CREATE DATABASE IF NOT EXISTS sys
USE sys;

-- Worlds table
CREATE TABLE Worlds (
    world_id INT PRIMARY KEY AUTO_INCREMENT,
    world_name VARCHAR(255) NOT NULL,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (world_name)
);

-- Tabs table
CREATE TABLE Tabs (
    tab_id INT PRIMARY KEY AUTO_INCREMENT,
    world_id INT NOT NULL,
    tab_name ENUM('Minecraft', 'Nether', 'The End', 'Adventure', 'Husbandry') NOT NULL,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    FOREIGN KEY (world_id) REFERENCES Worlds(world_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Advancements table
CREATE TABLE Advancements (
    advancement_id INT PRIMARY KEY AUTO_INCREMENT,
    tab_id INT NOT NULL,
    advancement_name VARCHAR(255) NOT NULL,
    description TEXT,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    is_completed BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    parent_advancement_id INT NULL,
    rewards TEXT,
    resource_path VARCHAR(255),
    FOREIGN KEY (tab_id) REFERENCES Tabs(tab_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (parent_advancement_id) REFERENCES Advancements(advancement_id) ON DELETE SET NULL ON UPDATE CASCADE,
    UNIQUE (tab_id, advancement_name)
);

-- Requirements table
CREATE TABLE Requirements (
    requirement_id INT PRIMARY KEY AUTO_INCREMENT,
    advancement_id INT NOT NULL,
    requirement_type ENUM('boolean', 'integer', 'float', 'array') NOT NULL,
    requirement_value TEXT NOT NULL,
    FOREIGN KEY (advancement_id) REFERENCES Advancements(advancement_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Guides table
CREATE TABLE Guides (
    guide_id INT PRIMARY KEY AUTO_INCREMENT,
    advancement_id INT NOT NULL,
    guide_link VARCHAR(255) NOT NULL,
    guide_description TEXT,
    source_type ENUM('YouTube', 'Minecraft Wiki', 'Other') NOT NULL,
    FOREIGN KEY (advancement_id) REFERENCES Advancements(advancement_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes for better query performance
CREATE INDEX idx_advancement_name ON Advancements(advancement_name);
CREATE INDEX idx_tab_name ON Tabs(tab_name);
CREATE INDEX idx_world_name ON Worlds(world_name);
CREATE INDEX idx_guides_source ON Guides(source_type);


-- Inserting base advancements

-- Insert a sample world
INSERT INTO Worlds (world_name) VALUES ('SurvivalWorld');

-- Insert tabs for the world
INSERT INTO Tabs (world_id, tab_name) VALUES
(1, 'Minecraft'),
(1, 'Nether'),
(1, 'The End'),
(1, 'Adventure'),
(1, 'Husbandry');

ALTER TABLE Advancements AUTO_INCREMENT = 1;

INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
-- Minecraft Tab (Tab ID: 1, Advancements 1–16)
(1, 'Minecraft', 'The heart and story of the game', FALSE, TRUE, NULL, NULL, 'minecraft:story/root'), -- 1
(1, 'Stone Age', 'Mine stone with your new pickaxe', FALSE, TRUE, 1, NULL, 'minecraft:story/mine_stone'), -- 2
(1, 'Getting an Upgrade', 'Construct a better pickaxe', FALSE, TRUE, 2, NULL, 'minecraft:story/upgrade_tools'), -- 3
(1, 'Acquire Hardware', 'Smelt an iron ingot', FALSE, TRUE, 2, NULL, 'minecraft:story/smelt_iron'), -- 4
(1, 'Suit Up', 'Protect yourself with a piece of iron armor', FALSE, TRUE, 4, NULL, 'minecraft:story/obtain_armor'), -- 5
(1, 'Hot Stuff', 'Fill a bucket with lava', FALSE, TRUE, 4, NULL, 'minecraft:story/lava_bucket'), -- 6
(1, 'Isn''t It Iron Pick', 'Upgrade your pickaxe', FALSE, TRUE, 4, NULL, 'minecraft:story/iron_tools'), -- 7
(1, 'Not Today, Thank You', 'Block a projectile using your shield', FALSE, TRUE, 5, NULL, 'minecraft:story/deflect_arrow'), -- 8
(1, 'Ice Bucket Challenge', 'Obtain a block of obsidian', FALSE, TRUE, 6, NULL, 'minecraft:story/form_obsidian'), -- 9
(1, 'Diamonds!', 'Acquire diamonds', FALSE, TRUE, 7, NULL, 'minecraft:story/mine_diamond'), -- 10
(1, 'We Need to Go Deeper', 'Build, light and enter a Nether Portal', FALSE, TRUE, 9, NULL, 'minecraft:story/enter_the_nether'), -- 11
(1, 'Cover Me with Diamonds', 'Diamond armor saves lives', FALSE, TRUE, 10, NULL, 'minecraft:story/shiny_gear'), -- 12
(1, 'Enchanter', 'Enchant an item at an Enchanting Table', FALSE, TRUE, 10, NULL, 'minecraft:story/enchant_item'), -- 13
(1, 'Zombie Doctor', 'Weaken and then cure a Zombie Villager', FALSE, TRUE, 11, '100 experience', 'minecraft:story/cure_zombie_villager'), -- 14
(1, 'Eye Spy', 'Follow an Eye of Ender', FALSE, TRUE, 11, NULL, 'minecraft:story/follow_ender_eye'), -- 15
(1, 'The End?', 'Enter the End Portal', FALSE, TRUE, 15, NULL, 'minecraft:story/enter_the_end'), -- 16

-- Nether Tab (Tab ID: 2, Advancements 17–40)
(2, 'Nether', 'Bring summer clothes', FALSE, TRUE, NULL, NULL, 'minecraft:nether/root'), -- 17
(2, 'Return to Sender', 'Destroy a Ghast with a fireball', FALSE, TRUE, 17, '50 experience', 'minecraft:nether/return_to_sender'), -- 18
(2, 'Those Were the Days', 'Enter a Bastion Remnant', FALSE, TRUE, 17, NULL, 'minecraft:nether/find_bastion'), -- 19
(2, 'Hidden in the Depths', 'Obtain Ancient Debris', FALSE, TRUE, 17, NULL, 'minecraft:nether/obtain_ancient_debris'), -- 20
(2, 'Subspace Bubble', 'Use the Nether to travel 7 km in the Overworld', FALSE, TRUE, 17, '100 experience', 'minecraft:nether/fast_travel'), -- 21
(2, 'A Terrible Fortress', 'Break your way into a Nether Fortress', FALSE, TRUE, 17, NULL, 'minecraft:nether/find_fortress'), -- 22
(2, 'Who is Cutting Onions?', 'Obtain Crying Obsidian', FALSE, TRUE, 17, NULL, 'minecraft:nether/obtain_crying_obsidian'), -- 23
(2, 'Oh Shiny', 'Distract Piglins with gold', FALSE, TRUE, 17, NULL, 'minecraft:nether/distract_piglin'), -- 24
(2, 'This Boat Has Legs', 'Ride a Strider with a Warped Fungus on a Stick', FALSE, TRUE, 23, NULL, 'minecraft:nether/ride_strider'),-- 25
(2, 'Uneasy Alliance', 'Rescue a Ghast from the Nether, bring it safely home to the Overworld... and then kill it', FALSE, TRUE, 18, '100 experience', 'minecraft:nether/uneasy_alliance'), -- 26
(2, 'War Pigs', 'Loot a chest in a Bastion Remnant', FALSE, TRUE, 19, NULL, 'minecraft:nether/loot_bastion'), -- 27
(2, 'Country Lode, Take Me Home', 'Use a Compass on a Lodestone', FALSE, TRUE, 20, NULL, 'minecraft:nether/use_lodestone'), -- 28
(2, 'Cover Me in Debris', 'Get a full suit of Netherite armor', FALSE, TRUE, 20, '100 experience', 'minecraft:nether/netherite_armor'), -- 29
(2, 'Spooky Scary Skeleton', 'Obtain a Wither Skeleton''s skull', FALSE, TRUE, 22, NULL, 'minecraft:nether/get_wither_skull'), -- 30
(2, 'Into Fire', 'Relieve a Blaze of its rod', FALSE, TRUE, 22, NULL, 'minecraft:nether/obtain_blaze_rod'), -- 31
(2, 'Not Quite "Nine" Lives', 'Charge a Respawn Anchor to the maximum', FALSE, TRUE, 23, NULL, 'minecraft:nether/charge_respawn_anchor'), -- 32
(2, 'Feels Like Home', 'Take a Strider for a loooong ride on a lava lake in the Overworld', FALSE, TRUE, 25, '50 experience', 'minecraft:nether/ride_strider_in_overworld_lava'), -- 33
(2, 'Hot Tourist Destinations', 'Explore all Nether biomes', FALSE, TRUE, 22, NULL, 'minecraft:nether/explore_nether'), -- 34
(2, 'Withering Heights', 'Summon the Wither', FALSE, TRUE, 30, NULL, 'minecraft:nether/summon_wither'), -- 35
(2, 'Local Brewery', 'Brew a potion', FALSE, TRUE, 31, NULL, 'minecraft:nether/brew_potion'), -- 36
(2, 'Bring Home the Beacon', 'Construct and place a Beacon', FALSE, TRUE, 35, NULL, 'minecraft:nether/create_beacon'), -- 37
(2, 'A Furious Cocktail', 'Have every potion effect applied at the same time', FALSE, TRUE, 36, '100 experience', 'minecraft:nether/all_potions'), -- 38
(2, 'Beaconator', 'Bring a beacon to full power', FALSE, TRUE, 37, NULL, 'minecraft:nether/create_full_beacon'), -- 39
(2, 'How Did We Get Here?', 'Have every effect applied at the same time', FALSE, TRUE, 38, '1000 experience', 'minecraft:nether/all_effects'), -- 40

-- The End Tab (Tab ID: 3, Advancements 41–49)
(3, 'The End', 'Or the beginning?', FALSE, TRUE, NULL, NULL, 'minecraft:end/root'), -- 41
(3, 'Free the End', 'Good luck', FALSE, TRUE, 41, NULL, 'minecraft:end/kill_dragon'), -- 42
(3, 'The Next Generation', 'Hold the Dragon Egg', FALSE, TRUE, 42, NULL, 'minecraft:end/dragon_egg'), -- 43
(3, 'Remote Getaway', 'Escape the island', FALSE, TRUE, 42, NULL, 'minecraft:end/enter_end_gateway'), -- 44
(3, 'The End... Again...', 'Respawn the Ender Dragon', FALSE, TRUE, 42, NULL, 'minecraft:end/respawn_dragon'), -- 45
(3, 'You Need a Mint', 'Collect dragon''s breath in a glass bottle', FALSE, TRUE, 42, NULL, 'minecraft:end/dragon_breath'), -- 46
(3, 'The City at the End of the Game', 'Go on in, what could happen?', FALSE, TRUE, 44, NULL, 'minecraft:end/find_end_city'), -- 47
(3, 'Sky''s the Limit', 'Find elytra', FALSE, TRUE, 47, NULL, 'minecraft:end/elytra'), -- 48
(3, 'Great View From Up Here', 'Levitate up 50 blocks from the attacks of a Shulker', FALSE, TRUE, 47, NULL, 'minecraft:end/levitate'), -- 49

-- Adventure Tab (Tab ID: 4, Advancements 50–84)
(4, 'Adventure', 'Adventure, exploration and combat', FALSE, TRUE, NULL, NULL, 'minecraft:adventure/root'), -- 50
(4, 'Voluntary Exile', 'Kill a raid captain. Maybe consider staying away from villages for the time being...', FALSE, TRUE, 50, NULL, 'minecraft:adventure/voluntary_exile'), -- 51
(4, 'Is It a Bird?', 'Look at a parrot through a spyglass', FALSE, TRUE, 50, NULL, 'minecraft:adventure/spyglass_at_parrot'), -- 52
(4, 'Monster Hunter', 'Kill any hostile monster', FALSE, TRUE, 50, NULL, 'minecraft:adventure/kill_a_mob'), -- 53
(4, 'The Power of Books', 'Read the power signal of a Chiseled Bookshelf using a Comparator', FALSE, TRUE, 50, NULL, 'minecraft:adventure/read_power_of_chiseled_bookshelf'), -- 54
(4, 'What a Deal!', 'Successfully trade with a Villager', FALSE, TRUE, 50, NULL, 'minecraft:adventure/trade'), -- 55
(4, 'Crafting a New Look', 'Craft a trimmed armor at a Smithing Table', FALSE, TRUE, 50, NULL, 'minecraft:adventure/trim_with_any_armor_pattern'), -- 56
(4, 'Sticky Situation', 'Jump into a Honey Block to break your fall', FALSE, TRUE, 50, NULL, 'minecraft:adventure/honey_block_slide'), -- 57
(4, 'Ol'' Betsy', 'Shoot a crossbow', FALSE, TRUE, 50, NULL, 'minecraft:adventure/ol_betsy'), -- 58
(4, 'Surge Protector', 'Protect a villager from an undesired shock without starting a fire', FALSE, TRUE, 50, NULL, 'minecraft:adventure/lightning_rod_with_villager_no_fire'), -- 59
(4, 'Caves & Cliffs', 'Free fall from the top of the world (build limit) to the bottom of the world and survive', FALSE, TRUE, 50, NULL, 'minecraft:adventure/fall_from_world_height'), -- 60
(4, 'Respecting the Remnants', 'Brush a Suspicious block to obtain a pottery sherd', FALSE, TRUE, 50, NULL, 'minecraft:adventure/salvage_sherd'), -- 61
(4, 'Sneak 100', 'Sneak near a Sculk Sensor or Warden to prevent it from detecting you', FALSE, TRUE, 50, NULL, 'minecraft:adventure/avoid_vibration'), -- 62
(4, 'Sweet Dreams', 'Sleep in a bed to change your respawn point', FALSE, TRUE, 50, NULL, 'minecraft:adventure/sleep_in_bed'), -- 63
(4, 'Hero of the Village', 'Successfully defend a village from a raid', FALSE, TRUE, 51, NULL, 'minecraft:adventure/hero_of_the_village'), -- 64
(4, 'Is It a Balloon?', 'Look at a ghast through a spyglass', FALSE, TRUE, 52, NULL, 'minecraft:adventure/spyglass_at_ghast'),-- 65
(4, 'A Throwaway Joke', 'Throw a trident at something.', FALSE, TRUE, 53, NULL, 'minecraft:adventure/throw_trident'), -- 66
(4, 'It Spreads', 'Kill a mob near a Sculk Catalyst', FALSE, TRUE, 53, NULL, 'minecraft:adventure/kill_mob_near_sculk_catalyst'), -- 67
(4, 'Take Aim', 'Shoot something with an arrow', FALSE, TRUE, 53, NULL, 'minecraft:adventure/shoot_arrow'), -- 68
(4, 'Monsters Hunted', 'Kill one of every hostile monster', FALSE, TRUE, 53, '100 experience', 'minecraft:adventure/kill_all_mobs'), -- 69
(4, 'Postmortal', 'Use a Totem of Undying to cheat death', FALSE, TRUE, 55, NULL, 'minecraft:adventure/totem_of_undying'), -- 70
(4, 'Hired Help', 'Summon an Iron Golem to help defend a village', FALSE, TRUE, 55, NULL, 'minecraft:adventure/summon_iron_golem'), -- 71
(4, 'Star Trader', 'Trade with a Villager at the build height limit', FALSE, TRUE, 55, NULL, 'minecraft:adventure/trade_at_world_height'), -- 72
(4, 'Smithing with Style', 'Apply these smithing templates at least once: Spire, Snout, Rib, Ward, Silence, Vex, Tide, Wayfinder', FALSE, TRUE, 56, NULL, 'minecraft:adventure/trim_with_all_exclusive_armor_patterns'), -- 73
(4, 'Two Birds, One Arrow', 'Kill two Phantoms with a piercing arrow', FALSE, TRUE, 58, NULL, 'minecraft:adventure/two_birds_one_arrow'), -- 74
(4, 'Who''s the Pillager Now?', 'Give a Pillager a taste of their own medicine', FALSE, TRUE, 58, NULL, 'minecraft:adventure/kill_pillager_with_crossbow'), -- 75
(4, 'Arbalistic', 'Kill five unique mobs with one crossbow shot', FALSE, TRUE, 58, '85 experience', 'minecraft:adventure/arbalistic'), -- 76
(4, 'Careful Restoration', 'Make a decorated pot out of 4 pottery sherds', FALSE, TRUE, 61, NULL, 'minecraft:adventure/craft_decorated_pot_using_only_sherds'), -- 77
(4, 'Adventuring Time', 'Discover every biome', FALSE, TRUE, 63, '100 experience', 'minecraft:adventure/adventuring_time'), -- 78
(4, 'Sound of Music', 'Make the Meadows come alive with the sound of music from a Jukebox', FALSE, TRUE, 63, NULL, 'minecraft:adventure/play_jukebox_in_meadows'), -- 79
(4, 'Light as a Rabbit', 'Walk on powder snow... without sinking in it', FALSE, TRUE, 63, NULL, 'minecraft:adventure/walk_on_powder_snow_with_leather_boots'), -- 80
(4, 'Is It a Plane?', 'Look at the Ender Dragon through a spyglass', FALSE, TRUE, 65, NULL, 'minecraft:adventure/spyglass_at_dragon'), -- 81
(4, 'Very Very Frightening', 'Strike a Villager with lightning', FALSE, TRUE, 66, NULL, 'minecraft:adventure/very_very_frightening'), -- 82
(4, 'Sniper Duel', 'Kill a Skeleton from at least 50 meters away', FALSE, TRUE, 68, NULL, 'minecraft:adventure/sniper_duel'), -- 83
(4, 'Bullseye', 'Hit the bullseye of a Target block from at least 30 meters away', FALSE, TRUE, 68, NULL, 'minecraft:adventure/bullseye'), -- 84

-- Husbandry Tab (Tab ID: 5, Advancements 85–109)
(5, 'Husbandry', 'The world is full of friends and food', FALSE, TRUE, NULL, NULL, 'minecraft:husbandry/root'), -- 85
(5, 'Bee Our Guest', 'Use a Campfire to collect Honey from a Beehive using a Bottle without aggravating the bees', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/safely_harvest_honey'), -- 86
(5, 'The Parrots and the Bats', 'Breed two animals together', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/breed_an_animal'), -- 87
(5, 'You''ve Got a Friend in Me', 'Have an Allay deliver items to you', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/allay_deliver_item_to_player'), -- 88
(5, 'Whatever Floats Your Goat!', 'Get in a Boat and float with a Goat', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/ride_a_boat_with_a_goat'), -- 89
(5, 'Best Friends Forever', 'Tame an animal', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/tame_an_animal'), -- 90
(5, 'Glow and Behold!', 'Make a sign glow', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/make_a_sign_glow'), -- 91
(5, 'Fishy Business', 'Catch a fish', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/fishy_business'), -- 92
(5, 'Total Beelocation', 'Move a Bee Nest, with 3 bees inside, using Silk Touch', FALSE, TRUE, 86, NULL, 'minecraft:husbandry/silk_touch_nest'), -- 93
(5, 'Bukkit Bukkit', 'Catch a tadpole in a Bucket', FALSE, TRUE, 92, NULL, 'minecraft:husbandry/tadpole_in_a_bucket'), -- 94
(5, 'Smells Interesting', 'Obtain a Sniffer Egg', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/sniff_sniffer_egg'), -- 95
(5, 'A Seedy Place', 'Plant a seed and watch it grow', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/plant_seed'), -- 96
(5, 'Wax On', 'Apply Honeycomb to a Copper block!', FALSE, TRUE, 85, NULL, 'minecraft:husbandry/wax_on'), -- 97
(5, 'Two by Two', 'Breed all the animals!', FALSE, TRUE, 87, '100 experience', 'minecraft:husbandry/bred_all_animals'),
(5, 'Birthday Song', 'Have an Allay drop a Cake at a Note Block', FALSE, TRUE, 88, NULL, 'minecraft:husbandry/allay_deliver_cake_to_note_block'), -- 98
(5, 'A Complete Catalogue', 'Tame all cat variants!', FALSE, TRUE, 90, '50 experience', 'minecraft:husbandry/complete_catalogue'), -- 99
(5, 'Tactical Fishing', 'Catch a fish... without a fishing rod!', FALSE, TRUE, 92, NULL, 'minecraft:husbandry/tactical_fishing'),  -- 100
(5, 'When the Squad Hops into Town', 'Get each Frog variant on a Lead', FALSE, TRUE, 94, NULL, 'minecraft:husbandry/leash_all_frog_variants'), -- 101
(5, 'Little Sniffs', 'Feed a Snifflet', FALSE, TRUE, 95, NULL, 'minecraft:husbandry/feed_snifflet'), -- 102
(5, 'A Balanced Diet', 'Eat everything that is edible, even if it''s not good for you', FALSE, TRUE, 96, '100 experience', 'minecraft:husbandry/balanced_diet'), -- 103
(5, 'Serious Dedication', 'Use a Netherite Ingot to upgrade a hoe, and then reevaluate your life choices', FALSE, TRUE, 96, '100 experience', 'minecraft:husbandry/netherite_hoe'), -- 104
(5, 'Wax Off', 'Scrape Wax off of a Copper block!', FALSE, TRUE, 97, NULL, 'minecraft:husbandry/wax_off'), -- 105
(5, 'The Cutest Predator', 'Catch an axolotl in a bucket', FALSE, TRUE, 101, NULL, 'minecraft:husbandry/axolotl_in_a_bucket'), -- 106
(5, 'With Our Powers Combined!', 'Have all Froglights in your inventory', FALSE, TRUE, 102, NULL, 'minecraft:husbandry/froglight'), -- 107
(5, 'Planting the Past', 'Plant any Sniffer seed', FALSE, TRUE, 103, NULL, 'minecraft:husbandry/plant_any_sniffer_seed'), -- 108
(5, 'The Healing Power of Friendship!', 'Team up with an axolotl and win a fight', FALSE, TRUE, 107, NULL, 'minecraft:husbandry/kill_axolotl_target'); -- 109

--Guides for some achievements
INSERT INTO Guides (advancement_id, guide_link, guide_description, source_type) VALUES
(14, 'https://minecraft.wiki/w/Zombie_Villager#Curing', 'Curing a Zombie Villager', 'Minecraft Wiki'),
(39, 'https://minecraft.wiki/w/Beacon#Pyramids', 'Full power beacon set-up', 'Minecraft Wiki'),
(40, 'https://youtu.be/fUcPvosFIKY?si=5S_x-ioit_rwNUpT', 'How did we get here video guide', 'YouTube'),
(59, 'https://youtu.be/jASrhXOkM1s?si=UCY3T8iCNUihiDno', 'Quick Surge Protecter Guide', 'YouTube'),
(108, 'https://minecraft.wiki/w/Froglight', 'Obtaining froglights', 'Minecraft Wiki');

--Base Numbers for some acheivemnets
Insert into Requirements (advancement_id, requirement_type, requirement_value) VALUES
(21, 'float', 875.00)
(34, 'integer', 5)
(69, 'integer', 37),
(78, 'integer', 54),
(98, 'integer', 25),
(100, 'integer', 11),
(104, 'integer', 40);
