# Roblox Studio setup

Create this structure:

ReplicatedStorage
- Folder: Remotes
  - RemoteEvent: BuySquishy
  - RemoteEvent: StealSquishy
  - RemoteEvent: LockBase
  - RemoteEvent: UpgradeBase
- ModuleScript: SquishyConfig

ServerScriptService
- Script: GameServer

StarterPlayer
- StarterPlayerScripts
  - LocalScript: GameClient

Workspace
- Folder: Bases
  - Models: Base1 through Base6
  - Each base should contain Parts named Spawn and Deposit
- Folder: Conveyor
  - Parts named Start and End

The server can generate placeholder bases if they are missing. Custom models and map geometry can be added later.
