# Text Forge Menus
## Introduction
In TextForge, we use menus as the main way to edit with the help of Action Scripts and dynamic command structure.

This guide has tried to explore the tips for menu options. 

## File
This menu includes regular actions with working with files and the editor window. 

### New
Opens a new file. It doesn't activate any mode, so it's recommended to save it after creating a new file and then continue editing. 

### New Window
Opens another window of the editor. Due to the lack of support for multi-file editing (currently), this is a good way to work with multiple files. 

### New With Template

!!! Note
		
	It is not yet available. 

### Open
Creates a pop-up to select and open an existing file. 

### Recent Files
It lists recently opened files, clicking on any file will open that file. 

### Save
Saves the open file, if the file doesn't have a specific location (e.g. created with the New option) it will be the same as Save. 

### Save As
It creates a pop-up to choose a location and name to save the open file. 

### Reload
It reloads the open file, similar to reopening the same file. 

!!! Note

	Some functions may not work properly after saving a file, in which case please report the problem and use Reload as a temporary solution. 

### Close
It closes the open file, without closing the editor. 

### Create Backup
Saves a manual backup of the open file, use Load From Backup to restore. Go to Preferences for automatic backups. 

### Load From Backup
It displays a list of available backups by file and time, restored by clicking on the file version. 

!!! Warning

	This is an experimental feature.

### Copy Path
Copies the path of the open file to the clipboard. 

### Show In FileSystem
It displays the open file in the system files. 

### Secure Delete
It deletes the file completely, fills the entire content of the file with zero bits, and then deletes. 

### Restart
Similar to New Window but closes the current window. 

### Exit
Closes the editor. 

## Edit
This menu contains commands and actions related to editing the content of the file. 

### Undo
It takes a step back in memory. 

### Redo
It returns the last Undo. 

### Cut
Copies the selected text to the clipboard and deletes it in the file. It does this for the entire line if no text is selected. This option is also available in the context menu. 

### Copy
Copies the selected text (or entire line) to the clipboard. This option is also available in the context menu. 

### Paste
Paste the latest clipboard content (instead of the selected text). This option is also available in the context menu. 

### Delete
Deletes the selected text or the next character. 

### Select All
Selects all file content. 

### Select Next Occurrence 
The next occurrence selects the selected text and keeps the current selections. If no text is selected, it selects the current word. 

### Select All Occurrences 
This operation repeats the Select next occurrence until there is an occurrence. 

### Duplicate Selection 
Duplicates the selected text and selects duplicated text.

### Evaluate Selection
Evaluates the selected text. 

### Line
It puts the actions related to the line in a group. 

#### Move Lines Up
Lines with caret or selection move up one line. 

#### Move Lines Down
Lines with caret or selection move down one line. 

#### Indent
The selected lines are taken one block further in. 

#### Unindent
It brings out the selected lines one block further. 

#### Delete Lines
Removes the entire content of selected lines.

#### Toggle Comment
It converts the line into a comment or vice versa. 

!!! Warning

	This is an experimental feature.

#### Duplicate Lines
It duplicates the selected lines and selects the duplicated lines. 

#### Select Whole Line
Extends the selection to the entire line(s). 

#### Select Paragraph 
It expands the selection to the point where there is a blank line. 

#### Join Lines
It joins the selected lines, leaving a space between each line. 

#### Move To New File
opens a new file and moves the selected lines to that file. 