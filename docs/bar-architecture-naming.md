# Bar Architecture And Naming

This document defines shared names for the Quickshell bar structure. Use these names when discussing layout bugs or requesting changes so the target component and container layer are unambiguous.

## Source Files

- `modules/ii/bar/Bar.qml`: creates one bar `PanelWindow` per screen.
- `modules/ii/bar/BarContent.qml`: main bar layout and the three visual sections.
- `modules/ii/bar/BarGroup.qml`: pill-shaped Layer 1 container used around grouped bar widgets.
- `DynamicIslandWindow.qml`: separate overlay window for the Dynamic Island. It is not a child of the bar.
- `modules/common/Appearance.qml`: color layer and size definitions.

## Top-Level Hierarchy

```text
Bar.qml
└─ barRoot: PanelWindow
   └─ hoverRegion: MouseArea
      └─ barContent: BarContent
         ├─ barBackground: Rectangle
         ├─ barLeftSideMouseArea: FocusedScrollMouseArea
         ├─ middleSection: RowLayout
         └─ barRightSideMouseArea: FocusedScrollMouseArea
```

`barRoot` is the actual bar window. It is transparent by itself. The visible full-width bar background is `barBackground` inside `BarContent.qml`.

The Dynamic Island is a separate `PanelWindow` in `DynamicIslandWindow.qml`, using the overlay layer. It is not inside `barRoot` or `barContent`. The bar only reserves visual space for it with `islandPlaceholder`.

## Background Layers

Use these layer names when talking about colors or backgrounds:

```text
Layer 0: barBackground
Layer 1: BarGroup background
Layer 2: RippleButton / CircleUtilButton / child button background
Content: text, icons, progress bars, symbols
```

### Layer 0: Bar Background

Name: `barBackground`

Location: `BarContent.qml`

Type: `Rectangle`

Color: `Appearance.colors.colLayer0` when `Config.options.bar.showBackground` is enabled, otherwise transparent.

Role: full bar surface behind all left, middle, and right sections.

### Layer 1: BarGroup Background

Name: `BarGroup.background`

Location: `BarGroup.qml`

Type: `Rectangle` inside `BarGroup`

Color: `Appearance.colors.colLayer1`, or transparent when `Config.options.bar.borderless` is enabled.

Role: pill-shaped grouped-widget background. Examples: workspaces group, system/media group, clock/tools/battery group, weather group.

Important: `BarGroup` is not just a layout. It is an `Item` containing a background `Rectangle` plus an internal `GridLayout`.

### Layer 2: Button Background

Name: `RippleButton.background` or specific button background

Location: `RippleButton.qml` and button components such as `LeftSidebarButton.qml`, `CircleUtilButton.qml`

Type: usually a `Rectangle`

Color: hover/toggled/ripple state colors, such as `colLayer1Hover`, `colSecondaryContainer`, or button-specific colors.

Role: interactive surface for buttons.

## Main Sections

The bar is divided into three major sections:

```text
[Left Section] [Middle Section] [Right Section]
```

### Left Section

Standard name: `leftSection`

Root object: `barLeftSideMouseArea`

Layout object: `leftSectionRowLayout`

Type: `FocusedScrollMouseArea` containing a `RowLayout`

Behavior: scrolling changes brightness.

Background: no local background; it shows `barBackground` underneath, except for child button/group backgrounds.

Hierarchy:

```text
barLeftSideMouseArea
└─ leftSectionRowLayout
   ├─ leftSidebarButton: LeftSidebarButton / RippleButton
   ├─ workspacesGroup: BarGroup
   │  └─ Workspaces
   └─ ActiveWindow
```

Components:

- `leftSidebarButton`: opens/toggles the left sidebar. It is a `RippleButton`, so it has its own button background.
- `workspacesGroup`: anonymous `BarGroup` wrapping `Workspaces`. This group has a Layer 1 background.
- `Workspaces`: workspace display and workspace interaction content.
- `ActiveWindow`: focused window title/app info. It has no dedicated background and uses `Layout.fillWidth: true` to consume remaining left-section width.

