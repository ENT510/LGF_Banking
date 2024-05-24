
# Don't restart  the script with the Near printer :D


# LGF_Banking

### Provide Functions:

- Manage Robbery Bank
- CoolDown Robbery
- NPC Robbery System (duplicate card)
- 3D Printer with Prop (by Mrs. BzZz)
- Place Printer with Raycast
- Battery System for Printer
- Shop for Tools
- Support ATMs
- Create Fake Card with metadata
- Hacking Time for Robbery
- Hack Pin
- Dispatch Internal
- Dispatch Custom
- Support Multi-Core
- Support Multi-Notification
- SQL Table Execution and Creation
- Credit Card Configuration
- Progress Bar Type
- Enable Blip for all ATMs
- Bank Zones and Configuration
- Enable Camera for Ped
- Fake Credit Card Configuration
- Skill Check Support
- Admin Pannel Printer
- Initiating a Bank Robbery
- Robbery Loot Items
- Society Funds Management (Boss Exclusive)
- Change PIN


## Configuratiom (Convars)

To configure `LGF_Banking`, follow these steps:

Open your `server.cfg` file: This file is usually located in your server's root directory.

Add the following lines to your `server.cfg` file: These settings allow you to set the language and enable debug mode for troubleshooting purposes.

```cfg
## Convars LGF Banking
setr LGF_Banking:Traduction en ## locales check locales 
setr LGF_Banking:Getdebug true ## enable or disable Debug
setr LGF_Banking:RunSqlTable false ## Run and create SQL table for banking
setr LGF_Banking:EnableRobberyNpc true ##Enable Stealing NPC and remove Sell Stealing Card
setr LGF_Banking:MetadataNPC en ## Language Metadata for Stealed Card -- it , en 
setr LGF_Banking:EnablePrinterMenuCommand true ## Enable o Disable command for printer menu
setr LGF_Banking:PrinterMenuCommand "printer" ## Command for open Printer Menu
setr LGF_Banking:EnableAllAtmBlips true ## Enable or Disable all Atm's Blips
setr LGF_Banking:EnableOxHooksCheck false ## If true, the item cannot be moved from the player's inventory to any stash, etc. (prevent bugs and crafty people)
setr LGF_Banking:ReturnTypeSerial 1 ## Serial type to generate: 1) generic (letters and numbers), 2) Return letters only, 3) Return numbers only
```

- Save the file: After making the changes, save and close the server.cfg file.

- Restart your server: For the changes to take effect, you need to restart your game server.

## Dependency

