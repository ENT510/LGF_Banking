return {
	['credit_card'] = {
		label = 'Credit Card',
		weight = 40,
		stack = false,
		description = 'A standard credit card used for transactions.'
	},
	['fake_credit_card'] = {
		label = 'Fake Credit Card',
		weight = 40,
		stack = false,
		description = 'A counterfeit credit card, looks real but is fake.'
	},
	['battery_printer'] = {
		label = 'Battery 3D Printer',
		weight = 1000,
		stack = true,
		description = 'A battery for recharger a Printer 3D'
	},
	['tool_hack_cooldown'] = {
		label = 'Cooldown Reduction',
		weight = 1000,
		stack = false,
		degrade = 15,
		decay = true,
		description = 'A tool used to reduce the cooldown of hacking attempts.',
		client = {
			export = 'LGF_Banking.ToolRemoveCoolDown',
		}
	},
	['tool_3dprint'] = {
		label = 'Printer 3D',
		weight = 3000,
		stack = false,
		description = 'A Printer 3D for crafting Tools.',
		client = {
			export = 'LGF_Banking.ToolCraftingItems',
		}
	},
	['tool_3dprint_delprinter'] = {
		label = 'Provider Printer Wipe',
		weight = 3000,
		stack = false,
		description = 'A tool for remove Printer 3D with yur serial.',
	},
	['tool_steal_npcmoney'] = {
		label = 'Provider Steal Money',
		weight = 3000,
		stack = false,
		description = 'A tool for steal money from civil.',
	},
	['stealing_card'] = {
		label = 'Civil Credit Card',
		weight = 20,
		stack = false,
		description = 'A Credit Card Stealed by a civil.',
	},
}