Width behavior:

- The left section stretches from the screen left edge to `middleSection.left`.
- `ActiveWindow` is flexible and may shrink or expand with available space.
- Moving `barLeftSideMouseArea` moves all of its children.
- Moving only `ActiveWindow` does not move the section background because there is no local section background.

### Middle Section

Standard name: `middleSection`

Root object: `middleSection`

Type: `RowLayout`

Behavior: horizontally centered; contains the island placeholder and natural-width groups.

Background: no section-level background. Child `BarGroup` objects provide visible pill backgrounds.

Hierarchy:

```text
middleSection: RowLayout
├─ leftBalanceSpacer: Item
├─ leftCenterGroup: BarGroup
│  ├─ resourcesWidget: Resources
│  └─ mediaWidget: Media
├─ islandPlaceholder: Item
├─ rightCenterGroupContent: BarGroup
│  ├─ ClockWidget
│  ├─ UtilButtons
│  └─ BatteryIndicator
└─ rightBalanceSpacer: Item
```

#### Left Center Group

Standard name: `leftCenterGroup`

Human name: system/media group, or system-media pill

Type: `BarGroup`

Background: Layer 1, `Appearance.colors.colLayer1`

Children:

- `resourcesWidget`: the system resource component.
- `mediaWidget`: the media component.

Width behavior:

- The group width follows its content through `BarGroup.implicitWidth`.
- It is clipped in the current layout so long media text does not visually spill toward the island.
- `mediaWidget` has a maximum/preferred width constraint in `BarContent.qml` so long titles elide before reaching the island placeholder.

Movement behavior:

- Moving `leftCenterGroup` moves its background, `Resources`, and `Media` together.
- Moving `Resources` only moves the resource content; it does not move the group background.
- Moving `BarGroup.background` only moves the background and should normally be avoided.

#### Resources Component

Standard name: `resourcesWidget`

Human name: system resources, system info component

Type: `Resources`, implemented as a `MouseArea`

Own background: none.

Visible background: inherited from parent `leftCenterGroup` BarGroup.

Hierarchy:

```text
leftCenterGroup: BarGroup
└─ Resources: MouseArea
   └─ rowLayout
      ├─ Resource(memory)
      ├─ Resource(swap)
      └─ Resource(cpu)
```

Important wording: if discussing the visible background around the system resource component, call it the `leftCenterGroup BarGroup background`, not the `Resources background`.

#### Media Component

Standard name: `mediaWidget`

Type: `Media`, implemented as an `Item`

Own background: none.

Visible background: inherited from parent `leftCenterGroup` BarGroup.

Width behavior:

- Natural width for normal content.
- Width-capped in the middle section so long title/artist text is elided/clipped before it reaches `islandPlaceholder`.

#### Island Placeholder

Standard name: `islandPlaceholder`

Human name: island reserved space, island gap

Type: empty `Item`

Background: none.

Content: none.

Width binding: `Layout.preferredWidth: root.islandCapsuleWidth`

Role: reserves bar space equal to the current Dynamic Island capsule width.

Important: this is not the Dynamic Island itself. The real island is a separate overlay `PanelWindow` in `DynamicIslandWindow.qml`.

#### Right Center Group

Standard name: `rightCenterGroupContent`

Human name: clock/tools/battery group, or time-tools pill

Type: `BarGroup`

Background: Layer 1, `Appearance.colors.colLayer1`

Children:

- `ClockWidget`: time/date display. Click toggles the right sidebar.
- `UtilButtons`: utility button row.
- `BatteryIndicator`: battery display.

Width behavior:

- Width follows content through `BarGroup.implicitWidth`.
- Adding utility buttons expands this group.
- The group should not use a fixed center-side width.

Movement behavior:

- Moving `rightCenterGroupContent` moves the background, clock, utility buttons, and battery together.
- Moving `ClockWidget`, `UtilButtons`, or `BatteryIndicator` only moves that child content.

