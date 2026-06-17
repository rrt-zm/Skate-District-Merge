import Foundation

enum GameContent {
    static let chains: [ChainDefinition] = [
        ChainDefinition(
            id: .boards,
            title: "Boards & Gear",
            accentHex: "FFD23F",
            symbol: "skateboard",
            tiers: [
                TierDef(name: "Plank"),
                TierDef(name: "Deck"),
                TierDef(name: "Griptape Deck"),
                TierDef(name: "Trick Deck"),
                TierDef(name: "Pro Deck"),
                TierDef(name: "Custom Board"),
                TierDef(name: "Signature Board"),
                TierDef(name: "Legend Board")
            ]
        ),
        ChainDefinition(
            id: .ramps,
            title: "Ramps & Obstacles",
            accentHex: "20E0D6",
            symbol: "triangle",
            tiers: [
                TierDef(name: "Curb"),
                TierDef(name: "Kicker"),
                TierDef(name: "Grind Rail"),
                TierDef(name: "Quarter Pipe"),
                TierDef(name: "Half Pipe"),
                TierDef(name: "Concrete Bowl"),
                TierDef(name: "Vert Ramp"),
                TierDef(name: "Mega Ramp")
            ]
        ),
        ChainDefinition(
            id: .graffiti,
            title: "Graffiti & Art",
            accentHex: "FF2E97",
            symbol: "paintbrush.pointed",
            tiers: [
                TierDef(name: "Sticker"),
                TierDef(name: "Tag"),
                TierDef(name: "Throw-Up"),
                TierDef(name: "Stencil"),
                TierDef(name: "Piece"),
                TierDef(name: "Mural"),
                TierDef(name: "Graffiti Wall"),
                TierDef(name: "Masterpiece")
            ]
        ),
        ChainDefinition(
            id: .lighting,
            title: "Lighting",
            accentHex: "B14EFF",
            symbol: "lightbulb",
            tiers: [
                TierDef(name: "Bulb"),
                TierDef(name: "Lamp"),
                TierDef(name: "Floodlight"),
                TierDef(name: "Spotlight"),
                TierDef(name: "String Lights"),
                TierDef(name: "Neon Tube"),
                TierDef(name: "Neon Sign"),
                TierDef(name: "Neon Skyline")
            ]
        ),
        ChainDefinition(
            id: .shops,
            title: "Shops",
            accentHex: "FF7A3C",
            symbol: "bag",
            tiers: [
                TierDef(name: "Crate Stand"),
                TierDef(name: "Kiosk"),
                TierDef(name: "Pop-Up"),
                TierDef(name: "Board Shop"),
                TierDef(name: "Skate Shop"),
                TierDef(name: "Café Corner"),
                TierDef(name: "Flagship Store"),
                TierDef(name: "Mega Plaza")
            ]
        )
    ]

    static let generators: [GeneratorDef] = [
        GeneratorDef(id: .supplyCrate, title: "Supply Crate", blurb: "Spawns fresh boards and gear.",
                     chain: .boards, unlockLevel: 1, baseCapacity: 8, capacityStep: 2,
                     baseRefill: 5.5, refillStep: 0.5, minRefill: 1.5, maxUpgradeLevel: 8),
        GeneratorDef(id: .rampKit, title: "Ramp Kit", blurb: "Drops curbs and ramp parts.",
                     chain: .ramps, unlockLevel: 3, baseCapacity: 7, capacityStep: 2,
                     baseRefill: 6.5, refillStep: 0.55, minRefill: 1.8, maxUpgradeLevel: 8),
        GeneratorDef(id: .paintCan, title: "Paint Can", blurb: "Sprays stickers and tags.",
                     chain: .graffiti, unlockLevel: 5, baseCapacity: 7, capacityStep: 2,
                     baseRefill: 7.0, refillStep: 0.6, minRefill: 2.0, maxUpgradeLevel: 8),
        GeneratorDef(id: .lampCrate, title: "Lamp Crate", blurb: "Powers up street lighting.",
                     chain: .lighting, unlockLevel: 8, baseCapacity: 6, capacityStep: 2,
                     baseRefill: 8.0, refillStep: 0.6, minRefill: 2.2, maxUpgradeLevel: 8),
        GeneratorDef(id: .shopCrate, title: "Vendor Cart", blurb: "Stocks shop fronts.",
                     chain: .shops, unlockLevel: 11, baseCapacity: 6, capacityStep: 2,
                     baseRefill: 9.0, refillStep: 0.65, minRefill: 2.5, maxUpgradeLevel: 8)
    ]

