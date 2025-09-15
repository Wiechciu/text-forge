# Themes in Text Forge
Text Forge supports customizable themes for UI elements. This page explains how themes work, how to 
create your own, and how to install or share them.

## Theme Strcuture
Each theme is defined as a `.tres` file. This file is a Godot (text-based) resource in INI style.
With this file you can apply changes to any UI element style.

## Getting Themes
Text Forge has some internal themes:

- Dark (default) `dark`

You can find other themes here:

- [Text Forge awsome themes](https://text-forge.github.io/awsome-themes)

## Installing Themes
To install new themes, you can use **Settings > Open Data Folder**, then go to `themes/` folder and
paste theme `.tres` file there.

!!! Note

    You can use installed themes without restart.

## Changing Editor Theme
For changing theme, go to **Settings > Preferences > Editor UI > Theme Name** and enter your theme
file name (without `.tres`). When you close Preferences window editor will load new theme.

## Creating a Theme
If you want to create new themes, you must create it inside Godot, there is a guide about opening
Text Forge source in Godot:

- [Build Text Forge from source](build.md)

Then, you can edit `res://data/themes/dark.tres` in Godot Theme Editor or create new theme in this
folder. When your theme completed, change its name and share it. You can test it directly, editor
will copy `res://data/themes/` content to `user://themes/` when you run it.

## Themes Location
Editor loads all themes from `themes/` folder in editor data folder, for internal themes you can see
`res://data/themes/`.