### Right Section

Standard name: `rightSection`

Root object: `barRightSideMouseArea`

Layout object: `rightSectionRowLayout`

Type: `FocusedScrollMouseArea` containing a `RowLayout`

Behavior: scrolling changes volume.

Background: no local background; it shows `barBackground` underneath, except for child button/group backgrounds.

Important layout detail: `rightSectionRowLayout` uses `layoutDirection: Qt.RightToLeft`, so visual order and code order should be interpreted carefully.

Hierarchy:

```text
barRightSideMouseArea
└─ rightSectionRowLayout: RowLayout, RightToLeft
   ├─ rightSidebarButton: RippleButton
   │  └─ indicatorsRowLayout
   │     ├─ volume muted indicator
   │     ├─ mic muted indicator
   │     ├─ HyprlandXkbIndicator
   │     ├─ NotificationUnreadCount
   │     ├─ Network icon
   │     └─ Bluetooth icon
   ├─ SysTray
   ├─ fill spacer: Item
   └─ weatherGroup: BarGroup
      └─ WeatherBar
```

Components:

- `rightSidebarButton`: right sidebar/status indicator button. It is a `RippleButton`, not a `BarGroup`.
- `indicatorsRowLayout`: row of status icons inside `rightSidebarButton`.
- `SysTray`: system tray.
- `weatherGroup`: `BarGroup` created by a `Loader`.
- `WeatherBar`: weather content inside `weatherGroup`.

Width behavior:

- `rightSidebarButton` width follows `indicatorsRowLayout.implicitWidth + padding`.
- `SysTray` has `Layout.fillWidth: false`.
- The fill spacer consumes empty space inside the right section.
- `weatherGroup` width follows `WeatherBar` content.

Background behavior:

- `rightSidebarButton` has a Layer 2 button background controlled by hover/toggled state.
- `WeatherBar` has no own background; its visible background is `weatherGroup` BarGroup Layer 1.

## Covering And Z-Order Rules

Within one QML item tree, later siblings normally paint above earlier siblings unless explicit `z` values are used. In the bar, normal anchors and layouts are intended to prevent overlap.

Inside `BarContent.qml`, the practical paint order is:

```text
barBackground
barLeftSideMouseArea
middleSection
barRightSideMouseArea
```

Inside `BarGroup`:

```text
BarGroup Item
├─ background Rectangle
└─ gridLayout with children
```

So BarGroup children paint above the BarGroup background.

Inside `RippleButton`:

```text
RippleButton
├─ background Rectangle
│  └─ ripple
└─ contentItem
```

So button content paints above the button background and ripple surface.

Cross-window rule:

- The Dynamic Island is not a child of the bar.
- It is a separate overlay window.
- Bar-internal `z` ordering cannot place bar content above the Dynamic Island.
- To avoid visual collision with the island, change bar layout or `islandPlaceholder`, not QML `z` inside `BarContent`.

## Movement Rules

Use these rules when deciding what should move together:

- Move `barRoot`: moves the entire bar window.
- Move `barContent`: moves the bar background and all three sections.
- Move `barBackground`: moves only the Layer 0 background, not the child widgets.
- Move `barLeftSideMouseArea`: moves the whole left section.
- Move `middleSection`: moves both center groups, island placeholder, and balance spacers.
- Move `leftCenterGroup`: moves its Layer 1 background plus `Resources` and `Media`.
- Move `resourcesWidget`: moves only the system resource content; the group background stays put.
- Move `rightCenterGroupContent`: moves its Layer 1 background plus clock, utility buttons, and battery.
- Move `barRightSideMouseArea`: moves the whole right section.
- Move `rightSidebarButton`: moves the button background and all status indicators inside it.
- Move `WeatherBar`: moves only weather content; the `weatherGroup` BarGroup background stays put.

## Width Rules

