# LGF_Banking

## Configuratiom (Convars)

To configure `LGF_Banking`, follow these steps:

Open your `server.cfg` file: This file is usually located in your server's root directory.

Add the following lines to your `server.cfg` file: These settings allow you to set the language and enable debug mode for troubleshooting purposes.

```cfg
setr LGF_Banking:traduction en
setr LGF_Banking:debug "true"
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
</table>

`LGF_Banking` is a comprehensive banking system designed for game servers, offering secure `PIN management`, customizable `credit card creation`, and seamless integration with popular frameworks like `LGF`, `ESX`, and `QB`. Enhance your server's financial interactions with real-time updates and advanced features tailored for an immersive player experience.

## Framework Support

- [x] **LGF_CORE**
- [x] **ESX**
- [x] **QB**

# Support Resources

# Skill Check Support

- Choose between `OX Lib` and [BL UI](https://github.com/Byte-Labs-Studio/bl_ui) for skill checks and configure multiple presets with various difficulty levels:

- OX Lib: Implement skill checks efficiently using `OX Lib` robust functionality. Customize presets for different difficulty levels, including easy, normal, hard, and insane.

- Integrate [BL UI](https://github.com/Byte-Labs-Studio/bl_ui) seamlessly into your server's user interface for enhanced functionality. Configure presets specifically for `Circle Progress` and `Progress` skill checks. Adjust `difficulty` levels to tailor the experience to your players' needs.

# Framework/Core Configuration

## Features

### Multi Core Support

- Supports: `lgf`, `esx`, `qb`

### Multi Notify System Support

- Supports: `lgf`, `esx`, `qb`

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

### Enable Blip for all ATMs

- Enable: `CB.EnableAtmBlip`

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

### Hacking Features

- **PIN Restoration**: Allows restoring the PIN if forgotten

<hr style="border-radius: 50%; margin: 0 25px;">

### Society Funds Management (Boss Exclusive)

- **Feature**: Ability to manage society funds
  - The feature enables the management of society funds, allowing actions such as `deposit` or `withdraw`.
- **Access**: Restricted to boss roles within each framework
  -  Restricted to boss roles within each framework, ensuring control and preventing misuse by limiting access to authorized personnel.

<hr style="border-radius: 50%; margin: 0 25px;">

- All: `exports`
  **Server Side Exports**:

```lua
-- Create Fake Card With Params
exports.LGF_Banking:CreateCreditCard(source, metadata)
-- Change Pin Directly
exports.LGF_Banking:ChangePin(data)
```

<hr style="border-radius: 50%; margin: 0 25px;">

# Exports Usage

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

or

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
