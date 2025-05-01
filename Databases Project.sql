-- Create database for Minecraft Advancements Tracker
CREATE DATABASE IF NOT EXISTS minecraft_advancements
USE minecraft_advancements;

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

-- Insert advancements for Minecraft tab (Tab ID: 1)
INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
(1, 'Minecraft', 'The heart and story of the game', FALSE, TRUE, NULL, NULL, 'minecraft:story/root'),
(1, 'Stone Age', 'Mine stone with your new pickaxe', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/root'), NULL, 'minecraft:story/mine_stone'),
(1, 'Getting an Upgrade', 'Construct a better pickaxe', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/mine_stone'), NULL, 'minecraft:story/upgrade_tools'),
(1, 'Acquire Hardware', 'Smelt an iron ingot', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/mine_stone'), NULL, 'minecraft:story/smelt_iron'),
(1, 'Suit Up', 'Protect yourself with a piece of iron armor', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/smelt_iron'), NULL, 'minecraft:story/obtain_armor'),
(1, 'Hot Stuff', 'Fill a bucket with lava', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/smelt_iron'), NULL, 'minecraft:story/lava_bucket'),
(1, 'Isn''t It Iron Pick', 'Upgrade your pickaxe', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/smelt_iron'), NULL, 'minecraft:story/iron_tools'),
(1, 'Not Today, Thank You', 'Block a projectile using your shield', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/obtain_armor'), NULL, 'minecraft:story/deflect_arrow'),
(1, 'Ice Bucket Challenge', 'Obtain a block of obsidian', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/lava_bucket'), NULL, 'minecraft:story/form_obsidian'),
(1, 'Diamonds!', 'Acquire diamonds', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/iron_tools'), NULL, 'minecraft:story/mine_diamond'),
(1, 'We Need to Go Deeper', 'Build, light and enter a Nether Portal', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/form_obsidian'), NULL, 'minecraft:story/enter_the_nether'),
(1, 'Cover Me with Diamonds', 'Diamond armor saves lives', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/mine_diamond'), NULL, 'minecraft:story/shiny_gear'),
(1, 'Enchanter', 'Enchant an item at an Enchanting Table', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/mine_diamond'), NULL, 'minecraft:story/enchant_item'),
(1, 'Zombie Doctor', 'Weaken and then cure a Zombie Villager', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/enter_the_nether'), '100 experience', 'minecraft:story/cure_zombie_villager'),
(1, 'Eye Spy', 'Follow an Eye of Ender', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/enter_the_nether'), NULL, 'minecraft:story/follow_ender_eye'),
(1, 'The End?', 'Enter the End Portal', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:story/follow_ender_eye'), NULL, 'minecraft:story/enter_the_end');

-- Insert advancements for Nether tab (Tab ID: 2)
INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
(2, 'Nether', 'Bring summer clothes', FALSE, TRUE, NULL, NULL, 'minecraft:nether/root'),
(2, 'Return to Sender', 'Destroy a Ghast with a fireball', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), '50 experience', 'minecraft:nether/return_to_sender'),
(2, 'Those Were the Days', 'Enter a Bastion Remnant', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), NULL, 'minecraft:nether/find_bastion'),
(2, 'Hidden in the Depths', 'Obtain Ancient Debris', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), NULL, 'minecraft:nether/obtain_ancient_debris'),
(2, 'Subspace Bubble', 'Use the Nether to travel 7 km in the Overworld', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), '100 experience', 'minecraft:nether/fast_travel'),
(2, 'A Terrible Fortress', 'Break your way into a Nether Fortress', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), NULL, 'minecraft:nether/find_fortress'),
(2, 'Who is Cutting Onions?', 'Obtain Crying Obsidian', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), NULL, 'minecraft:nether/obtain_crying_obsidian'),
(2, 'Oh Shiny', 'Distract Piglins with gold', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/root'), NULL, 'minecraft:nether/distract_piglin'),
(2, 'This Boat Has Legs', 'Ride a Strider with a Warped Fungus on a Stick', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/obtain_crying_obsidian'), NULL, 'minecraft:nether/ride_strider'),
(2, 'Uneasy Alliance', 'Rescue a Ghast from the Nether, bring it safely home to the Overworld... and then kill it', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/return_to_sender'), '100 experience', 'minecraft:nether/uneasy_alliance'),
(2, 'War Pigs', 'Loot a chest in a Bastion Remnant', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/find_bastion'), NULL, 'minecraft:nether/loot_bastion'),
(2, 'Country Lode, Take Me Home', 'Use a Compass on a Lodestone', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/obtain_ancient_debris'), NULL, 'minecraft:nether/use_lodestone'),
(2, 'Cover Me in Debris', 'Get a full suit of Netherite armor', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/obtain_ancient_debris'), '100 experience', 'minecraft:nether/netherite_armor'),
(2, 'Spooky Scary Skeleton', 'Obtain a Wither Skeleton''s skull', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/find_fortress'), NULL, 'minecraft:nether/get_wither_skull'),
(2, 'Into Fire', 'Relieve a Blaze of its rod', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/find_fortress'), NULL, 'minecraft:nether/obtain_blaze_rod'),
(2, 'Not Quite "Nine" Lives', 'Charge a Respawn Anchor to the maximum', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/obtain_crying_obsidian'), NULL, 'minecraft:nether/charge_respawn_anchor'),
(2, 'Feels Like Home', 'Take a Strider for a loooong ride on a lava lake in the Overworld', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/ride_strider'), '50 experience', 'minecraft:nether/ride_strider_in_overworld_lava'),
(2, 'Hot Tourist Destinations', 'Explore all Nether biomes', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/find_fortress'), NULL, 'minecraft:nether/explore_nether'),
(2, 'Withering Heights', 'Summon the Wither', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/get_wither_skull'), NULL, 'minecraft:nether/summon_wither'),
(2, 'Local Brewery', 'Brew a potion', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/obtain_blaze_rod'), NULL, 'minecraft:nether/brew_potion'),
(2, 'Bring Home the Beacon', 'Construct and place a Beacon', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/summon_wither'), NULL, 'minecraft:nether/create_beacon'),
(2, 'A Furious Cocktail', 'Have every potion effect applied at the same time', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/brew_potion'), '100 experience', 'minecraft:nether/all_potions'),
(2, 'Beaconator', 'Bring a beacon to full power', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/create_beacon'), NULL, 'minecraft:nether/create_full_beacon'),
(2, 'How Did We Get Here?', 'Have every effect applied at the same time', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:nether/all_potions'), '1000 experience', 'minecraft:nether/all_effects');

-- Insert advancements for The End tab (Tab ID: 3)
INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
(3, 'The End', 'Or the beginning?', FALSE, TRUE, NULL, NULL, 'minecraft:end/root'),
(3, 'Free the End', 'Good luck', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/root'), NULL, 'minecraft:end/kill_dragon'),
(3, 'The Next Generation', 'Hold the Dragon Egg', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/kill_dragon'), NULL, 'minecraft:end/dragon_egg'),
(3, 'Remote Getaway', 'Escape the island', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/kill_dragon'), NULL, 'minecraft:end/enter_end_gateway'),
(3, 'The End... Again...', 'Respawn the Ender Dragon', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/kill_dragon'), NULL, 'minecraft:end/respawn_dragon'),
(3, 'You Need a Mint', 'Collect dragon''s breath in a glass bottle', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/kill_dragon'), NULL, 'minecraft:end/dragon_breath'),
(3, 'The City at the End of the Game', 'Go on in, what could happen?', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/enter_end_gateway'), NULL, 'minecraft:end/find_end_city'),
(3, 'Sky''s the Limit', 'Find elytra', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/find_end_city'), NULL, 'minecraft:end/elytra'),
(3, 'Great View From Up Here', 'Levitate up 50 blocks from the attacks of a Shulker', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:end/find_end_city'), NULL, 'minecraft:end/levitate');

-- Insert advancements for Adventure tab (Tab ID: 4)
INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
(4, 'Adventure', 'Adventure, exploration and combat', FALSE, TRUE, NULL, NULL, 'minecraft:adventure/root'),
(4, 'Voluntary Exile', 'Kill a raid captain. Maybe consider staying away from villages for the time being...', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/voluntary_exile'),
(4, 'Is It a Bird?', 'Look at a parrot through a spyglass', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/spyglass_at_parrot'),
(4, 'Monster Hunter', 'Kill any hostile monster', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/kill_a_mob'),
(4, 'The Power of Books', 'Read the power signal of a Chiseled Bookshelf using a Comparator', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/read_power_of_chiseled_bookshelf'),
(4, 'What a Deal!', 'Successfully trade with a Villager', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/trade'),
(4, 'Crafting a New Look', 'Craft a trimmed armor at a Smithing Table', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/trim_with_any_armor_pattern'),
(4, 'Sticky Situation', 'Jump into a Honey Block to break your fall', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/honey_block_slide'),
(4, 'Ol'' Betsy', 'Shoot a crossbow', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/ol_betsy'),
(4, 'Surge Protector', 'Protect a villager from an undesired shock without starting a fire', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/lightning_rod_with_villager_no_fire'),
(4, 'Caves & Cliffs', 'Free fall from the top of the world (build limit) to the bottom of the world and survive', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/fall_from_world_height'),
(4, 'Respecting the Remnants', 'Brush a Suspicious block to obtain a pottery sherd', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/salvage_sherd'),
(4, 'Sneak 100', 'Sneak near a Sculk Sensor or Warden to prevent it from detecting you', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/avoid_vibration'),
(4, 'Sweet Dreams', 'Sleep in a bed to change your respawn point', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/root'), NULL, 'minecraft:adventure/sleep_in_bed'),
(4, 'Hero of the Village', 'Successfully defend a village from a raid', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/voluntary_exile'), NULL, 'minecraft:adventure/hero_of_the_village'),
(4, 'Is It a Balloon?', 'Look at a ghast through a spyglass', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/spyglass_at_parrot'), NULL, 'minecraft:adventure/spyglass_at_ghast'),
(4, 'A Throwaway Joke', 'Throw a trident at something.', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/kill_a_mob'), NULL, 'minecraft:adventure/throw_trident'),
(4, 'It Spreads', 'Kill a mob near a Sculk Catalyst', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/kill_a_mob'), NULL, 'minecraft:adventure/kill_mob_near_sculk_catalyst'),
(4, 'Take Aim', 'Shoot something with an arrow', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/kill_a_mob'), NULL, 'minecraft:adventure/shoot_arrow'),
(4, 'Monsters Hunted', 'Kill one of every hostile monster', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/kill_a_mob'), '100 experience', 'minecraft:adventure/kill_all_mobs'),
(4, 'Postmortal', 'Use a Totem of Undying to cheat death', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/trade'), NULL, 'minecraft:adventure/totem_of_undying'),
(4, 'Hired Help', 'Summon an Iron Golem to help defend a village', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/trade'), NULL, 'minecraft:adventure/summon_iron_golem'),
(4, 'Star Trader', 'Trade with a Villager at the build height limit', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/trade'), NULL, 'minecraft:adventure/trade_at_world_height'),
(4, 'Smithing with Style', 'Apply these smithing templates at least once: Spire, Snout, Rib, Ward, Silence, Vex, Tide, Wayfinder', FALSE, TRUE, (SELECT advancement_id presses FROM Advancements WHERE resource_path = 'minecraft:adventure/trim_with_any_armor_pattern'), NULL, 'minecraft:adventure/trim_with_all_exclusive_armor_patterns'),
(4, 'Two Birds, One Arrow', 'Kill two Phantoms with a piercing arrow', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/ol_betsy'), NULL, 'minecraft:adventure/two_birds_one_arrow'),
(4, 'Who''s the Pillager Now?', 'Give a Pillager a taste of their own medicine', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/ol_betsy'), NULL, 'minecraft:adventure/kill_pillager_with_crossbow'),
(4, 'Arbalistic', 'Kill five unique mobs with one crossbow shot', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/ol_betsy'), '85 experience', 'minecraft:adventure/arbalistic'),
(4, 'Careful Restoration', 'Make a decorated pot out of 4 pottery sherds', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/salvage_sherd'), NULL, 'minecraft:adventure/craft_decorated_pot_using_only_sherds'),
(4, 'Adventuring Time', 'Discover every biome', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/sleep_in_bed'), '100 experience', 'minecraft:adventure/adventuring_time'),
(4, 'Sound of Music', 'Make the Meadows come alive with the sound of music from a Jukebox', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/sleep_in_bed'), NULL, 'minecraft:adventure/play_jukebox_in_meadows'),
(4, 'Light as a Rabbit', 'Walk on powder snow... without sinking in it', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/sleep_in_bed'), NULL, 'minecraft:adventure/walk_on_powder_snow_with_leather_boots'),
(4, 'Is It a Plane?', 'Look at the Ender Dragon through a spyglass', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/spyglass_at_ghast'), NULL, 'minecraft:adventure/spyglass_at_dragon'),
(4, 'Very Very Frightening', 'Strike a Villager with lightning', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/throw_trident'), NULL, 'minecraft:adventure/very_very_frightening'),
(4, 'Sniper Duel', 'Kill a Skeleton from at least 50 meters away', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/shoot_arrow'), NULL, 'minecraft:adventure/sniper_duel'),
(4, 'Bullseye', 'Hit the bullseye of a Target block from at least 30 meters away', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:adventure/shoot_arrow'), NULL, 'minecraft:adventure/bullseye');

-- Insert advancements for Husbandry tab (Tab ID: 5)
INSERT INTO Advancements (tab_id, advancement_name, description, is_completed, is_available, parent_advancement_id, rewards, resource_path) VALUES
(5, 'Husbandry', 'The world is full of friends and food', FALSE, TRUE, NULL, NULL, 'minecraft:husbandry/root'),
(5, 'Bee Our Guest', 'Use a Campfire to collect Honey from a Beehive using a Bottle without aggravating the bees', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/safely_harvest_honey'),
(5, 'The Parrots and the Bats', 'Breed two animals together', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/breed_an_animal'),
(5, 'You''ve Got a Friend in Me', 'Have an Allay deliver items to you', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/allay_deliver_item_to_player'),
(5, 'Whatever Floats Your Goat!', 'Get in a Boat and float with a Goat', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/ride_a_boat_with_a_goat'),
(5, 'Best Friends Forever', 'Tame an animal', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/tame_an_animal'),
(5, 'Glow and Behold!', 'Make a sign glow', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/make_a_sign_glow'),
(5, 'Fishy Business', 'Catch a fish', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/fishy_business'),
(5, 'Total Beelocation', 'Move a Bee Nest, with 3 bees inside, using Silk Touch', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/safely_harvest_honey'), NULL, 'minecraft:husbandry/silk_touch_nest'),
(5, 'Bukkit Bukkit', 'Catch a tadpole in a Bucket', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/fishy_business'), NULL, 'minecraft:husbandry/tadpole_in_a_bucket'),
(5, 'Smells Interesting', 'Obtain a Sniffer Egg', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/sniff_sniffer_egg'),
(5, 'A Seedy Place', 'Plant a seed and watch it grow', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/plant_seed'),
(5, 'Wax On', 'Apply Honeycomb to a Copper block!', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/root'), NULL, 'minecraft:husbandry/wax_on'),
(5, 'Two by Two', 'Breed all the animals!', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/breed_an_animal'), '100 experience', 'minecraft:husbandry/bred_all_animals'),
(5, 'Birthday Song', 'Have an Allay drop a Cake at a Note Block', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/allay_deliver_item_to_player'), NULL, 'minecraft:husbandry/allay_deliver_cake_to_note_block'),
(5, 'A Complete Catalogue', 'Tame all cat variants!', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/tame_an_animal'), '50 experience', 'minecraft:husbandry/complete_catalogue'),
(5, 'Tactical Fishing', 'Catch a fish... without a fishing rod!', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/fishy_business'), NULL, 'minecraft:husbandry/tactical_fishing'),
(5, 'When the Squad Hops into Town', 'Get each Frog variant on a Lead', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/tadpole_in_a_bucket'), NULL, 'minecraft:husbandry/leash_all_frog_variants'),
(5, 'Little Sniffs', 'Feed a Snifflet', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/sniff_sniffer_egg'), NULL, 'minecraft:husbandry/feed_snifflet'),
(5, 'A Balanced Diet', 'Eat everything that is edible, even if it''s not good for you', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/plant_seed'), '100 experience', 'minecraft:husbandry/balanced_diet'),
(5, 'Serious Dedication', 'Use a Netherite Ingot to upgrade a hoe, and then reevaluate your life choices', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/plant_seed'), '100 experience', 'minecraft:husbandry/netherite_hoe'),
(5, 'Wax Off', 'Scrape Wax off of a Copper block!', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/wax_on'), NULL, 'minecraft:husbandry/wax_off'),
(5, 'The Cutest Predator', 'Catch an axolotl in a bucket', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/tactical_fishing'), NULL, 'minecraft:husbandry/axolotl_in_a_bucket'),
(5, 'With Our Powers Combined!', 'Have all Froglights in your inventory', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/leash_all_frog_variants'), NULL, 'minecraft:husbandry/froglight'),
(5, 'Planting the Past', 'Plant any Sniffer seed', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/feed_snifflet'), NULL, 'minecraft:husbandry/plant_any_sniffer_seed'),
(5, 'The Healing Power of Friendship!', 'Team up with an axolotl and win a fight', FALSE, TRUE, (SELECT advancement_id FROM Advancements WHERE resource_path = 'minecraft:husbandry/axolotl_in_a_bucket'), NULL, 'minecraft:husbandry/kill_axolotl_target');