- `barRoot` spans the screen width.
- `barContent` spans the bar window width.
- `barLeftSideMouseArea` spans from the left edge to `middleSection.left`.
- `barRightSideMouseArea` spans from `middleSection.right` to the right edge.
- `middleSection` uses its implicit content width and is horizontally centered.
- `BarGroup` width is content-driven: `gridLayout.implicitWidth + padding * 2`.
- `islandPlaceholder` width is dynamic and follows `root.islandCapsuleWidth`.
- `ActiveWindow` is flexible and fills leftover width in the left section.
- `Media` is content-driven but capped in the middle section to avoid island overlap.
- `rightCenterGroupContent` expands when more utility buttons are visible.

## Standard Names To Use In Discussion

| Human name | Code name | Type | Background owner |
| --- | --- | --- | --- |
| bar window | `barRoot` | `PanelWindow` | none, transparent |
| bar content root | `barContent` | `BarContent` / `Item` | contains `barBackground` |
| bar large background | `barBackground` | `Rectangle` | itself, Layer 0 |
| left section | `barLeftSideMouseArea` | `FocusedScrollMouseArea` | none |
| left layout row | `leftSectionRowLayout` | `RowLayout` | none |
| left sidebar button | `leftSidebarButton` | `LeftSidebarButton` / `RippleButton` | button background, Layer 2 |
| workspace group | `workspacesGroup` | `BarGroup` | BarGroup background, Layer 1 |
| workspaces | `Workspaces` | `Item` | parent BarGroup |
| active window | `ActiveWindow` | `Item` | none |
| middle section | `middleSection` | `RowLayout` | none |
| system/media group | `leftCenterGroup` | `BarGroup` | BarGroup background, Layer 1 |
| system resources | `resourcesWidget` / `Resources` | `MouseArea` | parent BarGroup |
| media widget | `mediaWidget` / `Media` | `Item` | parent BarGroup |
| island reserved space | `islandPlaceholder` | `Item` | none |
| clock/tools/battery group | `rightCenterGroupContent` | `BarGroup` | BarGroup background, Layer 1 |
| clock | `ClockWidget` | `Item` | parent BarGroup |
| utility buttons | `UtilButtons` | `Item` | parent BarGroup plus child buttons |
| battery | `BatteryIndicator` | `MouseArea` | parent BarGroup |
| right section | `barRightSideMouseArea` | `FocusedScrollMouseArea` | none |
| right layout row | `rightSectionRowLayout` | `RowLayout` | none |
| right sidebar/status button | `rightSidebarButton` | `RippleButton` | button background, Layer 2 |
| status indicators | `indicatorsRowLayout` | `RowLayout` | parent button |
| system tray | `SysTray` | tray component | none / tray item internals |
| weather group | `weatherGroup` | `BarGroup` | BarGroup background, Layer 1 |
| weather content | `WeatherBar` | `MouseArea` | parent BarGroup |
| Dynamic Island | real island window | `PanelWindow` in `DynamicIslandWindow.qml` | island's own window/components |

## Preferred Question Format

When asking for a change, try to identify four things:

1. Section: left section, middle section, or right section.
2. Container: for example `leftCenterGroup`, `rightCenterGroupContent`, `rightSidebarButton`, `weatherGroup`.
3. Layer: Layer 0 bar background, Layer 1 BarGroup background, Layer 2 button background, or content.
4. Desired behavior: width, position, visibility, hover color, click area, clipping, or movement.

Examples:

- "In the middle section, move `rightCenterGroupContent` closer to `islandPlaceholder` without changing the width of `ClockWidget`."
- "Change the Layer 1 background of `leftCenterGroup`, not the `Resources` content itself."
- "The `Media` content should shrink before touching `islandPlaceholder`; do not move the real Dynamic Island."
- "The `rightSidebarButton` hover background is too tall; adjust the Layer 2 button background, not the whole right section."
- "Move the weather pill by moving `weatherGroup`, not `WeatherBar`, so the background follows the content."