    static let zones: [ZoneDef] = [
        ZoneDef(id: .streetPlaza, title: "Street Plaza", blurb: "The first cracked slab where it all begins.",
                cost: 0, unlockLevel: 1, structures: ["ledge", "bench", "planter"], skaterBonus: 3),
        ZoneDef(id: .graffitiAlley, title: "Graffiti Alley", blurb: "Brick walls begging for color.",
                cost: 60, unlockLevel: 4, structures: ["mural", "tags", "dumpster"], skaterBonus: 4),
        ZoneDef(id: .bowl, title: "The Bowl", blurb: "A deep concrete bowl for carving lines.",
                cost: 140, unlockLevel: 6, structures: ["bowl", "coping", "deck"], skaterBonus: 5),
        ZoneDef(id: .shopRow, title: "Shop Row", blurb: "Storefronts that bring the crowd.",
                cost: 240, unlockLevel: 9, structures: ["shop", "awning", "signpost"], skaterBonus: 6),
        ZoneDef(id: .vertPark, title: "Vert Park", blurb: "Big ramps reaching for the sky.",
                cost: 400, unlockLevel: 12, structures: ["vert", "halfpipe", "scaffold"], skaterBonus: 8),
        ZoneDef(id: .nightStrip, title: "Night Strip", blurb: "Neon glow over the after-dark session.",
                cost: 650, unlockLevel: 15, structures: ["neon", "billboard", "spotlight"], skaterBonus: 10)
    ]

    static let boosts: [BoostDef] = [
        BoostDef(id: .sessionTime, title: "Session Time", blurb: "Generators recharge twice as fast for 60s.",
                 symbol: "bolt.fill", duration: 60, multiplier: 2.0),
        BoostDef(id: .coinRush, title: "Coin Rush", blurb: "Double coins from requests for 45s.",
                 symbol: "dollarsign.circle.fill", duration: 45, multiplier: 2.0),
        BoostDef(id: .gritSurge, title: "Grit Surge", blurb: "Double XP from merges for 60s.",
                 symbol: "sparkles", duration: 60, multiplier: 2.0),
        BoostDef(id: .crowdHype, title: "Crowd Hype", blurb: "Skaters land tricks like crazy for 90s.",
                 symbol: "flame.fill", duration: 90, multiplier: 2.5)
    ]

    static let quests: [QuestDef] = [
        QuestDef(id: "q1", chapter: 1, order: 1, title: "First Merge",
                 detail: "Drag two matching pieces together to merge them.",
                 goal: Objective(kind: .merge, chain: nil, tier: nil, target: 3),
                 reward: Reward(coins: 40, xp: 20, cred: 2)),
        QuestDef(id: "q2", chapter: 1, order: 2, title: "Build a Deck",
                 detail: "Merge planks up to a proper Deck.",
                 goal: Objective(kind: .createItem, chain: .boards, tier: 2, target: 1),
                 reward: Reward(coins: 60, xp: 30, cred: 3)),
        QuestDef(id: "q3", chapter: 1, order: 3, title: "Fill an Order",
                 detail: "Complete a skater request from the rail.",
                 goal: Objective(kind: .fulfillRequest, chain: nil, tier: nil, target: 1),
                 reward: Reward(coins: 80, xp: 40, cred: 4, boost: .sessionTime)),
        QuestDef(id: "q4", chapter: 2, order: 1, title: "Keep It Stocked",
                 detail: "Tap your generators to spawn pieces.",
                 goal: Objective(kind: .tapGenerator, chain: nil, tier: nil, target: 20),
                 reward: Reward(coins: 90, xp: 45, cred: 4)),
        QuestDef(id: "q5", chapter: 2, order: 2, title: "Grind Rail",
                 detail: "Merge ramp parts into a Grind Rail.",
                 goal: Objective(kind: .createItem, chain: .ramps, tier: 3, target: 1),
                 reward: Reward(coins: 120, xp: 60, cred: 6)),
        QuestDef(id: "q6", chapter: 2, order: 3, title: "Draw a Crowd",
                 detail: "Attract skaters to your district.",
                 goal: Objective(kind: .attractSkaters, chain: nil, tier: nil, target: 12),
                 reward: Reward(coins: 140, xp: 70, cred: 8, boost: .crowdHype)),
        QuestDef(id: "q7", chapter: 3, order: 1, title: "Paint a Piece",
                 detail: "Merge graffiti up to a full Piece.",
                 goal: Objective(kind: .createItem, chain: .graffiti, tier: 5, target: 1),
                 reward: Reward(coins: 180, xp: 90, cred: 10)),
        QuestDef(id: "q8", chapter: 3, order: 2, title: "Local Legend",
                 detail: "Fulfill plenty of skater requests.",
                 goal: Objective(kind: .fulfillRequest, chain: nil, tier: nil, target: 15),
                 reward: Reward(coins: 220, xp: 110, cred: 12, boost: .coinRush)),
        QuestDef(id: "q9", chapter: 3, order: 3, title: "Expand the District",
                 detail: "Unlock a brand new zone.",
                 goal: Objective(kind: .unlockZone, chain: nil, tier: nil, target: 1),
                 reward: Reward(coins: 260, xp: 130, cred: 0)),
        QuestDef(id: "q10", chapter: 4, order: 1, title: "Drop In",
                 detail: "Merge a towering Half Pipe.",
                 goal: Objective(kind: .createItem, chain: .ramps, tier: 5, target: 1),
                 reward: Reward(coins: 320, xp: 160, cred: 14)),
        QuestDef(id: "q11", chapter: 4, order: 2, title: "Rising Star",
                 detail: "Reach player level 10.",
                 goal: Objective(kind: .reachLevel, chain: nil, tier: nil, target: 10),
                 reward: Reward(coins: 380, xp: 0, cred: 16, boost: .gritSurge)),
        QuestDef(id: "q12", chapter: 4, order: 3, title: "Light the Night",
                 detail: "Merge lighting into a glowing Neon Sign.",
                 goal: Objective(kind: .createItem, chain: .lighting, tier: 7, target: 1),
                 reward: Reward(coins: 500, xp: 220, cred: 24))
    ]