- [OX INVENTORY](https://github.com/overextended/ox_inventory)
- [OX TARGET](https://github.com/overextended/ox_target/tree/main)
- [OX LIB](https://github.com/overextended/ox_lib)

## Screenshots

<table>
  <tr>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/7b5cbcb9-fe60-4828-9d1e-1bdc43fa7560" alt="Manage Banking" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/fa70a893-f2d4-4d2e-91fc-84704820eeb9" alt="Pin Creation" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/666fce84-cb7f-4d6a-977d-a32d5fc9b1ba" alt="Create Fake Card" width="300"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/c0dfcdac-ffb3-4759-9b82-66a6fb10b5a6" alt="Create Fake Card" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/367ba412-f15f-40bc-9ecb-a74fc9e4d0e5" alt="Create Fake Card" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/cb052811-d4d1-4ef3-97a8-a41767486bf2" alt="+ Society Found" width="300"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/4b86ef38-e09c-4403-9264-f6cda3d41d95" alt="Manage Society Found" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/3b8903d3-1a8b-46c2-9975-1f0d920e1a79" alt="Manage Society Found" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/fe5a0a7e-9e0c-4eef-a4d4-15d207555bcc" alt="Manage Society Found" width="300"/></td>
  </tr>
   <tr>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/5d8f3ae7-8139-48f3-ba15-9719db144c64" alt="Manage Society Found" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/5ffa40eb-0a63-4985-98d7-62e494f003ab" alt="Manage Society Found" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/cf696b0f-3899-40c9-9ed2-87cfdc2c2b7e" alt="Manage Society Found" width="300"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/cec5a6de-4e7a-42f0-8df6-d3367a11a947" alt="Manage Society Found" width="300"/></td>
    <td><img src="https://github.com/ENT510/LGF_Banking/assets/145626625/5b29c056-5ae6-4852-8a62-5ef69025fe8d" alt="Manage Society Found" width="300"/></td>
  </tr>
</table>



`LGF_Banking` is a comprehensive banking system designed for game servers, offering secure `PIN management`, customizable `credit card creation`, and seamless integration with popular frameworks like `LGF`, `ESX`, and `QB`. Enhance your server's financial interactions with real-time updates and advanced features tailored for an immersive player experience.

### Framework Support

- [x] **LGF_CORE**
- [x] **ESX**
- [x] **QB**

# Support Resources

### Skill Check Support

- Choose between `OX Lib` and [BL UI](https://github.com/Byte-Labs-Studio/bl_ui) for skill checks and configure multiple presets with various difficulty levels:

- OX Lib: Implement skill checks efficiently using `OX Lib` robust functionality. Customize presets for different difficulty levels, including easy, normal, hard, and insane.

- Integrate [BL UI](https://github.com/Byte-Labs-Studio/bl_ui) seamlessly into your server's user interface for enhanced functionality. Configure presets specifically for `Circle Progress` and `Progress` skill checks. Adjust `difficulty` levels to tailor the experience to your players' needs.

# Framework/Core Configuration

# Features

### Hacking Features

- **PIN Restoration**: Allows restoring the PIN if forgotten
- **Create Fake Card**: Create fake cards to find yourself in pure RP situations, manage every metadata value
- **TIME heist Restoration**: Optimize time and hack time restore for heists removing cooldown with hack tool
- **Crafting Tools**: Create tools dedicated to robberies and hacking using the 3D printer
- **Tools Shop**: Support Shop Items in ox to Buy Tool
- **Steal NPC**: Credit card clone provider
  
### Multi Core Support

- Supports: `lgf`, `esx`, `qb`

### Multi Notify System Support

- Supports: `lgf`, `esx`, `qb`, `ox`

### SQL Table Execution and Creation

- Execute and create SQL table: `CB.RunSqlTable`

### Credit Card Configuration

- **Credit Card Item**:
  - `CB.ItemCreditCard`
- **Credit Card Purchase Price**:
  - `CB.PriceCreditCard`
- **Fake Credit Card Item**:
  - `CB.ItemFakeCreditCard`

### Progress Bar Type

- Type: `CB.TypeProgressBar` (`circle` or `label`)

### ATM Prop Models

- Models: `CB.PropAtm`

### Bank Zones and Configuration

- Zones: `CB.BankingZone`

### SkillCheck

- **Difficulty Levels**:
  - `easy`, `normal`, `hard`, `insane`
- **SkillCheck Type**:
  - `CB.SkillCheckType`

### Enable Camera for Ped

- Enable: `CB.EnableCam`


<hr style="border-radius: 50%; margin: 0 25px;">


### Fake Credit Card Configuration

- Configuration: `CB.FakeCreditCard`
- **Fake Credit Card Sellers**:
  - Position: `PedPosSell`
  - Model: `PedModelSell`
  - Scenario: `PedScenarioSell`
  - Price:
    - Fake Card: `PriceFakeCard`
    - Hack Pin: `PriceHackPin`
  - SkillCheck: `SkillCheck`
  - **Customization Options**:
    - Choose Name
    - Choose Image
    - Manage Metadata
    - Set Weight


<hr style="border-radius: 50%; margin: 0 25px;">


### Dispatch Configuration

- **Configuration**: `CB.UseDispatchInternal`
  - **Use Dispatch Internal for Robbery**
    - **Job**: `CB.DistPatchJob`
      - Choice of MultiJob {'police', 'ambulance'}
    - **Duration**: `DurationBlipDispatch`
- **Configuration**: `CB.UseCustomDispatch`
  - Get player `id`, `coordinates`, `job`
  - Custom Dispatch:
    - Return `playerId`, `coords`, `job`
      
    ```lua
    CB.UseCustomDispatch = true
    CB.CustomDistPatch = function(playerId, coords, job)
        print(playerId, coords, job)
    end
    ```


<hr style="border-radius: 50%; margin: 0 25px;">


### Robbery Configuration

- **Configuration**: `CB.BankingZone`
  - **Zone for Starting the Robbery**: `RobberyZone`
  - **Item Requested for Robbery**: `ItemRequestedRobbery`
  - **Quantity of Item Requested for Robbery**: `QntItemRequested`
  - **Robbery Drop Items**: `RobberyDrop`
    - **Minimum and Maximum Quantity for Drop Items**
      - Example:
     ```lua
        RobberyDrop = {
            ['money'] = { min = 20, max = 50 },
            ['water'] = { min = 4, max = 10 },
        },
    ```
  - **Skill Check Configuration**: `SkillCheck`
    - **Enable or Disable Skill Check**: `Enable`
    - **Skill Check Difficulty**
    - **Skill Check Type**
  - **Hacking Provide**
    - Optimize time and hack time restore for heists removing cooldown with `hack tool`
    - Make tools to rob or hack with `3d printer tool`
   

<hr style="border-radius: 50%; margin: 0 25px;">


### Printer Configuration


  - **3D Printer Configuration**: `CB.CraftingPrinter`
    - Weather System
      - when there is rain the printer will have two more description options with the current weather, and if it rains it cannot be used, and a further option will be shown with a warning,
    - Label
      - (Label in 3D printer menu)
    - itemHash
      - (Hash Items)
    - itemRequested
      - (Item requested for Craft Tool or Weapon)
    - ItemRequestedQnt
      - (Quantity requested for Craft Tool or Weapon)
    - Description
      - (Provide Description in menu)
    - CraftingTime
      - (Crafting Time with Progress Bar)
    - propHash
      - (Hash Prop for Create object in 3D Printer. Prop Object: thttps://gtahash.ru/)
        - Minimum and Maximum Quantity for Craft Tools
    - Battery
        - Recharge the battery via item
              - Example:
```lua
   CB.CraftingPrinter = {
    { Label = 'Weapon Pistol',  itemHash = 'WEAPON_PISTOL',       ItemRequestedPrint = 'water', ItemRequestedQnt = 3, Description = 'A standard issue pistol with moderate damage and accuracy.', CraftingTime = 20, propHash = 'w_pi_pistol' },
    { Label = 'Carabine Rifle', itemHash = 'WEAPON_CARBINERIFLE', ItemRequestedPrint = 'water', ItemRequestedQnt = 5, Description = 'A submachine gun with high fire rate and decent damage.',    CraftingTime = 20, propHash = 'w_ar_carbinerifle' }
}
```

<hr style="border-radius: 50%; margin: 0 25px;">

### Admin Panel Printer

LGF_Banking includes an Admin Panel Printer feature that allows authorized users to manage 3D printers in real-time. This feature is essential for server administrators to control and maintain the printer entities efficiently.

#### Key Features:
- **Delete Object in Real-Time all sync**: Admins can instantly remove a 3D printer object from the game world.
- **Delete Object in Real-Time all sync**: Admins can restore a 3D printer object, making it functional again in the game world.

  - **Admin Panel Printer**: `convars`
    - Printer Data
      - Get data like name, battery, serial code
        - Delete Printer for player (if the object is spawned it will be eliminated wherever it is)
        - Restore Specific Printer

<hr style="border-radius: 50%; margin: 0 25px;">

### NPC Robbery System

LGF_Banking now includes a feature for robbing NPCs, adding a dynamic and interactive element to your server. This allows players to engage in robbery scenarios with NPCs, providing rewards and consequences based on their actions.

#### Key Features:
- **Interactive Progress Bar**: A visible progress bar indicates the time required to complete the robbery.
- **Distance Checks**: Ensures the player stays within a specific distance of the NPC during the robbery.
- **NPC Reaction**: NPCs will react aggressively if the player gets too close or too far, creating a challenging and immersive experience.

### Stealing NPC Configuration

Customize the settings for the NPC robbery system to tailor the experience to your server's needs.

- CardstealItem: Specify the item used for stealing from NPCs.
- TimeStealing: Set the duration, in seconds, for completing the robbery.
- DistanceCancelSteal: Define the distance, in meters, that triggers the cancellation of the robbery if the player moves away.
- DistanceStartAngryorScaried: Determine the proximity, in meters, at which the player can trigger the NPC's aggressive or frightened reaction.
- Price:
  - **min**: Set the minimum value of the stolen loot.
  - **max**: Set the maximum value of the stolen loot.


<hr style="border-radius: 50%; margin: 0 25px;">



# Bank Robbery Configuration

`LGF_Banking` supports customizable bank robberies, enabling players to engage in heists with randomized loot items. You can adjust various aspects of bank robberies, including loot items, hacking challenges, and the dispatch system.

### Initiating a Bank Robbery

To initiate a bank robbery, players must interact with a designated object within the bank area. Once the robbery commences, players may encounter hacking challenges or other obstacles that they must overcome to succeed in the heist.

### Robbery Loot Items

You have the option to configure the loot items available to players during bank robberies. These items can be randomized to introduce variety and excitement to the robbery experience, offering players a chance to obtain different rewards each time they engage in a heist.

### Dispatch System

`LGF_Banking` provides two alternatives for handling robbery notifications: internal dispatch and custom dispatch.

- **Internal Dispatch**: Automatically sends robbery notifications to all players, complete with blip and position indicators.

- **Custom Dispatch**: Grants you the flexibility to customize how robbery notifications are managed, allowing for more control over the notification process. With custom dispatch, you can define specific actions or alerts triggered when a robbery occurs, such as notifying law enforcement or broadcasting messages to nearby players. This option offers a tailored approach to managing robbery events on your game server.

### Hacktool Item for Cooldown Deviation

In addition to the standard cooldown mechanism, `LGF_Banking` allows players to deviate the cooldown using a special hacktool item. When used, this item can bypass or reduce the cooldown period, providing players with more strategic options during bank heists.

<hr style="border-radius: 50%; margin: 0 25px;">

# Society Funds Management (Boss Exclusive)

- **Feature**: Ability to manage society funds
  - The feature enables the management of society funds, allowing actions such as `deposit` or `withdraw`.
- **Access**: Restricted to boss roles within each framework
  -  Restricted to boss roles within each framework, ensuring control and preventing misuse by limiting access to authorized personnel.


<hr style="border-radius: 50%; margin: 0 25px;">


# Items Preconfigured

## Register Item in Ox Inventory

<hr style="border-radius: 50%; margin: 0 25px;">


```lua
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
		description = 'A tool for steal money from ped.',
	},
	['stealing_card'] = {
		label = 'Civil Credit Card',
		weight = 20,
		stack = false,
		description = 'A Credit Card Stealed by a civik.',
	},
}
```

<hr style="border-radius: 50%; margin: 0 25px;">


- All: `exports`
  **Server Side Exports**:

```lua
-- Create Fake Card With Params
exports.LGF_Banking:CreateCreditCard(source, metadata)
-- Change Pin Directly
exports.LGF_Banking:ChangePin(data)
```

# Exports Usage (Server Side)

## Create Credit Card

## Using the `CreateCreditCard` exports

The `CreateCreditCard` exports allows you to create a credit card in the game with customized metadata.

```lua
exports.LGF_Banking:CreateCreditCard(source, metadata)
```

`source`: The player ID requesting the creation of the credit card.
`metadata`: A table containing custom data for the credit card.

# Example Usage

```lua
RegisterCommand('getCard', function(source, args)
    local metadata = {
        label = 'My Custom Credit Card',
        description = 'My Custom Credit Card Description',
        type = "Custom Card Type",
        price = 0,
        itemHash = 'burger',
        weight = 10,
        imageUrl = 'nui://ox_inventory/data/images/' .. itemname .. '.png'
    }
    exports.LGF_Banking:CreateCreditCard(source, metadata)
end)

RegisterCommand('getCard2', function(source, args)
    exports.LGF_Banking:CreateCreditCard(source, {
        label = 'My Custom Credit Card',
        description = 'My Custom Credit Card Description',
        type = "Custom Card Type",
        price = 0,
        itemHash = 'burger',
        weight = 10,
        imageUrl = 'nui://ox_inventory/data/images/' .. itemname .. '.png'
    })
end)
```

- This format should be clearer and more structured for users to understand how to use your script.

# Change PIN (Using the ChangePin exports)

The `ChangePin` exports allows you to change the PIN associated with a player's identifier.

```lua
exports.LGF_Banking:ChangePin(data)
```

`data`: A table containing the player's identifier and the new PIN.

# Example Usage (using LegacyFramework)

```lua
RegisterCommand('newpin', function(source)
    local playerData = LGF.SvPlayerFunctions.GetPlayerData(source)[1]
    local IDent = playerData.charName
    exports.LGF_Banking:ChangePin({
        identifier = IDent, -- identifier
        pin = "1998" -- new pin (string or boolean)
    })
end)
```

- This function allows you to easily update a player's PIN by specifying their `identifier` and the new `PIN`.

# License GPL 3.0

```
LGF_Banking Version 1.0

LGF_Banking is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

LGF_Banking is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with LGF_Banking. If not, see https://www.gnu.org/licenses/gpl-3.0.html for the full text of the license.

LGF_Banking is based on open-source code and contributions from the community. It was created by ENT510.

Every contribution is welcome and appreciated.

```
