> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# How To Implement Swipe To Refresh In Arkts Wearable Apps

This is a pull-to-refresh message list for HarmonyOS Next wearable. It has a Refresh component wired to the list, a state-driven loading indicator, pull-up to load more, an unread dot on fresh rows, and mock data behind a repository seam, all in a light MVVM structure so the mock can be swapped for a real API without touching the UI.

# Preview
<div>
 <img src="./screenshots/1.gif" width="25%"/>
</div>

# Use Cases
- Wiring the Refresh component to a List on a wearable target
- Binding a data fetch to the pull-to-refresh gesture
- Driving a custom refreshing indicator and header from the refresh status
- Handling the full loading lifecycle: skeleton, refreshing, success, and error
- Animating the new rows on arrival and flashing a new-messages badge
- Marking freshly pulled rows unread with a dot that auto-clears
- Pulling up at the bottom to load older messages with a footer loader

# Tech Stack

- **Languages**: ArkTS
- **Frameworks**: HarmonyOS SDK 6.1.0(23)
- **Tools**: DevEco Studio Vers 6.0.1.251
- **Libraries**: 
  - @kit.ArkUI, 
  - @kit.CryptoArchitectureKit

# Directory Structure
```
├── entry/
   └── src/main/
       └── ets/
           ├── entryability/EntryAbility.ets
           ├── entrybackupability/EntryBackupAbility.ets
           ├── model/
           │   └── Message.ets
           ├── data/
           │   ├── MessageRepository.ets
           │   └── MockMessageRepository.ets
           ├── viewmodel/
           │   └── MessageListViewModel.ets
           ├── view/
           │   └── components/MessageCard.ets
           ├── util/
           │   ├── SecureRandom.ets
           │   └── TimeFormat.ets
           └── pages/
               ├── Index.ets
               └── IndexArcList.ets
```

# Constraints and Restrictions

## Supported Devices
- Huawei Watch 5

## Note
- The app runs entirely on mock data and is not connected to any backend or API. It needs no network permission or live endpoint. Swapping the repository implementation is all it takes to connect a real service.

# License
**How to Implement Swipe-to-Refresh in ArkTS Wearable Apps** is distributed under the terms of the MIT License.
See the [LICENSE](./LICENSE) for more information.