    static let achievements: [AchievementDef] = [
        AchievementDef(id: "a_merge1", title: "Getting the Hang", detail: "Make 50 merges.", symbol: "arrow.triangle.merge",
                       goal: Objective(kind: .merge, chain: nil, tier: nil, target: 50),
                       reward: Reward(coins: 60, xp: 30)),
        AchievementDef(id: "a_merge2", title: "Merge Machine", detail: "Make 300 merges.", symbol: "arrow.triangle.merge",
                       goal: Objective(kind: .merge, chain: nil, tier: nil, target: 300),
                       reward: Reward(coins: 180, xp: 90, cred: 8)),
        AchievementDef(id: "a_merge3", title: "Concrete Veteran", detail: "Make 1200 merges.", symbol: "arrow.triangle.merge",
                       goal: Objective(kind: .merge, chain: nil, tier: nil, target: 1200),
                       reward: Reward(coins: 500, xp: 250, cred: 20)),
        AchievementDef(id: "a_req1", title: "Helpful Local", detail: "Fill 10 requests.", symbol: "checkmark.seal",
                       goal: Objective(kind: .fulfillRequest, chain: nil, tier: nil, target: 10),
                       reward: Reward(coins: 80, xp: 40)),
        AchievementDef(id: "a_req2", title: "Crew Favorite", detail: "Fill 60 requests.", symbol: "checkmark.seal.fill",
                       goal: Objective(kind: .fulfillRequest, chain: nil, tier: nil, target: 60),
                       reward: Reward(coins: 260, xp: 130, cred: 12)),
        AchievementDef(id: "a_skate1", title: "Spot Opens Up", detail: "Attract 30 skaters.", symbol: "figure.skating",
                       goal: Objective(kind: .attractSkaters, chain: nil, tier: nil, target: 30),
                       reward: Reward(coins: 100, xp: 50)),
        AchievementDef(id: "a_skate2", title: "Packed Session", detail: "Attract 150 skaters.", symbol: "figure.skating",
                       goal: Objective(kind: .attractSkaters, chain: nil, tier: nil, target: 150),
                       reward: Reward(coins: 320, xp: 160, cred: 14)),
        AchievementDef(id: "a_trick1", title: "Trick List", detail: "Land 200 tricks.", symbol: "flame",
                       goal: Objective(kind: .landTricks, chain: nil, tier: nil, target: 200),
                       reward: Reward(coins: 140, xp: 70, cred: 6)),
        AchievementDef(id: "a_tap1", title: "Stocked Up", detail: "Tap generators 150 times.", symbol: "shippingbox",
                       goal: Objective(kind: .tapGenerator, chain: nil, tier: nil, target: 150),
                       reward: Reward(coins: 120, xp: 60)),
        AchievementDef(id: "a_board", title: "Board Builder", detail: "Create a Custom Board.", symbol: "skateboard",
                       goal: Objective(kind: .createItem, chain: .boards, tier: 6, target: 1),
                       reward: Reward(coins: 200, xp: 100, cred: 10)),
        AchievementDef(id: "a_ramp", title: "Ramp Architect", detail: "Create a Vert Ramp.", symbol: "triangle",
                       goal: Objective(kind: .createItem, chain: .ramps, tier: 7, target: 1),
                       reward: Reward(coins: 240, xp: 120, cred: 12)),
        AchievementDef(id: "a_graf", title: "Wall Master", detail: "Create a Graffiti Wall.", symbol: "paintbrush.pointed",
                       goal: Objective(kind: .createItem, chain: .graffiti, tier: 7, target: 1),
                       reward: Reward(coins: 240, xp: 120, cred: 12)),
        AchievementDef(id: "a_light", title: "Neon Dreams", detail: "Create a Neon Skyline.", symbol: "lightbulb.fill",
                       goal: Objective(kind: .createItem, chain: .lighting, tier: 8, target: 1),
                       reward: Reward(coins: 400, xp: 200, cred: 18)),
        AchievementDef(id: "a_shop", title: "Retail Mogul", detail: "Create a Flagship Store.", symbol: "bag.fill",
                       goal: Objective(kind: .createItem, chain: .shops, tier: 7, target: 1),
                       reward: Reward(coins: 400, xp: 200, cred: 18)),
        AchievementDef(id: "a_level", title: "Seasoned", detail: "Reach level 15.", symbol: "star.fill",
                       goal: Objective(kind: .reachLevel, chain: nil, tier: nil, target: 15),
                       reward: Reward(coins: 360, xp: 0, cred: 16)),
        AchievementDef(id: "a_zone", title: "District Boss", detail: "Unlock all 6 zones.", symbol: "map.fill",
                       goal: Objective(kind: .unlockZone, chain: nil, tier: nil, target: 5),
                       reward: Reward(coins: 600, xp: 300, cred: 30))
    ]

    static let skaterNames: [String] = [
        "Rio", "Kai", "Nova", "Dex", "Sage", "Vex", "Indie", "Ziggy",
        "Marlo", "Reese", "Juno", "Ash", "Cody", "Pax", "Blue", "Remy",
        "Tate", "Echo", "Lux", "Kano", "Mika", "Skip", "Onyx", "Wren"
    ]

    private static let chainMap: [ChainID: ChainDefinition] = {
        var map: [ChainID: ChainDefinition] = [:]
        for chain in chains { map[chain.id] = chain }
        return map
    }()

    private static let generatorMap: [GeneratorID: GeneratorDef] = {
        var map: [GeneratorID: GeneratorDef] = [:]
        for gen in generators { map[gen.id] = gen }
        return map
    }()

    private static let zoneMap: [ZoneID: ZoneDef] = {
        var map: [ZoneID: ZoneDef] = [:]
        for zone in zones { map[zone.id] = zone }
        return map
    }()

    private static let boostMap: [BoostID: BoostDef] = {
        var map: [BoostID: BoostDef] = [:]
        for boost in boosts { map[boost.id] = boost }
        return map
    }()

    static func chain(_ id: ChainID) -> ChainDefinition { chainMap[id]! }
    static func generator(_ id: GeneratorID) -> GeneratorDef { generatorMap[id]! }
    static func zone(_ id: ZoneID) -> ZoneDef { zoneMap[id]! }
    static func boost(_ id: BoostID) -> BoostDef { boostMap[id]! }

    static func name(for kind: ItemKind) -> String { chain(kind.chain).name(tier: kind.tier) }
    static func maxTier(_ chain: ChainID) -> Int { self.chain(chain).maxTier }

    static func quest(_ id: String) -> QuestDef? { quests.first(where: { $0.id == id }) }
    static func achievement(_ id: String) -> AchievementDef? { achievements.first(where: { $0.id == id }) }

    static var allItemKinds: [ItemKind] {
        var kinds: [ItemKind] = []
        for chain in chains {
            for tier in 1...chain.maxTier {
                kinds.append(ItemKind(chain: chain.id, tier: tier))
            }
        }
        return kinds
    }
}
